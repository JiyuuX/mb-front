import 'package:flutter/material.dart';
import '../models/event.dart';
import '../services/event_service.dart';
import '../utils/responsive_utils.dart';
import 'event_detail_screen.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  List<Event> _events = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() { _isLoading = true; });
    try {
      final events = await EventService.fetchEvents();
      setState(() {
        _events = events;
        _isLoading = false;
      });
    } catch (e) {
      if (e.toString().contains('BanException')) {
        rethrow; // BanException'ı yeniden fırlat, başka hata mesajı gösterme
      }
      setState(() { _isLoading = false; });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Etkinlikler yüklenemedi: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _buyTicket(Event event) async {
    try {
      final ticket = await EventService.buyTicket(event.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bilet alındı! Kodunuz: ${ticket.code}'), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (e.toString().contains('BanException')) {
        rethrow; // BanException'ı yeniden fırlat, başka hata mesajı gösterme
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bilet alınamadı: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Etkinlikler', style: TextStyle(
          fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 18)
        ))),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _events.length,
              itemBuilder: (context, index) {
                final event = _events[index];
                return Card(
                  margin: const EdgeInsets.all(12),
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => EventDetailScreen(event: event),
                        ),
                      );
                    },
                    child: Padding(
                      padding: ResponsiveUtils.getResponsiveEdgeInsets(context, baseValue: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      event.name,
                                      style: TextStyle(
                                        fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 18),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: ResponsiveUtils.getResponsivePadding(context, basePadding: 8)),
                                    Row(
                                      children: [
                                        Icon(Icons.location_on, size: 16, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            '${event.venue} (${event.cityDisplay})',
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            '${event.date} ${event.timeFormatted}',
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Text('Fiyat: ', style: TextStyle(color: Colors.grey)),
                                        Expanded(
                                          child: Text(
                                            '₺${event.ticketPrice}',
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () => _buyTicket(event),
                                child: const Text('Bilet Al'),
                              ),
                            ],
                          ),
                          if (event.description.isNotEmpty) ...[
                            SizedBox(height: ResponsiveUtils.getResponsivePadding(context, basePadding: 12)),
                            const Divider(),
                            const SizedBox(height: 8),
                            Text(
                              event.description,
                              style: TextStyle(
                                fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 14),
                                color: Colors.grey,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
} 