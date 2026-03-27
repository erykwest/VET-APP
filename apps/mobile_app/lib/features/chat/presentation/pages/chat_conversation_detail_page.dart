import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../data/chat_ask_vet_share_store.dart';
import '../../data/chat_demo_store.dart';
import '../../data/chat_seed_data.dart';
import '../../domain/chat_models.dart';
import '../widgets/chat_composer.dart';
import '../widgets/chat_empty_state.dart';
import '../widgets/chat_error_state.dart';
import '../widgets/chat_loading_state.dart';
import '../widgets/chat_message_bubble.dart';

class ChatConversationDetailPage extends StatefulWidget {
  const ChatConversationDetailPage({
    super.key,
    required this.conversationId,
    this.initialConversation,
    this.state = ChatScreenState.success,
    this.onRetry,
  });

  final String conversationId;
  final ChatConversationDetail? initialConversation;
  final ChatScreenState state;
  final VoidCallback? onRetry;

  @override
  State<ChatConversationDetailPage> createState() =>
      _ChatConversationDetailPageState();
}

class _ChatConversationDetailPageState
    extends State<ChatConversationDetailPage> {
  final ChatDemoStore _store = ChatDemoStore.instance;
  final ScrollController _scrollController = ScrollController();

  bool _isSending = false;
  bool _isLeavingAfterDelete = false;
  int _lastRenderedMessageCount = 0;

  @override
  void initState() {
    super.initState();
    _store.openConversation(widget.conversationId);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _store,
          builder: (context, _) {
            final conversation = _store.conversationById(widget.conversationId);

            if (conversation == null) {
              if (!_isLeavingAfterDelete) {
                _scheduleReturnToList();
              }

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xxl,
                      AppSpacing.lg,
                      AppSpacing.xxl,
                      AppSpacing.md,
                    ),
                    child: _Header(
                      conversation:
                          widget.initialConversation ?? ChatSeedData.detail,
                      onDeleteConversation: () => _deleteConversation(
                        context,
                        widget.initialConversation ?? ChatSeedData.detail,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ChatEmptyState(
                      title: 'Conversazione eliminata',
                      subtitle:
                          'Questo thread non fa piu parte del preview store. Torna alle chat o crea una nuova conversazione.',
                      actionLabel: 'Torna alle chat',
                      onAction: () => Navigator.of(context).maybePop(),
                    ),
                  ),
                ],
              );
            }

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xxl,
                    AppSpacing.lg,
                    AppSpacing.xxl,
                    AppSpacing.md,
                  ),
                  child: _Header(
                    conversation: conversation,
                    onDeleteConversation: () =>
                        _deleteConversation(context, conversation),
                  ),
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: switch (widget.state) {
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
                          onAction: () => _sendMessage(
                            'Ciao, ho una domanda per ${conversation.petName}.',
                          ),
                        ),
                      ChatScreenState.error => ChatErrorState(
                          key: const ValueKey('error'),
                          title: 'Conversazione non disponibile',
                          subtitle:
                              'Qualcosa e andato storto nel recupero del thread.',
                          actionLabel: 'Torna alle chat',
                          onAction: widget.onRetry ??
                              () => Navigator.of(context).maybePop(),
                        ),
                      ChatScreenState.success => _SuccessConversationView(
                          key: const ValueKey('success'),
                          conversation: conversation,
                          isSending: _isSending,
                          onSendMessage: _sendMessage,
                          scrollController: _scrollController,
                          onAskVet: (message) =>
                              _openAskVetShareOptions(conversation, message),
                        ),
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _sendMessage(String message) async {
    if (_isSending) return;

    final cleanMessage = message.trim();
    if (cleanMessage.isEmpty) return;

    setState(() {
      _isSending = true;
    });

    try {
      await _store.sendMessage(widget.conversationId, cleanMessage);
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) {
        return;
      }
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  void _scheduleScrollIfNeeded(int messageCount) {
    if (_lastRenderedMessageCount == messageCount) {
      return;
    }

    _lastRenderedMessageCount = messageCount;
    _scrollToBottom();
  }

  void _scheduleReturnToList() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _isLeavingAfterDelete) {
        return;
      }

      Navigator.of(context).maybePop();
    });
  }

  Future<void> _deleteConversation(
    BuildContext context,
    ChatConversationDetail conversation,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Eliminare la chat?'),
          content: Text(
            'Rimuoviamo "${conversation.title}" dal preview store. '
            'Potrai ripristinarla subito con Annulla.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Annulla'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Elimina'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    setState(() {
      _isLeavingAfterDelete = true;
    });

    final removed = _store.deleteConversation(conversation.id);
    if (removed == null) {
      if (mounted) {
        setState(() {
          _isLeavingAfterDelete = false;
        });
      }
      return;
    }

    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(
        content: Text('${removed.conversation.title} eliminata'),
        action: SnackBarAction(
          label: 'Annulla',
          onPressed: () {
            ChatDemoStore.instance.restoreConversation(
              removed.conversation,
              index: removed.index,
            );
          },
        ),
      ),
    );

    if (mounted) {
      Navigator.of(context).maybePop();
    }
  }

  Future<void> _openAskVetShareOptions(
    ChatConversationDetail conversation,
    ChatMessage message,
  ) async {
    final question = ChatAskVetShareStore.instance.buildQuestionText(
      conversation: conversation,
      message: message,
    );

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ask the vet',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Trasformo la risposta in una domanda pronta da inoltrare per ${conversation.petName}.',
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.45,
                  color: AppColors.secondaryText,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.accentSoft,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  question,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: AppColors.text,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  FilledButton.icon(
                    onPressed: () async {
                      await _shareAskVetToWhatsApp(conversation.id, question);
                      if (sheetContext.mounted) {
                        Navigator.of(sheetContext).pop();
                      }
                    },
                    icon: const Icon(Icons.chat_bubble_outline_rounded),
                    label: const Text('WhatsApp'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () async {
                      await _shareAskVetByEmail(
                        conversation.id,
                        conversation.petName,
                        question,
                      );
                      if (sheetContext.mounted) {
                        Navigator.of(sheetContext).pop();
                      }
                    },
                    icon: const Icon(Icons.mail_outline_rounded),
                    label: const Text('Email'),
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      await _copyAskVet(conversation.id, question);
                      if (sheetContext.mounted) {
                        Navigator.of(sheetContext).pop();
                      }
                    },
                    icon: const Icon(Icons.copy_all_rounded),
                    label: const Text('Copia'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                'Metriche hook: ask_vet_share_clicked e ask_vet_share_copied.',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.secondaryText,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _shareAskVetToWhatsApp(
      String conversationId, String text) async {
    try {
      await ChatAskVetShareStore.instance.recordShareClicked(conversationId);
      final launched = await launchUrl(
        Uri.parse('https://wa.me/?text=${Uri.encodeComponent(text)}'),
      );
      if (!mounted) {
        return;
      }
      if (!launched) {
        await Clipboard.setData(ClipboardData(text: text));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('WhatsApp non disponibile. Domanda copiata.'),
          ),
        );
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('WhatsApp aperto con la domanda pronta per il veterinario.'),
        ),
      );
    } catch (_) {
      await Clipboard.setData(ClipboardData(text: text));
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Condivisione non riuscita. Domanda copiata.'),
        ),
      );
    }
  }

  Future<void> _shareAskVetByEmail(
    String conversationId,
    String petName,
    String text,
  ) async {
    try {
      await ChatAskVetShareStore.instance.recordShareClicked(conversationId);
      final launched = await launchUrl(
        Uri.parse(
          'mailto:?subject=${Uri.encodeComponent('Domanda vet su $petName')}&body=${Uri.encodeComponent(text)}',
        ),
      );
      if (!mounted) {
        return;
      }
      if (!launched) {
        await Clipboard.setData(ClipboardData(text: text));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email non disponibile. Domanda copiata.'),
          ),
        );
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Email aperta con la domanda pronta per il veterinario.'),
        ),
      );
    } catch (_) {
      await Clipboard.setData(ClipboardData(text: text));
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invio email non riuscito. Domanda copiata.'),
        ),
      );
    }
  }

  Future<void> _copyAskVet(String conversationId, String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    await ChatAskVetShareStore.instance.recordShareCopied(conversationId);
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Domanda per il veterinario copiata.'),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.conversation,
    required this.onDeleteConversation,
  });

  final ChatConversationDetail conversation;
  final VoidCallback onDeleteConversation;

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
            child: const Icon(
              Icons.chat_bubble_outline,
              color: AppColors.onPrimary,
            ),
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
          PopupMenuButton<String>(
            tooltip: 'Azioni chat',
            icon: const Icon(Icons.more_horiz, color: AppColors.secondaryText),
            onSelected: (value) {
              if (value == 'delete') {
                onDeleteConversation();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(
                      Icons.delete_outline,
                      size: 18,
                      color: AppColors.danger,
                    ),
                    SizedBox(width: 12),
                    Text('Elimina chat'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SuccessConversationView extends StatelessWidget {
  const _SuccessConversationView({
    super.key,
    required this.conversation,
    required this.isSending,
    required this.onSendMessage,
    required this.scrollController,
    required this.onAskVet,
  });

  final ChatConversationDetail conversation;
  final bool isSending;
  final ValueChanged<String> onSendMessage;
  final ScrollController scrollController;
  final ValueChanged<ChatMessage> onAskVet;

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final totalItems = conversation.messages.length + (isSending ? 1 : 0);
        final state =
            context.findAncestorStateOfType<_ChatConversationDetailPageState>();
        state?._scheduleScrollIfNeeded(totalItems);

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
              child: _ContextBanner(conversation: conversation),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: ListView.separated(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xxl,
                  0,
                  AppSpacing.xxl,
                  AppSpacing.md,
                ),
                itemBuilder: (context, index) {
                  if (index < conversation.messages.length) {
                    final message = conversation.messages[index];
                    return ChatMessageBubble(
                      message: message,
                      onAskVet: message.author == ChatMessageAuthor.assistant
                          ? () => onAskVet(message)
                          : null,
                    );
                  }

                  return const _TypingBubble();
                },
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSpacing.sm),
                itemCount: totalItems,
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
      },
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

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: AppSpacing.sm),
            Text(
              'Sta scrivendo una risposta...',
              style: TextStyle(
                color: AppColors.secondaryText,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
