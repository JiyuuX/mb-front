import 'dart:convert';
import '../models/thread.dart';
import '../models/post.dart';
import '../models/comment.dart';
import 'api_service.dart';

class ForumService {
  // Thread işlemleri
  static Future<Map<String, dynamic>> getThreads() async {
    try {
      final response = await ApiService.get('/forum/threads/');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'threads': (data['results'] as List)
              .map((thread) => Thread.fromJson(thread))
              .where((t) => t.forumType == 'genel' && (t.university == null || t.university!.isEmpty))
              .toList(),
        };
      } else {
        return {
          'success': false,
          'message': 'Thread\'ler yüklenemedi.',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Bağlantı hatası: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> createThread(String title, String category) async {
    try {
      final response = await ApiService.post('/forum/threads/', {
        'title': title,
        'category': category,
      });
      
      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'message': 'Thread başarıyla oluşturuldu.',
          'thread': Thread.fromJson(data),
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
        'message': 'Thread oluşturma hatası: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> getThreadDetail(int threadId) async {
    try {
      final response = await ApiService.get('/forum/threads/$threadId/');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'thread': Thread.fromJson(data),
        };
      } else {
        return {
          'success': false,
          'message': 'Thread bulunamadı.',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Thread detay hatası: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> toggleThreadLike(int threadId) async {
    try {
      final response = await ApiService.post('/forum/threads/$threadId/like/', {});
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'liked': data['liked'],
          'likes_count': data['likes_count'],
        };
      } else {
        return {
          'success': false,
          'message': 'Beğeni işlemi başarısız.',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Beğeni işlemi hatası: $e',
      };
    }
  }

  // Post işlemleri
  static Future<Map<String, dynamic>> getPosts(int threadId) async {
    try {
      final response = await ApiService.get('/forum/threads/$threadId/posts/');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'posts': (data['results'] as List).map((post) => Post.fromJson(post)).toList(),
        };
      } else {
        return {
          'success': false,
          'message': 'Post\'lar yüklenemedi.',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Post yükleme hatası: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> createPost(int threadId, String content) async {
    try {
      final response = await ApiService.post('/forum/threads/$threadId/posts/', {
        'content': content,
      });
      
      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'message': 'Post başarıyla oluşturuldu.',
          'post': Post.fromJson(data),
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
        'message': 'Post oluşturma hatası: $e',
      };
    }
  }

  // Comment işlemleri
  static Future<Map<String, dynamic>> getComments(int postId, {int page = 1}) async {
    try {
      final response = await ApiService.get('/forum/posts/$postId/comments/?page=$page');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'comments': (data['results'] as List).map((comment) => Comment.fromJson(comment)).toList(),
          'hasNext': data['next'] != null,
          'totalPages': data['count'] != null ? (data['count'] / 5).ceil() : 1, // 5 is page_size
        };
      } else {
        return {
          'success': false,
          'message': 'Yorumlar yüklenemedi.',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Yorum yükleme hatası: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> createComment(int postId, String content) async {
    try {
      final response = await ApiService.post('/forum/posts/$postId/comments/', {
        'content': content,
      });
      
      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'message': 'Yorum başarıyla eklendi.',
          'comment': Comment.fromJson(data),
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
        'message': 'Yorum ekleme hatası: $e',
      };
    }
  }

  // Thread istatistikleri
  static Future<Map<String, dynamic>> getThreadStats(int threadId) async {
    try {
      final response = await ApiService.get('/forum/threads/$threadId/stats/');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'stats': data,
        };
      } else {
        return {
          'success': false,
          'message': 'İstatistikler yüklenemedi.',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'İstatistik hatası: $e',
      };
    }
  }

  // Hot Topics (Trend) threadler
  static Future<Map<String, dynamic>> getHotTopics() async {
    try {
      final response = await ApiService.get('/forum/threads/hot/');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'hotTopics': data,
        };
      } else {
        return {
          'success': false,
          'message': 'Trend konular yüklenemedi.',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Trend konu yükleme hatası: $e',
      };
    }
  }

  static Future<List<Thread>> getCampusForumThreads({required String university, required String forumType}) async {
    try {
      final response = await ApiService.get('/forum/threads/campus/?university=${Uri.encodeComponent(university)}&forum_type=$forumType');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['threads'] as List).map((thread) {
          final t = Thread.fromJson(thread);
          // like_count ve comment_count varsa Thread objesine ekle (gerekirse Thread modelini güncelle)
          if (thread['like_count'] != null) t.likesCount = thread['like_count'];
          if (thread['comment_count'] != null) t.commentCount = thread['comment_count'];
          return t;
        }).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> createCampusThread({
    required String title,
    required String category,
    required String forumType,
    required String university,
  }) async {
    try {
      final response = await ApiService.post('/forum/threads/', {
        'title': title,
        'category': category,
        'forum_type': forumType,
        'university': university,
      });
      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'message': 'Konu başarıyla oluşturuldu.',
          'thread': Thread.fromJson(data),
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
        'message': 'Konu oluşturma hatası: $e',
      };
    }
  }

  // Thread report işlemi
  static Future<Map<String, dynamic>> reportThread(int threadId, String category, String reason) async {
    try {
      final response = await ApiService.post('/forum/threads/$threadId/report/', {
        'category': category,
        'reason': reason,
      });
      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'Raporunuz alındı.'
        };
      } else {
        final data = json.decode(response.body);
        return {
          'success': false,
          'message': data['message'] is String ? data['message'] : data['message'].toString(),
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Rapor gönderme hatası: $e',
      };
    }
  }

  // Yorum report işlemi
  static Future<Map<String, dynamic>> reportComment(int commentId, String category, String reason) async {
    try {
      final response = await ApiService.post('/forum/comments/$commentId/report/', {
        'category': category,
        'reason': reason,
      });
      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'Raporunuz alındı.'
        };
      } else {
        final data = json.decode(response.body);
        return {
          'success': false,
          'message': data['message'] is String ? data['message'] : data['message'].toString(),
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Rapor gönderme hatası: $e',
      };
    }
  }

  // Post report işlemi
  static Future<Map<String, dynamic>> reportPost(int postId, String category, String reason) async {
    try {
      final response = await ApiService.post('/forum/posts/$postId/report/', {
        'category': category,
        'reason': reason,
      });
      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'Raporunuz alındı.'
        };
      } else {
        final data = json.decode(response.body);
        return {
          'success': false,
          'message': data['message'] is String ? data['message'] : data['message'].toString(),
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Rapor gönderme hatası: $e',
      };
    }
  }
} 