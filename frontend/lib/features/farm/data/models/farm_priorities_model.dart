class FarmPrioritiesModel {
  const FarmPrioritiesModel({
    required this.waterEfficiency,
    required this.soilHealth,
    required this.climateResilience,
    required this.yieldStability,
  });

  final bool waterEfficiency;
  final bool soilHealth;
  final bool climateResilience;
  final bool yieldStability;

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
      waterEfficiency: json['waterEfficiency'] as bool,
      soilHealth: json['soilHealth'] as bool,
      climateResilience: json['climateResilience'] as bool,
      yieldStability: json['yieldStability'] as bool,
    );
  }
}
