import 'package:flutter/material.dart';
import 'colors.dart';

/// Nimbus typography system.
/// Two typefaces only: Manrope (everything) + Instrument Serif (city name).
class NimbusTypography {
  NimbusTypography._();

  // --- City name (Instrument Serif) ---
  static const cityName = TextStyle(
    fontFamily: 'InstrumentSerif',
    fontSize: 36,
    fontWeight: FontWeight.w400,
    color: NimbusColors.white,
    height: 1.1,
    letterSpacing: 0,
  );

  // --- Giant temperature ---
  static const temperatureHero = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 120,
    fontWeight: FontWeight.w200,
    color: NimbusColors.white,
    height: 1.0,
    letterSpacing: -4,
  );

  // --- Condition description ---
  static const condition = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 18,
    fontWeight: FontWeight.w300,
    color: NimbusColors.white70,
    height: 1.3,
    letterSpacing: 0.2,
  );

  // --- Feels-like / high-low ---
  static const feelsLike = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 15,
    fontWeight: FontWeight.w300,
    color: NimbusColors.white70,
    letterSpacing: 0.1,
  );

  // --- Stat value (humidity, wind, UV number) ---
  static const statValue = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 20,
    fontWeight: FontWeight.w300,
    color: NimbusColors.white,
    letterSpacing: -0.5,
  );

  // --- Stat label (HUMIDITY, WIND, UV) ---
  static const statLabel = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: NimbusColors.white50,
    letterSpacing: 1.2,
    height: 1.4,
  );

  // --- Updated timestamp ---
  static const timestamp = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: NimbusColors.white50,
    letterSpacing: 0.2,
  );

  // --- Body / general ---
  static const body = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: NimbusColors.white,
    height: 1.5,
  );

  // --- Caption ---
  static const caption = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: NimbusColors.white70,
    height: 1.5,
  );

  // --- Onboarding heading ---
  static const onboardingTitle = TextStyle(
    fontFamily: 'InstrumentSerif',
    fontSize: 52,
    fontWeight: FontWeight.w400,
    color: NimbusColors.white,
    height: 1.05,
    letterSpacing: -0.5,
  );

  // --- Onboarding subtitle ---
  static const onboardingSubtitle = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 17,
    fontWeight: FontWeight.w300,
    color: NimbusColors.white70,
    height: 1.6,
    letterSpacing: 0.1,
  );

  // --- Button label ---
  static const buttonLabel = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
  );

  // --- Error message ---
  static const errorText = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 16,
    fontWeight: FontWeight.w300,
    color: NimbusColors.white70,
    height: 1.5,
  );

  // --- Hourly time label ---
  static const hourlyTime = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: NimbusColors.white70,
    letterSpacing: 0.3,
  );

  // --- Hourly temperature ---
  static const hourlyTemp = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 14,
    fontWeight: FontWeight.w300,
    color: NimbusColors.white,
    letterSpacing: -0.3,
  );

  // --- Daily day name ---
  static const dailyDay = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: NimbusColors.white,
    letterSpacing: 0.1,
  );

  // --- Daily temp range ---
  static const dailyTemp = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 14,
    fontWeight: FontWeight.w300,
    color: NimbusColors.white70,
    letterSpacing: -0.2,
  );

  // --- Section heading (HOURLY, DAILY, DETAILS) ---
  static const sectionHeading = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: NimbusColors.white50,
    letterSpacing: 1.8,
    height: 1.4,
  );

  // --- Detail value ---
  static const detailValue = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 22,
    fontWeight: FontWeight.w200,
    color: NimbusColors.white,
    letterSpacing: -0.5,
  );

  // --- Detail explanation ---
  static const detailExplanation = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: NimbusColors.white50,
    height: 1.5,
    letterSpacing: 0.1,
  );

  // --- Search result primary ---
  static const searchResultPrimary = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: NimbusColors.white,
    letterSpacing: 0.1,
  );

  // --- Search result secondary ---
  static const searchResultSecondary = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: NimbusColors.white50,
    letterSpacing: 0.1,
  );

  // --- City card name ---
  static const cityCardName = TextStyle(
    fontFamily: 'InstrumentSerif',
    fontSize: 20,
    fontWeight: FontWeight.w400,
    color: NimbusColors.white,
    letterSpacing: 0,
  );

  // --- City card temperature ---
  static const cityCardTemp = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 28,
    fontWeight: FontWeight.w200,
    color: NimbusColors.white,
    letterSpacing: -1,
  );

  // --- Rain chance percentage ---
  static const rainChance = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: NimbusColors.white50,
    letterSpacing: 0.1,
  );
}
