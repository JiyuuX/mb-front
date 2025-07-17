import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'providers/theme_provider.dart';
import 'utils/app_theme.dart';
import 'services/api_service.dart';
import 'widgets/ban_dialog.dart';
import 'dart:async';
import 'dart:convert';

void main() {
  runApp(const HPGencApp());
}

class HPGencApp extends StatelessWidget {
  const HPGencApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'HPGenc',
            theme: AppTheme.lightTheme(),
            darkTheme: AppTheme.darkTheme(),
            themeMode: themeProvider.themeMode,
            home: const AuthWrapper(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _isLoggedIn = false;
  Map<String, dynamic>? _banInfo;
  int _banCountdown = 5;
  bool _banDialogOpen = false;
  Timer? _banCheckTimer; // Artık kullanılmıyor

  @override
  void initState() {
    super.initState();
    ApiService.onBanDetected = (banInfo) {
      if (_banDialogOpen) return;
      setState(() {
        _isLoggedIn = false;
        _banInfo = banInfo;
        _banCountdown = 5;
        _banDialogOpen = true;
      });
      _showBanDialogWithCountdown();
    };
    _checkAuthStatus();
  }

  @override
  void dispose() {
    _banCheckTimer?.cancel(); // Artık kullanılmıyor
    super.dispose();
  }

  // void _startBanCheckTimer() { ... } // Tamamen kaldırıldı

  Future<void> _checkAuthStatus() async {
    try {
      final isLoggedIn = await AuthService.isLoggedIn();
      setState(() {
        _isLoggedIn = isLoggedIn;
        _isLoading = false;
      });
      // if (isLoggedIn) {
      //   _startBanCheckTimer();
      // } else {
      //   _banCheckTimer?.cancel();
      // }
    } catch (e) {
      setState(() {
        _isLoggedIn = false;
        _isLoading = false;
      });
      // _banCheckTimer?.cancel();
    }
  }

  void _showBanDialogWithCountdown() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            // Geri sayım timer'ı başlat
            Future.delayed(const Duration(seconds: 1), () {
              if (_banCountdown > 0 && _banDialogOpen) {
                setStateDialog(() {
                  _banCountdown--;
                });
                if (_banCountdown == 0) {
                  Navigator.of(context, rootNavigator: true).pop();
                  _forceLogout();
                } else {
                  _showBanDialogWithCountdown();
                }
              }
            });
            return ModernBanDialog(
              banInfo: _banInfo ?? {},
              countdown: _banCountdown,
              onConfirm: () {
                Navigator.of(context, rootNavigator: true).pop();
                _forceLogout();
              },
            );
          },
        );
      },
    ).then((_) {
      setState(() {
        _banDialogOpen = false;
      });
    });
  }

  void _forceLogout() async {
    await AuthService.logout();
    _banCheckTimer?.cancel();
    setState(() {
      _isLoggedIn = false;
      _banInfo = null;
      _banCountdown = 5;
      _banDialogOpen = false;
    });
    // Direkt login sayfasına yönlendir
    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.school,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
                              ).animate(onPlay: (controller) => controller.repeat())
                  .shimmer(duration: 2.seconds, color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)),
              const SizedBox(height: 24),
              Text(
                'HPGenc',
                style: GoogleFonts.inter(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3),
              const SizedBox(height: 8),
              Text(
                'Üniversite Gençlik Platformu',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ).animate().fadeIn(delay: 300.ms, duration: 600.ms).slideY(begin: 0.3),
              const SizedBox(height: 48),
              CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
                strokeWidth: 3,
                              ).animate(onPlay: (controller) => controller.repeat())
                  .shimmer(duration: 1.5.seconds, color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)),
            ],
          ),
        ),
      );
    }

    if (_banInfo != null) {
      // Banlı kullanıcı login ekranına yönlendirilir
      return const LoginScreen();
    }

    return _isLoggedIn ? const DashboardScreen() : const LoginScreen();
  }
}
