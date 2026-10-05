import 'package:flutter/material.dart';

import '../../features/onboarding/presentation/screens/welcome_screen.dart';

class AppRouter {
  AppRouter._();

  static const String welcome = '/';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case welcome:
        return MaterialPageRoute(
          builder: (_) => const WelcomeScreen(),
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