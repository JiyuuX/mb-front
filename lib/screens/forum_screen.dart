import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/forum_service.dart';
import '../models/thread.dart';
import '../models/user.dart';
import '../utils/responsive_utils.dart';
import 'thread_detail_screen.dart';
import 'profile_screen.dart';
import 'dart:convert';
import '../utils/app_theme.dart';
import '../widgets/colored_username.dart';
import 'public_profile_screen.dart';
import 'dashboard_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

// Add report categories for dialog
const List<Map<String, String>> reportCategories = [
  {'value': 'spam', 'label': 'Spam'},
  {'value': 'abuse', 'label': 'Hakaret/İftira'},
  {'value': 'misinfo', 'label': 'Yanlış Bilgi'},
  {'value': 'offtopic', 'label': 'Konu Dışı'},
  {'value': 'other', 'label': 'Diğer'},
];

class ForumScreen extends StatefulWidget {
  const ForumScreen({super.key});

  @override
  State<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen> {
  List<Thread> _threads = [];
  List<dynamic> _hotTopics = [];
  bool _hotLoading = true;
  User? _user;
  bool _isLoading = true;
  bool _isPremium = false;
  String selectedCategory = 'genel';
  final List<Map<String, String>> categories = [
    {'value': 'genel', 'label': 'Genel'},
    {'value': 'muzik', 'label': 'Müzik'},
    {'value': 'oyun', 'label': 'Oyun'},
    {'value': 'film', 'label': 'Film'},
    {'value': 'spor', 'label': 'Spor'},
    {'value': 'teknoloji', 'label': 'Teknoloji'},
    {'value': 'espor', 'label': 'Espor'},
    {'value': 'finans', 'label': 'Finans&Kripto'},
    {'value': 'bilim', 'label': 'Bilim'},
    {'value': 'diger', 'label': 'Diğer'},
  ];

  @override
  void initState() {
    super.initState();
    _loadThreads();
    _checkPremiumStatus();
    _loadUserProfile();
    _loadHotTopics();
  }

  Future<void> _loadHotTopics() async {
    setState(() { _hotLoading = true; });
    final result = await ForumService.getHotTopics();
    if (result['success']) {
      setState(() {
        _hotTopics = result['hotTopics']
            .where((hot) => hot['thread']['forum_type'] == 'genel' && (hot['thread']['university'] == null || hot['thread']['university'] == ''))
            .toList();
        _hotLoading = false;
      });
    } else {
      setState(() { _hotLoading = false; });
    }
  }

  Future<void> _loadThreads() async {
    try {
      final result = await ForumService.getThreads();
      if (result['success']) {
        setState(() {
          _threads = result['threads']
              .where((t) => t.forumType == 'genel' && (t.university == null || t.university!.isEmpty))
              .toList();
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
            content: Text('Forum yüklenirken hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _checkPremiumStatus() async {
    try {
      final response = await ApiService.get('/users/profile/');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _isPremium = data['is_premium'] ?? false;
        });
      }
    } catch (e) {
      setState(() {
        _isPremium = false;
      });
    }
  }

  Future<void> _loadUserProfile() async {
    try {
      final response = await ApiService.get('/users/profile/');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _user = User.fromJson(data);
        });
      }
    } catch (e) {
      // Kullanıcı bilgileri yüklenemezse varsayılan ikon göster
    }
  }

  void _showCreateThreadDialog() {
    if (!_isPremium) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thread oluşturmak için premium üyelik gereklidir.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final titleController = TextEditingController();
    String selectedCategory = 'genel';
    final categories = [
      {'value': 'genel', 'label': 'Genel'},
      {'value': 'muzik', 'label': 'Müzik'},
      {'value': 'oyun', 'label': 'Oyun'},
      {'value': 'film', 'label': 'Film'},
      {'value': 'spor', 'label': 'Spor'},
      {'value': 'teknoloji', 'label': 'Teknoloji'},
      {'value': 'espor', 'label': 'Espor'},
      {'value': 'bilim', 'label': 'Bilim'},
      {'value': 'diger', 'label': 'Diğer'},
    ];

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
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
                        'Yeni Thread Oluştur',
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
                controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Thread başlığını girin...'
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
                maxLines: 2,
                    style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                    decoration: InputDecoration(
                  labelText: 'Kategori',
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
                items: categories
                    .map((cat) => DropdownMenuItem<String>(
                          value: cat['value'],
                          child: Text(cat['label']!),
                        ))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    selectedCategory = val!;
                  });
                },
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
                if (titleController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Thread başlığı gereklidir.'),
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
                final result = await ForumService.createThread(
                  titleController.text.trim(),
                  selectedCategory,
                );
                if (result['success']) {
                  if (mounted) {
                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                        content: Text(result['message']),
                        backgroundColor: Colors.green,
                      ),
                    );
                    await _loadThreads();
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
                          child: const Text('Oluştur', style: TextStyle(fontWeight: FontWeight.w600)),
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

  Widget _buildUsernameText(String username, String? customColor, bool isPremium) {
    return ColoredUsername(
      text: username,
      colorHex: customColor,
      isPremium: isPremium,
    );
  }

  void _showReportThreadDialog(Thread thread) {
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
                              thread.id,
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const DashboardScreen()),
              (route) => false,
            );
          },
        ),
        title: Text('Forum', style: TextStyle(color: isDark ? Colors.black : Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: isDark ? Colors.white : Colors.black,
        foregroundColor: isDark ? Colors.black : Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.black : Colors.white),
        actions: [
          IconButton(
            onPressed: _showCreateThreadDialog,
            icon: Icon(Icons.add, color: isDark ? Colors.black : Colors.white),
          ),
          GestureDetector(
            onTap: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
              _loadUserProfile();
            },
            child: Container(
              margin: const EdgeInsets.all(8),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
              ),
              child: (_user?.profilePicture != null && _user!.profilePicture!.isNotEmpty)
                  ? CircleAvatar(
                      radius: 16,
                      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                      backgroundImage: NetworkImage(_user!.profilePicture!),
                      onBackgroundImageError: (exception, stackTrace) {
                        // Handle image loading errors silently
                        print('Profile image loading error: $exception');
                      },
                      child: null,
                    )
                  : Icon(
                      Icons.person,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Kategori barı
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  color: Theme.of(context).colorScheme.surface,
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 8,
                    children: categories.map((cat) {
                      final isSelected = selectedCategory == cat['value'];
                      return ChoiceChip(
                        label: Text(cat['label']!, style: const TextStyle(fontWeight: FontWeight.w600)),
                        selected: isSelected,
                        onSelected: (_) {
                          setState(() {
                            selectedCategory = cat['value']!;
                          });
                        },
                        selectedColor: Theme.of(context).colorScheme.primary,
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).colorScheme.primary,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.outline,
                            width: 1.5,
                          ),
                        ),
                        elevation: 0,
                      );
                    }).toList(),
                  ),
                ),
                // Hot Topics Bölgesi
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.local_fire_department, color: Colors.orange, size: 22),
                          const SizedBox(width: 8),
                          Text('Şu anda trend', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).colorScheme.primary)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _hotLoading
                          ? const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()))
                          : _hotTopics.isEmpty
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: Text('Şu anda trend konu yok.', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                                )
                              : Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  children: _hotTopics
                                      .map<Widget>((hot) {
                                    final thread = Thread.fromJson(hot['thread']);
                                    final likeCount = hot['like_count'] ?? 0;
                                    final commentCount = hot['comment_count'] ?? 0;
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => ThreadDetailScreen(thread: thread),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        width: 260,
                                        padding: const EdgeInsets.all(14),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).colorScheme.surface,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: Theme.of(context).colorScheme.outline, width: 1),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.03),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    thread.title,
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Theme.of(context).colorScheme.primary),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                Icon(Icons.favorite, size: 16, color: Colors.red.withOpacity(0.8)),
                                                const SizedBox(width: 4),
                                                Text(likeCount.toString(), style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.primary)),
                                                const SizedBox(width: 12),
                                                Icon(Icons.comment, size: 16, color: Theme.of(context).colorScheme.primary.withOpacity(0.7)),
                                                const SizedBox(width: 4),
                                                Text(commentCount.toString(), style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.primary)),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                    ],
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
              onRefresh: _loadThreads,
              child: _threads.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.forum, size: 64, color: Theme.of(context).colorScheme.primary.withOpacity(0.2)),
                          const SizedBox(height: 16),
                          Text('Henüz thread yok', style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                            itemCount: _threads.where((t) => selectedCategory == 'genel' ? true : t.category == selectedCategory).length,
                      itemBuilder: (context, index) {
                              final filteredThreads = _threads.where((t) => selectedCategory == 'genel' ? true : t.category == selectedCategory).toList();
                              final thread = filteredThreads[index];
                        return Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: Theme.of(context).colorScheme.outline, width: 1),
                          ),
                          margin: const EdgeInsets.only(bottom: 18),
                          color: Theme.of(context).colorScheme.surface,
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                            onTap: () async {
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ThreadDetailScreen(thread: thread),
                                ),
                              );
                            },
                            leading: (thread.creator.profilePicture != null && thread.creator.profilePicture!.isNotEmpty)
                                ? CircleAvatar(
                                    backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                                    backgroundImage: NetworkImage(thread.creator.profilePicture!),
                                    onBackgroundImageError: (exception, stackTrace) {
                                      // Handle image loading errors silently
                                      print('Profile image loading error: $exception');
                                    },
                                    child: null,
                                  )
                                : CircleAvatar(
                                    backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                                    child: Text(
                                      (thread.creator.username.isNotEmpty ? thread.creator.username[0] : 'A').toUpperCase(),
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    thread.title,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _categoryLabel(thread.category),
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.primary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.person, size: 16, color: Theme.of(context).colorScheme.primary.withOpacity(0.7)),
                                    const SizedBox(width: 6),
                                    GestureDetector(
                                      onTap: () {
                                        final username = thread.creator.username;
                                        if (username.isNotEmpty) {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) => PublicProfileScreen(username: username),
                                            ),
                                          );
                                        }
                                      },
                                      child: ColoredUsername(
                                        text: thread.creator.username,
                                        colorHex: thread.creator.customUsernameColor,
                                        isPremium: thread.creator.isPremium,
                                      ),
                                    ),
                                    const Spacer(),
                                    InkWell(
                                      borderRadius: BorderRadius.circular(16),
                                      onTap: () async {
                                        final result = await ForumService.toggleThreadLike(thread.id);
                                        if (result['success']) {
                                          setState(() {
                                                  final idx = _threads.indexWhere((t) => t.id == thread.id);
                                                  if (idx != -1) {
                                                    _threads[idx] = Thread(
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
                                              forumType: thread.forumType, // <-- eklendi
                                            );
                                                  }
                                          });
                                        }
                                      },
                                      child: Row(
                                        children: [
                                          Icon(
                                            thread.isLiked ? Icons.favorite : Icons.favorite_border,
                                            color: thread.isLiked ? Colors.red : Theme.of(context).colorScheme.primary.withOpacity(0.7),
                                            size: 18,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            thread.likesCount.toString(),
                                            style: TextStyle(
                                              color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.flag, color: Theme.of(context).colorScheme.primary.withOpacity(0.7)),
                                  tooltip: 'Raporla',
                                  onPressed: () => _showReportThreadDialog(thread),
                                ),
                                Icon(Icons.arrow_forward_ios, color: Theme.of(context).colorScheme.primary.withOpacity(0.5)),
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
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
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
      case 'espor':
        return 'Espor';
      case 'finans':
        return 'Finans&Kripto';
      case 'bilim':
        return 'Bilim';
      case 'diger':
        return 'Diğer';
      default:
        return 'Genel';
    }
  }
}