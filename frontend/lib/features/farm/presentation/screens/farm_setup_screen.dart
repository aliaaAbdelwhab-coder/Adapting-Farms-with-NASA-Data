import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_shell.dart';
import '../../../../core/widgets/app_sidebar.dart';
import '../widgets/farm_profile_form.dart';

class FarmSetupScreen extends StatelessWidget {
  const FarmSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: const AppShell(
        activeSection: AppSidebarSection.myFarm,
        child: SafeArea(child: SingleChildScrollView(child: FarmProfileForm())),
      ),
    );
  }
}
