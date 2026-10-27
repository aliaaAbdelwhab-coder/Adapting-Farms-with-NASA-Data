/// User-selected priority scores on a 0–100 scale.
/// These are preferences, not measured NASA environmental values.
class FarmPrioritiesModel {
  const FarmPrioritiesModel({
    required this.waterEfficiency,
    required this.soilHealth,
    required this.climateResilience,
    required this.yieldStability,
  }) : assert(waterEfficiency >= 0 && waterEfficiency <= 100),
       assert(soilHealth >= 0 && soilHealth <= 100),
       assert(climateResilience >= 0 && climateResilience <= 100),
       assert(yieldStability >= 0 && yieldStability <= 100);

  final int waterEfficiency;
  final int soilHealth;
  final int climateResilience;
  final int yieldStability;

  Map<String, dynamic> toJson() {
    return {
      'waterEfficiency': waterEfficiency,
      'soilHealth': soilHealth,
      'climateResilience': climateResilience,
      'yieldStability': yieldStability,
    };
  }

  factory FarmPrioritiesModel.fromJson(Map<String, dynamic> json) {
    return FarmPrioritiesModel(
      waterEfficiency: (json['waterEfficiency'] as num).toInt(),
      soilHealth: (json['soilHealth'] as num).toInt(),
      climateResilience: (json['climateResilience'] as num).toInt(),
      yieldStability: (json['yieldStability'] as num).toInt(),
    );
  }
}
