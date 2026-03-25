import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../shared/config/app_runtime_config_loader.dart';

class MedicalRecordEntry {
  const MedicalRecordEntry({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.meta,
    required this.badge,
    required this.detailSource,
    required this.createdAt,
    required this.timeline,
  });

  final String id;
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
  MedicalRecordsRepository({SupabaseClient? client}) : _client = client;

  final SupabaseClient? _client;

  Future<List<MedicalRecordEntry>> loadRecords() async {
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
    return records.isEmpty ? null : records.first;
  }

  Future<void> saveRecord(MedicalRecordEntry record) async {
    final client = _resolveClient();
    if (client == null) {
      return;
    }

    await client.from('medical_records').upsert({
      'id': record.id,
      'title': record.title,
      'subtitle': record.subtitle,
      'meta': record.meta,
      'badge': record.badge,
      'detail_source': record.detailSource,
      'created_at': record.createdAt,
    });
  }

  Future<List<MedicalRecordEntry>> _tryLoadRemoteRecords() async {
    final client = _resolveClient();
    if (client == null) {
      return const [];
    }

    try {
      final response = await client
          .from('medical_records')
          .select('id,title,subtitle,meta,badge,detail_source,created_at');
      final rows = response as List<dynamic>;
      return rows
          .map(
            (row) => MedicalRecordEntry(
              id: (row['id'] ?? '').toString(),
              title: (row['title'] ?? 'Medical record').toString(),
              subtitle: (row['subtitle'] ?? 'Remote record').toString(),
              meta: (row['meta'] ?? 'Synced from Supabase').toString(),
              badge: (row['badge'] ?? 'Synced').toString(),
              detailSource: (row['detail_source'] ?? 'Supabase').toString(),
              createdAt: (row['created_at'] ?? 'Now').toString(),
              timeline: const [
                MedicalRecordTimelineEntry(label: 'Imported', value: 'Synced'),
                MedicalRecordTimelineEntry(label: 'Reviewed', value: 'Pending'),
                MedicalRecordTimelineEntry(label: 'Ready for export', value: 'Available'),
              ],
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

  static const List<MedicalRecordEntry> _previewRecords = [
    MedicalRecordEntry(
      id: 'vaccination-certificate',
      title: 'Vaccination certificate',
      subtitle: 'PDF - 2 pages - uploaded from clinic',
      meta: 'Updated today',
      badge: 'Verified',
      detailSource: 'Clinica Vet Roma',
      createdAt: '25 Mar 2026, 09:32',
      timeline: [
        MedicalRecordTimelineEntry(label: 'Imported', value: '25 Mar 2026'),
        MedicalRecordTimelineEntry(label: 'Reviewed', value: '25 Mar 2026, 09:45'),
        MedicalRecordTimelineEntry(label: 'Ready for export', value: 'Available'),
      ],
    ),
    MedicalRecordEntry(
      id: 'blood-test-result',
      title: 'Blood test result',
      subtitle: 'PDF - 5 pages - hematology panel',
      meta: 'Reviewed yesterday',
      badge: 'Needs follow up',
      detailSource: 'Vet Lab',
      createdAt: '24 Mar 2026, 17:08',
      timeline: [
        MedicalRecordTimelineEntry(label: 'Imported', value: '24 Mar 2026'),
        MedicalRecordTimelineEntry(label: 'Reviewed', value: '24 Mar 2026, 18:20'),
        MedicalRecordTimelineEntry(label: 'Ready for export', value: 'Pending note'),
      ],
    ),
    MedicalRecordEntry(
      id: 'xray-summary',
      title: 'X-ray summary',
      subtitle: 'Image set - orthopedic note',
      meta: 'Imported 12 Mar',
      badge: 'Archived',
      detailSource: 'Radiology clinic',
      createdAt: '12 Mar 2026, 14:10',
      timeline: [
        MedicalRecordTimelineEntry(label: 'Imported', value: '12 Mar 2026'),
        MedicalRecordTimelineEntry(label: 'Reviewed', value: '13 Mar 2026, 10:00'),
        MedicalRecordTimelineEntry(label: 'Ready for export', value: 'Archived'),
      ],
    ),
  ];
}
