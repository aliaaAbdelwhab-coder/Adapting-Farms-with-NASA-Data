import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/crop_reference/data/models/crop_reference_model.dart';

void main() {
  test('contains four distinct design-reference crop profiles', () {
    expect(figmaCropReferenceExamples.length, 4);
    expect(figmaCropReferenceExamples.map((e) => e.id).toSet().length, 4);
  });

  test('model round trips without dropping reference fields', () {
    final sample = figmaCropReferenceExamples.first;
    final restored = CropReferenceModel.fromJson(sample.toJson());
    expect(restored.toJson(), sample.toJson());
  });

  test('rejects a missing required crop title', () {
    final invalid = Map<String, dynamic>.from(
      figmaCropReferenceExamples.first.toJson(),
    )..remove('name');
    expect(() => CropReferenceModel.fromJson(invalid), throwsFormatException);
  });

  test('rejects a metric value outside zero through one hundred', () {
    final invalid = Map<String, dynamic>.from(
      figmaCropReferenceExamples.first.toJson(),
    )..['waterLevel'] = 110;
    expect(() => CropReferenceModel.fromJson(invalid), throwsFormatException);
  });

  test('rejects a fractional metric level rather than truncating', () {
    final invalid = Map<String, dynamic>.from(
      figmaCropReferenceExamples.first.toJson(),
    )..['heatLevel'] = 74.5;
    expect(() => CropReferenceModel.fromJson(invalid), throwsFormatException);
  });
}
