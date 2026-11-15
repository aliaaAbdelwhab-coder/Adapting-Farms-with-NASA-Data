import '../../features/enviroment/data/models/environment_data_model.dart';
import '../../features/farm/data/models/farm_analysis_result.dart';
import '../../features/farm/data/models/farm_profile_model.dart';
import '../../features/farm/data/models/farm_priorities_model.dart';
import '../../features/farm/data/models/rotation_plan_model.dart';
import '../../features/what_if/data/models/what_if_scenario_model.dart';

/// Current in-memory editing context ONLY. Nothing is saved on disk.
/// A browser refresh/app restart resets these inputs.
class FieldShiftSession {
  FieldShiftSession._();

  static final FieldShiftSession instance = FieldShiftSession._();

  FarmProfileModel? farmProfile;
  FarmPrioritiesModel? farmPriorities;
  WhatIfScenarioModel? scenario;

  /// Latest backend analysis output, populated by the priorities step.
  EnvironmentDataModel? environmentData;
  List<RotationPlanModel>? rotationPlans;
  List<String> overallNotes = const <String>[];
  List<String> validationWarnings = const <String>[];
  bool _editRequested = false;

  void setFarmProfile(FarmProfileModel profile) {
    farmProfile = profile;
    // Changing farms invalidates the previous farm's priorities/scenario.
    farmPriorities = null;
    scenario = null;
    clearAnalysisResult();
    _editRequested = false;
  }

  void setFarmPriorities(FarmPrioritiesModel priorities) {
    farmPriorities = priorities;
    scenario = null;
  }

  void setAnalysisResult(FarmAnalysisResult result) {
    environmentData = result.environmentData;
    rotationPlans = result.plans;
    overallNotes = result.overallNotes;
    validationWarnings = result.validationWarnings;
  }

  void clearAnalysisResult() {
    environmentData = null;
    rotationPlans = null;
    overallNotes = const <String>[];
    validationWarnings = const <String>[];
  }

  void requestEdit() => _editRequested = true;

  /// Prefill only for an explicit Edit action, not for a new-farm flow.
  FarmProfileModel? takeEditProfile() {
    final profile = _editRequested ? farmProfile : null;
    _editRequested = false;
    return profile;
  }

  void reset() {
    farmProfile = null;
    farmPriorities = null;
    scenario = null;
    clearAnalysisResult();
    _editRequested = false;
  }
}
