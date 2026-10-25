import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weather_models.dart';

final cacheServiceProvider = Provider<CacheService>((_) => CacheService());

/// Cache keys
const _cachePrefix = 'weather_cache_';
const _cacheTimestampPrefix = 'weather_ts_';
const _savedCitiesKey = 'saved_cities_v2';

/// How long before a cached response is considered stale (10 min).
const _cacheMaxAge = Duration(minutes: 10);

class CacheService {
  /// Save a WeatherResponse for a given query key.
  Future<void> saveWeather(String query, Map<String, dynamic> rawJson) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _cacheKey(query);
    await prefs.setString(key, jsonEncode(rawJson));
    await prefs.setInt(_tsKey(query), _nowMs());
  }

  /// Load cached WeatherResponse. Returns null if absent.
  Future<WeatherResponse?> loadWeather(String query) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cacheKey(query));
    if (raw == null) return null;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return WeatherResponse.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  /// Returns the age of the cached data, or null if not cached.
  Future<Duration?> cacheAge(String query) async {
    final prefs = await SharedPreferences.getInstance();
    final ts = prefs.getInt(_tsKey(query));
    if (ts == null) return null;
    return Duration(milliseconds: _nowMs() - ts);
  }

  /// Returns true if data is fresh enough (< 10 minutes old).
  Future<bool> isFresh(String query) async {
    final age = await cacheAge(query);
    if (age == null) return false;
    return age < _cacheMaxAge;
  }

  /// Returns formatted age string like "2 hours ago" or "5 minutes ago".
  Future<String?> cacheAgeLabel(String query) async {
    final age = await cacheAge(query);
    if (age == null) return null;
    if (age.inMinutes < 1) return 'just now';
    if (age.inHours < 1) return '${age.inMinutes} min ago';
    if (age.inHours == 1) return '1 hour ago';
    return '${age.inHours} hours ago';
  }

  // --- Saved cities ---

  Future<List<SavedCity>> loadSavedCities() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_savedCitiesKey);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => SavedCity.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveCities(List<SavedCity> cities) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _savedCitiesKey,
      jsonEncode(cities.map((c) => c.toJson()).toList()),
    );
  }

  Future<void> addCity(SavedCity city) async {
    final cities = await loadSavedCities();
    if (!cities.contains(city)) {
      cities.add(city);
      await saveCities(cities);
    }
  }

  Future<void> removeCity(String query) async {
    final cities = await loadSavedCities();
    cities.removeWhere((c) => c.query == query);
    await saveCities(cities);
  }

  // --- Current city key (legacy compat) ---

  Future<String?> loadCurrentQuery() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('saved_city');
  }

  Future<void> saveCurrentQuery(String query) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_city', query);
  }

  Future<void> clearWeatherCache() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys()
        .where((key) =>
            key.startsWith(_cachePrefix) || key.startsWith(_cacheTimestampPrefix))
        .toList();
    await Future.wait(keys.map(prefs.remove));
  }

  // --- Helpers ---

  String _cacheKey(String query) => '$_cachePrefix${_normalizeKey(query)}';
  String _tsKey(String query) =>
      '$_cacheTimestampPrefix${_normalizeKey(query)}';
  String _normalizeKey(String q) => q.toLowerCase().replaceAll(' ', '_');
  int _nowMs() => DateTime.now().millisecondsSinceEpoch;
}
