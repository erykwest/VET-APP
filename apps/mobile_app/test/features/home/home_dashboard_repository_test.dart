import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vet_app_mobile/features/chat/domain/chat_models.dart';
import 'package:vet_app_mobile/features/home/data/home_dashboard_repository.dart';
import 'package:vet_app_mobile/features/home/presentation/models/home_dashboard_seed_data.dart';
import 'package:vet_app_mobile/features/home/presentation/widgets/home_dashboard_sections.dart';
import 'package:vet_app_mobile/features/pets/domain/pet_models.dart';

void main() {
  const moka = PetProfile(
    id: 'pet-moka',
    name: 'Moka',
    species: 'Cane',
    breed: 'Meticcio - Media',
    birthDateLabel: 'Mag 2021',
    birthDateIso: '2021-05-01',
    ageYears: 4,
    sex: 'Femmina',
    weightLabel: '17,8 kg',
    medicalNote: 'Stomaco delicato',
    healthBadge: 'Stabile',
    nextVisitLabel: 'Vaccino di richiamo tra 12 giorni',
    avatarEmoji: 'portrait-bosco',
    accentColor: Color(0xFFE7F2EE),
  );

  const oliver = PetProfile(
    id: 'pet-oliver',
    name: 'Oliver',
    species: 'Gatto',
    breed: 'Europeo a pelo corto',
    birthDateLabel: 'Set 2019',
    birthDateIso: '2019-09-01',
    ageYears: 6,
    sex: 'Maschio',
    weightLabel: '5,1 kg',
    medicalNote: 'Vita in casa',
    healthBadge: 'Da monitorare',
    nextVisitLabel: 'Controllo dentale la prossima settimana',
    avatarEmoji: 'portrait-nebbia',
    accentColor: Color(0xFFF6EADF),
  );

  test('selectActivePet prefers an id coming from backend relations', () {
    final selected = HomeDashboardRepository.selectActivePet(
      [moka, oliver],
      preferredPetIds: const ['pet-oliver'],
    );

    expect(selected, oliver);
  });

  test('parses dashboard rows and composes real seed data', () {
    final petsById = {moka.id: moka, oliver.id: oliver};

    final conversation = HomeDashboardRepository.conversationSummaryFromApi(
      {
        'id': 'conv-1',
        'pet_id': moka.id,
        'title': 'Vaccino Moka',
        'messages': [
          {
            'id': 'msg-1',
            'role': 'user',
            'content': 'Come sta?',
            'created_at': '2026-03-27T08:00:00Z',
          },
          {
            'id': 'msg-2',
            'role': 'assistant',
            'content': 'Serve acqua extra?',
            'created_at': '2026-03-27T08:10:00Z',
          },
        ],
      },
      petsById: petsById,
    );

    final reminder = HomeDashboardRepository.reminderItemFromApi(
      {
        'id': 'rem-1',
        'pet_id': moka.id,
        'title': 'Vaccino di richiamo',
        'due_date': '2026-04-05',
        'notes': 'Porta il libretto',
      },
      petsById: petsById,
    );

    final seed = HomeDashboardRepository.buildDashboardData(
      activePet: moka,
      conversations: [conversation],
      reminderItems: [reminder],
    );

    expect(seed.activePet, moka);
    expect(seed.heroDetails, contains('Cane - Meticcio - Media - 17,8 kg'));
    expect(seed.aiPrompt, 'Serve acqua extra?');
    expect(seed.alertCount, 2);
    expect(seed.reminders, hasLength(1));
    expect(seed.reminders.first.title, 'Vaccino di richiamo');
    expect(seed.reminders.first.subtitle, contains('Moka'));

    final trailing = seed.reminders.first.trailing;
    expect(trailing, isA<Text>());
    expect((trailing as Text).data, isNotEmpty);

    expect(seed.aiSuggestions, isNotEmpty);
    expect(seed.insightSections, isNotEmpty);
  });
}
