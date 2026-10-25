import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/what_if/data/models/what_if_scenario_model.dart';

void main() {
  test('Figma input defaults are recorded without calculated outcomes', () {
    const model = WhatIfScenarioModel();
    expect(model.rainfallChangePercent, -15);
    expect(model.temperatureChangeCelsius, 2);
    expect(model.waterAvailabilityChangePercent, -10);
    expect(model.isBaseline, false);
  });

  test('Three neutral shifts form a baseline', () {
    const model = WhatIfScenarioModel(
      rainfallChangePercent: 0,
      temperatureChangeCelsius: 0,
      waterAvailabilityChangePercent: 0,
    );
    expect(model.isBaseline, true);
  });

  test('Scenario inputs round-trip through JSON', () {
    const original = WhatIfScenarioModel(
      rainfallChangePercent: 10,
      temperatureChangeCelsius: -2,
      waterAvailabilityChangePercent: 25,
    );
    final restored = WhatIfScenarioModel.fromJson(original.toJson());
    expect(restored.rainfallChangePercent, 10);
    expect(restored.temperatureChangeCelsius, -2);
    expect(restored.waterAvailabilityChangePercent, 25);
  });

  test('copyWith only replaces the requested scenario dimension', () {
    const original = WhatIfScenarioModel();
    final changed = original.copyWith(rainfallChangePercent: -25);
    expect(changed.rainfallChangePercent, -25);
    expect(changed.temperatureChangeCelsius, 2);
    expect(changed.waterAvailabilityChangePercent, -10);
  });

  test('Non-numeric or out-of-range values are rejected', () {
    final base = const WhatIfScenarioModel().toJson();
    expect(
      () => WhatIfScenarioModel.fromJson({
        ...base,
        'rainfallChangePercent': 'severe',
      }),
      throwsFormatException,
    );
    expect(
      () => WhatIfScenarioModel.fromJson({
        ...base,
        'waterAvailabilityChangePercent': -99,
      }),
      throwsFormatException,
    );
  });
}
