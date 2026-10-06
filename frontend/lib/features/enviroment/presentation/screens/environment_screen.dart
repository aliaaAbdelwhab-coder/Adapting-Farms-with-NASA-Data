import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/routing/app_router.dart';
import '../../../farm/data/models/farm_profile_model.dart';
import '../../../farm/data/models/farm_priorities_model.dart';
import '../../../farm/presentation/widgets/farm_setup_header.dart';
import '../../data/models/environment_data_model.dart';

class EnvironmentScreen extends StatelessWidget {
  const EnvironmentScreen({
    super.key,
    required this.farmProfile,
    required this.farmPriorities,
  });

  final FarmProfileModel farmProfile;
  final FarmPrioritiesModel farmPriorities;

  @override
  Widget build(BuildContext context) {
    final environmentData = EnvironmentDataModel();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            FarmSetupHeader(onBack: () => Navigator.pop(context)),
            Expanded(
              child: SingleChildScrollView(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 40,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Step 3 of 4',
                                style: AppTextStyles.body.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryGreen,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '75% Complete',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: const LinearProgressIndicator(
                              value: 0.75,
                              minHeight: 6,
                              backgroundColor: AppColors.borderSlate,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                          const SizedBox(height: 32),

                          Text('NASA Environment', style: AppTextStyles.h1),
                          const SizedBox(height: 8),
                          Text(
                            'Review the environmental conditions for your farm.',
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 32),

                          Text(
                            'Environmental Overview',
                            style: AppTextStyles.h2,
                          ),
                          const SizedBox(height: 16),

                          _EnvironmentGrid(environmentData: environmentData),

                          const SizedBox(height: 24),

                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceWhite,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.borderSlate),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.satellite_alt_outlined,
                                  color: AppColors.accentBlue,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Environmental values will be populated from NASA Earth observation data when the data service is connected.',
                                    style: AppTextStyles.body.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 32),

                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRouter.rotationStrategy,
                                );
                              },
                              child: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 4),
                                child: Text('Continue to Rotation Strategy'),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EnvironmentGrid extends StatelessWidget {
  const _EnvironmentGrid({required this.environmentData});

  final EnvironmentDataModel environmentData;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        final cards = [
          _EnvironmentCard(
            icon: Icons.thermostat_outlined,
            title: 'Temperature',
            value: environmentData.temperature != null
                ? '${environmentData.temperature!.toStringAsFixed(1)} °C'
                : 'Pending',
            subtitle: 'NASA data',
          ),
          _EnvironmentCard(
            icon: Icons.water_drop_outlined,
            title: 'Precipitation',
            value: environmentData.precipitation != null
                ? '${environmentData.precipitation!.toStringAsFixed(1)} mm'
                : 'Pending',
            subtitle: 'NASA data',
          ),
          _EnvironmentCard(
            icon: Icons.grass_outlined,
            title: 'Soil Moisture',
            value: environmentData.soilMoisture != null
                ? environmentData.soilMoisture!.toStringAsFixed(2)
                : 'Pending',
            subtitle: 'NASA data',
          ),
          _EnvironmentCard(
            icon: Icons.wb_sunny_outlined,
            title: 'Land Surface',
            value: environmentData.landSurfaceTemperature != null
                ? '${environmentData.landSurfaceTemperature!.toStringAsFixed(1)} °C'
                : 'Pending',
            subtitle: 'NASA data',
          ),
        ];

        if (isMobile) {
          return Column(
            children: [
              cards[0],
              SizedBox(height: 12),
              cards[1],
              SizedBox(height: 12),
              cards[2],
              SizedBox(height: 12),
              cards[3],
            ],
          );
        }

        return Column(
          children: [
            Row(
              children: [
                Expanded(child: cards[0]),
                SizedBox(width: 16),
                Expanded(child: cards[1]),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: cards[2]),
                SizedBox(width: 16),
                Expanded(child: cards[3]),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _EnvironmentCard extends StatelessWidget {
  const _EnvironmentCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSlate),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primaryGreen, size: 26),
          const SizedBox(height: 16),
          Text(
            title,
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 6),
          Text(value, style: AppTextStyles.h3),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
