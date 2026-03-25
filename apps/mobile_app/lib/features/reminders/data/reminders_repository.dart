import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../shared/config/app_runtime_config_loader.dart';

class ReminderEntry {
  const ReminderEntry({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.due,
    required this.badge,
    required this.note,
    required this.schedule,
  });

  final String id;
  final String title;
  final String subtitle;
  final String due;
  final String badge;
  final String note;
  final String schedule;
}

class RemindersRepository {
  RemindersRepository({SupabaseClient? client}) : _client = client;

  final SupabaseClient? _client;

  Future<List<ReminderEntry>> loadReminders() async {
    final remote = await _tryLoadRemoteReminders();
    if (remote.isNotEmpty) {
      return remote;
    }
    return _previewReminders;
  }

  Future<ReminderEntry?> loadReminderById(String id) async {
    final reminders = await loadReminders();
    for (final reminder in reminders) {
      if (reminder.id == id) {
        return reminder;
      }
    }
    return reminders.isEmpty ? null : reminders.first;
  }

  Future<void> saveReminder(ReminderEntry reminder) async {
    final client = _resolveClient();
    if (client == null) {
      return;
    }

    await client.from('reminders').upsert({
      'id': reminder.id,
      'title': reminder.title,
      'subtitle': reminder.subtitle,
      'due': reminder.due,
      'badge': reminder.badge,
      'note': reminder.note,
      'schedule': reminder.schedule,
    });
  }

  Future<List<ReminderEntry>> _tryLoadRemoteReminders() async {
    final client = _resolveClient();
    if (client == null) {
      return const [];
    }

    try {
      final response = await client.from('reminders').select('id,title,subtitle,due,badge,note,schedule');
      final rows = response as List<dynamic>;
      return rows
          .map(
            (row) => ReminderEntry(
              id: (row['id'] ?? '').toString(),
              title: (row['title'] ?? 'Reminder').toString(),
              subtitle: (row['subtitle'] ?? 'Remote reminder').toString(),
              due: (row['due'] ?? 'Soon').toString(),
              badge: (row['badge'] ?? 'Synced').toString(),
              note: (row['note'] ?? 'Supabase source').toString(),
              schedule: (row['schedule'] ?? 'Once').toString(),
            ),
          )
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  SupabaseClient? _resolveClient() {
    if (_client != null) {
      return _client;
    }

    final config = const AppRuntimeConfigLoader().load();
    if (!config.hasSupabaseCredentials) {
      return null;
    }

    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  static const List<ReminderEntry> _previewReminders = [
    ReminderEntry(
      id: 'antiparasitic-treatment',
      title: 'Antiparasitic treatment',
      subtitle: 'Every 30 days',
      due: 'Due in 3 days',
      badge: 'Priority',
      note: 'Keep the treatment synced with the calendar.',
      schedule: 'Recurring every 30 days',
    ),
    ReminderEntry(
      id: 'annual-vaccine',
      title: 'Annual vaccine',
      subtitle: 'Yearly recurrence',
      due: 'Due in 27 days',
      badge: 'Planned',
      note: 'Prepare documents before the visit.',
      schedule: 'Recurring every 12 months',
    ),
    ReminderEntry(
      id: 'follow-up-visit',
      title: 'Follow-up visit',
      subtitle: 'Manual reminder',
      due: 'Tomorrow 11:30',
      badge: 'Soon',
      note: 'Review the recovery progress and notes.',
      schedule: 'One-time visit',
    ),
  ];
}
