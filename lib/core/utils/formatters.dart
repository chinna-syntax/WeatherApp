import 'package:intl/intl.dart';
import '../strings.dart';

class Formatters {
  Formatters._();

  /// "7:42 PM"
  static String formatTime(DateTime dt, {bool use24Hour = false}) =>
      DateFormat(use24Hour ? 'HH:mm' : 'h:mm a').format(dt);

  /// "Mon, Oct 25"
  static String formatDate(DateTime dt) => DateFormat('EEE, MMM d').format(dt);

  /// Day abbreviation "Mon"
  static String formatDayShort(DateTime dt) => DateFormat('EEE').format(dt);

  /// Format temperature without unit symbol
  static String formatTemp(double temp) => temp.round().toString();

  /// Convert m/s to kph
  static double msToKph(double ms) => ms * 3.6;
  static double kphToMph(double kph) => kph * 0.621371;

  /// UV Index category string
  static String uvCategory(double uv) {
    if (uv <= 2) return 'Low';
    if (uv <= 5) return 'Moderate';
    if (uv <= 7) return 'High';
    if (uv <= 10) return 'Very High';
    return 'Extreme';
  }

  /// UV explanation for details screen
  static String uvExplanation(double uv) {
    if (uv <= 2) return NimbusStrings.uvLow;
    if (uv <= 5) return NimbusStrings.uvModerate;
    if (uv <= 7) return NimbusStrings.uvHigh;
    if (uv <= 10) return NimbusStrings.uvVeryHigh;
    return NimbusStrings.uvExtreme;
  }

  /// Humidity explanation
  static String humidityExplanation(int humidity) {
    if (humidity < 30) return NimbusStrings.humidityLow;
    if (humidity <= 60) return NimbusStrings.humidityComfort;
    return NimbusStrings.humidityHigh;
  }

  /// Visibility explanation
  static String visibilityExplanation(double visKm) {
    if (visKm >= 10) return NimbusStrings.visibilityGood;
    if (visKm >= 4) return NimbusStrings.visibilityModerate;
    return NimbusStrings.visibilityPoor;
  }

  /// AQI US EPA label
  static String aqiLabel(int index) {
    switch (index) {
      case 1:
        return NimbusStrings.aqiGood;
      case 2:
        return NimbusStrings.aqiModerate;
      case 3:
        return NimbusStrings.aqiSensitive;
      case 4:
        return NimbusStrings.aqiUnhealthy;
      case 5:
        return NimbusStrings.aqiVeryUnhealthy;
      default:
        return NimbusStrings.aqiHazardous;
    }
  }

  /// Sunrise/sunset from epoch
  static String formatEpoch(int epoch) {
    final dt = DateTime.fromMillisecondsSinceEpoch(epoch * 1000);
    return formatTime(dt);
  }

  /// "Now", "1 AM", "2 PM" for hourly forecast
  static String formatHourLabel(DateTime dt, DateTime now) {
    if (dt.hour == now.hour && dt.day == now.day) return NimbusStrings.now;
    return DateFormat('h a').format(dt);
  }

  /// "Today", "Tomorrow", "Mon" for daily forecast
  static String formatDayLabel(DateTime dt, DateTime now) {
    final diff = DateTime(dt.year, dt.month, dt.day)
        .difference(DateTime(now.year, now.month, now.day))
        .inDays;
    if (diff == 0) return NimbusStrings.today;
    if (diff == 1) return NimbusStrings.tomorrow;
    return formatDayShort(dt);
  }

  /// Wind direction degree → readable label
  static String windDegreeToLabel(int degree) {
    const dirs = [
      'N', 'NNE', 'NE', 'ENE', 'E', 'ESE', 'SE', 'SSE',
      'S', 'SSW', 'SW', 'WSW', 'W', 'WNW', 'NW', 'NNW',
    ];
    final idx = ((degree + 11.25) / 22.5).floor() % 16;
    return dirs[idx];
  }

  /// Moon phase icon via code-point free approach (returns a plain string)
  static String moonPhaseLabel(String phase) {
    const map = {
      'New Moon': 'New Moon',
      'Waxing Crescent': 'Waxing Crescent',
      'First Quarter': 'First Quarter',
      'Waxing Gibbous': 'Waxing Gibbous',
      'Full Moon': 'Full Moon',
      'Waning Gibbous': 'Waning Gibbous',
      'Last Quarter': 'Last Quarter',
      'Waning Crescent': 'Waning Crescent',
    };
    return map[phase] ?? phase;
  }

  /// Parse "06:30 AM" → DateTime today with that time
  static DateTime? parseTimeString(String timeStr, DateTime baseDate) {
    try {
      final fmt = DateFormat('hh:mm a');
      final parsed = fmt.parse(timeStr.trim().toUpperCase());
      return DateTime(
        baseDate.year,
        baseDate.month,
        baseDate.day,
        parsed.hour,
        parsed.minute,
      );
    } catch (_) {
      return null;
    }
  }

  /// Celsius → Fahrenheit
  static double toFahrenheit(double c) => c * 9 / 5 + 32;

  /// Convert based on flag
  static double convertTemp(double c, {required bool useCelsius}) =>
      useCelsius ? c : toFahrenheit(c);

  /// Unit symbol
  static String unitSymbol({required bool useCelsius}) =>
      useCelsius ? '°C' : '°F';
}
