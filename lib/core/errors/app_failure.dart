import '../strings.dart';

/// Typed error domain for the Nimbus app.
/// Every repository method either returns a model or throws [AppFailure].
abstract class AppFailure implements Exception {
  const AppFailure(this.message);
  final String message;

  @override
  String toString() => 'AppFailure: $message';
}

class NetworkFailure extends AppFailure {
  const NetworkFailure([super.message = NimbusStrings.errorNetwork]);
}

class TimeoutFailure extends AppFailure {
  const TimeoutFailure([super.message = NimbusStrings.errorTimeout]);
}

class InvalidLocationFailure extends AppFailure {
  const InvalidLocationFailure(
      [super.message = NimbusStrings.errorInvalidLocation]);
}

class ApiKeyFailure extends AppFailure {
  const ApiKeyFailure([super.message = NimbusStrings.errorApiKey]);
}

class RateLimitFailure extends AppFailure {
  const RateLimitFailure([super.message = NimbusStrings.errorRateLimit]);
}

class UnknownFailure extends AppFailure {
  const UnknownFailure([super.message = NimbusStrings.errorUnknown]);
}

class LocationPermissionFailure extends AppFailure {
  const LocationPermissionFailure(
      [super.message = NimbusStrings.errorPermissionDenied]);
}

class LocationServiceDisabledFailure extends AppFailure {
  const LocationServiceDisabledFailure(
      [super.message = NimbusStrings.errorLocationService]);
}
