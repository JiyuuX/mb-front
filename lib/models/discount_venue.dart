class DiscountVenue {
  final int id;
  final String name;
  final String city;
  final String description;
  final bool isPremiumOnly;
  final bool isActive;
  final DateTime createdAt;

  DiscountVenue({
    required this.id,
    required this.name,
    required this.city,
    required this.description,
    required this.isPremiumOnly,
    required this.isActive,
    required this.createdAt,
  });

  factory DiscountVenue.fromJson(Map<String, dynamic> json) {
    return DiscountVenue(
      id: json['id'],
      name: json['name'],
      city: json['city'],
      description: json['description'] ?? '',
      isPremiumOnly: json['is_premium_only'] ?? true,
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
} 