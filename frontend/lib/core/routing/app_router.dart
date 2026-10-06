import 'package:flutter/material.dart';

import '../../features/farm/presentation/screens/farm_setup_screen.dart';
import '../../features/onboarding/presentation/screens/welcome_screen.dart';
import '../../features/farm/presentation/screens/priorities_screen.dart';

class AppRouter {
  AppRouter._();

  static const String welcome = '/';
static const String farmSetup = '/farm-setup';
static const String priorities = '/priorities';

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
  return MaterialPageRoute(
    builder: (_) => const PrioritiesScreen(),
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