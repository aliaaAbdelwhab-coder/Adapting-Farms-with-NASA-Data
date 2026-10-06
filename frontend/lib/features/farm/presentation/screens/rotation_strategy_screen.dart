import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../widgets/farm_setup_header.dart';

class RotationStrategyScreen extends StatelessWidget {
  const RotationStrategyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            FarmSetupHeader(
              onBack: () => Navigator.pop(context),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 930),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 48, 24, 64),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Step 4 of 4',
                                style: AppTextStyles.body.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryGreen,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '100% Complete',
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
                              value: 1,
                              minHeight: 6,
                              backgroundColor: AppColors.borderSlate,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                          const SizedBox(height: 48),
                          Text(
                            'Rotation Strategy',
                            style: AppTextStyles.h1,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Review the recommended crop rotation strategy for your farm.',
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 40),
                          Text(
                            'Recommended Rotation',
                            style: AppTextStyles.h2,
                          ),
                          const SizedBox(height: 20),
                          const _PendingStrategyCard(),
                          const SizedBox(height: 24),
                          const _DataNotice(),
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

class _PendingStrategyCard extends StatelessWidget {
  const _PendingStrategyCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.borderSlate,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.autorenew_rounded,
            color: AppColors.primaryGreen,
            size: 30,
          ),
          const SizedBox(height: 18),
          Text(
            'Strategy Pending',
            style: AppTextStyles.h3,
          ),
          const SizedBox(height: 8),
          Text(
            'Your crop rotation recommendation will appear here once environmental data and the decision engine are connected.',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _DataNotice extends StatelessWidget {
  const _DataNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.borderSlate,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AppColors.accentBlue,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'This screen is ready for integration with the NASA data pipeline and rotation decision engine.',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}