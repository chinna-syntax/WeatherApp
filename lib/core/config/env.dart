import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  Env._();

  static String get weatherApiKey {
    final key = dotenv.env['WEATHER_API_KEY'];
    if (key == null || key.isEmpty) {
      throw StateError(
        'WEATHER_API_KEY is not set. Please add it to your .env file.',
      );
    }
    return key;
  }

  static const String baseUrl = 'https://api.weatherapi.com/v1';
}
