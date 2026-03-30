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
    this.birthDateIso,
    this.ageYears,
    this.profileImageDataUrl,
    this.galleryProvider,
  });

  final String id;
  final String name;
  final String species;
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

  String get title => '$name - $species';
  IconData get speciesIcon => speciesIconFor(species);
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

  static IconData speciesIconFor(String species) {
    switch (species.trim().toLowerCase()) {
      case 'cane':
        return Icons.pets_rounded;
      case 'gatto':
        return Icons.pets_outlined;
      case 'coniglio':
        return Icons.cruelty_free_outlined;
      case 'uccello':
        return Icons.flutter_dash_rounded;
      case 'rettile':
        return Icons.bug_report_outlined;
      case 'roditore':
        return Icons.park_outlined;
      case 'altro':
        return Icons.category_outlined;
      default:
        return Icons.pets_rounded;
    }
  }

  PetProfile copyWith({
    String? id,
    String? name,
    String? species,
    String? breed,
    String? birthDateLabel,
    String? birthDateIso,
    int? ageYears,
    String? sex,
    String? weightLabel,
    String? medicalNote,
    String? healthBadge,
    String? nextVisitLabel,
    String? avatarEmoji,
    Color? accentColor,
    String? profileImageDataUrl,
    String? galleryProvider,
  }) {
    return PetProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      species: species ?? this.species,
      breed: breed ?? this.breed,
      birthDateLabel: birthDateLabel ?? this.birthDateLabel,
      birthDateIso: birthDateIso ?? this.birthDateIso,
      ageYears: ageYears ?? this.ageYears,
      sex: sex ?? this.sex,
      weightLabel: weightLabel ?? this.weightLabel,
      medicalNote: medicalNote ?? this.medicalNote,
      healthBadge: healthBadge ?? this.healthBadge,
      nextVisitLabel: nextVisitLabel ?? this.nextVisitLabel,
      avatarEmoji: avatarEmoji ?? this.avatarEmoji,
      accentColor: accentColor ?? this.accentColor,
      profileImageDataUrl: profileImageDataUrl ?? this.profileImageDataUrl,
      galleryProvider: galleryProvider ?? this.galleryProvider,
    );
  }
}

const samplePets = <PetProfile>[];
