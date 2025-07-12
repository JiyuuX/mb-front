class Announcement {
  final int id;
  final String title;
  final String content;
  final String announcementType;
  final String? image;
  final bool isActive;
  final bool isFeatured;
  final DateTime publishDate;
  final DateTime? expiryDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  Announcement({
    required this.id,
    required this.title,
    required this.content,
    required this.announcementType,
    this.image,
    required this.isActive,
    required this.isFeatured,
    required this.publishDate,
    this.expiryDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      announcementType: json['announcement_type'],
      image: json['image'],
      isActive: json['is_active'],
      isFeatured: json['is_featured'],
      publishDate: DateTime.parse(json['publish_date']),
      expiryDate: json['expiry_date'] != null 
          ? DateTime.parse(json['expiry_date']) 
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'announcement_type': announcementType,
      'image': image,
      'is_active': isActive,
      'is_featured': isFeatured,
      'publish_date': publishDate.toIso8601String(),
      'expiry_date': expiryDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
} 