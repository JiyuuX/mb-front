class Accommodation {
  final int id;
  final String name;
  final String city;
  final String description;
  final double price;
  final bool isActive;
  final DateTime createdAt;

  Accommodation({
    required this.id,
    required this.name,
    required this.city,
    required this.description,
    required this.price,
    required this.isActive,
    required this.createdAt,
  });

  factory Accommodation.fromJson(Map<String, dynamic> json) {
    return Accommodation(
      id: json['id'],
      name: json['name'],
      city: json['city'],
      description: json['description'] ?? '',
      price: (json['price'] is int) ? (json['price'] as int).toDouble() : (json['price'] as num).toDouble(),
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
} 