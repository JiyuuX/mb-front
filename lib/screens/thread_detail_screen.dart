import 'package:flutter/material.dart';
import '../models/thread.dart';
import '../models/post.dart';
import '../models/comment.dart';
import '../services/forum_service.dart';
import '../utils/app_theme.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../utils/responsive_utils.dart';
import 'public_profile_screen.dart';
import 'dart:convert';
import '../widgets/colored_username.dart';

class ThreadDetailScreen extends StatefulWidget {
  final Thread thread;

  const ThreadDetailScreen({super.key, required this.thread});

  @override
  State<ThreadDetailScreen> createState() => _ThreadDetailScreenState();
}

class _ThreadDetailScreenState extends State<ThreadDetailScreen> {
  List<Post> _posts = [];
  Map<int, List<Comment>> _comments = {};
  Map<int, bool> _commentsLoading = {};
  Map<int, bool> _hasMoreComments = {};
  Map<int, int> _commentPage = {};
  Map<int, bool> _commentsExpanded = {};
  bool _isLoading = true;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadPosts();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final response = await ApiService.get('/users/profile/');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _currentUser = User.fromJson(data);
        });
      }
    } catch (e) {
      // ignore
    }
  }

  Future<void> _loadComments(int postId) async {
    try {
      setState(() {
        _commentsLoading[postId] = true;
      });

      final result = await ForumService.getComments(postId, page: 1);
      if (result['success']) {
        setState(() {
          _comments[postId] = result['comments'];
          _commentsLoading[postId] = false;
          _hasMoreComments[postId] = result['hasNext'] ?? false;
          _commentPage[postId] = 1;
        });
      } else {
        setState(() {
          _commentsLoading[postId] = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _commentsLoading[postId] = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Yorumlar yüklenirken hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadMoreComments(int postId) async {
    try {
      final nextPage = (_commentPage[postId] ?? 1) + 1;
      
      setState(() {
        _commentsLoading[postId] = true;
      });

      final result = await ForumService.getComments(postId, page: nextPage);
      if (result['success']) {
        setState(() {
          _comments[postId] = [...(_comments[postId] ?? []), ...result['comments']];
          _commentsLoading[postId] = false;
          _hasMoreComments[postId] = result['hasNext'] ?? false;
          _commentPage[postId] = nextPage;
        });
      } else {
        setState(() {
          _commentsLoading[postId] = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _commentsLoading[postId] = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Yorumlar yüklenirken hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _toggleComments(int postId) async {
    setState(() {
      _commentsExpanded[postId] = !(_commentsExpanded[postId] ?? false);
    });

    if (_commentsExpanded[postId] == true && _comments[postId] == null) {
      await _loadComments(postId);
    }
  }

  Future<void> _loadPosts() async {
    try {
      final result = await ForumService.getPosts(widget.thread.id);
      if (result['success']) {
        setState(() {
          _posts = result['posts'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Post\'lar yüklenirken hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showCreatePostDialog() {
    final contentController = TextEditingController();

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final bgColor = Theme.of(context).colorScheme.surface;
        final primaryColor = Theme.of(context).colorScheme.primary;
        final onPrimary = Theme.of(context).colorScheme.onPrimary;
        final inputFill = isDark ? AppTheme.darkInput : AppTheme.lightInput;
        final inputBorder = isDark ? AppTheme.darkBorder : AppTheme.lightBorder;
        final destructive = Colors.red;
        
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: bgColor,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Yeni Post Ekle',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(Icons.close, color: Theme.of(context).colorScheme.onSurface),
                      splashRadius: 20,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: contentController,
                  decoration: InputDecoration(
                    labelText: 'Post içeriğinizi yazın...',
                    filled: true,
                    fillColor: inputFill,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: inputBorder, width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: inputBorder, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: primaryColor, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  ),
                  maxLines: 6,
                  style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: destructive,
                          side: BorderSide(color: destructive, width: 1),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('İptal'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: onPrimary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () async {
                          if (contentController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Post içeriği gereklidir.'),
                                backgroundColor: destructive,
                              ),
                            );
                            return;
                          }
                          final scaffoldMessenger = ScaffoldMessenger.of(context);
                          Navigator.of(context).pop();
                          setState(() {
                            _isLoading = true;
                          });
                          final result = await ForumService.createPost(
                            widget.thread.id,
                            contentController.text.trim(),
                          );
                          if (result['success']) {
                            if (mounted) {
                              scaffoldMessenger.showSnackBar(
                                SnackBar(
                                  content: Text(result['message']),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              await _loadPosts();
                            }
                          } else {
                            if (mounted) {
                              scaffoldMessenger.showSnackBar(
                                SnackBar(
                                  content: Text(result['message']),
                                  backgroundColor: destructive,
                                ),
                              );
                              setState(() {
                                _isLoading = false;
                              });
                            }
                          }
                        },
                        child: const Text('Ekle', style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCreateCommentDialog(int postId) {
    final contentController = TextEditingController();

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final bgColor = Theme.of(context).colorScheme.surface;
        final primaryColor = Theme.of(context).colorScheme.primary;
        final onPrimary = Theme.of(context).colorScheme.onPrimary;
        final inputFill = isDark ? AppTheme.darkInput : AppTheme.lightInput;
        final inputBorder = isDark ? AppTheme.darkBorder : AppTheme.lightBorder;
        final destructive = Colors.red;
        
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: bgColor,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Yorum Ekle',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(Icons.close, color: Theme.of(context).colorScheme.onSurface),
                      splashRadius: 20,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: contentController,
                  decoration: InputDecoration(
                    labelText: 'Yorumunuzu yazın...',
                    filled: true,
                    fillColor: inputFill,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: inputBorder, width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: inputBorder, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: primaryColor, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  maxLines: 3,
                  style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.onSurface),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: destructive,
                          side: BorderSide(color: destructive, width: 1),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('İptal'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: onPrimary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () async {
                          if (contentController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Yorum içeriği gereklidir.'),
                                backgroundColor: destructive,
                              ),
                            );
                            return;
                          }
                          final scaffoldMessenger = ScaffoldMessenger.of(context);
                          Navigator.of(context).pop();
                          setState(() {
                            _commentsLoading[postId] = true;
                          });
                          final result = await ForumService.createComment(
                            postId,
                            contentController.text.trim(),
                          );
                          if (result['success']) {
                            if (mounted) {
                              scaffoldMessenger.showSnackBar(
                                SnackBar(
                                  content: Text(result['message']),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              await _loadPosts();
                              await _loadComments(postId);
                            }
                          } else {
                            if (mounted) {
                              scaffoldMessenger.showSnackBar(
                                SnackBar(
                                  content: Text(result['message']),
                                  backgroundColor: destructive,
                                ),
                              );
                              setState(() {
                                _commentsLoading[postId] = false;
                              });
                            }
                          }
                        },
                        child: const Text('Ekle', style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _categoryLabel(String value) {
    switch (value) {
      case 'muzik':
        return 'Müzik';
      case 'oyun':
        return 'Oyun';
      case 'film':
        return 'Film';
      case 'spor':
        return 'Spor';
      case 'teknoloji':
        return 'Teknoloji';
      case 'edebiyat':
        return 'Edebiyat';
      case 'bilim':
        return 'Bilim';
      case 'diger':
        return 'Diğer';
      default:
        return 'Genel';
    }
  }

  // 1. Report kategorileri sabiti ekle (dosya başına):
  final List<Map<String, String>> reportCategories = [
    {'value': 'spam', 'label': 'Spam'},
    {'value': 'abuse', 'label': 'Hakaret/İftira'},
    {'value': 'misinfo', 'label': 'Yanlış Bilgi'},
    {'value': 'offtopic', 'label': 'Konu Dışı'},
    {'value': 'other', 'label': 'Diğer'},
  ];

  // 2. Thread header Container'ında Row'a report butonunu ekle:
  void _showReportThreadDialog() {
    String selectedCategory = reportCategories[0]['value']!;
    final reasonController = TextEditingController();
    final destructive = Theme.of(context).brightness == Brightness.dark ? AppTheme.darkDestructive : AppTheme.lightDestructive;
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            backgroundColor: Theme.of(context).colorScheme.surface,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('Thread Raporla', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                      const Spacer(),
                      IconButton(
                        icon: Icon(Icons.close, color: Theme.of(context).colorScheme.onSurface),
                        splashRadius: 20,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text('Rapor Kategorisi', style: TextStyle(fontWeight: FontWeight.w500)),
                  ...reportCategories.map((cat) => RadioListTile<String>(
                    value: cat['value']!,
                    groupValue: selectedCategory,
                    onChanged: (val) => setState(() => selectedCategory = val!),
                    title: Text(cat['label']!),
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  )),
                  const SizedBox(height: 8),
                  TextField(
                    controller: reasonController,
                    decoration: InputDecoration(
                      labelText: 'Açıklama (isteğe bağlı)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    minLines: 1,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: destructive,
                            side: BorderSide(color: destructive, width: 1),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('İptal'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Theme.of(context).colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () async {
                            final scaffoldMessenger = ScaffoldMessenger.of(context);
                            Navigator.of(context).pop();
                            final result = await ForumService.reportThread(
                              widget.thread.id,
                              selectedCategory,
                              reasonController.text.trim(),
                            );
                            scaffoldMessenger.showSnackBar(
                              SnackBar(
                                content: Text(result['message'] ?? 'Rapor gönderildi.'),
                                backgroundColor: result['success'] ? Colors.green : destructive,
                              ),
                            );
                          },
                          child: const Text('Gönder', style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Thread Detayı',
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
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(context).colorScheme.outline,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.thread.title,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _categoryLabel(widget.thread.category),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              Icon(
                                Icons.favorite,
                                color: widget.thread.isLiked ? Colors.red : Colors.grey,
                                size: 18,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.thread.likesCount.toString(),
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(width: 12),
                              IconButton(
                                icon: Icon(Icons.flag, color: Theme.of(context).colorScheme.primary.withOpacity(0.7)),
                                tooltip: 'Raporla',
                                onPressed: _showReportThreadDialog,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              final username = widget.thread.creator.username;
                              if (username.isNotEmpty) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => PublicProfileScreen(username: username),
                                  ),
                                );
                              }
                            },
                            child: ColoredUsername(
                              text: widget.thread.creator.username,
                              colorHex: widget.thread.creator.customUsernameColor,
                              isPremium: widget.thread.creator.isPremium,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${widget.thread.createdAt.day}/${widget.thread.createdAt.month}/${widget.thread.createdAt.year}',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Flexible(
                  child: RefreshIndicator(
                    onRefresh: _loadPosts,
                    child: _posts.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.chat_bubble_outline,
                                  size: 80,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Henüz post bulunmuyor',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'İlk post\'u sen ekle!',
                                  style: TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _posts.length,
                            itemBuilder: (context, index) {
                              final post = _posts[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: ResponsiveUtils.getResponsiveEdgeInsets(context, baseValue: 16),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 16,
                                            backgroundColor: Colors.grey[300],
                                            backgroundImage: post.author.profilePicture != null
                                                ? NetworkImage(post.author.profilePicture!)
                                                : null,
                                            child: post.author.profilePicture == null
                                                ? Text(
                                                    (post.author.username.isNotEmpty ? post.author.username[0] : 'A').toUpperCase(),
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  )
                                                : null,
                                          ),
                                          const SizedBox(width: 12),
                                          Flexible(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () {
                                                        final username = post.author.username;
                                                        if (username.isNotEmpty) {
                                                          Navigator.of(context).push(
                                                            MaterialPageRoute(
                                                              builder: (context) => PublicProfileScreen(username: username),
                                                            ),
                                                          );
                                                        }
                                                      },
                                                      child: ColoredUsername(
                                                        text: post.author.username,
                                                        colorHex: post.author.customUsernameColor,
                                                        isPremium: post.author.isPremium,
                                                      ),
                                                    ),
                                                    if (post.author.isPremium) ...[
                                                      const SizedBox(width: 4),
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(
                                                          horizontal: 4,
                                                          vertical: 2,
                                                        ),
                                                        decoration: BoxDecoration(
                                                          color: Colors.amber,
                                                          borderRadius: BorderRadius.circular(4),
                                                        ),
                                                        child: const Text(
                                                          'PREMIUM',
                                                          style: TextStyle(
                                                            fontSize: 8,
                                                            color: Colors.white,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                                Text(
                                                  _formatDate(post.createdAt),
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (post.isEdited)
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 6,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.grey[300],
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: const Text(
                                                'Düzenlendi',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        post.content,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          height: 1.5,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          IconButton(
                                            onPressed: () {
                                              _toggleComments(post.id);
                                            },
                                            icon: Icon(
                                              _commentsExpanded[post.id] == true ? Icons.expand_less : Icons.expand_more,
                                              size: 20,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '${post.commentCount} yorum',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          const Spacer(),
                                          IconButton(
                                            onPressed: () {
                                              _showCreateCommentDialog(post.id);
                                            },
                                            icon: const Icon(Icons.add_comment_outlined),
                                            iconSize: 20,
                                            tooltip: 'Yorum ekle',
                                          ),
                                        ],
                                      ),
                                      if (_commentsExpanded[post.id] == true && _comments[post.id] != null && _comments[post.id]!.isNotEmpty) ...[
                                        const SizedBox(height: 12),
                                        const Divider(),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Yorumlar',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        ...(_comments[post.id]!.map((comment) => Container(
                                          margin: const EdgeInsets.only(bottom: 8),
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).brightness == Brightness.dark
                                                ? AppTheme.darkCard
                                                : AppTheme.lightCard,
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(
                                              color: Theme.of(context).brightness == Brightness.dark
                                                  ? AppTheme.darkBorder
                                                  : AppTheme.lightBorder,
                                              width: 1,
                                            ),
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  CircleAvatar(
                                                    radius: 12,
                                                    backgroundColor: Theme.of(context).brightness == Brightness.dark
                                                        ? AppTheme.darkAccent
                                                        : AppTheme.lightAccent,
                                                    backgroundImage: comment.author.profilePicture != null
                                                        ? NetworkImage(comment.author.profilePicture!)
                                                        : null,
                                                    child: comment.author.profilePicture == null
                                                        ? Text(
                                                            (comment.author.username.isNotEmpty ? comment.author.username[0] : 'A').toUpperCase(),
                                                            style: const TextStyle(
                                                              fontSize: 10,
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          )
                                                        : null,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Flexible(
                                                    child: Column(
                                                      mainAxisSize: MainAxisSize.min,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            GestureDetector(
                                                              onTap: () {
                                                                final username = comment.author.username;
                                                                if (username.isNotEmpty) {
                                                                  Navigator.of(context).push(
                                                                    MaterialPageRoute(
                                                                      builder: (context) => PublicProfileScreen(username: username),
                                                                    ),
                                                                  );
                                                                }
                                                              },
                                                              child: ColoredUsername(
                                                                text: comment.author.username,
                                                                colorHex: comment.author.customUsernameColor,
                                                                isPremium: comment.author.isPremium,
                                                              ),
                                                            ),
                                                            if (comment.author.isPremium) ...[
                                                              const SizedBox(width: 4),
                                                              Container(
                                                                padding: const EdgeInsets.symmetric(
                                                                  horizontal: 3,
                                                                  vertical: 1,
                                                                ),
                                                                decoration: BoxDecoration(
                                                                  color: Colors.amber,
                                                                  borderRadius: BorderRadius.circular(3),
                                                                ),
                                                                child: const Text(
                                                                  'PREMIUM',
                                                                  style: TextStyle(
                                                                    fontSize: 7,
                                                                    color: Colors.white,
                                                                    fontWeight: FontWeight.bold,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ],
                                                        ),
                                                        Text(
                                                          _formatDate(comment.createdAt),
                                                          style: TextStyle(
                                                            fontSize: 10,
                                                            color: Colors.grey[600],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  if (comment.isEdited)
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(
                                                        horizontal: 4,
                                                        vertical: 1,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: Theme.of(context).brightness == Brightness.dark
                                                            ? AppTheme.darkMuted
                                                            : AppTheme.lightMuted,
                                                        borderRadius: BorderRadius.circular(4),
                                                      ),
                                                      child: const Text(
                                                        'Düzenlendi',
                                                        style: TextStyle(
                                                          fontSize: 8,
                                                          color: Colors.white70,
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                comment.content,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  height: 1.4,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  GestureDetector(
                                                    onTap: () {
                                                      final username = comment.author.username;
                                                      if (username.isNotEmpty) {
                                                        Navigator.of(context).push(
                                                          MaterialPageRoute(
                                                            builder: (context) => PublicProfileScreen(username: username),
                                                          ),
                                                        );
                                                      }
                                                    },
                                                    child: ColoredUsername(
                                                      text: comment.author.username,
                                                      colorHex: comment.author.customUsernameColor,
                                                      isPremium: comment.author.isPremium,
                                                    ),
                                                  ),
                                                  if (comment.author.id != null && _currentUser?.id != null && comment.author.id != _currentUser!.id) ...[
                                                    const Spacer(),
                                                    IconButton(
                                                      icon: Icon(Icons.flag, color: Theme.of(context).colorScheme.primary.withOpacity(0.7)),
                                                      tooltip: 'Yorumu Raporla',
                                                      onPressed: () => _showReportCommentDialog(comment),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ],
                                          ),
                                        )).toList()),
                                      ],
                                      if (_hasMoreComments[post.id] == true) ...[
                                        const SizedBox(height: 8),
                                        Center(
                                          child: TextButton(
                                            onPressed: _commentsLoading[post.id] == true 
                                                ? null 
                                                : () => _loadMoreComments(post.id),
                                            child: _commentsLoading[post.id] == true
                                                ? const SizedBox(
                                                    width: 16,
                                                    height: 16,
                                                    child: CircularProgressIndicator(strokeWidth: 2),
                                                  )
                                                : Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      const Icon(Icons.expand_more, size: 16),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        'Daha fazla yorum göster',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.blue[600],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                          ),
                                        ),
                                      ],
                                      if (_commentsLoading[post.id] == true) ...[
                                        const SizedBox(height: 12),
                                        const Divider(),
                                        const SizedBox(height: 8),
                                        const Center(
                                          child: SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(strokeWidth: 2),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
      floatingActionButton: Builder(
        builder: (context) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return FloatingActionButton(
            onPressed: _showCreatePostDialog,
            backgroundColor: isDark ? Colors.white : Theme.of(context).colorScheme.primary,
            child: Icon(Icons.add, color: isDark ? Colors.black : Colors.white),
            elevation: 2,
            tooltip: 'Yeni Post',
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  // 3. _showReportCommentDialog fonksiyonunu ekle:
  void _showReportCommentDialog(Comment comment) {
    String selectedCategory = reportCategories[0]['value']!;
    final reasonController = TextEditingController();
    final destructive = Theme.of(context).brightness == Brightness.dark ? AppTheme.darkDestructive : AppTheme.lightDestructive;
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            backgroundColor: Theme.of(context).colorScheme.surface,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('Yorumu Raporla', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                      const Spacer(),
                      IconButton(
                        icon: Icon(Icons.close, color: Theme.of(context).colorScheme.onSurface),
                        splashRadius: 20,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text('Rapor Kategorisi', style: TextStyle(fontWeight: FontWeight.w500)),
                  ...reportCategories.map((cat) => RadioListTile<String>(
                    value: cat['value']!,
                    groupValue: selectedCategory,
                    onChanged: (val) => setState(() => selectedCategory = val!),
                    title: Text(cat['label']!),
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  )),
                  const SizedBox(height: 8),
                  TextField(
                    controller: reasonController,
                    decoration: InputDecoration(
                      labelText: 'Açıklama (isteğe bağlı)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    minLines: 1,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: destructive,
                            side: BorderSide(color: destructive, width: 1),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('İptal'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Theme.of(context).colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () async {
                            final scaffoldMessenger = ScaffoldMessenger.of(context);
                            Navigator.of(context).pop();
                            final result = await ForumService.reportComment(
                              comment.id,
                              selectedCategory,
                              reasonController.text.trim(),
                            );
                            scaffoldMessenger.showSnackBar(
                              SnackBar(
                                content: Text(result['message'] ?? 'Rapor gönderildi.'),
                                backgroundColor: result['success'] ? Colors.green : destructive,
                              ),
                            );
                          },
                          child: const Text('Gönder', style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // 4. _showReportPostDialog fonksiyonunu ekle:
  void _showReportPostDialog(Post post) {
    String selectedCategory = reportCategories[0]['value']!;
    final reasonController = TextEditingController();
    final destructive = Theme.of(context).brightness == Brightness.dark ? AppTheme.darkDestructive : AppTheme.lightDestructive;
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            backgroundColor: Theme.of(context).colorScheme.surface,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('Postu Raporla', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                      const Spacer(),
                      IconButton(
                        icon: Icon(Icons.close, color: Theme.of(context).colorScheme.onSurface),
                        splashRadius: 20,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text('Rapor Kategorisi', style: TextStyle(fontWeight: FontWeight.w500)),
                  ...reportCategories.map((cat) => RadioListTile<String>(
                    value: cat['value']!,
                    groupValue: selectedCategory,
                    onChanged: (val) => setState(() => selectedCategory = val!),
                    title: Text(cat['label']!),
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  )),
                  const SizedBox(height: 8),
                  TextField(
                    controller: reasonController,
                    decoration: InputDecoration(
                      labelText: 'Açıklama (isteğe bağlı)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    minLines: 1,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: destructive,
                            side: BorderSide(color: destructive, width: 1),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('İptal'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Theme.of(context).colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () async {
                            final scaffoldMessenger = ScaffoldMessenger.of(context);
                            Navigator.of(context).pop();
                            final result = await ForumService.reportPost(
                              post.id,
                              selectedCategory,
                              reasonController.text.trim(),
                            );
                            scaffoldMessenger.showSnackBar(
                              SnackBar(
                                content: Text(result['message'] ?? 'Rapor gönderildi.'),
                                backgroundColor: result['success'] ? Colors.green : destructive,
                              ),
                            );
                          },
                          child: const Text('Gönder', style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
} 