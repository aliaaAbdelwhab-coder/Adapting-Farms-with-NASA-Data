import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/farm/data/models/farm_priorities_model.dart';

void main() {
  test('FarmPrioritiesModel serializes four 0-100 scores', () {
    const priorities = FarmPrioritiesModel(
      waterEfficiency: 80,
      soilHealth: 90,
      climateResilience: 65,
      yieldStability: 40,
    );

    final json = priorities.toJson();
    expect(json['waterEfficiency'], 80);
    expect(json['soilHealth'], 90);
    expect(json['climateResilience'], 65);
    expect(json['yieldStability'], 40);

    final decoded = FarmPrioritiesModel.fromJson(json);
    expect(decoded.waterEfficiency, priorities.waterEfficiency);
    expect(decoded.soilHealth, priorities.soilHealth);
    expect(decoded.climateResilience, priorities.climateResilience);
    expect(decoded.yieldStability, priorities.yieldStability);
  });
}
