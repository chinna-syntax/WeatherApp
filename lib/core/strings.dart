/// All user-visible strings in one place for later localization.
/// Never write string literals directly in widget files.
class NimbusStrings {
  NimbusStrings._();

  // --- Onboarding ---
  static const appName = 'Nimbus';
  static const onboardingTagline = 'Weather, thoughtfully presented.';
  static const onboardingLocationRationale =
      'To show you local conditions, Nimbus uses your device\'s GPS. '
      'Your location is sent directly to the weather service and '
      'is never stored on our servers.';
  static const useMyLocation = 'Use my location';
  static const searchCityInstead = 'Search a city instead';
  static const useLocationInstead = 'Use my location instead';

  // --- Home ---
  static const updatedAt = 'Updated';
  static const feelsLike = 'Feels like';
  static const high = 'H';
  static const low = 'L';
  static const pullToRefresh = 'Pull to refresh';
  static const today = 'Today';
  static const tomorrow = 'Tomorrow';
  static const now = 'Now';

  // --- Stats ---
  static const humidity = 'HUMIDITY';
  static const wind = 'WIND';
  static const uvIndex = 'UV INDEX';
  static const pressure = 'PRESSURE';
  static const visibility = 'VISIBILITY';
  static const dewPoint = 'DEW POINT';
  static const precipitation = 'PRECIP';
  static const airQuality = 'AIR QUALITY';
  static const sunrise = 'SUNRISE';
  static const sunset = 'SUNSET';
  static const moonPhase = 'MOON PHASE';
  static const settings = 'Settings';
  static const temperatureUnits = 'Temperature';
  static const windUnits = 'Wind speed';
  static const timeFormat = 'Time format';
  static const celsius = 'Celsius (°C)';
  static const fahrenheit = 'Fahrenheit (°F)';
  static const kilometresPerHour = 'Kilometres per hour';
  static const milesPerHour = 'Miles per hour';
  static const time12 = '12-hour';
  static const time24 = '24-hour';
  static const theme = 'Theme';
  static const themeAuto = 'Auto by sky';
  static const themeDark = 'Always dark';
  static const themeLight = 'Always light';
  static const reduceMotion = 'Reduce motion';
  static const locationOnLaunch = 'Use my location on launch';
  static const clearCache = 'Clear cached weather';
  static const cacheCleared = 'Cached weather cleared';
  static const privacyPolicy = 'Privacy Policy';
  static const terms = 'Terms & Conditions';
  static const about = 'About Nimbus';
  static const aboutParagraphs = <String>[
    'Nimbus is a calm, privacy-first weather companion.',
    'Version 1.0.0+1',
    'Weather data is provided by WeatherAPI.com. No accounts, ads, tracking, or analytics are used.',
    'Powered by WeatherAPI.com.',
    'Support: support@example.com (replace this address before release).',
  ];
  static const back = 'Back';
  static const poweredBy = 'Powered by WeatherAPI.com';
  static const weatherApiUrl = 'https://www.weatherapi.com/';
  static const linkCopied = 'Link copied';
  static const privacyParagraphs = <String>[
    'Nimbus does not require an account and does not show ads. We store saved city names and app preferences locally on your device.',
    'If you grant permission, approximate or precise device location is used only to request local weather. It is sent to WeatherAPI.com with the weather request and is not stored by Nimbus.',
    'Weather requests are sent to WeatherAPI.com. We do not sell data, use tracking, or include analytics or advertising SDKs.',
    'You can revoke location access at any time in your device Settings. For questions, contact support@example.com (replace this address before release).',
  ];
  static const termsParagraphs = <String>[
    'Nimbus provides weather information for general informational purposes. Forecasts can change and should not replace official warnings or professional advice.',
    'You are responsible for checking local conditions before travel or outdoor activity. Nimbus is not liable for decisions made using forecast data.',
    'The app uses WeatherAPI.com and its service terms. You may stop using Nimbus and remove its local data at any time.',
    'Questions about these draft terms can be sent to support@example.com (replace this address before release).',
  ];

  // --- Search ---
  static const searchTitle = 'Search';
  static const searchHint = 'City name...';
  static const searchEmpty = 'Search for a city to get started.';
  static const searchNoResults = 'No results found.';
  static const searchLoading = 'Searching...';

  // --- Cities ---
  static const citiesTitle = 'My Cities';
  static const myLocation = 'My Location';
  static const addCity = 'Add city';
  static const noCities = 'No saved cities yet.\nSearch and add cities to track.';
  static const cityDeleted = 'City removed';
  static const undo = 'Undo';

  // --- Details ---
  static const detailsTitle = 'Details';
  static const uvLow = 'Low — safe to go outside.';
  static const uvModerate = 'Moderate — wear sunscreen.';
  static const uvHigh = 'High — limit sun exposure.';
  static const uvVeryHigh = 'Very High — extra protection needed.';
  static const uvExtreme = 'Extreme — avoid outdoor activity.';

  static const humidityLow = 'Low — air feels dry.';
  static const humidityComfort = 'Comfortable humidity.';
  static const humidityHigh = 'High — air feels humid.';

  static const visibilityGood = 'Good visibility.';
  static const visibilityModerate = 'Moderate visibility.';
  static const visibilityPoor = 'Poor visibility — drive carefully.';

  // --- Air quality labels ---
  static const aqiGood = 'Good';
  static const aqiModerate = 'Moderate';
  static const aqiSensitive = 'Unhealthy for Sensitive Groups';
  static const aqiUnhealthy = 'Unhealthy';
  static const aqiVeryUnhealthy = 'Very Unhealthy';
  static const aqiHazardous = 'Hazardous';

  // --- Errors ---
  static const errorRetry = 'Try again';
  static const errorOffline = 'No internet connection';
  static const errorOfflineWithAge = 'Offline · updated';
  static const errorNetwork = 'No internet connection.';
  static const errorTimeout = 'The request timed out.';
  static const errorInvalidLocation = 'Location not found. Try a different name.';
  static const errorApiKey = 'Invalid API key.';
  static const errorUnknown = 'Something went wrong.';
  static const errorRateLimit =
      'Too many requests right now. Please wait a few minutes.';
  static const errorPermissionDenied = 'Location permission denied.';
  static const errorPermissionForever =
      'Location access is permanently blocked. Enable it in Settings.';
  static const errorLocationService = 'Location services are disabled.';
  static const openSettings = 'Open Settings';

  // --- Accessibility ---
  static String tempSemantic(String temp, String unit, String feelsLike) =>
      'Temperature $temp $unit, feels like $feelsLike';
  static String humiditySemantic(int pct) => 'Humidity $pct percent';
  static String windSemantic(double kph, String dir) =>
      'Wind ${kph.round()} kilometres per hour, direction $dir';
  static String uvSemantic(double uv) => 'UV index ${uv.round()}';
  static String aqiSemantic(String label) => 'Air quality: $label';
  static String hourTemp(String time, String temp) =>
      'At $time, temperature $temp';
  static String dailyForecast(String day, String hi, String lo) =>
      '$day, high $hi, low $lo';
}
