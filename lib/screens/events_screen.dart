import 'package:flutter/material.dart';
import '../models/event.dart';
import '../services/event_service.dart';
import '../utils/responsive_utils.dart';
import 'event_detail_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:math' as math;

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  List<Event> _events = [];
  bool _isLoading = true;
  String? _userCity;
  bool _isLoadingLocation = false;
  bool _showAllEvents = true; // true: tüm etkinlikler, false: konumdaki etkinlikler

  // Türkiye il merkezleri (slug, ad, lat, lon) - Dashboard'dan kopyalandı
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
    _loadUserLocation().then((_) {
      // Konum yüklendikten sonra etkinlikleri yükle
      _loadEvents();
    });
  }

  // Haversine formülü ile iki nokta arası mesafe (km)
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
        _userCity = found!['slug']; // Slug formatında kaydet
      });
      print('DEBUG: City by bounding box: ${found!['name']} (slug: $_userCity)');
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
        _userCity = nearest?['slug'] ?? ''; // Slug formatında kaydet
      });
      print('DEBUG: Fallback to nearest city: ${nearest?['name']} (slug: $_userCity)');
    }
  }

  String _getCityDisplayName(String? citySlug) {
    if (citySlug == null) return '';
    final city = _turkeyCities.firstWhere(
      (c) => c['slug'] == citySlug,
      orElse: () => {'name': citySlug},
    );
    return city['name'] ?? citySlug;
  }

  Future<void> _loadUserLocation() async {
    setState(() { _isLoadingLocation = true; });
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('DEBUG: Location services are disabled.');
        return;
      }
      
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('DEBUG: Location permission denied.');
          return;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        print('DEBUG: Location permission denied forever.');
        return;
      }
      
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      print('DEBUG: Position: lat=${position.latitude}, lon=${position.longitude}');
      _findCityByBoundingBox(position.latitude, position.longitude);
    } catch (e) {
      print('DEBUG: Error getting location: $e');
    } finally {
      setState(() { _isLoadingLocation = false; });
    }
  }

  Future<void> _loadEvents() async {
    setState(() { _isLoading = true; });
    try {
      String? cityFilter = _showAllEvents ? null : _userCity;
      print('DEBUG: EventsScreen._loadEvents - showAllEvents: $_showAllEvents, userCity: $_userCity, cityFilter: $cityFilter');
      final events = await EventService.fetchEvents(city: cityFilter);
      print('DEBUG: EventsScreen._loadEvents - loaded events count: ${events.length}');
      setState(() {
        _events = events;
        _isLoading = false;
      });
    } catch (e) {
      if (e.toString().contains('BanException')) {
        rethrow; // BanException'ı yeniden fırlat, başka hata mesajı gösterme
      }
      setState(() { _isLoading = false; });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Etkinlikler yüklenemedi: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _buyTicket(Event event) async {
    try {
      final ticket = await EventService.buyTicket(event.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bilet alındı! Kodunuz: ${ticket.code}'), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (e.toString().contains('BanException')) {
        rethrow; // BanException'ı yeniden fırlat, başka hata mesajı gösterme
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bilet alınamadı: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _toggleEventFilter() {
    setState(() {
      _showAllEvents = !_showAllEvents;
    });
    _loadEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Etkinlikler', style: TextStyle(
          fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 18)
        )),
        actions: [
          if (_isLoadingLocation)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
          if (_userCity != null && !_isLoadingLocation)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: TextButton(
                onPressed: _toggleEventFilter,
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).brightness == Brightness.light 
                      ? Colors.black 
                      : Colors.white,
                ),
                child: Text(
                  _showAllEvents ? 'Konumumdaki Etkinlikler' : 'Tüm Etkinlikler',
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Filtre bilgisi
          if (_userCity != null && !_showAllEvents)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              child: Row(
                children: [
                  Icon(Icons.location_on, color: Theme.of(context).colorScheme.primary),
                  SizedBox(width: 8),
                  Text(
                    '${_getCityDisplayName(_userCity)} etkinlikleri gösteriliyor',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          // Etkinlik listesi
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _events.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.event_busy,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              _showAllEvents 
                                  ? 'Henüz etkinlik bulunmuyor'
                                  : '${_getCityDisplayName(_userCity)}\'de henüz etkinlik bulunmuyor',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            if (!_showAllEvents) ...[
                              SizedBox(height: 8),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _showAllEvents = true;
                                  });
                                  _loadEvents();
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: Theme.of(context).colorScheme.primary,
                                ),
                                child: Text('Tüm etkinlikleri göster'),
                              ),
                            ],
                          ],
                        ),
                      )
                    : ListView.builder(
              itemCount: _events.length,
              itemBuilder: (context, index) {
                final event = _events[index];
                return Card(
                  margin: const EdgeInsets.all(12),
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => EventDetailScreen(event: event),
                        ),
                      );
                    },
                    child: Padding(
                      padding: ResponsiveUtils.getResponsiveEdgeInsets(context, baseValue: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      event.name,
                                      style: TextStyle(
                                        fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 18),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: ResponsiveUtils.getResponsivePadding(context, basePadding: 8)),
                                    Row(
                                      children: [
                                        Icon(Icons.location_on, size: 16, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            '${event.venue} (${event.cityDisplay})',
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            '${event.date.day}.${event.date.month}.${event.date.year} ${event.timeFormatted}',
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Text('Fiyat: ', style: TextStyle(color: Colors.grey)),
                                        Expanded(
                                          child: Text(
                                            '₺${event.ticketPrice}',
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () => _buyTicket(event),
                                child: const Text('Bilet Al'),
                              ),
                            ],
                          ),
                          if (event.description.isNotEmpty) ...[
                            SizedBox(height: ResponsiveUtils.getResponsivePadding(context, basePadding: 12)),
                            const Divider(),
                            const SizedBox(height: 8),
                            Text(
                              event.description,
                              style: TextStyle(
                                fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 14),
                                color: Colors.grey,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 