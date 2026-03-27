import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/chat_models.dart';

class AskVetShareMetrics {
  const AskVetShareMetrics({
    this.shareClicks = 0,
    this.shareCopies = 0,
    this.lastSharedAt,
  });

  final int shareClicks;
  final int shareCopies;
  final DateTime? lastSharedAt;

  String get shareClicksLabel => 'Share $shareClicks';
  String get shareCopiesLabel => 'Copie $shareCopies';

  AskVetShareMetrics copyWith({
    int? shareClicks,
    int? shareCopies,
    DateTime? lastSharedAt,
  }) {
    return AskVetShareMetrics(
      shareClicks: shareClicks ?? this.shareClicks,
      shareCopies: shareCopies ?? this.shareCopies,
      lastSharedAt: lastSharedAt ?? this.lastSharedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'share_clicks': shareClicks,
      'share_copies': shareCopies,
      'last_shared_at': lastSharedAt?.toIso8601String(),
    };
  }

  factory AskVetShareMetrics.fromMap(Map<String, dynamic> map) {
    return AskVetShareMetrics(
      shareClicks: map['share_clicks'] as int? ?? 0,
      shareCopies: map['share_copies'] as int? ?? 0,
      lastSharedAt: DateTime.tryParse(map['last_shared_at'] as String? ?? ''),
    );
  }
}

class ChatAskVetShareStore {
  ChatAskVetShareStore._();

  static const _storageKey = 'vet_app.ask_vet_share_metrics';
  static final ChatAskVetShareStore instance = ChatAskVetShareStore._();

  SharedPreferences? _preferences;

  Future<SharedPreferences> _preferencesInstance() async {
    final current = _preferences;
    if (current != null) {
      return current;
    }

    final created = await SharedPreferences.getInstance();
    _preferences = created;
    return created;
  }

  Future<AskVetShareMetrics> metricsForConversation(
    String conversationId,
  ) async {
    final payload = await _readPayload();
    final rawMetrics = payload[conversationId];
    if (rawMetrics is! Map<String, dynamic>) {
      return const AskVetShareMetrics();
    }
    return AskVetShareMetrics.fromMap(rawMetrics);
  }

  Future<AskVetShareMetrics> recordShareClicked(String conversationId) async {
    final current = await metricsForConversation(conversationId);
    return _writeMetrics(
      conversationId,
      current.copyWith(
        shareClicks: current.shareClicks + 1,
        lastSharedAt: DateTime.now(),
      ),
    );
  }

  Future<AskVetShareMetrics> recordShareCopied(String conversationId) async {
    final current = await metricsForConversation(conversationId);
    return _writeMetrics(
      conversationId,
      current.copyWith(
        shareCopies: current.shareCopies + 1,
        lastSharedAt: DateTime.now(),
      ),
    );
  }

  String buildQuestionText({
    required ChatConversationDetail conversation,
    required ChatMessage message,
  }) {
    final cleaned = message.text.trim().replaceAll('\n\n', '\n');
    return [
      'Domanda per il veterinario su ${conversation.petName}',
      '',
      'Contesto dalla chat VET APP:',
      cleaned,
      '',
      'Potete dirmi se serve visita, monitoraggio a casa oppure un controllo a breve?',
    ].join('\n');
  }

  Future<Map<String, dynamic>> _readPayload() async {
    final preferences = await _preferencesInstance();
    final raw = preferences.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      return <String, dynamic>{};
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return <String, dynamic>{};
      }
      return decoded;
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  Future<AskVetShareMetrics> _writeMetrics(
    String conversationId,
    AskVetShareMetrics metrics,
  ) async {
    final payload = await _readPayload();
    payload[conversationId] = metrics.toMap();
    final preferences = await _preferencesInstance();
    await preferences.setString(_storageKey, jsonEncode(payload));
    return metrics;
  }
}
