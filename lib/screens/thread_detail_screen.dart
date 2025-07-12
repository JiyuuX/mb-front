import 'package:flutter/material.dart';
import '../models/thread.dart';
import '../models/post.dart';
import '../models/comment.dart';
import '../services/forum_service.dart';

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
      builder: (context) => AlertDialog(
        title: const Text('Yeni Post Ekle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: contentController,
              decoration: const InputDecoration(
                labelText: 'Post İçeriği',
                border: OutlineInputBorder(),
                hintText: 'Post içeriğinizi yazın...',
              ),
              maxLines: 5,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (contentController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Post içeriği gereklidir.'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              // ScaffoldMessenger referansını önceden al
              final scaffoldMessenger = ScaffoldMessenger.of(context);

              Navigator.of(context).pop();
              
              // Loading göster
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
                  // Post listesini yeniden yükle (en güvenli yöntem)
                  await _loadPosts();
                }
              } else {
                if (mounted) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text(result['message']),
                      backgroundColor: Colors.red,
                    ),
                  );
                  setState(() {
                    _isLoading = false;
                  });
                }
              }
            },
            child: const Text('Ekle'),
          ),
        ],
      ),
    );
  }

  void _showCreateCommentDialog(int postId) {
    final contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yorum Ekle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: contentController,
              decoration: const InputDecoration(
                labelText: 'Yorum İçeriği',
                border: OutlineInputBorder(),
                hintText: 'Yorumunuzu yazın...',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (contentController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Yorum içeriği gereklidir.'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              // ScaffoldMessenger referansını önceden al
              final scaffoldMessenger = ScaffoldMessenger.of(context);

              Navigator.of(context).pop();
              
              // Loading göster
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
                  // Post'ları yeniden yükle ki comment count güncellensin
                  await _loadPosts();
                }
              } else {
                if (mounted) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text(result['message']),
                      backgroundColor: Colors.red,
                    ),
                  );
                  setState(() {
                    _commentsLoading[postId] = false;
                  });
                }
              }
            },
            child: const Text('Ekle'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.thread.title),
        backgroundColor: const Color(0xFF667eea),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _showCreatePostDialog,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
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
                            padding: const EdgeInsets.all(16),
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
                                      color: Colors.grey[50],
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.grey[200]!),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 12,
                                              backgroundColor: Colors.grey[300],
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
                                                  color: Colors.grey[300],
                                                  borderRadius: BorderRadius.circular(3),
                                                ),
                                                child: const Text(
                                                  'Düzenlendi',
                                                  style: TextStyle(
                                                    fontSize: 8,
                                                    color: Colors.grey,
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
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreatePostDialog,
        backgroundColor: const Color(0xFF667eea),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
} 