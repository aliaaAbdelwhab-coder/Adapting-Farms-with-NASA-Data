import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/enviroment/data/models/environment_data_model.dart';

void main() {
  test('Unconnected NASA data stays empty and never becomes zero', () {
    const model = EnvironmentDataModel();
    expect(model.hasData, false);
    expect(model.hasMonthlyData, false);
    expect(model.temperature, null);
    expect(model.vegetationIndex, null);
  });

  test('Existing environmental JSON fields remain compatible', () {
    const original = EnvironmentDataModel(
      temperature: 25.2,
      precipitation: 12.5,
      soilMoisture: 0.22,
      landSurfaceTemperature: 31.0,
    );
    final decoded = EnvironmentDataModel.fromJson(original.toJson());
    expect(decoded.temperature, 25.2);
    expect(decoded.precipitation, 12.5);
    expect(decoded.soilMoisture, 0.22);
    expect(decoded.landSurfaceTemperature, 31.0);
    expect(decoded.hasData, true);
  });

  test('Additional metrics and monthly data round trip', () {
    final source = EnvironmentDataModel(
      vegetationIndex: 0.72,
      solarRadiation: 5.24,
      growingSeasonDays: 245,
      monthlyMeanTemperatureC: List<double?>.generate(
        12,
        (i) => 15 + i.toDouble(),
      ),
      monthlyPrecipitationMm: List<double?>.generate(
        12,
        (i) => i.isEven ? 10.0 : null,
      ),
    );
    final restored = EnvironmentDataModel.fromJson(source.toJson());
    expect(restored.vegetationIndex, 0.72);
    expect(restored.solarRadiation, 5.24);
    expect(restored.growingSeasonDays, 245);
    expect(restored.hasMonthlyData, true);
    expect(restored.monthlyMeanTemperatureC?.length, 12);
    expect(restored.monthlyPrecipitationMm?[1], null);
  });

  test('Malformed time-series payload is rejected', () {
    expect(
      () => EnvironmentDataModel.fromJson({
        'monthlyPrecipitationMm': [1, 2, 3],
      }),
      throwsFormatException,
    );
  });
}
