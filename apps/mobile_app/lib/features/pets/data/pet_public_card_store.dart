import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/pet_models.dart';

class PetPublicCardMetrics {
  const PetPublicCardMetrics({
    this.openCount = 0,
    this.shareCount = 0,
    this.lastSharedAt,
  });

  final int openCount;
  final int shareCount;
  final DateTime? lastSharedAt;

  String get openLabel => 'Aperta $openCount';
  String get shareLabel => 'Condivisa $shareCount';

  String get lastSharedLabel {
    final value = lastSharedAt;
    if (value == null) {
      return 'Mai condivisa';
    }

    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$day/$month alle $hour:$minute';
  }

  PetPublicCardMetrics copyWith({
    int? openCount,
    int? shareCount,
    DateTime? lastSharedAt,
  }) {
    return PetPublicCardMetrics(
      openCount: openCount ?? this.openCount,
      shareCount: shareCount ?? this.shareCount,
      lastSharedAt: lastSharedAt ?? this.lastSharedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'open_count': openCount,
      'share_count': shareCount,
      'last_shared_at': lastSharedAt?.toIso8601String(),
    };
  }

  factory PetPublicCardMetrics.fromMap(Map<String, dynamic> map) {
    return PetPublicCardMetrics(
      openCount: map['open_count'] as int? ?? 0,
      shareCount: map['share_count'] as int? ?? 0,
      lastSharedAt: DateTime.tryParse(map['last_shared_at'] as String? ?? ''),
    );
  }
}

class PetPublicCardStore {
  PetPublicCardStore._();

  static const _storageKey = 'vet_app.pet_public_card_metrics';
  static final PetPublicCardStore instance = PetPublicCardStore._();

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

  Future<PetPublicCardMetrics> metricsForPet(String petId) async {
    final payload = await _readPayload();
    final rawMetrics = payload[petId];
    if (rawMetrics is! Map<String, dynamic>) {
      return const PetPublicCardMetrics();
    }
    return PetPublicCardMetrics.fromMap(rawMetrics);
  }

  Future<PetPublicCardMetrics> recordOpened(String petId) async {
    final current = await metricsForPet(petId);
    return _writeMetrics(
      petId,
      current.copyWith(openCount: current.openCount + 1),
    );
  }

  Future<PetPublicCardMetrics> recordShared(String petId) async {
    final current = await metricsForPet(petId);
    return _writeMetrics(
      petId,
      current.copyWith(
        shareCount: current.shareCount + 1,
        lastSharedAt: DateTime.now(),
      ),
    );
  }

  String buildCardPreviewText(PetProfile pet) {
    return [
      '${pet.name} | ${pet.healthBadge}',
      'Prossima visita: ${pet.nextVisitLabel}',
      'Nota breve: ${pet.medicalNote}',
    ].join('\n');
  }

  String buildDemoLink(String petId) {
    return 'vetapp://pet-card/$petId';
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

  Future<PetPublicCardMetrics> _writeMetrics(
    String petId,
    PetPublicCardMetrics metrics,
  ) async {
    final payload = await _readPayload();
    payload[petId] = metrics.toMap();
    final preferences = await _preferencesInstance();
    await preferences.setString(_storageKey, jsonEncode(payload));
    return metrics;
  }
}
