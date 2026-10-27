/// Scenario inputs only. This model does NOT estimate crop outcomes.
class WhatIfScenarioModel {
  const WhatIfScenarioModel({
    this.rainfallChangePercent = -15,
    this.temperatureChangeCelsius = 2,
    this.waterAvailabilityChangePercent = -10,
  }) : assert(rainfallChangePercent >= -30 && rainfallChangePercent <= 30),
       assert(temperatureChangeCelsius >= -3 && temperatureChangeCelsius <= 5),
       assert(
         waterAvailabilityChangePercent >= -50 &&
             waterAvailabilityChangePercent <= 50,
       );

  final double rainfallChangePercent;
  final double temperatureChangeCelsius;
  final double waterAvailabilityChangePercent;

  bool get isBaseline =>
      rainfallChangePercent == 0 &&
      temperatureChangeCelsius == 0 &&
      waterAvailabilityChangePercent == 0;

  WhatIfScenarioModel copyWith({
    double? rainfallChangePercent,
    double? temperatureChangeCelsius,
    double? waterAvailabilityChangePercent,
  }) {
    return WhatIfScenarioModel(
      rainfallChangePercent:
          rainfallChangePercent ?? this.rainfallChangePercent,
      temperatureChangeCelsius:
          temperatureChangeCelsius ?? this.temperatureChangeCelsius,
      waterAvailabilityChangePercent:
          waterAvailabilityChangePercent ?? this.waterAvailabilityChangePercent,
    );
  }

  Map<String, dynamic> toJson() => {
    'rainfallChangePercent': rainfallChangePercent,
    'temperatureChangeCelsius': temperatureChangeCelsius,
    'waterAvailabilityChangePercent': waterAvailabilityChangePercent,
  };

  factory WhatIfScenarioModel.fromJson(Map<String, dynamic> json) {
    double field(String key, double min, double max) {
      final raw = json[key];
      if (raw is! num) {
        throw FormatException('Expected a numeric $key.');
      }
      final result = raw.toDouble();
      if (!result.isFinite || result < min || result > max) {
        throw FormatException('$key is outside the supported range.');
      }
      return result;
    }

    return WhatIfScenarioModel(
      rainfallChangePercent: field('rainfallChangePercent', -30, 30),
      temperatureChangeCelsius: field('temperatureChangeCelsius', -3, 5),
      waterAvailabilityChangePercent: field(
        'waterAvailabilityChangePercent',
        -50,
        50,
      ),
    );
  }
}
