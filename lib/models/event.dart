class Event {
  final int id;
  final String title;
  final String description;
  final String eventType;
  final DateTime startDate;
  final DateTime endDate;
  final String location;
  final String? locationDetails;
  final String organizer;
  final String? contactEmail;
  final String? contactPhone;
  final String? image;
  final int? maxParticipants;
  final int currentParticipants;
  final bool isApproved;
  final bool isFeatured;
  final DateTime createdAt;
  final DateTime updatedAt;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.eventType,
    required this.startDate,
    required this.endDate,
    required this.location,
    this.locationDetails,
    required this.organizer,
    this.contactEmail,
    this.contactPhone,
    this.image,
    this.maxParticipants,
    required this.currentParticipants,
    required this.isApproved,
    required this.isFeatured,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      eventType: json['event_type'],
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      location: json['location'],
      locationDetails: json['location_details'],
      organizer: json['organizer'],
      contactEmail: json['contact_email'],
      contactPhone: json['contact_phone'],
      image: json['image'],
      maxParticipants: json['max_participants'],
      currentParticipants: json['current_participants'],
      isApproved: json['is_approved'],
      isFeatured: json['is_featured'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'event_type': eventType,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'location': location,
      'location_details': locationDetails,
      'organizer': organizer,
      'contact_email': contactEmail,
      'contact_phone': contactPhone,
      'image': image,
      'max_participants': maxParticipants,
      'current_participants': currentParticipants,
      'is_approved': isApproved,
      'is_featured': isFeatured,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
} 