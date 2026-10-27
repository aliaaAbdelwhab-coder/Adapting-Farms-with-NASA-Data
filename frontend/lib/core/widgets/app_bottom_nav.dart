import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';

enum AppMobileTab { home, farm, data, plans, more }

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.activeTab,
    required this.onTabSelected,
  });

  final AppMobileTab activeTab;
  final ValueChanged<AppMobileTab> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceWhite,
      child: SafeArea(
        top: false,
        child: Container(
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: AppColors.borderSlate)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: SizedBox(
            height: 64,
            child: Row(
              children: [
                _buildTab(AppMobileTab.home, 'Home', Icons.home_outlined),
                _buildTab(AppMobileTab.farm, 'Farm', Icons.spa_outlined),
                _buildTab(
                  AppMobileTab.data,
                  'Data',
                  Icons.satellite_alt_outlined,
                ),
                _buildTab(AppMobileTab.plans, 'Plans', Icons.autorenew_rounded),
                _buildTab(AppMobileTab.more, 'More', Icons.more_horiz_rounded),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTab(AppMobileTab tab, String label, IconData icon) {
    final isActive = activeTab == tab;

    return Expanded(
      child: Semantics(
        button: true,
        selected: isActive,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => onTabSelected(tab),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 28,
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primaryGreen : Colors.transparent,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  icon,
                  color: isActive ? Colors.white : AppColors.textSecondary,
                  size: 20,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: GoogleFonts.figtree(
                  fontSize: 11,
                  color: isActive
                      ? AppColors.primaryGreen
                      : AppColors.textSecondary,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
