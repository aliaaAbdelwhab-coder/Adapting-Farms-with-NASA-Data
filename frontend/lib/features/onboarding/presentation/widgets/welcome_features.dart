import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class WelcomeFeatures extends StatelessWidget {
  const WelcomeFeatures({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 700;

        final features = [
          const _FeatureData(
            icon: Icons.satellite_alt_outlined,
            title: 'Satellite Intelligence',
            description:
                'Use Earth observation data to better understand your farm.',
          ),
          const _FeatureData(
            icon: Icons.autorenew_rounded,
            title: 'Smart Rotation',
            description:
                'Explore crop rotation strategies designed around your conditions.',
          ),
          const _FeatureData(
            icon: Icons.eco_outlined,
            title: 'Climate Ready',
            description:
                'Plan with resilience in mind as environmental conditions change.',
          ),
        ];

        return Padding(
          padding: EdgeInsets.fromLTRB(
            isMobile ? 20 : 48,
            isMobile ? 24 : 40,
            isMobile ? 20 : 48,
            isMobile ? 48 : 72,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 1100,
              ),
              child: isMobile
                  ? Column(
                      children: [
                        for (int i = 0; i < features.length; i++) ...[
                          _FeatureCard(data: features[i]),
                          if (i < features.length - 1)
                            const SizedBox(height: 16),
                        ],
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (int i = 0; i < features.length; i++) ...[
                          Expanded(
                            child: _FeatureCard(data: features[i]),
                          ),
                          if (i < features.length - 1)
                            const SizedBox(width: 16),
                        ],
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.data,
  });

  final _FeatureData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.borderSlate,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              data.icon,
              color: AppColors.primaryGreen,
              size: 24,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            data.title,
            style: AppTextStyles.h3,
          ),
          const SizedBox(height: 8),
          Text(
            data.description,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureData {
  const _FeatureData({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;
}