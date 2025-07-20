import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import '../utils/responsive_utils.dart';
import 'product_form_screen.dart';
import 'product_detail_screen.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import 'dart:convert';

class MyStoreScreen extends StatefulWidget {
  const MyStoreScreen({super.key});

  @override
  State<MyStoreScreen> createState() => _MyStoreScreenState();
}

class _MyStoreScreenState extends State<MyStoreScreen> {
  List<Product> _products = [];
  bool _isLoading = true;
  User? _user;
  bool _badgeLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadProducts();
  }

  Future<void> _loadUser() async {
    try {
      final response = await ApiService.get('/users/profile/');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _user = User.fromJson(data);
        });
      }
    } catch (e) {
      print('Kullanıcı yükleme hatası: $e');
    }
  }

  Future<void> _activateBadge() async {
    setState(() { _badgeLoading = true; });
    try {
      final response = await ApiService.post('/users/actions/activate_secondhand_seller/', {});
      if (response.statusCode == 200) {
        await _loadUser();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('2. el satıcı badge aktif edildi!'), backgroundColor: Colors.green),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Badge aktifleştirilemedi!'), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() { _badgeLoading = false; });
    }
  }

  Future<void> _loadProducts() async {
    setState(() { _isLoading = true; });
    try {
      final products = await ProductService.fetchMyProducts();
      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() { _isLoading = false; });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ürünler yüklenemedi: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _deleteProduct(int id) async {
    try {
      await ProductService.deleteProduct(id);
      _loadProducts();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ürün silindi.'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Silinemedi: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSeller = _user?.isSecondhandSeller ?? false;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Mağazam', style: TextStyle(
          fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 18)
        )),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Badge açma butonu (eğer seller değilse)
                if (!isSeller)
                  Container(
                    width: double.infinity,
                    margin: ResponsiveUtils.getResponsiveEdgeInsets(context, baseValue: 16),
                    padding: ResponsiveUtils.getResponsiveEdgeInsets(context, baseValue: 16),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.verified, size: ResponsiveUtils.getResponsiveIconSize(context, baseSize: 32), color: Colors.orange),
                        SizedBox(height: ResponsiveUtils.getResponsivePadding(context, basePadding: 8)),
                        Text(
                          'Satış yapmak için badge gerekli',
                          style: TextStyle(
                            fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 16),
                            fontWeight: FontWeight.w600,
                            color: Colors.orange,
                          ),
                        ),
                        SizedBox(height: ResponsiveUtils.getResponsivePadding(context, basePadding: 12)),
                        ElevatedButton.icon(
                          onPressed: _badgeLoading ? null : _activateBadge,
                          icon: _badgeLoading
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.verified),
                          label: Text(_badgeLoading ? 'Aktifleştiriliyor...' : 'Badge Aç'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                            textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            elevation: 0,
                          ),
                        ),
                      ],
                    ),
                  ),
                
                // Ürün listesi
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadProducts,
                    child: _products.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.store, size: 64, color: Theme.of(context).colorScheme.primary.withOpacity(0.2)),
                                const SizedBox(height: 16),
                                Text(
                                  isSeller ? 'Henüz ürününüz yok.' : 'Badge açtıktan sonra ürün ekleyebilirsiniz.',
                                  style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.onSurfaceVariant),
                                  textAlign: TextAlign.center,
                                ),
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
                                  onTap: () async {
                                    final result = await Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => ProductDetailScreen(product: product),
                                      ),
                                    );
                                    if (result == true) _loadProducts();
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
                                                    color: Theme.of(context).colorScheme.primary
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
                                                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 14)
                                                  )
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
                                                        )
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
                                                  ],
                                                ),
                                                SizedBox(height: ResponsiveUtils.getResponsivePadding(context, basePadding: 8)),
                                                Wrap(
                                                  spacing: ResponsiveUtils.getResponsivePadding(context, basePadding: 8),
                                                  runSpacing: ResponsiveUtils.getResponsivePadding(context, basePadding: 4),
                                                children: [
                                                  ElevatedButton.icon(
                                                    onPressed: () async {
                                                      final result = await Navigator.of(context).push(
                                                        MaterialPageRoute(
                                                          builder: (context) => ProductFormScreen(product: product),
                                                        ),
                                                      );
                                                      if (result == true) _loadProducts();
                                                    },
                                                      icon: Icon(
                                                        Icons.edit,
                                                        size: ResponsiveUtils.getResponsiveIconSize(context, baseSize: 16)
                                                      ),
                                                      label: Text(
                                                        'Düzenle',
                                                        style: TextStyle(
                                                          fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 12)
                                                        )
                                                      ),
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: isDark ? Colors.white : Theme.of(context).colorScheme.primary,
                                                      foregroundColor: isDark ? Colors.black : Colors.white,
                                                        padding: ResponsiveUtils.getResponsiveEdgeInsets(context, baseValue: 8, horizontal: 12, vertical: 6),
                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                                    ),
                                                  ),
                                                  ElevatedButton.icon(
                                                    onPressed: () async {
                                                      final confirm = await showDialog<bool>(
                                                        context: context,
                                                        builder: (context) => AlertDialog(
                                                          title: const Text('Ürünü Sil'),
                                                          content: const Text('Bu ürünü silmek istediğinize emin misiniz?'),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () => Navigator.of(context).pop(false),
                                                              child: const Text('İptal'),
                                                            ),
                                                            TextButton(
                                                              onPressed: () => Navigator.of(context).pop(true),
                                                              child: const Text('Sil'),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                      if (confirm == true) {
                                                        _deleteProduct(product.id);
                                                      }
                                                    },
                                                      icon: Icon(
                                                        Icons.delete,
                                                        size: ResponsiveUtils.getResponsiveIconSize(context, baseSize: 16)
                                                      ),
                                                      label: Text(
                                                        'Sil',
                                                        style: TextStyle(
                                                          fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 12)
                                                        )
                                                      ),
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: Colors.red,
                                                      foregroundColor: Colors.white,
                                                        padding: ResponsiveUtils.getResponsiveEdgeInsets(context, baseValue: 8, horizontal: 12, vertical: 6),
                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
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
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
      floatingActionButton: isSeller
          ? FloatingActionButton(
              onPressed: () async {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ProductFormScreen(),
                  ),
                );
                if (result == true) _loadProducts();
              },
              backgroundColor: isDark ? Colors.white : Theme.of(context).colorScheme.primary,
              child: Icon(Icons.add, color: isDark ? Colors.black : Colors.white),
              elevation: 2,
            )
          : null,
    );
  }
} 