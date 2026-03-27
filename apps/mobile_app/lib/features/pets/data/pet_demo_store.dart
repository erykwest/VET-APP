import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../domain/pet_models.dart';
import 'pet_api_repository.dart';

class PetAvatarChoice {
  const PetAvatarChoice({
    required this.key,
    required this.label,
    required this.subtitle,
    required this.backgroundColor,
    required this.accentColor,
    required this.icon,
  });

  final String key;
  final String label;
  final String subtitle;
  final Color backgroundColor;
  final Color accentColor;
  final IconData icon;
}

class PetSpeciesOption {
  const PetSpeciesOption({
    required this.label,
    required this.avatarEmoji,
    required this.accentColor,
    required this.breeds,
  });

  final String label;
  final String avatarEmoji;
  final Color accentColor;
  final List<String> breeds;
}

class PetDemoStore {
  PetDemoStore._({PetApiRepository? repository})
      : _repository = repository ?? PetApiRepository();

  factory PetDemoStore.testing({required PetApiRepository repository}) {
    return PetDemoStore._(repository: repository);
  }

  static final PetDemoStore instance = PetDemoStore._();

  final PetApiRepository _repository;
  List<PetProfile> _pets = List<PetProfile>.of(samplePets);
  bool _hasLoaded = false;
  bool _isLoading = false;
  String? _errorMessage;

  bool get hasLoaded => _hasLoaded;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  static const List<PetAvatarChoice> avatarChoices = [
    PetAvatarChoice(
      key: 'portrait-bosco',
      label: 'Bosco',
      subtitle: 'Verde clinico e deciso',
      backgroundColor: Color(0xFFE7F2EE),
      accentColor: Color(0xFF2F6B6D),
      icon: Icons.park_rounded,
    ),
    PetAvatarChoice(
      key: 'portrait-miele',
      label: 'Miele',
      subtitle: 'Caldo, morbido, luminoso',
      backgroundColor: Color(0xFFF4E7D4),
      accentColor: Color(0xFF9F6A3D),
      icon: Icons.wb_sunny_rounded,
    ),
    PetAvatarChoice(
      key: 'portrait-oceano',
      label: 'Oceano',
      subtitle: 'Fresco e pulito',
      backgroundColor: Color(0xFFE0EEF4),
      accentColor: Color(0xFF2E6F8A),
      icon: Icons.water_rounded,
    ),
    PetAvatarChoice(
      key: 'portrait-corallo',
      label: 'Corallo',
      subtitle: 'Accento vivo ma gentile',
      backgroundColor: Color(0xFFF6E3DD),
      accentColor: Color(0xFFC96C55),
      icon: Icons.favorite_rounded,
    ),
    PetAvatarChoice(
      key: 'portrait-nebbia',
      label: 'Nebbia',
      subtitle: 'Soft e neutro',
      backgroundColor: Color(0xFFF1F0EE),
      accentColor: Color(0xFF7A7F87),
      icon: Icons.cloud_rounded,
    ),
    PetAvatarChoice(
      key: 'portrait-smeraldo',
      label: 'Smeraldo',
      subtitle: 'Profondo e premium',
      backgroundColor: Color(0xFFE2EFE6),
      accentColor: Color(0xFF3F7D63),
      icon: Icons.eco_rounded,
    ),
  ];

  static const List<PetSpeciesOption> speciesOptions = [
    PetSpeciesOption(
      label: 'Cane',
      avatarEmoji: 'portrait-bosco',
      accentColor: Color(0xFFE7F2EE),
      breeds: [
        'Labrador Retriever',
        'Golden Retriever',
        'Border Collie',
        'Meticcio',
      ],
    ),
    PetSpeciesOption(
      label: 'Gatto',
      avatarEmoji: 'portrait-nebbia',
      accentColor: Color(0xFFF6EADF),
      breeds: [
        'Europeo',
        'Europeo a pelo corto',
        'Siamese',
        'Norvegese delle foreste',
      ],
    ),
    PetSpeciesOption(
      label: 'Coniglio',
      avatarEmoji: 'portrait-miele',
      accentColor: Color(0xFFF5F0D8),
      breeds: [
        'Olandese',
        'Nana',
        'Ariete',
      ],
    ),
    PetSpeciesOption(
      label: 'Uccello',
      avatarEmoji: 'portrait-oceano',
      accentColor: Color(0xFFE0EEF4),
      breeds: [
        'Pappagallo',
        'Canarino',
        'Cocorita',
      ],
    ),
    PetSpeciesOption(
      label: 'Rettile',
      avatarEmoji: 'portrait-smeraldo',
      accentColor: Color(0xFFE9F0D7),
      breeds: [],
    ),
    PetSpeciesOption(
      label: 'Roditore',
      avatarEmoji: 'portrait-corallo',
      accentColor: Color(0xFFF2E9DB),
      breeds: [],
    ),
    PetSpeciesOption(
      label: 'Altro',
      avatarEmoji: 'portrait-corallo',
      accentColor: Color(0xFFF1E7F3),
      breeds: [],
    ),
  ];

  static const List<String> sexOptions = [
    'Maschio',
    'Femmina',
    'Sconosciuto',
  ];

  static const List<String> galleryProviderOptions = [
    'Google Foto',
    'Apple Foto',
    'Amazon Photos',
  ];

  Future<void> initialize({bool force = false}) async {
    if (_hasLoaded && !force) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    try {
      _pets = await _repository.listPets();
      if (_pets.isEmpty) {
        _pets = List<PetProfile>.of(samplePets);
      }
      _hasLoaded = true;
    } catch (error) {
      _errorMessage = error.toString();
      _pets = List<PetProfile>.of(samplePets);
      _hasLoaded = true;
    } finally {
      _isLoading = false;
    }
  }

  List<PetProfile> list({String? species}) {
    final normalizedSpecies = species?.trim() ?? '';
    if (normalizedSpecies.isEmpty || normalizedSpecies == 'Tutti') {
      return List<PetProfile>.unmodifiable(_pets);
    }

    return List<PetProfile>.unmodifiable(
      _pets.where((pet) => pet.species == normalizedSpecies),
    );
  }

  PetProfile? byId(String id) {
    for (final pet in _pets) {
      if (pet.id == id) {
        return pet;
      }
    }
    return null;
  }

  Future<PetProfile> create({
    required String name,
    required String species,
    required String? breed,
    required DateTime birthDate,
    required String sex,
    required double weightKg,
    String medicalNote = '',
    String? avatarKey,
    String? profileImageDataUrl,
    String? galleryProvider,
  }) async {
    final resolvedAvatarKey = resolveAvatarKey(
      avatarKey ?? defaultAvatarKeyForSpecies(species),
    );
    final created = await _repository.createPet(
      name: name.trim(),
      species: species,
      breed: breed?.trim(),
      birthDate: birthDate,
      sex: sex,
      weightKg: weightKg,
      medicalNote: medicalNote.trim().isEmpty
          ? 'Profilo creato da poco, pronto per la prossima visita.'
          : medicalNote.trim(),
      healthBadge: 'Nuovo profilo',
      nextVisitLabel: 'Da pianificare',
      avatarKey: resolvedAvatarKey,
      profileImageDataUrl: profileImageDataUrl,
      galleryProvider: galleryProvider,
    );
    _pets = [created, ..._pets.where((pet) => pet.id != created.id)];
    return created;
  }

  Future<PetProfile> upsert(PetProfile pet) async {
    final updated = await _repository.updatePet(
      petId: pet.id,
      name: pet.name,
      species: pet.species,
      breed: pet.breed,
      birthDate: _birthDateFromPet(pet),
      sex: pet.sex,
      weightKg: _weightKgFromLabel(pet.weightLabel),
      medicalNote: pet.medicalNote,
      healthBadge: pet.healthBadge,
      nextVisitLabel: pet.nextVisitLabel,
      avatarKey: pet.avatarEmoji,
      profileImageDataUrl: pet.profileImageDataUrl,
      galleryProvider: pet.galleryProvider,
    );
    _pets = [
      updated,
      ..._pets.where((item) => item.id != updated.id),
    ];
    return updated;
  }

  static PetSpeciesOption optionForSpecies(String species) {
    return speciesOptions.firstWhere(
      (option) => option.label == species,
      orElse: () => speciesOptions.last,
    );
  }

  static bool supportsMixedBreed(String species) {
    final normalized = species.trim();
    return normalized == 'Cane' || normalized == 'Gatto';
  }

  static bool isFallbackSpecies(String species) {
    return optionForSpecies(species).breeds.isEmpty;
  }

  static List<String> breedsForSpecies(String species) {
    final option = optionForSpecies(species);
    if (option.breeds.isEmpty) {
      return const [
        'Razza non specificata',
        'Da definire con assistente',
        'Altro',
      ];
    }

    final breeds = <String>['Razza non specificata', ...option.breeds];
    if (supportsMixedBreed(option.label) &&
        !breeds.contains(PetProfile.mixedBreedLabel)) {
      breeds.add(PetProfile.mixedBreedLabel);
    }

    return breeds;
  }

  static String resolveAvatarKey(String? rawKey) {
    final key = rawKey?.trim() ?? '';
    if (key.isEmpty) {
      return avatarChoices.first.key;
    }

    return avatarChoices.any((choice) => choice.key == key)
        ? key
        : avatarChoices.first.key;
  }

  static String defaultAvatarKeyForSpecies(String species) {
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
        return avatarChoices.first.key;
    }
  }

  static PetAvatarChoice avatarChoiceForKey(String key) {
    return avatarChoices.firstWhere(
      (choice) => choice.key == key,
      orElse: () => avatarChoices.first,
    );
  }

  static String avatarChoiceLabelForKey(String key) {
    if (!_looksLikePresetKey(key)) {
      final trimmed = key.trim();
      return trimmed.isEmpty ? 'Avatar preview' : 'Monogramma';
    }

    return avatarChoiceForKey(resolveAvatarKey(key)).label;
  }

  static bool _looksLikePresetKey(String key) {
    final trimmed = key.trim();
    return trimmed.startsWith('portrait-') ||
        trimmed.startsWith('photo-') ||
        trimmed.startsWith('avatar-');
  }

  DateTime _birthDateFromPet(PetProfile pet) {
    if (pet.birthDateIso != null) {
      final parsed = DateTime.tryParse(pet.birthDateIso!);
      if (parsed != null) {
        return parsed;
      }
    }

    final parts = pet.birthDateLabel.split(' ');
    if (parts.length == 2) {
      const months = {
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
      final month = months[parts[0].toLowerCase()];
      final year = int.tryParse(parts[1]);
      if (month != null && year != null) {
        return DateTime(year, month, 1);
      }
    }

    final ageYears = pet.ageYears;
    if (ageYears != null) {
      final now = DateTime.now();
      return DateTime(now.year - ageYears, 1, 1);
    }

    return DateTime.now();
  }

  double _weightKgFromLabel(String weightLabel) {
    final normalized = weightLabel.toLowerCase().replaceAll('kg', '').trim();
    return double.tryParse(normalized.replaceAll(',', '.')) ?? 0;
  }
}
