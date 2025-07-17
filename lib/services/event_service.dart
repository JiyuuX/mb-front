import 'dart:convert';
import '../models/event.dart';
import '../models/ticket.dart';
import 'api_service.dart';

class EventService {
  static Future<List<Event>> fetchEvents() async {
    try {
      final response = await ApiService.get('/events/events/');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> items = data is List ? data : (data['results'] ?? []);
        return items.map((item) => Event.fromJson(item)).toList();
      } else {
        throw Exception('Etkinlikler alınamadı');
      }
    } on BanException {
      rethrow; // BanException'ı yeniden fırlat, başka hata mesajı gösterme
    } catch (e) {
      throw Exception('Etkinlikler alınamadı');
    }
  }

  static Future<Ticket> buyTicket(int eventId) async {
    try {
      final response = await ApiService.post('/events/events/$eventId/buy_ticket/', {});
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Ticket.fromJson(data['ticket']);
      } else {
        throw Exception('Bilet alınamadı');
      }
    } on BanException {
      rethrow; // BanException'ı yeniden fırlat, başka hata mesajı gösterme
    } catch (e) {
      throw Exception('Bilet alınamadı');
    }
  }

  static Future<List<Ticket>> fetchUserTickets() async {
    try {
      final response = await ApiService.get('/events/my-tickets/');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> items = data is List ? data : (data['results'] ?? []);
        return items.map((item) => Ticket.fromJson(item)).toList();
      } else {
        throw Exception('Biletler alınamadı');
      }
    } on BanException {
      rethrow; // BanException'ı yeniden fırlat, başka hata mesajı gösterme
    } catch (e) {
      throw Exception('Biletler alınamadı');
    }
  }
} 