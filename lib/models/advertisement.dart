class Advertisement {
  final int id;
  final String title;
  final String description;
  final String companyName;
  final String? gifUrl;
  final String? linkUrl;
  final int priority;

  Advertisement({
    required this.id,
    required this.title,
    required this.description,
    required this.companyName,
    this.gifUrl,
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
      'link_url': linkUrl,
      'priority': priority,
    };
  }
} 