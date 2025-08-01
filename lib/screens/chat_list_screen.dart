import 'package:flutter/material.dart';
import '../models/message.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../utils/responsive_utils.dart';
import 'chat_screen.dart';
import 'dart:convert';
import '../widgets/colored_username.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  List<Conversation> _conversations = [];
  bool _isLoading = true;
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final response = await ApiService.get('/users/profile/');
      if (response.statusCode == 200) {
        final data = Map<String, dynamic>.from(await Future.value(
            response.body is String ? jsonDecode(response.body) : response.body));
        setState(() {
          _currentUserId = data['id'];
        });
      }
    } catch (e) {
      // ignore
    }
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    setState(() { _isLoading = true; });
    try {
      final data = await ApiService.getUserConversations();
      setState(() {
        _conversations = data.map((e) => Conversation.fromJson(e)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() { _isLoading = false; });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sohbetler yüklenemedi: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sohbetler', style: TextStyle(
          fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 18)
        ))),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _conversations.isEmpty
              ? const Center(child: Text('Sohbet bulunamadı'))
              : ListView.separated(
                  itemCount: _conversations.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final conv = _conversations[index];
                    // Find the other user (not the current user)
                    final otherUser = conv.participants.firstWhere(
                      (u) => u.id != _currentUserId,
                      orElse: () => conv.participants.first,
                    );
                    return ListTile(
                      leading: (otherUser.profilePicture != null && otherUser.profilePicture!.isNotEmpty)
                          ? CircleAvatar(
                              backgroundImage: NetworkImage(otherUser.profilePicture!),
                              onBackgroundImageError: (exception, stackTrace) {
                                // Handle image loading errors silently
                                print('Profile image loading error: $exception');
                              },
                              child: null,
                            )
                          : CircleAvatar(
                              child: const Icon(Icons.person),
                            ),
                      title: ColoredUsername(
                        text: otherUser.fullName,
                        colorHex: otherUser.customUsernameColor,
                        isPremium: otherUser.isPremium,
                      ),
                      subtitle: conv.lastMessage != null
                          ? Text(
                              conv.lastMessage!.text ?? '[Medya]',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )
                          : const Text('Henüz mesaj yok'),
                      trailing: (conv.unreadCount ?? 0) > 0
                          ? Container(
                              padding: ResponsiveUtils.getResponsiveEdgeInsets(context, baseValue: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                conv.unreadCount.toString(),
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            )
                          : null,
                      onTap: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(otherUser: otherUser),
                          ),
                        );
                        _loadConversations();
                      },
                    );
                  },
                ),
    );
  }
}