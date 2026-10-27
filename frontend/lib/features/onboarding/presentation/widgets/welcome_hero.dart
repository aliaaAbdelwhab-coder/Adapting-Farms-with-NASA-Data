import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class WelcomeHero extends StatelessWidget {
  const WelcomeHero({
    super.key,
    required this.onAnalyzeFarm,
    required this.onExploreDemo,
  });

  final VoidCallback onAnalyzeFarm;
  final VoidCallback onExploreDemo;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 20 : 48,
            vertical: isMobile ? 48 : 80,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 760,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Adapt your farm.\nGrow smarter.',
                    style: AppTextStyles.display.copyWith(
                      fontSize: isMobile ? 38 : 48,
                      height: 1.1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: isMobile ? 18 : 20,
                  ),
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 600,
                    ),
                    child: Text(
                      'Smart crop rotation powered by Earth observation data.',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(
                    height: isMobile ? 28 : 32,
                  ),
                  _HeroActions(
                    isMobile: isMobile,
                    onAnalyzeFarm: onAnalyzeFarm,
                    onExploreDemo: onExploreDemo,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _HeroActions extends StatelessWidget {
  const _HeroActions({
    required this.isMobile,
    required this.onAnalyzeFarm,
    required this.onExploreDemo,
  });

  final bool isMobile;
  final VoidCallback onAnalyzeFarm;
  final VoidCallback onExploreDemo;

  @override
  Widget build(BuildContext context) {
    final analyzeButton = ElevatedButton(
      onPressed: onAnalyzeFarm,
      child: const Text('Analyze My Farm'),
    );

    final demoButton = TextButton(
      onPressed: onExploreDemo,
      child: const Text('Explore Demo Farm'),
    );

    if (isMobile) {
      return SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: analyzeButton,
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: demoButton,
            ),
          ],
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        analyzeButton,
        const SizedBox(width: 12),
        demoButton,
      ],
    );
  }
}
