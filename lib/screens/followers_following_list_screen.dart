import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import 'public_profile_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.showFollowers ? 'Takipçiler' : 'Takip Edilenler'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _users.isEmpty
              ? Center(child: Text('Kullanıcı bulunamadı'))
              : ListView.separated(
                  itemCount: _users.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final user = _users[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: user.profilePicture != null ? NetworkImage(user.profilePicture!) : null,
                        child: user.profilePicture == null ? const Icon(Icons.person) : null,
                      ),
                      title: Text(user.username),
                      subtitle: user.fullName != user.username ? Text(user.fullName) : null,
                      onTap: () {
                        // Profiline git
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => PublicProfileScreen(username: user.username),
                        ));
                      },
                    );
                  },
                ),
    );
  }
} 