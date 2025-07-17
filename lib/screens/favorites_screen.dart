import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import 'product_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Product> _favorites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() { _isLoading = true; });
    try {
      final favorites = await ProductService.fetchMyFavorites();
      setState(() {
        _favorites = favorites;
        _isLoading = false;
      });
    } catch (e) {
      setState(() { _isLoading = false; });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Favoriler yüklenirken hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _removeFromFavorites(int productId) async {
    try {
      await ProductService.toggleFavorite(productId);
      await _loadFavorites();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Favorilerden çıkarıldı'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Favorilerim'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.primary),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadFavorites,
              child: _favorites.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.favorite_border, size: 64, color: Theme.of(context).colorScheme.primary.withOpacity(0.2)),
                          const SizedBox(height: 16),
                          Text(
                            'Henüz favori ürününüz yok',
                            style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.onSurfaceVariant),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Beğendiğiniz ürünleri favorilere ekleyebilirsiniz',
                            style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: _favorites.length,
                      itemBuilder: (context, index) {
                        final product = _favorites[index];
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
                            onTap: () async {
                              final result = await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ProductDetailScreen(product: product),
                                ),
                              );
                              if (result == true) _loadFavorites();
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
                                        Text(
                                          product.title,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            color: Theme.of(context).colorScheme.primary,
                                          ),
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
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            ElevatedButton.icon(
                                              onPressed: () => _removeFromFavorites(product.id),
                                              icon: const Icon(Icons.favorite, color: Colors.red),
                                              label: const Text('Favorilerden Çıkar'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red.withOpacity(0.1),
                                                foregroundColor: Colors.red,
                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                textStyle: const TextStyle(fontSize: 14),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                elevation: 0,
                                              ),
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
    );
  }
} 