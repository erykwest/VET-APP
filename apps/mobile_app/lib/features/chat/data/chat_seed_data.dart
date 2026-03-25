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
      previewMessage:
          'Se vuoi, posso riassumere il referto in punti chiave.',
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
}
