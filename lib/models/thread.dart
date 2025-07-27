import 'user.dart';

class Thread {
  final int id;
  final String title;
  final User creator;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPinned;
  final bool isLocked;
  final String category;
  int likesCount;
  final bool isLiked;
  final String forumType;
  final String? university;
  int? commentCount;

  Thread({
    required this.id,
    required this.title,
    required this.creator,
    required this.createdAt,
    required this.updatedAt,
    required this.isPinned,
    required this.isLocked,
    required this.category,
    required this.likesCount,
    required this.isLiked,
    required this.forumType,
    this.university,
    this.commentCount,
  });

  factory Thread.fromJson(Map<String, dynamic> json) {
    return Thread(
      id: json['id'],
      title: json['title'],
      creator: User.fromJson(json['creator'] ?? {}),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      isPinned: json['is_pinned'] ?? false,
      isLocked: json['is_locked'] ?? false,
      category: json['category'] ?? 'genel',
      likesCount: json['likes_count'] ?? 0,
      isLiked: json['is_liked'] ?? false,
      forumType: json['forum_type'] ?? 'genel',
      university: json['university'],
      commentCount: json['comment_count'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'creator': creator.toJson(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_pinned': isPinned,
      'is_locked': isLocked,
      'category': category,
      'likes_count': likesCount,
      'is_liked': isLiked,
      'forum_type': forumType,
      'university': university,
    };
  }
} 