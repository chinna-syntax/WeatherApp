import 'package:flutter/material.dart';
import '../tokens/colors.dart';

/// Nimbus Material 3 theme — most visual decisions are in
/// sky_palette.dart and direct widget styling, so this is intentionally thin.
class AppTheme {
  AppTheme._();

  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: 'Manrope',
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF4FA3E0),
        brightness: brightness,
      ),
      scaffoldBackgroundColor: Colors.transparent,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: NimbusColors.white,
      ),
      // Disable ink splashes — we handle our own feedback
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
    );
  }
}
