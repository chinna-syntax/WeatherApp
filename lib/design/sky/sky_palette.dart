import 'package:flutter/material.dart';

/// Maps WeatherAPI condition codes + is_day to sky gradient palettes.
/// Each [SkyPalette] carries two gradient stops and a text scrim opacity.
class SkyPalette {
  const SkyPalette({
    required this.top,
    required this.bottom,
    this.scrimOpacity = 0.0,
  });

  final Color top;
  final Color bottom;

  /// Extra dark scrim under text to maintain WCAG contrast (0.0 – 0.5)
  final double scrimOpacity;

  LinearGradient toGradient() => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [top, bottom],
      );
}

// ---------------------------------------------------------------------------
// Palette definitions
// ---------------------------------------------------------------------------

class SkyPalettes {
  SkyPalettes._();

  // Clear day — open sky blue
  static const clearDay = SkyPalette(
    top: Color(0xFF4FA3E0),
    bottom: Color(0xFFBFE3F5),
  );

  // Clear night — deep navy
  static const clearNight = SkyPalette(
    top: Color(0xFF0B1026),
    bottom: Color(0xFF26325C),
    scrimOpacity: 0.15,
  );

  // Partly cloudy day
  static const partlyCloudyDay = SkyPalette(
    top: Color(0xFF6B90B8),
    bottom: Color(0xFFB8CDE0),
  );

  // Partly cloudy night
  static const partlyCloudyNight = SkyPalette(
    top: Color(0xFF0F1830),
    bottom: Color(0xFF2A3A58),
    scrimOpacity: 0.15,
  );

  // Cloudy day — muted steel
  static const cloudyDay = SkyPalette(
    top: Color(0xFF7E8FA3),
    bottom: Color(0xFFC9D2DC),
  );

  // Cloudy night
  static const cloudyNight = SkyPalette(
    top: Color(0xFF1A2030),
    bottom: Color(0xFF3A4660),
    scrimOpacity: 0.15,
  );

  // Rain
  static const rain = SkyPalette(
    top: Color(0xFF2F3E4F),
    bottom: Color(0xFF5C6F82),
    scrimOpacity: 0.1,
  );

  // Storm / thunder
  static const storm = SkyPalette(
    top: Color(0xFF1B1F2B),
    bottom: Color(0xFF3D3550),
    scrimOpacity: 0.2,
  );

  // Snow
  static const snow = SkyPalette(
    top: Color(0xFFAFC3D6),
    bottom: Color(0xFFEEF3F8),
    scrimOpacity: 0.05,
  );

  // Fog / mist
  static const fog = SkyPalette(
    top: Color(0xFF8C969E),
    bottom: Color(0xFFCDD3D8),
  );

  // Sleet / freezing rain
  static const sleet = SkyPalette(
    top: Color(0xFF4A5C72),
    bottom: Color(0xFF8FA8BE),
  );

  // Default fallback
  static const defaultPalette = clearDay;
}

// ---------------------------------------------------------------------------
// Resolver: WeatherAPI condition code → SkyPalette
// ---------------------------------------------------------------------------

SkyPalette paletteFromCondition(int conditionCode, bool isDay) {
  // WeatherAPI condition codes: https://www.weatherapi.com/docs/weather_conditions.json
  switch (conditionCode) {
    // Sunny / Clear
    case 1000:
      return isDay ? SkyPalettes.clearDay : SkyPalettes.clearNight;

    // Partly cloudy
    case 1003:
      return isDay
          ? SkyPalettes.partlyCloudyDay
          : SkyPalettes.partlyCloudyNight;

    // Cloudy / overcast
    case 1006:
    case 1009:
      return isDay ? SkyPalettes.cloudyDay : SkyPalettes.cloudyNight;

    // Mist
    case 1030:
      return SkyPalettes.fog;

    // Fog / freezing fog
    case 1135:
    case 1147:
      return SkyPalettes.fog;

    // Patchy rain / drizzle
    case 1063:
    case 1072:
    case 1150:
    case 1153:
    case 1168:
    case 1171:
    case 1180:
    case 1183:
    case 1186:
    case 1189:
    case 1192:
    case 1195:
    case 1198:
    case 1201:
    case 1240:
    case 1243:
    case 1246:
      return SkyPalettes.rain;

    // Thunder / storm
    case 1087:
    case 1273:
    case 1276:
    case 1279:
    case 1282:
      return SkyPalettes.storm;

    // Snow / blizzard
    case 1066:
    case 1114:
    case 1117:
    case 1210:
    case 1213:
    case 1216:
    case 1219:
    case 1222:
    case 1225:
    case 1255:
    case 1258:
      return SkyPalettes.snow;

    // Sleet / ice pellets
    case 1069:
    case 1204:
    case 1207:
    case 1249:
    case 1252:
      return SkyPalettes.sleet;

    // Blowing snow
    case 1261:
    case 1264:
      return SkyPalettes.snow;

    default:
      return isDay ? SkyPalettes.clearDay : SkyPalettes.clearNight;
  }
}
