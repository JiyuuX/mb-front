import 'user.dart';

class Message {
  final int id;
  final int conversationId;
  final User sender;
  final String? text;
  final String? mediaUrl;
  final bool isRead;
  final String status; // 'sending', 'sent', 'delivered', 'read', 'failed'
  final DateTime createdAt;
  final DateTime updatedAt;

  Message({
    required this.id,
    required this.conversationId,
    required this.sender,
    this.text,
    this.mediaUrl,
    required this.isRead,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      conversationId: json['conversation'],
      sender: User.fromJson(json['sender']),
      text: json['text'],
      mediaUrl: json['media'],
      isRead: json['is_read'],
      status: json['status'] ?? 'sent',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}

class Conversation {
  final int id;
  final List<User> participants;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Message? lastMessage;
  final int? unreadCount;

  Conversation({
    required this.id,
    required this.participants,
    required this.createdAt,
    required this.updatedAt,
    this.lastMessage,
    this.unreadCount,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'],
      participants: (json['participants'] as List)
          .map((u) => User.fromJson(u))
          .toList(),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      lastMessage: json['last_message'] != null
          ? Message.fromJson(json['last_message'])
          : null,
      unreadCount: json['unread_count'],
    );
  }
} 