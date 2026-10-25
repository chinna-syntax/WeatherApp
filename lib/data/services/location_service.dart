import 'package:geolocator/geolocator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/errors/app_failure.dart';

final locationServiceProvider = Provider<LocationService>(
  (_) => LocationService(),
);

class LocationService {
  /// Returns "lat,lon" string ready to pass to WeatherAPI.
  /// Throws [LocationPermissionFailure], [LocationServiceDisabledFailure],
  /// or [UnknownFailure] on unexpected errors.
  Future<String> getCurrentLocationQuery() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationServiceDisabledFailure();
    }

    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw const LocationPermissionFailure('Location permission denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw const LocationPermissionFailure(
        'Location permission permanently denied. Please enable it in Settings.',
      );
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 10),
        ),
      );
      return '${position.latitude},${position.longitude}';
    } catch (e) {
      throw UnknownFailure('Could not get location: $e');
    }
  }

  /// Check permission status without requesting.
  Future<LocationPermission> checkPermission() =>
      Geolocator.checkPermission();

  /// Open system settings for location.
  Future<bool> openSettings() => Geolocator.openLocationSettings();
}
