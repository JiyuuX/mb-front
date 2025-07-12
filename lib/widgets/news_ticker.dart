import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/news.dart';

class NewsTicker extends StatefulWidget {
  final List<News> news;
  final double height;
  final Color backgroundColor;
  final Color textColor;
  final bool isEnabled;
  final VoidCallback? onToggle;

  const NewsTicker({
    super.key,
    required this.news,
    this.height = 40,
    this.backgroundColor = Colors.orange,
    this.textColor = Colors.white,
    this.isEnabled = true,
    this.onToggle,
  });

  @override
  State<NewsTicker> createState() => _NewsTickerState();
}

class _NewsTickerState extends State<NewsTicker>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  int _currentNewsIndex = 0;
  int _currentPartIndex = 0;
  List<String> _currentNewsParts = [];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _startSwitching();
  }

  @override
  void didUpdateWidget(NewsTicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Eğer haber listesi değiştiyse ticker'ı yeniden başlat
    if (oldWidget.news != widget.news) {
      print('Haber listesi güncellendi - ${widget.news.length} haber');
      _currentNewsIndex = 0;
      _currentPartIndex = 0;
      _startSwitching();
    }
    // Eğer enabled durumu değiştiyse
    if (oldWidget.isEnabled != widget.isEnabled) {
      if (widget.isEnabled) {
        _startSwitching();
      }
    }
  }

  // Uzun yazıyı mantıklı parçalara böl
  List<String> _splitNewsIntoParts(String newsText) {
    List<String> parts = [];
    
    try {
      // Maksimum karakter sayısını artırdım (yaklaşık 80 karakter)
      const int maxLength = 80;
      
      if (newsText.length <= maxLength) {
        // Kısa yazı, bölmeye gerek yok
        parts.add(newsText);
      } else {
        // Uzun yazıyı böl - daha mantıklı bölme
        int startIndex = 0;
        
        while (startIndex < newsText.length) {
          int endIndex = startIndex + maxLength;
          
          // Range kontrolü - endIndex string uzunluğunu aşmasın
          if (endIndex > newsText.length) {
            endIndex = newsText.length;
          }
          
          // Eğer son karakter değilse ve boşluk varsa, boşlukta böl
          if (endIndex < newsText.length) {
            // Son boşluk pozisyonunu bul (daha geniş arama)
            int lastSpaceIndex = newsText.lastIndexOf(' ', endIndex);
            if (lastSpaceIndex > startIndex + 20) { // En az 20 karakter olsun
              endIndex = lastSpaceIndex;
            }
          }
          
          // Parçayı ekle
          String part = newsText.substring(startIndex, endIndex).trim();
          if (part.isNotEmpty) {
            parts.add(part);
          }
          
          startIndex = endIndex;
          
          // Sonsuz döngüyü önle
          if (startIndex >= newsText.length) {
            break;
          }
        }
      }
    } catch (e) {
      print('Haber bölme hatası: $e');
      // Hata durumunda orijinal metni tek parça olarak döndür
      parts = [newsText];
    }
    
    return parts;
  }

  void _startSwitching() {
    if (widget.news.isNotEmpty && widget.isEnabled) {
      print('Ticker başlatılıyor - ${widget.news.length} haber var');
      print('Mevcut haber indeksi: $_currentNewsIndex');
      print('Mevcut parça indeksi: $_currentPartIndex');
      
      // Mevcut haberi parçalara böl
      _currentNewsParts = _splitNewsIntoParts(widget.news[_currentNewsIndex].title);
      print('Haber parçaları: $_currentNewsParts');
      print('Mevcut haber: ${widget.news[_currentNewsIndex].title}');
      
      // 3 saniye bekle, sonra fade out
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && widget.isEnabled) {
          print('3 saniye geçti, fade out başlıyor');
          _fadeController.forward().then((_) {
            if (mounted && widget.isEnabled) {
              setState(() {
                _currentPartIndex++;
                print('Parça indeksi artırıldı: $_currentPartIndex');
                
                // Eğer mevcut haberin tüm parçaları gösterildiyse, sonraki habere geç
                if (_currentPartIndex >= _currentNewsParts.length) {
                  _currentNewsIndex = (_currentNewsIndex + 1) % widget.news.length;
                  _currentPartIndex = 0;
                  _currentNewsParts = _splitNewsIntoParts(widget.news[_currentNewsIndex].title);
                  print('Sonraki habere geçildi: $_currentNewsIndex - ${widget.news[_currentNewsIndex].title}');
                }
              });
              _fadeController.reverse().then((_) {
                print('Fade in başlıyor');
                if (widget.isEnabled) {
                  _startSwitching(); // Tekrar başla
                }
              });
            }
          });
        }
      });
    } else {
      print('Haber listesi boş veya ticker devre dışı!');
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('NewsTicker build - Haber sayısı: ${widget.news.length}, Enabled: ${widget.isEnabled}');
    
    if (widget.news.isEmpty) {
      return Container(
        height: widget.height,
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            'Henüz haber bulunmuyor',
            style: GoogleFonts.poppins(
              color: widget.textColor,
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    // Mevcut parçayı al
    String currentText = _currentNewsParts.isNotEmpty && _currentPartIndex < _currentNewsParts.length
        ? _currentNewsParts[_currentPartIndex]
        : widget.news[_currentNewsIndex].title;

    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
          width: 1,
        ),
      ),
            child: Row(
        children: [
          // Haber ikonu ve "HABERLER" etiketi
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Icon(
                  Icons.newspaper,
                  color: widget.textColor,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'HABERLER',
                  style: GoogleFonts.poppins(
                    color: widget.textColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // Ayırıcı çizgi
          Container(
            width: 1,
            height: 20,
            color: widget.textColor.withValues(alpha: 0.3),
          ),
          
          // Haber metni alanı - Fade animasyonu ile
          Expanded(
            child: AnimatedBuilder(
              animation: _fadeController,
              builder: (context, child) {
                return Opacity(
                  opacity: widget.isEnabled ? (1.0 - _fadeController.value) : 0.5,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.isEnabled ? currentText : 'Haberler devre dışı',
                            style: GoogleFonts.poppins(
                              color: widget.textColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Parça göstergesi (eğer birden fazla parça varsa ve aktifse)
                        if (_currentNewsParts.length > 1 && widget.isEnabled)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            child: Text(
                              '${_currentPartIndex + 1}/${_currentNewsParts.length}',
                              style: GoogleFonts.poppins(
                                color: widget.textColor.withValues(alpha: 0.7),
                                fontSize: 10,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Switch butonu
          if (widget.onToggle != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: GestureDetector(
                onTap: widget.onToggle,
                child: Container(
                  width: 40,
                  height: 20,
                  decoration: BoxDecoration(
                    color: widget.isEnabled 
                        ? widget.textColor 
                        : widget.textColor.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Stack(
                    children: [
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 200),
                        left: widget.isEnabled ? 22 : 2,
                        top: 2,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: widget.isEnabled 
                                ? Theme.of(context).colorScheme.surface 
                                : widget.textColor.withValues(alpha: 0.5),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.3);
  }
} 