import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/product.dart';
import 'api_service.dart';

class ProductService {
  static Future<List<Product>> fetchProducts() async {
    final response = await ApiService.get('/market/products/');
    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      final List<dynamic> items = data is List ? data : (data['results'] ?? []);
      return items.map((item) => Product.fromJson(item)).toList();
    } else {
      throw Exception('Ürünler alınamadı');
    }
  }

  static Future<Product> fetchProduct(int id) async {
    final response = await ApiService.get('/market/products/ $id/');
    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      return Product.fromJson(data);
    } else {
      throw Exception('Ürün detayı alınamadı');
    }
  }

  static Future<Product> createProduct(Map<String, dynamic> data) async {
    final response = await ApiService.post('/market/products/', data);
    if (response.statusCode == 201) {
      final productData = json.decode(utf8.decode(response.bodyBytes));
      return Product.fromJson(productData);
    } else {
      throw Exception('Ürün eklenemedi');
    }
  }

  static Future<Product> updateProduct(int id, Map<String, dynamic> data) async {
    final response = await ApiService.put('/market/products/ $id/', data);
    if (response.statusCode == 200) {
      final productData = json.decode(utf8.decode(response.bodyBytes));
      return Product.fromJson(productData);
    } else {
      throw Exception('Ürün güncellenemedi');
    }
  }

  static Future<void> deleteProduct(int id) async {
    final response = await ApiService.delete('/market/products/ $id/');
    if (response.statusCode != 204) {
      throw Exception('Ürün silinemedi');
    }
  }

  static Future<void> uploadProductImages(int productId, List<XFile> images) async {
    for (final image in images) {
      var request = http.MultipartRequest('POST', Uri.parse('${ApiService.baseUrl}/market/products/$productId/upload_image/'));
      final token = await ApiService.getToken();
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        request.files.add(
          http.MultipartFile.fromBytes(
            'image',
            bytes,
            filename: image.name,
          ),
        );
      } else {
        request.files.add(await http.MultipartFile.fromPath('image', image.path));
      }
      await request.send();
    }
  }

  static Future<List<Product>> fetchMyProducts() async {
    final response = await ApiService.get('/market/products/my_products/');
    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      final List<dynamic> items = data is List ? data : (data['results'] ?? []);
      return items.map((item) => Product.fromJson(item)).toList();
    } else {
      throw Exception('Kendi ürünleriniz alınamadı');
    }
  }

  static Future<List<Product>> fetchMyFavorites() async {
    final response = await ApiService.get('/market/products/my_favorites/');
    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      final List<dynamic> items = data is List ? data : (data['results'] ?? []);
      return items.map((item) => Product.fromJson(item)).toList();
    } else {
      throw Exception('Favori ürünleriniz alınamadı');
    }
  }

  static Future<Map<String, dynamic>> toggleFavorite(int productId) async {
    final response = await ApiService.post('/market/products/$productId/toggle_favorite/', {});
    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      return data;
    } else {
      throw Exception('Favori işlemi başarısız');
    }
  }

  static Future<List<Map<String, dynamic>>> fetchCategories() async {
    final response = await ApiService.get('/market/categories/');
    if (response.statusCode == 200) {
      final List data = json.decode(utf8.decode(response.bodyBytes));
      return data.map<Map<String, dynamic>>((item) => {
        'id': item['id'],
        'name': item['name'],
        'subcategories': item['subcategories'],
      }).toList();
    } else {
      throw Exception('Kategori listesi alınamadı');
    }
  }
} 