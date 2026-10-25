import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_shell.dart';
import '../../../../core/widgets/app_sidebar.dart';
import '../../../farm/presentation/widgets/farm_setup_header.dart';
import '../../data/models/what_if_scenario_model.dart';

/// Responsive Figma-style What-If interface.
///
/// Slider values are real user inputs; comparison numbers are explicitly
/// labeled illustrative Figma examples and are NOT calculated from the inputs.
/// The real simulation engine/repository will supply outcomes later.
class WhatIfScreen extends StatefulWidget {
  const WhatIfScreen({
    super.key,
    this.farmName = 'Your Farm',
    this.farmLocation = 'Location not set',
    this.initialScenario = const WhatIfScenarioModel(),
  });

  final String farmName;
  final String farmLocation;
  final WhatIfScenarioModel initialScenario;

  @override
  State<WhatIfScreen> createState() => _WhatIfScreenState();
}

class _WhatIfScreenState extends State<WhatIfScreen> {
  late WhatIfScenarioModel _scenario;
  bool _showThirdPlanOnMobile = false;

  @override
  void initState() {
    super.initState();
    _scenario = widget.initialScenario;
  }

  void _resetScenario() => setState(() {
        _scenario = const WhatIfScenarioModel(
          rainfallChangePercent: 0,
          temperatureChangeCelsius: 0,
          waterAvailabilityChangePercent: 0,
        );
      });

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.sizeOf(context).width >=
        AppShell.desktopBreakpoint;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppShell(
        // Figma treats What-If as a subpage of Plans in the mobile bottom bar.
        activeSection: desktop
            ? AppSidebarSection.whatIf
            : AppSidebarSection.rotationExplorer,
        farmName: widget.farmName,
        farmLocation: widget.farmLocation,
        onSectionSelected: (section) {
          if (section == AppSidebarSection.rotationExplorer && desktop) {
            Navigator.maybePop(context);
            return;
          }
          if (section == AppSidebarSection.whatIf) return;
          _notConnected(context);
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
                          42,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _header(desktop),
                            const SizedBox(height: 24),
                            _slidersCard(desktop),
                            const SizedBox(height: 26),
                            _outputTitle(desktop),
                            const SizedBox(height: 14),
                            _outcomes(desktop),
                            const SizedBox(height: 22),
                            _insightCard(desktop),
                            const SizedBox(height: 18),
                            Align(
                              alignment: Alignment.centerRight,
                              child: OutlinedButton.icon(
                                onPressed: () => Navigator.pushNamed(
                                  context,
                                  AppRouter.cropReference,
                                  arguments: {
                                    'farmName': widget.farmName,
                                    'farmLocation': widget.farmLocation,
                                  },
                                ),
                                icon: const Icon(Icons.menu_book_outlined),
                                label: const Text('View Crop Reference'),
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

  Widget _header(bool desktop) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            desktop ? 'What If Conditions Change?' : 'What If?',
            style: _outfit(desktop ? 32 : 28, bold: true),
          ),
          const SizedBox(height: 6),
          Text(
            desktop
                ? 'Adjust future meteorological and irrigation conditions '
                    'to explore climate scenario inputs.'
                : 'Test future climate and resource conditions',
            style: _figtree(
              desktop ? 15 : 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      );

  Widget _slidersCard(bool desktop) => Container(
        width: double.infinity,
        padding: EdgeInsets.all(desktop ? 24 : 18),
        decoration: _whiteCardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (desktop) ...[
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Simulate Environmental Shifts',
                      style: _outfit(19, bold: true),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _resetScenario,
                    icon: const Icon(Icons.restart_alt_rounded, size: 18),
                    label: const Text('Reset to normal'),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _rainfallSlider(desktop)),
                  const SizedBox(width: 24),
                  Expanded(child: _temperatureSlider(desktop)),
                  const SizedBox(width: 24),
                  Expanded(child: _waterSlider(desktop)),
                ],
              ),
            ] else ...[
              _rainfallSlider(desktop),
              const SizedBox(height: 25),
              _temperatureSlider(desktop),
              const SizedBox(height: 25),
              _waterSlider(desktop),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: _resetScenario,
                  icon: const Icon(Icons.restart_alt_rounded, size: 16),
                  label: const Text('Reset to normal'),
                ),
              ),
            ],
          ],
        ),
      );

  Widget _rainfallSlider(bool desktop) => _ScenarioSlider(
        title: desktop ? 'Rainfall Change' : 'Rainfall Projection',
        description: desktop ? null : 'Water intake trend line',
        valueLabel: _percent(_scenario.rainfallChangePercent),
        value: _scenario.rainfallChangePercent,
        min: -30,
        max: 30,
        divisions: 60,
        color: desktop ? AppColors.alertAmber : AppColors.accentBlue,
        minLabel: '-30%',
        maxLabel: '+30%',
        onChanged: (value) => setState(
          () => _scenario = _scenario.copyWith(rainfallChangePercent: value),
        ),
        showLimits: desktop,
      );

  Widget _temperatureSlider(bool desktop) => _ScenarioSlider(
        title: desktop ? 'Temperature Change' : 'Temperature Shift',
        description: desktop ? null : 'Thermal stress levels',
        valueLabel: _temperature(_scenario.temperatureChangeCelsius),
        value: _scenario.temperatureChangeCelsius,
        min: -3,
        max: 5,
        divisions: 8,
        color: AppColors.alertAmber,
        minLabel: '-3°C',
        maxLabel: '+5°C',
        onChanged: (value) => setState(
          () => _scenario = _scenario.copyWith(temperatureChangeCelsius: value),
        ),
        showLimits: desktop,
      );

  Widget _waterSlider(bool desktop) => _ScenarioSlider(
        title: 'Water Availability',
        description: desktop ? null : 'Irrigation capacity ceiling',
        valueLabel: _percent(_scenario.waterAvailabilityChangePercent),
        value: _scenario.waterAvailabilityChangePercent,
        min: -50,
        max: 50,
        divisions: 100,
        color: desktop ? AppColors.alertAmber : AppColors.secondaryBrown,
        minLabel: '-50%',
        maxLabel: '+50%',
        onChanged: (value) => setState(
          () => _scenario = _scenario.copyWith(
            waterAvailabilityChangePercent: value,
          ),
        ),
        showLimits: desktop,
      );

  Widget _outputTitle(bool desktop) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            desktop ? 'Adaptive Scenario Outputs' : 'Impact On Current Plans',
            style: _outfit(desktop ? 20 : 19, bold: true),
          ),
          const SizedBox(height: 5),
          Text(
            'Fixed Figma UI examples — not calculated from these sliders.',
            style: _figtree(12, color: AppColors.textSecondary),
          ),
        ],
      );

  Widget _outcomes(bool desktop) {
    if (desktop) {
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < _examples.length; i++) ...[
              if (i > 0) const SizedBox(width: 16),
              Expanded(child: _ExampleOutcomeCard(example: _examples[i])),
            ],
          ],
        ),
      );
    }

    return Column(
      children: [
        for (var i = 0; i < (_showThirdPlanOnMobile ? 3 : 2); i++) ...[
          if (i > 0) const SizedBox(height: 12),
          _ExampleOutcomeCard(example: _examples[i], compact: true),
        ],
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => setState(
            () => _showThirdPlanOnMobile = !_showThirdPlanOnMobile,
          ),
          child: Text(_showThirdPlanOnMobile ? 'Hide Plan C' : 'Show Plan C'),
        ),
      ],
    );
  }

  Widget _insightCard(bool desktop) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F2E8),
          border: Border.all(color: AppColors.borderSlate),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  desktop ? Icons.lightbulb_outline : Icons.spa_rounded,
                  color: AppColors.secondaryBrown,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    desktop ? 'Simulator Insight Indicator' : 'Scenario Status',
                    style: _figtree(
                      14,
                      bold: true,
                      color: AppColors.secondaryBrown,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Your input: rainfall ${_percent(_scenario.rainfallChangePercent)}, '
              'temperature ${_temperature(_scenario.temperatureChangeCelsius)}, '
              'water availability ${_percent(_scenario.waterAvailabilityChangePercent)}. '
              'No farm-specific impacts have been calculated. The comparison '
              'cards above demonstrate the Figma layout only; a verified '
              'simulation engine is required for real outcomes.',
              style: _figtree(13, color: AppColors.textPrimary),
            ),
          ],
        ),
      );
}

class _ScenarioSlider extends StatelessWidget {
  const _ScenarioSlider({
    required this.title,
    required this.valueLabel,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.color,
    required this.onChanged,
    required this.minLabel,
    required this.maxLabel,
    this.description,
    this.showLimits = true,
  });

  final String title;
  final String? description;
  final String valueLabel;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final Color color;
  final ValueChanged<double> onChanged;
  final String minLabel;
  final String maxLabel;
  final bool showLimits;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: _figtree(14, bold: true)),
                    if (description != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        description!,
                        style: _figtree(
                          11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                valueLabel,
                style: _outfit(17, bold: true, color: color),
              ),
            ],
          ),
          const SizedBox(height: 9),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 8,
              activeTrackColor: color,
              inactiveTrackColor: AppColors.borderSlate,
              thumbColor: color,
              overlayColor: color.withValues(alpha: 0.12),
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 8,
              ),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            ),
            child: SizedBox(
              height: 26,
              child: Slider(
                value: value,
                min: min,
                max: max,
                divisions: divisions,
                onChanged: onChanged,
                label: valueLabel,
              ),
            ),
          ),
          if (showLimits) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  minLabel,
                  style: _figtree(10, color: AppColors.textSecondary),
                ),
                Text(
                  'Normal',
                  style: _figtree(10, color: AppColors.textSecondary),
                ),
                Text(
                  maxLabel,
                  style: _figtree(10, color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
        ],
      );
}

class _ExampleOutcomeCard extends StatelessWidget {
  const _ExampleOutcomeCard({
    required this.example,
    this.compact = false,
  });

  final _ExampleOutcome example;
  final bool compact;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: EdgeInsets.all(compact ? 16 : 19),
        decoration: _whiteCardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(minHeight: compact ? 0 : 48),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      example.title,
                      style: _outfit(compact ? 16 : 17, bold: true),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDF4FB),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      'DEMO',
                      style: _figtree(
                        9,
                        bold: true,
                        color: AppColors.accentBlue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _comparisonRow(
              'Water Demand',
              example.waterBefore,
              example.waterAfter,
              compact: compact,
              emphasize: example.warning,
            ),
            const SizedBox(height: 10),
            _comparisonRow(
              compact ? 'Climate Resilience' : 'Resilience Score',
              example.resilienceBefore,
              example.resilienceAfter,
              compact: compact,
              emphasize: example.warning,
            ),
            if (!compact) ...[
              const SizedBox(height: 10),
              _comparisonRow(
                'Estimated Overall Match',
                example.matchBefore,
                example.matchAfter,
                emphasize: example.warning,
              ),
            ],
          ],
        ),
      );

  Widget _comparisonRow(
    String label,
    String before,
    String after, {
    bool compact = false,
    bool emphasize = false,
  }) => Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: _figtree(
                compact ? 12 : 11,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            before,
            style: _figtree(
              compact ? 12 : 11,
              color: AppColors.textMuted,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 6),
            child: Icon(
              Icons.arrow_forward_rounded,
              size: 14,
              color: AppColors.textMuted,
            ),
          ),
          Text(
            after,
            style: _figtree(
              compact ? 12 : 11,
              bold: true,
              color: emphasize
                  ? AppColors.alertAmber
                  : AppColors.primaryGreen,
            ),
          ),
        ],
      );
}

class _ExampleOutcome {
  const _ExampleOutcome({
    required this.title,
    required this.waterBefore,
    required this.waterAfter,
    required this.resilienceBefore,
    required this.resilienceAfter,
    required this.matchBefore,
    required this.matchAfter,
    this.warning = false,
  });

  final String title;
  final String waterBefore;
  final String waterAfter;
  final String resilienceBefore;
  final String resilienceAfter;
  final String matchBefore;
  final String matchAfter;
  final bool warning;
}

const _examples = <_ExampleOutcome>[
  _ExampleOutcome(
    title: 'Plan A — Balanced Growth',
    waterBefore: 'Medium',
    waterAfter: 'Low',
    resilienceBefore: '74',
    resilienceAfter: '82',
    matchBefore: '82%',
    matchAfter: '85%',
  ),
  _ExampleOutcome(
    title: 'Plan B — Water Smart',
    waterBefore: 'Low',
    waterAfter: 'Very Low',
    resilienceBefore: '86',
    resilienceAfter: '91',
    matchBefore: '79%',
    matchAfter: '88%',
  ),
  _ExampleOutcome(
    title: 'Plan C — Yield Focus',
    waterBefore: 'High',
    waterAfter: 'Critical',
    resilienceBefore: '68',
    resilienceAfter: '49',
    matchBefore: '71%',
    matchAfter: '55%',
    warning: true,
  ),
];

BoxDecoration _whiteCardDecoration() => BoxDecoration(
      color: Colors.white,
      border: Border.all(color: AppColors.borderSlate),
      borderRadius: BorderRadius.circular(16),
    );

String _percent(double value) =>
    '${value > 0 ? '+' : ''}${value.round()}%';

String _temperature(double value) =>
    '${value > 0 ? '+' : ''}${value.round()}°C';

TextStyle _outfit(
  double fontSize, {
  bool bold = false,
  Color color = AppColors.textPrimary,
}) =>
    GoogleFonts.outfit(
      fontSize: fontSize,
      fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
      color: color,
    );

TextStyle _figtree(
  double fontSize, {
  bool bold = false,
  Color color = AppColors.textPrimary,
}) =>
    GoogleFonts.figtree(
      fontSize: fontSize,
      fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
      color: color,
    );

void _notConnected(BuildContext context) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      const SnackBar(
        content: Text('This navigation section is not connected yet.'),
        duration: Duration(seconds: 2),
      ),
    );
}
