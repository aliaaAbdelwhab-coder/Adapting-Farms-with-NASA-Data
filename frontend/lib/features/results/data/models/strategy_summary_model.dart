import '../../../farm/data/models/farm_priorities_model.dart';
import '../../../farm/data/models/farm_profile_model.dart';
import '../../../what_if/data/models/what_if_scenario_model.dart';

/// A presentation summary of user-entered inputs; not a recommendation result.
/// Missing data stays null and must never be substituted with Figma demo values.
class StrategySummaryModel {
  const StrategySummaryModel({
    required this.farmName,
    required this.farmLocation,
    this.cultivatedArea,
    this.areaUnit = 'Acres',
    this.country,
    this.governorate,
    this.latitude,
    this.longitude,
    this.soilType,
    this.currentCrop,
    this.farmPriorities,
    this.scenario,
  });

  final String farmName;
  final String farmLocation;
  final double? cultivatedArea;

  /// Original area unit; area value is stored as normalized acres.
  final String areaUnit;

  final String? country;
  final String? governorate;

  /// Selected farm point in WGS84 decimal degrees, when available.
  final double? latitude;
  final double? longitude;
  bool get hasCoordinates =>
      FarmProfileModel.coordinatesAreValid(latitude, longitude);

  double? get displayArea => cultivatedArea == null
      ? null
      : areaUnit == 'Hectares'
      ? cultivatedArea! / 2.471053814671653
      : cultivatedArea;
  final String? soilType;
  final String? currentCrop;
  final FarmPrioritiesModel? farmPriorities;
  final WhatIfScenarioModel? scenario;

  bool get hasFarmDetails =>
      cultivatedArea != null || soilType != null || currentCrop != null;
  bool get hasPriorityInputs => farmPriorities != null;
  bool get hasScenarioInputs => scenario != null;

  factory StrategySummaryModel.fromRouteArguments(Object? routeArguments) {
    final args = routeArguments is Map<String, dynamic>
        ? routeArguments
        : <String, dynamic>{};
    final profile = args['farmProfile'];
    final priorities = args['farmPriorities'];
    final input = args['scenario'];
    final p = profile is FarmProfileModel ? profile : null;
    return StrategySummaryModel(
      farmName:
          p?.farmName ??
          (args['farmName'] is String
              ? args['farmName'] as String
              : 'Your Farm'),
      farmLocation:
          p?.location ??
          (args['farmLocation'] is String
              ? args['farmLocation'] as String
              : 'Location not set'),
      cultivatedArea: p?.cultivatedArea,
      areaUnit: p?.areaUnit ?? 'Acres',
      country: p?.country,
      governorate: p?.governorate,
      latitude: p?.latitude,
      longitude: p?.longitude,
      soilType: p?.soilType,
      currentCrop: p?.currentCrop,
      farmPriorities: priorities is FarmPrioritiesModel ? priorities : null,
      scenario: input is WhatIfScenarioModel ? input : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'farmName': farmName,
    'farmLocation': farmLocation,
    'cultivatedArea': cultivatedArea,
    'areaUnit': areaUnit,
    'country': country,
    'governorate': governorate,
    'latitude': latitude,
    'longitude': longitude,
    'soilType': soilType,
    'currentCrop': currentCrop,
    'farmPriorities': farmPriorities?.toJson(),
    'scenario': scenario?.toJson(),
  };

  factory StrategySummaryModel.fromJson(Map<String, dynamic> json) {
    final priorities = json['farmPriorities'];
    final scenario = json['scenario'];
    return StrategySummaryModel(
      farmName: json['farmName'] as String,
      farmLocation: json['farmLocation'] as String,
      cultivatedArea: (json['cultivatedArea'] as num?)?.toDouble(),
      areaUnit: json['areaUnit'] == 'Hectares' ? 'Hectares' : 'Acres',
      country: json['country'] as String?,
      governorate: json['governorate'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      soilType: json['soilType'] as String?,
      currentCrop: json['currentCrop'] as String?,
      farmPriorities: priorities is Map<String, dynamic>
          ? FarmPrioritiesModel.fromJson(priorities)
          : null,
      scenario: scenario is Map<String, dynamic>
          ? WhatIfScenarioModel.fromJson(scenario)
          : null,
    );
  }
}
