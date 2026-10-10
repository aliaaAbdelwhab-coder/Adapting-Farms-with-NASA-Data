import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';

class EnvironmentApiService {
  EnvironmentApiService({required ApiClient apiClient}) : _dio = apiClient.dio;

  final Dio _dio;

  Future<Map<String, dynamic>> fetchEnvironment({
    required String endpoint,
    required String method,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await _dio.request<dynamic>(
      endpoint,
      data: body,
      queryParameters: queryParameters,
      options: Options(method: method),
    );

    final data = response.data;

    if (data is Map<String, dynamic>) {
      return data;
    }

    throw const FormatException(
      'Expected a JSON object from the environment API.',
    );
  }
}
