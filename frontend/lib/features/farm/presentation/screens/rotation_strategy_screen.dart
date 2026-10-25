import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_shell.dart';
import '../../../../core/widgets/app_sidebar.dart';
import '../../data/models/rotation_plan_model.dart';
import '../widgets/farm_setup_header.dart';

/// Figma-aligned Rotation Explorer for desktop and mobile.
///
/// Until the recommendation engine supplies [plans], the cards are explicitly
/// marked as a DESIGN PREVIEW. Preview figures are not NASA observations or
/// farm-specific agronomic advice. Existing no-argument navigation still works.
class RotationStrategyScreen extends StatefulWidget {
  const RotationStrategyScreen({
    super.key,
    this.plans = const <RotationPlanModel>[],
    this.farmName = 'Your Farm',
    this.farmLocation = 'Location not set',
  });

  /// Pass verified results here once the recommendation engine is integrated.
  final List<RotationPlanModel> plans;
  final String farmName;
  final String farmLocation;

  @override
  State<RotationStrategyScreen> createState() => _RotationStrategyScreenState();
}

class _RotationStrategyScreenState extends State<RotationStrategyScreen> {
  late final PageController _pageController;
  int _selectedPlan = 0;
  bool _showMobileComparison = false;
  final GlobalKey _comparisonKey = GlobalKey();

  bool get _isPreview => widget.plans.isEmpty;
  List<RotationPlanModel> get _plans =>
      _isPreview ? _figmaPreviewPlans : widget.plans;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.91);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop =
        MediaQuery.sizeOf(context).width >= AppShell.desktopBreakpoint;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppShell(
        activeSection: AppSidebarSection.rotationExplorer,
        farmName: widget.farmName,
        farmLocation: widget.farmLocation,
        child: SafeArea(
          child: Column(
            children: [
              if (!isDesktop)
                FarmSetupHeader(onBack: () => Navigator.maybePop(context)),
              Expanded(
                child: SingleChildScrollView(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1220),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          isDesktop ? 48 : 20,
                          isDesktop ? 44 : 18,
                          isDesktop ? 48 : 20,
                          42,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeader(isDesktop),
                            const SizedBox(height: 24),
                            if (_isPreview) _buildPreviewNotice(),
                            if (_isPreview) const SizedBox(height: 20),
                            if (isDesktop) ...[
                              _buildDesktopCards(),
                              const SizedBox(height: 24),
                              _buildComparisonTable(),
                              const SizedBox(height: 20),
                              Text(
                                'Illustrative comparison only. Actual results require '
                                'verified farm observations and the recommendation engine.',
                                textAlign: TextAlign.center,
                                style: _figtree(12, color: AppColors.textMuted),
                              ),
                            ] else ...[
                              _buildMobileCards(),
                              const SizedBox(height: 14),
                              _buildDots(),
                              const SizedBox(height: 10),
                              Center(
                                child: TextButton(
                                  onPressed: _toggleMobileComparison,
                                  child: Text(
                                    _showMobileComparison
                                        ? 'Hide Comparison'
                                        : 'Compare All Plans',
                                    style: _figtree(
                                      15,
                                      weight: FontWeight.w700,
                                      color: AppColors.primaryGreen,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ),
                              if (_showMobileComparison) ...[
                                const SizedBox(height: 18),
                                KeyedSubtree(
                                  key: _comparisonKey,
                                  child: _buildComparisonTable(),
                                ),
                              ],
                            ],
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

  Widget _buildHeader(bool desktop) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        desktop ? 'Rotation Explorer' : 'Rotation Plans',
        style: _outfit(desktop ? 30 : 28, weight: FontWeight.w700),
      ),
      const SizedBox(height: 6),
      Text(
        _isPreview
            ? 'Preview how crop rotation options could be compared.'
            : desktop
            ? 'Compare crop rotation strategies for your farm.'
            : 'Compare adaptive crop rotation plans.',
        style: _figtree(desktop ? 15 : 13, color: AppColors.textSecondary),
      ),
    ],
  );

  Widget _buildPreviewNotice() => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: const Color(0xFFF7F2E8),
      border: Border.all(color: AppColors.borderSlate),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.info_outline_rounded,
          color: AppColors.secondaryBrown,
          size: 20,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'DESIGN PREVIEW — All plans, crops and scores below are '
            'illustrative Figma examples, NOT actual NASA data or '
            'recommendations for your farm.',
            style: _figtree(
              12,
              weight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildDesktopCards() => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (var i = 0; i < _plans.length; i++) ...[
        if (i > 0) const SizedBox(width: 16),
        Expanded(
          child: SizedBox(
            height: 376,
            child: _RotationPlanCard(
              plan: _plans[i],
              index: i,
              isPreview: _isPreview,
              onExplore: () => _showPlanDetails(_plans[i]),
              onSave: _explainSaveUnavailable,
            ),
          ),
        ),
      ],
    ],
  );

  Widget _buildMobileCards() => SizedBox(
    height: 386,
    child: PageView.builder(
      controller: _pageController,
      itemCount: _plans.length,
      onPageChanged: (index) => setState(() => _selectedPlan = index),
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(right: 12),
        child: _RotationPlanCard(
          plan: _plans[index],
          index: index,
          isPreview: _isPreview,
          onExplore: () => _showPlanDetails(_plans[index]),
          onSave: _explainSaveUnavailable,
        ),
      ),
    ),
  );

  Widget _buildDots() => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      for (var i = 0; i < _plans.length; i++)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: InkWell(
            onTap: () => _pageController.animateToPage(
              i,
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeInOut,
            ),
            borderRadius: BorderRadius.circular(10),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i == _selectedPlan
                    ? AppColors.primaryGreen
                    : AppColors.borderSlate,
              ),
            ),
          ),
        ),
    ],
  );

  void _toggleMobileComparison() {
    setState(() => _showMobileComparison = !_showMobileComparison);
    if (_showMobileComparison) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final comparisonContext = _comparisonKey.currentContext;
        if (comparisonContext != null) {
          Scrollable.ensureVisible(
            comparisonContext,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  Widget _buildComparisonTable() => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: AppColors.surfaceWhite,
      border: Border.all(color: AppColors.borderSlate),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Metric Matrix Comparison',
          style: _outfit(17, weight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Text(
          _isPreview
              ? 'Example metrics for layout demonstration only.'
              : 'Compare available details across the supplied plans.',
          style: _figtree(12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 12),
        if (MediaQuery.sizeOf(context).width < AppShell.desktopBreakpoint) ...[
          Row(
            children: [
              const Icon(
                Icons.swipe_rounded,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Swipe left to see Plans B and C',
                  style: _figtree(11, color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowHeight: 44,
            dataRowMinHeight: 50,
            dataRowMaxHeight: 60,
            horizontalMargin: 0,
            columnSpacing: 34,
            dividerThickness: 0.7,
            headingTextStyle: _figtree(
              12,
              weight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            dataTextStyle: _figtree(12, color: AppColors.textPrimary),
            columns: [
              const DataColumn(label: Text('Evaluation Parameter')),
              for (var i = 0; i < _plans.length; i++)
                DataColumn(label: Text('Plan ${_planLetter(i)}')),
            ],
            rows: [
              DataRow(
                cells: [
                  const DataCell(Text('Biomass Nitrogen Accrual')),
                  for (final plan in _plans)
                    DataCell(Text(plan.biomassNitrogen)),
                ],
              ),
              DataRow(
                cells: [
                  const DataCell(Text('Rooting System Depth Range')),
                  for (final plan in _plans) DataCell(Text(plan.rootingDepth)),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );

  void _explainSaveUnavailable() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Saving plans is not connected yet.'),
          duration: Duration(seconds: 2),
        ),
      );
  }

  Future<void> _showPlanDetails(RotationPlanModel plan) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: AppColors.surfaceWhite,
      builder: (sheetContext) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(plan.title, style: _outfit(22, weight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text(
                  _isPreview
                      ? 'DESIGN PREVIEW — not a farm recommendation.'
                      : plan.description,
                  style: _figtree(
                    13,
                    color: _isPreview
                        ? AppColors.secondaryBrown
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                _detail('Crop sequence', plan.crops.join(' → ')),
                _detail('Match', '${plan.matchPercent}%'),
                _detail(
                  'Water demand',
                  '${plan.waterDemandLabel} (${plan.waterDemandPercent}%)',
                ),
                _detail('Soil health', '${plan.soilHealthScore}/100'),
                _detail(
                  'Climate resilience',
                  '${plan.climateResilienceScore}/100',
                ),
                _detail('Biomass nitrogen', plan.biomassNitrogen),
                _detail('Root depth', plan.rootingDepth),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(sheetContext),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _detail(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 124,
          child: Text(
            label,
            style: _figtree(12, color: AppColors.textSecondary),
          ),
        ),
        Expanded(child: Text(value, style: _figtree(13))),
      ],
    ),
  );
}

class _RotationPlanCard extends StatelessWidget {
  const _RotationPlanCard({
    required this.plan,
    required this.index,
    required this.isPreview,
    required this.onExplore,
    required this.onSave,
  });

  final RotationPlanModel plan;
  final int index;
  final bool isPreview;
  final VoidCallback onExplore;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final badgeColor = switch (index % 3) {
      0 => AppColors.accentBlue,
      1 => AppColors.alertAmber,
      _ => AppColors.secondaryBrown,
    };
    final accentColor = switch (index % 3) {
      0 => AppColors.accentBlue,
      1 => AppColors.alertAmber,
      _ => AppColors.textPrimary,
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        border: Border.all(color: AppColors.borderSlate),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Text(
                    plan.badgeLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _figtree(
                      10,
                      weight: FontWeight.w700,
                      color: badgeColor,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '${plan.matchPercent}% Match',
                style: _outfit(15, weight: FontWeight.w700),
              ),
            ],
          ),
          if (isPreview)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'DEMO PLAN',
                style: _figtree(
                  9,
                  weight: FontWeight.w700,
                  color: AppColors.textMuted,
                ),
              ),
            ),
          const SizedBox(height: 10),
          Text(
            plan.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: _outfit(17, weight: FontWeight.w700),
          ),
          const SizedBox(height: 3),
          Text(
            plan.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: _figtree(12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 14),
          _CropSequence(crops: plan.crops),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.borderSlate),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Water Need: ${plan.waterDemandLabel}',
                  style: _figtree(12, color: AppColors.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${plan.waterDemandPercent}%',
                style: _figtree(12, weight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 7),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: plan.waterDemandPercent / 100,
              minHeight: 7,
              backgroundColor: AppColors.borderSlate,
              color: accentColor,
            ),
          ),
          const SizedBox(height: 12),
          _metric('Soil Health Score', '${plan.soilHealthScore}/100'),
          const SizedBox(height: 8),
          _metric('Climate Resilience', '${plan.climateResilienceScore}/100'),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 43,
                  child: FilledButton(
                    onPressed: onExplore,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                    ),
                    child: Text(
                      'Explore Details',
                      style: _figtree(
                        12,
                        weight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 43,
                width: 43,
                child: OutlinedButton(
                  onPressed: onSave,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryGreen,
                    padding: EdgeInsets.zero,
                    side: const BorderSide(color: AppColors.borderSlate),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                  child: const Icon(Icons.bookmark_border_rounded, size: 21),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metric(String label, String value) => Row(
    children: [
      Expanded(
        child: Text(label, style: _figtree(12, color: AppColors.textSecondary)),
      ),
      Text(value, style: _figtree(12, weight: FontWeight.w700)),
    ],
  );
}

class _CropSequence extends StatelessWidget {
  const _CropSequence({required this.crops});

  final List<String> crops;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 5,
    runSpacing: 5,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      for (var i = 0; i < crops.length; i++) ...[
        if (i > 0)
          const Icon(
            Icons.arrow_forward_rounded,
            size: 12,
            color: AppColors.textMuted,
          ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
          decoration: BoxDecoration(
            color: _cropColor(crops[i]).withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            crops[i],
            style: _figtree(
              11,
              weight: FontWeight.w700,
              color: _cropColor(crops[i]),
            ),
          ),
        ),
      ],
    ],
  );
}

Color _cropColor(String name) {
  switch (name.toLowerCase()) {
    case 'corn':
      return AppColors.accentBlue;
    case 'legume':
    case 'soybean':
      return const Color(0xFF8056D9);
    case 'wheat':
      return AppColors.secondaryBrown;
    default:
      return AppColors.primaryGreen;
  }
}

String _planLetter(int i) => String.fromCharCode(65 + i);

TextStyle _outfit(double size, {FontWeight weight = FontWeight.w600}) =>
    GoogleFonts.outfit(
      fontSize: size,
      fontWeight: weight,
      color: AppColors.textPrimary,
    );

TextStyle _figtree(
  double size, {
  FontWeight weight = FontWeight.w400,
  Color color = AppColors.textPrimary,
  TextDecoration? decoration,
}) => GoogleFonts.figtree(
  fontSize: size,
  fontWeight: weight,
  color: color,
  decoration: decoration,
);

/// Static numbers are shown ONLY when the real plan list is empty, and every
/// visible section labels them as illustrative prototype values.
const List<RotationPlanModel> _figmaPreviewPlans = [
  RotationPlanModel(
    id: 'figma-a',
    title: 'Plan A — Balanced Growth',
    description: 'Standard resilient progression',
    badgeLabel: 'Good Balance',
    matchPercent: 82,
    crops: ['Corn', 'Legume', 'Wheat'],
    waterDemandLabel: 'Medium',
    waterDemandPercent: 60,
    soilHealthScore: 84,
    climateResilienceScore: 81,
    biomassNitrogen: 'High (+42 kg/ha) — demo',
    rootingDepth: '0.8m–1.2m — demo',
  ),
  RotationPlanModel(
    id: 'figma-b',
    title: 'Plan B — Water Smart',
    description: 'Optimized for heat stress & dry seasons',
    badgeLabel: 'Best for Water',
    matchPercent: 79,
    crops: ['Corn', 'Wheat', 'Legume'],
    waterDemandLabel: 'Low',
    waterDemandPercent: 35,
    soilHealthScore: 78,
    climateResilienceScore: 86,
    biomassNitrogen: 'Moderate (+28 kg/ha) — demo',
    rootingDepth: 'Up to 1.8m — demo',
  ),
  RotationPlanModel(
    id: 'figma-c',
    title: 'Plan C — Yield Focus',
    description: 'Traditional high extraction rotation',
    badgeLabel: 'Highest Yield',
    matchPercent: 71,
    crops: ['Soybean', 'Corn', 'Wheat'],
    waterDemandLabel: 'High',
    waterDemandPercent: 80,
    soilHealthScore: 72,
    climateResilienceScore: 68,
    biomassNitrogen: 'Low (+12 kg/ha) — demo',
    rootingDepth: '0.5m–1.0m — demo',
  ),
];
