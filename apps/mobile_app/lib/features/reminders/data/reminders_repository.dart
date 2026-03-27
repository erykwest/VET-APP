import '../../../shared/network/backend_api_client.dart';

class ReminderEntry {
  const ReminderEntry({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.due,
    required this.badge,
    required this.note,
    required this.schedule,
    this.petId,
    this.dueDate,
    this.notes,
  });

  final String id;
  final String title;
  final String subtitle;
  final String due;
  final String badge;
  final String note;
  final String schedule;
  final String? petId;
  final DateTime? dueDate;
  final String? notes;
}

class RemindersRepository {
  RemindersRepository({BackendApiClient? apiClient})
      : _apiClient = apiClient ?? BackendApiClient();

  final BackendApiClient _apiClient;

  Future<List<ReminderEntry>> loadReminders() async {
    if (!_apiClient.isConfigured) {
      return _previewReminders;
    }

    try {
      return await _loadRemoteReminders();
    } catch (_) {
      return _previewReminders;
    }
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
    if (!_apiClient.isConfigured) {
      return;
    }

    final petId = await _resolvePetId(reminder);
    final dueDate = reminder.dueDate ?? _parseDueDate(reminder.due);
    final payload = <String, dynamic>{
      'pet_id': petId,
      'title': reminder.title,
      'due_date': _formatDateForApi(dueDate ?? DateTime.now().toUtc()),
      'notes': _serializeNotes(reminder),
    };

    await _apiClient.postJson('/reminders', payload);
  }

  Future<List<ReminderEntry>> _loadRemoteReminders() async {
    final pets = await _loadPets();
    final petNamesById = {
      for (final pet in pets) pet.id: pet.name,
    };
    final reminders = await _apiClient.getCollection('/reminders', 'reminders');

    return reminders
        .map(
          (row) => _mapReminderFromRow(
            row,
            petNamesById: petNamesById,
          ),
        )
        .toList(growable: false);
  }

  Future<List<_BackendPet>> _loadPets() async {
    final response = await _apiClient.getCollection('/pets', 'pet_profiles');
    return response
        .map(
          (row) => _BackendPet(
            id: (row['id'] ?? '').toString(),
            name: (row['name'] ?? 'Moka').toString(),
          ),
        )
        .where((pet) => pet.id.isNotEmpty)
        .toList(growable: false);
  }

  ReminderEntry _mapReminderFromRow(
    Map<String, dynamic> row, {
    required Map<String, String> petNamesById,
  }) {
    final notes = (row['notes'] ?? '').toString();
    final petId = (row['pet_id'] ?? '').toString();
    final parsedNotes = _decodeNotes(notes);
    final dueDate = _parseDateOnly(row['due_date']?.toString());
    final petName = petNamesById[petId] ?? parsedNotes.subtitleOwnerName;

    return ReminderEntry(
      id: (row['id'] ?? '').toString(),
      title: (row['title'] ?? 'Promemoria').toString(),
      subtitle: parsedNotes.subtitle.isNotEmpty
          ? parsedNotes.subtitle
          : (petName == null ? 'Promemoria sincronizzato' : 'Per $petName'),
      due: _formatDueLabel(dueDate),
      badge: parsedNotes.badge.isNotEmpty ? parsedNotes.badge : 'Sincronizzato',
      note: parsedNotes.note.isNotEmpty ? parsedNotes.note : notes,
      schedule: parsedNotes.schedule.isNotEmpty
          ? parsedNotes.schedule
          : 'Promemoria backend',
      petId: petId.isEmpty ? null : petId,
      dueDate: dueDate,
      notes: notes.isEmpty ? null : notes,
    );
  }

  Future<String> _resolvePetId(ReminderEntry reminder) async {
    if (reminder.petId != null && reminder.petId!.trim().isNotEmpty) {
      return reminder.petId!.trim();
    }

    final pets = await _loadPets();
    final title = reminder.title.toLowerCase();
    for (final pet in pets) {
      if (title.contains(pet.name.toLowerCase())) {
        return pet.id;
      }
    }

    return pets.isNotEmpty ? pets.first.id : 'demo-pet-moka';
  }

  String _serializeNotes(ReminderEntry reminder) {
    return [
      'subtitle: ${reminder.subtitle}',
      'badge: ${reminder.badge}',
      'schedule: ${reminder.schedule}',
      'note: ${reminder.note}',
    ].join('\n');
  }

  String _formatDateForApi(DateTime date) {
    return date.toUtc().toIso8601String().split('T').first;
  }

  String _formatDueLabel(DateTime? date) {
    if (date == null) {
      return 'A breve';
    }

    final local = date.toLocal();
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
    return '${local.day.toString().padLeft(2, '0')} ${months[local.month - 1]} ${local.year}';
  }

  DateTime? _parseDueDate(String label) {
    return _parseDateOnly(label) ?? _parseRelativeDate(label);
  }

  DateTime? _parseDateOnly(String? raw) {
    final value = (raw ?? '').trim();
    if (value.isEmpty) {
      return null;
    }

    final parsed = DateTime.tryParse(value);
    if (parsed != null) {
      return parsed.toUtc();
    }

    final normalized = value.replaceAll(RegExp(r'\s+'), ' ');
    final parts = normalized.split(' ');
    if (parts.length != 3) {
      return null;
    }

    final day = int.tryParse(parts[0]);
    final month = _monthIndex(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) {
      return null;
    }

    return DateTime.utc(year, month, day);
  }

  DateTime? _parseRelativeDate(String label) {
    final lower = label.toLowerCase();
    final now = DateTime.now().toUtc();
    if (lower.contains('domani')) {
      return now.add(const Duration(days: 1));
    }
    if (lower.contains('3 giorni')) {
      return now.add(const Duration(days: 3));
    }
    if (lower.contains('21 giorni')) {
      return now.add(const Duration(days: 21));
    }
    return null;
  }

  int? _monthIndex(String month) {
    switch (month.toLowerCase()) {
      case 'gen':
      case 'gennaio':
        return 1;
      case 'feb':
      case 'febbraio':
        return 2;
      case 'mar':
      case 'marzo':
        return 3;
      case 'apr':
      case 'aprile':
        return 4;
      case 'mag':
      case 'maggio':
        return 5;
      case 'giu':
      case 'giugno':
        return 6;
      case 'lug':
      case 'luglio':
        return 7;
      case 'ago':
      case 'agosto':
        return 8;
      case 'set':
      case 'settembre':
        return 9;
      case 'ott':
      case 'ottobre':
        return 10;
      case 'nov':
      case 'novembre':
        return 11;
      case 'dic':
      case 'dicembre':
        return 12;
    }
    return null;
  }

  _ReminderNoteParts _decodeNotes(String notes) {
    if (notes.trim().isEmpty) {
      return const _ReminderNoteParts();
    }

    final lines = notes
        .split(RegExp(r'[\r\n]+'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList(growable: false);

    if (lines.any((line) => line.contains(':'))) {
      final values = <String, String>{};
      for (final line in lines) {
        final separator = line.indexOf(':');
        if (separator <= 0) {
          continue;
        }
        final key = line.substring(0, separator).trim().toLowerCase();
        final value = line.substring(separator + 1).trim();
        values[key] = value;
      }

      return _ReminderNoteParts(
        subtitle: values['subtitle'] ?? '',
        badge: values['badge'] ?? '',
        schedule: values['schedule'] ?? '',
        note: values['note'] ?? '',
      );
    }

    final segments = notes.split('|').map((segment) => segment.trim()).toList(
          growable: false,
        );
    return _ReminderNoteParts(
      subtitle: segments.isNotEmpty ? segments.first : '',
      badge: segments.length > 1 ? segments[1] : '',
      schedule: segments.length > 2 ? segments[2] : '',
      note: segments.length > 3 ? segments[3] : notes,
    );
  }

  static const List<ReminderEntry> _previewReminders = [
    ReminderEntry(
      id: 'moka-antiparassitario',
      title: 'Antiparassitario di Moka',
      subtitle: 'Ogni 30 giorni',
      due: 'Scade tra 3 giorni',
      badge: 'Prioritario',
      note: 'Notifica gia pronta per Francesco e collegata al profilo di Moka.',
      schedule: 'Ricorrente ogni 30 giorni',
      petId: 'demo-pet-moka',
    ),
    ReminderEntry(
      id: 'moka-richiamo-vaccinale',
      title: 'Richiamo vaccinale di Moka',
      subtitle: 'Ogni 12 mesi',
      due: 'Scade tra 21 giorni',
      badge: 'Programmato',
      note: 'Documento gia caricato in cartella per la prossima visita.',
      schedule: 'Ricorrente ogni 12 mesi',
      petId: 'demo-pet-moka',
    ),
    ReminderEntry(
      id: 'luna-controllo-peso',
      title: 'Controllo peso di Luna',
      subtitle: 'Promemoria manuale',
      due: 'Domani alle 11:30',
      badge: 'Vicino',
      note: 'Rivedi andamento, peso e note cliniche prima della chiamata.',
      schedule: 'Promemoria una tantum',
      petId: 'demo-pet-luna',
    ),
  ];
}

class _BackendPet {
  const _BackendPet({
    required this.id,
    required this.name,
  });

  final String id;
  final String name;
}

class _ReminderNoteParts {
  const _ReminderNoteParts({
    this.subtitle = '',
    this.badge = '',
    this.schedule = '',
    this.note = '',
  });

  final String subtitle;
  final String badge;
  final String schedule;
  final String note;

  String get subtitleOwnerName {
    if (subtitle.toLowerCase().startsWith('per ')) {
      return subtitle.substring(4).trim();
    }
    return '';
  }
}
