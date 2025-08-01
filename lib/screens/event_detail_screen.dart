import 'package:flutter/material.dart';
import '../models/event.dart';
import '../utils/responsive_utils.dart';

class EventDetailScreen extends StatelessWidget {
  final Event event;
  const EventDetailScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(event.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text('Mekan: ${event.venue}'),
            Text('Tarih: ${event.date.day}.${event.date.month}.${event.date.year}'),
            Text('Saat: ${event.timeFormatted}'),
            Text('Açıklama: ${event.description}'),
            Text('Bilet Fiyatı: ${event.ticketPrice} TL'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Bilet alma işlemi burada yapılabilir
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Bilet alma işlemi burada yapılacak.')),
                );
              },
              child: const Text('Bilet Satın Al'),
            ),
          ],
        ),
      ),
    );
  }
} 