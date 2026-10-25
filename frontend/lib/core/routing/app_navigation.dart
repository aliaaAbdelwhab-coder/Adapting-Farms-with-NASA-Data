import 'package:flutter/material.dart';

import '../state/fieldshift_session.dart';
import '../widgets/app_sidebar.dart';
import 'app_router.dart';

/// Navigation shared by AppShell, Rotation, What-If and Results Summary.
/// Uses the latest in-memory farm inputs; blocks data-dependent screens when
/// no completed farm setup is available instead of inventing context.
class AppNavigation {
  AppNavigation._();

  static void go(BuildContext context, AppSidebarSection section) {
    final session = FieldShiftSession.instance;
    final navigator = Navigator.of(context);
    switch (section) {
      case AppSidebarSection.dashboard:
        navigator.pushNamed(AppRouter.welcome);
        return;
      case AppSidebarSection.myFarm:
        session.requestEdit();
        navigator.pushNamed(AppRouter.farmSetup);
        return;
      case AppSidebarSection.nasaData:
        if (session.farmProfile == null || session.farmPriorities == null) {
          _notice(
            context,
            'Complete Farm Profile and Priorities before NASA Data.',
          );
          return;
        }
        navigator.pushNamed(
          AppRouter.environment,
          arguments: {
            'farmProfile': session.farmProfile!,
            'farmPriorities': session.farmPriorities!,
          },
        );
        return;
      case AppSidebarSection.rotationExplorer:
        navigator.pushNamed(
          AppRouter.rotationStrategy,
          arguments: {
            'farmProfile': session.farmProfile,
            'farmPriorities': session.farmPriorities,
          },
        );
        return;
      case AppSidebarSection.whatIf:
        navigator.pushNamed(
          AppRouter.whatIf,
          arguments: {
            'farmProfile': session.farmProfile,
            'farmPriorities': session.farmPriorities,
            'scenario': session.scenario,
          },
        );
        return;
      case AppSidebarSection.savedScenarios:
        _notice(context, 'No saved scenarios yet. Saving is not connected.');
        return;
    }
  }

  static void _notice(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
