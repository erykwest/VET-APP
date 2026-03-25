import 'package:flutter/material.dart';

import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../data/chat_seed_data.dart';
import '../../domain/chat_models.dart';
import '../widgets/chat_composer.dart';
import '../widgets/chat_empty_state.dart';
import '../widgets/chat_error_state.dart';
import '../widgets/chat_loading_state.dart';
import '../widgets/chat_message_bubble.dart';

class ChatConversationDetailPage extends StatelessWidget {
  const ChatConversationDetailPage({
    super.key,
    this.state = ChatScreenState.success,
    this.conversation = ChatSeedData.detail,
    this.onSendMessage,
    this.onRetry,
  });

  final ChatScreenState state;
  final ChatConversationDetail conversation;
  final ValueChanged<String>? onSendMessage;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xxl,
                AppSpacing.lg,
                AppSpacing.xxl,
                AppSpacing.md,
              ),
              child: _Header(conversation: conversation),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: switch (state) {
                  ChatScreenState.loading => const ChatLoadingState(
                      key: ValueKey('loading'),
                      title: 'Apriamo la conversazione',
                      subtitle:
                          'Stiamo caricando il thread e l ultimo contesto disponibile.',
                    ),
                  ChatScreenState.empty => ChatEmptyState(
                      key: const ValueKey('empty'),
                      title: 'La conversazione e vuota',
                      subtitle:
                          'Scrivi il primo messaggio per iniziare il dialogo con l assistente.',
                      actionLabel: 'Scrivi ora',
                      onAction: onSendMessage == null
                          ? null
                          : () => onSendMessage!
                              .call('Ciao, ho una domanda per Cocco.'),
                    ),
                  ChatScreenState.error => ChatErrorState(
                      key: const ValueKey('error'),
                      title: 'Conversazione non disponibile',
                      subtitle:
                          'Qualcosa e andato storto nel recupero del thread.',
                      actionLabel: 'Back to chats',
                      onAction:
                          onRetry ?? () => Navigator.of(context).maybePop(),
                    ),
                  ChatScreenState.success => _SuccessConversationView(
                      key: const ValueKey('success'),
                      conversation: conversation,
                      onSendMessage: onSendMessage,
                    ),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.conversation,
  });

  final ChatConversationDetail conversation;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.chat_bubble_outline,
                color: AppColors.onPrimary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  conversation.title,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 16,
                    height: 1.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${conversation.petName} - ${conversation.statusLabel}',
                  style: const TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 12,
                    height: 1.3,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.more_horiz, color: AppColors.secondaryText),
        ],
      ),
    );
  }
}

class _SuccessConversationView extends StatelessWidget {
  const _SuccessConversationView({
    super.key,
    required this.conversation,
    required this.onSendMessage,
  });

  final ChatConversationDetail conversation;
  final ValueChanged<String>? onSendMessage;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
          child: _ContextBanner(conversation: conversation),
        ),
        const SizedBox(height: AppSpacing.md),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xxl,
              0,
              AppSpacing.xxl,
              AppSpacing.md,
            ),
            itemBuilder: (context, index) {
              final message = conversation.messages[index];
              return ChatMessageBubble(message: message);
            },
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
            itemCount: conversation.messages.length,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xxl,
            0,
            AppSpacing.xxl,
            AppSpacing.xxl,
          ),
          child: ChatComposer(
            hintText: 'Scrivi una domanda su ${conversation.petName}',
            onSend: onSendMessage,
          ),
        ),
      ],
    );
  }
}

class _ContextBanner extends StatelessWidget {
  const _ContextBanner({
    required this.conversation,
  });

  final ChatConversationDetail conversation;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.accentSoft,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.pets, color: AppColors.onPrimary, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${conversation.petName} attivo',
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 16,
                    height: 1.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Il contesto del pet e gia pronto per questa chat.',
                  style: TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 12,
                    height: 1.3,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
