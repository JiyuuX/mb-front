import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/notification.dart';
import '../models/user.dart';
import '../services/notification_service.dart';
import '../utils/responsive_utils.dart';
import 'public_profile_screen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<AppNotification> _notifications = [];
  bool _isLoading = true;
  bool _isMarkingAsRead = false;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    // Sayfa açıldığında tüm bildirimleri okundu olarak işaretle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _markAllAsRead();
    });
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final notifications = await NotificationService.getNotifications();
      if (mounted) {
        setState(() {
          _notifications = notifications;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bildirimler yüklenirken hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _markAllAsRead() async {
    setState(() {
      _isMarkingAsRead = true;
    });

    try {
      final success = await NotificationService.markAllAsRead();
      if (success && mounted) {
        setState(() {
          _notifications = _notifications.map((notification) {
            return AppNotification(
              id: notification.id,
              senderId: notification.senderId,
              senderUsername: notification.senderUsername,
              senderProfilePicture: notification.senderProfilePicture,
              notificationType: notification.notificationType,
              notificationTypeDisplay: notification.notificationTypeDisplay,
              title: notification.title,
              message: notification.message,
              isRead: true,
              createdAt: notification.createdAt,
            );
          }).toList();
          _isMarkingAsRead = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tüm bildirimler okundu olarak işaretlendi.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isMarkingAsRead = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bildirimler güncellenirken hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildNotificationItem(AppNotification notification) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: notification.isRead ? 1 : 3,
      color: notification.isRead 
          ? Theme.of(context).colorScheme.surface
          : Theme.of(context).colorScheme.primary.withOpacity(0.05),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: notification.iconColor.withOpacity(0.1),
          child: Icon(
            _getIconData(notification.icon),
            color: notification.iconColor,
            size: 20,
          ),
        ),
        title: Text(
          notification.title,
          style: GoogleFonts.inter(
            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notification.message,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  notification.timeAgo,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                if (notification.senderUsername != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    '• ${notification.senderUsername}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: notification.senderUsername != null
            ? IconButton(
                icon: const Icon(Icons.person, size: 20),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => PublicProfileScreen(
                        username: notification.senderUsername!,
                      ),
                    ),
                  );
                },
              )
            : null,
        onTap: () {
          // Bildirime tıklandığında yapılacak işlemler
          if (notification.senderUsername != null) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => PublicProfileScreen(
                  username: notification.senderUsername!,
                ),
              ),
            );
          }
        },
      ),
    ).animate().fadeIn(delay: 100.ms).slideX(begin: 0.3);
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'person_add':
        return Icons.person_add;
      case 'favorite':
        return Icons.favorite;
      case 'comment':
        return Icons.comment;
      case 'alternate_email':
        return Icons.alternate_email;
      case 'notifications':
        return Icons.notifications;
      default:
        return Icons.notifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Bildirimler',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (_notifications.isNotEmpty)
            TextButton(
              onPressed: _isMarkingAsRead ? null : _markAllAsRead,
              child: _isMarkingAsRead
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      'Tümünü Okundu İşaretle',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
            ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Bildirimler yükleniyor...',
                    style: GoogleFonts.inter(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            )
          : _notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_none,
                        size: 64,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Henüz bildiriminiz yok',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Yeni bildirimler geldiğinde burada görünecek',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadNotifications,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      return _buildNotificationItem(_notifications[index]);
                    },
                  ),
                ),
    );
  }
} 