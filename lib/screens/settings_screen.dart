import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/responsive_utils.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _ipController = TextEditingController();
  String _currentIp = '192.168.1.100';

  @override
  void initState() {
    super.initState();
    _loadCurrentIp();
  }

  Future<void> _loadCurrentIp() async {
    final prefs = await SharedPreferences.getInstance();
    final savedIp = prefs.getString('custom_ip') ?? '192.168.1.100';
    setState(() {
      _currentIp = savedIp;
      _ipController.text = savedIp;
    });
  }

  Future<void> _saveIpAddress() async {
    final newIp = _ipController.text.trim();
    if (newIp.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('custom_ip', newIp);
      
      // API Service'e yeni IP'yi ayarla
      ApiService.setCustomBaseUrl('http://$newIp:8000/api');
      
      setState(() {
        _currentIp = newIp;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('IP adresi güncellendi: $newIp')),
        );
      }
    }
  }

  Future<void> _logout() async {
    await AuthService.logout();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ayarlar', style: TextStyle(
          fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 18)
        )),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: ResponsiveUtils.getResponsiveEdgeInsets(context, baseValue: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Backend IP Adresi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Backend sunucusunun IP adresini ayarlayın. Aynı ağda olmalıdır.',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _ipController,
                          decoration: const InputDecoration(
                            labelText: 'IP Adresi',
                            hintText: '192.168.1.100',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _saveIpAddress,
                        child: const Text('Kaydet'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Mevcut IP: $_currentIp',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Çıkış Yap'),
              onTap: _logout,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _ipController.dispose();
    super.dispose();
  }
} 