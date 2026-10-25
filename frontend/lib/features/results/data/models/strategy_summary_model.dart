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
    this.soilType,
    this.currentCrop,
    this.farmPriorities,
    this.scenario,
  });

  final String farmName;
  final String farmLocation;
  final double? cultivatedArea;
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
