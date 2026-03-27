import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../medical_records/data/medical_records_repository.dart';
import '../domain/pet_models.dart';

class PostVisitRecapMetrics {
  const PostVisitRecapMetrics({
    this.shareClicks = 0,
    this.shareCopies = 0,
    this.lastSharedAt,
  });

  final int shareClicks;
  final int shareCopies;
  final DateTime? lastSharedAt;

  String get shareClicksLabel => 'Invii $shareClicks';
  String get shareCopiesLabel => 'Copie $shareCopies';

  PostVisitRecapMetrics copyWith({
    int? shareClicks,
    int? shareCopies,
    DateTime? lastSharedAt,
  }) {
    return PostVisitRecapMetrics(
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

  factory PostVisitRecapMetrics.fromMap(Map<String, dynamic> map) {
    return PostVisitRecapMetrics(
      shareClicks: map['share_clicks'] as int? ?? 0,
      shareCopies: map['share_copies'] as int? ?? 0,
      lastSharedAt: DateTime.tryParse(map['last_shared_at'] as String? ?? ''),
    );
  }
}

class PostVisitRecapStore {
  PostVisitRecapStore._();

  static const _storageKey = 'vet_app.post_visit_recap_metrics';
  static final PostVisitRecapStore instance = PostVisitRecapStore._();

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

  Future<PostVisitRecapMetrics> metricsForEntry(String entryId) async {
    final payload = await _readPayload();
    final rawMetrics = payload[entryId];
    if (rawMetrics is! Map<String, dynamic>) {
      return const PostVisitRecapMetrics();
    }
    return PostVisitRecapMetrics.fromMap(rawMetrics);
  }

  Future<PostVisitRecapMetrics> recordShareClicked(String entryId) async {
    final current = await metricsForEntry(entryId);
    return _writeMetrics(
      entryId,
      current.copyWith(
        shareClicks: current.shareClicks + 1,
        lastSharedAt: DateTime.now(),
      ),
    );
  }

  Future<PostVisitRecapMetrics> recordShareCopied(String entryId) async {
    final current = await metricsForEntry(entryId);
    return _writeMetrics(
      entryId,
      current.copyWith(
        shareCopies: current.shareCopies + 1,
        lastSharedAt: DateTime.now(),
      ),
    );
  }

  String buildPetRecapText(PetProfile pet) {
    return [
      'Riepilogo visita di ${pet.name}',
      'Profilo aggiornato in VET APP',
      'Stato: ${pet.healthBadge}',
      'Prossima visita: ${pet.nextVisitLabel}',
      'Nota clinica: ${pet.medicalNote}',
      '',
      'Recap pronto da inoltrare a vet, partner o pet sitter.',
    ].join('\n');
  }

  String buildMedicalRecordRecapText(MedicalRecordEntry record) {
    return [
      'Riepilogo visita di ${record.petName}',
      'Documento: ${record.title}',
      'Fonte: ${record.detailSource}',
      'Creato: ${record.createdAt}',
      'Stato: ${record.badge}',
      'Nota operativa: ${record.subtitle}',
      '',
      'Recap pronto da condividere da VET APP.',
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

  Future<PostVisitRecapMetrics> _writeMetrics(
    String entryId,
    PostVisitRecapMetrics metrics,
  ) async {
    final payload = await _readPayload();
    payload[entryId] = metrics.toMap();
    final preferences = await _preferencesInstance();
    await preferences.setString(_storageKey, jsonEncode(payload));
    return metrics;
  }
}
