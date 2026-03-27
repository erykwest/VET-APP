import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/pet_models.dart';

class PetShareSnapshotMetrics {
  const PetShareSnapshotMetrics({
    this.shareClicks = 0,
    this.shareCopies = 0,
    this.lastSharedAt,
  });

  final int shareClicks;
  final int shareCopies;
  final DateTime? lastSharedAt;

  String get shareLaunchesLabel => 'Share $shareClicks';
  String get copyFallbacksLabel => 'Copie $shareCopies';

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

  PetShareSnapshotMetrics copyWith({
    int? shareClicks,
    int? shareCopies,
    DateTime? lastSharedAt,
    bool clearLastSharedAt = false,
  }) {
    return PetShareSnapshotMetrics(
      shareClicks: shareClicks ?? this.shareClicks,
      shareCopies: shareCopies ?? this.shareCopies,
      lastSharedAt:
          clearLastSharedAt ? null : (lastSharedAt ?? this.lastSharedAt),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'share_clicks': shareClicks,
      'share_copies': shareCopies,
      'last_shared_at': lastSharedAt?.toIso8601String(),
    };
  }

  factory PetShareSnapshotMetrics.fromMap(Map<String, dynamic> map) {
    return PetShareSnapshotMetrics(
      shareClicks: map['share_clicks'] as int? ?? 0,
      shareCopies: map['share_copies'] as int? ?? 0,
      lastSharedAt: DateTime.tryParse(map['last_shared_at'] as String? ?? ''),
    );
  }
}

class PetShareSnapshotStore {
  PetShareSnapshotStore._();

  static const _storageKey = 'vet_app.pet_share_snapshot_metrics';
  static final PetShareSnapshotStore instance = PetShareSnapshotStore._();

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

  Future<PetShareSnapshotMetrics> metricsForPet(String petId) async {
    final payload = await _readPayload();
    final rawMetrics = payload[petId];
    if (rawMetrics is! Map<String, dynamic>) {
      return const PetShareSnapshotMetrics();
    }
    return PetShareSnapshotMetrics.fromMap(rawMetrics);
  }

  Future<PetShareSnapshotMetrics> recordShareClicked(String petId) async {
    final current = await metricsForPet(petId);
    return _writeMetrics(
      petId,
      current.copyWith(
        shareClicks: current.shareClicks + 1,
        lastSharedAt: DateTime.now(),
      ),
    );
  }

  Future<PetShareSnapshotMetrics> recordShareCopied(String petId) async {
    final current = await metricsForPet(petId);
    return _writeMetrics(
      petId,
      current.copyWith(
        shareCopies: current.shareCopies + 1,
        lastSharedAt: DateTime.now(),
      ),
    );
  }

  String buildSnapshotText(PetProfile pet) {
    return [
      'Aggiornamento rapido su ${pet.name}',
      '${pet.species} - ${pet.breedLabel}',
      'Stato: ${pet.healthBadge}',
      'Peso: ${pet.weightLabel}',
      'Prossima visita: ${pet.nextVisitLabel}',
      'Nota: ${pet.medicalNote}',
      '',
      'Condiviso da VET APP per allineare vet, partner o pet sitter in un solo messaggio.',
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

  Future<PetShareSnapshotMetrics> _writeMetrics(
    String petId,
    PetShareSnapshotMetrics metrics,
  ) async {
    final payload = await _readPayload();
    payload[petId] = metrics.toMap();
    final preferences = await _preferencesInstance();
    await preferences.setString(_storageKey, jsonEncode(payload));
    return metrics;
  }
}
