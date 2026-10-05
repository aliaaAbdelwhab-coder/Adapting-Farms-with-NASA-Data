import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class WelcomeHeader extends StatelessWidget {
  const WelcomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 20 : 48,
            vertical: isMobile ? 16 : 20,
          ),
          child: Row(
            children: [
              _buildBrand(),
              const Spacer(),
              if (!isMobile) _buildDesktopNavigation(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBrand() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primaryGreen,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.eco_outlined,
            color: AppColors.surfaceWhite,
            size: 21,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'FieldShift',
          style: AppTextStyles.h3.copyWith(
            color: AppColors.primaryGreen,
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopNavigation() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(
          onPressed: () {},
          child: const Text('How It Works'),
        ),
        const SizedBox(width: 8),
        TextButton(
          onPressed: () {},
          child: const Text('About'),
        ),
      ],
    );
  }
}