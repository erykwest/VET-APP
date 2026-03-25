import 'package:flutter/material.dart';

enum PetsScreenStatus {
  loading,
  empty,
  error,
  success,
}

class PetProfile {
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
    id: 'pet-luna',
    name: 'Luna',
    species: 'Dog',
    breed: 'Border Collie',
    birthDateLabel: 'Apr 2021',
    sex: 'Female',
    weightLabel: '18.4 kg',
    medicalNote: 'Sensitive stomach, needs gentle diet and regular checkups.',
    healthBadge: 'Stable',
    nextVisitLabel: 'Vaccination due in 21 days',
    avatarEmoji: 'L',
    accentColor: Color(0xFFE7F2EE),
  ),
  PetProfile(
    id: 'pet-nemo',
    name: 'Nemo',
    species: 'Cat',
    breed: 'European Shorthair',
    birthDateLabel: 'Sep 2019',
    sex: 'Male',
    weightLabel: '5.2 kg',
    medicalNote: 'Prefers indoor life and regular fur care.',
    healthBadge: 'Needs review',
    nextVisitLabel: 'Dental follow-up next week',
    avatarEmoji: 'N',
    accentColor: Color(0xFFF6EADF),
  ),
  PetProfile(
    id: 'pet-kiwi',
    name: 'Kiwi',
    species: 'Rabbit',
    breed: 'Dwarf rabbit',
    birthDateLabel: 'Jan 2023',
    sex: 'Female',
    weightLabel: '2.8 kg',
    medicalNote: 'Weekly diet tracking and hydration reminders.',
    healthBadge: 'Good',
    nextVisitLabel: 'Routine check in 1 month',
    avatarEmoji: 'K',
    accentColor: Color(0xFFDDEDE8),
  ),
];
