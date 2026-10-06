import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/routing/app_router.dart';

class FarmProfileForm extends StatelessWidget {
  const FarmProfileForm({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 700;

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 760,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 20 : 32,
                vertical: isMobile ? 32 : 48,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
  children: [
    Text(
      'Step 1 of 4',
      style: AppTextStyles.body.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.primaryGreen,
      ),
    ),
    const Spacer(),
    Text(
      '25% Complete',
      style: AppTextStyles.caption.copyWith(
        color: AppColors.textSecondary,
      ),
    ),
  ],
),
const SizedBox(height: 10),
ClipRRect(
  borderRadius: BorderRadius.circular(999),
  child: LinearProgressIndicator(
    value: 0.25,
    minHeight: 6,
    backgroundColor: AppColors.borderSlate,
    color: AppColors.primaryGreen,
  ),
),
const SizedBox(height: 32),
                  Text(
                    'Set Up Your Farm Profile',
                    style: AppTextStyles.h1.copyWith(
                      fontSize: isMobile ? 28 : 32,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start with a few details about your farm.',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 32),

if (isMobile) ...[
  const _FarmTextField(
    label: 'Farm Name',
    hintText: 'Enter your farm name',
  ),
  const SizedBox(height: 20),
  const _FarmTextField(
    label: 'Location',
    hintText: 'Enter your farm location',
  ),
  const SizedBox(height: 20),
  const _FarmTextField(
    label: 'Cultivated Area',
    hintText: 'Enter cultivated area',
    suffixText: 'Acres',
  ),
  const SizedBox(height: 20),
  const _SoilTypeDropdown(),
  const SizedBox(height: 20),
const _CurrentCropDropdown(),
const SizedBox(height: 20),
const _WaterSourceDropdown(),
] else ...[
  const Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: _FarmTextField(
          label: 'Farm Name',
          hintText: 'Enter your farm name',
        ),
      ),
      SizedBox(width: 20),
      Expanded(
        child: _FarmTextField(
          label: 'Location',
          hintText: 'Enter your farm location',
        ),
      ),
    ],
  ),
  const SizedBox(height: 20),
  const Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: _FarmTextField(
          label: 'Cultivated Area',
          hintText: 'Enter cultivated area',
          suffixText: 'Acres',
        ),
      ),
      SizedBox(width: 20),
      Expanded(
        child: _SoilTypeDropdown(),
      ),
    ],
  ),
 const SizedBox(height: 20),
const Row(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Expanded(
      child: _CurrentCropDropdown(),
    ),
    SizedBox(width: 20),
    Expanded(
      child: _WaterSourceDropdown(),
    ),
  ],
),
],
                const SizedBox(height: 32),

SizedBox(
  width: double.infinity,
  child: FilledButton(
   onPressed: () {
  Navigator.pushNamed(
    context,
    AppRouter.priorities,
  );
},
    child: const Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Text('Continue to Priorities'),
    ),
  ),
),

const SizedBox(height: 24),    
                ],
                
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FarmTextField extends StatelessWidget {
  const _FarmTextField({
    required this.label,
    required this.hintText,
    this.suffixText,
  });

  final String label;
  final String hintText;
  final String? suffixText;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          decoration: InputDecoration(
  hintText: hintText,
  suffixIcon: suffixText == null
    ? null
    : Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Center(
          widthFactor: 1,
          child: Text(
            suffixText!,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
),
        ),
      ],
    );
  }
}
class _SoilTypeDropdown extends StatefulWidget {
  const _SoilTypeDropdown();

  @override
  State<_SoilTypeDropdown> createState() => _SoilTypeDropdownState();
}

class _SoilTypeDropdownState extends State<_SoilTypeDropdown> {
  String? selectedSoilType;

  static const List<String> soilTypes = [
    'Loam',
    'Clay',
    'Sandy Loam',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Soil Type',
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: selectedSoilType,
          hint: Text(
            'Select soil type',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textMuted,
            ),
          ),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.textSecondary,
          ),
          items: soilTypes.map((soilType) {
            return DropdownMenuItem<String>(
              value: soilType,
              child: Text(soilType),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedSoilType = value;
            });
          },
        ),
      ],
    );
  }
}
class _CurrentCropDropdown extends StatefulWidget {
  const _CurrentCropDropdown();

  @override
  State<_CurrentCropDropdown> createState() =>
      _CurrentCropDropdownState();
}

class _CurrentCropDropdownState extends State<_CurrentCropDropdown> {
  String? selectedCrop;

  static const List<String> crops = [
    'Corn',
    'Wheat',
    'Soybean',
    'Rice',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Current Crop',
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: selectedCrop,
          hint: Text(
            'Select current crop',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textMuted,
            ),
          ),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.textSecondary,
          ),
          items: crops.map((crop) {
            return DropdownMenuItem<String>(
              value: crop,
              child: Text(crop),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedCrop = value;
            });
          },
        ),
      ],
    );
  }
}
class _WaterSourceDropdown extends StatefulWidget {
  const _WaterSourceDropdown();

  @override
  State<_WaterSourceDropdown> createState() =>
      _WaterSourceDropdownState();
}

class _WaterSourceDropdownState extends State<_WaterSourceDropdown> {
  String? selectedWaterSource;

  static const List<String> waterSources = [
    'Irrigated',
    'Rain-fed',
    'Mixed',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Primary Water Source',
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: selectedWaterSource,
          hint: Text(
            'Select water source',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textMuted,
            ),
          ),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.textSecondary,
          ),
          items: waterSources.map((source) {
            return DropdownMenuItem<String>(
              value: source,
              child: Text(source),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedWaterSource = value;
            });
          },
        ),
      ],
    );
  }
}