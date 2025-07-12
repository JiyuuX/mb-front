class News {
  final int id;
  final String title;
  final String content;
  final bool isActive;
  final int priority;
  final DateTime createdAt;

  News({
    required this.id,
    required this.title,
    required this.content,
    required this.isActive,
    required this.priority,
    required this.createdAt,
  });

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      isActive: json['is_active'],
      priority: json['priority'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'is_active': isActive,
      'priority': priority,
      'created_at': createdAt.toIso8601String(),
    };
  }
} 