class User {
  final int id;
  final String username;
  final String email;
  final String? firstName;
  final String? lastName;
  final bool isPremium;
  final bool isPremiumActive;
  final bool emailVerified;
  final String? profilePicture;
  final String? bio;
  final String? phoneNumber;
  final String? customUsernameColor;
  final String? cardNumber;
  final DateTime? cardIssuedAt;
  final bool canCreateThreads;
  final bool isSecondhandSeller;
  final int? threadCount;
  final bool isBanned;
  final String? banReason;
  final DateTime? banUntil;
  final String? university;
  final String? city;
  // Social media fields
  final String? instagram;
  final String? twitter;
  final String? facebook;
  final String? linkedin;
  final String? website;
  // Follow system fields
  final int followersCount;
  final int followingCount;
  final bool isFollowing;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? popularity;
  final int? threadLikes;
  final int? newFollowers;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.firstName,
    this.lastName,
    required this.isPremium,
    required this.isPremiumActive,
    required this.emailVerified,
    this.profilePicture,
    this.bio,
    this.phoneNumber,
    this.customUsernameColor,
    this.cardNumber,
    this.cardIssuedAt,
    required this.canCreateThreads,
    required this.isSecondhandSeller,
    this.instagram,
    this.twitter,
    this.facebook,
    this.linkedin,
    this.website,
    required this.followersCount,
    required this.followingCount,
    required this.isFollowing,
    required this.createdAt,
    required this.updatedAt,
    this.threadCount,
    required this.isBanned,
    this.banReason,
    this.banUntil,
    this.university,
    this.city,
    this.popularity,
    this.threadLikes,
    this.newFollowers,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      firstName: json['first_name'],
      lastName: json['last_name'],
      isPremium: json['is_premium'] ?? false,
      isPremiumActive: json['is_premium_active'] ?? false,
      emailVerified: json['email_verified'] ?? false,
      profilePicture: json['profile_picture'],
      bio: json['bio'],
      phoneNumber: json['phone_number'],
      customUsernameColor: json['custom_username_color'],
      cardNumber: json['card_number'],
      cardIssuedAt: json['card_issued_at'] != null 
          ? DateTime.parse(json['card_issued_at']) 
          : null,
      canCreateThreads: json['can_create_threads'] ?? false,
      isSecondhandSeller: json['is_secondhand_seller'] ?? false,
      instagram: json['instagram'],
      twitter: json['twitter'],
      facebook: json['facebook'],
      linkedin: json['linkedin'],
      website: json['website'],
      followersCount: json['followers_count'] ?? 0,
      followingCount: json['following_count'] ?? 0,
      isFollowing: json['is_following'] ?? false,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : DateTime.now(),
      threadCount: json['thread_count'],
      isBanned: json['is_banned'] ?? false,
      banReason: json['ban_reason'],
      banUntil: json['ban_until'] != null ? DateTime.tryParse(json['ban_until']) : null,
      university: json['university'],
      city: json['city'],
      popularity: json['popularity'] as int?,
      threadLikes: json['thread_likes'] as int?,
      newFollowers: json['new_followers'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'is_premium': isPremium,
      'is_premium_active': isPremiumActive,
      'email_verified': emailVerified,
      'profile_picture': profilePicture,
      'bio': bio,
      'phone_number': phoneNumber,
      'custom_username_color': customUsernameColor,
      'card_number': cardNumber,
      'card_issued_at': cardIssuedAt?.toIso8601String(),
      'can_create_threads': canCreateThreads,
      'is_secondhand_seller': isSecondhandSeller,
      'instagram': instagram,
      'twitter': twitter,
      'facebook': facebook,
      'linkedin': linkedin,
      'website': website,
      'followers_count': followersCount,
      'following_count': followingCount,
      'is_following': isFollowing,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'thread_count': threadCount,
      'is_banned': isBanned,
      'ban_reason': banReason,
      'ban_until': banUntil?.toIso8601String(),
      'university': university,
      'city': city,
      'popularity': popularity,
      'thread_likes': threadLikes,
      'new_followers': newFollowers,
    };
  }

  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    } else if (firstName != null) {
      return firstName!;
    } else if (lastName != null) {
      return lastName!;
    }
    return username;
  }
} 