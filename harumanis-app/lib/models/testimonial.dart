class Testimonial {
  final int id;
  final int farmId;
  final String buyerName;
  final int rating;
  final String? comment;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Testimonial({
    required this.id,
    required this.farmId,
    required this.buyerName,
    required this.rating,
    this.comment,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Testimonial.fromJson(Map<String, dynamic> j) => Testimonial(
        id: j['id'] as int,
        farmId: j['farm_id'] as int,
        buyerName: j['buyer_name'] as String,
        rating: j['rating'] as int,
        comment: j['comment'] as String?,
        createdAt: DateTime.parse(j['created_at'] as String),
        updatedAt: DateTime.parse(j['updated_at'] as String),
      );
}
