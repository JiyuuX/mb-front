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
  static const String baseUrl = 'http://localhost:8000/api'; // Web için localhost
  // static const String baseUrl = 'http://10.0.2.2:8000/api'; // Android emulator için
  // static const String baseUrl = 'http://127.0.0.1:8000/api'; // iOS simulator için

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
} 