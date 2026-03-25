import '../domain/chat_models.dart';

class ChatSeedData {
  static const conversations = <ChatConversationSummary>[
    ChatConversationSummary(
      id: 'conv-1',
      title: 'Cocco - dieta e digestione',
      subtitle: 'Sintomi lievi, controllo routine e piano alimentare.',
      updatedAtLabel: '2m fa',
      unreadCount: 2,
      activePetName: 'Cocco',
      previewMessage:
          'Puoi dirmi se questa variazione di appetito merita una visita?',
      lastSender: 'Assistente',
    ),
    ChatConversationSummary(
      id: 'conv-2',
      title: 'Luna - promemoria vaccino',
      subtitle: 'Richiamo programmato e nota su antiparassitario.',
      updatedAtLabel: 'ieri',
      unreadCount: 0,
      activePetName: 'Luna',
      previewMessage:
          'Ho aggiunto anche un promemoria per il controllo annuale.',
      lastSender: 'Tu',
    ),
    ChatConversationSummary(
      id: 'conv-3',
      title: 'Milo - referto visita',
      subtitle: 'Trascrizione referto e prossimi passi.',
      updatedAtLabel: '3 gg fa',
      unreadCount: 1,
      activePetName: 'Milo',
      previewMessage: 'Se vuoi, posso riassumere il referto in punti chiave.',
      lastSender: 'Assistente',
    ),
  ];

  static const emptyConversations = <ChatConversationSummary>[];

  static const detail = ChatConversationDetail(
    id: 'conv-1',
    title: 'Cocco - dieta e digestione',
    petName: 'Cocco',
    statusLabel: 'Contesto pet attivo',
    messages: [
      ChatMessage(
        id: 'msg-1',
        author: ChatMessageAuthor.assistant,
        text:
            'Raccontami pure cosa stai osservando: appetito, energia, acqua e feci sono i segnali piu utili per capire il quadro.',
        timeLabel: '09:12',
      ),
      ChatMessage(
        id: 'msg-2',
        author: ChatMessageAuthor.user,
        text:
            'Da ieri mangia meno del solito ma resta vivace. Devo preoccuparmi subito?',
        timeLabel: '09:13',
      ),
      ChatMessage(
        id: 'msg-3',
        author: ChatMessageAuthor.assistant,
        text:
            'Se non ci sono vomito, abbattimento o dolore evidente, di solito conviene monitorare 24 ore e tenere nota dei sintomi. Se peggiora, contatta il veterinario.',
        timeLabel: '09:14',
      ),
    ],
  );

  static ChatConversationDetail detailForSummary(
    ChatConversationSummary conversation,
  ) {
    return switch (conversation.id) {
      'conv-2' => const ChatConversationDetail(
          id: 'conv-2',
          title: 'Luna - promemoria vaccino',
          petName: 'Luna',
          statusLabel: 'Promemoria attivo',
          messages: [
            ChatMessage(
              id: 'msg-1',
              author: ChatMessageAuthor.assistant,
              text:
                  'Ho impostato il richiamo e aggiunto una nota sull antiparassitario. Se vuoi, possiamo anche allineare la prossima visita.',
              timeLabel: '08:41',
            ),
            ChatMessage(
              id: 'msg-2',
              author: ChatMessageAuthor.user,
              text: 'Perfetto, mi avvisi anche quando manca una settimana?',
              timeLabel: '08:43',
            ),
          ],
        ),
      'conv-3' => const ChatConversationDetail(
          id: 'conv-3',
          title: 'Milo - referto visita',
          petName: 'Milo',
          statusLabel: 'Referto caricato',
          messages: [
            ChatMessage(
              id: 'msg-1',
              author: ChatMessageAuthor.assistant,
              text:
                  'Posso sintetizzare il referto in tre punti: diagnosi, terapia e prossimi controlli. Se vuoi, preparo anche una versione breve per l owner.',
              timeLabel: '17:05',
            ),
            ChatMessage(
              id: 'msg-2',
              author: ChatMessageAuthor.user,
              text: 'Sì, dammi la versione breve.',
              timeLabel: '17:06',
            ),
          ],
        ),
      _ => detail,
    };
  }
}
