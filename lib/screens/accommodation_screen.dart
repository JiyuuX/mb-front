import 'package:flutter/material.dart';
import '../models/accommodation.dart';
import '../services/api_service.dart';

class AccommodationScreen extends StatefulWidget {
  const AccommodationScreen({Key? key}) : super(key: key);

  @override
  State<AccommodationScreen> createState() => _AccommodationScreenState();
}

class _AccommodationScreenState extends State<AccommodationScreen> {
  List<Accommodation> _accommodations = [];
  bool _isLoading = true;
  String _userCity = '';

  @override
  void initState() {
    super.initState();
    _loadUserCityAndAccommodations();
  }

  Future<void> _loadUserCityAndAccommodations() async {
    // Şimdilik örnek olarak sabit şehir kullanıyorum
    // TODO: Gerçek kullanıcıdan çekilecek
    setState(() { _userCity = 'İstanbul'; });
    await _fetchAccommodations();
  }

  Future<void> _fetchAccommodations() async {
    setState(() { _isLoading = true; });
    final accommodationsJson = await ApiService.fetchAccommodations(city: _userCity);
    setState(() {
      _accommodations = accommodationsJson.map((a) => Accommodation.fromJson(a)).toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Konaklama'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _accommodations.isEmpty
              ? const Center(child: Text('Bu şehirde konaklama bulunamadı.'))
              : ListView.builder(
                  itemCount: _accommodations.length,
                  itemBuilder: (context, index) {
                    final acc = _accommodations[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(acc.name),
                        subtitle: Text('${acc.city} - ${acc.description}'),
                        trailing: Text('${acc.price.toStringAsFixed(2)} TL', style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                      ),
                    );
                  },
                ),
    );
  }
} 