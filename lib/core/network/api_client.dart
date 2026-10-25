import 'dart:async';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/env.dart';
import '../errors/app_failure.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

class ApiClient {
  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: Env.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        queryParameters: {'key': Env.weatherApiKey},
      ),
    );
  }

  late final Dio _dio;

  static const int _maxRetries = 2;

  /// GET that expects a JSON object (Map). Retries up to [_maxRetries] times.
  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return _withRetry(() async {
      final response = await _dio.get<dynamic>(
        path,
        queryParameters: queryParameters,
      );
      final data = response.data;
      if (data is Map<String, dynamic>) return data;
      throw const UnknownFailure('Unexpected response format.');
    });
  }

  /// GET that can return a JSON list OR object. Retries up to [_maxRetries] times.
  Future<dynamic> getRaw(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return _withRetry(() async {
      final response = await _dio.get<dynamic>(
        path,
        queryParameters: queryParameters,
      );
      return response.data;
    });
  }

  /// Wraps [fn] with exponential backoff retry. Does NOT retry on 4xx errors.
  Future<T> _withRetry<T>(Future<T> Function() fn) async {
    AppFailure? lastFailure;
    for (int attempt = 0; attempt <= _maxRetries; attempt++) {
      try {
        return await fn();
      } on DioException catch (e) {
        final failure = _mapDioError(e);
        lastFailure = failure;
        // Don't retry client errors (4xx)
        if (failure is ApiKeyFailure || failure is InvalidLocationFailure) {
          throw failure;
        }
        if (attempt < _maxRetries) {
          final delay = Duration(milliseconds: 500 * pow(2, attempt).toInt());
          await Future.delayed(delay);
        }
      } catch (e) {
        if (e is AppFailure) rethrow;
        lastFailure = UnknownFailure(e.toString());
        if (attempt < _maxRetries) {
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }
    }
    throw lastFailure ?? const UnknownFailure();
  }

  AppFailure _mapDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return const TimeoutFailure();
      case DioExceptionType.connectionError:
        return const NetworkFailure();
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 401 || statusCode == 403) {
          return const ApiKeyFailure();
        }
        if (statusCode == 429) {
          return const RateLimitFailure();
        }
        if (statusCode == 400) {
          final errorData = e.response?.data;
          if (errorData is Map) {
            final msg = errorData['error']?['message'] as String?;
            if (msg != null && msg.toLowerCase().contains('no matching')) {
              return const InvalidLocationFailure();
            }
          }
        }
        return UnknownFailure('Server error: $statusCode');
      default:
        return UnknownFailure(e.message ?? 'Unknown network error.');
    }
  }
}
