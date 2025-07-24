import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BanException implements Exception {
  final String message;
  BanException([this.message = 'Hesabınız banlandığı için erişiminiz engellendi.']);
  @override
  String toString() => message;
}

class ApiService {
  // Dinamik IP adresi - her iki bilgisayar için uyumlu
  static String get baseUrl {
    // Android emulator için özel IP
    if (const bool.fromEnvironment('dart.vm.product') == false) {
      return 'http://10.0.2.2:8000/api'; // Android emulator
    }
    
    // Gerçek cihazlar için ağ IP'si
    // Windows: 192.168.1.105, macOS: 192.168.1.100
    // Aynı ağda olduğu için her iki IP de çalışacak
    return 'http://192.168.1.105:8000/api'; // Ana IP (Windows)
    // Alternatif: return 'http://192.168.1.100:8000/api'; // macOS IP
  }
  
  // IP adresini değiştirmek için kullanın
  static String? _customBaseUrl;
  static void setCustomBaseUrl(String url) {
    _customBaseUrl = url;
  }
  
  static Future<String> get effectiveBaseUrl async {
    if (_customBaseUrl != null) {
      return _customBaseUrl!;
    }
    
    // Kaydedilen IP'yi kontrol et
    final prefs = await SharedPreferences.getInstance();
    final savedIp = prefs.getString('custom_ip');
    if (savedIp != null) {
      return 'http://$savedIp:8000/api';
    }
    
    // Varsayılan IP (Mac için)
    return 'http://192.168.1.105:8000/api';
  }

  // Ban handler
  static void Function(Map<String, dynamic> banInfo)? onBanDetected;

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', token);
  }

  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
  }

  static Future<Map<String, String>> _getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<http.Response> get(String endpoint) async {
    final headers = await _getHeaders();
    final baseUrl = await effectiveBaseUrl;
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    );
    _checkBan(response);
    if (response.statusCode == 403) {
      await removeToken();
      throw BanException();
    } else if (response.statusCode == 401) {
      await removeToken();
      throw Exception('Oturum süreniz dolmuş. Lütfen tekrar giriş yapın.');
    }
    return response;
  }

  static Future<http.Response> post(String endpoint, Map<String, dynamic> data) async {
    final headers = await _getHeaders();
    final baseUrl = await effectiveBaseUrl;
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: json.encode(data),
    );
    _checkBan(response);
    if (response.statusCode == 403) {
      await removeToken();
      throw BanException();
    } else if (response.statusCode == 401) {
      await removeToken();
      throw Exception('Oturum süreniz dolmuş. Lütfen tekrar giriş yapın.');
    }
    return response;
  }

  static Future<http.Response> put(String endpoint, Map<String, dynamic> data) async {
    final headers = await _getHeaders();
    final baseUrl = await effectiveBaseUrl;
    final response = await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: json.encode(data),
    );
    _checkBan(response);
    if (response.statusCode == 403) {
      await removeToken();
      throw BanException();
    } else if (response.statusCode == 401) {
      await removeToken();
      throw Exception('Oturum süreniz dolmuş. Lütfen tekrar giriş yapın.');
    }
    return response;
  }

  static Future<http.Response> delete(String endpoint) async {
    final headers = await _getHeaders();
    final baseUrl = await effectiveBaseUrl;
    final response = await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    );
    _checkBan(response);
    if (response.statusCode == 403) {
      await removeToken();
      throw BanException();
    } else if (response.statusCode == 401) {
      await removeToken();
      throw Exception('Oturum süreniz dolmuş. Lütfen tekrar giriş yapın.');
    }
    return response;
  }

  static void _checkBan(http.Response response) async {
    try {
      // Eğer 403 Forbidden ise, ban response'u olmasa bile ban mekanizmasını tetikle
      if (response.statusCode == 403) {
        await removeToken();
        if (onBanDetected != null) {
          onBanDetected!({
            'mesaj': 'Hesabınız banlandığı için oturumunuz sonlandırıldı.',
          });
        }
        return;
      }
      
      // Eğer 401 Unauthorized ise, sadece token'ı sil, ban dialogu açma
      if (response.statusCode == 401) {
        await removeToken();
        return;
      }
      
      final data = json.decode(response.body);
      if (data is Map && data['banli'] == true) {
        await removeToken();
        if (onBanDetected != null) {
          onBanDetected!(Map<String, dynamic>.from(data));
        }
      }
    } catch (_) {}
  }

  static Future<http.Response> getExternal(String url) async {
    final response = await http.get(Uri.parse(url));
    return response;
  }

  // Public Profile Methods
  static Future<Map<String, dynamic>> getPublicProfile(String username) async {
    final response = await get('/users/public/$username/');
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> followUser(int userId) async {
    final response = await post('/users/follow/', {
      'user_id': userId,
      'action': 'follow',
    });
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> unfollowUser(int userId) async {
    final response = await post('/users/follow/', {
      'user_id': userId,
      'action': 'unfollow',
    });
    return json.decode(response.body);
  }

  static Future<List<Map<String, dynamic>>> getUserFollowers(String username) async {
    final response = await get('/users/followers/$username/');
    return List<Map<String, dynamic>>.from(json.decode(response.body));
  }

  static Future<List<Map<String, dynamic>>> getUserFollowing(String username) async {
    final response = await get('/users/following/$username/');
    return List<Map<String, dynamic>>.from(json.decode(response.body));
  }

  // Fetch user conversations
  static Future<List<Map<String, dynamic>>> getUserConversations() async {
    final response = await get('/chat/conversations/');
    final data = json.decode(response.body);
    if (data is Map && data.containsKey('results')) {
      return List<Map<String, dynamic>>.from(data['results']);
    } else if (data is List) {
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception('Beklenmeyen sohbet listesi formatı');
    }
  }

  // Mark all messages in a conversation as read
  static Future<void> markConversationRead(int conversationId) async {
    await post('/chat/conversations/$conversationId/mark_read/', {});
  }

  static Future<List<dynamic>> fetchDiscountVenues({required String city, bool isPremium = true}) async {
    final response = await get('/market/discount-venues/?city=${Uri.encodeComponent(city)}&is_premium=${isPremium ? 'true' : 'false'}');
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return data['venues'];
      }
    }
    return [];
  }

  static Future<List<dynamic>> fetchAccommodations({required String city}) async {
    final response = await get('/market/accommodations/?city=${Uri.encodeComponent(city)}');
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return data['accommodations'];
      }
    }
    return [];
  }

  static Future<List<dynamic>> fetchUpcomingEvents() async {
    final response = await get('/events/upcoming-events/');
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is Map && data.containsKey('results')) {
        return data['results'];
      } else if (data is List) {
        return data;
      }
    }
    return [];
  }

  static Future<List<dynamic>> fetchHotThreads() async {
    final response = await get('/forum/threads/hot/');
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is List) {
        return data;
      }
    }
    return [];
  }

  static Future<List<dynamic>> fetchPopularUsers() async {
    final response = await get('/users/popular-users/');
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true && data['users'] != null) {
        return data['users'];
      }
    }
    return [];
  }

  static Future<Map<String, dynamic>?> fetchWeather({required String city}) async {
    const apiKey = 'YOUR_OPENWEATHERMAP_API_KEY'; // TODO: Gerçek anahtar ile değiştir
    final url = 'https://api.openweathermap.org/data/2.5/weather?q=${Uri.encodeComponent(city)}&appid=$apiKey&units=metric&lang=tr';
    final response = await getExternal(url);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    return null;
  }

  static Future<Map<String, dynamic>?> fetchWeatherByCoords({required double lat, required double lon}) async {
    final url = 'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current_weather=true';
    final response = await getExternal(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['current_weather'] != null) {
        return data['current_weather'];
      }
      return null;
    }
    return null;
  }

  static Future<String?> fetchDailySuggestion() async {
    final response = await get('/news/daily-suggestion/');
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true && data['suggestion'] != null) {
        return data['suggestion']['text'];
      }
    }
    return null;
  }
} 