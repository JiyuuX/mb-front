import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import '../services/api_service.dart';
import '../utils/responsive_utils.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:geolocator/geolocator.dart';
import 'dart:math' as math;

class ProductFormScreen extends StatefulWidget {
  final Product? product;
  final String? category;
  const ProductFormScreen({super.key, this.product, this.category});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _cityController = TextEditingController();
  final _categoryController = TextEditingController();
  String _status = 'used';
  String? _selectedCity;
  List<XFile> _pickedImages = [];
  bool _isLoading = false;
  int? _selectedCategoryId;
  int? _selectedSubcategoryId;
  List<Map<String, dynamic>> _categories = [];
  
  // Türkiye'nin 81 ili
  final List<String> _cities = [
    'Adana', 'Adıyaman', 'Afyonkarahisar', 'Ağrı', 'Amasya', 'Ankara', 'Antalya', 'Artvin', 'Aydın', 'Balıkesir',
    'Bilecik', 'Bingöl', 'Bitlis', 'Bolu', 'Burdur', 'Bursa', 'Çanakkale', 'Çankırı', 'Çorum', 'Denizli',
    'Diyarbakır', 'Edirne', 'Elazığ', 'Erzincan', 'Erzurum', 'Eskişehir', 'Gaziantep', 'Giresun', 'Gümüşhane', 'Hakkari',
    'Hatay', 'Isparta', 'Mersin', 'İstanbul', 'İzmir', 'Kars', 'Kastamonu', 'Kayseri', 'Kırklareli', 'Kırşehir',
    'Kocaeli', 'Konya', 'Kütahya', 'Malatya', 'Manisa', 'Kahramanmaraş', 'Mardin', 'Muğla', 'Muş', 'Nevşehir',
    'Niğde', 'Ordu', 'Rize', 'Sakarya', 'Samsun', 'Siirt', 'Sinop', 'Sivas', 'Tekirdağ', 'Tokat',
    'Trabzon', 'Tunceli', 'Şanlıurfa', 'Uşak', 'Van', 'Yozgat', 'Zonguldak', 'Aksaray', 'Bayburt', 'Karaman',
    'Kırıkkale', 'Batman', 'Şırnak', 'Bartın', 'Ardahan', 'Iğdır', 'Yalova', 'Karabük', 'Kilis', 'Osmaniye', 'Düzce'
  ];
  
  // Türkiye il merkezleri (slug, ad, lat, lon) - Dashboard'dan alındı
  final List<Map<String, dynamic>> _turkeyCities = [
    {"slug": "adana", "name": "Adana", "lat": 37.0000, "lon": 35.3213},
    {"slug": "adiyaman", "name": "Adıyaman", "lat": 37.7648, "lon": 38.2786},
    {"slug": "afyonkarahisar", "name": "Afyonkarahisar", "lat": 38.7507, "lon": 30.5567},
    {"slug": "agri", "name": "Ağrı", "lat": 39.7191, "lon": 43.0503},
    {"slug": "amasya", "name": "Amasya", "lat": 40.6499, "lon": 35.8353},
    {"slug": "ankara", "name": "Ankara", "lat": 39.9208, "lon": 32.8541},
    {"slug": "antalya", "name": "Antalya", "lat": 36.8841, "lon": 30.7056},
    {"slug": "ardahan", "name": "Ardahan", "lat": 41.1108, "lon": 42.7022},
    {"slug": "artvin", "name": "Artvin", "lat": 41.1832, "lon": 41.8309},
    {"slug": "aydin", "name": "Aydın", "lat": 37.8499, "lon": 27.8500},
    {"slug": "balikesir", "name": "Balıkesir", "lat": 39.6504, "lon": 27.8900},
    {"slug": "bartin", "name": "Bartın", "lat": 41.5811, "lon": 32.4619},
    {"slug": "batman", "name": "Batman", "lat": 37.8890, "lon": 41.1400},
    {"slug": "bayburt", "name": "Bayburt", "lat": 40.2550, "lon": 40.2247},
    {"slug": "bilecik", "name": "Bilecik", "lat": 40.1500, "lon": 29.9830},
    {"slug": "bingol", "name": "Bingöl", "lat": 38.8850, "lon": 40.4980},
    {"slug": "bitlis", "name": "Bitlis", "lat": 38.3940, "lon": 42.1230},
    {"slug": "bolu", "name": "Bolu", "lat": 40.7363, "lon": 31.6061},
    {"slug": "burdur", "name": "Burdur", "lat": 37.7167, "lon": 30.2833},
    {"slug": "bursa", "name": "Bursa", "lat": 40.1999, "lon": 29.0699},
    {"slug": "canakkale", "name": "Çanakkale", "lat": 40.1459, "lon": 26.4064},
    {"slug": "cankiri", "name": "Çankırı", "lat": 40.6070, "lon": 33.6210},
    {"slug": "corum", "name": "Çorum", "lat": 40.5200, "lon": 34.9500},
    {"slug": "denizli", "name": "Denizli", "lat": 37.7704, "lon": 29.0800},
    {"slug": "diyarbakir", "name": "Diyarbakır", "lat": 37.9100, "lon": 40.2400},
    {"slug": "duzce", "name": "Düzce", "lat": 40.8430, "lon": 31.1565},
    {"slug": "edirne", "name": "Edirne", "lat": 41.6704, "lon": 26.5700},
    {"slug": "elazig", "name": "Elazığ", "lat": 38.6809, "lon": 39.2264},
    {"slug": "erzincan", "name": "Erzincan", "lat": 39.7526, "lon": 39.4928},
    {"slug": "erzurum", "name": "Erzurum", "lat": 39.9204, "lon": 41.2900},
    {"slug": "eskisehir", "name": "Eskişehir", "lat": 39.7949, "lon": 30.5299},
    {"slug": "gaziantep", "name": "Gaziantep", "lat": 37.0667, "lon": 37.3833},
    {"slug": "giresun", "name": "Giresun", "lat": 40.9175, "lon": 38.3927},
    {"slug": "gumushane", "name": "Gümüşhane", "lat": 40.4640, "lon": 39.4840},
    {"slug": "hakkari", "name": "Hakkari", "lat": 37.5744, "lon": 43.7408},
    {"slug": "hatay", "name": "Hatay", "lat": 36.2000, "lon": 36.1667},
    {"slug": "igdir", "name": "Iğdır", "lat": 39.8887, "lon": 44.0046},
    {"slug": "isparta", "name": "Isparta", "lat": 37.7680, "lon": 30.5619},
    {"slug": "istanbul", "name": "İstanbul", "lat": 41.0151, "lon": 28.9795},
    {"slug": "izmir", "name": "İzmir", "lat": 38.4237, "lon": 27.1428},
    {"slug": "kahramanmaras", "name": "Kahramanmaraş", "lat": 37.5753, "lon": 36.9228},
    {"slug": "karabuk", "name": "Karabük", "lat": 41.2053, "lon": 32.6203},
    {"slug": "karaman", "name": "Karaman", "lat": 37.1815, "lon": 33.2150},
    {"slug": "kars", "name": "Kars", "lat": 40.6085, "lon": 43.0975},
    {"slug": "kastamonu", "name": "Kastamonu", "lat": 41.3890, "lon": 33.7830},
    {"slug": "kayseri", "name": "Kayseri", "lat": 38.7348, "lon": 35.4680},
    {"slug": "kirikkale", "name": "Kırıkkale", "lat": 39.8504, "lon": 33.5300},
    {"slug": "kirklareli", "name": "Kırklareli", "lat": 41.7430, "lon": 27.2260},
    {"slug": "kirsehir", "name": "Kırşehir", "lat": 39.1420, "lon": 34.1710},
    {"slug": "kocaeli", "name": "Kocaeli", "lat": 40.7760, "lon": 29.9306},
    {"slug": "konya", "name": "Konya", "lat": 37.8746, "lon": 32.4932},
    {"slug": "kutahya", "name": "Kütahya", "lat": 39.4200, "lon": 29.9300},
    {"slug": "malatya", "name": "Malatya", "lat": 38.3704, "lon": 38.3000},
    {"slug": "manisa", "name": "Manisa", "lat": 38.6306, "lon": 27.4222},
    {"slug": "mardin", "name": "Mardin", "lat": 37.07498, "lon": 41.21835},
    {"slug": "mersin", "name": "Mersin", "lat": 36.8121, "lon": 34.6415},
    {"slug": "mugla", "name": "Muğla", "lat": 37.2164, "lon": 28.3639},
    {"slug": "mus", "name": "Muş", "lat": 38.7490, "lon": 41.4969},
    {"slug": "nevsehir", "name": "Nevşehir", "lat": 38.6250, "lon": 34.7200},
    {"slug": "nigde", "name": "Niğde", "lat": 37.9760, "lon": 34.6940},
    {"slug": "ordu", "name": "Ordu", "lat": 41.0004, "lon": 37.8699},
    {"slug": "osmaniye", "name": "Osmaniye", "lat": 37.0748, "lon": 36.2450},
    {"slug": "rize", "name": "Rize", "lat": 41.0255, "lon": 40.5177},
    {"slug": "sakarya", "name": "Sakarya", "lat": 40.7667, "lon": 30.4000},
    {"slug": "samsun", "name": "Samsun", "lat": 41.5682, "lon": 35.9069},
    {"slug": "siirt", "name": "Siirt", "lat": 37.9440, "lon": 41.9330},
    {"slug": "sinop", "name": "Sinop", "lat": 42.0230, "lon": 35.1530},
    {"slug": "sivas", "name": "Sivas", "lat": 39.7454, "lon": 37.0350},
    {"slug": "sanliurfa", "name": "Şanlıurfa", "lat": 37.1583, "lon": 38.7917},
    {"slug": "sirnak", "name": "Şırnak", "lat": 37.1520, "lon": 42.4590},
    {"slug": "tekirdag", "name": "Tekirdağ", "lat": 40.9778, "lon": 27.5153},
    {"slug": "tokat", "name": "Tokat", "lat": 40.3060, "lon": 36.5630},
    {"slug": "trabzon", "name": "Trabzon", "lat": 40.97999, "lon": 39.71999},
    {"slug": "tunceli", "name": "Tunceli", "lat": 39.1167, "lon": 39.5333},
    {"slug": "usak", "name": "Uşak", "lat": 38.6804, "lon": 29.4200},
    {"slug": "van", "name": "Van", "lat": 38.4998, "lon": 43.3781},
    {"slug": "yalova", "name": "Yalova", "lat": 40.6500, "lon": 29.2667},
    {"slug": "yozgat", "name": "Yozgat", "lat": 39.8180, "lon": 34.8150},
    {"slug": "zonguldak", "name": "Zonguldak", "lat": 41.2000, "lon": 32.6000}
  ];

  @override
  void initState() {
    super.initState();
    // Kategori ve alt kategori çekme fonksiyonu her zaman çağrılacak
    _fetchCategories();
    if (widget.product != null) {
      _titleController.text = widget.product!.title;
      _descController.text = widget.product!.description;
      _priceController.text = widget.product!.price.toString();
      _selectedCity = widget.product!.city;
      _selectedCategoryId = widget.product!.category;
      _selectedSubcategoryId = widget.product!.subcategory;
      _status = widget.product!.status;
    } else if (widget.category != null) {
      _selectedCategoryId = int.tryParse(widget.category!);
    }
    // Yeni ürün eklerken kullanıcının konum bilgisini al
    if (widget.product == null) {
      _getUserLocation();
    }
  }

  Future<void> _fetchCategories() async {
    try {
      final cats = await ProductService.fetchCategories();
      setState(() { _categories = cats; });
    } catch (e, st) {
      print('Kategori çekme hatası: $e');
      print(st);
    }
  }

  // Dashboard'dan alınan mesafe hesaplama fonksiyonu
  double _distance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371; // Dünya yarıçapı km
    final dLat = (lat2 - lat1) * 3.141592653589793 / 180.0;
    final dLon = (lon2 - lon1) * 3.141592653589793 / 180.0;
    final a =
        0.5 - (lat2 - lat1) / 360 +
        (math.sin(dLat / 2) * math.sin(dLat / 2)) +
        math.cos(lat1 * 3.141592653589793 / 180.0) *
            math.cos(lat2 * 3.141592653589793 / 180.0) *
            math.sin(dLon / 2) * math.sin(dLon / 2);
    return R * 2 * math.asin(math.sqrt(a));
  }

  // Dashboard'dan alınan şehir tespit fonksiyonu
  void _findCityByBoundingBox(double lat, double lon) {
    Map<String, dynamic>? found;
    for (final city in _turkeyCities) {
      final double cityLat = city['lat'];
      final double cityLon = city['lon'];
      // Bounding box: ±0.2 derece
      if (lat >= cityLat - 0.2 && lat <= cityLat + 0.2 &&
          lon >= cityLon - 0.2 && lon <= cityLon + 0.2) {
        found = city;
        break;
      }
    }
    if (found != null) {
      setState(() {
        _selectedCity = found!['name'];
      });
      print('DEBUG: City by bounding box: ${found!['name']} (${found!['slug']})');
    } else {
      // Fallback: nearest city
      double minDist = double.infinity;
      Map<String, dynamic>? nearest;
      for (final city in _turkeyCities) {
        final dist = _distance(lat, lon, city['lat'], city['lon']);
        if (dist < minDist) {
          minDist = dist;
          nearest = city;
        }
      }
      setState(() {
        _selectedCity = nearest?['name'] ?? 'İstanbul';
      });
      print('DEBUG: Fallback to nearest city: ${nearest?['name']} (${nearest?['slug']})');
    }
  }

  Future<void> _getUserLocation() async {
    try {
      // Önce kullanıcının profil bilgilerini kontrol et
      final response = await ApiService.get('/users/profile/');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final userCity = data['city'];
        if (userCity != null && userCity.isNotEmpty) {
          setState(() {
            _selectedCity = userCity;
          });
          print('DEBUG: User profile city: $userCity');
          return;
        }
      }
      
      // Profil bilgilerinde şehir yoksa GPS konumunu al
      print('DEBUG: No city in profile, getting GPS location...');
      await _getCurrentLocation();
      
    } catch (e) {
      print('Kullanıcı konum bilgisi alınamadı: $e');
      // Hata durumunda varsayılan olarak İstanbul'u seç
      setState(() {
        _selectedCity = 'İstanbul';
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('DEBUG: Location services are disabled.');
        setState(() { _selectedCity = 'İstanbul'; });
        return;
      }
      
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('DEBUG: Location permission denied.');
          setState(() { _selectedCity = 'İstanbul'; });
          return;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        print('DEBUG: Location permission denied forever.');
        setState(() { _selectedCity = 'İstanbul'; });
        return;
      }
      
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      print('DEBUG: Position: lat=${position.latitude}, lon=${position.longitude}');
      _findCityByBoundingBox(position.latitude, position.longitude);
      
    } catch (e) {
      print('DEBUG: Error getting current location: $e');
      setState(() { _selectedCity = 'İstanbul'; });
    }
  }

  // Güvenli kategori bulma fonksiyonu
  Map<String, dynamic>? _findCategory(int? categoryId) {
    if (categoryId == null || _categories.isEmpty) return null;
    try {
      return _categories.firstWhere((cat) => cat['id'] == categoryId);
    } catch (e) {
      return null;
    }
  }

  // Güvenli alt kategori listesi alma
  List<Map<String, dynamic>> _getSubcategories(int? categoryId) {
    final category = _findCategory(categoryId);
    if (category == null) return [];
    return (category['subcategories'] as List?)?.cast<Map<String, dynamic>>() ?? [];
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage();
    if (picked.isNotEmpty) {
      setState(() {
        _pickedImages = picked;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; });
    try {
      final data = {
        'title': _titleController.text.trim(),
        'description': _descController.text.trim(),
        'price': double.tryParse(_priceController.text.trim()) ?? 0.0,
        'city': _selectedCity ?? '',
        'category': _selectedCategoryId,
        'subcategory': _selectedSubcategoryId,
        'status': _status,
      };
      
      print('Submitting product data: $data');
      
      final product = widget.product == null
          ? await ProductService.createProduct(data)
          : await ProductService.updateProduct(widget.product!.id, data);
      
      print('Product created/updated: ${product.id}');
      
      if (widget.product == null && _pickedImages.isNotEmpty) {
        print('Uploading ${_pickedImages.length} images for product ${product.id}');
        await ProductService.uploadProductImages(product.id, _pickedImages);
        print('Images uploaded successfully');
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.product == null ? 'Ürün başarıyla eklendi!' : 'Ürün başarıyla güncellendi!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      print('Product submit error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'), 
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(widget.product == null ? 'Ürün Ekle' : 'Ürünü Düzenle', style: TextStyle(
          fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 18),
          color: Theme.of(context).colorScheme.primary, 
          fontWeight: FontWeight.bold
        )),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.primary),
      ),
      body: SingleChildScrollView(
        padding: ResponsiveUtils.getResponsiveEdgeInsets(context, baseValue: 16),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: ResponsiveUtils.isLargeScreen(context) ? 600 : double.infinity,
            ),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Theme.of(context).colorScheme.outline, width: 1),
              ),
              margin: ResponsiveUtils.getResponsiveEdgeInsets(context, baseValue: 16),
              color: Theme.of(context).colorScheme.surface,
              child: Padding(
                padding: ResponsiveUtils.getResponsiveEdgeInsets(context, baseValue: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: 'Başlık',
                          labelStyle: TextStyle(
                            fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 14),
                            color: Theme.of(context).colorScheme.onSurfaceVariant
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                          ),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                        ),
                        validator: (v) => v == null || v.isEmpty ? 'Başlık gerekli' : null,
                      ),
                      SizedBox(height: ResponsiveUtils.getResponsivePadding(context, basePadding: 16)),
                      TextFormField(
                        controller: _descController,
                        decoration: InputDecoration(
                          labelText: 'Açıklama',
                          labelStyle: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 14)
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                          ),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                        ),
                        maxLines: 3,
                        validator: (v) => v == null || v.isEmpty ? 'Açıklama gerekli' : null,
                      ),
                      SizedBox(height: ResponsiveUtils.getResponsivePadding(context, basePadding: 16)),
                      TextFormField(
                        controller: _priceController,
                        decoration: InputDecoration(
                          labelText: 'Fiyat (TL)',
                          labelStyle: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 14)
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                          ),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) => v == null || v.isEmpty ? 'Fiyat gerekli' : null,
                      ),
                      SizedBox(height: ResponsiveUtils.getResponsivePadding(context, basePadding: 16)),
                      DropdownButtonFormField<String>(
                        value: _selectedCity,
                        items: [
                          DropdownMenuItem<String>(
                            value: null,
                            child: Text(
                              'Şehir Seçin',
                              style: TextStyle(
                                fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 14),
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          ..._cities.map<DropdownMenuItem<String>>((city) => DropdownMenuItem<String>(
                            value: city,
                            child: Text(
                              city,
                              style: TextStyle(
                                fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 14)
                              ),
                            ),
                          )).toList(),
                        ],
                        onChanged: (val) => setState(() => _selectedCity = val),
                        decoration: InputDecoration(
                          labelText: 'Şehir',
                          labelStyle: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 14)
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                          ),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                        ),
                        validator: (v) => v == null || v.isEmpty ? 'Şehir gerekli' : null,
                      ),
                      SizedBox(height: ResponsiveUtils.getResponsivePadding(context, basePadding: 16)),
                      DropdownButtonFormField<int>(
                        value: _selectedCategoryId,
                        items: _categories.map<DropdownMenuItem<int>>((cat) => DropdownMenuItem<int>(
                          value: cat['id'] as int,
                          child: Text(
                            cat['name'] ?? '',
                            style: TextStyle(
                              fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 14)
                            ),
                          ),
                        )).toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedCategoryId = val;
                            _selectedSubcategoryId = null;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Kategori',
                          labelStyle: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 14)
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                          ),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                        ),
                        validator: (v) => v == null ? 'Kategori gerekli' : null,
                      ),
                      SizedBox(height: ResponsiveUtils.getResponsivePadding(context, basePadding: 16)),
                      if (_selectedCategoryId != null)
                        DropdownButtonFormField<int>(
                          value: _selectedSubcategoryId,
                          items: _getSubcategories(_selectedCategoryId)
                              .map<DropdownMenuItem<int>>((subcat) => DropdownMenuItem<int>(
                                    value: subcat['id'] as int,
                                    child: Text(
                                      subcat['name'],
                                      style: TextStyle(
                                        fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 14)
                                      ),
                                    ),
                                  ))
                              .toList(),
                          onChanged: (val) => setState(() => _selectedSubcategoryId = val),
                          decoration: InputDecoration(
                            labelText: 'Alt Kategori',
                            labelStyle: TextStyle(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 14)
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                            ),
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                          ),
                          validator: (v) => v == null ? 'Alt kategori gerekli' : null,
                      ),
                      SizedBox(height: ResponsiveUtils.getResponsivePadding(context, basePadding: 16)),
                      DropdownButtonFormField<String>(
                        value: _status,
                        items: [
                          DropdownMenuItem(
                            value: 'new', 
                            child: Text(
                              'Yeni',
                              style: TextStyle(
                                fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 14)
                              )
                            )
                          ),
                          DropdownMenuItem(
                            value: 'used', 
                            child: Text(
                              '2. El',
                              style: TextStyle(
                                fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 14)
                              )
                            )
                          ),
                        ],
                        onChanged: (v) => setState(() => _status = v ?? 'used'),
                        decoration: InputDecoration(
                          labelText: 'Durum',
                          labelStyle: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 14)
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                          ),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                        ),
                      ),
                      SizedBox(height: ResponsiveUtils.getResponsivePadding(context, basePadding: 16)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _pickImages,
                            icon: Icon(
                              Icons.image,
                              size: ResponsiveUtils.getResponsiveIconSize(context, baseSize: 18)
                            ),
                            label: Text(
                              'Görselleri Seç',
                              style: TextStyle(
                                fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 14)
                              )
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              foregroundColor: Theme.of(context).colorScheme.onPrimary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              elevation: 0,
                              padding: ResponsiveUtils.getResponsiveEdgeInsets(context, baseValue: 12, horizontal: 16, vertical: 8),
                            ),
                          ),
                          if (_pickedImages.isNotEmpty) ...[
                            SizedBox(height: ResponsiveUtils.getResponsivePadding(context, basePadding: 12)),
                            SizedBox(
                              height: ResponsiveUtils.getResponsiveImageSize(context, baseSize: 60),
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: _pickedImages.length,
                                separatorBuilder: (_, __) => SizedBox(width: ResponsiveUtils.getResponsivePadding(context, basePadding: 8)),
                                itemBuilder: (context, idx) {
                                  if (kIsWeb) {
                                    return Container(
                                      width: ResponsiveUtils.getResponsiveImageSize(context, baseSize: 60),
                                      height: ResponsiveUtils.getResponsiveImageSize(context, baseSize: 60),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.image, 
                                        color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                                        size: ResponsiveUtils.getResponsiveIconSize(context, baseSize: 24)
                                      ),
                                    );
                                  } else {
                                    return ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        File(_pickedImages[idx].path),
                                        width: ResponsiveUtils.getResponsiveImageSize(context, baseSize: 60),
                                        height: ResponsiveUtils.getResponsiveImageSize(context, baseSize: 60),
                                        fit: BoxFit.cover,
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: ResponsiveUtils.getResponsivePadding(context, basePadding: 24)),
                      _isLoading
                          ? Center(
                              child: CircularProgressIndicator(
                                color: Theme.of(context).colorScheme.primary,
                              )
                            )
                          : SizedBox(
                              width: double.infinity,
                              height: ResponsiveUtils.getResponsiveButtonHeight(context, baseHeight: 48),
                              child: ElevatedButton(
                                onPressed: _submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context).colorScheme.primary,
                                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  elevation: 0,
                                ),
                                child: Text(
                                  widget.product == null ? 'Ekle' : 'Güncelle', 
                                  style: TextStyle(
                                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 16), 
                                    fontWeight: FontWeight.bold
                                  )
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
} 