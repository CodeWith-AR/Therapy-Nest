import 'package:dio/dio.dart';

import '../../core/errors/failure.dart';
import '../../core/utils/logger.dart';
import '../storage/token_store.dart';
import 'api_response.dart';

/// HTTP client wrapper using [Dio].
/// Handles auth headers, request building, and error normalization.
/// Used for custom API endpoints (Render/Koyeb FastAPI backend).
/// Supabase operations use supabase_flutter directly in repositories.
class ApiClient {
  ApiClient(this._tokenStore) {
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _tokenStore.getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        AppLogger.debug('${options.method} ${options.uri}', tag: 'ApiClient');
        handler.next(options);
      },
      onError: (error, handler) {
        AppLogger.error(
          'API Error: ${error.response?.statusCode} ${error.message}',
          tag: 'ApiClient',
        );
        handler.next(error);
      },
    ));
  }

  final TokenStore _tokenStore;
  late final Dio _dio;

  void setBaseUrl(String baseUrl) {
    _dio.options.baseUrl = baseUrl;
  }

  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.get(endpoint, queryParameters: queryParams);
      return ApiResponse.success(
        data: fromJson != null ? fromJson(response.data) : response.data as T,
        statusCode: response.statusCode ?? 200,
      );
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.post(endpoint, data: body);
      return ApiResponse.success(
        data: fromJson != null ? fromJson(response.data) : response.data as T,
        statusCode: response.statusCode ?? 200,
      );
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.put(endpoint, data: body);
      return ApiResponse.success(
        data: fromJson != null ? fromJson(response.data) : response.data as T,
        statusCode: response.statusCode ?? 200,
      );
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.delete(endpoint);
      return ApiResponse.success(
        data: fromJson != null ? fromJson(response.data) : response.data as T,
        statusCode: response.statusCode ?? 200,
      );
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Failure _mapDioError(DioException e) {
    return switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout =>
        const TimeoutFailure(),
      DioExceptionType.connectionError => const NetworkFailure(),
      DioExceptionType.badResponse => _mapStatusCode(e.response),
      _ => const UnknownFailure(),
    };
  }

  Failure _mapStatusCode(Response? response) {
    final statusCode = response?.statusCode ?? 500;
    final message = response?.data is Map
        ? (response!.data['message'] as String?) ?? 'Request failed'
        : 'Request failed';

    return switch (statusCode) {
      401 || 403 => const UnauthorizedFailure(),
      400 || 422 => ValidationFailure(message),
      >= 500 => ServerFailure(message),
      _ => UnknownFailure(message),
    };
  }
}
