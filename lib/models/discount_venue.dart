class DiscountVenue {
  final int id;
  final String name;
  final String? image;
  final bool isActive;
  final DateTime createdAt;

  DiscountVenue({
    required this.id,
    required this.name,
    this.image,
    required this.isActive,
    required this.createdAt,
  });

  factory DiscountVenue.fromJson(Map<String, dynamic> json) {
    return DiscountVenue(
      id: json['id'],
      name: json['name'],
      image: json['image'],
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
} 