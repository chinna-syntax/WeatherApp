import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/weather_models.dart';
import '../../../design/tokens/colors.dart';
import '../../../design/tokens/spacing.dart';
import '../../../design/tokens/typography.dart';
import '../../../design/widgets/weather_icon.dart';
import '../../../core/strings.dart';

const _itemWidth = 52.0;
const _stripHeight = 120.0;
const _curveHeight = 36.0;

/// Horizontally scrolling 24-hour forecast strip.
/// Shows: time label, weather icon, temperature.
/// Current hour gets a thin underline accent.
/// A smooth bezier temperature curve floats above the items.
class HourlyForecastStrip extends StatelessWidget {
  const HourlyForecastStrip({
    super.key,
    required this.hours,
    required this.useCelsius,
  });

  final List<HourlyWeather> hours;
  final bool useCelsius;

  @override
  Widget build(BuildContext context) {
    if (hours.isEmpty) return const SizedBox.shrink();

    final now = DateTime.now();
    // Get up to 24 hours starting from current hour
    final filtered = _filterNext24(hours, now);
    if (filtered.isEmpty) return const SizedBox.shrink();

    final temps = filtered
        .map((h) => Formatters.convertTemp(h.tempC, useCelsius: useCelsius))
        .toList();
    final minTemp = temps.reduce(math.min);
    final maxTemp = temps.reduce(math.max);

    return SizedBox(
      height: _stripHeight + _curveHeight,
      child: Stack(
        children: [
          // Temperature curve behind items
          Positioned.fill(
            child: CustomPaint(
              painter: _TempCurvePainter(
                temps: temps,
                minTemp: minTemp,
                maxTemp: maxTemp,
                itemWidth: _itemWidth,
              ),
            ),
          ),
          // Scrollable items
          ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: NimbusSpacing.xl),
            itemCount: filtered.length,
            itemBuilder: (context, i) {
              final hour = filtered[i];
              final dt =
                  DateTime.fromMillisecondsSinceEpoch(hour.timeEpoch * 1000);
              final isCurrent = dt.hour == now.hour && dt.day == now.day;
              final temp = Formatters.convertTemp(
                hour.tempC,
                useCelsius: useCelsius,
              );

              return Semantics(
                label: NimbusStrings.hourTemp(
                  Formatters.formatHourLabel(dt, now),
                  '${Formatters.formatTemp(temp)}${Formatters.unitSymbol(useCelsius: useCelsius)}',
                ),
                child: SizedBox(
                  width: _itemWidth,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Time label
                      Text(
                        Formatters.formatHourLabel(dt, now),
                        style: NimbusTypography.hourlyTime.copyWith(
                          color: isCurrent
                              ? NimbusColors.white
                              : NimbusColors.white50,
                          fontWeight: isCurrent
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: NimbusSpacing.xs),
                      // Weather icon
                      WeatherIcon(
                        conditionCode: hour.condition.code,
                        isDay: hour.isDay,
                        size: 18,
                        opacity: isCurrent ? 0.95 : 0.6,
                      ),
                      const SizedBox(height: NimbusSpacing.xs),
                      // Temperature
                      Text(
                        '${Formatters.formatTemp(temp)}°',
                        style: NimbusTypography.hourlyTemp.copyWith(
                          color: isCurrent
                              ? NimbusColors.white
                              : NimbusColors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: NimbusSpacing.xs),
                      // Current hour underline
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 1.5,
                        width: isCurrent ? 20 : 0,
                        decoration: BoxDecoration(
                          color: NimbusColors.white,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                      const SizedBox(height: NimbusSpacing.xs),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  List<HourlyWeather> _filterNext24(List<HourlyWeather> all, DateTime now) {
    final result = <HourlyWeather>[];
    for (final h in all) {
      final dt = DateTime.fromMillisecondsSinceEpoch(h.timeEpoch * 1000);
      if (!dt.isBefore(
              DateTime(now.year, now.month, now.day, now.hour)) &&
          result.length < 24) {
        result.add(h);
      }
    }
    return result;
  }
}

// ---------------------------------------------------------------------------
// Temperature curve painter
// ---------------------------------------------------------------------------

class _TempCurvePainter extends CustomPainter {
  const _TempCurvePainter({
    required this.temps,
    required this.minTemp,
    required this.maxTemp,
    required this.itemWidth,
  });

  final List<double> temps;
  final double minTemp;
  final double maxTemp;
  final double itemWidth;

  @override
  void paint(Canvas canvas, Size size) {
    if (temps.length < 2) return;

    final range = (maxTemp - minTemp).abs();
    final effectiveRange = range < 1 ? 1.0 : range;

    // Map temp to y within the top portion of the strip
    double tempToY(double temp) {
      final t = (temp - minTemp) / effectiveRange;
      // Higher temp = lower y value (near top)
      return size.height * 0.1 + (1 - t) * (size.height * 0.35);
    }

    // X center of each item (account for left padding = NimbusSpacing.xl = 32)
    double tempToX(int index) =>
        NimbusSpacing.xl + itemWidth * index + itemWidth / 2;

    final points = List.generate(
      temps.length,
      (i) => Offset(tempToX(i), tempToY(temps[i])),
    );

    final paint = Paint()
      ..color = NimbusColors.white.withAlpha(50)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final cp1 = Offset((p0.dx + p1.dx) / 2, p0.dy);
      final cp2 = Offset((p0.dx + p1.dx) / 2, p1.dy);
      path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, p1.dx, p1.dy);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_TempCurvePainter old) =>
      old.temps != temps || old.minTemp != minTemp || old.maxTemp != maxTemp;
}
