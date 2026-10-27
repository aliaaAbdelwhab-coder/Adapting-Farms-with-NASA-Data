import 'package:flutter/material.dart';

import '../state/fieldshift_session.dart';

import '../../features/enviroment/presentation/screens/environment_screen.dart'
    show EnvironmentScreen;
import '../../features/farm/presentation/screens/farm_setup_screen.dart';
import '../../features/onboarding/presentation/screens/welcome_screen.dart';
import '../../features/farm/presentation/screens/priorities_screen.dart';
import '../../features/farm/presentation/screens/rotation_strategy_screen.dart';
import '../../features/farm/data/models/farm_profile_model.dart';
import '../../features/farm/data/models/farm_priorities_model.dart';
import '../../features/what_if/presentation/screens/what_if_screen.dart';
import '../../features/crop_reference/presentation/screens/crop_reference_screen.dart';
import '../../features/results/presentation/screens/results_summary_screen.dart';
import '../../features/results/data/models/strategy_summary_model.dart';
import '../../features/what_if/data/models/what_if_scenario_model.dart';

class AppRouter {
  AppRouter._();

  static const String welcome = '/';
  static const String farmSetup = '/farm-setup';
  static const String priorities = '/priorities';
  static const String environment = '/environment';
  static const String rotationStrategy = '/rotation-strategy';
  static const String whatIf = '/what-if';
  static const String cropReference = '/crop-reference';
  static const String resultsSummary = '/results-summary';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final session = FieldShiftSession.instance;
    switch (settings.name) {
      case welcome:
        return MaterialPageRoute(
          builder: (_) => const WelcomeScreen(),
          settings: settings,
        );
      case farmSetup:
        return MaterialPageRoute(
          builder: (_) => const FarmSetupScreen(),
          settings: settings,
        );
      case priorities:
        final farmProfile = settings.arguments as FarmProfileModel;
        session.setFarmProfile(farmProfile);
        return MaterialPageRoute(
          builder: (_) => PrioritiesScreen(farmProfile: farmProfile),
          settings: settings,
        );
      case environment:
        final arguments = settings.arguments as Map<String, dynamic>;
        final farmProfile = arguments['farmProfile'] as FarmProfileModel;
        final farmPriorities =
            arguments['farmPriorities'] as FarmPrioritiesModel;
        session.farmProfile = farmProfile;
        session.setFarmPriorities(farmPriorities);
        return MaterialPageRoute(
          builder: (_) => EnvironmentScreen(
            farmProfile: farmProfile,
            farmPriorities: farmPriorities,
          ),
          settings: settings,
        );
      case rotationStrategy:
        final args = settings.arguments;
        final profileArg = args is Map<String, dynamic>
            ? args['farmProfile']
            : null;
        final priorityArg = args is Map<String, dynamic>
            ? args['farmPriorities']
            : null;
        final profile = profileArg is FarmProfileModel
            ? profileArg
            : session.farmProfile;
        final priorities = priorityArg is FarmPrioritiesModel
            ? priorityArg
            : session.farmPriorities;
        if (profile is FarmProfileModel) session.farmProfile = profile;
        if (priorities is FarmPrioritiesModel) {
          session.farmPriorities = priorities;
        }
        return MaterialPageRoute(
          builder: (_) => RotationStrategyScreen(
            farmProfile: profile is FarmProfileModel ? profile : null,
            farmPriorities: priorities is FarmPrioritiesModel
                ? priorities
                : null,
            farmName: profile is FarmProfileModel
                ? profile.farmName
                : 'Your Farm',
            farmLocation: profile is FarmProfileModel
                ? profile.location
                : 'Location not set',
          ),
          settings: settings,
        );
      case whatIf:
        final args = settings.arguments;
        final data = args is Map<String, dynamic> ? args : <String, dynamic>{};
        final profile = data['farmProfile'] is FarmProfileModel
            ? data['farmProfile'] as FarmProfileModel
            : session.farmProfile;
        final priorities = data['farmPriorities'] is FarmPrioritiesModel
            ? data['farmPriorities'] as FarmPrioritiesModel
            : session.farmPriorities;
        final initial = data['scenario'] is WhatIfScenarioModel
            ? data['scenario'] as WhatIfScenarioModel
            : session.scenario ?? const WhatIfScenarioModel();
        return MaterialPageRoute(
          builder: (_) => WhatIfScreen(
            farmProfile: profile,
            farmPriorities: priorities,
            farmName:
                profile?.farmName ??
                (data['farmName'] is String
                    ? data['farmName'] as String
                    : 'Your Farm'),
            farmLocation:
                profile?.location ??
                (data['farmLocation'] is String
                    ? data['farmLocation'] as String
                    : 'Location not set'),
            initialScenario: initial,
          ),
          settings: settings,
        );
      case cropReference:
        final args = settings.arguments;
        final farmName = args is Map<String, dynamic> ? args['farmName'] : null;
        final farmLocation = args is Map<String, dynamic>
            ? args['farmLocation']
            : null;
        return MaterialPageRoute(
          builder: (_) => CropReferenceScreen(
            farmName: farmName is String
                ? farmName
                : session.farmProfile?.farmName ?? 'Your Farm',
            farmLocation: farmLocation is String
                ? farmLocation
                : session.farmProfile?.location ?? 'Location not set',
          ),
          settings: settings,
        );
      case resultsSummary:
        final incoming = settings.arguments;
        final data = incoming is Map<String, dynamic>
            ? Map<String, dynamic>.from(incoming)
            : <String, dynamic>{};
        data.putIfAbsent('farmProfile', () => session.farmProfile);
        data.putIfAbsent('farmPriorities', () => session.farmPriorities);
        data.putIfAbsent('scenario', () => session.scenario);
        final summary = StrategySummaryModel.fromRouteArguments(data);
        if (summary.scenario != null) session.scenario = summary.scenario;
        return MaterialPageRoute(
          builder: (_) => ResultsSummaryScreen(summary: summary),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const WelcomeScreen(),
          settings: settings,
        );
    }
  }
}
