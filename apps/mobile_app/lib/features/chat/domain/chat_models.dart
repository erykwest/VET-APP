enum ChatScreenState {
  loading,
  empty,
  error,
  success,
}

enum ChatMessageAuthor {
  user,
  assistant,
}

class ChatConversationSummary {
  const ChatConversationSummary({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.updatedAtLabel,
    required this.unreadCount,
    required this.activePetName,
    required this.previewMessage,
    required this.lastSender,
  });

  final String id;
  final String title;
  final String subtitle;
  final String updatedAtLabel;
  final int unreadCount;
  final String activePetName;
  final String previewMessage;
  final String lastSender;
}

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.author,
    required this.text,
    required this.timeLabel,
    this.isRead = true,
  });

  final String id;
  final ChatMessageAuthor author;
  final String text;
  final String timeLabel;
  final bool isRead;
}

class ChatConversationDetail {
  const ChatConversationDetail({
    required this.id,
    required this.title,
    required this.petName,
    required this.statusLabel,
    required this.messages,
  });

  final String id;
  final String title;
  final String petName;
  final String statusLabel;
  final List<ChatMessage> messages;
}
