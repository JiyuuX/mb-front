import 'package:flutter/material.dart';
import '../models/thread.dart';
import '../models/post.dart';
import '../models/comment.dart';
import '../services/forum_service.dart';
import '../utils/app_theme.dart'; // Correct import for AppColors and AppTheme
import '../models/user.dart';
import '../services/api_service.dart';
import '../utils/responsive_utils.dart';
import 'public_profile_screen.dart';
import 'dart:convert';

class ThreadDetailScreen extends StatefulWidget {
  final Thread thread;

  const ThreadDetailScreen({super.key, required this.thread});

  @override
  State<ThreadDetailScreen> createState() => _ThreadDetailScreenState();
}

class _ThreadDetailScreenState extends State<ThreadDetailScreen> {
  List<Post> _posts = [];
  Map<int, List<Comment>> _comments = {}; // postId -> comments
  Map<int, bool> _commentsLoading = {}; // postId -> loading state
  Map<int, bool> _hasMoreComments = {}; // postId -> has more comments
  Map<int, int> _commentPage = {}; // postId -> current page
  Map<int, bool> _commentsExpanded = {}; // postId -> comments expanded state
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPosts();
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

    // Eğer yorumlar açılıyorsa ve henüz yüklenmemişse yükle
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
        
        // Yorumları başlangıçta yükleme - sadece açıldığında yüklenecek
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
        final borderColor = Theme.of(context).colorScheme.outline;
        final bgColor = Theme.of(context).colorScheme.surface;
        final primaryColor = Theme.of(context).colorScheme.primary;
        final onPrimary = Theme.of(context).colorScheme.onPrimary;
        final inputFill = isDark ? AppTheme.darkInput : AppTheme.lightInput;
        final inputBorder = isDark ? AppTheme.darkBorder : AppTheme.lightBorder;
        final destructive = isDark ? AppTheme.darkDestructive : AppTheme.lightDestructive;
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: bgColor,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
          mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                // Navbar-style başlık ve kapatma
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
                // shadcn-style geniş input
            TextField(
              controller: contentController,
                  decoration: InputDecoration(
                    labelText: 'Post içeriğinizi yazın...'
                        ,
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
        final borderColor = Theme.of(context).colorScheme.outline;
        final bgColor = Theme.of(context).colorScheme.surface;
        final primaryColor = Theme.of(context).colorScheme.primary;
        final onPrimary = Theme.of(context).colorScheme.onPrimary;
        final inputFill = isDark ? AppTheme.darkInput : AppTheme.lightInput;
        final inputBorder = isDark ? AppTheme.darkBorder : AppTheme.lightBorder;
        final destructive = isDark ? AppTheme.darkDestructive : AppTheme.lightDestructive;
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: bgColor,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
          mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                // Navbar-style başlık ve kapatma
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
                // shadcn-style input
            TextField(
              controller: contentController,
                  decoration: InputDecoration(
                    labelText: 'Yorumunuzu yazın...'
                        ,
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
                              await _loadComments(postId); // Yorumlar anında güncellensin
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

  @override
  Widget build(BuildContext context) {
    Thread thread = widget.thread;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          thread.title,
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
            fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 18),
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.primary),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _showCreatePostDialog,
            icon: Icon(Icons.add, color: Theme.of(context).colorScheme.primary),
            tooltip: 'Yeni Post',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: ResponsiveUtils.getResponsiveEdgeInsets(context, baseValue: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _categoryLabel(thread.category),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () async {
                          final result = await ForumService.toggleThreadLike(thread.id);
                          if (result['success']) {
                            setState(() {
                              thread = Thread(
                                id: thread.id,
                                title: thread.title,
                                creator: thread.creator,
                                createdAt: thread.createdAt,
                                updatedAt: thread.updatedAt,
                                isPinned: thread.isPinned,
                                isLocked: thread.isLocked,
                                category: thread.category,
                                likesCount: result['likes_count'],
                                isLiked: result['liked'],
                              );
                            });
                          }
                        },
                        child: Row(
                          children: [
                            Icon(
                              thread.isLiked ? Icons.favorite : Icons.favorite_border,
                              color: thread.isLiked ? Colors.red : Theme.of(context).colorScheme.primary.withOpacity(0.7),
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              thread.likesCount.toString(),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Text(
                        thread.creator['username'] ?? '-',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${thread.createdAt.day}/${thread.createdAt.month}/${thread.createdAt.year}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
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
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Post başlığı ve yazar bilgisi
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 16,
                                            backgroundColor: Colors.grey[300],
                                            backgroundImage: post.author['profile_picture'] != null
                                                ? NetworkImage(post.author['profile_picture'])
                                                : null,
                                            child: post.author['profile_picture'] == null
                                                ? Text(
                                                    (post.author['username'] ?? 'A')[0].toUpperCase(),
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  )
                                                : null,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      post.author['username'] ?? 'Anonim',
                                                      style: TextStyle(
                                                        fontWeight: post.author['is_premium'] == true 
                                                            ? FontWeight.bold 
                                                            : FontWeight.normal,
                                                        color: post.author['is_premium'] == true 
                                                            ? Colors.amber[700]
                                                            : null,
                                                      ),
                                                    ),
                                                    if (post.author['is_premium'] == true) ...[
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
                                      
                                      // Post içeriği
                                      Text(
                                        post.content,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          height: 1.5,
                                        ),
                                      ),
                                      
                                      const SizedBox(height: 12),
                                      
                                      // Aksiyon butonları
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
                                      
                                      // Yorumlar bölümü
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
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  CircleAvatar(
                                                    radius: 12,
                                                    backgroundColor: Theme.of(context).brightness == Brightness.dark
                                                        ? AppTheme.darkAccent
                                                        : AppTheme.lightAccent,
                                                    backgroundImage: comment.author['profile_picture'] != null
                                                        ? NetworkImage(comment.author['profile_picture'])
                                                        : null,
                                                    child: comment.author['profile_picture'] == null
                                                        ? Text(
                                                            (comment.author['username'] ?? 'A')[0].toUpperCase(),
                                                            style: const TextStyle(
                                                              fontSize: 10,
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          )
                                                        : null,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Text(
                                                              comment.author['username'] ?? 'Anonim',
                                                              style: TextStyle(
                                                                fontWeight: comment.author['is_premium'] == true 
                                                                    ? FontWeight.bold 
                                                                    : FontWeight.normal,
                                                                fontSize: 12,
                                                                color: comment.author['is_premium'] == true 
                                                                    ? Colors.amber[700]
                                                                    : null,
                                                              ),
                                                            ),
                                                            if (comment.author['is_premium'] == true) ...[
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
                                            ],
                                          ),
                                        )).toList()),
                                      ],
                                      
                                      // Daha fazla yorum göster butonu
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
                                      
                                      // Yorumlar yükleniyor
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
} 