import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_shell.dart';
import '../../../../core/widgets/app_sidebar.dart';
import '../../../farm/presentation/widgets/farm_setup_header.dart';
import '../../data/models/strategy_summary_model.dart';

/// Figma-inspired Results Summary. This is a user-input review, not a NASA
/// analysis, farm-specific AI forecast, or stored strategy.
class ResultsSummaryScreen extends StatelessWidget {
  const ResultsSummaryScreen({super.key, required this.summary});

  final StrategySummaryModel summary;

  @override
  Widget build(BuildContext context) {
    final desktop =
        MediaQuery.sizeOf(context).width >= AppShell.desktopBreakpoint;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppShell(
        activeSection: AppSidebarSection.savedScenarios,
        farmName: summary.farmName,
        farmLocation: summary.farmLocation,
        onSectionSelected: (section) {
          if (section == AppSidebarSection.savedScenarios) return;
          if (section == AppSidebarSection.rotationExplorer) {
            _comparePlans(context);
          } else if (section == AppSidebarSection.myFarm) {
            _modifyFarm(context);
          } else {
            _showNotice(
              context,
              'This navigation section is not connected yet.',
            );
          }
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
                          desktop ? 44 : 14,
                          desktop ? 48 : 20,
                          44,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              desktop ? 'My Farm Strategy' : 'My Strategy',
                              style: _outfit(desktop ? 34 : 28, bold: true),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Review your farm inputs and a sample results layout. '
                              'A verified strategy has not been generated.',
                              style: _figtree(
                                desktop ? 15 : 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 22),
                            _infoNotice(),
                            const SizedBox(height: 22),
                            if (desktop)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      children: [
                                        _farmCard(desktop: true),
                                        const SizedBox(height: 18),
                                        _sequenceCard(desktop: true),
                                        const SizedBox(height: 18),
                                        _environmentCard(desktop: true),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 22),
                                  Expanded(
                                    child: Column(
                                      children: [
                                        _prioritiesCard(desktop: true),
                                        const SizedBox(height: 18),
                                        _scenarioCard(desktop: true),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            else ...[
                              _farmCard(desktop: false),
                              const SizedBox(height: 14),
                              _sequenceCard(desktop: false),
                              const SizedBox(height: 22),
                              Text(
                                'Expected Yield Metrics',
                                style: _outfit(18, bold: true),
                              ),
                              const SizedBox(height: 10),
                              _mobileMetrics(),
                              const SizedBox(height: 18),
                              _prioritiesCard(desktop: false),
                              const SizedBox(height: 14),
                              _environmentCard(desktop: false),
                              const SizedBox(height: 14),
                              _scenarioCard(desktop: false),
                            ],
                            const SizedBox(height: 26),
                            _actions(context, desktop: desktop),
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

  Widget _infoNotice() => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xFFF7F2E8),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.borderSlate),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.info_outline_rounded,
          color: Color(0xFF8B6914),
          size: 20,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'DESIGN PREVIEW — The example crop sequence and any sample '
            'scores are not recommendations. NASA observations, a '
            'decision engine, and strategy storage are not connected.',
            style: _figtree(12, color: AppColors.textPrimary),
          ),
        ),
      ],
    ),
  );

  Widget _farmCard({required bool desktop}) {
    final area = summary.cultivatedArea;
    final rows = <_ValueItem>[
      _ValueItem('Location', summary.farmLocation),
      _ValueItem(
        'Size',
        area == null
            ? 'Not available'
            : '${area.toStringAsFixed(area == area.roundToDouble() ? 0 : 1)} (unit not stored)',
      ),
      _ValueItem('Soil Type', summary.soilType ?? 'Not available'),
      _ValueItem('Active Crop', summary.currentCrop ?? 'Not available'),
    ];
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (desktop)
            Text('Farm Coordinates Overview', style: _outfit(17, bold: true))
          else
            Row(
              children: [
                const Icon(
                  Icons.home_rounded,
                  color: AppColors.primaryGreen,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${summary.farmName} • ${summary.farmLocation}',
                    style: _figtree(14, bold: true),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 15),
          if (desktop)
            Wrap(
              spacing: 20,
              runSpacing: 14,
              children: rows
                  .map((r) => SizedBox(width: 126, child: _field(r)))
                  .toList(),
            )
          else
            Wrap(
              spacing: 12,
              runSpacing: 10,
              children: rows
                  .map((r) => SizedBox(width: 126, child: _field(r)))
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _field(_ValueItem item) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(item.name, style: _figtree(11, color: AppColors.textSecondary)),
      const SizedBox(height: 4),
      Text(item.value, style: _figtree(13, bold: true)),
    ],
  );

  Widget _sequenceCard({required bool desktop}) => _card(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                desktop ? 'Selected Sequence' : 'Plan Preview',
                style: _outfit(18, bold: true),
              ),
            ),
            _tag('DEMO ONLY', const Color(0xFFE07A3A)),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Plan B — Water Smart',
          style: _outfit(19, bold: true, color: AppColors.primaryGreen),
        ),
        const SizedBox(height: 4),
        Text(
          'Figma illustration, not selected or calculated for your farm',
          style: _figtree(12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _cropChip('Corn', const Color(0xFF4A90D9)),
            const Icon(
              Icons.arrow_forward,
              size: 14,
              color: AppColors.textMuted,
            ),
            _cropChip('Wheat', const Color(0xFF8B6914)),
            const Icon(
              Icons.arrow_forward,
              size: 14,
              color: AppColors.textMuted,
            ),
            _cropChip('Legume', const Color(0xFF8752ED)),
          ],
        ),
      ],
    ),
  );

  Widget _cropChip(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.09),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(label, style: _figtree(12, bold: true, color: color)),
  );

  Widget _environmentCard({required bool desktop}) => _card(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          desktop
              ? 'Meteorological Trendline (10 yr)'
              : 'CLIMATE OUTLOOK SUMMARY',
          style: _outfit(desktop ? 17 : 15, bold: true),
        ),
        const SizedBox(height: 12),
        Text(
          'Pending verified NASA observations. Historical trend, rainfall '
          'and surface water metrics cannot be calculated yet.',
          style: _figtree(13, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 12,
          runSpacing: 10,
          children: [
            _pendingMetric('Temperature'),
            _pendingMetric('Precipitation'),
            _pendingMetric('Surface Water'),
          ],
        ),
      ],
    ),
  );

  Widget _pendingMetric(String title) => SizedBox(
    width: 126,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: _figtree(11, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Text(
          'Pending',
          style: _figtree(13, bold: true, color: AppColors.textMuted),
        ),
      ],
    ),
  );

  Widget _prioritiesCard({required bool desktop}) {
    final p = summary.farmPriorities;
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('My Priority Balance Target', style: _outfit(17, bold: true)),
          const SizedBox(height: 18),
          Row(
            children: [
              SizedBox(
                height: desktop ? 118 : 104,
                width: desktop ? 118 : 104,
                child: CustomPaint(
                  painter: _PriorityDiamondPainter(
                    values: p == null
                        ? null
                        : [
                            p.waterEfficiency,
                            p.soilHealth,
                            p.climateResilience,
                            p.yieldStability,
                          ],
                  ),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _priorityLine('Water Conservation', p?.waterEfficiency),
                    _priorityLine('Soil Health Priority', p?.soilHealth),
                    _priorityLine('Climate Resilience', p?.climateResilience),
                    _priorityLine('Yield Target Index', p?.yieldStability),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'These are your preferences, not NASA measurements.',
            style: _figtree(11, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _priorityLine(String title, int? value) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      '$title: ${value == null ? 'Not entered' : '$value/100'}',
      style: _figtree(12, color: AppColors.textPrimary),
    ),
  );

  Widget _scenarioCard({required bool desktop}) {
    final s = summary.scenario;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F2E8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSlate),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What-If Analysis Verdict',
            style: _outfit(17, bold: true, color: const Color(0xFF8B6914)),
          ),
          const SizedBox(height: 10),
          Text(
            s == null
                ? 'No simulation inputs have been passed to this summary.'
                : 'Your scenario inputs: rainfall ${_signed(s.rainfallChangePercent, '%')}, '
                      'temperature ${_signed(s.temperatureChangeCelsius, '°C')}, '
                      'water availability ${_signed(s.waterAvailabilityChangePercent, '%')}.',
            style: _figtree(13),
          ),
          const SizedBox(height: 8),
          Text(
            'No farm-specific climate verdict, yield projection, or recommended '
            'strategy has been calculated. The analysis engine is not connected.',
            style: _figtree(12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  static String _signed(double value, String suffix) {
    final n = value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(1);
    return '${value > 0 ? '+' : ''}$n$suffix';
  }

  Widget _mobileMetrics() => LayoutBuilder(
    builder: (context, constraints) {
      final half = (constraints.maxWidth - 12) / 2;
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          _metricTile(half, 'WATER SAVING', 'Pending'),
          _metricTile(half, 'SOIL HEALTH', 'Pending'),
          _metricTile(half, 'RESILIENCE', 'Pending'),
          _metricTile(half, 'YIELD LEVEL', 'Pending'),
        ],
      );
    },
  );

  Widget _metricTile(double width, String label, String value) => Container(
    width: width,
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: AppColors.borderSlate),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _figtree(10, color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        Text(value, style: _outfit(16, bold: true)),
      ],
    ),
  );

  Widget _actions(BuildContext context, {required bool desktop}) {
    final compare = OutlinedButton(
      onPressed: () => _comparePlans(context),
      child: const Text('Compare Plans'),
    );
    final modify = TextButton(
      onPressed: () => _modifyFarm(context),
      child: const Text('Modify Farm Data'),
    );
    final save = FilledButton(
      onPressed: () => _showNotice(
        context,
        'Saving strategies is not available yet. No strategy has been saved.',
      ),
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
      ),
      child: const Text('Save Strategy'),
    );
    final export = OutlinedButton.icon(
      onPressed: () => _showNotice(
        context,
        'Export is not available until verified results are connected.',
      ),
      icon: const Icon(Icons.file_download_outlined, size: 17),
      label: const Text('Export Report'),
    );
    if (desktop) {
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        alignment: WrapAlignment.spaceBetween,
        children: [compare, modify, export, save],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        save,
        const SizedBox(height: 10),
        compare,
        const SizedBox(height: 2),
        modify,
        TextButton(
          onPressed: () => _showNotice(
            context,
            'Sharing is not available until verified results are connected.',
          ),
          child: const Text('Share Results'),
        ),
      ],
    );
  }

  void _comparePlans(BuildContext context) {
    final navigator = Navigator.of(context);
    var found = false;
    navigator.popUntil((route) {
      if (route.settings.name == AppRouter.rotationStrategy) {
        found = true;
        return true;
      }
      return route.isFirst;
    });
    if (!found) {
      navigator.pushNamed(AppRouter.rotationStrategy);
    }
  }

  void _modifyFarm(BuildContext context) {
    Navigator.pushNamed(context, AppRouter.farmSetup);
  }

  void _showNotice(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _card({required Widget child}) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.borderSlate),
    ),
    child: child,
  );

  Widget _tag(String text, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .10),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(text, style: _figtree(10, bold: true, color: color)),
  );
}

class _ValueItem {
  const _ValueItem(this.name, this.value);
  final String name;
  final String value;
}

class _PriorityDiamondPainter extends CustomPainter {
  const _PriorityDiamondPainter({required this.values});
  final List<int>? values;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * .39;
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..color = AppColors.borderSlate
      ..strokeWidth = 1;
    for (final scale in [.33, .66, 1.0]) {
      canvas.drawCircle(center, radius * scale, ring);
    }
    final axis = Paint()
      ..color = AppColors.borderSlate
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(center.dx, center.dy - radius),
      Offset(center.dx, center.dy + radius),
      axis,
    );
    canvas.drawLine(
      Offset(center.dx - radius, center.dy),
      Offset(center.dx + radius, center.dy),
      axis,
    );
    final weights = values;
    if (weights == null || weights.length != 4) return;
    final n = weights.map((v) => v.clamp(0, 100) / 100).toList();
    final polygon = Path()
      ..moveTo(center.dx, center.dy - radius * n[0])
      ..lineTo(center.dx + radius * n[1], center.dy)
      ..lineTo(center.dx, center.dy + radius * n[2])
      ..lineTo(center.dx - radius * n[3], center.dy)
      ..close();
    canvas.drawPath(
      polygon,
      Paint()..color = AppColors.primaryGreen.withValues(alpha: .20),
    );
    canvas.drawPath(
      polygon,
      Paint()
        ..color = AppColors.primaryGreen
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant _PriorityDiamondPainter oldDelegate) {
    if (oldDelegate.values == null && values == null) return false;
    return oldDelegate.values.toString() != values.toString();
  }
}

TextStyle _outfit(double size, {bool bold = false, Color? color}) =>
    GoogleFonts.outfit(
      fontSize: size,
      fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
      color: color ?? AppColors.textPrimary,
    );

TextStyle _figtree(double size, {bool bold = false, Color? color}) =>
    GoogleFonts.figtree(
      fontSize: size,
      fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
      color: color ?? AppColors.textPrimary,
    );
