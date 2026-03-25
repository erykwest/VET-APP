import 'package:flutter/material.dart';

import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../data/chat_seed_data.dart';
import '../../domain/chat_models.dart';
import '../widgets/chat_conversation_card.dart';
import '../widgets/chat_empty_state.dart';
import '../widgets/chat_error_state.dart';
import '../widgets/chat_loading_state.dart';
import 'chat_conversation_detail_page.dart';

class ChatConversationsPage extends StatelessWidget {
  const ChatConversationsPage({
    super.key,
    this.state = ChatScreenState.success,
    this.conversations = ChatSeedData.conversations,
    this.onRetry,
    this.onConversationTap,
  });

  final ChatScreenState state;
  final List<ChatConversationSummary> conversations;
  final VoidCallback? onRetry;
  final ValueChanged<ChatConversationSummary>? onConversationTap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF6FAF8),
              Color(0xFFEAF3EE),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xxl,
                  AppSpacing.lg,
                  AppSpacing.xxl,
                  AppSpacing.md,
                ),
                child: _Header(totalCount: conversations.length),
              ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: switch (state) {
                    ChatScreenState.loading => const ChatLoadingState(
                        key: ValueKey('loading'),
                        title: 'Carichiamo le conversazioni',
                        subtitle:
                            'Stiamo recuperando le ultime chat del tuo account.',
                      ),
                    ChatScreenState.empty => ChatEmptyState(
                        key: const ValueKey('empty'),
                        title: 'Nessuna conversazione ancora',
                        subtitle:
                            'Qui compariranno i thread con l assistente veterinario.',
                        actionLabel: 'Avvia la prima chat',
                        onAction: conversations.isEmpty
                            ? () => Navigator.of(context).maybePop()
                            : () =>
                                _openConversation(context, conversations.first),
                    ),
                    ChatScreenState.error => ChatErrorState(
                        key: const ValueKey('error'),
                        title: 'Non riusciamo a caricare le chat',
                        subtitle:
                            'Controlla la connessione e riprova tra un momento.',
                        actionLabel: 'Back',
                        onAction:
                            onRetry ?? () => Navigator.of(context).maybePop(),
                      ),
                    ChatScreenState.success => _ConversationList(
                        key: const ValueKey('success'),
                        conversations: conversations,
                        onConversationTap: onConversationTap ??
                            (conversation) =>
                                _openConversation(context, conversation),
                      ),
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openConversation(
    BuildContext context,
    ChatConversationSummary conversation,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChatConversationDetailPage(
          conversation: ChatSeedData.detailForSummary(conversation),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.totalCount,
  });

  final int totalCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14163A35),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'CHAT',
                  style: TextStyle(
                    color: AppColors.onPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '$totalCount thread${totalCount == 1 ? '' : 's'}',
                style: const TextStyle(
                  color: AppColors.mutedText,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          const Text(
            'Le tue conversazioni con l assistente veterinario',
            style: TextStyle(
              color: AppColors.text,
              fontSize: 20,
              height: 1.3,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Tieni tutto il contesto del pet attivo in un unico posto: domande, risposte e prossimi passi.',
            style: TextStyle(
              color: AppColors.secondaryText,
              fontSize: 14,
              height: 1.45,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _ConversationList extends StatelessWidget {
  const _ConversationList({
    super.key,
    required this.conversations,
    required this.onConversationTap,
  });

  final List<ChatConversationSummary> conversations;
  final ValueChanged<ChatConversationSummary>? onConversationTap;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        0,
        AppSpacing.xxl,
        AppSpacing.xxl,
      ),
      itemCount: conversations.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final conversation = conversations[index];
        return ChatConversationCard(
          conversation: conversation,
          onTap: onConversationTap == null
              ? null
              : () => onConversationTap!.call(conversation),
        );
      },
    );
  }
}
