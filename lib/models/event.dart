class Event {
  final int id;
  final String name;
  final String venue;
  final String city;
  final DateTime date;
  final String description;
  final double ticketPrice;
  final String? organizer;

  Event({
    required this.id,
    required this.name,
    required this.venue,
    required this.city,
    required this.date,
    required this.description,
    required this.ticketPrice,
    this.organizer,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      name: json['name'] ?? '',
      venue: json['venue'] ?? '',
      city: json['city_display'] ?? json['city'] ?? '',
      date: DateTime.parse(json['date']),
      description: json['description'] ?? '',
      ticketPrice: double.tryParse(json['ticket_price']?.toString() ?? json['price']?.toString() ?? '0') ?? 0.0,
      organizer: json['organizer'],
    );
  }

  String get cityDisplay => city;

  String get timeFormatted => "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
} 