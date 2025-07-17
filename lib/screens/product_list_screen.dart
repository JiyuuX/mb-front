import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import 'product_detail_screen.dart';
import 'product_form_screen.dart';
import '../models/user.dart';

class ProductListScreen extends StatefulWidget {
  final String? category;
  final String? subcategory;
  final User? user;
  const ProductListScreen({super.key, this.category, this.subcategory, this.user});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List<Product> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final products = await ProductService.fetchProducts();
      setState(() {
        _products = products.where((p) {
          final catMatch = widget.category == null || p.category?.toString() == widget.category;
          final subcatMatch = widget.subcategory == null || p.subcategory?.toString() == widget.subcategory;
          return catMatch && subcatMatch;
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ürünler yüklenirken hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _toggleFavorite(Product product) async {
    try {
      final result = await ProductService.toggleFavorite(product.id);
      // Ürün listesini güncelle
      await _loadProducts();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: result['is_favorited'] ? Colors.green : Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Favori işlemi başarısız: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String title = '2. El Eşyalar';
    if (widget.subcategory != null) {
      if (_products.isNotEmpty && _products.first.subcategoryDetail != null) {
        title = _products.first.subcategoryDetail!['name'] ?? '2. El Eşyalar';
      }
    } else if (widget.category != null) {
      if (_products.isNotEmpty && _products.first.categoryDetail != null) {
        title = _products.first.categoryDetail!['name'] ?? '2. El Eşyalar';
      }
    }
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(title, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.primary),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadProducts,
              child: _products.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shopping_bag, size: 64, color: Theme.of(context).colorScheme.primary.withOpacity(0.2)),
                          const SizedBox(height: 16),
                          Text('Henüz ürün bulunmuyor', style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: _products.length,
                      itemBuilder: (context, index) {
                        final product = _products[index];
                        return Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: Theme.of(context).colorScheme.outline, width: 1),
                          ),
                          margin: const EdgeInsets.only(bottom: 18),
                          color: Theme.of(context).colorScheme.surface,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ProductDetailScreen(product: product),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(18),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: product.imageUrl != null
                                        ? Image.network(
                                            product.imageUrl!,
                                            width: 80,
                                            height: 80,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported, size: 40),
                                          )
                                        : Container(
                                            width: 80,
                                            height: 80,
                                            color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                                            child: Icon(Icons.image, size: 40, color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
                                          ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                product.title,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                  color: Theme.of(context).colorScheme.primary,
                                                ),
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () => _toggleFavorite(product),
                                              icon: Icon(
                                                product.isFavorited ? Icons.favorite : Icons.favorite_border,
                                                color: product.isFavorited ? Colors.red : Theme.of(context).colorScheme.primary.withOpacity(0.7),
                                                size: 24,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          product.description,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                '${product.price} TL',
                                                style: TextStyle(
                                                  color: Theme.of(context).colorScheme.primary,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Icon(Icons.category, size: 18, color: Theme.of(context).colorScheme.primary.withOpacity(0.7)),
                                            const SizedBox(width: 4),
                                            Text(
                                              product.categoryDetail?['name'] ?? '',
                                              style: TextStyle(
                                                color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                                                fontSize: 14,
                                              ),
                                            ),
                                            const Spacer(),
                                            if (product.favoriteCount > 0)
                                              Row(
                                                children: [
                                                  Icon(Icons.favorite, size: 16, color: Colors.red.withOpacity(0.7)),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    '${product.favoriteCount}',
                                                    style: TextStyle(
                                                      color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
      floatingActionButton: (widget.user?.isSecondhandSeller ?? false)
          ? FloatingActionButton(
              onPressed: () async {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ProductFormScreen(category: widget.category),
                  ),
                );
                if (result == true) {
                  _loadProducts();
                }
              },
              backgroundColor: isDark ? Colors.white : Theme.of(context).colorScheme.primary,
              child: Icon(Icons.add, color: isDark ? Colors.black : Colors.white),
              elevation: 2,
            )
          : null,
    );
  }
} 