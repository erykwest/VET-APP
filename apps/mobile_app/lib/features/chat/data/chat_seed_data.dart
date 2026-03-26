import '../domain/chat_models.dart';

class ChatSeedData {
  static const conversations = <ChatConversationSummary>[
    ChatConversationSummary(
      id: 'conv-1',
      title: 'Moka - appetito e controllo',
      subtitle: 'Piccolo calo dell appetito, monitoraggio e piano d azione.',
      updatedAtLabel: '2 min fa',
      unreadCount: 2,
      activePetName: 'Moka',
      previewMessage:
          'Se resta vivace possiamo osservare fino a domani, ma tieni nota di appetito e acqua.',
      lastSender: 'Assistente',
    ),
    ChatConversationSummary(
      id: 'conv-2',
      title: 'Moka - promemoria vaccino',
      subtitle: 'Richiamo annuale con nota sul richiamo antiparassitario.',
      updatedAtLabel: 'ieri',
      unreadCount: 0,
      activePetName: 'Moka',
      previewMessage:
          'Ho già messo il richiamo e il promemoria di follow-up per la prossima settimana.',
      lastSender: 'Tu',
    ),
    ChatConversationSummary(
      id: 'conv-3',
      title: 'Moka - referto visita',
      subtitle: 'Sintesi del controllo, terapia leggera e prossima azione.',
      updatedAtLabel: '3 gg fa',
      unreadCount: 1,
      activePetName: 'Moka',
      previewMessage:
          'Posso riassumere il referto in tre punti: quadro, terapia e prossimo controllo.',
      lastSender: 'Assistente',
    ),
  ];

  static const emptyConversations = <ChatConversationSummary>[];

  static const detail = ChatConversationDetail(
    id: 'conv-1',
    title: 'Moka - appetito e controllo',
    petName: 'Moka',
    statusLabel: 'Contesto attivo del pet',
    messages: [
      ChatMessage(
        id: 'msg-1',
        author: ChatMessageAuthor.assistant,
        text:
            'Raccontami pure cosa stai osservando: appetito, energia, acqua e feci ci aiutano a capire subito se serve una visita o basta monitorare.',
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
            'Se non ci sono vomito, abbattimento o dolore evidente, in genere conviene monitorare 24 ore e tenere nota di appetito, acqua e feci. Se qualcosa peggiora, contatta il veterinario.',
        timeLabel: '09:14',
      ),
      ChatMessage(
        id: 'msg-4',
        author: ChatMessageAuthor.assistant,
        text:
            'Per sicurezza ti lascio anche un mini piano: pasti piccoli, acqua sempre disponibile e controllo della temperatura se ti sembra piu fiacco del solito.',
        timeLabel: '09:15',
      ),
    ],
  );

  static ChatConversationDetail detailForSummary(
    ChatConversationSummary conversation,
  ) {
    return switch (conversation.id) {
      'conv-2' => const ChatConversationDetail(
          id: 'conv-2',
          title: 'Moka - promemoria vaccino',
          petName: 'Moka',
          statusLabel: 'Promemoria attivo',
          messages: [
            ChatMessage(
              id: 'msg-1',
              author: ChatMessageAuthor.assistant,
              text:
                  'Ho impostato il richiamo e aggiunto una nota sull antiparassitario. Se vuoi, possiamo allineare anche la prossima visita di controllo.',
              timeLabel: '08:41',
            ),
            ChatMessage(
              id: 'msg-2',
              author: ChatMessageAuthor.user,
              text: 'Perfetto, mi avvisi anche quando manca una settimana?',
              timeLabel: '08:43',
            ),
            ChatMessage(
              id: 'msg-3',
              author: ChatMessageAuthor.assistant,
              text:
                  'Certo. Ti preparo anche una nota visiva con la scadenza piu vicina, cosi la trovi subito nella home.',
              timeLabel: '08:44',
            ),
          ],
        ),
      'conv-3' => const ChatConversationDetail(
          id: 'conv-3',
          title: 'Moka - referto visita',
          petName: 'Moka',
          statusLabel: 'Referto caricato',
          messages: [
            ChatMessage(
              id: 'msg-1',
              author: ChatMessageAuthor.assistant,
              text:
                  'Posso sintetizzare il referto in tre punti: quadro clinico, terapia e prossimi controlli. Se vuoi, preparo anche una versione breve da condividere.',
              timeLabel: '17:05',
            ),
            ChatMessage(
              id: 'msg-2',
              author: ChatMessageAuthor.user,
              text: 'Sì, dammi la versione breve.',
              timeLabel: '17:06',
            ),
            ChatMessage(
              id: 'msg-3',
              author: ChatMessageAuthor.assistant,
              text:
                  'In breve: quadro stabile, terapia leggera per pochi giorni e controllo di follow-up gia programmato.',
              timeLabel: '17:07',
            ),
          ],
        ),
      _ => detail,
    };
  }
}

