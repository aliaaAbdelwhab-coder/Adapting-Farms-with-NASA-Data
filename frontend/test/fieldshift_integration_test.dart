import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/core/state/fieldshift_session.dart';
import 'package:frontend/features/farm/data/models/farm_profile_model.dart';
import 'package:frontend/features/results/data/models/strategy_summary_model.dart';
void main() {
  final session = FieldShiftSession.instance;

  tearDown(session.reset);

  test('Stores selected hectares but normalizes cultivatedArea to acres', () {
    const acres = 24.71053814671653;
    const p = FarmProfileModel(
      farmName: 'Example',
      location: 'Test area',
      cultivatedArea: acres,
      soilType: 'Loam',
      currentCrop: 'Corn',
      waterSource: 'Rain-fed',
      areaUnit: 'Hectares',
    );
    expect(p.displayArea, closeTo(10, 0.00001));
    expect(FarmProfileModel.fromJson(p.toJson()).areaUnit, 'Hectares');
    expect(
      FarmProfileModel.fromJson(p.toJson()).displayArea,
      closeTo(10, 0.00001),
    );
    final summary = StrategySummaryModel.fromRouteArguments({'farmProfile': p});
    expect(summary.areaUnit, 'Hectares');
    expect(summary.displayArea, closeTo(10, 0.00001));
    expect(
      StrategySummaryModel.fromJson(summary.toJson()).areaUnit,
      'Hectares',
    );
  });

  test('Legacy farm JSON defaults to Acres safely', () {
    final p = FarmProfileModel.fromJson({
      'farmName': 'Example',
      'location': 'Test',
      'cultivatedArea': 20,
      'soilType': 'Clay',
      'currentCrop': 'Wheat',
      'waterSource': 'Mixed',
    });
    expect(p.areaUnit, 'Acres');
    expect(p.displayArea, 20);
  });

  test('Edit prefill only on explicit edit request', () {
    const p = FarmProfileModel(
      farmName: 'My Farm',
      location: 'Test',
      cultivatedArea: 30,
      soilType: 'Loam',
      currentCrop: 'Corn',
      waterSource: 'Mixed',
    );
    session.setFarmProfile(p);
    expect(session.takeEditProfile(), isNull);
    session.requestEdit();
    expect(session.takeEditProfile(), same(p));
    expect(session.takeEditProfile(), isNull);
  });

  test('Changing farm clears previous priorities and scenario context', () {
    const p = FarmProfileModel(
      farmName: 'Fresh Farm',
      location: 'Test',
      cultivatedArea: 20,
      soilType: 'Loam',
      currentCrop: 'Corn',
      waterSource: 'Mixed',
    );
    session.setFarmProfile(p);
    expect(session.farmProfile?.farmName, 'Fresh Farm');
    expect(session.farmPriorities, isNull);
    expect(session.scenario, isNull);
  });
}
