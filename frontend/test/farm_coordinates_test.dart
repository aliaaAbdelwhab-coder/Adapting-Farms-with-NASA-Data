import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/farm/data/models/farm_profile_model.dart';
import 'package:frontend/features/results/data/models/strategy_summary_model.dart';
import 'package:frontend/core/state/fieldshift_session.dart';

void main() {
  const farm = FarmProfileModel(
    farmName: 'Sample Farm',
    location: 'Makkah, Saudi Arabia',
    country: 'Saudi Arabia',
    governorate: 'Makkah',
    cultivatedArea: 25,
    soilType: 'Loam',
    currentCrop: 'Wheat',
    waterSource: 'Mixed',
    latitude: 21.422510,
    longitude: 39.826168,
  );

  test('Selected coordinates serialize as numeric latitude and longitude', () {
    expect(farm.hasCoordinates, isTrue);
    final json = farm.toJson();
    expect(json['country'], 'Saudi Arabia');
    expect(json['governorate'], 'Makkah');
    expect(json['latitude'], isA<double>());
    expect(json['longitude'], isA<double>());
    expect(json['latitude'], 21.422510);
    expect(json['longitude'], 39.826168);
    final restored = FarmProfileModel.fromJson(json);
    expect(restored.country, farm.country);
    expect(restored.governorate, farm.governorate);
    expect(restored.latitude, farm.latitude);
    expect(restored.longitude, farm.longitude);
  });

  test('WGS84 coordinate ranges are validated and require both fields', () {
    expect(FarmProfileModel.coordinatesAreValid(90, -180), isTrue);
    expect(FarmProfileModel.coordinatesAreValid(-90, 180), isTrue);
    expect(FarmProfileModel.coordinatesAreValid(90.1, 0), isFalse);
    expect(FarmProfileModel.coordinatesAreValid(0, -180.1), isFalse);
    expect(FarmProfileModel.coordinatesAreValid(null, 10), isFalse);
    expect(FarmProfileModel.coordinatesAreValid(double.nan, 1), isFalse);
    expect(FarmProfileModel.coordinatesAreValid(0, double.infinity), isFalse);
  });

  test('Legacy saved farms remain readable without coordinates', () {
    final legacy = FarmProfileModel.fromJson({
      'farmName': 'Old', 'location': 'City', 'cultivatedArea': 12,
      'soilType': 'Clay', 'currentCrop': 'Corn', 'waterSource': 'Rain-fed',
    });
    expect(legacy.country, isNull);
    expect(legacy.governorate, isNull);
    expect(legacy.hasCoordinates, isFalse);
    expect(legacy.latitude, isNull);
    expect(legacy.longitude, isNull);
  });

  test('Coordinates remain available in session and strategy summary', () {
    final session = FieldShiftSession.instance;
    addTearDown(session.reset);
    session.setFarmProfile(farm);
    session.requestEdit();
    final edit = session.takeEditProfile();
    expect(edit?.country, 'Saudi Arabia');
    expect(edit?.governorate, 'Makkah');
    expect(edit?.latitude, 21.422510);
    expect(edit?.longitude, 39.826168);
    final summary = StrategySummaryModel.fromRouteArguments({'farmProfile': farm});
    expect(summary.country, 'Saudi Arabia');
    expect(summary.governorate, 'Makkah');
    expect(summary.hasCoordinates, isTrue);
    final restored = StrategySummaryModel.fromJson(summary.toJson());
    expect(restored.latitude, farm.latitude);
    expect(restored.longitude, farm.longitude);
    expect(restored.country, farm.country);
    expect(restored.governorate, farm.governorate);
  });

  test('Backend location JSON has the four agreed fields only', () {
    expect(farm.hasCompleteLocation, isTrue);
    expect(farm.toBackendLocationJson(), {
      'country': 'Saudi Arabia',
      'governorate': 'Makkah',
      'latitude': 21.422510,
      'longitude': 39.826168,
    });
  });

  test('Incomplete administrative location is not backend-ready', () {
    const missingRegion = FarmProfileModel(
      farmName: 'Missing', location: 'Egypt', cultivatedArea: 20,
      soilType: 'Clay', currentCrop: 'Corn', waterSource: 'Rain-fed',
      country: 'Egypt', latitude: 31.0, longitude: 30.0,
    );
    expect(missingRegion.hasCoordinates, isTrue);
    expect(missingRegion.hasCompleteLocation, isFalse);
  });
}

