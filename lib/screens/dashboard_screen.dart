import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/event.dart';
import '../models/announcement.dart';
import '../models/user.dart';
import '../models/news.dart';
import '../models/message.dart';
import '../models/thread.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../widgets/news_ticker.dart';
import '../widgets/advertisement_widget.dart';
import '../widgets/theme_switch.dart';
import '../widgets/ban_dialog.dart';
import '../utils/responsive_utils.dart';
import 'profile_screen.dart';
import 'forum_screen.dart';
import 'login_screen.dart';
import 'dart:convert';
import 'product_list_screen.dart';
import 'product_category_screen.dart';
import 'my_store_screen.dart';
import 'favorites_screen.dart';
import 'events_screen.dart';
import 'tickets_screen.dart';
import 'chat_list_screen.dart';
import 'campus_screen.dart';
import 'package:geolocator/geolocator.dart';
import '../services/forum_service.dart';
import 'event_detail_screen.dart';
import 'thread_detail_screen.dart';
import 'opportunity_screen.dart';
import 'dart:async';
import 'package:geocoding/geocoding.dart';
import 'dart:math' as math;
import 'public_profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Event> _upcomingEvents = [];
  List<Announcement> _announcements = [];
  List<News> _news = [];
  User? _user;
  bool _isLoading = true;
  int _currentIndex = 0;
  bool _newsEnabled = true;
  int _unreadConversations = 0;
  Map<String, dynamic>? _weather;
  Position? _position;
  bool _isLoadingWeather = true;
  double? _latitude;
  double? _longitude;
  bool _isLoadingEvents = true;
  Thread? _popularThread;
  bool _isLoadingPopularThread = true;
  Thread? _localPopularThread;
  bool _isLoadingLocalPopularThread = true;
  String? _dailySuggestion;
  bool _isLoadingSuggestion = true;
  List<User> _popularUsers = [];
  bool _isLoadingPopularUsers = true;
  PageController? _eventPageController;
  int _eventPageIndex = 0;
  // Kampüs popüler thread state
  Thread? _campusPopularThread;
  bool _isLoadingCampusPopularThread = true;
  // Timer? _eventAutoScrollTimer; // kaldırıldı
  // Türkiye il merkezleri (slug, ad, lat, lon)
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

  String? _weatherCityName;
  String? _weatherCitySlug;

  List<Event> get filteredUpcomingEvents {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final cityName = _weather?['name'] ?? '';
    return _upcomingEvents.where((event) {
      final eventDay = DateTime(event.date.year, event.date.month, event.date.day);
      final diff = eventDay.difference(today).inDays;
      final eventCity = event.cityDisplay;
      return diff >= 0 && diff <= 3 && (cityName.isEmpty || eventCity == cityName);
    }).toList();
  }

  String _cityToSlug(String city) {
    return city
        .toLowerCase()
        .replaceAll('ç', 'c')
        .replaceAll('ğ', 'g')
        .replaceAll('ı', 'i')
        .replaceAll('ö', 'o')
        .replaceAll('ş', 's')
        .replaceAll('ü', 'u')
        .replaceAll(' ', '');
  }

  @override
  void initState() {
    super.initState();
    _initializeDashboard();
  }

  Future<void> _initializeDashboard() async {
    await _loadUserProfile();
    await _loadCampusPopularThread();
    _loadDashboardData();
    _loadNews();
    _loadUnreadConversations();
    _determinePositionAndFetchWeather();
    _loadUpcomingEvents();
    _loadPopularThread();
    _loadLocalPopularThread();
    _loadDailySuggestion();
    _loadPopularUsers();
    _eventPageController = PageController(viewportFraction: 0.8);
    // _startEventAutoScroll(); // kaldırıldı
  }

  // void _startEventAutoScroll() { ... } // kaldırıldı

  @override
  void dispose() {
    // _eventAutoScrollTimer?.cancel(); // kaldırıldı
    _eventPageController?.dispose();
    super.dispose();
  }

  Future<void> _loadDashboardData({String? citySlug}) async {
    try {
      final endpoint = citySlug != null && citySlug.isNotEmpty ? '/events/dashboard/?city=$citySlug' : '/events/dashboard/';
      print('DEBUG: Dashboard endpoint: $endpoint');
      final response = await ApiService.get(endpoint);
      print('DEBUG: Dashboard API response: ${response.body}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            _upcomingEvents = (data['upcoming_events'] as List)
                .map((event) => Event.fromJson(event))
                .toList();
            _announcements = (data['announcements'] as List)
                .map((announcement) => Announcement.fromJson(announcement))
                .toList();
            _isLoading = false;
          });
        }
        print('DEBUG: Upcoming events loaded: ${_upcomingEvents.length}');
        for (final e in _upcomingEvents) {
          print('DEBUG: Event: ${e.name}, city=${e.cityDisplay}, date=${e.date}');
        }
      }
    } catch (e) {
      print('DEBUG: Error in _loadDashboardData: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Veri yüklenirken hata oluştu: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  Future<void> _loadUserProfile() async {
    try {
      final response = await ApiService.get('/users/profile/');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            _user = User.fromJson(data);
          });
        }
      }
    } catch (e) {
      // Kullanıcı bilgileri yüklenemezse varsayılan ikon göster
      print('User profile loading error: $e');
    }
  }

  Future<void> _loadNews() async {
    try {
      final response = await ApiService.get('/news/ticker/');
      print('News API Response Status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('News API Data: $data');
        if (data['success']) {
          if (mounted) {
            setState(() {
              _news = (data['news'] as List)
                  .map((news) => News.fromJson(news))
                  .toList();
            });
          }
          print('Haberler yüklendi: ${_news.length} haber');
        }
      }
    } catch (e) {
      print('Haber yükleme hatası: $e');
      // Haberler yüklenemezse boş liste kalır
    }
  }

  Future<void> _loadUnreadConversations() async {
    try {
      final data = await ApiService.getUserConversations();
      final conversations = data.map((e) => Conversation.fromJson(e)).toList();
      if (mounted) {
        setState(() {
          _unreadConversations = conversations.where((c) => (c.unreadCount ?? 0) > 0).length;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _unreadConversations = 0;
        });
      }
    }
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
      if (mounted) {
        setState(() {
          _weatherCityName = found!['name'];
          _weatherCitySlug = found!['slug'];
        });
      }
      print('DEBUG: City by bounding box: $_weatherCityName ($_weatherCitySlug)');
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
      if (mounted) {
        setState(() {
          _weatherCityName = nearest?['name'] ?? 'Bilinmiyor';
          _weatherCitySlug = nearest?['slug'] ?? '';
        });
      }
      print('DEBUG: Fallback to nearest city: $_weatherCityName ($_weatherCitySlug)');
    }
  }

  Future<void> _determinePositionAndFetchWeather() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('DEBUG: Location services are disabled.');
        if (mounted) {
          setState(() { _weatherCityName = 'Bilinmiyor'; _weatherCitySlug = ''; });
        }
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('DEBUG: Location permission denied.');
          if (mounted) {
            setState(() { _weatherCityName = 'Bilinmiyor'; _weatherCitySlug = ''; });
          }
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        print('DEBUG: Location permission denied forever.');
        if (mounted) {
          setState(() { _weatherCityName = 'Bilinmiyor'; _weatherCitySlug = ''; });
        }
        return;
      }
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      print('DEBUG: Position: lat=${position.latitude}, lon=${position.longitude}');
      if (mounted) {
        setState(() { _position = position; });
      }
      _findCityByBoundingBox(position.latitude, position.longitude);
      final weather = await ApiService.fetchWeatherByCoords(lat: position.latitude, lon: position.longitude);
      print('DEBUG: Weather API response: $weather');
      if (mounted) {
        setState(() { _weather = weather; });
      }
      await _loadDashboardData(citySlug: _weatherCitySlug);
    } catch (e) {
      print('DEBUG: Error in _determinePositionAndFetchWeather: $e');
      if (mounted) {
        setState(() { _weatherCityName = 'Bilinmiyor'; _weatherCitySlug = ''; });
      }
    }
  }

  Future<void> _loadPopularLocalThread(String city) async {
    try {
      final result = await ForumService.getHotTopics();
      if (result['success'] && result['hotTopics'] is List) {
        final threads = (result['hotTopics'] as List)
          .map((t) => Thread.fromJson(t))
          .where((thread) => thread.category.toLowerCase().contains(city.toLowerCase()))
          .toList();
        if (threads.isNotEmpty) {
          setState(() { _localPopularThread = threads.first; });
        }
      }
    } catch (e) {}
  }

  Future<void> _loadWeatherByCoords() async {
    if (_latitude == null || _longitude == null) return;
    final weather = await ApiService.fetchWeatherByCoords(lat: _latitude!, lon: _longitude!);
    setState(() {
      _weather = weather;
      _isLoadingWeather = false;
    });
  }

  Future<void> _loadUpcomingEvents() async {
    setState(() { _isLoadingEvents = true; });
    final eventsJson = await ApiService.fetchUpcomingEvents();
    if (mounted) {
      setState(() {
        _upcomingEvents = eventsJson.map((e) => Event.fromJson(e)).toList();
        _isLoadingEvents = false;
      });
    }
  }

  Future<void> _loadPopularThread() async {
    setState(() { _isLoadingPopularThread = true; });
    final hotThreads = await ApiService.fetchHotThreads();
    if (hotThreads.isNotEmpty) {
      // Sadece genel forumdan olanı al
      final generalThread = hotThreads.firstWhere(
        (t) => (t['thread']['forum_type'] == 'genel' && (t['thread']['university'] == null || t['thread']['university'] == '')),
        orElse: () => null,
      );
      if (mounted) {
        setState(() {
          _popularThread = generalThread != null ? Thread.fromJson(generalThread['thread']) : null;
          _isLoadingPopularThread = false;
        });
      }
    } else {
      if (mounted) {
        setState(() { _isLoadingPopularThread = false; });
      }
    }
  }

  Future<void> _loadLocalPopularThread() async {
    setState(() { _isLoadingLocalPopularThread = true; });
    String? university = _user?.university;
    String? city = _weather?['name'];
    List<dynamic> threads = [];
    if (university != null && university.isNotEmpty) {
      threads = await ForumService.getCampusForumThreads(university: university, forumType: 'genel');
    } else if (city != null && city.isNotEmpty) {
      threads = await ForumService.getCampusForumThreads(university: city, forumType: 'genel');
    }
    if (threads.isNotEmpty) {
      if (mounted) {
        setState(() {
          _localPopularThread = Thread.fromJson(threads[0]);
          _isLoadingLocalPopularThread = false;
        });
      }
    } else {
      if (mounted) {
        setState(() { _isLoadingLocalPopularThread = false; });
      }
    }
  }

  Future<void> _loadDailySuggestion() async {
    setState(() { _isLoadingSuggestion = true; });
    final suggestion = await ApiService.fetchDailySuggestion();
    if (mounted) {
      setState(() {
        _dailySuggestion = suggestion;
        _isLoadingSuggestion = false;
      });
    }
  }

  Future<void> _loadPopularUsers() async {
    setState(() { _isLoadingPopularUsers = true; });
    final usersJson = await ApiService.fetchPopularUsers();
    print('DEBUG: Popular users API response: ' + usersJson.toString());
    if (mounted) {
      setState(() {
        _popularUsers = usersJson.map((u) => User.fromJson(u)).toList();
        _isLoadingPopularUsers = false;
      });
    }
  }

  Future<void> _loadCampusPopularThread() async {
    setState(() { _isLoadingCampusPopularThread = true; });
    print('DEBUG: Dashboard _user.university: ' + (_user?.university ?? 'null'));
    if (_user == null || _user!.university == null || _user!.university!.isEmpty) {
      print('DEBUG: Dashboard kullanıcı üniversite seçmemiş, kampüs threadi yüklenmeyecek.');
      if (mounted) {
        setState(() { _isLoadingCampusPopularThread = false; });
      }
      return;
    }
    final itirafThreads = await ForumService.getCampusForumThreads(university: _user!.university!, forumType: 'itiraf');
    final yardimThreads = await ForumService.getCampusForumThreads(university: _user!.university!, forumType: 'yardim');
    print('DEBUG: Dashboard itirafThreads: ${itirafThreads.length}, yardimThreads: ${yardimThreads.length}');
    List<Thread> all = [...itirafThreads, ...yardimThreads];
    if (all.isEmpty) {
      print('DEBUG: Dashboard kampüs threadi yok.');
      if (mounted) {
        setState(() { _campusPopularThread = null; _isLoadingCampusPopularThread = false; });
      }
      return;
    }
    // En popüler thread: (likesCount*2 + commentCount) en yüksek olan
    Thread? mostPopular;
    int maxScore = -1;
    for (final thread in all) {
      int likeCount = thread.likesCount;
      int commentCount = thread.commentCount ?? 0;
      int score = likeCount * 2 + commentCount;
      print('DEBUG: Dashboard campus thread: ${thread.title}, like: $likeCount, comment: $commentCount, score: $score');
      if (score > maxScore) {
        maxScore = score;
        mostPopular = thread;
      }
    }
    print('DEBUG: Dashboard seçilen kampüs popüler thread: ${mostPopular?.title ?? 'yok'}');
    if (mounted) {
      setState(() { _campusPopularThread = mostPopular; _isLoadingCampusPopularThread = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final filteredUpcomingEvents = _upcomingEvents.where((event) {
      final diff = event.date.difference(now).inSeconds;
      return diff >= 0 && diff <= 3 * 24 * 60 * 60; // 3 gün (saniye cinsinden)
    }).toList();
    if (_user != null && _user!.isBanned) {
      // Show modern ban dialog
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return ModernBanDialog(
              banInfo: {
                'mesaj': 'Hesabınız banlanmıştır.',
                'ban_sebebi': _user!.banReason,
                'ban_bitis': _user!.banUntil?.toString(),
                'ban_suresiz': _user!.banUntil == null,
              },
              onConfirm: () async {
                Navigator.of(context).pop();
                await AuthService.logout();
                if (context.mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                }
              },
              showCountdown: false,
            );
          },
        );
      });
      
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.block, size: 64, color: Theme.of(context).colorScheme.error),
              const SizedBox(height: 24),
              Text('Hesabınız banlanmıştır.',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Theme.of(context).colorScheme.error),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text('Platforma erişiminiz kısıtlanmıştır.', textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: _isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.primary,
                      strokeWidth: 3,
                    ).animate(onPlay: (controller) => controller.repeat())
                      .shimmer(duration: 1.5.seconds, color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)),
                    const SizedBox(height: 16),
                    Text(
                      'Yükleniyor...',
                      style: GoogleFonts.inter(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 16,
                      ),
                    ).animate().fadeIn(delay: 500.ms),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: _loadDashboardData,
                child: CustomScrollView(
                  slivers: [
                    // App Bar
                    SliverAppBar(
                      expandedHeight: ResponsiveUtils.getResponsiveCardHeight(context, baseHeight: 120),
                      floating: false,
                      pinned: true,
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      elevation: 0,
                      flexibleSpace: FlexibleSpaceBar(
                        title: Text(
                          'HPGenc',
                          style: GoogleFonts.inter(
                            fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 24),
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ).animate().fadeIn(duration: 600.ms),
                        background: Container(
                          color: Theme.of(context).colorScheme.surface,
                        ),
                      ),
                      actions: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ThemeModeSelector(),
                        ),
                        Stack(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.chat),
                              onPressed: () async {
                                await Navigator.of(context).push(
                                  MaterialPageRoute(builder: (context) => const ChatListScreen()),
                                );
                                _loadUnreadConversations();
                              },
                            ),
                            if (_unreadConversations > 0)
                              Positioned(
                                right: 8,
                                top: 8,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                                  child: Center(
                                    child: Text(
                                      _unreadConversations.toString(),
                                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        Padding(
                          padding: ResponsiveUtils.getResponsiveEdgeInsets(context, baseValue: 1),
                          child: PopupMenuButton<String>(
                            icon: _buildModernProfileAvatar(context),
                            onSelected: (value) async {
                              if (value == 'profile') {
                                final result = await Navigator.of(context).push(
                                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                                );
                                await _loadUserProfile();
                                await _loadCampusPopularThread();
                              } else if (value == 'store') {
                                await Navigator.of(context).push(
                                  MaterialPageRoute(builder: (context) => const MyStoreScreen()),
                                );
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'profile',
                                child: Text('Profil'),
                              ),
                              PopupMenuItem(
                                value: 'store',
                                child: Text('Mağazam'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Content
                    SliverPadding(
                      padding: ResponsiveUtils.getResponsiveEdgeInsets(context, baseValue: 16),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          // Konum ve hava durumu en üstte
                          if (_weatherCityName == null)
                            Row(
                              children: [
                                Icon(Icons.location_on, color: Theme.of(context).colorScheme.primary),
                                SizedBox(width: 4),
                                Text('Konum alınıyor...', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              ],
                            ),
                          if (_weatherCityName == 'Bilinmiyor')
                            Row(
                              children: [
                                Icon(Icons.location_off, color: Colors.red),
                                SizedBox(width: 4),
                                Text('Konum alınamadı', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red)),
                              ],
                            ),
                          if (_weatherCityName != null && _weatherCityName != 'Bilinmiyor')
                            Row(
                              children: [
                                Icon(Icons.location_on, color: Theme.of(context).colorScheme.primary),
                                SizedBox(width: 4),
                                Text(_weatherCityName!, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              ],
                            ),
                          if (_weather == null)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text('Hava durumu yükleniyor...', style: TextStyle(fontSize: 14)),
                            ),
                          if (_weather != null)
                            Card(
                              margin: EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                leading: Icon(Icons.wb_sunny),
                                title: Text('Sıcaklık: ${_weather!['temperature'] ?? '--'}°C'),
                                subtitle: Text('Rüzgar: ${_weather!['windspeed'] ?? '--'} m/s, Kod: ${_weather!['weathercode'] ?? '--'}'),
                              ),
                            ),
                          // Reklam en üstte
                          AdvertisementWidget(
                            height: ResponsiveUtils.getResponsiveCardHeight(context, baseHeight: 120),
                          ).animate().fadeIn(delay: 200.ms, duration: 600.ms).scale(begin: const Offset(0.8, 0.8)),
                          SizedBox(height: ResponsiveUtils.getResponsivePadding(context, basePadding: 16)),
                          
                          // Haber Ticker
                          Container(
                            margin: ResponsiveUtils.getResponsiveEdgeInsets(context, baseValue: 0, bottom: 8),
                            child: NewsTicker(
                              news: _news,
                              height: ResponsiveUtils.getResponsiveCardHeight(context, baseHeight: 50),
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              textColor: Theme.of(context).colorScheme.onPrimary,
                              isEnabled: _newsEnabled,
                              onToggle: () {
                                setState(() {
                                  _newsEnabled = !_newsEnabled;
                                });
                              },
                            ),
                          ).animate().fadeIn(delay: 400.ms, duration: 600.ms).slideY(begin: 0.3),
                          SizedBox(height: ResponsiveUtils.getResponsivePadding(context, basePadding: 24)),

                          // Ana Özellikler Grid
                          Text(
                            'Ana Özellikler',
                            style: GoogleFonts.inter(
                              fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 22),
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ).animate().fadeIn(delay: 500.ms, duration: 600.ms),
                          SizedBox(height: ResponsiveUtils.getResponsivePadding(context, basePadding: 16)),
                          
                          // Compact 4x2 Grid Layout
                          Column(
                            children: [
                              // First Row - 4 cards
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildCompactFeatureCard(
                                      icon: Icons.shopping_bag,
                                      color: const Color(0xFF667eea),
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(builder: (context) => const ProductCategoryScreen()),
                                        );
                                      },
                                      delay: 600,
                                    ),
                                  ),
                                  SizedBox(width: ResponsiveUtils.getResponsivePadding(context, basePadding: 12)),
                                  Expanded(
                                    child: Stack(
                                      children: [
                                        _buildCompactFeatureCard(
                                          icon: Icons.hotel,
                                          color: Colors.teal,
                                          onTap: () {
                                            showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: Text('Yakında'),
                                                content: Text('Konaklama sayfası yakında eklenecek.'),
                                                actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('Tamam'))],
                                              ),
                                            );
                                          },
                                          delay: 700,
                                        ),
                                        Positioned(
                                          top: 4,
                                          right: 4,
                                          child: Container(
                                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.amber,
                                              borderRadius: BorderRadius.circular(8),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.1),
                                                  blurRadius: 2,
                                                  offset: Offset(0, 1),
                                                ),
                                              ],
                                            ),
                                            child: Text(
                                              'Yakında',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: ResponsiveUtils.getResponsivePadding(context, basePadding: 12)),
                                  Expanded(
                                    child: _buildCompactFeatureCard(
                                      icon: Icons.event,
                                      color: Colors.green,
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(builder: (context) => const EventsScreen()),
                                        );
                                      },
                                      delay: 800,
                                    ),
                                  ),
                                  SizedBox(width: ResponsiveUtils.getResponsivePadding(context, basePadding: 12)),
                                  Expanded(
                                    child: _buildCompactFeatureCard(
                                      icon: Icons.favorite,
                                      color: Colors.red,
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(builder: (context) => const FavoritesScreen()),
                                        );
                                      },
                                      delay: 900,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: ResponsiveUtils.getResponsivePadding(context, basePadding: 12)),
                              // Second Row - 1 card (car rental)
                              Row(
                                children: [
                                  Expanded(
                                    child: Stack(
                                      children: [
                                        _buildCompactFeatureCard(
                                          icon: Icons.directions_car,
                                          color: Colors.orange,
                                          onTap: () {
                                            showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: Text('Yakında'),
                                                content: Text('Araba kiralama sayfası yakında eklenecek.'),
                                                actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('Tamam'))],
                                              ),
                                            );
                                          },
                                          delay: 1000,
                                        ),
                                        Positioned(
                                          top: 4,
                                          right: 4,
                                          child: Container(
                                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.amber,
                                              borderRadius: BorderRadius.circular(8),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.1),
                                                  blurRadius: 2,
                                                  offset: Offset(0, 1),
                                                ),
                                              ],
                                            ),
                                            child: Text(
                                              'Yakında',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Empty space for the remaining 3 slots
                                  SizedBox(width: ResponsiveUtils.getResponsivePadding(context, basePadding: 12)),
                                  Expanded(child: SizedBox()),
                                  SizedBox(width: ResponsiveUtils.getResponsivePadding(context, basePadding: 12)),
                                  Expanded(child: SizedBox()),
                                  SizedBox(width: ResponsiveUtils.getResponsivePadding(context, basePadding: 12)),
                                  Expanded(child: SizedBox()),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: ResponsiveUtils.getResponsivePadding(context, basePadding: 32)),

                          // Yaklaşan Etkinlikler
                          if (_isLoadingEvents)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          else if (filteredUpcomingEvents.isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              child: Text('Yaklaşan Etkinlikler', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.22,
                              child: Column(
                                children: [
                                  Expanded(
                                    child: Stack(
                                      children: [
                                        PageView.builder(
                                          controller: _eventPageController,
                                          itemCount: filteredUpcomingEvents.length,
                                          onPageChanged: (index) {
                                            setState(() { _eventPageIndex = index; });
                                          },
                                          itemBuilder: (context, index) {
                                            final event = filteredUpcomingEvents[index];
                                            return GestureDetector(
                                              onTap: () {
                                                Navigator.of(context).push(MaterialPageRoute(builder: (context) => EventDetailScreen(event: event)));
                                              },
                                              child: Card(
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                elevation: 2,
                                                child: Container(
                                                  width: 200,
                                                  padding: EdgeInsets.all(12),
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Flexible(
                                                        child: Text(event.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                                                      ),
                                                      SizedBox(height: 6),
                                                      Flexible(
                                                        child: Text('${event.venue} (${event.cityDisplay})', style: TextStyle(fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                                                      ),
                                                      SizedBox(height: 6),
                                                      Text('${event.date.day}.${event.date.month}.${event.date.year} ${event.timeFormatted}', style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                                                      SizedBox(height: 6),
                                                      Flexible(
                                                        child: Text('Organizatör: ${event.organizer ?? '-'}', style: TextStyle(fontSize: 12, color: Colors.grey[600]), maxLines: 1, overflow: TextOverflow.ellipsis),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                        // Left arrow
                                        Positioned(
                                          left: 0,
                                          top: 0,
                                          bottom: 0,
                                          child: IconButton(
                                            icon: Icon(Icons.arrow_back_ios, size: 24),
                                            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                                            onPressed: () {
                                              if (_eventPageIndex > 0) {
                                                _eventPageController?.previousPage(duration: Duration(milliseconds: 400), curve: Curves.easeInOut);
                                              }
                                            },
                                          ),
                                        ),
                                        // Right arrow
                                        Positioned(
                                          right: 0,
                                          top: 0,
                                          bottom: 0,
                                          child: IconButton(
                                            icon: Icon(Icons.arrow_forward_ios, size: 24),
                                            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                                            onPressed: () {
                                              if (_eventPageIndex < filteredUpcomingEvents.length - 1) {
                                                _eventPageController?.nextPage(duration: Duration(milliseconds: 400), curve: Curves.easeInOut);
                                              }
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(filteredUpcomingEvents.length, (index) {
                                      final isActive = index == _eventPageIndex;
                                      return AnimatedContainer(
                                        duration: Duration(milliseconds: 300),
                                        margin: EdgeInsets.symmetric(horizontal: 4),
                                        width: isActive ? 14 : 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: isActive
                                              ? (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)
                                              : (Theme.of(context).brightness == Brightness.dark ? Colors.white54 : Colors.black26),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      );
                                    }),
                                  ),
                                ],
                              ),
                            ),
                          ] else ...[
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(child: Text('Yaklaşan etkinlik bulunamadı.')),
                            ),
                          ],
                          SizedBox(height: 16),
                          // Popüler threadler
                          if (_popularThread != null) ...[
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4.0, top: 8.0),
                              child: Text('Genel Forumda En Popüler Thread', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Theme.of(context).colorScheme.primary)),
                            ),
                            Card(
                              margin: EdgeInsets.symmetric(vertical: 4),
                              child: ListTile(
                                leading: Icon(Icons.whatshot, color: Colors.orange),
                                title: Text(_popularThread!.title, maxLines: 2, overflow: TextOverflow.ellipsis),
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => ThreadDetailScreen(thread: _popularThread!)));
                                },
                              ),
                            ),
                          ],
                          if (_user != null && _user!.university != null && _user!.university!.isNotEmpty && !_isLoadingCampusPopularThread && _campusPopularThread != null) ...[
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4.0, top: 16.0),
                              child: Text('Kampüste En Popüler Thread', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Theme.of(context).colorScheme.primary)),
                            ),
                            Card(
                              margin: EdgeInsets.symmetric(vertical: 4),
                              child: ListTile(
                                leading: Icon(Icons.school, color: Colors.blue),
                                title: Text(_campusPopularThread!.title, maxLines: 2, overflow: TextOverflow.ellipsis),
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => ThreadDetailScreen(thread: _campusPopularThread!)));
                                },
                              ),
                            ),
                          ],
                          SizedBox(height: ResponsiveUtils.getResponsivePadding(context, basePadding: 32)),

                          // Duyurular
                          if (_announcements.isNotEmpty) ...[
                            Row(
                              children: [
                            Text(
                              'Duyurular',
                              style: GoogleFonts.inter(
                                fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 20),
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: ResponsiveUtils.getResponsiveEdgeInsets(context, baseValue: 0, horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${_announcements.length}',
                                    style: GoogleFonts.inter(
                                      fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 12),
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ).animate().fadeIn(delay: 1400.ms, duration: 600.ms),
                            SizedBox(height: ResponsiveUtils.getResponsivePadding(context, basePadding: 12)),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _announcements.length,
                              itemBuilder: (context, index) {
                                final announcement = _announcements[index];
                                return Container(
                                  margin: ResponsiveUtils.getResponsiveEdgeInsets(context, baseValue: 0, bottom: 12),
                                  child: Card(
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: BorderSide(
                                        color: Theme.of(context).colorScheme.outline,
                                        width: 1,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: ResponsiveUtils.getResponsiveEdgeInsets(context, baseValue: 16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                padding: ResponsiveUtils.getResponsiveEdgeInsets(context, baseValue: 6),
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Icon(
                                                Icons.announcement,
                                                color: Theme.of(context).colorScheme.primary,
                                                  size: ResponsiveUtils.getResponsiveIconSize(context, baseSize: 16),
                                                ),
                                              ),
                                              SizedBox(width: ResponsiveUtils.getResponsivePadding(context, basePadding: 12)),
                                              Expanded(
                                                child: Text(
                                                  announcement.title,
                                                  style: GoogleFonts.inter(
                                                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 16),
                                                    fontWeight: FontWeight.bold,
                                                    color: Theme.of(context).colorScheme.onSurface,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: ResponsiveUtils.getResponsivePadding(context, basePadding: 8)),
                                          Text(
                                            announcement.content,
                                            style: GoogleFonts.inter(
                                              fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 14),
                                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                                            ),
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(height: ResponsiveUtils.getResponsivePadding(context, basePadding: 8)),
                                          Text(
                                            '${announcement.publishDate.day}/${announcement.publishDate.month}/${announcement.publishDate.year}',
                                            style: GoogleFonts.inter(
                                              fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 12),
                                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ).animate().fadeIn(delay: (1600 + index * 100).ms, duration: 600.ms).slideY(begin: 0.3);
                              },
                            ),
                          ],
                          // Popüler kullanıcılar bölümü hemen altında
                          if (_popularUsers.isNotEmpty) _buildPopularUsersSection(),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          if (index == 0) {
            // Anasayfa
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => DashboardScreen()),
            );
          } else if (index == 1) {
            // Topluluk
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => ForumScreen()),
              );
            } else if (index == 2) {
            // Fırsatlar
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => OpportunityScreen()),
            );
          } else if (index == 3 && _user != null && _user!.university != null && _user!.university!.isNotEmpty) {
            // Kampüs
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => CampusScreen(user: _user!)),
              );
            }
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
            label: 'Anasayfa',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.forum),
            label: 'Topluluk',
            ),
            BottomNavigationBarItem(
            icon: Icon(Icons.local_offer),
            label: 'Fırsatlar',
            ),
          if (_user != null && _user!.university != null && _user!.university!.isNotEmpty)
            BottomNavigationBarItem(
              icon: Icon(Icons.school),
              label: 'Kampüs',
            ),
          ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    required int delay,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline,
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color,
                color.withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: ResponsiveUtils.getResponsiveEdgeInsets(context, baseValue: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: ResponsiveUtils.getResponsiveIconSize(context, baseSize: 32),
                color: Colors.white,
              ),
              SizedBox(height: ResponsiveUtils.getResponsivePadding(context, basePadding: 12)),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 16),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: ResponsiveUtils.getResponsivePadding(context, basePadding: 4)),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 12),
                  color: Colors.white.withOpacity(0.8),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: delay.ms, duration: 600.ms).scale(begin: const Offset(0.8, 0.8));
  }

  Widget _buildCompactFeatureCard({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required int delay,
  }) {
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
        onTap: onTap,
        child: Container(
          height: ResponsiveUtils.getResponsiveCardHeight(context, baseHeight: 60),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color,
                color.withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Icon(
              icon,
              size: ResponsiveUtils.getResponsiveIconSize(context, baseSize: 24),
              color: Colors.white,
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: delay.ms, duration: 600.ms).scale(begin: const Offset(0.8, 0.8));
  }

  Widget _buildUpcomingEventsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text('Yaklaşan Etkinlikler', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ),
        SizedBox(
          height: 160,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: _upcomingEvents.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final event = _upcomingEvents[index];
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Container(
                  width: 240,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(event.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      Text('${event.venue} - ${event.city}', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                      const SizedBox(height: 8),
                      Text('${event.date.day}.${event.date.month}.${event.date.year}', style: const TextStyle(fontSize: 13)),
                      const Spacer(),
                      Text(event.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPopularThreadSection() {
    final thread = _popularThread!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text('Genel Forumda En Popüler Thread', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            title: Text(thread.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Oluşturan: ${thread.creator.username}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.thumb_up, size: 18, color: Colors.blueGrey),
                const SizedBox(width: 4),
                Text(thread.likesCount.toString()),
              ],
            ),
            onTap: () {
              // Thread detayına git (ileride eklenebilir)
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLocalPopularThreadSection() {
    final thread = _localPopularThread!;
    final university = _user?.university;
    final city = _weather?['name'];
    final label = university != null && university.isNotEmpty
        ? '[$university] Forumda En Popüler Thread'
        : city != null && city.isNotEmpty
            ? '[$city] Forumda En Popüler Thread'
            : 'Yerel Forumda En Popüler Thread';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            title: Text(thread.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Oluşturan: ${thread.creator.username}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.thumb_up, size: 18, color: Colors.blueGrey),
                const SizedBox(width: 4),
                Text(thread.likesCount.toString()),
              ],
            ),
            onTap: () {
              // Thread detayına git (ileride eklenebilir)
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDailySuggestionSection() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: const Icon(Icons.lightbulb, color: Colors.amber, size: 32),
        title: const Text('Günün Önerisi', style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(_dailySuggestion ?? ''),
      ),
    );
  }

  Widget _buildWeatherCard(Map<String, dynamic> weather) {
    final temp = weather['main']?['temp']?.toStringAsFixed(1) ?? '--';
    final desc = (weather['weather']?[0]?['description'] ?? '').toString().toUpperCase();
    final icon = weather['weather']?[0]?['icon'] ?? '01d';
    final humidity = weather['main']?['humidity']?.toString() ?? '--';
    final wind = weather['wind']?['speed']?.toString() ?? '--';
    final city = weather['name'] ?? '';
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Image.network('https://openweathermap.org/img/wn/$icon@2x.png', width: 48, height: 48),
        title: Text('Hava Durumu: $desc', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Sıcaklık: $temp°C\nNem: %$humidity  Rüzgar: $wind m/s'),
        trailing: Text(city, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildPopularUsersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text(
            'Aylık En Popüler 10 Kullanıcı',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: _popularUsers.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final user = _popularUsers[index];
            return GestureDetector(
              onTap: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => PublicProfileScreen(username: user.username),
                  ),
                );
              },
              child: Card(
                elevation: 2,
                margin: EdgeInsets.symmetric(horizontal: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                  leading: Stack(
                    alignment: Alignment.center,
                    children: [
                      _buildProfileAvatar(user.profilePicture, isPremium: user.isPremium, radius: 24),
                      if (user.isPremium)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Icon(Icons.star, color: Colors.amber, size: 16),
                        ),
                    ],
                  ),
                  title: Row(
                    children: [
                      Text(user.username, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      SizedBox(width: 8),
                      Text('#${index + 1}', style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  subtitle: Row(
                    children: [
                      Text('Puan: ${user.popularity ?? 0}', style: TextStyle(fontSize: 13, color: Colors.deepOrange, fontWeight: FontWeight.bold)),
                      SizedBox(width: 10),
                      Icon(Icons.thumb_up, size: 14, color: Colors.blueGrey),
                      SizedBox(width: 2),
                      Text('${user.threadLikes ?? 0}', style: TextStyle(fontSize: 12)),
                      SizedBox(width: 10),
                      Icon(Icons.person_add, size: 14, color: Colors.green),
                      SizedBox(width: 2),
                      Text('${user.newFollowers ?? 0}', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                  trailing: Icon(Icons.chevron_right),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildModernProfileAvatar(BuildContext context) {
    final double size = ResponsiveUtils.getResponsiveIconSize(context, baseSize: 48);
    final double border = 3;
    final bool isPremium = _user?.isPremium ?? false;
    final String? profilePicture = _user?.profilePicture;
    return Stack(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: isPremium
                ? LinearGradient(colors: [Colors.amber, Colors.orange, Colors.deepOrange])
                : LinearGradient(colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primary.withOpacity(0.7)]),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(border),
            child: CircleAvatar(
              radius: size / 2 - border,
              backgroundColor: Theme.of(context).colorScheme.surface,
              backgroundImage: profilePicture != null && profilePicture.isNotEmpty ? NetworkImage(profilePicture) : null,
              onBackgroundImageError: (exception, stackTrace) {
                // Handle image loading errors silently
                print('Profile image loading error: $exception');
              },
              child: profilePicture == null || profilePicture.isEmpty
                  ? Icon(Icons.person, size: size * 0.55, color: Theme.of(context).colorScheme.primary.withOpacity(0.5))
                  : null,
            ),
          ),
        ),
        if (isPremium)
          Positioned(
            bottom: 2,
            right: 2,
            child: Icon(Icons.star, color: Colors.amber, size: size * 0.28),
          ),
        Positioned(
          bottom: 2,
          left: 2,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Icon(Icons.edit, size: size * 0.20, color: Theme.of(context).colorScheme.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildHomeIconButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 28, color: Theme.of(context).colorScheme.primary),
          ),
        ),
        SizedBox(height: 6),
        Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
  }

  String getFullImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    return 'http://localhost:8000$url'; // Gerekirse prod domain ile değiştir
  }

  Widget _buildProfileAvatar(String? url, {bool isPremium = false, double radius = 24}) {
    final fullUrl = getFullImageUrl(url);
    if (fullUrl.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(fullUrl),
        backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
        onBackgroundImageError: (exception, stackTrace) {
          // Handle image loading errors silently
          print('Profile avatar loading error: $exception');
        },
        child: Icon(Icons.person, size: radius, color: Theme.of(context).colorScheme.primary),
      );
    } else {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
        child: Icon(Icons.person, size: radius, color: Theme.of(context).colorScheme.primary),
      );
    }
  }
} 