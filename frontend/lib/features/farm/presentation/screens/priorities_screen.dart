import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../widgets/farm_setup_header.dart';
import '../../../../core/routing/app_router.dart';
import '../../data/models/farm_profile_model.dart';
import '../../data/models/farm_priorities_model.dart';

class PrioritiesScreen extends StatefulWidget {
  const PrioritiesScreen({super.key, required this.farmProfile});

  final FarmProfileModel farmProfile;

  @override
  State<PrioritiesScreen> createState() => _PrioritiesScreenState();
}

class _PrioritiesScreenState extends State<PrioritiesScreen> {
  bool _waterEfficiency = false;
  bool _soilHealth = false;
  bool _climateResilience = false;
  bool _yieldStability = false;

  @override
  Widget build(BuildContext context) {
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
                                'Step 2 of 4',
                                style: AppTextStyles.body.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryGreen,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '50% Complete',
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
                              value: 0.50,
                              minHeight: 6,
                              backgroundColor: AppColors.borderSlate,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                          const SizedBox(height: 32),
                          Text('Set Your Priorities', style: AppTextStyles.h1),
                          const SizedBox(height: 8),
                          Text(
                            'Tell us what matters most for your farm.',
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 32),

                          _PriorityCard(
                            icon: Icons.water_drop_outlined,
                            title: 'Water Efficiency',
                            description: 'Prioritize strategies that use water more efficiently.',
                            isSelected: _waterEfficiency,
                            onTap: () {
                              setState(() {
                                _waterEfficiency = !_waterEfficiency;
                              });
                            },
                          ),

                          const SizedBox(height: 16),

                          _PriorityCard(
                            icon: Icons.eco_outlined,
                            title: 'Soil Health',
                            description: 'Prioritize rotations that support healthier soil.',
                            isSelected: _soilHealth,
                            onTap: () {
                              setState(() {
                                _soilHealth = !_soilHealth;
                              });
                            },
                          ),

                          const SizedBox(height: 16),

                          _PriorityCard(
                            icon: Icons.shield_outlined,
                            title: 'Climate Resilience',
                            description: 'Prioritize strategies that improve resilience to climate stress.',
                            isSelected: _climateResilience,
                            onTap: () {
                              setState(() {
                                _climateResilience = !_climateResilience;
                              });
                            },
                          ),

                          const SizedBox(height: 16),

                          _PriorityCard(
                            icon: Icons.trending_up_rounded,
                            title: 'Yield Stability',
                            description: 'Prioritize consistent and reliable crop performance.',
                            isSelected: _yieldStability,
                            onTap: () {
                              setState(() {
                                _yieldStability = !_yieldStability;
                              });
                            },
                          ),
                          const SizedBox(height: 32),

                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: () {
                                final farmPriorities = FarmPrioritiesModel(
                                  waterEfficiency: _waterEfficiency,
                                  soilHealth: _soilHealth,
                                  climateResilience: _climateResilience,
                                  yieldStability: _yieldStability,
                                );

                                Navigator.pushNamed(
                                  context,
                                  AppRouter.environment,
                                  arguments: {
                                    'farmProfile': widget.farmProfile,
                                    'farmPriorities': farmPriorities,
                                  },
                                );
                              },
                              child: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 4),
                                child: Text('Generate NASA Environment'),
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

class _PriorityCard extends StatelessWidget {
  const _PriorityCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primaryGreen : AppColors.borderSlate,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primaryGreen, size: 26),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.h3),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isSelected ? AppColors.primaryGreen : AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}
