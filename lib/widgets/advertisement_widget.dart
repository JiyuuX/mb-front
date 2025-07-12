import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glassmorphism/glassmorphism.dart';
import '../models/advertisement.dart';
import '../services/api_service.dart';
import 'dart:convert';

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

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _loadAds();
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

  void _startAdRotation() {
    if (_ads.length > 1) {
      Future.delayed(const Duration(seconds: 8), () {
        if (mounted) {
          _fadeController.forward().then((_) {
            setState(() {
              _currentAdIndex = (_currentAdIndex + 1) % _ads.length;
            });
            _fadeController.reverse().then((_) {
              _startAdRotation();
            });
          });
        }
      });
    }
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
  void dispose() {
    _fadeController.dispose();
    super.dispose();
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

    // Eğer GIF yoksa hiçbir şey gösterme
    if (currentAd.gifUrl == null || currentAd.gifUrl!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      height: widget.height,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: GestureDetector(
        onTap: () => _handleAdClick(currentAd),
        child: Center(
          child: Container(
            width: 300,
            height: 300,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              currentAd.gifUrl!,
                              fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const SizedBox.shrink();
                },
                              errorBuilder: (context, error, stackTrace) {
                  return const SizedBox.shrink();
                              },
                            ),
                          ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: 1400.ms, duration: 600.ms).scale(begin: const Offset(0.8, 0.8));
  }
} 