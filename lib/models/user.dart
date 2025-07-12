class User {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String? profilePicture;
  final String? bio;
  final String? phoneNumber;
  final bool isPremium;
  final DateTime? premiumExpiresAt;
  final String customUsernameColor;
  final String? cardNumber;
  final bool canCreateThreads;
  final DateTime dateJoined;
  final DateTime? lastLogin;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.profilePicture,
    this.bio,
    this.phoneNumber,
    required this.isPremium,
    this.premiumExpiresAt,
    required this.customUsernameColor,
    this.cardNumber,
    required this.canCreateThreads,
    required this.dateJoined,
    this.lastLogin,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      profilePicture: json['profile_picture'],
      bio: json['bio'],
      phoneNumber: json['phone_number'],
      isPremium: json['is_premium'] ?? false,
      premiumExpiresAt: json['premium_expires_at'] != null 
          ? DateTime.parse(json['premium_expires_at']) 
          : null,
      customUsernameColor: json['custom_username_color'] ?? '#000000',
      cardNumber: json['card_number'],
      canCreateThreads: json['can_create_threads'] ?? false,
      dateJoined: json['date_joined'] != null 
          ? DateTime.parse(json['date_joined'])
          : DateTime.now(),
      lastLogin: json['last_login'] != null 
          ? DateTime.parse(json['last_login']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'profile_picture': profilePicture,
      'bio': bio,
      'phone_number': phoneNumber,
      'is_premium': isPremium,
      'premium_expires_at': premiumExpiresAt?.toIso8601String(),
      'custom_username_color': customUsernameColor,
      'card_number': cardNumber,
      'can_create_threads': canCreateThreads,
      'date_joined': dateJoined.toIso8601String(),
      'last_login': lastLogin?.toIso8601String(),
    };
  }
} 