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

class AppRouter {
  AppRouter._();

  static const String welcome = '/';
  static const String farmSetup = '/farm-setup';
  static const String priorities = '/priorities';
  static const String environment = '/environment';
  static const String rotationStrategy = '/rotation-strategy';
  static const String whatIf = '/what-if';

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
        return MaterialPageRoute(
          builder: (_) => RotationStrategyScreen(
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
            farmName: farmName is String ? farmName : 'Your Farm',
            farmLocation: farmLocation is String
                ? farmLocation
                : 'Location not set',
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
