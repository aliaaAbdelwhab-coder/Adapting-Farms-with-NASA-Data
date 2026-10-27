import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';

enum AppSidebarSection {
  dashboard,
  myFarm,
  nasaData,
  rotationExplorer,
  whatIf,
  savedScenarios,
}

class AppSidebar extends StatelessWidget {
  const AppSidebar({
    super.key,
    required this.activeSection,
    this.onSectionSelected,
    this.farmName = 'Your Farm',
    this.farmLocation = 'Location not set',
  });

  final AppSidebarSection activeSection;
  final ValueChanged<AppSidebarSection>? onSectionSelected;
  final String farmName;
  final String farmLocation;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      child: ColoredBox(
        color: AppColors.primaryGreen,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLogo(),
                        const SizedBox(height: 48),
                        _buildNavigation(),
                      ],
                    ),
                  ),
                ),
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.accentBlue,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.park_outlined, color: Colors.white, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'FieldShift',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'NASA SPACE APPS CONCEPT',
                style: GoogleFonts.figtree(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNavigation() {
    return Column(
      children: [
        _buildNavItem(
          section: AppSidebarSection.dashboard,
          icon: Icons.dashboard_outlined,
          label: 'Dashboard',
        ),
        const SizedBox(height: 8),
        _buildNavItem(
          section: AppSidebarSection.myFarm,
          icon: Icons.home_outlined,
          label: 'My Farm',
        ),
        const SizedBox(height: 8),
        _buildNavItem(
          section: AppSidebarSection.nasaData,
          icon: Icons.satellite_alt_outlined,
          label: 'NASA Data',
        ),
        const SizedBox(height: 8),
        _buildNavItem(
          section: AppSidebarSection.rotationExplorer,
          icon: Icons.swap_horiz_rounded,
          label: 'Rotation Explorer',
        ),
        const SizedBox(height: 8),
        _buildNavItem(
          section: AppSidebarSection.whatIf,
          icon: Icons.help_outline_rounded,
          label: 'What-If',
        ),
        const SizedBox(height: 8),
        _buildNavItem(
          section: AppSidebarSection.savedScenarios,
          icon: Icons.bookmark_border_rounded,
          label: 'Saved Scenarios',
        ),
      ],
    );
  }

  Widget _buildNavItem({
    required AppSidebarSection section,
    required IconData icon,
    required String label,
  }) {
    final isActive = activeSection == section;

    return Material(
      color: isActive
          ? Colors.white.withValues(alpha: 0.08)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onSectionSelected == null
            ? null
            : () => onSectionSelected!(section),
        child: SizedBox(
          height: 44,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isActive
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.85),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: GoogleFonts.figtree(
                      color: isActive
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.85),
                      fontSize: 14,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
                if (isActive)
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppColors.accentBlue,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Divider(color: Colors.white.withValues(alpha: 0.1), thickness: 1),
        const SizedBox(height: 16),
        Row(
          children: [
            const CircleAvatar(
              radius: 20,
              backgroundColor: Color(0xFF426754),
              child: Icon(
                Icons.agriculture_outlined,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    farmName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.figtree(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    farmLocation,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.figtree(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
