/// Environmental observations received from a verified data service.
/// All readings are optional: null means not available, not zero.
class EnvironmentDataModel {
  const EnvironmentDataModel({
    this.temperature,
    this.precipitation,
    this.soilMoisture,
    this.landSurfaceTemperature,
    this.vegetationIndex,
    this.solarRadiation,
    this.growingSeasonDays,
    this.monthlyMeanTemperatureC,
    this.monthlyPrecipitationMm,
  }) : assert(
         monthlyMeanTemperatureC == null ||
             monthlyMeanTemperatureC.length == 12,
       ),
       assert(
         monthlyPrecipitationMm == null || monthlyPrecipitationMm.length == 12,
       );

  /// Air temperature (°C), if the service supplies it.
  final double? temperature;

  /// Precipitation (mm) for the reporting period defined by the data service.
  final double? precipitation;

  /// Volumetric soil moisture (m³/m³).
  final double? soilMoisture;

  /// Land surface temperature (°C); not the same as air temperature.
  final double? landSurfaceTemperature;

  /// Normalized difference vegetation index (NDVI).
  final double? vegetationIndex;

  /// Mean daily solar radiation (kWh/m²/day).
  final double? solarRadiation;

  /// Growing season length in days.
  final int? growingSeasonDays;

  /// Twelve monthly average temperatures (°C), Jan through Dec.
  final List<double?>? monthlyMeanTemperatureC;

  /// Twelve monthly precipitation totals (mm), Jan through Dec.
  final List<double?>? monthlyPrecipitationMm;

  bool get hasData =>
      temperature != null ||
      precipitation != null ||
      soilMoisture != null ||
      landSurfaceTemperature != null ||
      vegetationIndex != null ||
      solarRadiation != null ||
      growingSeasonDays != null ||
      (monthlyMeanTemperatureC?.any((v) => v != null) ?? false) ||
      (monthlyPrecipitationMm?.any((v) => v != null) ?? false);

  bool get hasMonthlyData =>
      (monthlyMeanTemperatureC?.any((v) => v != null) ?? false) ||
      (monthlyPrecipitationMm?.any((v) => v != null) ?? false);

  Map<String, dynamic> toJson() => {
    'temperature': temperature,
    'precipitation': precipitation,
    'soilMoisture': soilMoisture,
    'landSurfaceTemperature': landSurfaceTemperature,
    'vegetationIndex': vegetationIndex,
    'solarRadiation': solarRadiation,
    'growingSeasonDays': growingSeasonDays,
    'monthlyMeanTemperatureC': monthlyMeanTemperatureC,
    'monthlyPrecipitationMm': monthlyPrecipitationMm,
  };

  factory EnvironmentDataModel.fromJson(Map<String, dynamic> json) {
    return EnvironmentDataModel(
      temperature: (json['temperature'] as num?)?.toDouble(),
      precipitation: (json['precipitation'] as num?)?.toDouble(),
      soilMoisture: (json['soilMoisture'] as num?)?.toDouble(),
      landSurfaceTemperature: (json['landSurfaceTemperature'] as num?)
          ?.toDouble(),
      vegetationIndex: (json['vegetationIndex'] as num?)?.toDouble(),
      solarRadiation: (json['solarRadiation'] as num?)?.toDouble(),
      growingSeasonDays: (json['growingSeasonDays'] as num?)?.toInt(),
      monthlyMeanTemperatureC: _readMonthlySeries(
        json['monthlyMeanTemperatureC'],
      ),
      monthlyPrecipitationMm: _readMonthlySeries(
        json['monthlyPrecipitationMm'],
      ),
    );
  }

  static List<double?>? _readMonthlySeries(Object? value) {
    if (value == null) return null;
    if (value is! List || value.length != 12) {
      throw const FormatException('Monthly series must contain 12 values.');
    }
    return value
        .map((item) {
          if (item == null) return null;
          if (item is! num) {
            throw const FormatException('Invalid monthly environmental value.');
          }
          return item.toDouble();
        })
        .toList(growable: false);
  }
}
