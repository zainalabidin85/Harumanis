class FruitResult {
  final int id;
  final String label;
  final double sizeCm;
  final int growthStage;
  final DateTime harvestDate;
  final int daysToHarvest;
  final double bboxX;
  final double bboxY;
  final double bboxW;
  final double bboxH;

  FruitResult({
    required this.id,
    required this.label,
    required this.sizeCm,
    required this.growthStage,
    required this.harvestDate,
    required this.daysToHarvest,
    required this.bboxX,
    required this.bboxY,
    required this.bboxW,
    required this.bboxH,
  });

  factory FruitResult.fromJson(Map<String, dynamic> json) => FruitResult(
        id: json['id'] as int,
        label: json['label'],
        sizeCm: (json['size_cm'] as num).toDouble(),
        growthStage: json['growth_stage'],
        harvestDate: DateTime.parse(json['harvest_date']),
        daysToHarvest: json['days_to_harvest'],
        bboxX: (json['bbox_x'] as num).toDouble(),
        bboxY: (json['bbox_y'] as num).toDouble(),
        bboxW: (json['bbox_w'] as num).toDouble(),
        bboxH: (json['bbox_h'] as num).toDouble(),
      );

  String get stageName {
    const names = {1: 'Early', 2: 'Mid', 3: 'Late', 4: 'Pre-harvest'};
    return names[growthStage] ?? 'Unknown';
  }
}

class ActiveFruit {
  final int id;
  final String label;
  final double sizeCm;
  final int growthStage;
  final DateTime harvestDate;
  final int daysToHarvest;
  final bool isHarvested;
  final bool isAborted;
  final String? abortReason;

  ActiveFruit({
    required this.id,
    required this.label,
    required this.sizeCm,
    required this.growthStage,
    required this.harvestDate,
    required this.daysToHarvest,
    required this.isHarvested,
    required this.isAborted,
    this.abortReason,
  });

  factory ActiveFruit.fromJson(Map<String, dynamic> json) => ActiveFruit(
        id: json['id'] as int,
        label: json['label'],
        sizeCm: (json['size_cm'] as num).toDouble(),
        growthStage: json['growth_stage'],
        harvestDate: DateTime.parse(json['harvest_date']),
        daysToHarvest: json['days_to_harvest'],
        isHarvested: json['is_harvested'] as bool,
        isAborted: json['is_aborted'] as bool,
        abortReason: json['abort_reason'] as String?,
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
  final bool readyForBagging;
  final String message;
  final List<FruitResult> fruits;

  DetectionResponse({
    required this.treeId,
    required this.treeNumber,
    required this.detectionDate,
    required this.mangoCount,
    required this.readyForBagging,
    required this.message,
    required this.fruits,
  });

  factory DetectionResponse.fromJson(Map<String, dynamic> json) =>
      DetectionResponse(
        treeId: json['tree_id'],
        treeNumber: json['tree_number'],
        detectionDate: DateTime.parse(json['detection_date']),
        mangoCount: json['mango_count'],
        readyForBagging: json['ready_for_bagging'] as bool,
        message: json['message'] as String,
        fruits: (json['fruits'] as List)
            .map((f) => FruitResult.fromJson(f))
            .toList(),
      );
}
