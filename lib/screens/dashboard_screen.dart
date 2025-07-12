import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/event.dart';
import '../models/announcement.dart';
import '../models/user.dart';
import '../models/news.dart';
import '../services/api_service.dart';
import '../widgets/news_ticker.dart';
import '../widgets/advertisement_widget.dart';
import '../widgets/theme_switch.dart';
import 'profile_screen.dart';
import 'forum_screen.dart';
import 'dart:convert';

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

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
    _loadUserProfile();
    _loadNews();
  }

  Future<void> _loadDashboardData() async {
    try {
      final response = await ApiService.get('/events/dashboard/');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
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
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
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
        setState(() {
          _user = User.fromJson(data);
        });
      }
    } catch (e) {
      // Kullanıcı bilgileri yüklenemezse varsayılan ikon göster
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
          setState(() {
            _news = (data['news'] as List)
                .map((news) => News.fromJson(news))
                .toList();
          });
          print('Haberler yüklendi: ${_news.length} haber');
        }
      }
    } catch (e) {
      print('Haber yükleme hatası: $e');
      // Haberler yüklenemezse boş liste kalır
    }
  }

  @override
  Widget build(BuildContext context) {
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
                      expandedHeight: 120,
                      floating: false,
                      pinned: true,
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      elevation: 0,
                      flexibleSpace: FlexibleSpaceBar(
                        title: Text(
                          'HPGenc',
                          style: GoogleFonts.inter(
                            fontSize: 24,
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
                        GestureDetector(
                          onTap: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => const ProfileScreen()),
                            );
                            _loadUserProfile();
                          },
                          child: Container(
                            margin: const EdgeInsets.all(8),
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.outline,
                                width: 1,
                              ),
                            ),
                            child: _user?.profilePicture != null
                                ? ClipOval(
                                    child: Image.network(
                                      _user!.profilePicture!,
                                      width: 40,
                                      height: 40,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Icon(
                                          Icons.person,
                                          color: Theme.of(context).colorScheme.primary,
                                        );
                                      },
                                    ),
                                  )
                                : Icon(
                                    Icons.person,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                          ),
                        ).animate().scale(duration: 300.ms),
                      ],
                    ),

                    // Content
                    SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          // Haber Ticker
                          Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: NewsTicker(
                              news: _news,
                              height: 50,
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
                          const SizedBox(height: 24),

                          // Yaklaşan Etkinlikler
                          if (_upcomingEvents.isNotEmpty) ...[
                            Text(
                              'Yaklaşan Etkinlikler',
                              style: GoogleFonts.inter(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ).animate().fadeIn(delay: 500.ms, duration: 600.ms),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 220,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _upcomingEvents.length,
                                itemBuilder: (context, index) {
                                  final event = _upcomingEvents[index];
                                  return Container(
                                    width: 300,
                                    margin: const EdgeInsets.only(right: 16),
                                    child: Card(
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        side: BorderSide(
                                          color: Theme.of(context).colorScheme.outline,
                                          width: 1,
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          if (event.image != null)
                                            ClipRRect(
                                              borderRadius: const BorderRadius.vertical(
                                                top: Radius.circular(12),
                                              ),
                                              child: Image.network(
                                                event.image!,
                                                height: 120,
                                                width: double.infinity,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) {
                                                  return Container(
                                                    height: 120,
                                                    decoration: BoxDecoration(
                                                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                                      borderRadius: const BorderRadius.vertical(
                                                        top: Radius.circular(12),
                                                      ),
                                                    ),
                                                    child: Icon(
                                                      Icons.event,
                                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                                      size: 40,
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  event.title,
                                                  style: GoogleFonts.inter(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Theme.of(context).colorScheme.onSurface,
                                                  ),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 8),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.location_on,
                                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                                      size: 16,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Expanded(
                                                      child: Text(
                                                        event.location,
                                                        style: GoogleFonts.inter(
                                                          fontSize: 14,
                                                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.calendar_today,
                                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                                      size: 16,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      '${event.startDate.day}/${event.startDate.month}/${event.startDate.year}',
                                                      style: GoogleFonts.inter(
                                                        fontSize: 12,
                                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ).animate().fadeIn(delay: (700 + index * 100).ms, duration: 600.ms).slideX(begin: 0.3);
                                },
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],

                          // Duyurular
                          if (_announcements.isNotEmpty) ...[
                            Text(
                              'Duyurular',
                              style: GoogleFonts.inter(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ).animate().fadeIn(delay: 900.ms, duration: 600.ms),
                            const SizedBox(height: 12),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _announcements.length,
                              itemBuilder: (context, index) {
                                final announcement = _announcements[index];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
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
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.announcement,
                                                color: Theme.of(context).colorScheme.primary,
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  announcement.title,
                                                  style: GoogleFonts.inter(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Theme.of(context).colorScheme.onSurface,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            announcement.content,
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                                            ),
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            '${announcement.publishDate.day}/${announcement.publishDate.month}/${announcement.publishDate.year}',
                                            style: GoogleFonts.inter(
                                              fontSize: 12,
                                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ).animate().fadeIn(delay: (1100 + index * 100).ms, duration: 600.ms).slideY(begin: 0.3);
                              },
                            ),
                          ],

                          // Reklam alanı
                          AdvertisementWidget(
                            height: 120,
                          ).animate().fadeIn(delay: 1500.ms, duration: 600.ms).scale(begin: const Offset(0.8, 0.8)),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: Theme.of(context).colorScheme.outline,
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
            if (index == 1) {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ForumScreen()),
              );
            }
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Ana Sayfa',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.forum),
              label: 'Forum',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.event),
              label: 'Etkinlikler',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications),
              label: 'Bildirimler',
            ),
          ],
        ),
      ),
    );
  }
} 