import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../tokens/colors.dart';

/// Draws a simple line-art weather icon based on a WeatherAPI condition code.
/// Thin strokes, white with opacity — matches Nimbus design language.
class WeatherIcon extends StatelessWidget {
  const WeatherIcon({
    super.key,
    required this.conditionCode,
    required this.isDay,
    this.size = 24,
    this.color = NimbusColors.white,
    this.opacity = 0.9,
  });

  final int conditionCode;
  final bool isDay;
  final double size;
  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _WeatherIconPainter(
          conditionCode: conditionCode,
          isDay: isDay,
          color: color,
          opacity: opacity,
        ),
      ),
    );
  }
}

class _WeatherIconPainter extends CustomPainter {
  const _WeatherIconPainter({
    required this.conditionCode,
    required this.isDay,
    required this.color,
    required this.opacity,
  });

  final int conditionCode;
  final bool isDay;
  final Color color;
  final double opacity;

  Paint get _paint => Paint()
    ..color = color.withAlpha((opacity * 255).round())
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.5
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  Paint get _fillPaint => Paint()
    ..color = color.withAlpha((opacity * 255).round())
    ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    switch (_iconType) {
      case _IconType.sunny:
        _drawSun(canvas, size);
        break;
      case _IconType.moon:
        _drawMoon(canvas, size);
        break;
      case _IconType.partlyCloudy:
        isDay
            ? _drawPartlyCloudyDay(canvas, size)
            : _drawPartlyCloudyNight(canvas, size);
        break;
      case _IconType.cloudy:
        _drawCloud(canvas, size);
        break;
      case _IconType.rain:
        _drawRain(canvas, size);
        break;
      case _IconType.storm:
        _drawStorm(canvas, size);
        break;
      case _IconType.snow:
        _drawSnow(canvas, size);
        break;
      case _IconType.fog:
        _drawFog(canvas, size);
        break;
      case _IconType.sleet:
        _drawSleet(canvas, size);
        break;
    }
  }

  _IconType get _iconType {
    switch (conditionCode) {
      case 1000:
        return isDay ? _IconType.sunny : _IconType.moon;
      case 1003:
        return _IconType.partlyCloudy;
      case 1006:
      case 1009:
        return _IconType.cloudy;
      case 1030:
      case 1135:
      case 1147:
        return _IconType.fog;
      case 1087:
      case 1273:
      case 1276:
      case 1279:
      case 1282:
        return _IconType.storm;
      case 1066:
      case 1114:
      case 1117:
      case 1210:
      case 1213:
      case 1216:
      case 1219:
      case 1222:
      case 1225:
      case 1255:
      case 1258:
      case 1261:
      case 1264:
        return _IconType.snow;
      case 1069:
      case 1204:
      case 1207:
      case 1249:
      case 1252:
        return _IconType.sleet;
      default:
        // Rain covers the remaining precipitation codes
        if (conditionCode >= 1063 && conditionCode <= 1246) {
          return _IconType.rain;
        }
        return isDay ? _IconType.sunny : _IconType.moon;
    }
  }

  void _drawSun(Canvas canvas, Size s) {
    final cx = s.width / 2;
    final cy = s.height / 2;
    final r = s.width * 0.22;
    canvas.drawCircle(Offset(cx, cy), r, _paint);
    for (int i = 0; i < 8; i++) {
      final angle = i * math.pi / 4;
      final inner = r + s.width * 0.06;
      final outer = r + s.width * 0.14;
      canvas.drawLine(
        Offset(cx + inner * math.cos(angle), cy + inner * math.sin(angle)),
        Offset(cx + outer * math.cos(angle), cy + outer * math.sin(angle)),
        _paint,
      );
    }
  }

  void _drawMoon(Canvas canvas, Size s) {
    final cx = s.width / 2;
    final cy = s.height / 2;
    final r = s.width * 0.28;
    final path = Path()
      ..moveTo(cx + r * math.cos(-1.2), cy + r * math.sin(-1.2))
      ..arcTo(
        Rect.fromCircle(center: Offset(cx, cy), radius: r),
        -1.2,
        4.6,
        false,
      )
      ..arcToPoint(
        Offset(cx + r * math.cos(-1.2), cy + r * math.sin(-1.2)),
        radius: Radius.circular(r * 0.9),
        clockwise: false,
      );
    canvas.drawPath(path, _paint);
  }

  void _drawCloud(Canvas canvas, Size s) {
    canvas.drawPath(_cloudPath(s, 0), _paint);
  }

  Path _cloudPath(Size s, double yOff) {
    final w = s.width;
    final h = s.height;
    return Path()
      ..moveTo(w * 0.15, h * 0.65 + yOff)
      ..arcToPoint(Offset(w * 0.3, h * 0.45 + yOff),
          radius: Radius.circular(w * 0.18), clockwise: false)
      ..arcToPoint(Offset(w * 0.55, h * 0.38 + yOff),
          radius: Radius.circular(w * 0.22), clockwise: false)
      ..arcToPoint(Offset(w * 0.75, h * 0.5 + yOff),
          radius: Radius.circular(w * 0.18), clockwise: false)
      ..arcToPoint(Offset(w * 0.85, h * 0.65 + yOff),
          radius: Radius.circular(w * 0.14), clockwise: false)
      ..arcToPoint(Offset(w * 0.15, h * 0.65 + yOff),
          radius: Radius.circular(w * 0.24), clockwise: false);
  }

  void _drawPartlyCloudyDay(Canvas canvas, Size s) {
    // Small sun (top-left region)
    final cx = s.width * 0.34;
    final cy = s.height * 0.36;
    final r = s.width * 0.17;
    canvas.drawCircle(Offset(cx, cy), r, _paint);
    for (int i = 0; i < 6; i++) {
      final angle = i * math.pi / 3;
      canvas.drawLine(
        Offset(cx + (r + s.width * 0.04) * math.cos(angle),
            cy + (r + s.width * 0.04) * math.sin(angle)),
        Offset(cx + (r + s.width * 0.1) * math.cos(angle),
            cy + (r + s.width * 0.1) * math.sin(angle)),
        _paint,
      );
    }
    // Cloud in foreground
    canvas.drawPath(_cloudPath(s, s.height * 0.12), _paint);
  }

  void _drawPartlyCloudyNight(Canvas canvas, Size s) {
    _drawMoon(canvas, s);
    canvas.drawPath(_cloudPath(s, s.height * 0.12), _paint);
  }

  void _drawRain(Canvas canvas, Size s) {
    canvas.drawPath(_cloudPath(s, 0), _paint);
    for (int i = 0; i < 3; i++) {
      final x = s.width * (0.3 + i * 0.2);
      canvas.drawLine(
        Offset(x, s.height * 0.72),
        Offset(x - s.width * 0.04, s.height * 0.88),
        _paint,
      );
    }
  }

  void _drawStorm(Canvas canvas, Size s) {
    canvas.drawPath(_cloudPath(s, 0), _paint);
    final bolt = Path()
      ..moveTo(s.width * 0.53, s.height * 0.65)
      ..lineTo(s.width * 0.42, s.height * 0.79)
      ..lineTo(s.width * 0.53, s.height * 0.77)
      ..lineTo(s.width * 0.44, s.height * 0.92);
    canvas.drawPath(bolt, _paint);
  }

  void _drawSnow(Canvas canvas, Size s) {
    canvas.drawPath(_cloudPath(s, 0), _paint);
    for (int i = 0; i < 3; i++) {
      final cx = s.width * (0.28 + i * 0.22);
      final cy = s.height * 0.82;
      final r = s.width * 0.038;
      // Asterisk
      for (int j = 0; j < 3; j++) {
        final angle = j * math.pi / 3;
        canvas.drawLine(
          Offset(cx - r * math.cos(angle), cy - r * math.sin(angle)),
          Offset(cx + r * math.cos(angle), cy + r * math.sin(angle)),
          _paint,
        );
      }
    }
  }

  void _drawFog(Canvas canvas, Size s) {
    for (int i = 0; i < 4; i++) {
      final y = s.height * (0.28 + i * 0.16);
      final margin = i.isEven ? 0.08 : 0.16;
      canvas.drawLine(
        Offset(s.width * margin, y),
        Offset(s.width * (1 - margin), y),
        _paint,
      );
    }
  }

  void _drawSleet(Canvas canvas, Size s) {
    canvas.drawPath(_cloudPath(s, 0), _paint);
    // Mixed: rain left, snow right
    canvas.drawLine(
      Offset(s.width * 0.3, s.height * 0.72),
      Offset(s.width * 0.26, s.height * 0.86),
      _paint,
    );
    canvas.drawCircle(
        Offset(s.width * 0.5, s.height * 0.82), s.width * 0.03, _fillPaint);
    canvas.drawLine(
      Offset(s.width * 0.7, s.height * 0.72),
      Offset(s.width * 0.66, s.height * 0.86),
      _paint,
    );
  }

  @override
  bool shouldRepaint(_WeatherIconPainter old) =>
      old.conditionCode != conditionCode ||
      old.isDay != isDay ||
      old.color != color;
}

enum _IconType { sunny, moon, partlyCloudy, cloudy, rain, storm, snow, fog, sleet }
