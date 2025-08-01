import 'dart:convert';
import '../models/event.dart';
import '../models/ticket.dart';
import 'api_service.dart';

class EventService {
  static Future<List<Event>> fetchEvents({String? city}) async {
    try {
      String endpoint = '/events/upcoming-events/';
      if (city != null && city.isNotEmpty) {
        endpoint += '?city=$city';
      }
      
      print('DEBUG: EventService.fetchEvents - endpoint: $endpoint');
      final response = await ApiService.get(endpoint);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('DEBUG: EventService.fetchEvents - response data: $data');
        final List<dynamic> items = data is List ? data : (data['results'] ?? []);
        print('DEBUG: EventService.fetchEvents - items count: ${items.length}');
        return items.map((item) => Event.fromJson(item)).toList();
      } else {
        print('DEBUG: EventService.fetchEvents - error status: ${response.statusCode}');
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