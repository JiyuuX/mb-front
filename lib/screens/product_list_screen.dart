import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import '../utils/responsive_utils.dart';
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
                      padding: ResponsiveUtils.getResponsiveEdgeInsets(context, baseValue: 16),
                      itemCount: _products.length,
                      itemBuilder: (context, index) {
                        final product = _products[index];
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
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => ProductDetailScreen(product: product),
                                  ),
                                );
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
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  product.title,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 16),
                                                    color: Theme.of(context).colorScheme.primary,
                                                  ),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              IconButton(
                                                onPressed: () => _toggleFavorite(product),
                                                icon: Icon(
                                                  product.isFavorited ? Icons.favorite : Icons.favorite_border,
                                                  color: product.isFavorited ? Colors.red : Theme.of(context).colorScheme.primary.withOpacity(0.7),
                                                  size: ResponsiveUtils.getResponsiveIconSize(context, baseSize: 20),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: ResponsiveUtils.getResponsivePadding(context, basePadding: 6)),
                                          Text(
                                            product.description,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                                              fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 14)
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
                                                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 12)
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
                                                        fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 12)
                                                      ),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              if (product.favoriteCount > 0)
                                                Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons.favorite, 
                                                      size: ResponsiveUtils.getResponsiveIconSize(context, baseSize: 12), 
                                                      color: Colors.red.withOpacity(0.7)
                                                    ),
                                                    SizedBox(width: ResponsiveUtils.getResponsivePadding(context, basePadding: 2)),
                                                    Text(
                                                      '${product.favoriteCount}',
                                                      style: TextStyle(
                                                        color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                                                        fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 10)
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