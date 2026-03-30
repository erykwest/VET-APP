import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../domain/pet_models.dart';
import '../../../shared/network/backend_api_client.dart';

class PetApiRepository {
  PetApiRepository({BackendApiClient? client})
      : _client = client ?? BackendApiClient();

  final BackendApiClient _client;

  bool get isConfigured => _client.isConfigured;

  Future<List<PetProfile>> listPets() async {
    final response = await _client.getJson('/pets');
    return rowsFromResponse(response, 'pet_profiles')
        .map(PetApiRepository.petFromJson)
        .toList(growable: false);
  }

  Future<PetProfile> getPet(String petId) async {
    final response = await _client.getJson('/pets/$petId');
    final row = rowFromResponse(response, 'pet_profile') ?? response;
    return petFromJson(row);
  }

  Future<PetProfile> createPet({
    required String name,
    required String species,
    String? breed,
    required DateTime birthDate,
    required String sex,
    required double weightKg,
    required String medicalNote,
    required String healthBadge,
    required String nextVisitLabel,
    required String avatarKey,
    String? profileImageDataUrl,
    String? galleryProvider,
  }) async {
    final response = await _client.postJson(
      '/pets',
      requestBodyFromProfile(
        name: name,
        species: species,
        breed: breed,
        birthDate: birthDate,
        sex: sex,
        weightKg: weightKg,
        medicalNote: medicalNote,
        healthBadge: healthBadge,
        nextVisitLabel: nextVisitLabel,
        avatarKey: avatarKey,
        profileImageDataUrl: profileImageDataUrl,
        galleryProvider: galleryProvider,
      ),
    );

    final row = rowFromResponse(response, 'pet_profile') ?? response;
    return petFromJson(row);
  }

  Future<PetProfile> updatePet({
    required String petId,
    required String name,
    required String species,
    String? breed,
    required DateTime birthDate,
    required String sex,
    required double weightKg,
    required String medicalNote,
    required String healthBadge,
    required String nextVisitLabel,
    required String avatarKey,
    String? profileImageDataUrl,
    String? galleryProvider,
  }) async {
    final response = await _client.putJson(
      '/pets/$petId',
      body: requestBodyFromProfile(
        name: name,
        species: species,
        breed: breed,
        birthDate: birthDate,
        sex: sex,
        weightKg: weightKg,
        medicalNote: medicalNote,
        healthBadge: healthBadge,
        nextVisitLabel: nextVisitLabel,
        avatarKey: avatarKey,
        profileImageDataUrl: profileImageDataUrl,
        galleryProvider: galleryProvider,
      ),
    );

    final row = rowFromResponse(response, 'pet_profile') ?? response;
    return petFromJson(row);
  }

  static PetProfile petFromJson(Map<String, dynamic> json) {
    final id = _stringValue(json['id'], fallback: 'pet');
    final name = _stringValue(json['name'], fallback: 'Pet');
    final species = _stringValue(json['species'], fallback: 'Altro');
    final breed = _optionalText(json['breed']);
    final ageYears = _intValue(json['age_years']);
    final notes = _optionalText(json['notes']) ?? '';
    final metadata = _PetMetadata.tryParse(notes);
    final preset = _demoPresetFor(id: id, name: name);
    final avatarKey = _resolveAvatarKey(
      metadata?.avatarKey ?? preset?.avatarEmoji,
      species,
    );
    final accentColor = metadata?.accentColor ??
        preset?.accentColor ??
        _backgroundColorForAvatarKey(avatarKey);
    final birthDateIso = metadata?.birthDateIso ?? preset?.birthDateIso;
    final birthDateLabel = metadata?.birthDateLabel ??
        preset?.birthDateLabel ??
        _birthDateLabelFromIso(birthDateIso) ??
        _birthDateLabelFromAgeYears(ageYears) ??
        'Data non disponibile';
    final weightLabel = metadata?.weightLabel ??
        preset?.weightLabel ??
        _weightLabelFromKg(metadata?.weightKg) ??
        'Peso non disponibile';
    final medicalNote = metadata?.medicalNote ??
        preset?.medicalNote ??
        (_looksLikeJson(notes)
            ? 'Nessuna nota clinica disponibile.'
            : (notes.trim().isNotEmpty
                ? notes.trim()
                : 'Nessuna nota clinica disponibile.'));
    final healthBadge = metadata?.healthBadge ??
        preset?.healthBadge ??
        _healthBadgeForSpecies(species);
    final nextVisitLabel =
        metadata?.nextVisitLabel ?? preset?.nextVisitLabel ?? 'Da pianificare';
    final galleryProvider = metadata?.galleryProvider ?? preset?.galleryProvider;
    final profileImageDataUrl =
        metadata?.profileImageDataUrl ?? preset?.profileImageDataUrl;
    final sex = metadata?.sex ?? preset?.sex ?? 'Sconosciuto';
    final resolvedAgeYears = metadata?.ageYears ?? preset?.ageYears ?? ageYears;

    return PetProfile(
      id: id,
      name: name,
      species: species,
      breed: breed ?? preset?.breed ?? '',
      birthDateLabel: birthDateLabel,
      birthDateIso: birthDateIso,
      ageYears: resolvedAgeYears,
      sex: sex,
      weightLabel: weightLabel,
      medicalNote: medicalNote,
      healthBadge: healthBadge,
      nextVisitLabel: nextVisitLabel,
      avatarEmoji: avatarKey,
      accentColor: accentColor,
      profileImageDataUrl: profileImageDataUrl,
      galleryProvider: galleryProvider,
    );
  }

  static Map<String, dynamic> requestBodyFromProfile({
    required String name,
    required String species,
    String? breed,
    required DateTime birthDate,
    required String sex,
    required double weightKg,
    required String medicalNote,
    required String healthBadge,
    required String nextVisitLabel,
    required String avatarKey,
    String? profileImageDataUrl,
    String? galleryProvider,
  }) {
    final resolvedAvatarKey = _resolveAvatarKey(avatarKey, species);
    final birthDateIso = _formatIsoDate(birthDate);
    return {
      'name': name.trim(),
      'species': species.trim(),
      'breed': _normalizedTextOrNull(breed),
      'age_years': _ageYearsFromBirthDate(birthDate),
      'notes': jsonEncode({
        'birth_date_iso': birthDateIso,
        'birth_date_label': _monthYearLabelFromDate(birthDate),
        'sex': sex.trim(),
        'weight_kg': weightKg,
        'weight_label': _weightLabelFromKg(weightKg),
        'medical_note': medicalNote.trim(),
        'health_badge': healthBadge.trim(),
        'next_visit_label': nextVisitLabel.trim(),
        'avatar_key': resolvedAvatarKey,
        'accent_color_hex':
            _backgroundColorForAvatarKey(resolvedAvatarKey)
                .value
                .toRadixString(16)
                .padLeft(8, '0'),
        if (profileImageDataUrl != null) 'profile_image_data_url': profileImageDataUrl,
        if (galleryProvider != null && galleryProvider.trim().isNotEmpty)
          'gallery_provider': galleryProvider.trim(),
      }),
    };
  }

  static List<Map<String, dynamic>> rowsFromResponse(
    Map<String, dynamic> response,
    String key,
  ) {
    final rows = response[key];
    if (rows is List) {
      return rows
          .whereType<Map>()
          .map((row) => Map<String, dynamic>.from(row))
          .toList(growable: false);
    }

    return const <Map<String, dynamic>>[];
  }

  static Map<String, dynamic>? rowFromResponse(
    Map<String, dynamic> response,
    String key,
  ) {
    final row = response[key];
    if (row is Map) {
      return Map<String, dynamic>.from(row);
    }

    if (response.isNotEmpty) {
      return response;
    }

    return null;
  }

  static String _stringValue(
    Object? value, {
    String fallback = '',
  }) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
  }

  static String? _optionalText(Object? value) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? null : text;
  }

  static int? _intValue(Object? value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '');
  }

  static String? _normalizedTextOrNull(String? value) {
    final text = value?.trim() ?? '';
    return text.isEmpty ? null : text;
  }

  static bool _looksLikeJson(String value) {
    final trimmed = value.trim();
    return trimmed.startsWith('{') && trimmed.endsWith('}');
  }

  static String _formatIsoDate(DateTime date) {
    return date.toIso8601String().split('T').first;
  }

  static int _ageYearsFromBirthDate(DateTime birthDate) {
    final now = DateTime.now();
    var years = now.year - birthDate.year;
    final hasHadBirthdayThisYear =
        now.month > birthDate.month ||
            (now.month == birthDate.month && now.day >= birthDate.day);
    if (!hasHadBirthdayThisYear) {
      years -= 1;
    }
    return years < 0 ? 0 : years;
  }

  static String _monthYearLabelFromDate(DateTime date) {
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

    return '${months[date.month - 1]} ${date.year}';
  }

  static String? _birthDateLabelFromIso(String? birthDateIso) {
    if (birthDateIso == null || birthDateIso.trim().isEmpty) {
      return null;
    }

    final parsed = DateTime.tryParse(birthDateIso);
    if (parsed == null) {
      return null;
    }

    return _monthYearLabelFromDate(parsed);
  }

  static String? _birthDateLabelFromAgeYears(int? ageYears) {
    if (ageYears == null) {
      return null;
    }

    if (ageYears <= 0) {
      return 'Meno di 1 anno';
    }

    final year = DateTime.now().year - ageYears;
    return 'Gen $year';
  }

  static String? _weightLabelFromKg(num? weightKg) {
    if (weightKg == null) {
      return null;
    }

    final normalized = weightKg.toStringAsFixed(
      weightKg.truncateToDouble() == weightKg ? 0 : 1,
    );
    return '${normalized.replaceAll('.', ',')} kg';
  }

  static String _healthBadgeForSpecies(String species) {
    switch (species.trim().toLowerCase()) {
      case 'gatto':
        return 'Da monitorare';
      case 'cane':
        return 'Stabile';
      default:
        return 'In valutazione';
    }
  }

  static _PetDemoPreset? _demoPresetFor({
    required String id,
    required String name,
  }) {
    for (final pet in samplePets) {
      if (pet.id == id || pet.name.toLowerCase() == name.toLowerCase()) {
        return _PetDemoPreset.fromPet(pet);
      }
    }

    return null;
  }

  static String _resolveAvatarKey(String? avatarKey, String species) {
    final key = avatarKey?.trim() ?? '';
    if (key.isNotEmpty) {
      return key;
    }
    return _defaultAvatarKeyForSpecies(species);
  }

  static String _defaultAvatarKeyForSpecies(String species) {
    switch (species.trim()) {
      case 'Cane':
        return 'portrait-bosco';
      case 'Gatto':
        return 'portrait-nebbia';
      case 'Coniglio':
        return 'portrait-miele';
      case 'Uccello':
        return 'portrait-oceano';
      case 'Rettile':
        return 'portrait-smeraldo';
      case 'Roditore':
      case 'Altro':
        return 'portrait-corallo';
      default:
        return 'portrait-bosco';
    }
  }

  static Color _backgroundColorForAvatarKey(String key) {
    switch (key) {
      case 'portrait-bosco':
        return const Color(0xFFE7F2EE);
      case 'portrait-miele':
        return const Color(0xFFF4E7D4);
      case 'portrait-oceano':
        return const Color(0xFFE0EEF4);
      case 'portrait-corallo':
        return const Color(0xFFF6E3DD);
      case 'portrait-nebbia':
        return const Color(0xFFF1F0EE);
      case 'portrait-smeraldo':
        return const Color(0xFFE2EFE6);
      default:
        return const Color(0xFFE7F2EE);
    }
  }
}

class _PetDemoPreset {
  const _PetDemoPreset({
    required this.breed,
    required this.birthDateLabel,
    required this.birthDateIso,
    required this.ageYears,
    required this.sex,
    required this.weightLabel,
    required this.medicalNote,
    required this.healthBadge,
    required this.nextVisitLabel,
    required this.avatarEmoji,
    required this.accentColor,
    this.profileImageDataUrl,
    this.galleryProvider,
  });

  final String breed;
  final String birthDateLabel;
  final String? birthDateIso;
  final int? ageYears;
  final String sex;
  final String weightLabel;
  final String medicalNote;
  final String healthBadge;
  final String nextVisitLabel;
  final String avatarEmoji;
  final Color accentColor;
  final String? profileImageDataUrl;
  final String? galleryProvider;

  factory _PetDemoPreset.fromPet(PetProfile pet) {
    return _PetDemoPreset(
      breed: pet.breed,
      birthDateLabel: pet.birthDateLabel,
      birthDateIso: pet.birthDateIso,
      ageYears: pet.ageYears,
      sex: pet.sex,
      weightLabel: pet.weightLabel,
      medicalNote: pet.medicalNote,
      healthBadge: pet.healthBadge,
      nextVisitLabel: pet.nextVisitLabel,
      avatarEmoji: pet.avatarEmoji,
      accentColor: pet.accentColor,
      profileImageDataUrl: pet.profileImageDataUrl,
      galleryProvider: pet.galleryProvider,
    );
  }
}

class _PetMetadata {
  const _PetMetadata({
    this.birthDateIso,
    this.birthDateLabel,
    this.sex,
    this.weightKg,
    this.weightLabel,
    this.medicalNote,
    this.healthBadge,
    this.nextVisitLabel,
    this.avatarKey,
    this.profileImageDataUrl,
    this.galleryProvider,
    this.accentColor,
    this.ageYears,
  });

  final String? birthDateIso;
  final String? birthDateLabel;
  final String? sex;
  final double? weightKg;
  final String? weightLabel;
  final String? medicalNote;
  final String? healthBadge;
  final String? nextVisitLabel;
  final String? avatarKey;
  final String? profileImageDataUrl;
  final String? galleryProvider;
  final Color? accentColor;
  final int? ageYears;

  static _PetMetadata? tryParse(String notes) {
    final trimmed = notes.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(trimmed);
      if (decoded is Map) {
        final map = Map<String, dynamic>.from(decoded);
        return _PetMetadata(
          birthDateIso: _textOrNull(map['birth_date_iso']),
          birthDateLabel: _textOrNull(map['birth_date_label']),
          sex: _textOrNull(map['sex']),
          weightKg: _doubleValue(map['weight_kg']),
          weightLabel: _textOrNull(map['weight_label']),
          medicalNote: _textOrNull(map['medical_note']),
          healthBadge: _textOrNull(map['health_badge']),
          nextVisitLabel: _textOrNull(map['next_visit_label']),
          avatarKey: _textOrNull(map['avatar_key']),
          profileImageDataUrl: _textOrNull(map['profile_image_data_url']),
          galleryProvider: _textOrNull(map['gallery_provider']),
          accentColor: _colorFromHex(_textOrNull(map['accent_color_hex'])),
          ageYears: PetApiRepository._intValue(map['age_years']),
        );
      }
    } catch (_) {
      return null;
    }

    return null;
  }

  static String? _textOrNull(Object? value) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? null : text;
  }

  static double? _doubleValue(Object? value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '');
  }

  static Color? _colorFromHex(String? value) {
    final normalized = value?.trim() ?? '';
    if (normalized.isEmpty) {
      return null;
    }

    final hex = normalized.replaceFirst('#', '');
    final parsed = int.tryParse(hex, radix: 16);
    if (parsed == null) {
      return null;
    }

    return Color(hex.length <= 6 ? 0xFF000000 | parsed : parsed);
  }
}
