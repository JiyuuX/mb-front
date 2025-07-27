import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import '../utils/responsive_utils.dart';
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
        title: Text('Favorilerim', style: TextStyle(
          fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 18)
        )),
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
                      padding: ResponsiveUtils.getResponsiveEdgeInsets(context, baseValue: 16),
                      itemCount: _favorites.length,
                      itemBuilder: (context, index) {
                        final product = _favorites[index];
                        return Container(
                          margin: ResponsiveUtils.getResponsiveEdgeInsets(context, baseValue: 0, bottom: 12),
                          child: Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: Theme.of(context).colorScheme.outline, width: 1),
                            ),
                            color: Theme.of(context).colorScheme.surface,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () async {
                                final result = await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => ProductDetailScreen(product: product),
                                  ),
                                );
                                if (result == true) _loadFavorites();
                              },
                              child: Padding(
                                padding: ResponsiveUtils.getResponsiveEdgeInsets(context, baseValue: 12),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: product.imageUrl != null
                                          ? Image.network(
                                              product.imageUrl!,
                                              width: ResponsiveUtils.getResponsiveImageSize(context, baseSize: 60),
                                              height: ResponsiveUtils.getResponsiveImageSize(context, baseSize: 60),
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) => Icon(
                                                Icons.image_not_supported, 
                                                size: ResponsiveUtils.getResponsiveIconSize(context, baseSize: 24)
                                              ),
                                            )
                                          : Container(
                                              width: ResponsiveUtils.getResponsiveImageSize(context, baseSize: 60),
                                              height: ResponsiveUtils.getResponsiveImageSize(context, baseSize: 60),
                                              color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                                              child: Icon(
                                                Icons.image, 
                                                size: ResponsiveUtils.getResponsiveIconSize(context, baseSize: 24), 
                                                color: Theme.of(context).colorScheme.primary.withOpacity(0.3)
                                              ),
                                            ),
                                    ),
                                    SizedBox(width: ResponsiveUtils.getResponsivePadding(context, basePadding: 12)),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            product.title,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 16),
                                              color: Theme.of(context).colorScheme.primary,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(height: ResponsiveUtils.getResponsivePadding(context, basePadding: 6)),
                                          Text(
                                            product.description,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                                              fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 14),
                                            ),
                                          ),
                                          SizedBox(height: ResponsiveUtils.getResponsivePadding(context, basePadding: 8)),
                                          Wrap(
                                            spacing: ResponsiveUtils.getResponsivePadding(context, basePadding: 8),
                                            runSpacing: ResponsiveUtils.getResponsivePadding(context, basePadding: 4),
                                            children: [
                                              Container(
                                                padding: ResponsiveUtils.getResponsiveEdgeInsets(context, baseValue: 6, horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  '${product.price} TL',
                                                  style: TextStyle(
                                                    color: Theme.of(context).colorScheme.primary,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 12),
                                                  ),
                                                ),
                                              ),
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.category, 
                                                    size: ResponsiveUtils.getResponsiveIconSize(context, baseSize: 14), 
                                                    color: Theme.of(context).colorScheme.primary.withOpacity(0.7)
                                                  ),
                                                  SizedBox(width: ResponsiveUtils.getResponsivePadding(context, basePadding: 2)),
                                                  Flexible(
                                                    child: Text(
                                                      product.categoryDetail?['name'] ?? '',
                                                      style: TextStyle(
                                                        color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                                                        fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 12),
                                                      ),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.location_on, 
                                                    size: ResponsiveUtils.getResponsiveIconSize(context, baseSize: 14), 
                                                    color: Theme.of(context).colorScheme.primary.withOpacity(0.7)
                                                  ),
                                                  SizedBox(width: ResponsiveUtils.getResponsivePadding(context, basePadding: 2)),
                                                  Flexible(
                                                    child: Text(
                                                      product.city ?? 'Bilinmeyen',
                                                      style: TextStyle(
                                                        color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                                                        fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 12),
                                                      ),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: ResponsiveUtils.getResponsivePadding(context, basePadding: 8)),
                                          SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton.icon(
                                              onPressed: () => _removeFromFavorites(product.id),
                                              icon: Icon(
                                                Icons.favorite, 
                                                color: Colors.red,
                                                size: ResponsiveUtils.getResponsiveIconSize(context, baseSize: 16)
                                              ),
                                              label: Text(
                                                'Favorilerden Çıkar',
                                                style: TextStyle(
                                                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 12)
                                                )
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red.withOpacity(0.1),
                                                foregroundColor: Colors.red,
                                                padding: ResponsiveUtils.getResponsiveEdgeInsets(context, baseValue: 8, horizontal: 12, vertical: 6),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                                elevation: 0,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
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