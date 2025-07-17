class Event {
  final int id;
  final String name;
  final String venue;
  final String city;
  final String cityDisplay;
  final String date;
  final String time;
  final String timeFormatted;
  final String description;
  final String ticketPrice;
  final int capacity;

  Event({
    required this.id,
    required this.name,
    required this.venue,
    required this.city,
    required this.cityDisplay,
    required this.date,
    required this.time,
    required this.timeFormatted,
    required this.description,
    required this.ticketPrice,
    required this.capacity,
  });

  factory Event.fromJson(Map<String, dynamic> json) => Event(
    id: json['id'],
    name: json['name'],
    venue: json['venue'],
    city: json['city'] ?? '',
    cityDisplay: json['city_display'] ?? '',
    date: json['date'],
    time: json['time'],
    timeFormatted: json['time_formatted'] ?? json['time'],
    description: json['description'] ?? '',
    ticketPrice: json['ticket_price'].toString(),
    capacity: json['capacity'],
  );
} 