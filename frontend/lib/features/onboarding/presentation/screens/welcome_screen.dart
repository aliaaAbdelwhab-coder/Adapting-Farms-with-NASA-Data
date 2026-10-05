import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../widgets/welcome_header.dart';
import '../widgets/welcome_hero.dart';
import '../widgets/welcome_features.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const WelcomeHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
  children: [
    WelcomeHero(
      onAnalyzeFarm: () {
        // TODO: Navigate to farm setup.
      },
      onExploreDemo: () {
        // TODO: Open demo farm.
      },
    ),
    const WelcomeFeatures(),
  ],
),
              ),
            ),
          ],
        ),
      ),
    );
  }
}