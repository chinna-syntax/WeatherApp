import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum NimbusThemeMode { auto, dark, light }

class NimbusSettings {
  const NimbusSettings({
    this.useCelsius = true,
    this.useKph = true,
    this.use24Hour = false,
    this.themeMode = NimbusThemeMode.auto,
    this.reduceMotion = false,
    this.useLocationOnLaunch = false,
  });

  final bool useCelsius;
  final bool useKph;
  final bool use24Hour;
  final NimbusThemeMode themeMode;
  final bool reduceMotion;
  final bool useLocationOnLaunch;

  NimbusSettings copyWith({
    bool? useCelsius,
    bool? useKph,
    bool? use24Hour,
    NimbusThemeMode? themeMode,
    bool? reduceMotion,
    bool? useLocationOnLaunch,
  }) {
    return NimbusSettings(
      useCelsius: useCelsius ?? this.useCelsius,
      useKph: useKph ?? this.useKph,
      use24Hour: use24Hour ?? this.use24Hour,
      themeMode: themeMode ?? this.themeMode,
      reduceMotion: reduceMotion ?? this.reduceMotion,
      useLocationOnLaunch: useLocationOnLaunch ?? this.useLocationOnLaunch,
    );
  }
}

final settingsProvider =
    NotifierProvider<SettingsNotifier, NimbusSettings>(SettingsNotifier.new);

class SettingsNotifier extends Notifier<NimbusSettings> {
  static const _prefix = 'nimbus_settings_';

  @override
  NimbusSettings build() {
    Future.microtask(_load);
    return const NimbusSettings();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt('${_prefix}theme') ?? 0;
    final safeThemeIndex = themeIndex.clamp(
      0,
      NimbusThemeMode.values.length - 1,
    );
    state = NimbusSettings(
      useCelsius: prefs.getBool('${_prefix}celsius') ?? true,
      useKph: prefs.getBool('${_prefix}kph') ?? true,
      use24Hour: prefs.getBool('${_prefix}24h') ?? false,
      themeMode: NimbusThemeMode.values[safeThemeIndex],
      reduceMotion: prefs.getBool('${_prefix}reduce_motion') ?? false,
      useLocationOnLaunch:
          prefs.getBool('${_prefix}location_launch') ?? false,
    );
  }

  Future<void> update(NimbusSettings next) async {
    state = next;
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setBool('${_prefix}celsius', next.useCelsius),
      prefs.setBool('${_prefix}kph', next.useKph),
      prefs.setBool('${_prefix}24h', next.use24Hour),
      prefs.setInt('${_prefix}theme', next.themeMode.index),
      prefs.setBool('${_prefix}reduce_motion', next.reduceMotion),
      prefs.setBool('${_prefix}location_launch', next.useLocationOnLaunch),
    ]);
  }

  Future<void> setReduceMotion(bool value) =>
      update(state.copyWith(reduceMotion: value));
}
