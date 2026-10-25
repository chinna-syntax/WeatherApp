import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/errors/app_failure.dart';
import '../../data/models/weather_models.dart';
import '../../data/repositories/weather_repository.dart';
import '../../data/services/cache_service.dart';
import '../../data/services/location_service.dart';
import '../../core/settings/settings_controller.dart';

// ---------------------------------------------------------------------------
// Connectivity providers (unchanged from Stage 1)
// ---------------------------------------------------------------------------

final connectivityProvider = StreamProvider<List<ConnectivityResult>>((ref) {
  return Connectivity().onConnectivityChanged;
});

final isOfflineProvider = Provider<bool>((ref) {
  final conn = ref.watch(connectivityProvider);
  return conn.whenData((results) {
    return results.every((r) => r == ConnectivityResult.none);
  }).valueOrNull ??
      false;
});

// ---------------------------------------------------------------------------
// Cities list provider
// ---------------------------------------------------------------------------

final savedCitiesProvider =
    NotifierProvider<SavedCitiesNotifier, List<SavedCity>>(
        SavedCitiesNotifier.new);

class SavedCitiesNotifier extends Notifier<List<SavedCity>> {
  @override
  List<SavedCity> build() {
    Future.microtask(_load);
    return [];
  }

  CacheService get _cache => ref.read(cacheServiceProvider);

  Future<void> _load() async {
    final cities = await _cache.loadSavedCities();
    state = cities;
  }

  Future<void> addCity(SavedCity city) async {
    if (state.any((c) => c.query == city.query)) return;
    state = [...state, city];
    await _cache.saveCities(state);
  }

  Future<SavedCity?> removeCity(String query) async {
    final removed = state.firstWhere(
      (c) => c.query == query,
      orElse: () => const SavedCity(query: '', name: '', country: ''),
    );
    if (removed.query.isEmpty) return null;
    state = state.where((c) => c.query != query).toList();
    await _cache.saveCities(state);
    return removed;
  }

  Future<void> restoreCity(SavedCity city, int index) async {
    final list = [...state];
    final insertAt = index.clamp(0, list.length);
    list.insert(insertAt, city);
    state = list;
    await _cache.saveCities(state);
  }
}

// ---------------------------------------------------------------------------
// Per-city weather provider (for cities screen parallel fetching)
// ---------------------------------------------------------------------------

final cityWeatherProvider = FutureProvider.family<WeatherResponse, String>(
  (ref, query) async {
    final repo = ref.watch(weatherRepositoryProvider);
    return repo.getForecast(query);
  },
);

// ---------------------------------------------------------------------------
// Home state
// ---------------------------------------------------------------------------

class HomeState {
  const HomeState({
    this.weather,
    this.failure,
    this.isLoading = false,
    this.savedQuery,
    this.useCelsius = true,
    this.cacheAgeLabel,
    this.isFromCache = false,
  });

  final WeatherResponse? weather;
  final AppFailure? failure;
  final bool isLoading;
  final String? savedQuery;
  final bool useCelsius;
  final String? cacheAgeLabel;
  final bool isFromCache;

  bool get hasData => weather != null;
  bool get hasError => failure != null && weather == null;

  HomeState copyWith({
    WeatherResponse? weather,
    AppFailure? failure,
    bool? isLoading,
    String? savedQuery,
    bool? useCelsius,
    String? cacheAgeLabel,
    bool? isFromCache,
    bool clearFailure = false,
    bool clearCache = false,
  }) {
    return HomeState(
      weather: weather ?? this.weather,
      failure: clearFailure ? null : (failure ?? this.failure),
      isLoading: isLoading ?? this.isLoading,
      savedQuery: savedQuery ?? this.savedQuery,
      useCelsius: useCelsius ?? this.useCelsius,
      cacheAgeLabel: clearCache ? null : (cacheAgeLabel ?? this.cacheAgeLabel),
      isFromCache: isFromCache ?? this.isFromCache,
    );
  }
}

// ---------------------------------------------------------------------------
// Home controller
// ---------------------------------------------------------------------------

final homeControllerProvider =
    NotifierProvider<HomeController, HomeState>(HomeController.new);

class HomeController extends Notifier<HomeState> {
  @override
  HomeState build() => const HomeState(isLoading: true);

  WeatherRepository get _repo => ref.read(weatherRepositoryProvider);
  CacheService get _cache => ref.read(cacheServiceProvider);
  LocationService get _location => ref.read(locationServiceProvider);

  /// Load weather for [query]. Uses cache unless [forceRefresh] is true.
  Future<void> loadWeather(String query, {bool forceRefresh = false}) async {
    state = state.copyWith(
      isLoading: true,
      savedQuery: query,
      clearFailure: true,
    );
    try {
      final weather =
          await _repo.getForecast(query, forceRefresh: forceRefresh);
      await _cache.saveCurrentQuery(query);

      final ageLabel = await _cache.cacheAgeLabel(query);
      final age = await _cache.cacheAge(query);
      final isFromCache = age != null && age.inSeconds > 5;

      state = state.copyWith(
        weather: weather,
        isLoading: false,
        clearFailure: true,
        cacheAgeLabel: isFromCache ? ageLabel : null,
        isFromCache: isFromCache,
      );
    } on AppFailure catch (e) {
      // If we have cached data, show it with an error banner instead of error screen
      if (state.hasData) {
        state = state.copyWith(isLoading: false, failure: e);
      } else {
        final cached = await _cache.loadWeather(query);
        if (cached != null) {
          final ageLabel = await _cache.cacheAgeLabel(query);
          state = state.copyWith(
            weather: cached,
            isLoading: false,
            failure: e,
            cacheAgeLabel: ageLabel,
            isFromCache: true,
          );
        } else {
          state = state.copyWith(isLoading: false, failure: e);
        }
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        failure: UnknownFailure(e.toString()),
      );
    }
  }

  /// Pull-to-refresh always forces a network fetch.
  Future<void> refresh() async {
    final q = state.savedQuery;
    if (q != null) await loadWeather(q, forceRefresh: true);
  }

  /// Called on app launch; loads from saved prefs.
  Future<void> loadSavedCity() async {
    final saved = await _cache.loadCurrentQuery();
    final settings = ref.read(settingsProvider);
    if (settings.useLocationOnLaunch) {
      try {
        final query = await _location.getCurrentLocationQuery();
        await loadWeather(query);
        return;
      } on AppFailure catch (e) {
        if (saved == null || saved.isEmpty) {
          state = state.copyWith(isLoading: false, failure: e);
          return;
        }
      }
    }
    if (saved != null && saved.isNotEmpty) {
      await loadWeather(saved);
    } else {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Switch to a different city query (from cities screen or search).
  Future<void> switchCity(String query) async {
    await _cache.saveCurrentQuery(query);
    await loadWeather(query);
  }
}
