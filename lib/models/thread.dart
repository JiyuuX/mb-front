class Thread {
  final int id;
  final String title;
  final Map<String, dynamic> creator;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPinned;
  final bool isLocked;

  Thread({
    required this.id,
    required this.title,
    required this.creator,
    required this.createdAt,
    required this.updatedAt,
    required this.isPinned,
    required this.isLocked,
  });

  factory Thread.fromJson(Map<String, dynamic> json) {
    return Thread(
      id: json['id'],
      title: json['title'],
      creator: json['creator'] ?? {},
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      isPinned: json['is_pinned'] ?? false,
      isLocked: json['is_locked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'creator': creator,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_pinned': isPinned,
      'is_locked': isLocked,
    };
  }
} 