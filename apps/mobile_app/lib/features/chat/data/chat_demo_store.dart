import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../../../shared/network/backend_api_client.dart';
import '../domain/chat_models.dart';
import 'chat_seed_data.dart';

class ChatDemoStore extends ChangeNotifier {
  ChatDemoStore._({BackendApiClient? apiClient})
      : _apiClient = apiClient ?? BackendApiClient();

  factory ChatDemoStore.testing({required BackendApiClient apiClient}) {
    return ChatDemoStore._(apiClient: apiClient);
  }

  static final ChatDemoStore instance = ChatDemoStore._();

  final BackendApiClient _apiClient;
  final List<ChatConversationDetail> _threads = <ChatConversationDetail>[];
  final Set<String> _openedConversationIds = <String>{};

  bool _isLoading = false;
  bool _hasLoaded = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  bool get hasLoaded => _hasLoaded;
  String? get errorMessage => _errorMessage;

  UnmodifiableListView<ChatConversationSummary> get conversations {
    final summaries = _threads.map(_summaryFor).toList(growable: false);
    return UnmodifiableListView<ChatConversationSummary>(summaries);
  }

  Future<void> ensureLoaded({bool force = false}) async {
    if (_hasLoaded && !force) {
      return;
    }

    _setLoading(true);
    _errorMessage = null;

    try {
      if (!_apiClient.isConfigured) {
        _replaceThreads(_previewThreads());
        _hasLoaded = true;
        return;
      }

      final remoteThreads = await _loadRemoteThreads();
      _replaceThreads(remoteThreads);
      _hasLoaded = true;
    } catch (error) {
      _errorMessage = error.toString();
      _replaceThreads(_previewThreads());
      _hasLoaded = true;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> reload() => ensureLoaded(force: true);

  ChatConversationDetail? conversationById(String id) {
    for (final thread in _threads) {
      if (thread.id == id) {
        return thread;
      }
    }
    return null;
  }

  Future<ChatConversationDetail> openConversation(String id) async {
    await ensureLoaded();
    final conversation = conversationById(id);
    if (conversation != null) {
      _openedConversationIds.add(id);
      notifyListeners();
      return conversation;
    }

    if (_threads.isNotEmpty) {
      final fallback = _threads.first;
      _openedConversationIds.add(fallback.id);
      notifyListeners();
      return fallback;
    }

    return startConversation();
  }

  Future<ChatConversationDeletion?> deleteConversation(String id) async {
    await ensureLoaded();
    final index = _threads.indexWhere((thread) => thread.id == id);
    if (index == -1) {
      return null;
    }

    final removed = _threads.removeAt(index);
    _openedConversationIds.remove(id);
    notifyListeners();
    return ChatConversationDeletion(
      conversation: removed,
      index: index,
    );
  }

  void restoreConversation(
    ChatConversationDetail conversation, {
    int? index,
  }) {
    final existingIndex =
        _threads.indexWhere((thread) => thread.id == conversation.id);
    _openedConversationIds.add(conversation.id);

    if (existingIndex != -1) {
      _threads[existingIndex] = conversation;
      notifyListeners();
      return;
    }

    final insertAt = index == null ? 0 : index.clamp(0, _threads.length).toInt();
    _threads.insert(insertAt, conversation);
    notifyListeners();
  }

  Future<ChatConversationDetail> startConversation({
    String? petId,
    String seedPrompt = 'Ciao, ho una domanda su questo pet.',
  }) async {
    await ensureLoaded();

    final targetPet = await _resolveTargetPet(petId);
    try {
      final response = await _apiClient.postJson('/chat', <String, dynamic>{
        'pet_id': targetPet.id,
        'user_message': seedPrompt,
      });
      final conversation = _mapConversationFromChatResponse(
        response,
        fallbackPet: targetPet,
      );
      _replaceOrInsertThread(conversation, asFirst: true);
      _openedConversationIds.add(conversation.id);
      notifyListeners();
      return conversation;
    } catch (_) {
      final conversation = _createLocalConversation(
        pet: targetPet,
        seedPrompt: seedPrompt,
      );
      _replaceOrInsertThread(conversation, asFirst: true);
      _openedConversationIds.add(conversation.id);
      notifyListeners();
      return conversation;
    }
  }

  Future<ChatConversationDetail> sendMessage(
    String conversationId,
    String message,
  ) async {
    await ensureLoaded();

    final cleanMessage = message.trim();
    if (cleanMessage.isEmpty) {
      final existing = conversationById(conversationId) ?? _threads.firstOrNull;
      if (existing != null) {
        return existing;
      }
      return startConversation();
    }

    final thread = conversationById(conversationId);
    final targetPet = thread == null
        ? await _resolveTargetPet()
        : await _resolveTargetPet(thread.petId);

    try {
      final response = await _apiClient.postJson('/chat', <String, dynamic>{
        'pet_id': targetPet.id,
        'conversation_id': thread?.id,
        'user_message': cleanMessage,
      });

      final conversation = _mapConversationFromChatResponse(
        response,
        fallbackPet: targetPet,
      );
      _replaceOrInsertThread(conversation);
      _openedConversationIds.add(conversation.id);
      notifyListeners();
      return conversation;
    } catch (_) {
      final existing = thread ??
          _createLocalConversation(
            pet: targetPet,
            seedPrompt: cleanMessage,
          );
      final updated = _appendLocalMessage(existing, cleanMessage);
      _replaceOrInsertThread(updated);
      _openedConversationIds.add(updated.id);
      notifyListeners();
      return updated;
    }
  }

  void reset() {
    _replaceThreads(_previewThreads());
    _hasLoaded = true;
    _errorMessage = null;
    notifyListeners();
  }

  ChatConversationSummary _summaryFor(ChatConversationDetail conversation) {
    final lastMessage = conversation.messages.isNotEmpty
        ? conversation.messages.last
        : ChatMessage(
            id: _messageId('summary'),
            author: ChatMessageAuthor.assistant,
            text: 'Nuovo thread pronto per essere usato.',
            timeLabel: 'adesso',
            createdAt: DateTime.now().toUtc(),
          );

    final unreadCount = _openedConversationIds.contains(conversation.id)
        ? 0
        : (lastMessage.author == ChatMessageAuthor.assistant ? 1 : 0);

    return ChatConversationSummary(
      id: conversation.id,
      title: conversation.title,
      subtitle: conversation.statusLabel,
      updatedAtLabel: _relativeTimeLabel(lastMessage.createdAt),
      unreadCount: unreadCount,
      activePetName: conversation.petName,
      previewMessage: lastMessage.text,
      lastSender: lastMessage.author == ChatMessageAuthor.assistant
          ? 'Assistente'
          : 'Tu',
      petId: conversation.petId,
    );
  }

  Future<List<ChatConversationDetail>> _loadRemoteThreads() async {
    final pets = await _loadPets();
    final petById = {for (final pet in pets) pet.id: pet};
    final response = await _apiClient.getCollection(
      '/conversations',
      'conversations',
    );

    final threads = response
        .map(
          (row) => _mapConversationFromRow(
            row,
            petById: petById,
          ),
        )
        .toList(growable: false)
      ..sort((left, right) =>
          _conversationSortKey(right).compareTo(_conversationSortKey(left)));

    return threads;
  }

  Future<List<_BackendPet>> _loadPets() async {
    final response = await _apiClient.getCollection('/pets', 'pet_profiles');
    return response
        .map(
          (row) => _BackendPet(
            id: (row['id'] ?? '').toString(),
            name: (row['name'] ?? 'Pet').toString(),
            species: (row['species'] ?? 'Pet').toString(),
          ),
        )
        .where((pet) => pet.id.isNotEmpty)
        .toList(growable: false);
  }

  Future<_BackendPet> _resolveTargetPet([String? petId]) async {
    final pets = await _loadPets();
    if (pets.isNotEmpty) {
      if (petId != null) {
        for (final pet in pets) {
          if (pet.id == petId) {
            return pet;
          }
        }
      }
      return pets.first;
    }

    final previewPetId = _previewThreads().first.petId ?? 'demo-pet-moka';
    return _BackendPet(
      id: petId ?? previewPetId,
      name: 'Moka',
      species: 'Cane',
    );
  }

  ChatConversationDetail _mapConversationFromRow(
    Map<String, dynamic> row, {
    required Map<String, _BackendPet> petById,
  }) {
    final petId = row['pet_id']?.toString();
    final pet = petId == null ? null : petById[petId];
    final messages = _mapMessages(row['messages']);
    final rawTitle = row['title']?.toString().trim() ?? '';
    final petName = pet?.name ?? _petNameFromConversationTitle(rawTitle);
    final title = _buildDisplayTitle(
      rawTitle: rawTitle,
      petName: petName,
      messages: messages,
    );

    return ChatConversationDetail(
      id: row['id']?.toString() ?? _conversationId(petName),
      title: title,
      petName: petName,
      petId: petId,
      statusLabel: _statusLabelFor(messages),
      messages: messages,
    );
  }

  ChatConversationDetail _mapConversationFromChatResponse(
    Map<String, dynamic> response, {
    required _BackendPet fallbackPet,
  }) {
    final row = response['conversation'];
    if (row is Map) {
      return _mapConversationFromRow(
        Map<String, dynamic>.from(row),
        petById: {fallbackPet.id: fallbackPet},
      );
    }

    return _createLocalConversation(
      pet: fallbackPet,
      seedPrompt: 'Ciao, ho una domanda su ${fallbackPet.name}.',
    );
  }

  List<ChatMessage> _mapMessages(dynamic payload) {
    if (payload is! List) {
      return <ChatMessage>[];
    }

    return payload
        .whereType<Map>()
        .map(
          (row) {
            final message = Map<String, dynamic>.from(row);
            final createdAt = DateTime.tryParse(
                  message['created_at']?.toString() ?? '',
                ) ??
                DateTime.now().toUtc();
            return ChatMessage(
              id: message['id']?.toString() ?? _messageId('message'),
              author: _authorFromRole(message['role']?.toString()),
              text: (message['content'] ?? '').toString(),
              timeLabel: _clockLabel(createdAt),
              createdAt: createdAt,
            );
          },
        )
        .toList(growable: false);
  }

  ChatConversationDetail _createLocalConversation({
    required _BackendPet pet,
    required String seedPrompt,
  }) {
    final createdAt = DateTime.now().toUtc();
    final timeLabel = _clockLabel(createdAt);
    return ChatConversationDetail(
      id: _conversationId(pet.name),
      title: '${pet.name} - nuova conversazione',
      petName: pet.name,
      petId: pet.id,
      statusLabel: 'Contesto attivo del pet',
      messages: [
        ChatMessage(
          id: _messageId('assistant'),
          author: ChatMessageAuthor.assistant,
          text:
              'Ti seguo su ${pet.name}. Dimmi pure cosa stai osservando e ti preparo una risposta concreta.',
          timeLabel: timeLabel,
          createdAt: createdAt,
        ),
        ChatMessage(
          id: _messageId('user'),
          author: ChatMessageAuthor.user,
          text: seedPrompt,
          timeLabel: timeLabel,
          createdAt: createdAt,
        ),
        ChatMessage(
          id: _messageId('assistant'),
          author: ChatMessageAuthor.assistant,
          text: _generateReply(seedPrompt, pet.name),
          timeLabel: timeLabel,
          createdAt: createdAt,
        ),
      ],
    );
  }

  ChatConversationDetail _appendLocalMessage(
    ChatConversationDetail thread,
    String message,
  ) {
    final now = DateTime.now().toUtc();
    final userMessage = ChatMessage(
      id: _messageId('user'),
      author: ChatMessageAuthor.user,
      text: message,
      timeLabel: _clockLabel(now),
      createdAt: now,
      isRead: true,
    );

    final updatedThread = thread.copyWith(
      title: _maybeRetitle(thread.title, message),
      statusLabel: 'Messaggio inviato',
      messages: [...thread.messages, userMessage],
    );

    final assistantMessage = ChatMessage(
      id: _messageId('assistant'),
      author: ChatMessageAuthor.assistant,
      text: _generateReply(message, updatedThread.petName),
      timeLabel: _clockLabel(now),
      createdAt: now,
    );

    return updatedThread.copyWith(
      statusLabel: 'Risposta pronta',
      messages: [...updatedThread.messages, assistantMessage],
    );
  }

  void _replaceOrInsertThread(
    ChatConversationDetail conversation, {
    bool asFirst = false,
  }) {
    final index = _threads.indexWhere((thread) => thread.id == conversation.id);
    if (index == -1) {
      if (asFirst) {
        _threads.insert(0, conversation);
      } else {
        _threads.add(conversation);
      }
      return;
    }

    _threads[index] = conversation;
  }

  void _replaceThreads(List<ChatConversationDetail> threads) {
    _threads
      ..clear()
      ..addAll(threads);
    _openedConversationIds.removeWhere(
      (id) => !_threads.any((thread) => thread.id == id),
    );
    notifyListeners();
  }

  void _setLoading(bool value) {
    if (_isLoading == value) {
      return;
    }

    _isLoading = value;
    notifyListeners();
  }

  String _conversationId(String petName) {
    final seed = DateTime.now().microsecondsSinceEpoch.toRadixString(16);
    final normalizedPet =
        petName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-');
    return 'conv-$normalizedPet-$seed';
  }

  String _messageId(String prefix) {
    final seed = DateTime.now().microsecondsSinceEpoch.toRadixString(16);
    return '$prefix-$seed';
  }

  String _clockLabel([DateTime? moment]) {
    final now = (moment ?? DateTime.now().toUtc()).toLocal();
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _relativeTimeLabel(DateTime? moment) {
    final parsed = moment?.toUtc();
    if (parsed == null) {
      return 'adesso';
    }

    final now = DateTime.now().toUtc();
    final difference = now.difference(parsed);
    if (difference.inMinutes < 1) {
      return 'adesso';
    }
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min fa';
    }
    if (difference.inHours < 24) {
      return '${difference.inHours} h fa';
    }
    if (difference.inDays == 1) {
      return 'ieri';
    }
    if (difference.inDays < 7) {
      return '${difference.inDays} gg fa';
    }

    return _formatDate(parsed.toLocal());
  }

  DateTime _conversationSortKey(ChatConversationDetail conversation) {
    if (conversation.messages.isEmpty) {
      return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    }
    return conversation.messages.last.createdAt ??
        DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
  }

  String _formatDate(DateTime date) {
    const months = [
      'Gen',
      'Feb',
      'Mar',
      'Apr',
      'Mag',
      'Giu',
      'Lug',
      'Ago',
      'Set',
      'Ott',
      'Nov',
      'Dic',
    ];

    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
  }

  String _statusLabelFor(List<ChatMessage> messages) {
    if (messages.isEmpty) {
      return 'Contesto attivo del pet';
    }

    final lastMessage = messages.last;
    if (lastMessage.author == ChatMessageAuthor.assistant) {
      return 'Risposta pronta';
    }
    return 'Messaggio inviato';
  }

  String _buildDisplayTitle({
    required String rawTitle,
    required String petName,
    required List<ChatMessage> messages,
  }) {
    final normalized = rawTitle.toLowerCase();
    if (rawTitle.isNotEmpty && !normalized.startsWith('chat for ')) {
      return rawTitle;
    }

    final subject = _conversationSubject(messages);
    if (subject != null && subject.isNotEmpty) {
      return '$petName - $subject';
    }

    if (petName.isNotEmpty) {
      return '$petName - nuova conversazione';
    }

    return rawTitle.isNotEmpty ? rawTitle : 'Conversazione';
  }

  String? _conversationSubject(List<ChatMessage> messages) {
    for (final message in messages) {
      if (message.author == ChatMessageAuthor.user &&
          message.text.trim().isNotEmpty) {
        return _shortSubject(message.text);
      }
    }
    return null;
  }

  String _shortSubject(String message) {
    final normalized = message.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (normalized.length <= 28) {
      return normalized;
    }
    return '${normalized.substring(0, 25).trimRight()}...';
  }

  String _petNameFromConversationTitle(String title) {
    final normalized = title.trim();
    if (normalized.isEmpty) {
      return 'Moka';
    }

    final parts = normalized.split('-');
    return parts.first.trim().isEmpty ? 'Moka' : parts.first.trim();
  }

  ChatMessageAuthor _authorFromRole(String? role) {
    switch (role?.trim().toLowerCase()) {
      case 'user':
        return ChatMessageAuthor.user;
      case 'assistant':
        return ChatMessageAuthor.assistant;
      default:
        return ChatMessageAuthor.assistant;
    }
  }

  String _generateReply(String message, String petName) {
    final normalized = message.toLowerCase();

    if (normalized.contains('appetito') ||
        normalized.contains('mang') ||
        normalized.contains('cibo')) {
      return 'Per $petName terrei sotto osservazione appetito, acqua e livello di energia per le prossime 24 ore. Se peggiora, meglio sentire il veterinario.';
    }

    if (normalized.contains('vomit') || normalized.contains('diarrea')) {
      return 'Se ci sono vomito o diarrea, conviene monitorare idratazione e contattare il veterinario se i sintomi si ripetono o diventano intensi.';
    }

    if (normalized.contains('vaccin') || normalized.contains('richiamo')) {
      return 'Posso aiutarti a mettere il richiamo di $petName in agenda e aggiungere un reminder chiaro nella home.';
    }

    if (normalized.contains('peso') || normalized.contains('dimagr')) {
      return 'Sul peso di $petName possiamo fissare un controllo periodico e confrontarlo con l ultima visita per capire se il trend cambia davvero.';
    }

    return 'Ho preso nota: per $petName ti preparo un riepilogo breve, cosi hai subito un piano pratico e leggibile.';
  }

  String _maybeRetitle(String currentTitle, String message) {
    final normalized = currentTitle.toLowerCase();
    if (!normalized.contains('nuova conversazione')) {
      return currentTitle;
    }

    final subject = _shortSubject(message);
    if (subject.isEmpty) {
      return currentTitle;
    }

    final petName = currentTitle.split('-').first.trim();
    return '$petName - $subject';
  }

  List<ChatConversationDetail> _previewThreads() {
    return ChatSeedData.conversations
        .map(ChatSeedData.detailForSummary)
        .toList(growable: false);
  }
}

class _BackendPet {
  const _BackendPet({
    required this.id,
    required this.name,
    required this.species,
  });

  final String id;
  final String name;
  final String species;
}

extension _IterableFirstOrNullExtension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
