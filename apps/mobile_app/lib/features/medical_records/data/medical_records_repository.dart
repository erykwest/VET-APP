import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../shared/config/app_runtime_config_loader.dart';
import '../../../../shared/network/backend_api_client.dart';

class MedicalRecordEntry {
  const MedicalRecordEntry({
    required this.id,
    required this.petName,
    required this.title,
    required this.subtitle,
    required this.meta,
    required this.badge,
    required this.detailSource,
    required this.createdAt,
    required this.timeline,
  });

  final String id;
  final String petName;
  final String title;
  final String subtitle;
  final String meta;
  final String badge;
  final String detailSource;
  final String createdAt;
  final List<MedicalRecordTimelineEntry> timeline;
}

class MedicalRecordTimelineEntry {
  const MedicalRecordTimelineEntry({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;
}

class ClinicalHealthProfile {
  const ClinicalHealthProfile({
    required this.petName,
    required this.species,
    required this.breed,
    required this.sex,
    required this.weightLabel,
    required this.microchipCode,
    required this.neuteredLabel,
    required this.notes,
  });

  final String petName;
  final String species;
  final String breed;
  final String sex;
  final String weightLabel;
  final String microchipCode;
  final String neuteredLabel;
  final String notes;
}

class ClinicalEventEntry {
  const ClinicalEventEntry({
    required this.id,
    required this.petName,
    required this.title,
    required this.eventType,
    required this.eventDate,
    required this.summary,
    required this.severityLabel,
    required this.sourceLabel,
  });

  final String id;
  final String petName;
  final String title;
  final String eventType;
  final String eventDate;
  final String summary;
  final String severityLabel;
  final String sourceLabel;
}

class MedicalRecordsRepository {
  MedicalRecordsRepository({
    SupabaseClient? client,
    BackendApiClient? backendApiClient,
  })  : _client = client,
        _backendApiClient = backendApiClient ?? BackendApiClient();

  final SupabaseClient? _client;
  final BackendApiClient _backendApiClient;

  Future<List<MedicalRecordEntry>> loadRecords() async {
    final backendRecords = await _tryLoadBackendRecords();
    if (backendRecords.isNotEmpty) {
      return backendRecords;
    }

    final remote = await _tryLoadRemoteRecords();
    if (remote.isNotEmpty) {
      return remote;
    }
    return List<MedicalRecordEntry>.from(_previewRecords);
  }

  Future<MedicalRecordEntry?> loadRecordById(String id) async {
    final records = await loadRecords();
    for (final record in records) {
      if (record.id == id) {
        return record;
      }
    }
    return null;
  }

  Future<List<MedicalRecordTimelineEntry>> loadTimeline({
    String? petName,
  }) async {
    final backendTimeline = await _tryLoadBackendTimeline(petName: petName);
    if (backendTimeline.isNotEmpty) {
      return backendTimeline;
    }
    return _previewTimeline(petName: petName);
  }

  Future<ClinicalHealthProfile?> loadHealthProfile({
    String? petName,
  }) async {
    final backendProfile = await _tryLoadBackendHealthProfile(petName: petName);
    if (backendProfile != null) {
      return backendProfile;
    }
    return _previewHealthProfile(petName: petName);
  }

  Future<void> saveHealthProfile(ClinicalHealthProfile profile) async {
    final backendSaved = await _trySaveHealthProfileToBackend(profile);
    if (backendSaved) {
      _upsertPreviewHealthProfile(profile);
      return;
    }
    _upsertPreviewHealthProfile(profile);
  }

  Future<List<ClinicalEventEntry>> loadEvents({
    String? petName,
  }) async {
    final backendEvents = await _tryLoadBackendEvents(petName: petName);
    if (backendEvents.isNotEmpty) {
      return backendEvents;
    }
    return _previewEvents(petName: petName);
  }

  Future<void> createClinicalEvent(ClinicalEventEntry event) async {
    final backendSaved = await _trySaveEventToBackend(event);
    if (backendSaved) {
      _upsertPreviewEvent(event);
      return;
    }
    _upsertPreviewEvent(event);
  }

  Future<void> saveRecord(MedicalRecordEntry record) async {
    final backendSaved = await _trySaveRecordToBackend(record);
    if (backendSaved) {
      _upsertPreviewRecord(record);
      return;
    }

    final client = _resolveClient();
    if (client == null) {
      _upsertPreviewRecord(record);
      return;
    }

    try {
      await client.from('medical_records').upsert({
        'id': record.id,
        'pet_name': record.petName,
        'title': record.title,
        'subtitle': record.subtitle,
        'meta': record.meta,
        'badge': record.badge,
        'detail_source': record.detailSource,
        'created_at': record.createdAt,
      });
      _upsertPreviewRecord(record);
    } catch (_) {
      _upsertPreviewRecord(record);
    }
  }

  Future<List<MedicalRecordEntry>> _tryLoadRemoteRecords() async {
    final client = _resolveClient();
    if (client == null) {
      return const [];
    }

    try {
      final response = await client.from('medical_records').select(
        'id,pet_name,title,subtitle,meta,badge,detail_source,created_at',
      );
      final rows = response as List<dynamic>;
      return rows
          .map(
            (row) => MedicalRecordEntry(
              id: _readString(row, 'id', fallback: 'remote-record'),
              petName: _readString(row, 'pet_name', fallback: 'Moka'),
              title: _readString(row, 'title', fallback: 'Referto clinico'),
              subtitle: _readString(
                row,
                'subtitle',
                fallback: 'Documento sincronizzato',
              ),
              meta: _readString(
                row,
                'meta',
                fallback: 'Sincronizzato da Supabase',
              ),
              badge: _readString(row, 'badge', fallback: 'Sincronizzato'),
              detailSource: _readString(
                row,
                'detail_source',
                fallback: 'Supabase',
              ),
              createdAt: _readString(row, 'created_at', fallback: 'Adesso'),
              timeline: const [
                MedicalRecordTimelineEntry(
                  label: 'Importato',
                  value: 'Sincronizzato',
                ),
                MedicalRecordTimelineEntry(
                  label: 'Revisionato',
                  value: 'In attesa',
                ),
                MedicalRecordTimelineEntry(
                  label: "Pronto per l'invio",
                  value: 'Disponibile',
                ),
              ],
            ),
          )
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  Future<List<MedicalRecordEntry>> _tryLoadBackendRecords() async {
    if (!_backendApiClient.isConfigured) {
      return const [];
    }

    try {
      final pets = await _backendApiClient.getCollection('/pets', 'pet_profiles');
      final records = <MedicalRecordEntry>[];
      for (final pet in pets) {
        final petId = _readString(pet, 'id', fallback: '');
        if (petId.isEmpty) {
          continue;
        }

        final petName = _readString(pet, 'name', fallback: 'Pet');
        final response = await _backendApiClient.getCollection(
          '/pets/$petId/clinical-documents',
          'documents',
        );
        records.addAll(
          response.map((row) => _recordFromBackend(row, petName)).toList(growable: false),
        );
      }
      return records;
    } catch (_) {
      return const [];
    }
  }

  Future<List<MedicalRecordTimelineEntry>> _tryLoadBackendTimeline({
    String? petName,
  }) async {
    if (!_backendApiClient.isConfigured) {
      return const [];
    }

    try {
      final pets = await _backendApiClient.getCollection('/pets', 'pet_profiles');
      final timeline = <MedicalRecordTimelineEntry>[];

      for (final pet in pets) {
        final currentPetName = _readString(pet, 'name', fallback: 'Pet');
        if (petName != null && currentPetName != petName) {
          continue;
        }

        final petId = _readString(pet, 'id', fallback: '');
        if (petId.isEmpty) {
          continue;
        }

        final response = await _backendApiClient.getCollection(
          '/pets/$petId/timeline',
          'timeline',
        );

        timeline.addAll(
          response
              .map(
                (row) => MedicalRecordTimelineEntry(
                  label: _timelineLabelFromBackend(row, currentPetName),
                  value: _timelineValueFromBackend(row),
                ),
              )
              .toList(growable: false),
        );
      }

      return timeline;
    } catch (_) {
      return const [];
    }
  }

  Future<ClinicalHealthProfile?> _tryLoadBackendHealthProfile({
    String? petName,
  }) async {
    if (!_backendApiClient.isConfigured) {
      return null;
    }

    try {
      final pets = await _backendApiClient.getCollection('/pets', 'pet_profiles');
      final selectedPet = _selectPetRow(pets, petName);
      final petId = _readString(selectedPet, 'id', fallback: '');
      if (petId.isEmpty) {
        return null;
      }

      final response = await _backendApiClient.getObject('/pets/$petId/health-profile');
      final petProfile = Map<String, dynamic>.from(
        response['pet_profile'] as Map? ?? selectedPet,
      );
      return ClinicalHealthProfile(
        petName: _readString(petProfile, 'name', fallback: 'Pet'),
        species: _readString(petProfile, 'species', fallback: 'Specie non disponibile'),
        breed: _readString(petProfile, 'breed', fallback: 'Razza non specificata'),
        sex: _readString(petProfile, 'sex', fallback: 'Non indicato'),
        weightLabel: _weightLabelFromBackend(petProfile),
        microchipCode:
            _readString(petProfile, 'microchip_code', fallback: 'Non disponibile'),
        neuteredLabel: _boolLabel(
          petProfile['neutered'],
          yesLabel: 'Si',
          noLabel: 'No',
          fallback: 'Non indicato',
        ),
        notes: _readString(
          petProfile,
          'notes',
          fallback: 'Nessuna nota clinica disponibile.',
        ),
      );
    } catch (_) {
      return null;
    }
  }

  Future<List<ClinicalEventEntry>> _tryLoadBackendEvents({
    String? petName,
  }) async {
    if (!_backendApiClient.isConfigured) {
      return const [];
    }

    try {
      final pets = await _backendApiClient.getCollection('/pets', 'pet_profiles');
      final events = <ClinicalEventEntry>[];
      final selectedPets = petName == null
          ? pets
          : pets
              .where(
                (pet) => _readString(pet, 'name', fallback: '') == petName,
              )
              .toList(growable: false);

      for (final pet in selectedPets) {
        final petId = _readString(pet, 'id', fallback: '');
        final currentPetName = _readString(pet, 'name', fallback: 'Pet');
        if (petId.isEmpty) {
          continue;
        }

        final response = await _backendApiClient.getCollection(
          '/pets/$petId/clinical-events',
          'events',
        );
        events.addAll(
          response.map((row) => _eventFromBackend(row, currentPetName)).toList(
                growable: false,
              ),
        );
      }
      return events;
    } catch (_) {
      return const [];
    }
  }

  Future<bool> _trySaveRecordToBackend(MedicalRecordEntry record) async {
    if (!_backendApiClient.isConfigured) {
      return false;
    }

    try {
      final pets = await _backendApiClient.getCollection('/pets', 'pet_profiles');
      final matchingPet = _findPetByName(pets, record.petName);
      final petId = _readString(matchingPet, 'id', fallback: '');
      if (petId.isEmpty) {
        return false;
      }

      await _backendApiClient.postJson(
        '/pets/$petId/clinical-documents',
        {
          'title': record.title,
          'document_type': _inferDocumentType(record),
          'document_date': _inferDocumentDate(record),
          'summary': record.subtitle,
          'source': record.detailSource,
          'original_filename': record.title,
          'status': _inferStatus(record),
          'verified_by_user': record.badge.toLowerCase().contains('verificat'),
        },
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _trySaveHealthProfileToBackend(ClinicalHealthProfile profile) async {
    if (!_backendApiClient.isConfigured) {
      return false;
    }

    try {
      final pets = await _backendApiClient.getCollection('/pets', 'pet_profiles');
      final matchingPet = _findPetByName(pets, profile.petName);
      final petId = _readString(matchingPet, 'id', fallback: '');
      if (petId.isEmpty) {
        return false;
      }

      await _backendApiClient.patchJson(
        '/pets/$petId/health-profile',
        body: {
          'breed': profile.breed,
          'sex': profile.sex,
          'weight_kg': _parseWeightKg(profile.weightLabel),
          'microchip_code':
              profile.microchipCode == 'Non disponibile' ? null : profile.microchipCode,
          'neutered': _boolFromItalianLabel(profile.neuteredLabel),
          'notes': profile.notes,
        },
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _trySaveEventToBackend(ClinicalEventEntry event) async {
    if (!_backendApiClient.isConfigured) {
      return false;
    }

    try {
      final pets = await _backendApiClient.getCollection('/pets', 'pet_profiles');
      final matchingPet = _findPetByName(pets, event.petName);
      final petId = _readString(matchingPet, 'id', fallback: '');
      if (petId.isEmpty) {
        return false;
      }

      await _backendApiClient.postJson(
        '/pets/$petId/clinical-events',
        {
          'title': event.title,
          'event_type': event.eventType,
          'event_date': event.eventDate,
          'summary': event.summary,
          'severity': _severityForBackend(event.severityLabel),
          'source': event.sourceLabel,
        },
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  static MedicalRecordEntry _recordFromBackend(
    Map<String, dynamic> row,
    String petName,
  ) {
    final title = _readString(row, 'title', fallback: 'Referto clinico');
    final documentType = _readString(row, 'document_type', fallback: 'Documento');
    final documentDate =
        _readString(row, 'document_date', fallback: 'Data non disponibile');
    final summary = _readString(
      row,
      'summary',
      fallback: 'Documento clinico disponibile nell archivio del pet.',
    );
    final status = _readString(row, 'status', fallback: 'Caricato');
    final source = _readString(row, 'source', fallback: 'Cartella clinica');

    return MedicalRecordEntry(
      id: _readString(row, 'id', fallback: 'clinical-document'),
      petName: petName,
      title: title,
      subtitle: summary,
      meta: '$documentType - $documentDate',
      badge: _badgeFromStatus(status),
      detailSource: source,
      createdAt: documentDate,
      timeline: [
        MedicalRecordTimelineEntry(label: 'Documento', value: documentType),
        MedicalRecordTimelineEntry(label: 'Data', value: documentDate),
        MedicalRecordTimelineEntry(label: 'Stato', value: status),
      ],
    );
  }

  static ClinicalEventEntry _eventFromBackend(
    Map<String, dynamic> row,
    String petName,
  ) {
    return ClinicalEventEntry(
      id: _readString(row, 'id', fallback: 'clinical-event'),
      petName: petName,
      title: _readString(row, 'title', fallback: 'Evento clinico'),
      eventType: _readString(row, 'event_type', fallback: 'note'),
      eventDate: _readString(row, 'event_date', fallback: '2026-03-25'),
      summary: _readString(
        row,
        'summary',
        fallback: 'Evento clinico disponibile nella timeline.',
      ),
      severityLabel:
          _readString(row, 'severity', fallback: 'Routine').toUpperCase(),
      sourceLabel: _readString(row, 'source', fallback: 'Cartella clinica'),
    );
  }

  static String _readString(
    Map<String, dynamic> row,
    String key, {
    required String fallback,
  }) {
    final value = row[key];
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
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

  static void _upsertPreviewRecord(MedicalRecordEntry record) {
    final index = _previewRecords.indexWhere((item) => item.id == record.id);
    if (index == -1) {
      _previewRecords.insert(0, record);
      return;
    }
    _previewRecords[index] = record;
  }

  static void _upsertPreviewHealthProfile(ClinicalHealthProfile profile) {
    final index = _previewHealthProfiles.indexWhere(
      (item) => item.petName == profile.petName,
    );
    if (index == -1) {
      _previewHealthProfiles.insert(0, profile);
      return;
    }
    _previewHealthProfiles[index] = profile;
  }

  static void _upsertPreviewEvent(ClinicalEventEntry event) {
    final index = _previewEventsStore.indexWhere((item) => item.id == event.id);
    if (index == -1) {
      _previewEventsStore.insert(0, event);
      return;
    }
    _previewEventsStore[index] = event;
  }

  static String _inferDocumentType(MedicalRecordEntry record) {
    final normalized =
        '${record.title} ${record.badge} ${record.subtitle}'.toLowerCase();
    if (normalized.contains('vaccin')) {
      return 'vaccination';
    }
    if (normalized.contains('esame') || normalized.contains('emocromo')) {
      return 'lab_result';
    }
    if (normalized.contains('nota')) {
      return 'clinical_visit';
    }
    return 'other';
  }

  static String _inferStatus(MedicalRecordEntry record) {
    final normalized = record.badge.toLowerCase();
    if (normalized.contains('verificat')) {
      return 'verified';
    }
    if (normalized.contains('revision')) {
      return 'in_review';
    }
    return 'uploaded';
  }

  static String _inferDocumentDate(MedicalRecordEntry record) {
    final match =
        RegExp(r'(\d{1,2})\s+[A-Za-z]{3}\s+(\d{4})').firstMatch(record.createdAt);
    if (match == null) {
      return '2026-03-25';
    }

    final day = int.tryParse(match.group(1) ?? '') ?? 25;
    final year = int.tryParse(match.group(2) ?? '') ?? 2026;
    final month = _monthFromItalianLabel(record.createdAt);
    return '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
  }

  static int _monthFromItalianLabel(String label) {
    final normalized = label.toLowerCase();
    const months = <String, int>{
      'gen': 1,
      'feb': 2,
      'mar': 3,
      'apr': 4,
      'mag': 5,
      'giu': 6,
      'lug': 7,
      'ago': 8,
      'set': 9,
      'ott': 10,
      'nov': 11,
      'dic': 12,
    };
    for (final entry in months.entries) {
      if (normalized.contains(entry.key)) {
        return entry.value;
      }
    }
    return 3;
  }

  static String _badgeFromStatus(String status) {
    switch (status.toLowerCase()) {
      case 'verified':
        return 'Verificato';
      case 'in_review':
        return 'In revisione';
      default:
        return 'Caricato';
    }
  }

  static List<MedicalRecordTimelineEntry> _previewTimeline({
    String? petName,
  }) {
    final records = petName == null
        ? _previewRecords
        : _previewRecords
            .where((record) => record.petName == petName)
            .toList(growable: false);

    final events = petName == null
        ? _previewEventsStore
        : _previewEventsStore
            .where((event) => event.petName == petName)
            .toList(growable: false);

    final rows = <MedicalRecordTimelineEntry>[
      ...records.map(
        (record) => MedicalRecordTimelineEntry(
          label: '${record.title} - ${record.badge}',
          value: record.createdAt,
        ),
      ),
      ...events.map(
        (event) => MedicalRecordTimelineEntry(
          label: '${event.title} - ${event.severityLabel}',
          value: event.eventDate,
        ),
      ),
    ];
    return rows;
  }

  static String _timelineLabelFromBackend(
    Map<String, dynamic> row,
    String petName,
  ) {
    final title = _readString(row, 'title', fallback: 'Voce timeline');
    final sourceLabel = _readString(row, 'source_label', fallback: petName);
    return '$title - $sourceLabel';
  }

  static String _timelineValueFromBackend(Map<String, dynamic> row) {
    final eventDate =
        _readString(row, 'event_date', fallback: 'Data non disponibile');
    final summary = _readString(row, 'summary', fallback: '');
    if (summary.isEmpty) {
      return eventDate;
    }
    return '$eventDate - $summary';
  }

  static Map<String, dynamic> _selectPetRow(
    List<Map<String, dynamic>> pets,
    String? petName,
  ) {
    if (pets.isEmpty) {
      return const <String, dynamic>{};
    }
    if (petName == null) {
      return pets.first;
    }
    return pets.firstWhere(
      (pet) => _readString(pet, 'name', fallback: '') == petName,
      orElse: () => pets.first,
    );
  }

  static Map<String, dynamic> _findPetByName(
    List<Map<String, dynamic>> pets,
    String petName,
  ) {
    return pets.firstWhere(
      (pet) => _readString(pet, 'name', fallback: '') == petName,
      orElse: () => const <String, dynamic>{},
    );
  }

  static ClinicalHealthProfile? _previewHealthProfile({String? petName}) {
    if (_previewHealthProfiles.isEmpty) {
      return null;
    }
    if (petName == null) {
      return _previewHealthProfiles.first;
    }
    for (final profile in _previewHealthProfiles) {
      if (profile.petName == petName) {
        return profile;
      }
    }
    return _previewHealthProfiles.first;
  }

  static List<ClinicalEventEntry> _previewEvents({String? petName}) {
    if (petName == null) {
      return List<ClinicalEventEntry>.from(_previewEventsStore);
    }
    return _previewEventsStore
        .where((event) => event.petName == petName)
        .toList(growable: false);
  }

  static String _weightLabelFromBackend(Map<String, dynamic> petProfile) {
    final numeric = petProfile['weight_kg'];
    if (numeric is num) {
      final normalized = numeric.toStringAsFixed(1).replaceAll('.', ',');
      return '$normalized kg';
    }
    return _readString(
      petProfile,
      'weight_label',
      fallback: 'Peso non disponibile',
    );
  }

  static String _boolLabel(
    Object? value, {
    required String yesLabel,
    required String noLabel,
    required String fallback,
  }) {
    if (value is bool) {
      return value ? yesLabel : noLabel;
    }
    return fallback;
  }

  static double? _parseWeightKg(String label) {
    final match = RegExp(r'(\d+[\,\.]?\d*)').firstMatch(label);
    if (match == null) {
      return null;
    }
    return double.tryParse(match.group(1)!.replaceAll(',', '.'));
  }

  static bool? _boolFromItalianLabel(String label) {
    final normalized = label.trim().toLowerCase();
    if (normalized == 'si') {
      return true;
    }
    if (normalized == 'no') {
      return false;
    }
    return null;
  }

  static String _severityForBackend(String severity) {
    final normalized = severity.trim().toLowerCase();
    if (normalized.isEmpty) {
      return 'routine';
    }
    return normalized.replaceAll(' ', '_');
  }

  static final List<MedicalRecordEntry> _previewRecords = [
    const MedicalRecordEntry(
      id: 'moka-richiamo-vaccinale',
      petName: 'Moka',
      title: 'Richiamo vaccinale di Moka',
      subtitle: 'PDF - 2 pagine - Clinica Vet Roma',
      meta: 'Caricato oggi, pronto da mostrare a Francesco',
      badge: 'Da condividere',
      detailSource: 'Clinica Vet Roma',
      createdAt: '25 Mar 2026, 09:32',
      timeline: [
        MedicalRecordTimelineEntry(label: 'Importato', value: '25 Mar 2026'),
        MedicalRecordTimelineEntry(label: 'Revisionato', value: '25 Mar 2026, 09:45'),
        MedicalRecordTimelineEntry(label: "Pronto per l'invio", value: 'Disponibile'),
      ],
    ),
    const MedicalRecordEntry(
      id: 'moka-esame-ematico',
      petName: 'Moka',
      title: 'Esame ematico di Moka',
      subtitle: 'PDF - 4 pagine - controlli di routine',
      meta: 'Letto ieri, richiede un controllo rapido',
      badge: 'Da rivedere',
      detailSource: 'Laboratorio Vet',
      createdAt: '24 Mar 2026, 17:08',
      timeline: [
        MedicalRecordTimelineEntry(label: 'Importato', value: '24 Mar 2026'),
        MedicalRecordTimelineEntry(label: 'Revisionato', value: '24 Mar 2026, 18:20'),
        MedicalRecordTimelineEntry(label: "Pronto per l'invio", value: 'In attesa di nota'),
      ],
    ),
    const MedicalRecordEntry(
      id: 'oliver-dentale',
      petName: 'Oliver',
      title: 'Controllo dentale di Oliver',
      subtitle: 'PDF - 3 pagine - ambulatorio di fiducia',
      meta: 'Utile per il follow-up dentale della prossima settimana',
      badge: 'In revisione',
      detailSource: 'Ambulatorio San Marco',
      createdAt: '18 Mar 2026, 11:20',
      timeline: [
        MedicalRecordTimelineEntry(label: 'Importato', value: '18 Mar 2026'),
        MedicalRecordTimelineEntry(label: 'Revisionato', value: '18 Mar 2026, 12:05'),
        MedicalRecordTimelineEntry(label: "Pronto per l'invio", value: 'Da controllare'),
      ],
    ),
  ];

  static final List<ClinicalHealthProfile> _previewHealthProfiles = [
    const ClinicalHealthProfile(
      petName: 'Moka',
      species: 'Cane',
      breed: 'Meticcio - Media',
      sex: 'Femmina',
      weightLabel: '17,8 kg',
      microchipCode: '380260101234567',
      neuteredLabel: 'Si',
      notes:
          'Stomaco delicato, dieta leggera e controllo periodico gia pianificato.',
    ),
    const ClinicalHealthProfile(
      petName: 'Oliver',
      species: 'Gatto',
      breed: 'Europeo a pelo corto',
      sex: 'Maschio',
      weightLabel: '5,1 kg',
      microchipCode: '380260109876543',
      neuteredLabel: 'Si',
      notes:
          'Vita in casa, controllo dentale programmato e monitoraggio alimentazione.',
    ),
  ];

  static final List<ClinicalEventEntry> _previewEventsStore = [
    const ClinicalEventEntry(
      id: 'evt-moka-vaccino',
      petName: 'Moka',
      title: 'Richiamo vaccinale annuale',
      eventType: 'vaccination_administered',
      eventDate: '2026-03-25',
      summary: 'Richiamo annuale completato senza criticita.',
      severityLabel: 'Routine',
      sourceLabel: 'Clinica Vet Roma',
    ),
    const ClinicalEventEntry(
      id: 'evt-moka-emocromo',
      petName: 'Moka',
      title: 'Emocromo di controllo',
      eventType: 'exam_result',
      eventDate: '2026-03-24',
      summary: 'Esame ematico di routine con referto archiviato.',
      severityLabel: 'Routine',
      sourceLabel: 'Laboratorio Vet',
    ),
    const ClinicalEventEntry(
      id: 'evt-oliver-dentale',
      petName: 'Oliver',
      title: 'Visita dentale',
      eventType: 'clinical_visit',
      eventDate: '2026-03-18',
      summary: 'Controllo dentale con follow-up consigliato.',
      severityLabel: 'Moderata',
      sourceLabel: 'Ambulatorio San Marco',
    ),
  ];
}
