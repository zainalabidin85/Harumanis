class DoaStageCount {
  final int stage;
  final String label;
  final int count;

  const DoaStageCount({required this.stage, required this.label, required this.count});

  factory DoaStageCount.fromJson(Map<String, dynamic> json) => DoaStageCount(
        stage: json['stage'] as int,
        label: json['label'] as String,
        count: json['count'] as int,
      );
}

class DoaFarmSummary {
  final int farmId;
  final String farmName;
  final String? location;
  final int ownerId;
  final String ownerName;
  final String? ownerPhone;
  final bool isVerified;
  final int totalTrees;
  final int activeFruits;
  final int harvestedFruits;
  final int abortedFruits;
  final List<DoaStageCount> stageCounts;

  const DoaFarmSummary({
    required this.farmId,
    required this.farmName,
    required this.location,
    required this.ownerId,
    required this.ownerName,
    required this.ownerPhone,
    required this.isVerified,
    required this.totalTrees,
    required this.activeFruits,
    required this.harvestedFruits,
    required this.abortedFruits,
    required this.stageCounts,
  });

  factory DoaFarmSummary.fromJson(Map<String, dynamic> json) => DoaFarmSummary(
        farmId: json['farm_id'] as int,
        farmName: json['farm_name'] as String,
        location: json['location'] as String?,
        ownerId: json['owner_id'] as int,
        ownerName: json['owner_name'] as String,
        ownerPhone: json['owner_phone'] as String?,
        isVerified: json['is_verified'] as bool,
        totalTrees: json['total_trees'] as int,
        activeFruits: json['active_fruits'] as int,
        harvestedFruits: json['harvested_fruits'] as int,
        abortedFruits: json['aborted_fruits'] as int,
        stageCounts: (json['stage_counts'] as List)
            .map((e) => DoaStageCount.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class DoaYieldReport {
  final int currentSeason;
  final List<int> availableSeasons;
  final int totalFarms;
  final int totalTrees;
  final int totalActiveFruits;
  final int totalHarvestedFruits;
  final int totalAbortedFruits;
  final List<DoaStageCount> stageSummary;
  final List<DoaFarmSummary> farms;

  const DoaYieldReport({
    required this.currentSeason,
    required this.availableSeasons,
    required this.totalFarms,
    required this.totalTrees,
    required this.totalActiveFruits,
    required this.totalHarvestedFruits,
    required this.totalAbortedFruits,
    required this.stageSummary,
    required this.farms,
  });

  factory DoaYieldReport.fromJson(Map<String, dynamic> json) => DoaYieldReport(
        currentSeason: json['current_season'] as int,
        availableSeasons: (json['available_seasons'] as List).map((e) => e as int).toList(),
        totalFarms: json['total_farms'] as int,
        totalTrees: json['total_trees'] as int,
        totalActiveFruits: json['total_active_fruits'] as int,
        totalHarvestedFruits: json['total_harvested_fruits'] as int,
        totalAbortedFruits: json['total_aborted_fruits'] as int,
        stageSummary: (json['stage_summary'] as List)
            .map((e) => DoaStageCount.fromJson(e as Map<String, dynamic>))
            .toList(),
        farms: (json['farms'] as List)
            .map((e) => DoaFarmSummary.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
