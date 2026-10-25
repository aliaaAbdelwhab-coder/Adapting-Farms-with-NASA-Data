import '../../features/farm/data/models/farm_profile_model.dart';
import '../../features/farm/data/models/farm_priorities_model.dart';
import '../../features/what_if/data/models/what_if_scenario_model.dart';

/// Current in-memory editing context ONLY. Nothing is saved on disk or sent
/// to a server. A browser refresh/app restart resets these inputs.
class FieldShiftSession {
  FieldShiftSession._();

  static final FieldShiftSession instance = FieldShiftSession._();

  FarmProfileModel? farmProfile;
  FarmPrioritiesModel? farmPriorities;
  WhatIfScenarioModel? scenario;
  bool _editRequested = false;

  void setFarmProfile(FarmProfileModel profile) {
    farmProfile = profile;
    // Changing farms invalidates the previous farm's priorities/scenario.
    farmPriorities = null;
    scenario = null;
    _editRequested = false;
  }

  void setFarmPriorities(FarmPrioritiesModel priorities) {
    farmPriorities = priorities;
    scenario = null;
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
    _editRequested = false;
  }
}
