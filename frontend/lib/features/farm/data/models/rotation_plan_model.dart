/// A crop rotation candidate provided by a future recommendation engine.
///
/// This data object carries values; it does not calculate suitability scores.
/// Numeric scores are nullable: null means the source did not provide them.
class RotationPlanModel {
  const RotationPlanModel({
    required this.id,
    required this.title,
    required this.description,
    required this.badgeLabel,
    this.matchPercent,
    required this.crops,
    this.waterDemandLabel,
    this.waterDemandPercent,
    this.soilHealthScore,
    this.climateResilienceScore,
    this.biomassNitrogen = 'Not available',
    this.rootingDepth = 'Not available',
  }) : assert(matchPercent == null ||
            (matchPercent >= 0 && matchPercent <= 100)),
       assert(waterDemandPercent == null ||
            (waterDemandPercent >= 0 && waterDemandPercent <= 100)),
       assert(soilHealthScore == null ||
            (soilHealthScore >= 0 && soilHealthScore <= 100)),
       assert(climateResilienceScore == null ||
            (climateResilienceScore >= 0 && climateResilienceScore <= 100));

  final String id;
  final String title;
  final String description;
  final String badgeLabel;
  final int? matchPercent;
  final List<String> crops;
  final String? waterDemandLabel;
  final int? waterDemandPercent;
  final int? soilHealthScore;
  final int? climateResilienceScore;
  final String biomassNitrogen;
  final String rootingDepth;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'badgeLabel': badgeLabel,
    'matchPercent': matchPercent,
    'crops': crops,
    'waterDemandLabel': waterDemandLabel,
    'waterDemandPercent': waterDemandPercent,
    'soilHealthScore': soilHealthScore,
    'climateResilienceScore': climateResilienceScore,
    'biomassNitrogen': biomassNitrogen,
    'rootingDepth': rootingDepth,
  };

  factory RotationPlanModel.fromJson(Map<String, dynamic> json) {
    int? percentage(String key) {
      final value = json[key];
      if (value == null) return null;
      if (value is! num || !value.isFinite || value < 0 || value > 100) {
        throw FormatException('$key must be a number from 0 to 100.');
      }
      return value.round();
    }

    final cropItems = json['crops'];
    if (cropItems is! List || cropItems.any((item) => item is! String)) {
      throw const FormatException('crops must be a list of strings.');
    }

    return RotationPlanModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      badgeLabel: json['badgeLabel'] as String,
      matchPercent: percentage('matchPercent'),
      crops: List<String>.unmodifiable(cropItems.cast<String>()),
      waterDemandLabel: json['waterDemandLabel'] as String?,
      waterDemandPercent: percentage('waterDemandPercent'),
      soilHealthScore: percentage('soilHealthScore'),
      climateResilienceScore: percentage('climateResilienceScore'),
      biomassNitrogen: json['biomassNitrogen'] as String? ?? 'Not available',
      rootingDepth: json['rootingDepth'] as String? ?? 'Not available',
    );
  }
}
