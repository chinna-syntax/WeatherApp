import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../tokens/colors.dart';

enum WeatherEffect { auto, clear, clearNight, cloudy, rain, storm, snow, fog }

WeatherEffect weatherEffectForCondition(int? code, {required bool isDay}) {
  if (code == null || code == 1000) {
    return isDay ? WeatherEffect.clear : WeatherEffect.clearNight;
  }
  if (code == 1003 || code == 1006 || code == 1009) return WeatherEffect.cloudy;
  if (code == 1087 || (code >= 1273 && code <= 1282)) return WeatherEffect.storm;
  if (code == 1030 || code == 1135 || code == 1147) return WeatherEffect.fog;
  if (code >= 1066 && code <= 1264 && code.isEven) return WeatherEffect.snow;
  return WeatherEffect.rain;
}

class WeatherMotionPainter extends CustomPainter {
  const WeatherMotionPainter({
    required this.effect,
    required this.progress,
    required this.reduceMotion,
  });

  final WeatherEffect effect;
  final double progress;
  final bool reduceMotion;

  @override
  void paint(Canvas canvas, Size size) {
    final resolved = effect == WeatherEffect.auto ? WeatherEffect.clear : effect;
    switch (resolved) {
      case WeatherEffect.clear:
        _paintSun(canvas, size);
        break;
      case WeatherEffect.clearNight:
        _paintNight(canvas, size);
        break;
      case WeatherEffect.cloudy:
        _paintClouds(canvas, size);
        break;
      case WeatherEffect.rain:
      case WeatherEffect.storm:
        _paintRain(canvas, size, resolved == WeatherEffect.storm);
        break;
      case WeatherEffect.snow:
        _paintSnow(canvas, size);
        break;
      case WeatherEffect.fog:
        _paintFog(canvas, size);
        break;
      case WeatherEffect.auto:
        break;
    }
  }

  void _paintSun(Canvas canvas, Size size) {
    final pulse =
        reduceMotion ? 0.12 : (math.sin(progress * math.pi * 2) + 1) * 0.06;
    final center = Offset(size.width * 0.78, size.height * 0.18);
    canvas.drawCircle(
      center,
      size.width * (0.16 + pulse),
      Paint()..color = Colors.white.withAlpha(18),
    );
    canvas.drawCircle(
      center,
      size.width * 0.07,
      Paint()..color = NimbusColors.accent.withAlpha(100),
    );
  }

  void _paintNight(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withAlpha(140);
    for (var i = 0; i < 28; i++) {
      final twinkle =
          reduceMotion ? 1.0 : 0.5 + 0.5 * math.sin(progress * math.pi * 4 + i);
      final x = (i * 53.0) % size.width;
      final y = (i * 31.0) % (size.height * 0.45);
      canvas.drawCircle(
        Offset(x, y + 18),
        0.8 + (i % 3) * 0.5 * twinkle,
        paint,
      );
    }
    if (!reduceMotion && progress > 0.73 && progress < 0.76) {
      final start = Offset(size.width * 0.2, size.height * 0.2);
      canvas.drawLine(
        start,
        Offset(start.dx + 70, start.dy + 24),
        Paint()
          ..color = Colors.white.withAlpha(170)
          ..strokeWidth = 1.4,
      );
    }
    canvas.drawCircle(
      Offset(size.width * 0.82, size.height * 0.16),
      size.width * 0.05,
      Paint()..color = Colors.white.withAlpha(42),
    );
  }

  void _paintClouds(Canvas canvas, Size size) {
    final drift = reduceMotion ? 0.0 : progress * size.width;
    final paint = Paint()..color = Colors.white.withAlpha(22);
    for (var i = 0; i < 3; i++) {
      final x = (size.width * (i + 1) / 3 + drift * (i + 1) / 8) %
              (size.width + 180) -
          90;
      final y = size.height * (0.16 + i * 0.12);
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, y), width: 190, height: 48),
        paint,
      );
    }
  }

  void _paintRain(Canvas canvas, Size size, bool storm) {
    final paint = Paint()..color = Colors.white.withAlpha(35);
    for (var i = 0; i < 34; i++) {
      final x = ((i * 47 + progress * size.width * 1.8) % (size.width + 30)) - 15;
      final y = (i * 71.0 + progress * size.height * 1.8) % size.height;
      canvas.drawLine(Offset(x, y), Offset(x - 5, y + 18), paint);
    }
    if (storm && !reduceMotion && progress > 0.47 && progress < 0.49) {
      canvas.drawRect(
        Offset.zero & size,
        Paint()..color = Colors.white.withAlpha(26),
      );
    }
  }

  void _paintSnow(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withAlpha(100);
    for (var i = 0; i < 24; i++) {
      final x = (i * 61.0 + math.sin(progress * math.pi * 2 + i) * 18) % size.width;
      final y = (i * 83.0 + progress * size.height) % size.height;
      canvas.drawCircle(Offset(x, y), 1.5 + (i % 3), paint);
    }
  }

  void _paintFog(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withAlpha(18);
    for (var i = 0; i < 3; i++) {
      final y = size.height * (0.35 + i * 0.16);
      final x = reduceMotion ? 0.0 : math.sin(progress * math.pi * 2 + i) * 60;
      canvas.drawOval(Rect.fromLTWH(x - 80, y, size.width + 160, 80), paint);
    }
  }

  @override
  bool shouldRepaint(WeatherMotionPainter old) =>
      old.progress != progress ||
      old.effect != effect ||
      old.reduceMotion != reduceMotion;
}
