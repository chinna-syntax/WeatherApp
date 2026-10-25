/// WeatherAPI forecast response — hand-written fromJson, null-safe.
/// Parse defensively: every field has a fallback so missing keys never crash.
library;

class WeatherResponse {
  const WeatherResponse({
    required this.location,
    required this.current,
    required this.forecast,
  });

  final WeatherLocation location;
  final CurrentWeather current;
  final WeatherForecast forecast;

  factory WeatherResponse.fromJson(Map<String, dynamic> json) {
    return WeatherResponse(
      location: WeatherLocation.fromJson(
        (json['location'] as Map<String, dynamic>?) ?? {},
      ),
      current: CurrentWeather.fromJson(
        (json['current'] as Map<String, dynamic>?) ?? {},
      ),
      forecast: WeatherForecast.fromJson(
        (json['forecast'] as Map<String, dynamic>?) ?? {},
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class WeatherLocation {
  const WeatherLocation({
    required this.name,
    required this.region,
    required this.country,
    required this.lat,
    required this.lon,
    required this.localtime,
    required this.localtimeEpoch,
  });

  final String name;
  final String region;
  final String country;
  final double lat;
  final double lon;
  final String localtime;
  final int localtimeEpoch;

  factory WeatherLocation.fromJson(Map<String, dynamic> json) {
    return WeatherLocation(
      name: (json['name'] as String?) ?? 'Unknown',
      region: (json['region'] as String?) ?? '',
      country: (json['country'] as String?) ?? '',
      lat: _toDouble(json['lat']),
      lon: _toDouble(json['lon']),
      localtime: (json['localtime'] as String?) ?? '',
      localtimeEpoch: (json['localtime_epoch'] as int?) ?? 0,
    );
  }
}

// ---------------------------------------------------------------------------

class CurrentWeather {
  const CurrentWeather({
    required this.tempC,
    required this.feelsLikeC,
    required this.isDay,
    required this.condition,
    required this.windKph,
    required this.windDir,
    required this.windDegree,
    required this.humidity,
    required this.cloud,
    required this.visKm,
    required this.uv,
    required this.pressureMb,
    required this.dewpointC,
    required this.precipMm,
    required this.lastUpdated,
    required this.airQuality,
  });

  final double tempC;
  final double feelsLikeC;
  final bool isDay;
  final WeatherCondition condition;
  final double windKph;
  final String windDir;
  final int windDegree;
  final int humidity;
  final int cloud;
  final double visKm;
  final double uv;
  final double pressureMb;
  final double dewpointC;
  final double precipMm;
  final String lastUpdated;
  final AirQuality? airQuality;

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
      tempC: _toDouble(json['temp_c']),
      feelsLikeC: _toDouble(json['feelslike_c']),
      isDay: (json['is_day'] as int?) == 1,
      condition: WeatherCondition.fromJson(
        (json['condition'] as Map<String, dynamic>?) ?? {},
      ),
      windKph: _toDouble(json['wind_kph']),
      windDir: (json['wind_dir'] as String?) ?? '',
      windDegree: (json['wind_degree'] as int?) ?? 0,
      humidity: (json['humidity'] as int?) ?? 0,
      cloud: (json['cloud'] as int?) ?? 0,
      visKm: _toDouble(json['vis_km']),
      uv: _toDouble(json['uv']),
      pressureMb: _toDouble(json['pressure_mb']),
      dewpointC: _toDouble(json['dewpoint_c']),
      precipMm: _toDouble(json['precip_mm']),
      lastUpdated: (json['last_updated'] as String?) ?? '',
      airQuality: json['air_quality'] != null
          ? AirQuality.fromJson(json['air_quality'] as Map<String, dynamic>)
          : null,
    );
  }
}

// ---------------------------------------------------------------------------

class WeatherCondition {
  const WeatherCondition({
    required this.text,
    required this.icon,
    required this.code,
  });

  final String text;
  final String icon;
  final int code;

  factory WeatherCondition.fromJson(Map<String, dynamic> json) {
    return WeatherCondition(
      text: (json['text'] as String?) ?? '',
      icon: (json['icon'] as String?) ?? '',
      code: (json['code'] as int?) ?? 1000,
    );
  }
}

// ---------------------------------------------------------------------------

class WeatherForecast {
  const WeatherForecast({required this.forecastDays});

  final List<ForecastDay> forecastDays;

  factory WeatherForecast.fromJson(Map<String, dynamic> json) {
    final days = json['forecastday'] as List<dynamic>?;
    return WeatherForecast(
      forecastDays: days
              ?.map(
                (d) => ForecastDay.fromJson(d as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }
}

// ---------------------------------------------------------------------------

class ForecastDay {
  const ForecastDay({
    required this.date,
    required this.dateEpoch,
    required this.day,
    required this.astro,
    required this.hour,
  });

  final String date;
  final int dateEpoch;
  final DayStats day;
  final Astronomy astro;
  final List<HourlyWeather> hour;

  factory ForecastDay.fromJson(Map<String, dynamic> json) {
    final hours = json['hour'] as List<dynamic>?;
    return ForecastDay(
      date: (json['date'] as String?) ?? '',
      dateEpoch: (json['date_epoch'] as int?) ?? 0,
      day: DayStats.fromJson((json['day'] as Map<String, dynamic>?) ?? {}),
      astro:
          Astronomy.fromJson((json['astro'] as Map<String, dynamic>?) ?? {}),
      hour: hours
              ?.map(
                (h) => HourlyWeather.fromJson(h as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }
}

// ---------------------------------------------------------------------------

class DayStats {
  const DayStats({
    required this.maxTempC,
    required this.minTempC,
    required this.avgTempC,
    required this.maxWindKph,
    required this.totalPrecipMm,
    required this.avgHumidity,
    required this.condition,
    required this.uv,
    required this.dailyChanceOfRain,
  });

  final double maxTempC;
  final double minTempC;
  final double avgTempC;
  final double maxWindKph;
  final double totalPrecipMm;
  final double avgHumidity;
  final WeatherCondition condition;
  final double uv;
  final int dailyChanceOfRain;

  factory DayStats.fromJson(Map<String, dynamic> json) {
    return DayStats(
      maxTempC: _toDouble(json['maxtemp_c']),
      minTempC: _toDouble(json['mintemp_c']),
      avgTempC: _toDouble(json['avgtemp_c']),
      maxWindKph: _toDouble(json['maxwind_kph']),
      totalPrecipMm: _toDouble(json['totalprecip_mm']),
      avgHumidity: _toDouble(json['avghumidity']),
      condition: WeatherCondition.fromJson(
        (json['condition'] as Map<String, dynamic>?) ?? {},
      ),
      uv: _toDouble(json['uv']),
      dailyChanceOfRain: (json['daily_chance_of_rain'] as int?) ?? 0,
    );
  }
}

// ---------------------------------------------------------------------------

class Astronomy {
  const Astronomy({
    required this.sunrise,
    required this.sunset,
    required this.moonPhase,
    required this.moonIllumination,
  });

  final String sunrise;
  final String sunset;
  final String moonPhase;
  final int moonIllumination;

  factory Astronomy.fromJson(Map<String, dynamic> json) {
    return Astronomy(
      sunrise: (json['sunrise'] as String?) ?? '--:--',
      sunset: (json['sunset'] as String?) ?? '--:--',
      moonPhase: (json['moon_phase'] as String?) ?? '',
      moonIllumination:
          int.tryParse((json['moon_illumination'] as String?) ?? '0') ?? 0,
    );
  }
}

// ---------------------------------------------------------------------------

class HourlyWeather {
  const HourlyWeather({
    required this.timeEpoch,
    required this.tempC,
    required this.isDay,
    required this.condition,
    required this.chanceOfRain,
    required this.windKph,
  });

  final int timeEpoch;
  final double tempC;
  final bool isDay;
  final WeatherCondition condition;
  final int chanceOfRain;
  final double windKph;

  factory HourlyWeather.fromJson(Map<String, dynamic> json) {
    return HourlyWeather(
      timeEpoch: (json['time_epoch'] as int?) ?? 0,
      tempC: _toDouble(json['temp_c']),
      isDay: (json['is_day'] as int?) == 1,
      condition: WeatherCondition.fromJson(
        (json['condition'] as Map<String, dynamic>?) ?? {},
      ),
      chanceOfRain: (json['chance_of_rain'] as int?) ?? 0,
      windKph: _toDouble(json['wind_kph']),
    );
  }
}

// ---------------------------------------------------------------------------

class AirQuality {
  const AirQuality({
    required this.pm25,
    required this.pm10,
    required this.usEpaIndex,
  });

  final double pm25;
  final double pm10;
  final int usEpaIndex;

  factory AirQuality.fromJson(Map<String, dynamic> json) {
    return AirQuality(
      pm25: _toDouble(json['pm2_5']),
      pm10: _toDouble(json['pm10']),
      usEpaIndex: (json['us-epa-index'] as int?) ?? 1,
    );
  }
}

// ---------------------------------------------------------------------------

class SearchResult {
  const SearchResult({
    required this.id,
    required this.name,
    required this.region,
    required this.country,
    required this.lat,
    required this.lon,
    required this.url,
  });

  final int id;
  final String name;
  final String region;
  final String country;
  final double lat;
  final double lon;
  final String url;

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      id: (json['id'] as int?) ?? 0,
      name: (json['name'] as String?) ?? '',
      region: (json['region'] as String?) ?? '',
      country: (json['country'] as String?) ?? '',
      lat: _toDouble(json['lat']),
      lon: _toDouble(json['lon']),
      url: (json['url'] as String?) ?? '',
    );
  }

  String get displayName =>
      region.isNotEmpty ? '$name, $region' : '$name, $country';

  String get queryString => '$lat,$lon';
}

// ---------------------------------------------------------------------------

/// Saved city entry stored in shared_preferences.
class SavedCity {
  const SavedCity({
    required this.query,
    required this.name,
    required this.country,
    this.isGps = false,
  });

  final String query;
  final String name;
  final String country;
  final bool isGps;

  Map<String, dynamic> toJson() => {
        'query': query,
        'name': name,
        'country': country,
        'isGps': isGps,
      };

  factory SavedCity.fromJson(Map<String, dynamic> json) {
    return SavedCity(
      query: (json['query'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      country: (json['country'] as String?) ?? '',
      isGps: (json['isGps'] as bool?) ?? false,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavedCity &&
          runtimeType == other.runtimeType &&
          query == other.query;

  @override
  int get hashCode => query.hashCode;
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

double _toDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}
