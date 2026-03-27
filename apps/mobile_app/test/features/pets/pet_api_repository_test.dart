import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vet_app_mobile/features/pets/data/pet_api_repository.dart';

void main() {
  test('petFromJson hydrates demo metadata from notes JSON', () {
    final pet = PetApiRepository.petFromJson({
      'id': 'pet-moka',
      'name': 'Moka',
      'species': 'Cane',
      'breed': 'Meticcio - Media',
      'age_years': 4,
      'notes': jsonEncode({
        'birth_date_iso': '2021-05-01',
        'birth_date_label': 'Mag 2021',
        'sex': 'Femmina',
        'weight_kg': 17.8,
        'weight_label': '17,8 kg',
        'medical_note': 'Stomaco delicato',
        'health_badge': 'Stabile',
        'next_visit_label': 'Vaccino di richiamo tra 12 giorni',
        'avatar_key': 'portrait-bosco',
        'accent_color_hex': 'ffe7f2ee',
        'gallery_provider': 'Google Foto',
      }),
    });

    expect(pet.name, 'Moka');
    expect(pet.birthDateLabel, 'Mag 2021');
    expect(pet.birthDateIso, '2021-05-01');
    expect(pet.ageYears, 4);
    expect(pet.sex, 'Femmina');
    expect(pet.weightLabel, '17,8 kg');
    expect(pet.medicalNote, 'Stomaco delicato');
    expect(pet.healthBadge, 'Stabile');
    expect(pet.nextVisitLabel, 'Vaccino di richiamo tra 12 giorni');
    expect(pet.avatarEmoji, 'portrait-bosco');
    expect(pet.accentColor, const Color(0xFFE7F2EE));
    expect(pet.galleryProvider, 'Google Foto');
  });

  test('requestBodyFromProfile serializes structured notes for backend', () {
    final body = PetApiRepository.requestBodyFromProfile(
      name: 'Oliver',
      species: 'Gatto',
      breed: '',
      birthDate: DateTime(2019, 9, 1),
      sex: 'Maschio',
      weightKg: 5.1,
      medicalNote: 'Vita in casa',
      healthBadge: 'Da monitorare',
      nextVisitLabel: 'Controllo dentale la prossima settimana',
      avatarKey: 'portrait-nebbia',
      galleryProvider: 'Apple Foto',
    );

    expect(body['name'], 'Oliver');
    expect(body['species'], 'Gatto');
    expect(body['breed'], isNull);
    expect(body['age_years'], 6);

    final notes = jsonDecode(body['notes'] as String) as Map<String, dynamic>;
    expect(notes['birth_date_iso'], '2019-09-01');
    expect(notes['birth_date_label'], 'Set 2019');
    expect(notes['sex'], 'Maschio');
    expect(notes['weight_label'], '5,1 kg');
    expect(notes['medical_note'], 'Vita in casa');
    expect(notes['avatar_key'], 'portrait-nebbia');
    expect(notes['gallery_provider'], 'Apple Foto');
    expect(notes['accent_color_hex'], 'fff1f0ee');
  });
}
