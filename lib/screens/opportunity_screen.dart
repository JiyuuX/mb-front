import 'package:flutter/material.dart';
import '../models/discount_venue.dart';
import '../services/api_service.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import '../screens/dashboard_screen.dart'; // Added import for DashboardScreen

class OpportunityScreen extends StatefulWidget {
  const OpportunityScreen({Key? key}) : super(key: key);

  @override
  State<OpportunityScreen> createState() => _OpportunityScreenState();
}

class _OpportunityScreenState extends State<OpportunityScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<DiscountVenue> _venues = [];
  bool _isLoadingVenues = true;
  String _userCity = '';
  bool _isPremium = false;
  List<Product> _freeProducts = [];
  bool _isLoadingFreeProducts = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserInfoAndVenues();
  }

  Future<void> _loadUserInfoAndVenues() async {
    // Burada kullanıcı profilinden şehir ve premium bilgisi çekilmeli
    // Şimdilik örnek olarak sabit değerler kullanıyorum
    // TODO: Gerçek kullanıcıdan çekilecek
    setState(() {
      _userCity = 'İstanbul';
      _isPremium = true;
    });
    await _fetchVenues();
  }

  Future<void> _fetchVenues() async {
    setState(() { _isLoadingVenues = true; });
    final venuesJson = await ApiService.fetchDiscountVenues(city: _userCity, isPremium: _isPremium);
    setState(() {
      _venues = venuesJson.map((v) => DiscountVenue.fromJson(v)).toList();
      _isLoadingVenues = false;
    });
  }

  Future<void> _loadFreeProducts() async {
    setState(() { _isLoadingFreeProducts = true; });
    try {
      final products = await ProductService.fetchFreeProducts();
      setState(() {
        _freeProducts = products;
        _isLoadingFreeProducts = false;
      });
    } catch (e) {
      setState(() { _isLoadingFreeProducts = false; });
    }
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
            Tab(text: _isPremium ? 'Premium Üyeler için İndirimli Mekanlar' : 'İndirimli Mekanlar'),
            Tab(text: 'Ücretsiz 2.EL Ürünler'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _isPremium ? _buildDiscountVenuesTab() : Center(child: Text('Sadece premium üyeler indirimli mekanları görebilir.')), 
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
      return const Center(child: Text('Bu şehirde indirimli mekan bulunamadı.'));
    }
    return ListView.builder(
      itemCount: _venues.length,
      itemBuilder: (context, index) {
        final venue = _venues[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text(venue.name),
            subtitle: Text('${venue.city} - ${venue.description}'),
            trailing: venue.isPremiumOnly
                ? const Icon(Icons.star, color: Colors.orange, size: 20)
                : null,
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
      return const Center(child: Text('Ücretsiz ürün bulunamadı.'));
    }
    return ListView.builder(
      itemCount: _freeProducts.length,
      itemBuilder: (context, index) {
        final product = _freeProducts[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text(product.title),
            subtitle: Text(product.description ?? ''),
            trailing: const Text('0 TL', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          ),
        );
      },
    );
  }
} 