import 'package:flutter/material.dart';
import '../models/discount_venue.dart';
import '../services/api_service.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import '../screens/dashboard_screen.dart'; // Added import for DashboardScreen
import '../screens/product_detail_screen.dart'; // Added import for ProductDetailScreen
import '../widgets/colored_username.dart'; // Added import for ColoredUsername

class OpportunityScreen extends StatefulWidget {
  const OpportunityScreen({Key? key}) : super(key: key);

  @override
  State<OpportunityScreen> createState() => _OpportunityScreenState();
}

class _OpportunityScreenState extends State<OpportunityScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<DiscountVenue> _venues = [];
  bool _isLoadingVenues = true;
  List<Product> _freeProducts = [];
  bool _isLoadingFreeProducts = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadVenues();
    _loadFreeProducts();
  }

  Future<void> _loadVenues() async {
    setState(() { _isLoadingVenues = true; });
    final venuesJson = await ApiService.fetchDiscountVenues();
    setState(() {
      _venues = venuesJson.map((v) => DiscountVenue.fromJson(v)).toList();
      _isLoadingVenues = false;
    });
  }

  Future<void> _loadFreeProducts() async {
    setState(() { _isLoadingFreeProducts = true; });
    try {
      final productsJson = await ApiService.fetchFreeProducts();
      setState(() {
        _freeProducts = productsJson.map((p) => Product.fromJson(p)).toList();
        _isLoadingFreeProducts = false;
      });
    } catch (e) {
      setState(() { _isLoadingFreeProducts = false; });
    }
  }

  String _getImageUrl(String imageUrl) {
    if (imageUrl.startsWith('http')) {
      return imageUrl;
    }
    
    // Backend URL'sini ekle
    return 'http://192.168.1.105:8000$imageUrl';
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const DashboardScreen()),
              (route) => false,
            );
          },
        ),
        title: const Text('Fırsatlar'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'İndirimli Mekanlar'),
            Tab(text: 'Ücretsiz 2.EL Ürünler'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDiscountVenuesTab(),
          _buildFreeProductsTab(),
        ],
      ),
    );
  }

  Widget _buildDiscountVenuesTab() {
    if (_isLoadingVenues) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_venues.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.store, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Henüz indirimli mekan bulunmuyor',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Yakında burada indirimli mekanlar görünecek',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      itemCount: _venues.length,
      itemBuilder: (context, index) {
        final venue = _venues[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Resim/GIF alanı - kartı kaplayacak
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: venue.image != null
                      ? Image.network(
                          _getImageUrl(venue.image!),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: const Icon(Icons.store, size: 50, color: Colors.grey),
                            );
                          },
                        )
                      : Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.store, size: 50, color: Colors.grey),
                        ),
                ),
              ),
              // İşletme adı
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  venue.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFreeProductsTab() {
    if (_isLoadingFreeProducts) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_freeProducts.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sentiment_dissatisfied, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Henüz ücretsiz ürün bulunmuyor',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Fiyatı 0 TL olan ürünler burada listelenecek',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      itemCount: _freeProducts.length,
      itemBuilder: (context, index) {
        final product = _freeProducts[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                // Ürün resmi
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: product.image != null
                        ? Image.network(
                            _getImageUrl(product.image!),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[300],
                                child: const Icon(Icons.inventory, size: 50, color: Colors.grey),
                              );
                            },
                          )
                        : Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.inventory, size: 50, color: Colors.grey),
                          ),
                  ),
                ),
                // Ürün bilgileri
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              product.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'ÜCRETSİZ',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (product.description != null && product.description!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          product.description!,
                          style: const TextStyle(fontSize: 14),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            product.city ?? 'Şehir belirtilmemiş',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '0 TL',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      // Satıcı bilgileri
                      if (product.seller != null) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            // Satıcı profil resmi
                            if (product.seller!['profile_picture'] != null)
                              CircleAvatar(
                                radius: 16,
                                backgroundImage: NetworkImage(product.seller!['profile_picture']),
                                onBackgroundImageError: (exception, stackTrace) {
                                  // Handle image loading errors silently
                                  print('Seller profile image loading error: $exception');
                                },
                                child: null,
                              )
                            else
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: Colors.grey[300],
                                child: Icon(
                                  Icons.person,
                                  size: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            const SizedBox(width: 8),
                            // Satıcı kullanıcı adı
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Satıcı',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  ColoredUsername(
                                    text: product.seller!['username'] ?? '-',
                                    colorHex: product.seller!['custom_username_color'],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
} 