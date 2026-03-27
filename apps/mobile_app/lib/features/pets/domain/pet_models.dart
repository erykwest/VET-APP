import 'package:flutter/material.dart';

enum PetsScreenStatus {
  loading,
  empty,
  error,
  success,
}

class PetProfile {
  static const String mixedBreedLabel = 'Meticcio';
  static const List<String> mixedBreedSizeOptions = [
    'Toy',
    'Piccola',
    'Medio-piccola',
    'Media',
    'Medio-grande',
    'Grande',
    'Gigante',
  ];

  const PetProfile({
    required this.id,
    required this.name,
    required this.species,
    required this.breed,
    required this.birthDateLabel,
    required this.sex,
    required this.weightLabel,
    required this.medicalNote,
    required this.healthBadge,
    required this.nextVisitLabel,
    required this.avatarEmoji,
    required this.accentColor,
  });

  final String id;
  final String name;
  final String species;
  final String breed;
  final String birthDateLabel;
  final String sex;
  final String weightLabel;
  final String medicalNote;
  final String healthBadge;
  final String nextVisitLabel;
  final String avatarEmoji;
  final Color accentColor;

  String get title => '$name - $species';
  String get breedLabel =>
      breed.trim().isEmpty ? 'Razza non specificata' : breed.trim();
  bool get isMixedBreed => isMixedBreedLabel(breed);
  String? get mixedBreedSize => mixedBreedSizeFromLabel(breed);

  static bool isMixedBreedLabel(String? breed) {
    final normalized = breed?.trim().toLowerCase() ?? '';
    if (normalized.isEmpty) {
      return false;
    }

    return normalized == mixedBreedLabel.toLowerCase() ||
        normalized.startsWith('${mixedBreedLabel.toLowerCase()} ') ||
        normalized.startsWith('${mixedBreedLabel.toLowerCase()}-') ||
        normalized.startsWith('${mixedBreedLabel.toLowerCase()}(');
  }

  static String? mixedBreedSizeFromLabel(String? breed) {
    final normalized = breed?.trim().toLowerCase() ?? '';
    if (!isMixedBreedLabel(normalized)) {
      return null;
    }

    const aliases = [
      ('medio-piccola', 'Medio-piccola'),
      ('medio piccola', 'Medio-piccola'),
      ('medio-grande', 'Medio-grande'),
      ('medio grande', 'Medio-grande'),
      ('toy', 'Toy'),
      ('piccola', 'Piccola'),
      ('media', 'Media'),
      ('grande', 'Grande'),
      ('gigante', 'Gigante'),
    ];

    for (final alias in aliases) {
      if (normalized.contains(alias.$1)) {
        return alias.$2;
      }
    }

    return null;
  }

  static String mixedBreedLabelForSize(String size) {
    return '$mixedBreedLabel - $size';
  }

  PetProfile copyWith({
    String? id,
    String? name,
    String? species,
    String? breed,
    String? birthDateLabel,
    String? sex,
    String? weightLabel,
    String? medicalNote,
    String? healthBadge,
    String? nextVisitLabel,
    String? avatarEmoji,
    Color? accentColor,
  }) {
    return PetProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      species: species ?? this.species,
      breed: breed ?? this.breed,
      birthDateLabel: birthDateLabel ?? this.birthDateLabel,
      sex: sex ?? this.sex,
      weightLabel: weightLabel ?? this.weightLabel,
      medicalNote: medicalNote ?? this.medicalNote,
      healthBadge: healthBadge ?? this.healthBadge,
      nextVisitLabel: nextVisitLabel ?? this.nextVisitLabel,
      avatarEmoji: avatarEmoji ?? this.avatarEmoji,
      accentColor: accentColor ?? this.accentColor,
    );
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
        'Stomaco delicato, dieta leggera e controllo periodico già pianificato.',
    healthBadge: 'Stabile',
    nextVisitLabel: 'Vaccino di richiamo tra 12 giorni',
    avatarEmoji: 'M',
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
    avatarEmoji: 'O',
    accentColor: Color(0xFFF6EADF),
  ),
];
