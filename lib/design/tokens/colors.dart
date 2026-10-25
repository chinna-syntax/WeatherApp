import 'package:flutter/material.dart';

/// Nimbus color tokens.
/// All UI colors derive from here — never use raw Color() inline.
class NimbusColors {
  NimbusColors._();

  // --- Base whites / neutrals ---
  static const white = Color(0xFFFFFFFF);
  static const white70 = Color(0xB3FFFFFF);
  static const white50 = Color(0x80FFFFFF);
  static const white30 = Color(0x4DFFFFFF);
  static const white10 = Color(0x1AFFFFFF);

  // --- Scrim ---
  static const scrimLight = Color(0x22000000);
  static const scrimMedium = Color(0x44000000);

  // --- Accent (soft warm gold — for interactive hits only) ---
  static const accent = Color(0xFFF5C87A);
  static const accentDim = Color(0x33F5C87A);

  // --- Error / warning ---
  static const error = Color(0xFFFF6B6B);
  static const warning = Color(0xFFFFB74D);

  // --- Stat divider ---
  static const divider = Color(0x33FFFFFF);

  // --- Skeleton shimmer ---
  static const shimmerBase = Color(0x33FFFFFF);
  static const shimmerHighlight = Color(0x66FFFFFF);

  // --- Offline banner ---
  static const offlineBg = Color(0xCC1B1F2B);
}
