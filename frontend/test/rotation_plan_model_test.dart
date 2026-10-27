import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/farm/data/models/rotation_plan_model.dart';

void main() {
  const plan = RotationPlanModel(
    id: 'test-plan',
    title: 'Example',
    description: 'For tests only',
    badgeLabel: 'Test',
    matchPercent: 82,
    crops: ['Corn', 'Legume', 'Wheat'],
    waterDemandLabel: 'Medium',
    waterDemandPercent: 60,
    soilHealthScore: 84,
    climateResilienceScore: 81,
    biomassNitrogen: 'Not available',
    rootingDepth: 'Not available',
  );

  test('Rotation plan round-trips through JSON', () {
    final result = RotationPlanModel.fromJson(plan.toJson());
    expect(result.id, plan.id);
    expect(result.crops, plan.crops);
    expect(result.matchPercent, 82);
    expect(result.waterDemandPercent, 60);
    expect(result.soilHealthScore, 84);
    expect(result.climateResilienceScore, 81);
  });

  test('Missing details are preserved as unavailable', () {
    final data = plan.toJson()
      ..remove('biomassNitrogen')
      ..remove('rootingDepth');
    final result = RotationPlanModel.fromJson(data);
    expect(result.biomassNitrogen, 'Not available');
    expect(result.rootingDepth, 'Not available');
  });

  test('Invalid comparison percentages cannot be decoded', () {
    final data = plan.toJson()..['matchPercent'] = 125;
    expect(() => RotationPlanModel.fromJson(data), throwsFormatException);
  });

  test('Crop sequence must be strings', () {
    final data = plan.toJson()..['crops'] = [1, 2];
    expect(() => RotationPlanModel.fromJson(data), throwsFormatException);
  });
}
