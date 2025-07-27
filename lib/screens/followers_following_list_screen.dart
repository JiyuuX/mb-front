import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../utils/responsive_utils.dart';
import 'public_profile_screen.dart';
import 'dart:convert';
import '../widgets/colored_username.dart';

class FollowersFollowingListScreen extends StatefulWidget {
  final String username;
  final bool showFollowers; // true: followers, false: following

  const FollowersFollowingListScreen({super.key, required this.username, required this.showFollowers});

  @override
  State<FollowersFollowingListScreen> createState() => _FollowersFollowingListScreenState();
}

class _FollowersFollowingListScreenState extends State<FollowersFollowingListScreen> {
  List<User> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() { _isLoading = true; });
    try {
      final List<Map<String, dynamic>> data = widget.showFollowers
        ? await ApiService.getUserFollowers(widget.username)
        : await ApiService.getUserFollowing(widget.username);
      setState(() {
        _users = data.map((e) => User.fromJson(e)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() { _isLoading = false; });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kullanıcılar yüklenemedi: $e')),
        );
      }
    }
  }

  Widget _buildUsernameText(String username, String? customColor) {
    return ColoredUsername(
      text: username,
      colorHex: customColor,
      isPremium: false, // Burada premium bilgisi yok
    );
  }

  Future<void> _followUser(User user) async {
    try {
      final response = await ApiService.post('/users/follow/', {
        'user_id': user.id,
        'action': user.isFollowing ? 'unfollow' : 'follow',
      });
      
      if (response.statusCode == 200) {
        setState(() {
          // Kullanıcının takip durumunu güncelle
          final index = _users.indexWhere((u) => u.id == user.id);
          if (index != -1) {
            _users[index] = User(
              id: user.id,
              username: user.username,
              email: user.email,
              firstName: user.firstName,
              lastName: user.lastName,
              isPremium: user.isPremium,
              isPremiumActive: user.isPremiumActive,
              emailVerified: user.emailVerified,
              profilePicture: user.profilePicture,
              bio: user.bio,
              phoneNumber: user.phoneNumber,
              customUsernameColor: user.customUsernameColor,
              cardNumber: user.cardNumber,
              cardIssuedAt: user.cardIssuedAt,
              canCreateThreads: user.canCreateThreads,
              isSecondhandSeller: user.isSecondhandSeller,
              instagram: user.instagram,
              twitter: user.twitter,
              facebook: user.facebook,
              linkedin: user.linkedin,
              website: user.website,
              followersCount: user.followersCount,
              followingCount: user.followingCount,
              isFollowing: !user.isFollowing, // Toggle follow status
              createdAt: user.createdAt,
              updatedAt: user.updatedAt,
              threadCount: user.threadCount,
              isBanned: user.isBanned,
              banReason: user.banReason,
              banUntil: user.banUntil,
            );
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Takip işlemi başarısız: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          widget.showFollowers ? 'Takipçiler' : 'Takip Edilenler',
          style: TextStyle(
            color: isDark ? Colors.black : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: isDark ? Colors.white : Colors.black,
        foregroundColor: isDark ? Colors.black : Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.black : Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _users.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        widget.showFollowers ? Icons.people_outline : Icons.person_add_outlined,
                        size: 64,
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.showFollowers ? 'Henüz takipçiniz yok' : 'Henüz kimseyi takip etmiyorsunuz',
                        style: TextStyle(
                          fontSize: 18,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _users.length,
                  itemBuilder: (context, index) {
                    final user = _users[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: CircleAvatar(
                          radius: 24,
                          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          backgroundImage: user.profilePicture != null
                               ? NetworkImage(user.profilePicture!)
                               : null,
                          onBackgroundImageError: (exception, stackTrace) {
                            // Handle image loading errors silently
                            print('Profile image loading error: $exception');
                          },
                          child: user.profilePicture == null
                              ? Text(
                                  user.username[0].toUpperCase(),
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                        ),
                        title: ColoredUsername(
                          text: user.username,
                          colorHex: user.customUsernameColor,
                          isPremium: user.isPremium,
                        ),
                        subtitle: user.fullName != user.username 
                            ? ColoredUsername(
                                text: user.fullName,
                                colorHex: user.customUsernameColor,
                                isPremium: user.isPremium,
                                fontSize: 14,
                              )
                            : null,
                        trailing: widget.showFollowers
                            ? ElevatedButton(
                                onPressed: () => _followUser(user),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: user.isFollowing
                                      ? Colors.grey
                                      : Theme.of(context).colorScheme.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: Text(
                                  user.isFollowing ? 'Takip Ediliyor' : 'Takip Et',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              )
                            : null,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => PublicProfileScreen(username: user.username),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
} 