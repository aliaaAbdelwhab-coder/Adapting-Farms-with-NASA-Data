import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/routing/app_router.dart';
import '../../../../core/state/fieldshift_session.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_shell.dart';
import '../../../../core/widgets/app_sidebar.dart';
import '../../data/models/farm_priorities_model.dart';
import '../../data/models/farm_profile_model.dart';
import '../../data/services/fieldshift_analysis_service.dart';

/// Step 2 of the farm setup flow. The user's four preferences are 0–100 scores.
class PrioritiesScreen extends StatefulWidget {
  const PrioritiesScreen({super.key, required this.farmProfile});

  final FarmProfileModel farmProfile;

  @override
  State<PrioritiesScreen> createState() => _PrioritiesScreenState();
}

class _PrioritiesScreenState extends State<PrioritiesScreen> {
  // Reference starting values from the Figma prototype; user can change them.
  int _waterEfficiency = 80;
  int _soilHealth = 90;
  int _climateResilience = 65;
  int _yieldStability = 40;
  bool _isGenerating = false;

  Future<void> _generateAndContinue() async {
    if (_isGenerating) return;

    final farmPriorities = FarmPrioritiesModel(
      waterEfficiency: _waterEfficiency,
      soilHealth: _soilHealth,
      climateResilience: _climateResilience,
      yieldStability: _yieldStability,
    );

    setState(() => _isGenerating = true);
    try {
      final result = await FieldShiftAnalysisService()
          .generateFarmAnalysis(
            farmProfile: widget.farmProfile,
            farmPriorities: farmPriorities,
          );
      if (!mounted) return;
      FieldShiftSession.instance.setAnalysisResult(result);
      Navigator.pushNamed(
        context,
        AppRouter.environment,
        arguments: {
          'farmProfile': widget.farmProfile,
          'farmPriorities': farmPriorities,
        },
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Could not reach the analysis service. '
              'Check that the backend is running, then try again.',
            ),
            duration: Duration(seconds: 4),
          ),
        );
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppShell(
        activeSection: AppSidebarSection.myFarm,
        farmName: widget.farmProfile.farmName,
        farmLocation: widget.farmProfile.location,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final desktop = constraints.maxWidth >= 900;
              return SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: desktop ? 48 : 20,
                    vertical: desktop ? 48 : 24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(desktop),
                      SizedBox(height: desktop ? 40 : 24),
                      if (desktop)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildSlidersCard(desktop)),
                            const SizedBox(width: 32),
                            Expanded(
                              child: Column(
                                children: [
                                  _buildRadarCard(desktop),
                                  const SizedBox(height: 32),
                                  _buildContextCard(desktop),
                                ],
                              ),
                            ),
                          ],
                        )
                      else
                        Column(
                          children: [
                            _buildSlidersCard(desktop),
                            const SizedBox(height: 20),
                            _buildRadarCard(desktop),
                            const SizedBox(height: 20),
                            _buildContextCard(desktop),
                          ],
                        ),
                      SizedBox(height: desktop ? 40 : 24),
                      _buildActions(desktop),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool desktop) {
    if (!desktop) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Step 2 of 4: Priorities', style: _body(14)),
              const Spacer(),
              for (var i = 0; i < 4; i++) ...[
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i == 1
                        ? AppColors.primaryGreen
                        : AppColors.borderSlate,
                  ),
                ),
                if (i != 3) const SizedBox(width: 6),
              ],
            ],
          ),
          const SizedBox(height: 26),
          Text('Farm Priorities', style: _heading(28)),
          const SizedBox(height: 6),
          Text(
            'Set how much each goal matters to your farm.',
            style: _body(14, color: AppColors.textSecondary),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Step 2 of 4', style: _body(14)),
            const Spacer(),
            Text(
              '50% Complete',
              style: _body(14, color: AppColors.primaryGreen),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(6)),
          child: LinearProgressIndicator(
            value: 0.5,
            minHeight: 6,
            backgroundColor: AppColors.borderSlate,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
          ),
        ),
        const SizedBox(height: 16),
        Text('Establish Your Farm Priorities', style: _heading(28)),
      ],
    );
  }

  Widget _buildSlidersCard(bool desktop) {
    return _card(
      desktop: desktop,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('What matters most to your farm?', style: _heading(20)),
          const SizedBox(height: 4),
          Text(
            'These metrics configure the crop rotation algorithm recommendation balance.',
            style: _body(14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 28),
          _PrioritySlider(
            label: 'Water Saving',
            description: 'Reduce demand during dry summer months',
            color: AppColors.accentBlue,
            value: _waterEfficiency,
            onChanged: (value) => setState(() => _waterEfficiency = value),
          ),
          const SizedBox(height: 24),
          _PrioritySlider(
            label: 'Soil Health',
            description: 'Restore organic nitrogen & protect carbon sink',
            color: AppColors.secondaryBrown,
            value: _soilHealth,
            onChanged: (value) => setState(() => _soilHealth = value),
          ),
          const SizedBox(height: 24),
          _PrioritySlider(
            label: 'Climate Resilience',
            description: 'Survive sudden severe heat spells',
            color: AppColors.primaryGreen,
            value: _climateResilience,
            onChanged: (value) => setState(() => _climateResilience = value),
          ),
          const SizedBox(height: 24),
          _PrioritySlider(
            label: 'Yield',
            description: 'Max cash return at harvesting season',
            color: AppColors.alertAmber,
            value: _yieldStability,
            onChanged: (value) => setState(() => _yieldStability = value),
          ),
        ],
      ),
    );
  }

  Widget _buildRadarCard(bool desktop) {
    return _card(
      desktop: desktop,
      child: Column(
        children: [
          Text('Priority Profile Shape', style: _heading(16)),
          const SizedBox(height: 18),
          _PriorityRadar(
            water: _waterEfficiency,
            soil: _soilHealth,
            resilience: _climateResilience,
            yieldScore: _yieldStability,
          ),
          if (desktop) const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildContextCard(bool desktop) {
    final weights = <(String, int)>[
      ('water saving', _waterEfficiency),
      ('soil health', _soilHealth),
      ('climate resilience', _climateResilience),
      ('yield', _yieldStability),
    ]..sort((a, b) => b.$2.compareTo(a.$2));
    final first = weights[0].$1;
    final second = weights[1].$1;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(desktop ? 24 : 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F2E8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSlate),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.lightbulb_outline_rounded,
                color: AppColors.secondaryBrown,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Recommendation Context',
                style: _heading(15, color: AppColors.secondaryBrown),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Your selected weights currently emphasize $first and $second. '
            'These preferences will guide strategy comparisons once the '
            'NASA data service and recommendation engine are connected.',
            style: _body(14),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(bool desktop) {
    final backButton = OutlinedButton(
      onPressed: () => Navigator.pop(context),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textSecondary,
        side: const BorderSide(color: AppColors.borderSlate),
        backgroundColor: AppColors.surfaceWhite,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: const Text('Back'),
    );

    final continueButton = FilledButton.icon(
      onPressed: _isGenerating ? null : _generateAndContinue,
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AppColors.primaryGreen.withValues(alpha: 0.6),
        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      icon: _isGenerating
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Icon(Icons.arrow_forward, size: 18),
      label: Text(
        _isGenerating
            ? 'Generating analysis...'
            : desktop
            ? 'Generate NASA Environment'
            : 'Continue',
        style: GoogleFonts.figtree(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    );

    if (desktop) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [backButton, continueButton],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [continueButton, const SizedBox(height: 12), backButton],
    );
  }

  Widget _card({required bool desktop, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(desktop ? 32 : 20),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSlate),
      ),
      child: child,
    );
  }

  TextStyle _heading(int size, {Color color = AppColors.textPrimary}) {
    return GoogleFonts.outfit(
      fontSize: size.toDouble(),
      fontWeight: FontWeight.bold,
      color: color,
    );
  }

  TextStyle _body(int size, {Color color = AppColors.textPrimary}) {
    return GoogleFonts.figtree(
      fontSize: size.toDouble(),
      color: color,
    );
  }
}

class _PrioritySlider extends StatelessWidget {
  const _PrioritySlider({
    required this.label,
    required this.description,
    required this.color,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String description;
  final Color color;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.figtree(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: GoogleFonts.figtree(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$value/100',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 10,
            activeTrackColor: color,
            inactiveTrackColor: AppColors.borderSlate,
            thumbColor: color,
            overlayColor: color.withValues(alpha: 0.15),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
          ),
          child: Slider(
            value: value.toDouble(),
            min: 0,
            max: 100,
            divisions: 100,
            label: '$value/100',
            semanticFormatterCallback: (score) =>
                '${score.round()} out of 100',
            onChanged: (newValue) => onChanged(newValue.round()),
          ),
        ),
      ],
    );
  }
}

class _PriorityRadar extends StatelessWidget {
  const _PriorityRadar({
    required this.water,
    required this.soil,
    required this.resilience,
    required this.yieldScore,
  });

  final int water;
  final int soil;
  final int resilience;
  final int yieldScore;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Priority shape: water $water, soil $soil, '
          'resilience $resilience, yield $yieldScore out of 100',
      child: SizedBox(
        width: 220,
        height: 220,
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _PriorityRadarPainter(
                  water: water,
                  soil: soil,
                  resilience: resilience,
                  yieldScore: yieldScore,
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'Water',
                  style: _radarLabel(AppColors.accentBlue),
                ),
              ),
            ),
            Positioned(
              top: 102,
              right: 2,
              child: Text(
                'Soil',
                style: _radarLabel(AppColors.secondaryBrown),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'Resilience',
                  style: _radarLabel(AppColors.primaryGreen),
                ),
              ),
            ),
            Positioned(
              top: 102,
              left: 2,
              child: Text(
                'Yield',
                style: _radarLabel(AppColors.alertAmber),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextStyle _radarLabel(Color color) {
    return GoogleFonts.figtree(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: color,
    );
  }
}

class _PriorityRadarPainter extends CustomPainter {
  const _PriorityRadarPainter({
    required this.water,
    required this.soil,
    required this.resilience,
    required this.yieldScore,
  });

  final int water;
  final int soil;
  final int resilience;
  final int yieldScore;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide * 0.30;
    final ringPaint = Paint()
      ..color = AppColors.borderSlate
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (final scale in [1 / 3, 2 / 3, 1.0]) {
      canvas.drawCircle(center, radius * scale, ringPaint);
    }
    canvas.drawLine(
      Offset(center.dx - radius, center.dy),
      Offset(center.dx + radius, center.dy),
      ringPaint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - radius),
      Offset(center.dx, center.dy + radius),
      ringPaint,
    );

    final polygon = Path()
      ..moveTo(center.dx, center.dy - radius * water / 100)
      ..lineTo(center.dx + radius * soil / 100, center.dy)
      ..lineTo(center.dx, center.dy + radius * resilience / 100)
      ..lineTo(center.dx - radius * yieldScore / 100, center.dy)
      ..close();

    canvas.drawPath(
      polygon,
      Paint()..color = AppColors.primaryGreen.withValues(alpha: 0.17),
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
  bool shouldRepaint(covariant _PriorityRadarPainter oldDelegate) {
    return water != oldDelegate.water ||
        soil != oldDelegate.soil ||
        resilience != oldDelegate.resilience ||
        yieldScore != oldDelegate.yieldScore;
  }
}
