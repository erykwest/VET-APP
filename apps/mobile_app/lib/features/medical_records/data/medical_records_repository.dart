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
    return _previewRecords;
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

  static List<MedicalRecordEntry> get previewRecords =>
      List<MedicalRecordEntry>.unmodifiable(_previewRecords);

  static MedicalRecordEntry? previewRecordById(String id) {
    for (final record in _previewRecords) {
      if (record.id == id) {
        return record;
      }
    }
    return _previewRecords.isEmpty ? null : _previewRecords.first;
  }

  Future<List<MedicalRecordEntry>> _tryLoadRemoteRecords() async {
    final client = _resolveClient();
    if (client == null) {
      return const [];
    }

    try {
      final response = await client.from('medical_records').select(
          'id,pet_name,title,subtitle,meta,badge,detail_source,created_at');
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
      final pets =
          await _backendApiClient.getCollection('/pets', 'pet_profiles');
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
          response
              .map((row) => _recordFromBackend(row, petName))
              .toList(growable: false),
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
      final pets =
          await _backendApiClient.getCollection('/pets', 'pet_profiles');
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

  Future<bool> _trySaveRecordToBackend(MedicalRecordEntry record) async {
    if (!_backendApiClient.isConfigured) {
      return false;
    }

    try {
      final pets =
          await _backendApiClient.getCollection('/pets', 'pet_profiles');
      final matchingPet = pets.cast<Map<String, dynamic>?>().firstWhere(
            (pet) =>
                _readString(pet ?? const {}, 'name', fallback: '') ==
                record.petName,
            orElse: () => null,
          );
      final petId = _readString(matchingPet ?? const {}, 'id', fallback: '');
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

  static MedicalRecordEntry _recordFromBackend(
    Map<String, dynamic> row,
    String petName,
  ) {
    final title = _readString(row, 'title', fallback: 'Referto clinico');
    final documentType =
        _readString(row, 'document_type', fallback: 'Documento');
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
        MedicalRecordTimelineEntry(
            label: 'Revisionato', value: '25 Mar 2026, 09:45'),
        MedicalRecordTimelineEntry(
            label: "Pronto per l'invio", value: 'Disponibile'),
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
        MedicalRecordTimelineEntry(
            label: 'Revisionato', value: '24 Mar 2026, 18:20'),
        MedicalRecordTimelineEntry(
            label: "Pronto per l'invio", value: 'In attesa di nota'),
      ],
    ),
    const MedicalRecordEntry(
      id: 'moka-controllo-peso',
      petName: 'Moka',
      title: 'Nota clinica controllo peso',
      subtitle: 'Immagine - follow-up breve',
      meta: 'Archiviato il 12 marzo, utile come storico',
      badge: 'Archivio',
      detailSource: 'Ambulatorio San Marco',
      createdAt: '12 Mar 2026, 14:10',
      timeline: [
        MedicalRecordTimelineEntry(label: 'Importato', value: '12 Mar 2026'),
        MedicalRecordTimelineEntry(
            label: 'Revisionato', value: '13 Mar 2026, 10:00'),
        MedicalRecordTimelineEntry(
            label: "Pronto per l'invio", value: 'Archiviato'),
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
        MedicalRecordTimelineEntry(
            label: 'Revisionato', value: '18 Mar 2026, 12:05'),
        MedicalRecordTimelineEntry(
            label: "Pronto per l'invio", value: 'Da controllare'),
      ],
    ),
  ];

  static void _upsertPreviewRecord(MedicalRecordEntry record) {
    final index = _previewRecords.indexWhere((item) => item.id == record.id);
    if (index == -1) {
      _previewRecords.insert(0, record);
      return;
    }

    _previewRecords[index] = record;
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
    final match = RegExp(r'(\d{1,2})\s+[A-Za-z]{3}\s+(\d{4})')
        .firstMatch(record.createdAt);
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

    return records
        .map(
          (record) => MedicalRecordTimelineEntry(
            label: '${record.title} · ${record.badge}',
            value: record.createdAt,
          ),
        )
        .toList(growable: false);
  }

  static String _timelineLabelFromBackend(
    Map<String, dynamic> row,
    String petName,
  ) {
    final title = _readString(row, 'title', fallback: 'Voce timeline');
    final sourceLabel = _readString(row, 'source_label', fallback: petName);
    return '$title · $sourceLabel';
  }

  static String _timelineValueFromBackend(Map<String, dynamic> row) {
    final eventDate =
        _readString(row, 'event_date', fallback: 'Data non disponibile');
    final summary = _readString(row, 'summary', fallback: '');
    if (summary.isEmpty) {
      return eventDate;
    }
    return '$eventDate · $summary';
  }
}
