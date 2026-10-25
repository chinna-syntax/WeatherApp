#!/usr/bin/env bash
set -euo pipefail

export PATH="$PWD/flutter/bin:$PATH"
export CI=true

if [ -z "${WEATHER_API_KEY:-}" ]; then
  echo "WEATHER_API_KEY is not configured in Vercel."
  exit 1
fi

printf 'WEATHER_API_KEY=%s\n' "$WEATHER_API_KEY" > .env

flutter create . --platforms web
flutter pub get
flutter analyze
flutter build web --release
