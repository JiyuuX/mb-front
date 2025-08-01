class Event {
  final int id;
  final String name;
  final String venue;
  final String city;
  final DateTime date;
  final String time; // Backend'den gelen time field'ı
  final String description;
  final double ticketPrice;
  final String? organizer;

  Event({
    required this.id,
    required this.name,
    required this.venue,
    required this.city,
    required this.date,
    required this.time,
    required this.description,
    required this.ticketPrice,
    this.organizer,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    // Time field'ını parse edip sadece saat:dakika kısmını al
    String timeStr = json['time_formatted'] ?? json['time'] ?? '00:00';
    String formattedTime = timeStr;
    
    // Eğer HH:MM:SS formatındaysa sadece HH:MM kısmını al
    if (timeStr.contains(':')) {
      List<String> parts = timeStr.split(':');
      if (parts.length >= 2) {
        formattedTime = '${parts[0]}:${parts[1]}';
      }
    }
    
    return Event(
      id: json['id'],
      name: json['name'] ?? '',
      venue: json['venue'] ?? '',
      city: json['city_display'] ?? json['city'] ?? '',
      date: DateTime.parse(json['date']),
      time: formattedTime,
      description: json['description'] ?? '',
      ticketPrice: double.tryParse(json['ticket_price']?.toString() ?? json['price']?.toString() ?? '0') ?? 0.0,
      organizer: json['organizer'],
    );
  }

  String get cityDisplay => city;

  String get timeFormatted => time;
} 