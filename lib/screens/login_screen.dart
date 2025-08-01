import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/auth_service.dart';
import '../widgets/ban_dialog.dart';
import '../widgets/verification_dialog.dart';
import 'register_screen.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await AuthService.login(
        username: _usernameController.text.trim(),
        password: _passwordController.text,
      );

      // Debug: Response'u yazdır
      print('Login response: $result');

      if (result['success']) {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const DashboardScreen()),
          );
        }
      } else {
        if (mounted) {
          // Debug: Email verification kontrolü
          print('Email verification required: ${result['email_verification_required']}');
          
          if (result['banli'] == true) {
            // Banlı kullanıcıya özel modern dialog
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return ModernBanDialog(
                  banInfo: result,
                  onConfirm: () => Navigator.of(context).pop(),
                  showCountdown: false,
                );
              },
            );
          } else if (result['email_verification_required'] == true) {
            // Debug: Verification dialog açılıyor
            print('Opening verification dialog for email: ${result['email']}');
            
            // Email verification dialog'u göster
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => VerificationDialog(
                email: result['email'],
                initialCode: result['verification_code'],
                onVerificationSuccess: () {
                  // Doğrulama başarılı olduğunda tekrar login dene
                  _login();
                },
                onCancel: () {
                  // İptal edildiğinde dialog'u kapat
                  Navigator.of(context).pop();
                },
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result['message']),
                backgroundColor: Theme.of(context).colorScheme.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Giriş yapılırken hata oluştu: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo ve başlık
                Icon(
                  Icons.school,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ).animate().scale(duration: 600.ms).then().shimmer(duration: 2.seconds),
                const SizedBox(height: 16),
                Text(
                  'HPGenc',
                  style: GoogleFonts.inter(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideY(begin: 0.3),
                const SizedBox(height: 8),
                Text(
                  'Üniversite Gençlik Platformu',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ).animate().fadeIn(delay: 400.ms, duration: 600.ms).slideY(begin: 0.3),
                const SizedBox(height: 48),

                // Login formu
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.outline,
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Hoş Geldiniz',
                            style: GoogleFonts.inter(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ).animate().fadeIn(delay: 600.ms, duration: 600.ms),
                          const SizedBox(height: 32),

                          // Kullanıcı adı alanı
                          TextFormField(
                            controller: _usernameController,
                            style: GoogleFonts.inter(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Kullanıcı Adı',
                              labelStyle: GoogleFonts.inter(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                              prefixIcon: Icon(
                                Icons.person,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Kullanıcı adı gereklidir';
                              }
                              return null;
                            },
                          ).animate().fadeIn(delay: 800.ms, duration: 600.ms).slideX(begin: -0.3),
                          const SizedBox(height: 16),

                          // Şifre alanı
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            style: GoogleFonts.inter(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Şifre',
                              labelStyle: GoogleFonts.inter(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                              prefixIcon: Icon(
                                Icons.lock,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Şifre gereklidir';
                              }
                              return null;
                            },
                          ).animate().fadeIn(delay: 1000.ms, duration: 600.ms).slideX(begin: -0.3),
                          const SizedBox(height: 32),

                          // Giriş butonu
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
                              ),
                              child: _isLoading
                                  ? CircularProgressIndicator(
                                      color: Theme.of(context).colorScheme.onPrimary,
                                    )
                                  : Text(
                                      'Giriş Yap',
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(context).colorScheme.onPrimary,
                                      ),
                                    ),
                            ),
                          ).animate().fadeIn(delay: 1200.ms, duration: 600.ms).slideY(begin: 0.3),
                          const SizedBox(height: 24),

                          // Kayıt ol linki
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Hesabınız yok mu? ',
                                style: GoogleFonts.inter(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => const RegisterScreen(),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Kayıt Ol',
                                  style: GoogleFonts.inter(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ).animate().fadeIn(delay: 1400.ms, duration: 600.ms),
                        ],
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 600.ms, duration: 800.ms).scale(begin: const Offset(0.8, 0.8)),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 