# Nimbus — Project State (Stage 1)

## Overview
Nimbus is a premium Flutter weather app using WeatherAPI.com. This document is the canonical reference for Stage 2 and 3 development.

---

## Folder Map

```
d:/weather/
├── .env                          # API key (gitignored)
├── .env.example                  # Template with blank key
├── pubspec.yaml                  # Dependencies + font registration
├── PROJECT_STATE.md              # This file
│
├── assets/
│   └── fonts/                    # Manrope (7 weights) + Instrument Serif (2)
│
├── android/
│   └── app/src/main/
│       └── AndroidManifest.xml   # Internet + location permissions
│
└── lib/
    ├── main.dart                 # Entry: loads dotenv, sets up ProviderScope
    ├── app.dart                  # NimbusApp: MaterialApp.router + theme
    │
    ├── core/
    │   ├── config/
    │   │   └── env.dart          # Reads WEATHER_API_KEY from dotenv
    │   ├── errors/
    │   │   └── app_failure.dart  # Sealed error hierarchy
    │   ├── network/
    │   │   └── api_client.dart   # Dio client, error mapping
    │   ├── router/
    │   │   └── app_router.dart   # GoRouter: /, /onboarding, /home
    │   └── utils/
    │       └── formatters.dart   # Time, date, temp, UV helpers
    │
    ├── design/
    │   ├── tokens/
    │   │   ├── colors.dart       # NimbusColors — all color constants
    │   │   ├── typography.dart   # NimbusTypography — all TextStyles
    │   │   └── spacing.dart      # NimbusSpacing — 4/8/12/16/24/32/48/64
    │   ├── sky/
    │   │   └── sky_palette.dart  # Condition code → gradient palette map
    │   ├── theme/
    │   │   └── app_theme.dart    # Material 3 ThemeData (thin, delegates to tokens)
    │   └── widgets/
    │       ├── sky_background.dart  # AnimatedContainer gradient + scrim + offline banner
    │       └── shimmer.dart         # NimbusShimmer + HomeScreenSkeleton
    │
    ├── data/
    │   ├── models/
    │   │   └── weather_models.dart  # All models: WeatherResponse, Current, Forecast, etc.
    │   ├── repositories/
    │   │   └── weather_repository.dart  # getForecast(), searchLocations()
    │   └── services/
    │       └── location_service.dart    # Geolocator wrapper → "lat,lon" string
    │
    └── features/
        ├── home/
        │   ├── home_controller.dart   # HomeState + HomeController (Notifier)
        │   ├── home_screen.dart       # HomeScreen + _HomeContent + _CityHeader
        │   └── widgets/
        │       ├── error_view.dart         # HomeErrorView with retry
        │       ├── stats_row.dart          # Humidity | Wind | UV divided row
        │       └── temperature_display.dart # Count-up animated temperature
        └── onboarding/
            └── onboarding_screen.dart   # Location rationale + GPS + city search
```

---

## Providers

| Provider | Type | Purpose |
|---|---|---|
| `apiClientProvider` | `Provider<ApiClient>` | Singleton Dio client with base URL + API key |
| `weatherRepositoryProvider` | `Provider<WeatherRepository>` | Data access layer; throws AppFailure |
| `locationServiceProvider` | `Provider<LocationService>` | Wraps geolocator; returns "lat,lon" string |
| `appRouterProvider` | `Provider<GoRouter>` | App navigation with root redirect logic |
| `homeControllerProvider` | `NotifierProvider<HomeController, HomeState>` | Loads weather, persists city, handles errors |
| `connectivityProvider` | `StreamProvider<List<ConnectivityResult>>` | Live connectivity stream |
| `isOfflineProvider` | `Provider<bool>` | Derived: true when all connectivity results are `none` |

---

## Model Classes

All in `lib/data/models/weather_models.dart` — hand-written fromJson, no codegen.

| Class | Description |
|---|---|
| `WeatherResponse` | Root: location + current + forecast |
| `WeatherLocation` | City name, region, country, lat/lon, localtime |
| `CurrentWeather` | Temp, feels-like, condition, wind, humidity, UV, AQI |
| `WeatherCondition` | Text description, icon URL, condition code |
| `WeatherForecast` | List of ForecastDay |
| `ForecastDay` | Date, DayStats, Astronomy, List<HourlyWeather> |
| `DayStats` | Max/min/avg temp, wind, precip, condition, UV |
| `Astronomy` | Sunrise/sunset strings |
| `HourlyWeather` | Epoch, temp, condition, rain chance, wind |
| `AirQuality` | PM2.5, PM10, US EPA index |
| `SearchResult` | Location search hit with displayName + queryString helpers |

---

## Design Tokens

### Colors (`NimbusColors`)
- `white`, `white70`, `white50`, `white30`, `white10` — opacity layers
- `scrimLight`, `scrimMedium` — dark scrim for contrast
- `accent` — warm gold `#F5C87A`
- `error` — `#FF6B6B`
- `divider`, `shimmerBase/Highlight`, `offlineBg`

### Typography (`NimbusTypography`)
- `onboardingTitle` — Instrument Serif 52sp
- `cityName` — Instrument Serif 36sp (serif city only)
- `temperatureHero` — Manrope ExtraLight 120sp, ls -4
- `condition` — Manrope Light 18sp, white70
- `statLabel` — Manrope Medium 10sp, uppercase, ls 1.2, white50
- `statValue` — Manrope Light 20sp
- `timestamp` — Manrope Regular 12sp, white50

### Sky Palettes (`SkyPalettes` / `paletteFromCondition()`)
8+ palettes mapping to WeatherAPI condition codes + is_day boolean:
`clearDay`, `clearNight`, `partlyCloudyDay`, `partlyCloudyNight`, `cloudyDay`, `cloudyNight`, `rain`, `storm`, `snow`, `fog`, `sleet`

### Spacing (`NimbusSpacing`)
`xs=4, sm=8, md=12, base=16, lg=24, xl=32, xxl=48, xxxl=64`

---

## Shared Preferences Keys

| Key | Value | Purpose |
|---|---|---|
| `saved_city` | String (query) | Last loaded city/lat,lon — used for redirect decision |
| `unit_celsius` | bool | Celsius vs Fahrenheit — stored now, UI toggle in Stage 3 |

---

## Conventions

1. **No hardcoded colors** — always use `NimbusColors.*`
2. **No hardcoded TextStyles** — always use `NimbusTypography.*`
3. **No magic spacing numbers** — always use `NimbusSpacing.*`
4. **Every repository error** must be typed `AppFailure` or subclass
5. **No code generation** — models are hand-written fromJson
6. **No google_fonts package** — fonts bundled in `assets/fonts/`
7. **Sky drives the UI** — condition code + is_day determines background
8. **Animations**: flutter_animate with 40ms stagger, easeOutCubic, 500ms
9. **Haptics**: `HapticFeedback.selectionClick()` on all interactive taps
10. **Unit** stored as Celsius (`useCelsius: true`) — toggle UI in Stage 3

---

## API Contract (WeatherAPI.com)

- **Base URL**: `https://api.weatherapi.com/v1`
- **Key**: loaded from `.env` → `WEATHER_API_KEY`
- **Forecast**: `GET /forecast.json?q={q}&days=3&aqi=yes&alerts=no`
- **Search**: `GET /search.json?q={query}` → returns JSON array

---

## Previous gaps now addressed

- [x] Hourly 24-hour strip with bezier temperature curve.
- [x] Available-day forecast rows with proportional range bars.
- [x] Search, city switching, saved-city persistence and undo deletion.
- [x] Details metrics, AQI, sunrise/sunset, moon phase and attribution.
- [x] Unit/theme/reduced-motion settings and cache clearing.
- [x] Privacy, terms and about screens with draft compliance copy.

Remaining platform-specific release preparation is listed at the end of this
document. No analytics or tracking SDK is planned.

---

## Stage 1 Definition of Done

- [x] All source files created
- [x] pubspec.yaml with all required packages
- [x] Fonts bundled locally (Manrope + Instrument Serif)
- [x] .env loaded at startup
- [x] Onboarding screen with location rationale
- [x] GPS + city search flows
- [x] Home screen: city, condition, temperature, feels-like, H/L, timestamp, stats row
- [x] Sky gradient background with condition-code mapping
- [x] Animated temperature count-up
- [x] Staggered entrance animations (flutter_animate)
- [x] Pull-to-refresh
- [x] Skeleton loading state
- [x] Error state with retry
- [x] Offline banner (connectivity_plus)
- [x] Shared preferences persistence
- [x] AppFailure hierarchy
- [x] Android location permissions in manifest
- [ ] flutter analyze → 0 errors (run after pub get)
- [ ] flutter run → app boots on device

---

## Stage 2 / Stage 3 continuation

### Added files and providers

- `lib/core/settings/settings_controller.dart` — persisted units, theme,
  reduced-motion and location-on-launch settings via `settingsProvider`.
- `lib/features/settings/settings_screen.dart` — settings, cache clearing and
  links to legal/about screens.
- `lib/features/legal/legal_screen.dart` — in-app privacy, terms and about
  copy.
- `lib/design/widgets/sky_background.dart` now includes a RepaintBoundary
  custom-painted weather layer container.
- `lib/design/widgets/weather_motion_painter.dart` adds animated weather
  effects (clear day/night, clouds, rain/storm, snow, fog) with reduce-motion
  support.
- `lib/data/services/cache_service.dart` exposes `clearWeatherCache()`.
- `lib/design/widgets/press_scale.dart` adds 48px press-scale feedback with
  selection haptics for primary tappable controls.

### Routes

`/`, `/onboarding`, `/home`, `/search`, `/cities`, `/details`, `/settings`,
`/privacy`, `/terms`, and `/about` use the existing custom fade/shared-axis
transitions.

### Cache keys

Weather payloads use `weather_cache_<normalized-query>` and timestamps use
`weather_ts_<normalized-query>`. Saved cities remain in `saved_cities_v2`.
Settings use the `nimbus_settings_` prefix. `.env` remains local-only and is
ignored by git.
WeatherAPI is integrated through `Env.weatherApiKey` and Dio; the key is not
hardcoded in Dart. Forecast requests include `q`, `days=3`, `aqi=yes`, and
`alerts=no`.

### Known gaps / TODO for final release

- Flutter SDK is not installed on the current machine, so `flutter analyze`,
  device-flow testing, browser testing, profile tracing and release builds
  must be run on a Flutter-enabled workstation. This checkout also has no
  generated `web/` platform target yet; run `flutter create .` before
  `flutter run -d chrome`.
- Android/iOS platform folders are incomplete in this checkout; regenerate
  platform scaffolding with `flutter create .`, then set package id
  `com.nimbus.weather`, native splash, adaptive icon and signing configuration.
- Replace `support@example.com`, publish the legal copy at a public URL, and
  create Play Store screenshots/declarations.
- Add a real URL launcher only if external attribution links are required;
  no package was added here to preserve the dependency set.
