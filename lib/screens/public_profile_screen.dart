import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../utils/responsive_utils.dart';
import 'dart:convert';
import '../screens/chat_screen.dart'; // Added import for ChatScreen
import '../widgets/colored_username.dart';

class PublicProfileScreen extends StatefulWidget {
  final String username;
  
  const PublicProfileScreen({super.key, required this.username});

  @override
  State<PublicProfileScreen> createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends State<PublicProfileScreen> {
  User? _user;
  bool _isLoading = true;
  bool _isFollowing = false;
  int _followersCount = 0;
  int _followingCount = 0;
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _getCurrentUserId();
  }

  Future<void> _getCurrentUserId() async {
    try {
      final response = await ApiService.get('/users/profile/');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _currentUserId = data['id'];
        });
      }
    } catch (e) {
      print('Kullanıcı ID alınamadı: $e');
    }
  }

  Future<void> _loadProfile() async {
    try {
      final data = await ApiService.getPublicProfile(widget.username);
      setState(() {
        _user = User.fromJson(data);
        _isFollowing = data['is_following'] ?? false;
        _followersCount = data['followers_count'] ?? 0;
        _followingCount = data['following_count'] ?? 0;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profil yüklenirken hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _toggleFollow() async {
    if (_user == null) return;

    try {
      final result = _isFollowing 
          ? await ApiService.unfollowUser(_user!.id)
          : await ApiService.followUser(_user!.id);
      
      setState(() {
        _isFollowing = !_isFollowing; // Toggle the state
        // Takipçi sayısını güncelle
        if (_isFollowing) {
          _followersCount++;
        } else {
          _followersCount = _followersCount > 0 ? _followersCount - 1 : 0;
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: _isFollowing ? Colors.green : Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('İşlem başarısız: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildUsernameText(String username, String? customColor) {
    if (customColor != null && customColor.isNotEmpty) {
      return Text(
        username,
        style: TextStyle(
          color: Color(int.parse(customColor.replaceAll('#', '0xFF'))),
          fontWeight: FontWeight.bold,
        ),
      );
    } else {
      return Text(
        username,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          title: Text('Profil', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
          backgroundColor: Theme.of(context).colorScheme.surface,
          foregroundColor: Theme.of(context).colorScheme.primary,
          elevation: 0,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_user == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          title: Text('Profil', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
          backgroundColor: Theme.of(context).colorScheme.surface,
          foregroundColor: Theme.of(context).colorScheme.primary,
          elevation: 0,
        ),
        body: Center(
          child: Text(
            'Kullanıcı bulunamadı',
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: ColoredUsername(text: _user!.username, colorHex: _user!.customUsernameColor),
        backgroundColor: isDark ? Colors.white : Colors.black,
        foregroundColor: isDark ? Colors.black : Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.black : Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            Center(
              child: Column(
                children: [
                  // Profile Picture
                  (_user!.profilePicture != null && _user!.profilePicture!.isNotEmpty)
                      ? CircleAvatar(
                          radius: 60,
                          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          backgroundImage: NetworkImage(_user!.profilePicture!),
                          child: null,
                        )
                      : CircleAvatar(
                          radius: 60,
                          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          child: Icon(
                            Icons.person,
                            size: 60,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                  const SizedBox(height: 16),
                  
                  // Name and Username
                  ColoredUsername(
                    text: _user!.fullName,
                    colorHex: _user!.customUsernameColor,
                    isPremium: _user!.isPremium,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ColoredUsername(
                    text: '@${_user!.username}',
                    colorHex: _user!.customUsernameColor,
                    isPremium: _user!.isPremium,
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Follow Button
                  if (_currentUserId != null && _user!.id != _currentUserId) // Don't show follow button for own profile
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _toggleFollow,
                          icon: Icon(_isFollowing ? Icons.person_remove : Icons.person_add),
                          label: Text(_isFollowing ? 'Takipten Çık' : 'Takip Et'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isFollowing 
                                ? Theme.of(context).colorScheme.error
                                : Theme.of(context).colorScheme.primary,
                            foregroundColor: _isFollowing 
                                ? Theme.of(context).colorScheme.onError
                                : Theme.of(context).colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatScreen(
                                  otherUser: _user!,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.message),
                          label: const Text('Mesaj'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.secondary,
                            foregroundColor: Theme.of(context).colorScheme.onSecondary,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Stats Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem('Takipçi', _followersCount),
                _buildStatItem('Takip', _followingCount),
                _buildStatItem('Üyelik', _user!.createdAt.year.toString()),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Bio Section
            if (_user!.bio != null && _user!.bio!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hakkında',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _user!.bio!,
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            
            // Badges Section
            if (_user!.isSecondhandSeller || _user!.isPremium)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rozetler',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (_user!.isSecondhandSeller)
                        _buildBadge('2. El Satıcı', Icons.store, Colors.orange),
                      if (_user!.isPremium)
                        _buildBadge('Premium', Icons.star, Colors.amber),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            
            // Social Media Section
            if (_hasSocialMedia())
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sosyal Medya',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildSocialMediaLinks(),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, dynamic value) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildBadge(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  bool _hasSocialMedia() {
    return _user!.instagram != null || 
           _user!.twitter != null || 
           _user!.facebook != null || 
           _user!.linkedin != null || 
           _user!.website != null;
  }

  Widget _buildSocialMediaLinks() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        if (_user!.instagram != null)
          _buildSocialLink('Instagram', Icons.camera_alt, Colors.purple, _user!.instagram!),
        if (_user!.twitter != null)
          _buildSocialLink('Twitter', Icons.flutter_dash, Colors.blue, _user!.twitter!),
        if (_user!.facebook != null)
          _buildSocialLink('Facebook', Icons.facebook, Colors.blue, _user!.facebook!),
        if (_user!.linkedin != null)
          _buildSocialLink('LinkedIn', Icons.work, Colors.blue, _user!.linkedin!),
        if (_user!.website != null)
          _buildSocialLink('Website', Icons.language, Colors.green, _user!.website!),
      ],
    );
  }

  Widget _buildSocialLink(String label, IconData icon, Color color, String url) {
    return InkWell(
      onTap: () {
        // TODO: Implement URL opening
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 