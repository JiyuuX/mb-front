import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/event.dart';
import '../models/announcement.dart';
import '../models/user.dart';
import '../models/news.dart';
import '../models/message.dart';
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

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
    _loadUserProfile();
    _loadNews();
    _loadUnreadConversations();
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

  Future<void> _loadUnreadConversations() async {
    try {
      final data = await ApiService.getUserConversations();
      final conversations = data.map((e) => Conversation.fromJson(e)).toList();
      setState(() {
        _unreadConversations = conversations.where((c) => (c.unreadCount ?? 0) > 0).length;
      });
    } catch (e) {
      setState(() {
        _unreadConversations = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                                  constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
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
                          padding: ResponsiveUtils.getResponsiveEdgeInsets(context, baseValue: 8),
                          child: GestureDetector(
                            onTap: () async {
                              await Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) => const ProfileScreen()),
                              );
                              _loadUserProfile();
                            },
                            child: _buildModernProfileAvatar(context),
                          ),
                        ),
                      ],
                    ),

                    // Content
                    SliverPadding(
                      padding: ResponsiveUtils.getResponsiveEdgeInsets(context, baseValue: 16),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
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
                          
                          // Responsive Grid Layout
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            crossAxisSpacing: ResponsiveUtils.getResponsivePadding(context, basePadding: 16),
                            mainAxisSpacing: ResponsiveUtils.getResponsivePadding(context, basePadding: 16),
                            childAspectRatio: ResponsiveUtils.isSmallScreen(context) ? 0.8 : ResponsiveUtils.isMediumScreen(context) ? 1.0 : 1.3,
                            children: [
                              // 2. El Kıyafetler
                              _buildFeatureCard(
                                icon: Icons.shopping_bag,
                                title: '2. El\nKıyafetler',
                                subtitle: 'Alışveriş',
                                color: const Color(0xFF667eea),
                                onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) => const ProductCategoryScreen()),
                              );
                            },
                                delay: 600,
                              ),
                              
                              // Mağazam
                              _buildFeatureCard(
                                icon: Icons.store,
                                title: 'Mağazam',
                                subtitle: 'Satış',
                                color: Colors.orange,
                                onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) => const MyStoreScreen()),
                              );
                            },
                                delay: 700,
                              ),
                              
                              // Favorilerim
                              _buildFeatureCard(
                                icon: Icons.favorite,
                                title: 'Favorilerim',
                                subtitle: 'Beğenilenler',
                                color: Colors.red,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (context) => const FavoritesScreen()),
                                  );
                                },
                                delay: 800,
                              ),
                              
                              // Forum
                              _buildFeatureCard(
                                icon: Icons.forum,
                                title: 'Forum',
                                subtitle: 'Tartışma',
                                color: Colors.green,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (context) => const ForumScreen()),
                                  );
                                },
                                delay: 900,
                              ),
                            ],
                          ),
                          SizedBox(height: ResponsiveUtils.getResponsivePadding(context, basePadding: 32)),

                          // Yaklaşan Etkinlikler
                          if (_upcomingEvents.isNotEmpty) ...[
                            Row(
                              children: [
                            Text(
                              'Yaklaşan Etkinlikler',
                              style: GoogleFonts.inter(
                                fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 20),
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                                ),
                                const Spacer(),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(builder: (context) => const EventsScreen()),
                                    );
                                  },
                                  child: Text(
                                    'Tümünü Gör',
                                    style: GoogleFonts.inter(
                                      color: Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 14),
                                    ),
                                  ),
                                ),
                              ],
                            ).animate().fadeIn(delay: 1000.ms, duration: 600.ms),
                            SizedBox(height: ResponsiveUtils.getResponsivePadding(context, basePadding: 12)),
                            SizedBox(
                              height: ResponsiveUtils.getResponsiveCardHeight(context, baseHeight: 200),
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _upcomingEvents.length,
                                itemBuilder: (context, index) {
                                  final event = _upcomingEvents[index];
                                  return Container(
                                    width: ResponsiveUtils.getResponsiveImageSize(context, baseSize: 280),
                                    margin: ResponsiveUtils.getResponsiveEdgeInsets(context, baseValue: 0, right: 16),
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
                                                  padding: ResponsiveUtils.getResponsiveEdgeInsets(context, baseValue: 8),
                                                  decoration: BoxDecoration(
                                                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Icon(
                                                    Icons.event,
                                                    color: Theme.of(context).colorScheme.primary,
                                                    size: ResponsiveUtils.getResponsiveIconSize(context, baseSize: 20),
                                                  ),
                                                ),
                                                SizedBox(width: ResponsiveUtils.getResponsivePadding(context, basePadding: 12)),
                                                Expanded(
                                                  child: Text(
                                                  event.name,
                                                  style: GoogleFonts.inter(
                                                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 16),
                                                    fontWeight: FontWeight.bold,
                                                    color: Theme.of(context).colorScheme.onSurface,
                                                  ),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: ResponsiveUtils.getResponsivePadding(context, basePadding: 12)),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.location_on,
                                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                                      size: ResponsiveUtils.getResponsiveIconSize(context, baseSize: 16),
                                                    ),
                                                    SizedBox(width: ResponsiveUtils.getResponsivePadding(context, basePadding: 4)),
                                                    Expanded(
                                                      child: Text(
                                                        '${event.venue} (${event.cityDisplay})',
                                                        style: GoogleFonts.inter(
                                                          fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 14),
                                                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: ResponsiveUtils.getResponsivePadding(context, basePadding: 4)),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.calendar_today,
                                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                                      size: ResponsiveUtils.getResponsiveIconSize(context, baseSize: 16),
                                                    ),
                                                    SizedBox(width: ResponsiveUtils.getResponsivePadding(context, basePadding: 4)),
                                                    Text(
                                                      '${event.date} ${event.timeFormatted}',
                                                      style: GoogleFonts.inter(
                                                        fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 12),
                                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                      ),
                                    ),
                                  ).animate().fadeIn(delay: (1200 + index * 100).ms, duration: 600.ms).slideX(begin: 0.3);
                                },
                              ),
                            ),
                            SizedBox(height: ResponsiveUtils.getResponsivePadding(context, basePadding: 32)),
                          ],

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
            } else if (index == 2) {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const EventsScreen()),
              );
            } else if (index == 3) {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const TicketsScreen()),
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
              icon: Icon(Icons.confirmation_number),
              label: 'Biletlerim',
            ),
          ],
        ),
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
              backgroundImage: profilePicture != null ? NetworkImage(profilePicture) : null,
              child: profilePicture == null
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
} 