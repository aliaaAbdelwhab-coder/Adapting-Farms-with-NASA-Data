import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_shell.dart';
import '../../../../core/widgets/app_sidebar.dart';
import '../../../farm/presentation/widgets/farm_setup_header.dart';
import '../../data/models/crop_reference_model.dart';

/// Figma-aligned crop reference. All default profiles are explicitly
/// illustrative, not live NASA observations or generated recommendations.
class CropReferenceScreen extends StatefulWidget {
  const CropReferenceScreen({
    super.key,
    this.farmName = 'Your Farm',
    this.farmLocation = 'Location not set',
    this.profiles = const <CropReferenceModel>[],
  });

  final String farmName;
  final String farmLocation;
  final List<CropReferenceModel> profiles;

  @override
  State<CropReferenceScreen> createState() => _CropReferenceScreenState();
}

class _CropReferenceScreenState extends State<CropReferenceScreen> {
  String? _openId = 'corn';

  bool get _isDemo => widget.profiles.isEmpty;
  List<CropReferenceModel> get _profiles =>
      _isDemo ? figmaCropReferenceExamples : widget.profiles;

  @override
  Widget build(BuildContext context) {
    final desktop =
        MediaQuery.sizeOf(context).width >= AppShell.desktopBreakpoint;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppShell(
        activeSection: AppSidebarSection.rotationExplorer,
        farmName: widget.farmName,
        farmLocation: widget.farmLocation,
        onSectionSelected: (section) {
          if (section == AppSidebarSection.rotationExplorer) {
            Navigator.maybePop(context);
            return;
          }
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(
                content: Text('This navigation section is not connected yet.'),
                duration: Duration(seconds: 2),
              ),
            );
        },
        child: SafeArea(
          child: Column(
            children: [
              if (!desktop)
                FarmSetupHeader(onBack: () => Navigator.maybePop(context)),
              Expanded(
                child: SingleChildScrollView(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1220),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          desktop ? 48 : 20,
                          desktop ? 44 : 16,
                          desktop ? 48 : 20,
                          desktop ? 48 : 32,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              desktop
                                  ? 'Explanation & Crop Reference'
                                  : 'AI Insights',
                              style: _outfit(desktop ? 32 : 28, bold: true),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              desktop
                                  ? 'Explore crop reference traits and the reasoning concepts behind rotation planning.'
                                  : 'Crop logic & reference information',
                              style: _figtree(
                                desktop ? 16 : 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 24),
                            _explanationCard(desktop),
                            const SizedBox(height: 26),
                            Text(
                              desktop
                                  ? 'Crop Species Matrix Profiles'
                                  : 'Crop Reference Guide',
                              style: _outfit(desktop ? 20 : 19, bold: true),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _isDemo
                                  ? 'DESIGN REFERENCE — illustrative crop traits, not farm-specific advice.'
                                  : 'Reference entries provided to the interface; their source has not been verified here.',
                              style: _figtree(
                                12,
                                color: AppColors.secondaryBrown,
                              ),
                            ),
                            const SizedBox(height: 14),
                            if (desktop) _desktopGrid() else _mobileList(),
                            const SizedBox(height: 18),
                            Text(
                              'Crop water needs and resilience depend on local climate, variety, soil, and management. '
                              'Connect verified observations and the decision engine before using these profiles for planning.',
                              style: _figtree(
                                12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton.icon(
                                onPressed: () => Navigator.maybePop(context),
                                icon: const Icon(
                                  Icons.arrow_back_rounded,
                                  size: 18,
                                ),
                                label: const Text('Back to previous screen'),
                              ),
                            ),
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
      ),
    );
  }

  Widget _explanationCard(bool desktop) => Container(
    width: double.infinity,
    padding: EdgeInsets.all(desktop ? 26 : 18),
    decoration: _cardDecoration(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.auto_awesome_rounded,
              color: Color(0xFF8755EF),
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                desktop ? 'Why Does This Change?' : 'Why does this change?',
                style: _outfit(18, bold: true),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          'General explanation: maintaining soil cover and incorporating suitable legumes '
          'can support soil protection and nutrient cycling. Changes in rainfall or temperature '
          'may alter which crop sequences are suitable. No crop outcome has been calculated '
          'for this farm, and no AI explanation or NASA observations have been retrieved yet.',
          style: _figtree(14, color: AppColors.textSecondary, height: 1.55),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _sourceTag(
              'NASA: not connected',
              const Color(0xFFECF4FB),
              AppColors.accentBlue,
            ),
            _sourceTag(
              'Calculations: pending',
              const Color(0xFFE7F0EC),
              AppColors.primaryGreen,
            ),
            _sourceTag(
              'AI: not generated',
              const Color(0xFFF2EDFE),
              const Color(0xFF8755EF),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _sourceTag(String title, Color bg, Color ink) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(title, style: _figtree(11, bold: true, color: ink)),
  );

  Widget _desktopGrid() => LayoutBuilder(
    builder: (context, constraints) {
      final wide = constraints.maxWidth >= 700;
      final cardWidth = wide
          ? (constraints.maxWidth - 22) / 2
          : constraints.maxWidth;
      return Wrap(
        spacing: 22,
        runSpacing: 18,
        children: [
          for (final crop in _profiles)
            SizedBox(width: cardWidth, child: _desktopCropCard(crop)),
        ],
      );
    },
  );

  Widget _desktopCropCard(CropReferenceModel crop) => Container(
    constraints: const BoxConstraints(minHeight: 168),
    padding: const EdgeInsets.all(22),
    decoration: _cardDecoration(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 5,
          children: [
            Text(crop.scientificName, style: _outfit(17, bold: true)),
            _roleTag(crop.role),
          ],
        ),
        const SizedBox(height: 15),
        _traitLine('Water Demand', crop.waterDemand, crop.id == 'corn'),
        _traitLine(
          'Soil Contribution',
          crop.soilContribution,
          crop.id == 'legume' || crop.id == 'cover',
        ),
        _traitLine('Climate Tolerance', crop.heatTolerance, false),
      ],
    ),
  );

  Widget _traitLine(String label, String value, bool emphasized) => Padding(
    padding: const EdgeInsets.only(bottom: 9),
    child: Wrap(
      spacing: 5,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text('$label:', style: _figtree(13, color: AppColors.textSecondary)),
        Text(
          value,
          style: _figtree(
            13,
            bold: emphasized,
            color: emphasized
                ? (label == 'Water Demand'
                      ? AppColors.alertAmber
                      : const Color(0xFF8755EF))
                : AppColors.textPrimary,
          ),
        ),
      ],
    ),
  );

  Widget _mobileList() => Column(
    children: [
      for (final crop in _profiles) ...[
        _mobileCropCard(crop),
        const SizedBox(height: 12),
      ],
    ],
  );

  Widget _mobileCropCard(CropReferenceModel crop) {
    final expanded = _openId == crop.id;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: double.infinity,
      decoration: _cardDecoration(active: expanded),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() {
              _openId = expanded ? null : crop.id;
            }),
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                children: [
                  Expanded(
                    child: Text(crop.name, style: _outfit(17, bold: true)),
                  ),
                  _roleTag(crop.role),
                  const SizedBox(width: 7),
                  Icon(
                    expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textSecondary,
                    size: 19,
                  ),
                ],
              ),
            ),
          ),
          if (expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 0, 15, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 10, color: AppColors.borderSlate),
                  const SizedBox(height: 12),
                  _metricBar('Water Demand', crop.waterDemand, crop.waterLevel),
                  _metricBar(
                    'Soil Impact',
                    crop.soilContribution,
                    crop.soilLevel,
                  ),
                  _metricBar(
                    'Heat Tolerance',
                    crop.heatTolerance,
                    crop.heatLevel,
                  ),
                  const SizedBox(height: 11),
                  Container(
                    padding: const EdgeInsets.all(12),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PRIMARY FIELD ROLE',
                          style: _figtree(
                            11,
                            bold: true,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          crop.fieldRole,
                          style: _figtree(
                            12,
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _metricBar(String label, String value, int percent) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      children: [
        SizedBox(
          width: 92,
          child: Text(
            label,
            style: _figtree(12, color: AppColors.textSecondary),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent / 100,
              minHeight: 6,
              backgroundColor: AppColors.borderSlate,
              color: AppColors.primaryGreen,
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 65,
          child: Text(
            value,
            textAlign: TextAlign.end,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: _figtree(12, bold: true),
          ),
        ),
      ],
    ),
  );

  Widget _roleTag(String role) {
    final accent = switch (role) {
      'Cash Crop' => AppColors.alertAmber,
      'Grain Rotation' => AppColors.secondaryBrown,
      'Soil Builder' => const Color(0xFF8755EF),
      _ => AppColors.accentBlue,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        role,
        maxLines: 1,
        style: _figtree(10, bold: true, color: accent),
      ),
    );
  }

  BoxDecoration _cardDecoration({bool active = false}) => BoxDecoration(
    color: AppColors.surfaceWhite,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: active ? AppColors.primaryGreen : AppColors.borderSlate,
      width: active ? 1.5 : 1,
    ),
  );
}

TextStyle _figtree(
  double size, {
  bool bold = false,
  Color color = AppColors.textPrimary,
  double? height,
}) => GoogleFonts.figtree(
  fontSize: size,
  fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
  color: color,
  height: height,
);

TextStyle _outfit(double size, {bool bold = false}) => GoogleFonts.outfit(
  fontSize: size,
  fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
  color: AppColors.textPrimary,
);
