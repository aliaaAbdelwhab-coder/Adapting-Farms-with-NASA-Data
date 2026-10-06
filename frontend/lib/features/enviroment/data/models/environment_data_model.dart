class EnvironmentDataModel {
  const EnvironmentDataModel({
    this.temperature,
    this.precipitation,
    this.soilMoisture,
    this.landSurfaceTemperature,
  });

  final double? temperature;
  final double? precipitation;
  final double? soilMoisture;
  final double? landSurfaceTemperature;

  bool get hasData =>
      temperature != null ||
      precipitation != null ||
      soilMoisture != null ||
      landSurfaceTemperature != null;

  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'precipitation': precipitation,
      'soilMoisture': soilMoisture,
      'landSurfaceTemperature': landSurfaceTemperature,
    };
  }

  factory EnvironmentDataModel.fromJson(Map<String, dynamic> json) {
    return EnvironmentDataModel(
      temperature: (json['temperature'] as num?)?.toDouble(),
      precipitation: (json['precipitation'] as num?)?.toDouble(),
      soilMoisture: (json['soilMoisture'] as num?)?.toDouble(),
      landSurfaceTemperature: (json['landSurfaceTemperature'] as num?)
          ?.toDouble(),
    );
  }
}
