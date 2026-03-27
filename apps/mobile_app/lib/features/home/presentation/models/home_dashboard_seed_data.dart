import 'package:flutter/material.dart';

import '../../../chat/data/chat_seed_data.dart';
import '../../../pets/domain/pet_models.dart';
import '../widgets/home_dashboard_sections.dart';
import 'home_dashboard_insight_models.dart';

class HomeDashboardSeedData {
  const HomeDashboardSeedData({
    required this.activePet,
    required this.heroDetails,
    required this.heroDescription,
    required this.reminders,
    required this.aiPrompt,
    required this.aiSuggestions,
    required this.insightSections,
    required this.alertCount,
  });

  final PetProfile activePet;
  final String heroDetails;
  final String heroDescription;
  final List<WarmClinicalReminderItem> reminders;
  final String aiPrompt;
  final List<WarmClinicalAiSuggestion> aiSuggestions;
  final List<HomeDashboardInsightSection> insightSections;
  final int alertCount;

  static HomeDashboardSeedData fromSeeds() {
    final activePet = samplePets.first;
    return HomeDashboardSeedData(
      activePet: activePet,
      heroDetails:
          '${activePet.species} - ${activePet.breedLabel} - ${activePet.weightLabel}',
      heroDescription:
          '${activePet.medicalNote} Prossima visita: ${activePet.nextVisitLabel}.',
      reminders: const [
        WarmClinicalReminderItem(
          title: 'Antiparassitario di Moka',
          subtitle: 'Ogni 30 giorni',
          icon: Icons.notifications_active_outlined,
          trailing: Text(
            'Tra 3 giorni',
            style: TextStyle(
              color: Color(0xFF2E686A),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        WarmClinicalReminderItem(
          title: 'Richiamo vaccinale di Moka',
          subtitle: 'Ogni 12 mesi',
          icon: Icons.vaccines_outlined,
          trailing: Text(
            'Tra 21 giorni',
            style: TextStyle(
              color: Color(0xFF2E686A),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
      aiPrompt: ChatSeedData.conversations.first.previewMessage,
      aiSuggestions: const [
        WarmClinicalAiSuggestion(
          label: 'Moka - appetito e controllo',
          icon: Icons.chat_bubble_outline_rounded,
        ),
        WarmClinicalAiSuggestion(
          label: 'Richiamo vaccino',
          icon: Icons.vaccines_outlined,
        ),
      ],
      insightSections: HomeDashboardInsightComposer.buildForPet(
        activePet,
        conversations: ChatSeedData.conversations,
      ),
      alertCount: 3,
    );
  }
}
