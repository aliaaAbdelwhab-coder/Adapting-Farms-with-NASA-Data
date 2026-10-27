import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_shell.dart';
import '../../../../core/widgets/app_sidebar.dart';
import '../../../farm/data/models/farm_priorities_model.dart';
import '../../../farm/data/models/farm_profile_model.dart';
import '../../../farm/presentation/widgets/farm_setup_header.dart';
import '../../data/models/environment_data_model.dart';

/// NASA dashboard UI. A real repository connection will be added separately.
/// This screen deliberately does not create or imply live NASA measurements.
class EnvironmentScreen extends StatelessWidget {
  const EnvironmentScreen({
    super.key,
    required this.farmProfile,
    required this.farmPriorities,
    this.environmentData = const EnvironmentDataModel(),
  });

  final FarmProfileModel farmProfile;
  final FarmPrioritiesModel farmPriorities;
  final EnvironmentDataModel environmentData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppShell(
        activeSection: AppSidebarSection.nasaData,
        farmName: farmProfile.farmName,
        farmLocation: farmProfile.location,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Desktop AppShell has already removed its 280px sidebar.
              final isMobile =
                  MediaQuery.sizeOf(context).width < AppShell.desktopBreakpoint;
              return Column(
                children: [
                  if (isMobile)
                    FarmSetupHeader(onBack: () => Navigator.pop(context)),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1200),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 20 : 40,
                              vertical: isMobile ? 24 : 40,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildHeading(isMobile),
                                SizedBox(height: isMobile ? 24 : 32),
                                _buildMetrics(),
                                SizedBox(height: isMobile ? 20 : 28),
                                _SeasonalChartCard(
                                  environmentData: environmentData,
                                  isMobile: isMobile,
                                ),
                                const SizedBox(height: 20),
                                _buildConnectionNote(),
                                const SizedBox(height: 28),
                                _buildActions(context, isMobile),
                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeading(bool isMobile) {
    final rawName = farmProfile.farmName.trim();
    final farmName = rawName.isEmpty ? 'Your Farm' : rawName;
    final location = farmProfile.location.trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isMobile)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  '$farmName Environment',
                  style: _outfit(30, weight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 12),
              _StatusPill(connected: environmentData.hasData),
            ],
          )
        else
          Text('Environment', style: _outfit(28, weight: FontWeight.w700)),
        const SizedBox(height: 6),
        Text(
          environmentData.hasData
              ? 'Environmental observations for $farmName.'
              : 'NASA Earth observation data is not connected yet.',
          style: _figtree(isMobile ? 13 : 15, color: AppColors.textSecondary),
        ),
        if (location.isNotEmpty) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 15,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  'Farm location: $location',
                  style: _figtree(12, color: AppColors.textSecondary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
        if (isMobile) ...[
          const SizedBox(height: 10),
          _StatusPill(connected: environmentData.hasData),
        ],
      ],
    );
  }

  Widget _buildMetrics() {
    final data = environmentData;
    final hasAirTemperature = data.temperature != null;
    final temperature = hasAirTemperature
        ? data.temperature
        : data.landSurfaceTemperature;
    final temperatureLabel = hasAirTemperature
        ? 'Air temperature (°C)'
        : 'Land surface temperature (°C)';

    final metrics = <Widget>[
      _MetricCard(
        name: 'Temperature',
        value: _formatValue(temperature, decimals: 1),
        unit: temperature == null ? '' : '°C',
        color: AppColors.alertAmber,
        supportingText: temperature == null
            ? 'Awaiting NASA observations'
            : temperatureLabel,
      ),
      _MetricCard(
        name: 'Rainfall',
        value: _formatValue(data.precipitation, decimals: 1),
        unit: data.precipitation == null ? '' : 'mm',
        color: AppColors.accentBlue,
        supportingText: data.precipitation == null
            ? 'Awaiting rainfall data'
            : 'Reporting period defined by source',
      ),
      _MetricCard(
        name: 'Soil Moisture',
        value: _formatValue(data.soilMoisture, decimals: 2),
        unit: data.soilMoisture == null ? '' : 'm³/m³',
        color: AppColors.secondaryBrown,
        supportingText: data.soilMoisture == null
            ? 'Awaiting soil moisture data'
            : 'Volumetric water content',
      ),
      _MetricCard(
        name: 'Vegetation Health',
        value: _formatValue(data.vegetationIndex, decimals: 2),
        unit: data.vegetationIndex == null ? '' : 'NDVI',
        color: AppColors.primaryGreen,
        supportingText: data.vegetationIndex == null
            ? 'Awaiting vegetation data'
            : 'Normalized difference vegetation index',
      ),
      _MetricCard(
        name: 'Solar Radiation',
        value: _formatValue(data.solarRadiation, decimals: 2),
        unit: data.solarRadiation == null ? '' : 'kWh/m²/d',
        color: AppColors.alertAmber,
        supportingText: data.solarRadiation == null
            ? 'Awaiting radiation data'
            : 'Mean daily solar radiation',
      ),
      _MetricCard(
        name: 'Growing Season',
        value: data.growingSeasonDays?.toString() ?? 'Pending',
        unit: data.growingSeasonDays == null ? '' : 'days',
        color: AppColors.secondaryBrown,
        supportingText: data.growingSeasonDays == null
            ? 'Awaiting growing season data'
            : 'Growing season length',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        // Two compact cards on phone; three balanced columns on desktop.
        final columns = width >= 780 ? 3 : (width >= 300 ? 2 : 1);
        final spacing = width < 600 ? 12.0 : 16.0;
        final cardWidth = (width - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: metrics
              .map((metric) => SizedBox(width: cardWidth, child: metric))
              .toList(growable: false),
        );
      },
    );
  }

  Widget _buildConnectionNote() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F2E8),
        border: Border.all(color: AppColors.borderSlate),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.satellite_alt_outlined,
            color: AppColors.secondaryBrown,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Data connection pending. All missing readings and charts are '
              'shown as pending—not as simulated NASA results. '
              'Values will appear when the environment data service is connected.',
              style: _figtree(13, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, bool isMobile) {
    return isMobile
        ? SizedBox(width: double.infinity, child: _nextButton(context))
        : Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back'),
              ),
              const SizedBox(width: 16),
              _nextButton(context),
            ],
          );
  }

  Widget _nextButton(BuildContext context) {
    return FilledButton.icon(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: () => Navigator.pushNamed(
        context,
        AppRouter.rotationStrategy,
        arguments: {
          'farmProfile': farmProfile,
          'farmPriorities': farmPriorities,
        },
      ),
      icon: const Icon(Icons.arrow_forward, size: 18),
      label: Text(
        'Continue to Rotation Strategy',
        style: _figtree(14, weight: FontWeight.w700, color: Colors.white),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.connected});

  final bool connected;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        decoration: BoxDecoration(
          color: connected ? const Color(0xFFE7F3EB) : const Color(0xFFEBE9E4),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          connected ? 'Readings available' : 'NASA data not connected',
          style: _figtree(
            11,
            weight: FontWeight.w600,
            color: connected ? AppColors.primaryGreen : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.name,
    required this.value,
    required this.unit,
    required this.color,
    required this.supportingText,
  });

  final String name;
  final String value;
  final String unit;
  final Color color;
  final String supportingText;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 900;
    final pending = value == 'Pending';
    return Container(
      height: compact ? 164 : 174,
      padding: EdgeInsets.all(compact ? 12 : 18),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        border: Border.all(color: AppColors.borderSlate),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x07000000),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _figtree(
                    compact ? 11 : 13,
                    color: AppColors.textSecondary,
                    weight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  compact ? 'NASA' : 'NASA DATA',
                  style: _figtree(
                    compact ? 8 : 9,
                    color: color,
                    weight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: _outfit(compact ? 24 : 29, weight: FontWeight.w700),
                ),
                if (unit.isNotEmpty) ...[
                  const SizedBox(width: 5),
                  Text(
                    unit,
                    style: _figtree(12, color: AppColors.textSecondary),
                  ),
                ],
              ],
            ),
          ),
          const Spacer(),
          Row(
            children: [
              Icon(
                pending ? Icons.schedule_outlined : Icons.check_circle_outline,
                color: pending ? AppColors.textMuted : AppColors.primaryGreen,
                size: 13,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  supportingText,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: _figtree(10, color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SeasonalChartCard extends StatelessWidget {
  const _SeasonalChartCard({
    required this.environmentData,
    required this.isMobile,
  });

  final EnvironmentDataModel environmentData;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    final hasMonthlyData = environmentData.hasMonthlyData;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        border: Border.all(color: AppColors.borderSlate),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 8,
            alignment: WrapAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isMobile
                        ? 'Seasonal Climate Overview'
                        : 'Seasonal Climatology Cycle',
                    style: _outfit(16, weight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Monthly temperature and rainfall observations',
                    style: _figtree(11, color: AppColors.textSecondary),
                  ),
                ],
              ),
              if (hasMonthlyData)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _LegendDot(
                      label: 'Temperature',
                      color: AppColors.alertAmber,
                    ),
                    const SizedBox(width: 12),
                    _LegendDot(label: 'Rainfall', color: AppColors.accentBlue),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 20),
          if (!hasMonthlyData)
            Container(
              height: isMobile ? 175 : 220,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFF9F8F5),
                border: Border.all(color: AppColors.borderSlate),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.show_chart,
                    size: 32,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Monthly data pending',
                    style: _figtree(14, weight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'No climatology chart is available yet.',
                    style: _figtree(11, color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            SizedBox(
              height: isMobile ? 190 : 270,
              width: double.infinity,
              child: CustomPaint(
                painter: _SeasonalDataPainter(
                  temperatures: environmentData.monthlyMeanTemperatureC,
                  rainfall: environmentData.monthlyPrecipitationMm,
                ),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children:
                          const [
                                'Jan',
                                'Feb',
                                'Mar',
                                'Apr',
                                'May',
                                'Jun',
                                'Jul',
                                'Aug',
                                'Sep',
                                'Oct',
                                'Nov',
                                'Dec',
                              ]
                              .map(
                                (month) => Text(
                                  month,
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              )
                              .toList(growable: false),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      const SizedBox(width: 5),
      Text(label, style: _figtree(10, color: AppColors.textSecondary)),
    ],
  );
}

/// Renders only values supplied in EnvironmentDataModel.
/// The two series are independently scaled, so this is a visual trend chart,
/// not a common-axis numerical comparison.
class _SeasonalDataPainter extends CustomPainter {
  const _SeasonalDataPainter({
    required this.temperatures,
    required this.rainfall,
  });

  final List<double?>? temperatures;
  final List<double?>? rainfall;

  @override
  void paint(Canvas canvas, Size size) {
    const bottomMargin = 26.0;
    const topMargin = 12.0;
    final chartWidth = size.width;
    final chartHeight = math.max(1.0, size.height - topMargin - bottomMargin);
    final bottom = topMargin + chartHeight;

    final gridPaint = Paint()
      ..color = AppColors.borderSlate
      ..strokeWidth = 1;
    for (var i = 0; i < 4; i++) {
      final y = topMargin + chartHeight * i / 3;
      canvas.drawLine(Offset(0, y), Offset(chartWidth, y), gridPaint);
    }

    final rainfallValues = rainfall;
    if (rainfallValues != null) {
      final nonNullRainfall = rainfallValues.whereType<double>().toList();
      final maxRainfall = nonNullRainfall.isEmpty
          ? 1.0
          : math.max(1.0, nonNullRainfall.reduce(math.max));
      final barPaint = Paint()
        ..color = AppColors.accentBlue.withValues(alpha: 0.68);
      final gap = chartWidth / 12;
      final barWidth = math.min(24.0, gap * 0.45);
      for (var i = 0; i < 12; i++) {
        final value = rainfallValues[i];
        if (value == null) continue;
        final height = chartHeight * (value / maxRainfall).clamp(0.0, 1.0);
        final x = gap * (i + 0.5);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x - barWidth / 2, bottom - height, barWidth, height),
            const Radius.circular(2),
          ),
          barPaint,
        );
      }
    }

    final temperatureValues = temperatures;
    if (temperatureValues != null) {
      final nonNull = temperatureValues.whereType<double>().toList();
      if (nonNull.isNotEmpty) {
        final minValue = nonNull.reduce(math.min);
        final maxValue = nonNull.reduce(math.max);
        final range = math.max(1.0, maxValue - minValue);
        final linePaint = Paint()
          ..color = AppColors.alertAmber
          ..strokeWidth = 2.5
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;
        Path? activePath;
        final gap = chartWidth / 12;
        for (var i = 0; i < 12; i++) {
          final value = temperatureValues[i];
          if (value == null) {
            if (activePath != null) {
              canvas.drawPath(activePath, linePaint);
              activePath = null;
            }
            continue;
          }
          final x = gap * (i + 0.5);
          final y = bottom - chartHeight * ((value - minValue) / range);
          if (activePath == null) {
            activePath = Path()..moveTo(x, y);
          } else {
            activePath.lineTo(x, y);
          }
          canvas.drawCircle(
            Offset(x, y),
            2.5,
            Paint()..color = AppColors.alertAmber,
          );
        }
        if (activePath != null) canvas.drawPath(activePath, linePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SeasonalDataPainter oldDelegate) =>
      oldDelegate.temperatures != temperatures ||
      oldDelegate.rainfall != rainfall;
}

String _formatValue(double? value, {required int decimals}) =>
    value == null ? 'Pending' : value.toStringAsFixed(decimals);

TextStyle _outfit(double size, {FontWeight weight = FontWeight.w600}) =>
    GoogleFonts.outfit(
      fontSize: size,
      fontWeight: weight,
      color: AppColors.textPrimary,
    );

TextStyle _figtree(
  double size, {
  FontWeight weight = FontWeight.w400,
  Color? color,
}) => GoogleFonts.figtree(
  fontSize: size,
  fontWeight: weight,
  color: color ?? AppColors.textPrimary,
);
