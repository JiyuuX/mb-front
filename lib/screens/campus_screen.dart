import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import 'dart:convert';
import '../models/thread.dart';
import '../services/forum_service.dart';
import 'thread_detail_screen.dart';
import 'dashboard_screen.dart';

class CampusScreen extends StatefulWidget {
  final User user;
  const CampusScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<CampusScreen> createState() => _CampusScreenState();
}

class _CampusScreenState extends State<CampusScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _campusNews = [];
  bool _isLoadingNews = true;

  List<Thread> _itirafThreads = [];
  List<Thread> _yardimThreads = [];
  bool _isLoadingItiraf = true;
  bool _isLoadingYardim = true;

  // News swipe state
  late final PageController _newsPageController;
  int _currentNewsPage = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _newsPageController = PageController();
    _fetchCampusNews();
    _fetchItirafThreads();
    _fetchYardimThreads();
  }

  Future<void> _fetchCampusNews() async {
    setState(() { _isLoadingNews = true; });
    try {
      final response = await ApiService.get('/news/campus/?university=${Uri.encodeComponent(widget.user.university ?? '')}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            _campusNews = List<Map<String, dynamic>>.from(data['news']);
          });
        }
      }
    } catch (e) {
      // ignore
    }
    setState(() { _isLoadingNews = false; });
  }

  Future<void> _fetchItirafThreads() async {
    setState(() { _isLoadingItiraf = true; });
    final threads = await ForumService.getCampusForumThreads(university: widget.user.university ?? '', forumType: 'itiraf');
    setState(() { _itirafThreads = threads; });
    setState(() { _isLoadingItiraf = false; });
  }

  Future<void> _fetchYardimThreads() async {
    setState(() { _isLoadingYardim = true; });
    final threads = await ForumService.getCampusForumThreads(university: widget.user.university ?? '', forumType: 'yardim');
    setState(() { _yardimThreads = threads; });
    setState(() { _isLoadingYardim = false; });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _newsPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const DashboardScreen()),
              (route) => false,
            );
          },
        ),
        title: Text('${widget.user.university ?? "Kampüs"}'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'İtiraf'),
            Tab(text: 'Soru-Yardımlaşma'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildCampusNewsSection(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildThreadTab('itiraf'),
                _buildThreadTab('yardim'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCampusNewsSection() {
    if (_isLoadingNews) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_campusNews.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: Text('Bu üniversiteye ait haber bulunamadı.')),
      );
    }
    return SizedBox(
      height: 130,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PageView.builder(
            controller: _newsPageController,
        itemCount: _campusNews.length,
            onPageChanged: (index) {
              setState(() {
                _currentNewsPage = index;
              });
            },
        itemBuilder: (context, index) {
          final news = _campusNews[index];
              return GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(news['title'] ?? ''),
                      content: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(news['content'] ?? ''),
                            const SizedBox(height: 16),
                            Text(
                              news['created_at']?.substring(0, 10) ?? '',
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Kapat'),
                        ),
                      ],
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            width: 260,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  news['title'] ?? '',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                      Text(
                        'Detaylar için tıklayın',
                        style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.primary),
                      ),
                      const Spacer(),
                Text(
                  news['created_at']?.substring(0, 10) ?? '',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
                  ),
            ),
          );
        },
          ),
          if (_campusNews.length > 1 && _currentNewsPage > 0)
            Positioned(
              left: 0,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                color: Theme.of(context).colorScheme.primary,
                onPressed: () {
                  _newsPageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                },
              ),
            ),
          if (_campusNews.length > 1 && _currentNewsPage < _campusNews.length - 1)
            Positioned(
              right: 0,
              child: IconButton(
                icon: const Icon(Icons.arrow_forward_ios),
                color: Theme.of(context).colorScheme.primary,
                onPressed: () {
                  _newsPageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                },
              ),
            ),
          if (_campusNews.length > 1)
            Positioned(
              bottom: 4,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_campusNews.length, (idx) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentNewsPage == idx
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  ),
                )),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildThreadList(List<Thread> threads, bool isLoading, String forumType) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (threads.isEmpty) {
      return Center(child: Text('Henüz hiç konu yok.'));
    }
    return ListView.builder(
      itemCount: threads.length,
      itemBuilder: (context, index) {
        final thread = threads[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text(thread.title),
            subtitle: Text('Oluşturan: ${thread.creator.username}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () async {
                    final result = await ForumService.toggleThreadLike(thread.id);
                    if (result['success'] == true) {
                      setState(() {
                        threads[index] = Thread(
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
                          forumType: thread.forumType,
                        );
                      });
                    }
                  },
                  child: Row(
                    children: [
                      Icon(
                        thread.isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                        size: 18,
                        color: thread.isLiked ? Colors.blue : Colors.blueGrey,
                      ),
                const SizedBox(width: 4),
                Text(thread.likesCount.toString()),
                    ],
                  ),
                ),
              ],
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => ThreadDetailScreen(thread: thread)),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildThreadTab(String forumType) {
    final threads = forumType == 'itiraf' ? _itirafThreads : _yardimThreads;
    final isLoading = forumType == 'itiraf' ? _isLoadingItiraf : _isLoadingYardim;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                forumType == 'itiraf' ? 'İtiraflar' : 'Soru-Yardımlaşma',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Konu Aç'),
                onPressed: () => _showCreateThreadDialog(forumType),
              ),
            ],
          ),
        ),
        Expanded(child: _buildThreadList(threads, isLoading, forumType)),
      ],
    );
  }

  void _showCreateThreadDialog(String forumType) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(forumType == 'itiraf' ? 'Yeni İtiraf' : 'Yeni Soru/Yardımlaşma'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Başlık'),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () async {
                final title = controller.text.trim();
                if (title.isEmpty) return;
                Navigator.of(context).pop();
                await _createThread(title, forumType);
              },
              child: const Text('Oluştur'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _createThread(String title, String forumType) async {
    final result = await ForumService.createCampusThread(
      title: title,
      category: 'genel',
      forumType: forumType,
      university: widget.user.university ?? '',
    );
    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Konu başarıyla oluşturuldu.'), backgroundColor: Colors.green),
      );
      if (forumType == 'itiraf') {
        await _fetchItirafThreads();
      } else {
        await _fetchYardimThreads();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Konu oluşturulamadı: ${result['message']}'), backgroundColor: Colors.red),
      );
    }
  }
} 