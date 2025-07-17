class Product {
  final int id;
  final String title;
  final String description;
  final double price;
  final Map<String, dynamic> seller;
  final List<dynamic> images;
  final int? category;
  final int? subcategory;
  final String status;
  final DateTime createdAt;
  final Map<String, dynamic>? categoryDetail;
  final Map<String, dynamic>? subcategoryDetail;
  final bool isFavorited;
  final int favoriteCount;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.seller,
    required this.images,
    this.category,
    this.subcategory,
    required this.status,
    required this.createdAt,
    this.categoryDetail,
    this.subcategoryDetail,
    this.isFavorited = false,
    this.favoriteCount = 0,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      price: (json['price'] is String)
          ? double.tryParse(json['price']) ?? 0.0
          : (json['price'] as num).toDouble(),
      seller: json['seller'] is Map<String, dynamic> ? json['seller'] : {},
      images: (json['images'] as List?)?.map((e) {
        if (e is String) return e;
        if (e is Map && e['image'] != null) return e['image'] as String;
        return '';
      }).toList() ?? [],
      category: json['category'] is int ? json['category'] : int.tryParse(json['category'].toString()),
      subcategory: json['subcategory'] is int ? json['subcategory'] : int.tryParse(json['subcategory']?.toString() ?? ''),
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      categoryDetail: json['category_detail'],
      subcategoryDetail: json['subcategory_detail'],
      isFavorited: json['is_favorited'] ?? false,
      favoriteCount: json['favorite_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'seller': seller,
      'images': images,
      'category': category,
      'subcategory': subcategory,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'category_detail': categoryDetail,
      'subcategory_detail': subcategoryDetail,
      'is_favorited': isFavorited,
      'favorite_count': favoriteCount,
    };
  }

  String? get image => images.isNotEmpty ? images[0] : null;

  String? get imageUrl {
    if (image == null || image!.isEmpty) return null;
    if (image!.startsWith('http')) return image;
    // Gerekirse domaini değiştir: Flutter web için backend adresini kullan
    return 'http://localhost:8000$image';
  }
} 