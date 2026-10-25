import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/errors/app_failure.dart';
import '../../core/network/api_client.dart';
import '../models/weather_models.dart';
import '../services/cache_service.dart';

final weatherRepositoryProvider = Provider<WeatherRepository>((ref) {
  return WeatherRepository(
    ref.watch(apiClientProvider),
    ref.watch(cacheServiceProvider),
  );
});

class WeatherRepository {
  WeatherRepository(this._client, this._cache);

  final ApiClient _client;
  final CacheService _cache;

  /// Fetches a 3-day forecast with cache-first strategy.
  ///
  /// - If [forceRefresh] is false and cache is < 10 min old → return cached.
  /// - On network failure → return cached data if available, else throw.
  Future<WeatherResponse> getForecast(
    String q, {
    bool forceRefresh = false,
  }) async {
    final normalizedQ = q.trim();
    if (normalizedQ.isEmpty) {
      throw const InvalidLocationFailure();
    }

    // Return fresh cache if not forcing refresh
    if (!forceRefresh && await _cache.isFresh(normalizedQ)) {
      final cached = await _cache.loadWeather(normalizedQ);
      if (cached != null) return cached;
    }

    try {
      final data = await _client.get(
        '/forecast.json',
        queryParameters: {
          'q': normalizedQ,
          'days': 3,
          'aqi': 'yes',
          'alerts': 'no',
        },
      );
      // Save raw JSON to cache for offline use
      await _cache.saveWeather(normalizedQ, data);
      return WeatherResponse.fromJson(data);
    } on AppFailure catch (e) {
      // Fall back to cached data on network/timeout errors
      if (e is NetworkFailure || e is TimeoutFailure) {
        final cached = await _cache.loadWeather(normalizedQ);
        if (cached != null) return cached;
      }
      rethrow;
    }
  }

  /// Auto-complete search for city names.
  Future<List<SearchResult>> searchLocations(String query) async {
    if (query.trim().isEmpty) return [];
    final data = await _client.getRaw(
      '/search.json',
      queryParameters: {'q': query.trim()},
    );
    if (data is List) {
      return data
          .map((item) => SearchResult.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }
}
