import 'package:flutter/material.dart';

class AppNotification {
  final int id;
  final int? senderId;
  final String? senderUsername;
  final String? senderProfilePicture;
  final String notificationType;
  final String notificationTypeDisplay;
  final String title;
  final String message;
  final bool isRead;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    this.senderId,
    this.senderUsername,
    this.senderProfilePicture,
    required this.notificationType,
    required this.notificationTypeDisplay,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'],
      senderId: json['sender'],
      senderUsername: json['sender_username'],
      senderProfilePicture: json['sender_profile_picture'],
      notificationType: json['notification_type'],
      notificationTypeDisplay: json['notification_type_display'],
      title: json['title'],
      message: json['message'],
      isRead: json['is_read'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender': senderId,
      'sender_username': senderUsername,
      'sender_profile_picture': senderProfilePicture,
      'notification_type': notificationType,
      'notification_type_display': notificationTypeDisplay,
      'title': title,
      'message': message,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays} gün önce';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} saat önce';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} dakika önce';
    } else {
      return 'Az önce';
    }
  }

  String get icon {
    switch (notificationType) {
      case 'follow':
        return 'person_add';
      case 'like':
        return 'favorite';
      case 'comment':
        return 'comment';
      case 'mention':
        return 'alternate_email';
      case 'system':
        return 'notifications';
      default:
        return 'notifications';
    }
  }

  Color get iconColor {
    switch (notificationType) {
      case 'follow':
        return Colors.blue;
      case 'like':
        return Colors.red;
      case 'comment':
        return Colors.green;
      case 'mention':
        return Colors.orange;
      case 'system':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
} 