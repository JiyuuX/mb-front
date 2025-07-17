class Advertisement {
  final int id;
  final String title;
  final String description;
  final String companyName;
  final String? gifUrl;
  final String? imageUrl;
  final String? videoUrl;
  final String? linkUrl;
  final int priority;

  Advertisement({
    required this.id,
    required this.title,
    required this.description,
    required this.companyName,
    this.gifUrl,
    this.imageUrl,
    this.videoUrl,
    this.linkUrl,
    required this.priority,
  });

  factory Advertisement.fromJson(Map<String, dynamic> json) {
    return Advertisement(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      companyName: json['company_name'],
      gifUrl: json['gif_url'],
      imageUrl: json['image_file'],
      videoUrl: json['video_file'],
      linkUrl: json['link_url'],
      priority: json['priority'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'company_name': companyName,
      'gif_url': gifUrl,
      'image_file': imageUrl,
      'video_file': videoUrl,
      'link_url': linkUrl,
      'priority': priority,
    };
  }
} 