import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/farm/data/models/farm_analysis_result.dart';

void main() {
  test('Parses the UI-ready backend payload', () {
    final result = FarmAnalysisResult.fromResponse({
      'environment': {
        'temperature': 22.73,
        'precipitation': 62.51,
        'monthlyMeanTemperatureC': [15.4, null, 18.9] + List.filled(9, null),
        'monthlyPrecipitationMm': List.filled(12, null),
      },
      'plans': [
        {
          'id': 'strategy-1',
          'title': 'Maize-Soybean Rotation',
          'description': 'rationale\nSeasons: Summer → Winter',
          'badgeLabel': 'Generated Plan',
          'matchPercent': null,
          'crops': ['Maize', 'Soybean'],
          'waterDemandLabel': null,
          'waterDemandPercent': null,
          'soilHealthScore': null,
          'climateResilienceScore': null,
          'biomassNitrogen': 'Not available',
          'rootingDepth': 'Not available',
        },
      ],
      'overallNotes': ['note one'],
      'validationWarnings': ['warning one'],
    });

    expect(result.environmentData.temperature, 22.73);
    expect(result.environmentData.precipitation, 62.51);
    expect(result.environmentData.hasData, isTrue);
    expect(result.plans, hasLength(1));
    expect(result.plans.single.title, 'Maize-Soybean Rotation');
    expect(result.plans.single.crops, ['Maize', 'Soybean']);
    expect(result.plans.single.matchPercent, isNull);
    expect(result.overallNotes, ['note one']);
    expect(result.validationWarnings, ['warning one']);
  });

  test('Missing sections degrade to empty data', () {
    final result = FarmAnalysisResult.fromResponse(const {});
    expect(result.environmentData.hasData, isFalse);
    expect(result.plans, isEmpty);
    expect(result.overallNotes, isEmpty);
    expect(result.validationWarnings, isEmpty);
  });
}
