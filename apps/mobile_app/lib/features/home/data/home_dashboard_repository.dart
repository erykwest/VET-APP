import 'dart:ui';

import 'package:flutter/material.dart';

import '../../chat/domain/chat_models.dart';
import '../../pets/data/pet_api_repository.dart';
import '../../pets/domain/pet_models.dart';
import '../presentation/models/home_dashboard_insight_models.dart';
import '../presentation/models/home_dashboard_seed_data.dart';
import '../presentation/widgets/home_dashboard_sections.dart';
import 'backend_api_client.dart';

class HomeDashboardRepository {
  const HomeDashboardRepository({BackendApiClient? client})
      : _client = client ?? const BackendApiClient();

  final BackendApiClient _client;

  Future<HomeDashboardSeedData> loadDashboard() async {
    final petsResponse = await _client.getJson('/pets');
    final conversationsResponse = await _client.getJson('/conversations');
    final remindersResponse = await _client.getJson('/reminders');

    final pets = PetApiRepository.rowsFromResponse(petsResponse, 'pet_profiles')
        .map(PetApiRepository.petFromJson)
        .toList(growable: false);
    if (pets.isEmpty) {
      throw const BackendApiException('Nessun pet disponibile nel backend');
    }

    final petsById = {for (final pet in pets) pet.id: pet};
    final conversationRows =
        PetApiRepository.rowsFromResponse(conversationsResponse, 'conversations');
    final reminderRows =
        PetApiRepository.rowsFromResponse(remindersResponse, 'reminders');

    final conversations = conversationRows
        .map((row) => conversationSummaryFromApi(row, petsById: petsById))
        .toList(growable: false);
    final reminderItems = reminderRows
        .map((row) => reminderItemFromApi(row, petsById: petsById))
        .toList(growable: false);

    final preferredPetIds = <String>[
      ...conversationRows
          .map((row) => row['pet_id']?.toString())
          .whereType<String>(),
      ...reminderRows.map((row) => row['pet_id']?.toString()).whereType<String>(),
    ];

    final activePet = selectActivePet(
      pets,
      preferredPetIds: preferredPetIds,
    );

    return buildDashboardData(
      activePet: activePet,
      conversations: conversations,
      reminderItems: reminderItems,
    );
  }

  static HomeDashboardSeedData buildDashboardData({
    required PetProfile activePet,
    required List<ChatConversationSummary> conversations,
    required List<WarmClinicalReminderItem> reminderItems,
  }) {
    return HomeDashboardSeedData(
      activePet: activePet,
      heroDetails:
          '${activePet.species} - ${activePet.breedLabel} - ${activePet.weightLabel}',
      heroDescription:
          '${activePet.medicalNote} Prossima visita: ${activePet.nextVisitLabel}.',
      reminders: reminderItems,
      aiPrompt: conversations.isNotEmpty
          ? conversations.first.previewMessage
          : 'Hai tutto pronto per ${activePet.name}?',
      aiSuggestions: _buildSuggestions(conversations, activePet),
      insightSections: HomeDashboardInsightComposer.buildForPet(
        activePet,
        conversations: conversations,
      ),
      alertCount: countAlertsFromApi(conversations, reminderItems),
    );
  }

  static PetProfile selectActivePet(
    List<PetProfile> pets, {
    List<String> preferredPetIds = const [],
  }) {
    final petsById = {for (final pet in pets) pet.id: pet};
    for (final petId in preferredPetIds) {
      final resolved = petsById[petId];
      if (resolved != null) {
        return resolved;
      }
    }

    return pets.first;
  }

  static ChatConversationSummary conversationSummaryFromApi(
    Map<String, dynamic> row, {
    required Map<String, PetProfile> petsById,
  }) {
    final petId = row['pet_id']?.toString();
    final pet = petId == null ? null : petsById[petId];
    final messages = _messagesFromRow(row['messages']);
    final lastMessage = messages.isNotEmpty ? messages.last : null;
    final rawTitle = _stringValue(row['title'], fallback: '');
    final title =
        rawTitle.isNotEmpty ? rawTitle : (pet == null ? 'Conversazione' : 'Chat con ${pet.name}');
    final previewMessage = lastMessage == null
        ? 'Nessun messaggio ancora.'
        : _truncate(lastMessage.text);
    final updatedAtLabel = lastMessage == null
        ? 'ora'
        : _relativeTimeLabel(lastMessage.createdAt ?? DateTime.now());
    final lastSender = lastMessage == null
        ? 'Assistente'
        : lastMessage.author == ChatMessageAuthor.user
            ? 'Tu'
            : 'Assistente';
    final unreadCount =
        lastMessage != null && lastMessage.author != ChatMessageAuthor.user
            ? 1
            : 0;

    return ChatConversationSummary(
      id: _stringValue(row['id'], fallback: 'conversation'),
      title: title,
      subtitle: pet == null
          ? 'Conversazione attiva'
          : 'Con ${pet.name} - ${messages.length} messaggi',
      updatedAtLabel: updatedAtLabel,
      unreadCount: unreadCount,
      activePetName: pet?.name ?? _stringValue(row['pet_name'], fallback: 'Pet'),
      previewMessage: previewMessage,
      lastSender: lastSender,
      petId: petId,
    );
  }

  static WarmClinicalReminderItem reminderItemFromApi(
    Map<String, dynamic> row, {
    required Map<String, PetProfile> petsById,
  }) {
    final petId = row['pet_id']?.toString();
    final pet = petId == null ? null : petsById[petId];
    final title = _stringValue(row['title'], fallback: 'Reminder');
    final dueDate = DateTime.tryParse(row['due_date']?.toString() ?? '');
    final dueLabel = dueDate == null
        ? 'Da pianificare'
        : _friendlyDueDateLabel(dueDate);
    final notes = _stringValue(row['notes'], fallback: '');
    final subtitle = [
      if (pet != null) pet.name,
      if (notes.isNotEmpty) notes,
    ].join(' - ');

    return WarmClinicalReminderItem(
      title: title,
      subtitle: subtitle.isEmpty ? dueLabel : subtitle,
      icon: _reminderIconFor(title, notes),
      iconColor: _reminderColorFor(dueDate),
      trailing: Text(
        dueLabel,
        style: const TextStyle(
          color: Color(0xFF2E686A),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  static int countAlertsFromApi(
    List<ChatConversationSummary> conversations,
    List<WarmClinicalReminderItem> reminders,
  ) {
    final unread = conversations.fold<int>(
      0,
      (sum, conversation) => sum + conversation.unreadCount,
    );
    return unread + reminders.length;
  }

  static List<WarmClinicalAiSuggestion> _buildSuggestions(
    List<ChatConversationSummary> conversations,
    PetProfile activePet,
  ) {
    final suggestions = conversations
        .take(3)
        .map(
          (conversation) => WarmClinicalAiSuggestion(
            label: conversation.title,
            icon: _suggestionIconForConversation(conversation),
          ),
        )
        .toList(growable: false);

    if (suggestions.isNotEmpty) {
      return suggestions;
    }

    return [
      WarmClinicalAiSuggestion(
        label: 'Apri ${activePet.name}',
        icon: Icons.smart_toy_outlined,
      ),
    ];
  }

  static List<ChatMessage> _messagesFromRow(Object? value) {
    if (value is! List) {
      return const <ChatMessage>[];
    }

    return value
        .whereType<Map>()
        .map(
          (row) => ChatMessage(
            id: _stringValue(row['id'], fallback: 'message'),
            author: _messageAuthorFromRole(row['role']),
            text: _stringValue(row['content'], fallback: ''),
            timeLabel: _messageTimeLabel(row['created_at']?.toString()),
          ),
        )
        .toList(growable: false);
  }

  static ChatMessageAuthor _messageAuthorFromRole(Object? role) {
    final normalized = role?.toString().trim().toLowerCase() ?? '';
    return normalized == 'user'
        ? ChatMessageAuthor.user
        : ChatMessageAuthor.assistant;
  }

  static String _messageTimeLabel(String? value) {
    final parsed = value == null ? null : DateTime.tryParse(value);
    if (parsed == null) {
      return 'ora';
    }

    return _relativeTimeLabel(parsed);
  }

  static String _friendlyDueDateLabel(DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate.difference(DateTime(now.year, now.month, now.day));
    if (difference.inDays == 0) {
      return 'Oggi';
    }
    if (difference.inDays == 1) {
      return 'Domani';
    }
    if (difference.inDays > 1) {
      return 'Tra ${difference.inDays} giorni';
    }
    return 'Scaduto da ${difference.inDays.abs()} giorni';
  }

  static IconData _reminderIconFor(String title, String notes) {
    final normalized = '${title.toLowerCase()} ${notes.toLowerCase()}';
    if (normalized.contains('vacc')) {
      return Icons.vaccines_outlined;
    }
    if (normalized.contains('dent') || normalized.contains('dental')) {
      return Icons.medical_services_outlined;
    }
    if (normalized.contains('check') || normalized.contains('visit')) {
      return Icons.event_available_outlined;
    }
    return Icons.notifications_active_outlined;
  }

  static Color _reminderColorFor(DateTime? dueDate) {
    if (dueDate == null) {
      return const Color(0xFF6F91A3);
    }

    final now = DateTime.now();
    final delta = dueDate.difference(DateTime(now.year, now.month, now.day));
    if (delta.inDays < 0) {
      return const Color(0xFFE5856F);
    }
    if (delta.inDays <= 3) {
      return const Color(0xFFE0A35B);
    }
    return const Color(0xFF6F91A3);
  }

  static IconData _suggestionIconForConversation(
    ChatConversationSummary conversation,
  ) {
    final title = conversation.title.toLowerCase();
    if (title.contains('vaccino')) {
      return Icons.vaccines_outlined;
    }
    if (title.contains('referto')) {
      return Icons.summarize_outlined;
    }
    return Icons.chat_bubble_outline_rounded;
  }

  static String _truncate(String text, {int maxLength = 96}) {
    final trimmed = text.trim();
    if (trimmed.length <= maxLength) {
      return trimmed;
    }
    return '${trimmed.substring(0, maxLength - 1).trimRight()}...';
  }

  static String _relativeTimeLabel(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    if (difference.inMinutes < 60) {
      return 'ora';
    }
    if (difference.inHours < 24) {
      return '${difference.inHours}h fa';
    }
    if (difference.inDays < 7) {
      return '${difference.inDays}g fa';
    }
    return '${dateTime.day.toString().padLeft(2, '0')} ${_monthShort(dateTime.month)}';
  }

  static String _monthShort(int month) {
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

    return months[month - 1];
  }

  static String _stringValue(
    Object? value, {
    String? fallback,
  }) {
    final text = value?.toString().trim() ?? '';
    if (text.isEmpty) {
      return fallback ?? '';
    }
    return text;
  }
}
