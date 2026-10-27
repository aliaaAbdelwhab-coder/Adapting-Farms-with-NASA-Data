import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../routing/app_navigation.dart';
import 'app_bottom_nav.dart';
import 'app_sidebar.dart';

class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.activeSection,
    required this.child,
    this.onSectionSelected,
    this.farmName = 'Your Farm',
    this.farmLocation = 'Location not set',
  });

  final AppSidebarSection activeSection;
  final Widget child;
  final ValueChanged<AppSidebarSection>? onSectionSelected;
  final String farmName;
  final String farmLocation;

  static const double sidebarWidth = 280;
  static const double desktopBreakpoint = 900;

  AppMobileTab _getActiveMobileTab() {
    return switch (activeSection) {
      AppSidebarSection.dashboard => AppMobileTab.home,
      AppSidebarSection.myFarm => AppMobileTab.farm,
      AppSidebarSection.nasaData => AppMobileTab.data,
      AppSidebarSection.rotationExplorer => AppMobileTab.plans,
      AppSidebarSection.whatIf ||
      AppSidebarSection.savedScenarios => AppMobileTab.more,
    };
  }

  void _handleMobileNavigation(BuildContext context, AppMobileTab tab) {
    if (tab == _getActiveMobileTab()) return;

    final targetSection = switch (tab) {
      AppMobileTab.home => AppSidebarSection.dashboard,
      AppMobileTab.farm => AppSidebarSection.myFarm,
      AppMobileTab.data => AppSidebarSection.nasaData,
      AppMobileTab.plans => AppSidebarSection.rotationExplorer,
      AppMobileTab.more => AppSidebarSection.whatIf,
    };

    if (onSectionSelected != null) {
      onSectionSelected!(targetSection);
      return;
    }

    AppNavigation.go(context, targetSection);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Avoid layout overflow during temporary tiny viewport sizes.
        if (constraints.maxWidth < 80 || constraints.maxHeight < 80) {
          return const SizedBox.shrink();
        }

        final isDesktop = constraints.maxWidth >= desktopBreakpoint;
        if (!isDesktop) {
          return Column(
            children: [
              Expanded(child: child),
              AppBottomNav(
                activeTab: _getActiveMobileTab(),
                onTabSelected: (tab) {
                  _handleMobileNavigation(context, tab);
                },
              ),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppSidebar(
              activeSection: activeSection,
              onSectionSelected: (section) {
                if (section == activeSection) return;
                if (onSectionSelected != null) {
                  onSectionSelected!(section);
                } else {
                  AppNavigation.go(context, section);
                }
              },
              farmName: farmName,
              farmLocation: farmLocation,
            ),
            Expanded(
              child: ColoredBox(color: AppColors.background, child: child),
            ),
          ],
        );
      },
    );
  }
}
