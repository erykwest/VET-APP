import 'package:flutter/material.dart';

import '../domain/pet_models.dart';

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
  PetDemoStore._() {
    _pets = List<PetProfile>.of(samplePets);
  }

  static final PetDemoStore instance = PetDemoStore._();

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

  late List<PetProfile> _pets;

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

  PetProfile upsert(PetProfile pet) {
    final index = _pets.indexWhere((item) => item.id == pet.id);
    if (index == -1) {
      _pets = [pet, ..._pets];
      return pet;
    }

    _pets = [
      ..._pets.take(index),
      pet,
      ..._pets.skip(index + 1),
    ];
    return pet;
  }

  PetProfile create({
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
  }) {
    final option = optionForSpecies(species);
    final resolvedAvatarKey = resolveAvatarKey(
      avatarKey ?? defaultAvatarKeyForSpecies(species),
    );
    final pet = PetProfile(
      id: 'pet-${DateTime.now().microsecondsSinceEpoch}',
      name: name.trim(),
      species: species,
      breed: breed?.trim() ?? '',
      birthDateLabel: _formatDate(birthDate),
      sex: sex,
      weightLabel: _formatWeight(weightKg),
      medicalNote: medicalNote.trim().isEmpty
          ? 'Profilo creato da poco, pronto per la prossima visita.'
          : medicalNote.trim(),
      healthBadge: 'Nuovo profilo',
      nextVisitLabel: 'Da pianificare',
      avatarEmoji: resolvedAvatarKey,
      accentColor: option.accentColor,
      profileImageDataUrl: profileImageDataUrl,
      galleryProvider: galleryProvider,
    );

    return upsert(pet);
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
        return 'portrait-corallo';
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

  static String _formatWeight(double weightKg) {
    final normalized = weightKg.toStringAsFixed(
      weightKg.truncateToDouble() == weightKg ? 0 : 1,
    );
    return '${normalized.replaceAll('.', ',')} kg';
  }

  static String _formatDate(DateTime date) {
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

    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
  }

  static bool _looksLikePresetKey(String key) {
    final trimmed = key.trim();
    return trimmed.startsWith('portrait-') ||
        trimmed.startsWith('photo-') ||
        trimmed.startsWith('avatar-');
  }
}

const samplePets = <PetProfile>[
  PetProfile(
    id: 'pet-moka',
    name: 'Moka',
    species: 'Cane',
    breed: 'Meticcio - Media',
    birthDateLabel: 'Mag 2021',
    sex: 'Femmina',
    weightLabel: '17,8 kg',
    medicalNote:
        'Stomaco delicato, dieta leggera e controllo periodico gia pianificato.',
    healthBadge: 'Stabile',
    nextVisitLabel: 'Vaccino di richiamo tra 12 giorni',
    avatarEmoji: 'portrait-bosco',
    accentColor: Color(0xFFE7F2EE),
  ),
  PetProfile(
    id: 'pet-oliver',
    name: 'Oliver',
    species: 'Gatto',
    breed: 'Europeo a pelo corto',
    birthDateLabel: 'Set 2019',
    sex: 'Maschio',
    weightLabel: '5,1 kg',
    medicalNote:
        'Vita in casa, toelettatura regolare e attenzione ai controlli dentali.',
    healthBadge: 'Da monitorare',
    nextVisitLabel: 'Controllo dentale la prossima settimana',
    avatarEmoji: 'portrait-nebbia',
    accentColor: Color(0xFFF6EADF),
  ),
];
