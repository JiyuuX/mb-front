import 'event.dart';

class Ticket {
  final int id;
  final Event event;
  final int user;
  final String code;
  final DateTime purchasedAt;

  Ticket({
    required this.id,
    required this.event,
    required this.user,
    required this.code,
    required this.purchasedAt,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) => Ticket(
    id: json['id'],
    event: Event.fromJson(json['event']),
    user: json['user'],
    code: json['code'],
    purchasedAt: DateTime.parse(json['purchased_at']),
  );
} 