# Nimbus

Nimbus is a calm Flutter weather app using WeatherAPI.com, Riverpod, Dio and
shared preferences. It has no accounts, analytics, ads or tracking SDKs.

## Setup

1. Install Flutter and run `flutter pub get`.
2. Copy `.env.example` to `.env`.
3. Put a current WeatherAPI key in `.env` as `WEATHER_API_KEY=...`.
4. Run `flutter analyze`, then `flutter run`.

`.env` is ignored by git. Never commit the key. Release builds include the
Flutter asset through `pubspec.yaml`; replace the key if it has been exposed.
WeatherAPI requests require a query, for example
`/v1/current.json?key=YOUR_KEY&q=London`; a URL containing only `key` is
incomplete. Nimbus uses `/forecast.json` with the same configured key so the
home screen can render hourly and daily data.

## Build

```powershell
flutter build apk --release
flutter build appbundle --release
```

Before publishing, configure a private Android upload keystore and signing
properties outside source control. Do not commit the keystore or passwords.
Use `keytool -genkeypair`, keep the resulting `.jks` outside this repository,
and wire its values through a local `key.properties` excluded by `.gitignore`.

## Release checklist

- Replace `support@example.com` in the in-app legal copy.
- Set the final Android application id in the generated Android project.
- Publish the privacy policy at a public URL.
- Create Play Console developer account, store listing, screenshots and
  content declarations.
- Regenerate and restrict the WeatherAPI key before release.
