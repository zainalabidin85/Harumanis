class Announcement {
  final int id;
  final String title;
  final String body;
  final String? imageUrl;
  final DateTime? eventDate;
  final String? location;
  final DateTime createdAt;

  const Announcement({
    required this.id,
    required this.title,
    required this.body,
    required this.imageUrl,
    required this.eventDate,
    required this.location,
    required this.createdAt,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) => Announcement(
        id: json['id'] as int,
        title: json['title'] as String,
        body: json['body'] as String,
        imageUrl: json['image_url'] as String?,
        eventDate: json['event_date'] != null
            ? DateTime.parse(json['event_date'] as String)
            : null,
        location: json['location'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}
