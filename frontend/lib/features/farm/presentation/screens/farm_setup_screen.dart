import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../widgets/farm_profile_form.dart';
import '../widgets/farm_setup_header.dart';

class FarmSetupScreen extends StatelessWidget {
  const FarmSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            FarmSetupHeader(
              onBack: () {
                Navigator.pop(context);
              },
            ),
            const Expanded(
              child: SingleChildScrollView(
                child: FarmProfileForm(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}