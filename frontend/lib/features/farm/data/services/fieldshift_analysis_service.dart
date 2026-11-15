import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../models/farm_analysis_result.dart';
import '../models/farm_priorities_model.dart';
import '../models/farm_profile_model.dart';

/// Client for the Field Shift FastAPI backend.
///
/// The analysis workflow is long-running (NASA POWER + research + LLM), so
/// this service uses extended timeouts instead of the shared ApiClient ones.
class FieldShiftAnalysisService {
  FieldShiftAnalysisService({ApiClient? apiClient})
    : _dio = (apiClient ?? ApiClient(baseUrl: defaultBaseUrl)).dio;

  /// Override at build/run time with:
  /// `flutter run --dart-define=API_BASE_URL=http://192.168.x.x:8000`
  static const String defaultBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000',
  );

  final Dio _dio;

  Future<FarmAnalysisResult> generateFarmAnalysis({
    required FarmProfileModel farmProfile,
    required FarmPrioritiesModel farmPriorities,
  }) async {
    final body = <String, dynamic>{
      ...farmProfile.toJson(),
      'priorities': farmPriorities.toJson(),
    };

    final response = await _dio.post<dynamic>(
      '/api/farm-analysis',
      data: body,
      options: Options(
        receiveTimeout: const Duration(minutes: 6),
        sendTimeout: const Duration(minutes: 1),
      ),
    );

    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw const FormatException(
        'Expected a JSON object from the analysis API.',
      );
    }
    return FarmAnalysisResult.fromResponse(data);
  }
}
