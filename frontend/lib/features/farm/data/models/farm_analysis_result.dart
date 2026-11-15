import '../../../enviroment/data/models/environment_data_model.dart';
import 'rotation_plan_model.dart';

/// Combined result of one backend farm-analysis run: the NASA POWER climate
/// summary plus the generated rotation strategies, already shaped for the UI.
class FarmAnalysisResult {
  const FarmAnalysisResult({
    required this.environmentData,
    required this.plans,
    this.overallNotes = const <String>[],
    this.validationWarnings = const <String>[],
  });

  final EnvironmentDataModel environmentData;
  final List<RotationPlanModel> plans;
  final List<String> overallNotes;
  final List<String> validationWarnings;

  factory FarmAnalysisResult.fromResponse(Map<String, dynamic> json) {
    final environment = json['environment'];
    final rawPlans = json['plans'];

    final plans = <RotationPlanModel>[];
    if (rawPlans is List) {
      for (final item in rawPlans) {
        if (item is Map<String, dynamic>) {
          plans.add(RotationPlanModel.fromJson(item));
        }
      }
    }

    return FarmAnalysisResult(
      environmentData: environment is Map<String, dynamic>
          ? EnvironmentDataModel.fromJson(environment)
          : const EnvironmentDataModel(),
      plans: List<RotationPlanModel>.unmodifiable(plans),
      overallNotes: _stringList(json['overallNotes']),
      validationWarnings: _stringList(json['validationWarnings']),
    );
  }

  static List<String> _stringList(Object? value) {
    if (value is! List) return const <String>[];
    return value
        .whereType<String>()
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList(growable: false);
  }
}
