import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/message.dart';
import '../services/api_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';

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
  final TextEditingController _controller = TextEditingController();
  bool _sending = false;
  bool _showEmojiPicker = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadOrCreateConversation();
  }

  @override
  void dispose() {
    _focusNode.dispose();
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
  }

  Future<void> _loadMessages() async {
    if (_conversation == null) return;
    final response = await ApiService.get('/chat/conversations/${_conversation!.id}/messages/');
    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final List<dynamic> data = decoded is List ? decoded : decoded['results'] ?? decoded;
      setState(() {
        _messages = data.map((e) => Message.fromJson(e)).toList();
      });
    }
  }

  Future<void> _sendMessage() async {
    if (_controller.text.trim().isEmpty || _conversation == null) return;
    setState(() { _sending = true; });
    final messageData = {'text': _controller.text.trim()};
    final response = await ApiService.post(
      '/chat/conversations/${_conversation!.id}/messages/',
      messageData,
    );
    if (response.statusCode == 201) {
      _controller.clear();
      await _loadMessages();
    }
    setState(() { _sending = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.otherUser.fullName),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    reverse: true,
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[_messages.length - 1 - index];
                      final isMe = msg.sender.id != widget.otherUser.id;
                      return Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isMe
                                ? Theme.of(context).colorScheme.primary.withOpacity(0.15)
                                : Theme.of(context).colorScheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: msg.text != null && msg.text!.isNotEmpty
                              ? Text(msg.text!)
                              : msg.mediaUrl != null
                                  ? Image.network(msg.mediaUrl!)
                                  : const Text('[Medya]'),
                        ),
                      );
                    },
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(_showEmojiPicker ? Icons.keyboard : Icons.emoji_emotions),
                        onPressed: () {
                          setState(() {
                            _showEmojiPicker = !_showEmojiPicker;
                          });
                          if (_showEmojiPicker) {
                            _focusNode.unfocus();
                          }
                        },
                      ),
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
                if (_showEmojiPicker)
                  SizedBox(
                    height: 250,
                    child: EmojiPicker(
                      onEmojiSelected: (category, emoji) {
                        _controller.text += emoji.emoji;
                      },
                    ),
                  ),
              ],
            ),
    );
  }
} 