import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import '../utils/responsive_utils.dart';
import 'product_detail_screen.dart';
import 'public_profile_screen.dart';
import '../widgets/colored_username.dart';

class AllProductsScreen extends StatefulWidget {
  const AllProductsScreen({super.key});

  @override
  State<AllProductsScreen> createState() => _AllProductsScreenState();
}

class _AllProductsScreenState extends State<AllProductsScreen> {
  List<Product> _products = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading && _hasMore) {
        _loadMoreProducts();
      }
    }
  }

  Future<void> _loadProducts({bool refresh = false}) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (refresh) {
        _currentPage = 1;
        _products.clear();
      }

      final result = await ProductService.fetchAllProducts(
        page: _currentPage,
        search: _searchQuery,
      );

      if (mounted) {
        setState(() {
          if (refresh) {
            _products = result['products'];
          } else {
            _products.addAll(result['products']);
          }
          
          final pagination = result['pagination'];
          _hasMore = pagination['has_next'] ?? false;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    }
  }

  Future<void> _loadMoreProducts() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _currentPage++;
    });

    await _loadProducts();
  }

  void _performSearch() {
    _searchQuery = _searchController.text.trim();
    _loadProducts(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text('Tüm Ürünler', style: TextStyle(
          fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 18)
        )),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.primary),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: ResponsiveUtils.getResponsiveEdgeInsets(context, baseValue: 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Ürün ara...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: ResponsiveUtils.getResponsiveEdgeInsets(context, baseValue: 12),
                    ),
                    onSubmitted: (_) => _performSearch(),
                  ),
                ),
                SizedBox(width: ResponsiveUtils.getResponsivePadding(context, basePadding: 8)),
                ElevatedButton(
                  onPressed: _performSearch,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text('Ara'),
                ),
              ],
            ),
          ),
          
          // Products List
          Expanded(
            child: _products.isEmpty && !_isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty ? 'Arama sonucu bulunamadı' : 'Henüz ürün bulunmuyor',
                          style: TextStyle(
                            fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 16),
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () => _loadProducts(refresh: true),
                    child: GridView.builder(
                      controller: _scrollController,
                      padding: ResponsiveUtils.getResponsiveEdgeInsets(context, baseValue: 16),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: ResponsiveUtils.getResponsiveGridCrossAxisCount(context),
                        childAspectRatio: 0.75,
                        crossAxisSpacing: ResponsiveUtils.getResponsivePadding(context, basePadding: 12),
                        mainAxisSpacing: ResponsiveUtils.getResponsivePadding(context, basePadding: 12),
                      ),
                      itemCount: _products.length + (_hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _products.length) {
                          return _buildLoadingIndicator();
                        }
                        
                        final product = _products[index];
                        return _buildProductCard(product);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline,
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ProductDetailScreen(product: product),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  color: Theme.of(context).colorScheme.surfaceVariant,
                ),
                child: product.images.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                        child: Image.network(
                          product.images.first,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.image_not_supported,
                              size: 48,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            );
                          },
                        ),
                      )
                    : Icon(
                        Icons.image_not_supported,
                        size: 48,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
              ),
            ),
            
            // Product Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: ResponsiveUtils.getResponsiveEdgeInsets(context, baseValue: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 14),
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      '₺${product.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 16),
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    Spacer(),
                    // Satıcı bilgileri
                    Row(
                      children: [
                        // Satıcı profil resmi
                        GestureDetector(
                          onTap: () {
                            if (product.seller['username'] != null) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => PublicProfileScreen(
                                    username: product.seller['username'],
                                  ),
                                ),
                              );
                            }
                          },
                          child: (product.seller['profile_picture'] != null && product.seller['profile_picture'].isNotEmpty)
                              ? CircleAvatar(
                                  radius: 12,
                                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                  backgroundImage: NetworkImage(product.seller['profile_picture']),
                                  child: null,
                                )
                              : CircleAvatar(
                                  radius: 12,
                                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                  child: Icon(
                                    Icons.person,
                                    size: 14,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                        ),
                        SizedBox(width: 6),
                        // Satıcı kullanıcı adı
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              if (product.seller['username'] != null) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => PublicProfileScreen(
                                      username: product.seller['username'],
                                    ),
                                  ),
                                );
                              }
                            },
                            child: ColoredUsername(
                              text: product.seller['username'] ?? '-',
                              colorHex: product.seller['custom_username_color'],
                              fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 11),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    // Şehir bilgisi
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 10,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            product.city ?? 'Bilinmeyen',
                            style: TextStyle(
                              fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 10),
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
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

  Widget _buildLoadingIndicator() {
    return Center(
      child: Padding(
        padding: ResponsiveUtils.getResponsiveEdgeInsets(context, baseValue: 16),
        child: CircularProgressIndicator(),
      ),
    );
  }
} 