import 'farm_image.dart';

class FarmSummary {
  final int farmId;
  final String farmName;
  final String? location;
  final double? gpsLat;
  final double? gpsLng;
  final String farmerName;
  final bool farmerVerified;
  final String? farmerWhatsapp;
  final double? pricePerKg;
  final int totalActiveFruits;
  final int stage1Count;
  final int stage2Count;
  final int stage3Count;
  final int stage4Count;
  final DateTime? earliestHarvestDate;
  final String? thumbnailUrl;
  final double? avgRating;
  final int reviewCount;

  const FarmSummary({
    required this.farmId,
    required this.farmName,
    this.location,
    this.gpsLat,
    this.gpsLng,
    required this.farmerName,
    required this.farmerVerified,
    this.farmerWhatsapp,
    this.pricePerKg,
    required this.totalActiveFruits,
    required this.stage1Count,
    required this.stage2Count,
    required this.stage3Count,
    required this.stage4Count,
    this.earliestHarvestDate,
    this.thumbnailUrl,
    this.avgRating,
    this.reviewCount = 0,
  });

  factory FarmSummary.fromJson(Map<String, dynamic> j) => FarmSummary(
        farmId: j['farm_id'] as int,
        farmName: j['farm_name'] as String,
        location: j['location'] as String?,
        gpsLat: (j['gps_lat'] as num?)?.toDouble(),
        gpsLng: (j['gps_lng'] as num?)?.toDouble(),
        farmerName: j['farmer_name'] as String,
        farmerVerified: j['farmer_verified'] as bool? ?? false,
        farmerWhatsapp: j['farmer_whatsapp'] as String?,
        pricePerKg: (j['price_per_kg'] as num?)?.toDouble(),
        totalActiveFruits: j['total_active_fruits'] as int,
        stage1Count: j['stage_1_count'] as int,
        stage2Count: j['stage_2_count'] as int,
        stage3Count: j['stage_3_count'] as int,
        stage4Count: j['stage_4_count'] as int,
        earliestHarvestDate: j['earliest_harvest_date'] != null
            ? DateTime.tryParse(j['earliest_harvest_date'] as String)
            : null,
        thumbnailUrl: j['thumbnail_url'] as String?,
        avgRating: (j['avg_rating'] as num?)?.toDouble(),
        reviewCount: j['review_count'] as int? ?? 0,
      );
}

class TreeSummary {
  final String treeNumber;
  final int fruitCount;
  final DateTime? earliestHarvestDate;
  final int? growthStage;

  const TreeSummary({
    required this.treeNumber,
    required this.fruitCount,
    this.earliestHarvestDate,
    this.growthStage,
  });

  factory TreeSummary.fromJson(Map<String, dynamic> j) => TreeSummary(
        treeNumber: j['tree_number'] as String,
        fruitCount: j['fruit_count'] as int,
        earliestHarvestDate: j['earliest_harvest_date'] != null
            ? DateTime.tryParse(j['earliest_harvest_date'] as String)
            : null,
        growthStage: j['growth_stage'] as int?,
      );
}

class FarmDetail extends FarmSummary {
  final List<TreeSummary> trees;
  final List<FarmImage> images;

  const FarmDetail({
    required super.farmId,
    required super.farmName,
    super.location,
    super.gpsLat,
    super.gpsLng,
    required super.farmerName,
    required super.farmerVerified,
    super.farmerWhatsapp,
    super.pricePerKg,
    required super.totalActiveFruits,
    required super.stage1Count,
    required super.stage2Count,
    required super.stage3Count,
    required super.stage4Count,
    super.earliestHarvestDate,
    super.thumbnailUrl,
    super.avgRating,
    super.reviewCount,
    required this.trees,
    this.images = const [],
  });

  factory FarmDetail.fromJson(Map<String, dynamic> j) {
    final base = FarmSummary.fromJson(j);
    return FarmDetail(
      farmId: base.farmId,
      farmName: base.farmName,
      location: base.location,
      gpsLat: base.gpsLat,
      gpsLng: base.gpsLng,
      farmerName: base.farmerName,
      farmerVerified: base.farmerVerified,
      farmerWhatsapp: base.farmerWhatsapp,
      pricePerKg: base.pricePerKg,
      totalActiveFruits: base.totalActiveFruits,
      stage1Count: base.stage1Count,
      stage2Count: base.stage2Count,
      stage3Count: base.stage3Count,
      stage4Count: base.stage4Count,
      earliestHarvestDate: base.earliestHarvestDate,
      thumbnailUrl: base.thumbnailUrl,
      avgRating: base.avgRating,
      reviewCount: base.reviewCount,
      trees: (j['trees'] as List)
          .map((t) => TreeSummary.fromJson(t as Map<String, dynamic>))
          .toList(),
      images: ((j['images'] as List?) ?? [])
          .map((i) => FarmImage.fromJson(i as Map<String, dynamic>))
          .toList(),
    );
  }
}
