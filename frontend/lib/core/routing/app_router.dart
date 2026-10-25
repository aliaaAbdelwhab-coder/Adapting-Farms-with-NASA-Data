import 'package:flutter/material.dart';

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
        return MaterialPageRoute(
          builder: (_) => PrioritiesScreen(farmProfile: farmProfile),
          settings: settings,
        );
      case environment:
        final arguments = settings.arguments as Map<String, dynamic>;
        final farmProfile = arguments['farmProfile'] as FarmProfileModel;
        final farmPriorities =
            arguments['farmPriorities'] as FarmPrioritiesModel;
        return MaterialPageRoute(
          builder: (_) => EnvironmentScreen(
            farmProfile: farmProfile,
            farmPriorities: farmPriorities,
          ),
          settings: settings,
        );
      case rotationStrategy:
        final args = settings.arguments;
        final profile = args is Map<String, dynamic>
            ? args['farmProfile']
            : null;
        final priorities = args is Map<String, dynamic>
            ? args['farmPriorities']
            : null;
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
        final farmName = args is Map<String, dynamic> ? args['farmName'] : null;
        final farmLocation = args is Map<String, dynamic>
            ? args['farmLocation']
            : null;
        return MaterialPageRoute(
          builder: (_) => WhatIfScreen(
            farmProfile:
                args is Map<String, dynamic> &&
                    args['farmProfile'] is FarmProfileModel
                ? args['farmProfile'] as FarmProfileModel
                : null,
            farmPriorities:
                args is Map<String, dynamic> &&
                    args['farmPriorities'] is FarmPrioritiesModel
                ? args['farmPriorities'] as FarmPrioritiesModel
                : null,
            farmName: farmName is String ? farmName : 'Your Farm',
            farmLocation: farmLocation is String
                ? farmLocation
                : 'Location not set',
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
            farmName: farmName is String ? farmName : 'Your Farm',
            farmLocation: farmLocation is String
                ? farmLocation
                : 'Location not set',
          ),
          settings: settings,
        );
      case resultsSummary:
        return MaterialPageRoute(
          builder: (_) => ResultsSummaryScreen(
            summary: StrategySummaryModel.fromRouteArguments(
              settings.arguments,
            ),
          ),
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
