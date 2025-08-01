import 'dart:convert';
import '../models/notification.dart';
import 'api_service.dart';

class NotificationService {
  static Future<List<AppNotification>> getNotifications() async {
    try {
      final response = await ApiService.get('/users/notifications/');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['notifications'] as List)
            .map((notification) => AppNotification.fromJson(notification))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error fetching notifications: $e');
      return [];
    }
  }

  static Future<int> getUnreadCount() async {
    try {
      final response = await ApiService.get('/users/notifications/unread-count/');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['unread_count'] ?? 0;
      }
      return 0;
    } catch (e) {
      print('Error fetching unread count: $e');
      return 0;
    }
  }

  static Future<bool> markAllAsRead() async {
    try {
      final response = await ApiService.post('/users/notifications/mark-read/', {});
      return response.statusCode == 200;
    } catch (e) {
      print('Error marking notifications as read: $e');
      return false;
    }
  }
} 