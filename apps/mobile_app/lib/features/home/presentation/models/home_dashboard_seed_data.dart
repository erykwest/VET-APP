import 'package:flutter/material.dart';

import '../../../chat/data/chat_seed_data.dart';
import '../../../chat/domain/chat_models.dart';
import '../../../pets/domain/pet_models.dart';
import 'home_dashboard_insight_models.dart';
import '../widgets/home_dashboard_sections.dart';

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

  factory HomeDashboardSeedData.fromSeeds() {
    final activePet = samplePets.first;
    final conversations = ChatSeedData.conversations
        .where((conversation) => conversation.activePetName == activePet.name)
        .toList(growable: false);
    final reminders = _buildReminders(activePet, conversations);
    final primaryConversation = conversations.isNotEmpty
        ? conversations.first
        : const ChatConversationSummary(
            id: 'dashboard-fallback',
            title: 'Assistente',
            subtitle: 'Nessuna conversazione pronta.',
            updatedAtLabel: 'ora',
            unreadCount: 0,
            activePetName: 'Pet',
            previewMessage: 'La chat sara disponibile nella prossima iterazione.',
            lastSender: 'Assistente',
          );

    return HomeDashboardSeedData(
      activePet: activePet,
      heroDetails:
          '${activePet.species} - ${activePet.breed} - ${activePet.weightLabel}',
      heroDescription:
          '${activePet.medicalNote} Prossima visita: ${activePet.nextVisitLabel}.',
      reminders: reminders,
      aiPrompt: primaryConversation.previewMessage,
      aiSuggestions: _buildSuggestions(conversations),
      insightSections: HomeDashboardInsightComposer.buildForPet(
        activePet,
        conversations: conversations,
      ),
      alertCount: _countAlerts(conversations, reminders.length),
    );
  }

  static int _countAlerts(
    List<ChatConversationSummary> conversations,
    int reminderCount,
  ) {
    final unread = conversations.fold<int>(
      0,
      (sum, conversation) => sum + conversation.unreadCount,
    );
    return unread + reminderCount;
  }

  static List<WarmClinicalReminderItem> _buildReminders(
    PetProfile pet,
    List<ChatConversationSummary> conversations,
  ) {
    final conversation = conversations.isNotEmpty ? conversations.first : null;

    return [
      WarmClinicalReminderItem(
        title: 'Prossima visita',
        subtitle: pet.nextVisitLabel,
        icon: Icons.event_note_rounded,
        iconColor: const Color(0xFFE5856F),
        trailing: const _ReminderTrailingText('Pet'),
      ),
      if (conversation != null)
        WarmClinicalReminderItem(
          title: 'Chat da leggere',
          subtitle: '${conversation.title} - ${conversation.updatedAtLabel}',
          icon: Icons.chat_bubble_outline_rounded,
          iconColor: const Color(0xFF5F9F86),
          trailing: _ReminderTrailingText('${conversation.unreadCount} msg'),
        ),
      WarmClinicalReminderItem(
        title: 'Reminder attivo',
        subtitle: 'Richiamo vaccinale di ${pet.name}',
        icon: Icons.notifications_active_outlined,
        iconColor: const Color(0xFF6F91A3),
        trailing: const _ReminderTrailingText('Core'),
      ),
      if (conversations.isEmpty)
        WarmClinicalReminderItem(
          title: 'Nuova chat',
          subtitle: 'Apri il primo scambio per creare il contesto iniziale.',
          icon: Icons.add_comment_outlined,
          iconColor: const Color(0xFF6F91A3),
          trailing: const _ReminderTrailingText('Preview'),
        ),
    ];
  }

  static List<WarmClinicalAiSuggestion> _buildSuggestions(
    List<ChatConversationSummary> conversations,
  ) {
    final suggestions = conversations
        .take(3)
        .map(
          (conversation) => WarmClinicalAiSuggestion(
            label: conversation.title,
            icon: _suggestionIconForConversation(conversation),
          ),
        )
        .toList(growable: false);

    if (suggestions.isNotEmpty) {
      return suggestions;
    }

    return const [
      WarmClinicalAiSuggestion(
        label: 'Apri assistente',
        icon: Icons.smart_toy_outlined,
      ),
    ];
  }

  static IconData _suggestionIconForConversation(
    ChatConversationSummary conversation,
  ) {
    if (conversation.title.toLowerCase().contains('vaccino')) {
      return Icons.vaccines_outlined;
    }
    if (conversation.title.toLowerCase().contains('referto')) {
      return Icons.summarize_outlined;
    }
    return Icons.chat_bubble_outline_rounded;
  }
}

class _ReminderTrailingText extends StatelessWidget {
  const _ReminderTrailingText(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: const Color(0xFF2E686A),
            fontWeight: FontWeight.w700,
          ),
    );
  }
}
