import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/farm/data/models/farm_priorities_model.dart';
import 'package:frontend/features/farm/data/models/farm_profile_model.dart';
import 'package:frontend/features/results/data/models/strategy_summary_model.dart';
import 'package:frontend/features/what_if/data/models/what_if_scenario_model.dart';

void main() {
  const farm = FarmProfileModel(
    farmName: 'Green Field',
    location: 'Makkah',
    cultivatedArea: 12.5,
    soilType: 'Loam',
    currentCrop: 'Wheat',
    waterSource: 'Irrigated',
  );
  const priorities = FarmPrioritiesModel(
    waterEfficiency: 80,
    soilHealth: 90,
    climateResilience: 65,
    yieldStability: 40,
  );
  const scenario = WhatIfScenarioModel(
    rainfallChangePercent: -15,
    temperatureChangeCelsius: 2,
    waterAvailabilityChangePercent: -10,
  );

  test('preserves the user-provided farm and priorities', () {
    final model = StrategySummaryModel.fromRouteArguments({
      'farmProfile': farm,
      'farmPriorities': priorities,
      'scenario': scenario,
    });
    expect(model.farmName, 'Green Field');
    expect(model.farmLocation, 'Makkah');
    expect(model.cultivatedArea, 12.5);
    expect(model.soilType, 'Loam');
    expect(model.farmPriorities?.soilHealth, 90);
    expect(model.scenario?.rainfallChangePercent, -15);
  });

  test('falls back to name/location when full models are unavailable', () {
    final model = StrategySummaryModel.fromRouteArguments({
      'farmName': 'Test Farm',
      'farmLocation': 'Jeddah',
    });
    expect(model.farmName, 'Test Farm');
    expect(model.cultivatedArea, isNull);
    expect(model.hasPriorityInputs, isFalse);
    expect(model.hasScenarioInputs, isFalse);
  });

  test('empty route arguments never invent results', () {
    final model = StrategySummaryModel.fromRouteArguments(null);
    expect(model.farmName, 'Your Farm');
    expect(model.hasFarmDetails, isFalse);
    expect(model.farmPriorities, isNull);
    expect(model.scenario, isNull);
  });

  test('serializes and restores all entered data', () {
    final original = StrategySummaryModel.fromRouteArguments({
      'farmProfile': farm,
      'farmPriorities': priorities,
      'scenario': scenario,
    });
    final restored = StrategySummaryModel.fromJson(original.toJson());
    expect(restored.farmName, original.farmName);
    expect(restored.cultivatedArea, original.cultivatedArea);
    expect(restored.farmPriorities?.waterEfficiency, 80);
    expect(restored.scenario?.temperatureChangeCelsius, 2);
  });
}
