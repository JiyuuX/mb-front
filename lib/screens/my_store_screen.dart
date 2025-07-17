import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_service.dart';
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
        title: const Text('Mağazam'),
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
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.verified, size: 32, color: Colors.orange),
                        const SizedBox(height: 8),
                        Text(
                          'Satış yapmak için badge gerekli',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(height: 12),
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
                                  onTap: () async {
                                    final result = await Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => ProductDetailScreen(product: product),
                                      ),
                                    );
                                    if (result == true) _loadProducts();
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
                                              Text(product.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Theme.of(context).colorScheme.primary)),
                                              const SizedBox(height: 8),
                                              Text(product.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                                              const SizedBox(height: 12),
                                              Row(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Text('${product.price} TL', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Icon(Icons.category, size: 18, color: Theme.of(context).colorScheme.primary.withOpacity(0.7)),
                                                  const SizedBox(width: 4),
                                                  Text(product.categoryDetail?['name'] ?? '', style: TextStyle(color:
                                                  Theme.of(context).colorScheme.primary.withOpacity(0.7), fontSize: 14)),
                                                ],
                                              ),
                                              const SizedBox(height: 10),
                                              Row(
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
                                                    icon: const Icon(Icons.edit),
                                                    label: const Text('Düzenle'),
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: isDark ? Colors.white : Theme.of(context).colorScheme.primary,
                                                      foregroundColor: isDark ? Colors.black : Colors.white,
                                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                      textStyle: const TextStyle(fontSize: 14),
                                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
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
                                                    icon: const Icon(Icons.delete),
                                                    label: const Text('Sil'),
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: Colors.red,
                                                      foregroundColor: Colors.white,
                                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                      textStyle: const TextStyle(fontSize: 14),
                                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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