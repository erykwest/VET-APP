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
    this.petId,
  });

  final String id;
  final String title;
  final String subtitle;
  final String updatedAtLabel;
  final int unreadCount;
  final String activePetName;
  final String previewMessage;
  final String lastSender;
  final String? petId;
}

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.author,
    required this.text,
    required this.timeLabel,
    this.createdAt,
    this.isRead = true,
  });

  final String id;
  final ChatMessageAuthor author;
  final String text;
  final String timeLabel;
  final DateTime? createdAt;
  final bool isRead;
}

class ChatConversationDetail {
  const ChatConversationDetail({
    required this.id,
    required this.title,
    required this.petName,
    required this.statusLabel,
    required this.messages,
    this.petId,
  });

  final String id;
  final String title;
  final String petName;
  final String statusLabel;
  final List<ChatMessage> messages;
  final String? petId;

  ChatConversationDetail copyWith({
    String? id,
    String? title,
    String? petName,
    String? statusLabel,
    List<ChatMessage>? messages,
    String? petId,
  }) {
    return ChatConversationDetail(
      id: id ?? this.id,
      title: title ?? this.title,
      petName: petName ?? this.petName,
      statusLabel: statusLabel ?? this.statusLabel,
      messages: messages ?? this.messages,
      petId: petId ?? this.petId,
    );
  }
}

class ChatConversationDeletion {
  const ChatConversationDeletion({
    required this.conversation,
    required this.index,
  });

  final ChatConversationDetail conversation;
  final int index;
}
