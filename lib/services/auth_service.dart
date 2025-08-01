import 'dart:convert';
import '../models/user.dart';
import 'api_service.dart';

class AuthService {
  static Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String passwordConfirm,
    required String firstName,
    required String lastName,
  }) async {
    try {
      final response = await ApiService.post('/users/register/', {
        'username': username,
        'email': email,
        'password': password,
        'password_confirm': passwordConfirm,
        'first_name': firstName,
        'last_name': lastName,
      });

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'message': data['message'],
          'user_id': data['user_id'],
          'verification_code': data['verification_code'],
          'email': data['email'],
        };
      } else {
        final data = json.decode(response.body);
        return {
          'success': false,
          'message': data.toString(),
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Bağlantı hatası: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> verifyEmail({
    required String email,
    required String code,
  }) async {
    try {
      final response = await ApiService.post('/users/verify-email/', {
        'email': email,
        'code': code,
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'message': data['message'],
        };
      } else {
        final data = json.decode(response.body);
        return {
          'success': false,
          'message': data.toString(),
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Bağlantı hatası: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> resendVerificationCode({
    required String email,
  }) async {
    try {
      final response = await ApiService.post('/users/resend-verification/', {
        'email': email,
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'message': data['message'],
          'verification_code': data['verification_code'],
          'email': data['email'],
        };
      } else {
        final data = json.decode(response.body);
        return {
          'success': false,
          'message': data.toString(),
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Bağlantı hatası: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await ApiService.post('/users/login/', {
        'username': username,
        'password': password,
      });

      // Debug: Response status ve body
      print('Login response status: ${response.statusCode}');
      print('Login response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Null kontrolü ekle
        if (data['tokens'] == null || data['tokens']['access'] == null) {
          return {
            'success': false,
            'message': 'Token alınamadı.',
          };
        }
        
        if (data['user'] == null) {
          return {
            'success': false,
            'message': 'Kullanıcı bilgileri alınamadı.',
          };
        }
        
        await ApiService.saveToken(data['tokens']['access']);
        
        return {
          'success': true,
          'message': data['message'] ?? 'Giriş başarılı!',
          'user': User.fromJson(data['user']),
          'tokens': data['tokens'],
        };
      } else if (response.statusCode == 401) {
        final data = json.decode(response.body);
        
        // Debug: 401 response data
        print('401 response data: $data');
        
        // Email verification required kontrolü
        if (data['email_verification_required'] == true) {
          print('Email verification required detected');
          return {
            'success': false,
            'email_verification_required': true,
            'message': data['message'],
            'verification_code': data['verification_code'],
            'email': data['email'],
          };
        }
        
        return {
          'success': false,
          'message': data.toString(),
        };
      } else {
        final data = json.decode(response.body);
        // Ban response'u dict ise ve içinde 'banli' anahtarı varsa
        if (data is Map && data.containsKey('banli') && data['banli'] == true) {
          return {
            'success': false,
            'banli': true,
            'ban_sebebi': data['ban_sebebi'],
            'ban_suresiz': data['ban_suresiz'],
            'ban_bitis': data['ban_bitis'],
            'kalan_sure': data['kalan_sure'],
            'message': data['mesaj'] ?? 'Hesabınız banlanmıştır.'
          };
        }
        return {
          'success': false,
          'message': data.toString(),
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Bağlantı hatası: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> logout() async {
    try {
      final token = await ApiService.getToken();
      if (token != null) {
        await ApiService.post('/users/logout/', {
          'refresh_token': token,
        });
      }
      await ApiService.removeToken();
      
      return {
        'success': true,
        'message': 'Başarıyla çıkış yapıldı.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Çıkış yapılırken hata oluştu: $e',
      };
    }
  }

  static Future<bool> isLoggedIn() async {
    final token = await ApiService.getToken();
    return token != null;
  }

  static Future<Map<String, dynamic>> activatePremium() async {
    try {
      final response = await ApiService.post('/users/activate-premium/', {});
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'message': data['message'],
          'is_premium': data['is_premium'],
          'premium_expires_at': data['premium_expires_at'],
          'card_number': data['card_number'],
          'can_create_threads': data['can_create_threads'],
        };
      } else {
        final data = json.decode(response.body);
        return {
          'success': false,
          'message': data['message'],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Premium aktivasyon hatası: $e',
      };
    }
  }
} 