import 'package:flutter/material.dart';

import '../../../chat/data/chat_seed_data.dart';
import '../../../chat/domain/chat_models.dart';
import '../../../medical_records/data/medical_records_repository.dart';
import '../../../pets/domain/pet_models.dart';
import '../widgets/home_dashboard_sections.dart';

class HomeDashboardSeedData {
  const HomeDashboardSeedData({
    required this.activePet,
    required this.heroDetails,
    required this.heroDescription,
    required this.reminders,
    required this.documents,
    required this.activity,
    required this.aiPrompt,
    required this.aiSuggestions,
    required this.alertCount,
  });

  final PetProfile activePet;
  final String heroDetails;
  final String heroDescription;
  final List<WarmClinicalReminderItem> reminders;
  final List<WarmClinicalDocumentItem> documents;
  final List<WarmClinicalActivityItem> activity;
  final String aiPrompt;
  final List<WarmClinicalAiSuggestion> aiSuggestions;
  final int alertCount;

  factory HomeDashboardSeedData.fromSeeds() {
    final activePet = samplePets.first;
    final conversations = ChatSeedData.conversations
        .where((conversation) => conversation.activePetName == activePet.name)
        .toList(growable: false);
    final records = MedicalRecordsRepository.previewRecords;
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
          '${activePet.species} • ${activePet.breed} • ${activePet.weightLabel}',
      heroDescription:
          '${activePet.medicalNote} Prossima visita: ${activePet.nextVisitLabel}.',
      reminders: _buildReminders(activePet, records, conversations),
      documents: _buildDocuments(records),
      activity: _buildActivity(records, conversations),
      aiPrompt: primaryConversation.previewMessage,
      aiSuggestions: _buildSuggestions(conversations),
      alertCount: _countAlerts(activePet, records, conversations),
    );
  }

  static int _countAlerts(
    PetProfile pet,
    List<MedicalRecordEntry> records,
    List<ChatConversationSummary> conversations,
  ) {
    final unread = conversations.fold<int>(
      0,
      (sum, conversation) => sum + conversation.unreadCount,
    );
    return [unread, records.where((record) => record.badge != 'Archivio').length, 1]
        .reduce((a, b) => a + b);
  }

  static List<WarmClinicalReminderItem> _buildReminders(
    PetProfile pet,
    List<MedicalRecordEntry> records,
    List<ChatConversationSummary> conversations,
  ) {
    final reminderTitle = pet.nextVisitLabel;
    final record = records.isNotEmpty ? records.first : null;
    final conversation = conversations.length > 1
        ? conversations[1]
        : (conversations.isNotEmpty ? conversations.first : null);

    return [
      WarmClinicalReminderItem(
        title: 'Prossima visita',
        subtitle: reminderTitle,
        icon: Icons.event_note_rounded,
        iconColor: const Color(0xFFE5856F),
        trailing: const _ReminderTrailingText('Pet'),
      ),
      if (conversation != null)
        WarmClinicalReminderItem(
          title: 'Chat da leggere',
          subtitle: '${conversation.title} • ${conversation.updatedAtLabel}',
          icon: Icons.chat_bubble_outline_rounded,
          iconColor: const Color(0xFF5F9F86),
          trailing: _ReminderTrailingText('${conversation.unreadCount} msg'),
        ),
      if (record != null)
        WarmClinicalReminderItem(
          title: 'Documento clinico',
          subtitle: '${record.badge} • ${record.createdAt}',
          icon: Icons.description_outlined,
          iconColor: const Color(0xFF6F91A3),
          trailing: const _ReminderTrailingText('File'),
        ),
    ];
  }

  static List<WarmClinicalDocumentItem> _buildDocuments(
    List<MedicalRecordEntry> records,
  ) {
    return records
        .take(3)
        .map(
          (record) => WarmClinicalDocumentItem(
            title: record.title,
            subtitle: '${record.subtitle} • ${record.badge}',
            icon: _documentIconForBadge(record.badge),
            trailing: _ReminderTrailingText(record.detailSource),
          ),
        )
        .toList(growable: false);
  }

  static List<WarmClinicalActivityItem> _buildActivity(
    List<MedicalRecordEntry> records,
    List<ChatConversationSummary> conversations,
  ) {
    final items = <WarmClinicalActivityItem>[];

    for (final record in records.take(2)) {
      items.add(
        WarmClinicalActivityItem(
          date: _compactDate(record.createdAt),
          title: record.title,
          subtitle: record.meta,
          accentColor: record.badge == 'Da rivedere'
              ? const Color(0xFFE5856F)
              : const Color(0xFF2E686A),
        ),
      );
    }

    for (final conversation in conversations.take(2)) {
      items.add(
        WarmClinicalActivityItem(
          date: conversation.updatedAtLabel,
          title: conversation.title,
          subtitle: conversation.previewMessage,
          accentColor: conversation.unreadCount > 0
              ? const Color(0xFF5F9F86)
              : const Color(0xFF6F91A3),
        ),
      );
    }

    return items.take(3).toList(growable: false);
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

  static IconData _documentIconForBadge(String badge) {
    switch (badge) {
      case 'Da rivedere':
        return Icons.monitor_heart_outlined;
      case 'Archivio':
        return Icons.folder_open_outlined;
      default:
        return Icons.description_outlined;
    }
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

  static String _compactDate(String value) {
    final parts = value.split(',');
    return parts.first.trim();
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
