import 'user.dart';

class Post {
  final int id;
  final int threadId;
  final User author;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isEdited;
  final int commentCount;

  Post({
    required this.id,
    required this.threadId,
    required this.author,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    required this.isEdited,
    required this.commentCount,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      threadId: json['thread'],
      author: User.fromJson(json['author'] ?? {}),
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      isEdited: json['is_edited'] ?? false,
      commentCount: json['comment_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'thread': threadId,
      'author': author.toJson(),
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_edited': isEdited,
      'comment_count': commentCount,
    };
  }
} 