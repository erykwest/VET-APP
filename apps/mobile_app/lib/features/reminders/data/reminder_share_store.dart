import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'reminders_repository.dart';

class ReminderShareMetrics {
  const ReminderShareMetrics({
    this.shareClicks = 0,
    this.shareCopies = 0,
    this.lastSharedAt,
  });

  final int shareClicks;
  final int shareCopies;
  final DateTime? lastSharedAt;

  String get shareClicksLabel => 'Share $shareClicks';
  String get shareCopiesLabel => 'Copie $shareCopies';

  String get lastSharedLabel {
    final value = lastSharedAt;
    if (value == null) {
      return 'Mai condiviso';
    }

    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$day/$month alle $hour:$minute';
  }

  ReminderShareMetrics copyWith({
    int? shareClicks,
    int? shareCopies,
    DateTime? lastSharedAt,
  }) {
    return ReminderShareMetrics(
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

  factory ReminderShareMetrics.fromMap(Map<String, dynamic> map) {
    return ReminderShareMetrics(
      shareClicks: map['share_clicks'] as int? ?? 0,
      shareCopies: map['share_copies'] as int? ?? 0,
      lastSharedAt: DateTime.tryParse(map['last_shared_at'] as String? ?? ''),
    );
  }
}

class ReminderShareStore {
  ReminderShareStore._();

  static const _storageKey = 'vet_app.reminder_share_metrics';
  static final ReminderShareStore instance = ReminderShareStore._();

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

  Future<ReminderShareMetrics> metricsForReminder(String reminderId) async {
    final payload = await _readPayload();
    final rawMetrics = payload[reminderId];
    if (rawMetrics is! Map<String, dynamic>) {
      return const ReminderShareMetrics();
    }
    return ReminderShareMetrics.fromMap(rawMetrics);
  }

  Future<ReminderShareMetrics> recordShareClicked(String reminderId) async {
    final current = await metricsForReminder(reminderId);
    return _writeMetrics(
      reminderId,
      current.copyWith(
        shareClicks: current.shareClicks + 1,
        lastSharedAt: DateTime.now(),
      ),
    );
  }

  Future<ReminderShareMetrics> recordShareCopied(String reminderId) async {
    final current = await metricsForReminder(reminderId);
    return _writeMetrics(
      reminderId,
      current.copyWith(
        shareCopies: current.shareCopies + 1,
        lastSharedAt: DateTime.now(),
      ),
    );
  }

  String buildReminderShareText(ReminderEntry reminder) {
    return [
      'Promemoria condivisibile',
      reminder.title,
      'Scadenza: ${reminder.due}',
      'Ricorrenza: ${reminder.schedule}',
      'Stato: ${reminder.badge}',
      'Nota: ${reminder.note}',
      '',
      'Messaggio pronto da inoltrare a partner o pet sitter via VET APP.',
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

  Future<ReminderShareMetrics> _writeMetrics(
    String reminderId,
    ReminderShareMetrics metrics,
  ) async {
    final payload = await _readPayload();
    payload[reminderId] = metrics.toMap();
    final preferences = await _preferencesInstance();
    await preferences.setString(_storageKey, jsonEncode(payload));
    return metrics;
  }
}
