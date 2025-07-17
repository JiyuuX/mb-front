import 'package:flutter/material.dart';
import '../models/product.dart';
import 'product_form_screen.dart'; // Added import for ProductFormScreen
import '../models/user.dart';
import '../services/api_service.dart';
import 'dart:convert';
import '../services/product_service.dart';
import 'public_profile_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _currentPage = 0;
  late final PageController _pageController;
  int? _currentUserId;
  Product? _product;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadProduct();
    _getCurrentUserId();
  }

  Future<void> _getCurrentUserId() async {
    try {
      final response = await ApiService.get('/users/profile/');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _currentUserId = data['id'];
        });
      }
    } catch (e) {
      print('Kullanıcı ID alınamadı: $e');
    }
  }

  Future<void> _loadProduct() async {
    try {
      final product = await ProductService.fetchProduct(widget.product.id);
      setState(() {
        _product = product;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ürün detayı yüklenirken hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _toggleFavorite() async {
    if (_product == null) return;
    
    try {
      final result = await ProductService.toggleFavorite(_product!.id);
      await _loadProduct(); // Ürün bilgilerini güncelle
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
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int index) {
    final int imageCount = (_product?.images.length ?? 0);
    if (index >= 0 && index < imageCount) {
      _pageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    final images = _product?.images ?? [];
    final isOwner = _currentUserId != null && _product?.seller['id'] == _currentUserId;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(_product?.title ?? '', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.primary),
        actions: [
          if (isOwner)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ProductFormScreen(product: _product!),
                  ),
                );
                if (result == true) {
                  await _loadProduct();
                }
              },
            ),
          IconButton(
            icon: Icon(
              _product?.isFavorited == true ? Icons.favorite : Icons.favorite_border,
              color: _product?.isFavorited == true ? Colors.red : null,
            ),
            onPressed: _toggleFavorite,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (images.isNotEmpty)
              Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 260,
                        height: 260,
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: images.length,
                          onPageChanged: (index) {
                            setState(() {
                              _currentPage = index;
                            });
                          },
                          itemBuilder: (context, idx) => ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              images[idx],
                              width: 260,
                              height: 260,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Icon(Icons.image_not_supported, size: 80, color: Theme.of(context).colorScheme.primary.withOpacity(0.2)),
                            ),
                          ),
                        ),
                      ),
                      if (images.length > 1 && _currentPage > 0)
                        Positioned(
                          left: 0,
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back_ios),
                            color: Theme.of(context).colorScheme.primary,
                            onPressed: () => _goToPage(_currentPage - 1),
                          ),
                        ),
                      if (images.length > 1 && _currentPage < images.length - 1)
                        Positioned(
                          right: 0,
                          child: IconButton(
                            icon: const Icon(Icons.arrow_forward_ios),
                            color: Theme.of(context).colorScheme.primary,
                            onPressed: () => _goToPage(_currentPage + 1),
                          ),
                        ),
                    ],
                  ),
                  // Dot indicator: always show, even if only one image
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(images.isNotEmpty ? images.length : 1, (idx) => Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentPage == idx
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.primary.withOpacity(0.2),
                        ),
                      )),
                    ),
                  ),
                ],
              )
            else
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 260,
                  height: 260,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                  child: Icon(Icons.image, size: 80, color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
                ),
              ),
            const SizedBox(height: 28),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Theme.of(context).colorScheme.outline, width: 1),
              ),
              color: Theme.of(context).colorScheme.surface,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(_product?.title ?? '', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('${_product?.price ?? ''} TL', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(Icons.category, size: 20, color: Theme.of(context).colorScheme.primary.withOpacity(0.7)),
                        const SizedBox(width: 8),
                        Text(_product?.categoryDetail?['name'] ?? '', style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.primary.withOpacity(0.7))),
                        const SizedBox(width: 18),
                        Icon(Icons.check_circle, size: 20, color: Theme.of(context).colorScheme.primary.withOpacity(0.7)),
                        const SizedBox(width: 8),
                        Text(_product?.status == 'new' ? 'Yeni' : '2. El', style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.primary.withOpacity(0.7))),
                        const Spacer(),
                        if (_product?.favoriteCount != null && _product!.favoriteCount > 0)
                          Row(
                            children: [
                              Icon(Icons.favorite, size: 20, color: Colors.red.withOpacity(0.7)),
                              const SizedBox(width: 4),
                              Text('${_product!.favoriteCount}', style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.primary.withOpacity(0.7))),
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(_product?.description ?? '', style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface)),
                    const SizedBox(height: 18),
                    Divider(color: Theme.of(context).colorScheme.outline.withOpacity(0.3)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        // Satıcı profil resmi
                        if (_product?.seller['profile_picture'] != null)
                          GestureDetector(
                            onTap: () {
                              if (_product?.seller['username'] != null) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => PublicProfileScreen(
                                      username: _product!.seller['username'],
                                    ),
                                  ),
                                );
                              }
                            },
                            child: CircleAvatar(
                              radius: 20,
                              backgroundImage: NetworkImage(_product!.seller['profile_picture']),
                            ),
                          )
                        else
                          GestureDetector(
                            onTap: () {
                              if (_product?.seller['username'] != null) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => PublicProfileScreen(
                                      username: _product!.seller['username'],
                                    ),
                                  ),
                                );
                              }
                            },
                            child: CircleAvatar(
                              radius: 20,
                              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                              child: Icon(
                                Icons.person,
                                size: 20,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        const SizedBox(width: 12),
                        // Satıcı bilgileri
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              if (_product?.seller['username'] != null) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => PublicProfileScreen(
                                      username: _product!.seller['username'],
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Satıcı',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                Text(
                                  _product?.seller['username'] ?? '-',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).colorScheme.primary,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 18, color: Theme.of(context).colorScheme.primary.withOpacity(0.7)),
                        const SizedBox(width: 8),
                        Text('Eklenme: ${_formatDate(_product?.createdAt ?? DateTime.now())}', style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }
} 