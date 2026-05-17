class FruitResult {
  final String label;
  final double sizeCm;
  final int growthStage;
  final DateTime harvestDate;
  final int daysToHarvest;

  FruitResult({
    required this.label,
    required this.sizeCm,
    required this.growthStage,
    required this.harvestDate,
    required this.daysToHarvest,
  });

  factory FruitResult.fromJson(Map<String, dynamic> json) => FruitResult(
        label: json['label'],
        sizeCm: json['size_cm'].toDouble(),
        growthStage: json['growth_stage'],
        harvestDate: DateTime.parse(json['harvest_date']),
        daysToHarvest: json['days_to_harvest'],
      );

  String get stageName {
    const names = {1: 'Early', 2: 'Mid', 3: 'Late', 4: 'Pre-harvest'};
    return names[growthStage] ?? 'Unknown';
  }
}

class DetectionResponse {
  final int treeId;
  final String treeNumber;
  final DateTime detectionDate;
  final int mangoCount;
  final List<FruitResult> fruits;

  DetectionResponse({
    required this.treeId,
    required this.treeNumber,
    required this.detectionDate,
    required this.mangoCount,
    required this.fruits,
  });

  factory DetectionResponse.fromJson(Map<String, dynamic> json) =>
      DetectionResponse(
        treeId: json['tree_id'],
        treeNumber: json['tree_number'],
        detectionDate: DateTime.parse(json['detection_date']),
        mangoCount: json['mango_count'],
        fruits: (json['fruits'] as List)
            .map((f) => FruitResult.fromJson(f))
            .toList(),
      );
}
