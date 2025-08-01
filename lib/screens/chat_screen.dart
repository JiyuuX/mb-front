import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/message.dart';
import '../services/api_service.dart';
import '../utils/responsive_utils.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../widgets/colored_username.dart';
import '../widgets/message_status_indicator.dart';

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
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  Timer? _statusUpdateTimer;
  
  // Scroll pozisyonunu korumak için
  bool _isLoadingOlderMessages = false;
  double _scrollPositionBeforeLoad = 0.0;
  int _oldMessagesCount = 0;

  @override
  void initState() {
    super.initState();
    _loadOrCreateConversation();
    _scrollController.addListener(_onScroll);
    _startStatusUpdateTimer();
  }

  void _onScroll() {
    // Sadece scroll up yapıldığında ve listenin başına yaklaşıldığında eski mesajları yükle
    if (_scrollController.position.pixels <= 100 && !_isLoadingOlderMessages && _hasMoreMessages) {
      _loadOlderMessages();
    }
  }

  @override
  void dispose() {
    _statusUpdateTimer?.cancel();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadOrCreateConversation() async {
    setState(() { _isLoading = true; });
    
    final response = await ApiService.post(
      '/chat/conversations/',
      {'user_id': widget.otherUser.id},
    );
    
    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = json.decode(response.body);
      _conversation = Conversation.fromJson(data);
      await _loadMessages();
      
      // Chat açıldığında conversation'ı okundu olarak işaretle
      if (_conversation != null) {
        await ApiService.markConversationRead(_conversation!.id);
      }
    }
    
    setState(() { _isLoading = false; });
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
            // Eski mesajları listenin başına ekle
            _messages.insertAll(0, newMessages);
            _currentPage++;
            _hasMoreMessages = decoded['next'] != null;
          } else {
            // İlk yükleme - en son mesajları göster
            _messages = newMessages;
            _currentPage = 1;
            _hasMoreMessages = decoded['next'] != null;
          }
          _isLoadingMore = false;
        });
        
        // İlk yüklemede mesaj durumlarını hemen güncelle ve scroll down yap
        if (!loadMore) {
          // Kısa bir gecikme ile mesaj durumlarını güncelle
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) {
              _markMessagesAsReadAndUpdateStatus();
            }
          });
          
          // Mesajlar yüklendikten sonra en alta scroll yap - daha güvenilir yöntem
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted && _scrollController.hasClients && _messages.isNotEmpty) {
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOut,
              );
            }
          });
          
          // Ek güvenlik için bir kez daha dene
          Future.delayed(const Duration(milliseconds: 800), () {
            if (mounted && _scrollController.hasClients && _messages.isNotEmpty) {
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          });
        }
      }
    } catch (e) {
      print('Error loading messages: $e');
      setState(() { _isLoadingMore = false; });
    }
  }

  // Mesajları okundu olarak işaretle ve durumları güncelle
  Future<void> _markMessagesAsReadAndUpdateStatus() async {
    if (_conversation == null || !mounted) return;
    
    try {
      print('Marking messages as read for conversation: ${_conversation!.id}');
      
      // Önce mesajları okundu olarak işaretle
      final markResponse = await ApiService.markMessagesAsRead(_conversation!.id);
      print('Mark messages as read response: ${markResponse.statusCode}');
      print('Mark response body: ${markResponse.body}');
      
      // Sonra güncel mesaj durumlarını al
      final response = await ApiService.get(
        '/chat/conversations/${_conversation!.id}/messages/?page=1&page_size=100'
      );
      
      if (response.statusCode == 200 && mounted) {
        final decoded = json.decode(response.body);
        final List<dynamic> data = decoded['results'] ?? decoded;
        final updatedMessages = data.map((e) => Message.fromJson(e)).toList();
        
        print('Updating ${_messages.length} messages with new statuses');
        
        // Mevcut mesajları güncelle
        setState(() {
          for (int i = 0; i < _messages.length; i++) {
            final updatedMessage = updatedMessages.firstWhere(
              (msg) => msg.id == _messages[i].id,
              orElse: () => _messages[i],
            );
            
            final oldStatus = _messages[i].status;
            _messages[i] = updatedMessage;
            
            if (oldStatus != _messages[i].status) {
              print('Updated message ${_messages[i].id} status: $oldStatus -> ${_messages[i].status}');
            }
          }
        });
        
        print('Message statuses updated successfully');
      }
    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }

  Future<void> _loadOlderMessages() async {
    if (_isLoadingOlderMessages || !_hasMoreMessages || _conversation == null) return;
    
    setState(() { 
      _isLoadingOlderMessages = true;
      _scrollPositionBeforeLoad = _scrollController.position.pixels;
      _oldMessagesCount = _messages.length;
    });
    
    try {
      final response = await ApiService.get(
        '/chat/conversations/${_conversation!.id}/messages/?page=${_currentPage + 1}&page_size=$_pageSize'
      );
      
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final List<dynamic> data = decoded['results'] ?? decoded;
        final olderMessages = data.map((e) => Message.fromJson(e)).toList();
        
        if (olderMessages.isNotEmpty) {
          setState(() {
            // Eski mesajları listenin başına ekle
            _messages.insertAll(0, olderMessages);
            _currentPage++;
            _hasMoreMessages = decoded['next'] != null;
          });
          
          // Scroll pozisyonunu koru
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              final newMessagesHeight = _messages.length - _oldMessagesCount;
              final scrollOffset = newMessagesHeight * 80.0; // Ortalama mesaj yüksekliği
              _scrollController.jumpTo(_scrollPositionBeforeLoad + scrollOffset);
            }
          });
        } else {
          setState(() {
            _hasMoreMessages = false;
          });
        }
      }
    } catch (e) {
      print('Error loading older messages: $e');
    } finally {
      setState(() { _isLoadingOlderMessages = false; });
    }
  }

  void _startStatusUpdateTimer() {
    _statusUpdateTimer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      if (mounted) {
        _updateMessageStatuses();
      }
    });
  }

  Future<void> _updateMessageStatuses() async {
    if (_conversation == null || !mounted) return;
    
    try {
      // Sadece mesaj durumlarını güncelle, okundu işaretleme yapma
      final response = await ApiService.get(
        '/chat/conversations/${_conversation!.id}/messages/?page=1&page_size=100'
      );
      
      if (response.statusCode == 200 && mounted) {
        final decoded = json.decode(response.body);
        final List<dynamic> data = decoded['results'] ?? decoded;
        final updatedMessages = data.map((e) => Message.fromJson(e)).toList();
        
        setState(() {
          for (int i = 0; i < _messages.length; i++) {
            final updatedMessage = updatedMessages.firstWhere(
              (msg) => msg.id == _messages[i].id,
              orElse: () => _messages[i],
            );
            
            final oldStatus = _messages[i].status;
            _messages[i] = updatedMessage;
            
            if (oldStatus != _messages[i].status) {
              print('Updated message ${_messages[i].id} status: $oldStatus -> ${_messages[i].status}');
            }
          }
        });
      }
    } catch (e) {
      print('Error updating message statuses: $e');
    }
  }

  Future<void> _retryMessage(Message message) async {
    print('Retrying message: ${message.text}');
    setState(() {
      final index = _messages.indexWhere((msg) => msg.id == message.id);
      if (index != -1) {
        _messages[index] = Message(
          id: message.id,
          conversationId: message.conversationId,
          sender: message.sender,
          text: message.text,
          mediaUrl: message.mediaUrl,
          isRead: message.isRead,
          status: 'sending',
          createdAt: message.createdAt,
          updatedAt: DateTime.now(),
        );
      }
    });
    
    await _sendMessage();
  }

  Future<void> _sendMessage() async {
    print('_sendMessage() called');
    if (_controller.text.trim().isEmpty || _conversation == null) {
      print('Message validation failed: text="${_controller.text.trim()}", conversation=${_conversation?.id}');
      return;
    }
    
    final messageText = _controller.text.trim();
    print('Sending message: "$messageText" to conversation: ${_conversation!.id}');
    
    final tempMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch,
      conversationId: _conversation!.id,
      sender: User(
        id: 0,
        username: 'me',
        email: '',
        firstName: 'Me',
        lastName: null,
        isPremium: false,
        isPremiumActive: false,
        emailVerified: false,
        canCreateThreads: false,
        isSecondhandSeller: false,
        followersCount: 0,
        followingCount: 0,
        isFollowing: false,
        isBanned: false,
        customUsernameColor: '#000000',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      text: messageText,
      isRead: false,
      status: 'sending',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    setState(() { 
      _sending = true;
      _controller.clear();
      _messages.add(tempMessage);
    });
    
    // Yeni mesaj gönderildiğinde en alta scroll yap
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
    
    try {
      final messageData = {'text': messageText};
      print('API call to: /chat/conversations/${_conversation!.id}/messages/');
      print('Message data: $messageData');
      final response = await ApiService.post(
        '/chat/conversations/${_conversation!.id}/messages/',
        messageData,
      );
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 201) {
        final newMessageData = json.decode(response.body);
        final newMessage = Message.fromJson(newMessageData);
        
        setState(() {
          final index = _messages.indexWhere((msg) => msg.id == tempMessage.id);
          if (index != -1) {
            _messages[index] = newMessage;
          }
        });
        
        print('Message sent successfully: ${newMessage.text}');
      } else {
        print('Failed to send message: ${response.statusCode}');
        print('Error response: ${response.body}');
        
        setState(() {
          final index = _messages.indexWhere((msg) => msg.id == tempMessage.id);
          if (index != -1) {
            _messages[index] = Message(
              id: tempMessage.id,
              conversationId: tempMessage.conversationId,
              sender: tempMessage.sender,
              text: tempMessage.text,
              isRead: tempMessage.isRead,
              status: 'failed',
              createdAt: tempMessage.createdAt,
              updatedAt: DateTime.now(),
            );
          }
        });
        
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
      
      setState(() {
        final index = _messages.indexWhere((msg) => msg.id == tempMessage.id);
        if (index != -1) {
          _messages[index] = Message(
            id: tempMessage.id,
            conversationId: tempMessage.conversationId,
            sender: tempMessage.sender,
            text: tempMessage.text,
            isRead: tempMessage.isRead,
            status: 'failed',
            createdAt: tempMessage.createdAt,
            updatedAt: DateTime.now(),
          );
        }
      });
      
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: ColoredUsername(
            text: widget.otherUser.fullName,
            colorHex: widget.otherUser.customUsernameColor,
            isPremium: widget.otherUser.isPremium,
            style: TextStyle(
              color: isDark ? Colors.black : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    
    // Chat açıldığında en alta scroll yap
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients && _messages.isNotEmpty) {
        // Eğer scroll pozisyonu en aşağıda değilse, en aşağıya git
        if (_scrollController.position.pixels < _scrollController.position.maxScrollExtent - 10) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      }
    });
    
    return Scaffold(
      appBar: AppBar(
        title: ColoredUsername(
          text: widget.otherUser.fullName,
          colorHex: widget.otherUser.customUsernameColor,
          isPremium: widget.otherUser.isPremium,
          style: TextStyle(
            color: isDark ? Colors.black : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length + (_isLoadingOlderMessages ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isLoadingOlderMessages && index == 0) {
                  return Container(
                    padding: ResponsiveUtils.getResponsiveEdgeInsets(context, baseValue: 16),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: isDark
                            ? const Color(0xFF3B82F6) // blue-500 for dark mode
                            : const Color(0xFF3B82F6), // blue-500 for light mode
                        strokeWidth: 2,
                      ),
                    ),
                  );
                }
                
                final actualIndex = _isLoadingOlderMessages ? index - 1 : index;
                if (actualIndex < 0 || actualIndex >= _messages.length) {
                  return const SizedBox.shrink();
                }
                
                final msg = _messages[actualIndex];
                final isMe = msg.sender.id != widget.otherUser.id;
                
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: ResponsiveUtils.getResponsiveEdgeInsets(context, baseValue: 8, vertical: 4),
                    padding: ResponsiveUtils.getResponsiveEdgeInsets(context, baseValue: 12),
                    decoration: BoxDecoration(
                      color: isMe
                          ? (isDark 
                              ? const Color(0xFF0F172A) // slate-900 for dark mode
                              : const Color(0xFF3B82F6)) // blue-500 for light mode
                          : (isDark
                              ? const Color(0xFF1E293B) // slate-800 for dark mode
                              : const Color(0xFFF8FAFC)), // slate-50 for light mode
                      borderRadius: BorderRadius.circular(16),
                      border: isMe 
                          ? null 
                          : Border.all(
                              color: isDark
                                  ? const Color(0xFF334155) // slate-700 for dark mode
                                  : const Color(0xFFE2E8F0), // slate-200 for light mode
                              width: 1,
                            ),
                      boxShadow: isMe
                          ? [
                              BoxShadow(
                                color: isDark
                                    ? const Color(0xFF0F172A).withOpacity(0.3)
                                    : const Color(0xFF3B82F6).withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : [
                              BoxShadow(
                                color: isDark
                                    ? Colors.black.withOpacity(0.1)
                                    : Colors.grey.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                    ),
                    child: Column(
                      crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        msg.text != null && msg.text!.isNotEmpty
                            ? Text(
                                msg.text!,
                                style: TextStyle(
                                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 14),
                                  color: isMe 
                                      ? Colors.white
                                      : (isDark 
                                          ? const Color(0xFFF1F5F9) // slate-100 for dark mode
                                          : const Color(0xFF1E293B)), // slate-800 for light mode
                                  height: 1.4,
                                ),
                              )
                            : msg.mediaUrl != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      msg.mediaUrl!,
                                      width: ResponsiveUtils.getResponsiveImageSize(context, baseSize: 200),
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Text(
                                    '[Medya]',
                                    style: TextStyle(
                                      color: isMe 
                                          ? Colors.white.withOpacity(0.8)
                                          : (isDark 
                                              ? const Color(0xFF94A3B8) // slate-400 for dark mode
                                              : const Color(0xFF64748B)), // slate-500 for light mode
                                    ),
                                  ),
                        const SizedBox(height: 4),
                        MessageStatusIndicator(
                          status: msg.status,
                          isMe: isMe,
                          onRetry: msg.status == 'failed' && isMe ? () => _retryMessage(msg) : null,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Container(
            padding: ResponsiveUtils.getResponsiveEdgeInsets(context, baseValue: 16),
            decoration: BoxDecoration(
              color: isDark 
                  ? const Color(0xFF0F172A) // slate-900 for dark mode
                  : Colors.white,
              border: Border(
                top: BorderSide(
                  color: isDark
                      ? const Color(0xFF334155) // slate-700 for dark mode
                      : const Color(0xFFE2E8F0), // slate-200 for light mode
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1E293B) // slate-800 for dark mode
                          : const Color(0xFFF8FAFC), // slate-50 for light mode
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF334155) // slate-700 for dark mode
                            : const Color(0xFFE2E8F0), // slate-200 for light mode
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      decoration: InputDecoration(
                        hintText: 'Mesaj yaz...',
                        hintStyle: TextStyle(
                          color: isDark
                              ? const Color(0xFF94A3B8) // slate-400 for dark mode
                              : const Color(0xFF64748B), // slate-500 for light mode
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      style: TextStyle(
                        color: isDark
                            ? const Color(0xFFF1F5F9) // slate-100 for dark mode
                            : const Color(0xFF1E293B), // slate-800 for light mode
                        fontSize: 14,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF3B82F6) // blue-500 for dark mode
                        : const Color(0xFF3B82F6), // blue-500 for light mode
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF3B82F6).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: _sending
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white.withOpacity(0.8),
                              ),
                            ),
                          )
                        : const Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                    onPressed: _sending ? null : _sendMessage,
                    style: IconButton.styleFrom(
                      padding: const EdgeInsets.all(12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 
