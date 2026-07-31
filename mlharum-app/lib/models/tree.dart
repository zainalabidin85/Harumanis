class Tree {
  final int id;
  final String treeNumber;
  final double? gpsLat;
  final double? gpsLng;
  final String? notes;

  Tree({
    required this.id,
    required this.treeNumber,
    this.gpsLat,
    this.gpsLng,
    this.notes,
  });

  factory Tree.fromJson(Map<String, dynamic> json) => Tree(
        id: json['id'],
        treeNumber: json['tree_number'],
        gpsLat: json['gps_lat']?.toDouble(),
        gpsLng: json['gps_lng']?.toDouble(),
        notes: json['notes'],
      );
}

class TreeDashboard {
  final String treeNumber;
  final double? gpsLat;
  final double? gpsLng;
  final int fruitCount;
  final DateTime? earliestHarvestDate;
  final int? growthStage;

  TreeDashboard({
    required this.treeNumber,
    this.gpsLat,
    this.gpsLng,
    required this.fruitCount,
    this.earliestHarvestDate,
    this.growthStage,
  });

  factory TreeDashboard.fromJson(Map<String, dynamic> json) => TreeDashboard(
        treeNumber: json['tree_number'],
        gpsLat: json['gps_lat']?.toDouble(),
        gpsLng: json['gps_lng']?.toDouble(),
        fruitCount: json['fruit_count'],
        earliestHarvestDate: json['earliest_harvest_date'] != null
            ? DateTime.parse(json['earliest_harvest_date'])
            : null,
        growthStage: json['growth_stage'],
      );

  int get daysToHarvest => earliestHarvestDate != null
      ? earliestHarvestDate!.difference(DateTime.now()).inDays
      : 999;
}

class FarmDashboard {
  final int farmId;
  final String farmName;
  final int currentSeason;
  final int totalTrees;
  final int totalActiveFruits;
  final int totalHarvestedFruits;
  final int totalAbortedFruits;
  final List<TreeDashboard> trees;

  FarmDashboard({
    required this.farmId,
    required this.farmName,
    required this.currentSeason,
    required this.totalTrees,
    required this.totalActiveFruits,
    required this.totalHarvestedFruits,
    required this.totalAbortedFruits,
    required this.trees,
  });

  factory FarmDashboard.fromJson(Map<String, dynamic> json) => FarmDashboard(
        farmId: json['farm_id'],
        farmName: json['farm_name'],
        currentSeason: json['current_season'],
        totalTrees: json['total_trees'],
        totalActiveFruits: json['total_active_fruits'],
        totalHarvestedFruits: json['total_harvested_fruits'],
        totalAbortedFruits: json['total_aborted_fruits'],
        trees: (json['trees'] as List)
            .map((t) => TreeDashboard.fromJson(t))
            .toList(),
      );
}
