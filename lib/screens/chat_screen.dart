import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/message.dart';
import '../services/api_service.dart';
import '../utils/responsive_utils.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatScreen extends StatefulWidget {
  final User otherUser;
  const ChatScreen({Key? key, required this.otherUser}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Message> _messages = [];
  Conversation? _conversation;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMoreMessages = true;
  int _currentPage = 1;
  final int _pageSize = 20;
  final TextEditingController _controller = TextEditingController();
  bool _sending = false;
  // bool _showEmojiPicker = false; // temporarily removed
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadOrCreateConversation();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    // Scroll up yapıldığında (listenin başına yaklaşıldığında) eski mesajları yükle
    if (_scrollController.position.pixels <= 200) {
      _loadMoreMessages();
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadOrCreateConversation() async {
    setState(() { _isLoading = true; });
    // Sohbeti başlat veya getir
    final response = await ApiService.post(
      '/chat/conversations/',
      {'user_id': widget.otherUser.id},
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = json.decode(response.body);
      _conversation = Conversation.fromJson(data);
      await _loadMessages();
      // Mark as read after loading messages
      if (_conversation != null) {
        await ApiService.markConversationRead(_conversation!.id);
      }
    }
    setState(() { _isLoading = false; });
    
    // Chat açıldıktan sonra en alta scroll yap
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients && _messages.isNotEmpty) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _loadMessages({bool loadMore = false}) async {
    if (_conversation == null) return;
    
    if (loadMore) {
      if (_isLoadingMore || !_hasMoreMessages) return;
      setState(() { _isLoadingMore = true; });
    }
    
    try {
      final response = await ApiService.get(
        '/chat/conversations/${_conversation!.id}/messages/?page=${loadMore ? _currentPage + 1 : 1}&page_size=$_pageSize'
      );
      
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final List<dynamic> data = decoded['results'] ?? decoded;
        final newMessages = data.map((e) => Message.fromJson(e)).toList();
        
        print('Loaded ${newMessages.length} messages, page: ${loadMore ? _currentPage + 1 : 1}');
        
        setState(() {
          if (loadMore) {
            // Eski mesajları listenin başına ekle (scroll up için)
            _messages.insertAll(0, newMessages);
            _currentPage++;
            // Backend'den gelen pagination bilgisine göre hasMore kontrolü
            _hasMoreMessages = decoded['next'] != null;
          } else {
            // İlk yükleme - en son 20 mesajı göster
            _messages = newMessages;
            _currentPage = 1;
            _hasMoreMessages = decoded['next'] != null;
          }
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      print('Error loading messages: $e');
      setState(() { _isLoadingMore = false; });
    }
  }

  Future<void> _loadMoreMessages() async {
    if (_isLoadingMore || !_hasMoreMessages) return;
    await _loadMessages(loadMore: true);
  }

  Future<void> _sendMessage() async {
    if (_controller.text.trim().isEmpty || _conversation == null) return;
    setState(() { _sending = true; });
    
    try {
      final messageData = {'text': _controller.text.trim()};
      final response = await ApiService.post(
        '/chat/conversations/${_conversation!.id}/messages/',
        messageData,
      );
      
      if (response.statusCode == 201) {
        final newMessageData = json.decode(response.body);
        final newMessage = Message.fromJson(newMessageData);
        
        setState(() {
          _controller.clear();
          // Yeni mesajı listenin sonuna ekle
          _messages.add(newMessage);
        });
        
        // Yeni mesaj eklendikten sonra en alta scroll yap
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
        
        print('Message sent successfully: ${newMessage.text}');
      } else {
        print('Failed to send message: ${response.statusCode}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Mesaj gönderilemedi'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Error sending message: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Mesaj gönderilemedi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() { _sending = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.otherUser.fullName, style: TextStyle(
          fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 18)
        )),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: _messages.length + (_isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (_isLoadingMore && index == _messages.length) {
                        return Container(
                          padding: ResponsiveUtils.getResponsiveEdgeInsets(context, baseValue: 16),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Theme.of(context).colorScheme.primary,
                              strokeWidth: 2,
                            ),
                          ),
                        );
                      }
                      
                      final msg = _messages[index];
                      final isMe = msg.sender.id != widget.otherUser.id;
                      
                      return Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: ResponsiveUtils.getResponsiveEdgeInsets(context, baseValue: 8, vertical: 4),
                          padding: ResponsiveUtils.getResponsiveEdgeInsets(context, baseValue: 12),
                          decoration: BoxDecoration(
                            color: isMe
                                ? Theme.of(context).colorScheme.primary.withOpacity(0.15)
                                : Theme.of(context).colorScheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: msg.text != null && msg.text!.isNotEmpty
                              ? Text(
                                  msg.text!,
                                  style: TextStyle(
                                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 14),
                                  ),
                                )
                              : msg.mediaUrl != null
                                  ? Image.network(
                                      msg.mediaUrl!,
                                      width: ResponsiveUtils.getResponsiveImageSize(context, baseSize: 200),
                                      fit: BoxFit.cover,
                                    )
                                  : const Text('[Medya]'),
                        ),
                      );
                    },
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: ResponsiveUtils.getResponsiveEdgeInsets(context, baseValue: 8),
                  child: Row(
                    children: [
                      // Emoji button temporarily removed
                      // IconButton(
                      //   icon: Icon(_showEmojiPicker ? Icons.keyboard : Icons.emoji_emotions),
                      //   onPressed: () {
                      //     setState(() {
                      //       _showEmojiPicker = !_showEmojiPicker;
                      //     });
                      //     if (_showEmojiPicker) {
                      //       _focusNode.unfocus();
                      //     }
                      //   },
                      // ),
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          focusNode: _focusNode,
                          decoration: const InputDecoration(
                            hintText: 'Mesaj yaz...',
                            border: InputBorder.none,
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      IconButton(
                        icon: _sending
                            ? const CircularProgressIndicator()
                            : const Icon(Icons.send),
                        onPressed: _sending ? null : _sendMessage,
                      ),
                    ],
                  ),
                ),
                // Emoji picker temporarily removed
                // if (_showEmojiPicker)
                //   SizedBox(
                //     height: 250,
                //     child: EmojiPicker(
                //       onEmojiSelected: (category, emoji) {
                //         _controller.text += emoji.emoji;
                //       },
                //     ),
                //   ),
              ],
            ),
    );
  }
} 