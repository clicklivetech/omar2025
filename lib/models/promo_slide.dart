class PromoSlide {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String? actionUrl;
  final bool isActive;
  final DateTime startDate;
  final DateTime endDate;

  PromoSlide({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    this.actionUrl,
    required this.isActive,
    required this.startDate,
    required this.endDate,
  });

  factory PromoSlide.fromJson(Map<String, dynamic> json) {
    return PromoSlide(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrl: json['image_url'] as String,
      actionUrl: json['action_url'] as String?,
      isActive: json['is_active'] as bool,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'action_url': actionUrl,
      'is_active': isActive,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
    };
  }
}
