import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glassmorphism/glassmorphism.dart';
import '../models/advertisement.dart';
import '../services/api_service.dart';
import 'dart:convert';
import 'package:video_player/video_player.dart';

class AdvertisementWidget extends StatefulWidget {
  final double height;
  final Color backgroundColor;
  final Color textColor;

  const AdvertisementWidget({
    super.key,
    this.height = 120,
    this.backgroundColor = Colors.grey,
    this.textColor = Colors.white,
  });

  @override
  State<AdvertisementWidget> createState() => _AdvertisementWidgetState();
}

class _AdvertisementWidgetState extends State<AdvertisementWidget>
    with TickerProviderStateMixin {
  List<Advertisement> _ads = [];
  int _currentAdIndex = 0;
  late AnimationController _fadeController;
  bool _isLoading = true;
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _loadAds();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _loadAds() async {
    try {
      final response = await ApiService.get('/ads/active/');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            _ads = (data['ads'] as List)
                .map((ad) => Advertisement.fromJson(ad))
                .toList();
            _isLoading = false;
          });
          if (_ads.isNotEmpty) {
            _prepareMedia(_ads[0]);
            _startAdRotation();
          }
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _prepareMedia(Advertisement ad) async {
    _videoController?.dispose();
    _videoController = null;
    if (ad.videoUrl != null && ad.videoUrl!.isNotEmpty) {
      _videoController = VideoPlayerController.network(ad.videoUrl!);
      await _videoController!.initialize();
      _videoController!.setLooping(false); // Videonun bitmesini bekleyeceğiz
      _videoController!.setVolume(0.0); // Sesi kapalı başlat
      _videoController!.play();
      setState(() {});
      _videoController!.addListener(_onVideoEnd);
    }
  }

  void _onVideoEnd() {
    if (_videoController != null && _videoController!.value.position >= _videoController!.value.duration && !_videoController!.value.isPlaying) {
      _videoController!.removeListener(_onVideoEnd);
      _rotateToNextAd();
    }
  }

  void _startAdRotation() {
    if (_ads.length > 1) {
      final currentAd = _ads[_currentAdIndex];
      if (currentAd.videoUrl != null && currentAd.videoUrl!.isNotEmpty && _videoController != null) {
        // Video ise, bitince _onVideoEnd ile geçiş yapılacak
        // Hiçbir şey yapma, listener tetiklenecek
      } else {
        Future.delayed(const Duration(seconds: 8), () async {
          if (mounted) {
            _rotateToNextAd();
          }
        });
      }
    }
  }

  void _rotateToNextAd() async {
    _fadeController.forward().then((_) async {
      setState(() {
        _currentAdIndex = (_currentAdIndex + 1) % _ads.length;
      });
      await _prepareMedia(_ads[_currentAdIndex]);
      _fadeController.reverse().then((_) {
        _startAdRotation();
      });
    });
  }

  Future<void> _handleAdClick(Advertisement ad) async {
    try {
      // Tıklama sayısını artır
      await ApiService.post('/ads/click/${ad.id}/', {});
      
      // Eğer link varsa, tarayıcıda aç
      if (ad.linkUrl != null && ad.linkUrl!.isNotEmpty) {
        // URL launcher kullanılabilir
        print('Reklam linki: ${ad.linkUrl}');
      }
    } catch (e) {
      print('Reklam tıklama hatası: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox.shrink();
    }

    if (_ads.isEmpty) {
      return const SizedBox.shrink();
    }

    final currentAd = _ads[_currentAdIndex];

    // Medya önceliği: video > image > gif
    Widget? mediaWidget;
    if (currentAd.videoUrl != null && currentAd.videoUrl!.isNotEmpty && _videoController != null && _videoController!.value.isInitialized) {
      mediaWidget = AspectRatio(
        aspectRatio: _videoController!.value.aspectRatio,
        child: VideoPlayer(_videoController!),
      );
    } else if (currentAd.imageUrl != null && currentAd.imageUrl!.isNotEmpty) {
      mediaWidget = Image.network(
        currentAd.imageUrl!,
        fit: BoxFit.cover,
        width: 300,
        height: 300,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const SizedBox.shrink();
        },
        errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
      );
    } else if (currentAd.gifUrl != null && currentAd.gifUrl!.isNotEmpty) {
      mediaWidget = Image.network(
        currentAd.gifUrl!,
        fit: BoxFit.cover,
        width: 300,
        height: 300,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const SizedBox.shrink();
        },
        errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
      );
    }

    if (mediaWidget == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      height: widget.height,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: GestureDetector(
        onTap: () => _handleAdClick(currentAd),
        child: Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: mediaWidget,
          ),
        ),
      ),
    ).animate().fadeIn(delay: 1400.ms, duration: 600.ms).scale(begin: const Offset(0.8, 0.8));
  }
} 