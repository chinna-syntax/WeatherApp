import 'package:flutter/material.dart';
import '../../../core/strings.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/weather_models.dart';
import '../../../design/tokens/colors.dart';
import '../../../design/tokens/spacing.dart';
import '../../../design/tokens/typography.dart';
import '../../../design/widgets/weather_icon.dart';

/// List of available forecast days with proportional temp range bar.
/// No boxed cards — thin dividers between rows.
class DailyForecast extends StatelessWidget {
  const DailyForecast({
    super.key,
    required this.days,
    required this.useCelsius,
  });

  final List<ForecastDay> days;
  final bool useCelsius;

  @override
  Widget build(BuildContext context) {
    if (days.isEmpty) return const SizedBox.shrink();

    // Global min/max across all days for proportional bar
    final allMins = days.map((d) =>
        Formatters.convertTemp(d.day.minTempC, useCelsius: useCelsius));
    final allMaxes = days.map((d) =>
        Formatters.convertTemp(d.day.maxTempC, useCelsius: useCelsius));
    final globalMin = allMins.reduce((a, b) => a < b ? a : b);
    final globalMax = allMaxes.reduce((a, b) => a > b ? a : b);

    final now = DateTime.now();

    return Column(
      children: [
        for (int i = 0; i < days.length; i++) ...[
          if (i > 0)
            Divider(
              height: 1,
              thickness: 0.5,
              color: NimbusColors.divider,
              indent: 0,
              endIndent: 0,
            ),
          _DayRow(
            day: days[i],
            globalMin: globalMin,
            globalMax: globalMax,
            useCelsius: useCelsius,
            now: now,
          ),
        ],
      ],
    );
  }
}

class _DayRow extends StatelessWidget {
  const _DayRow({
    required this.day,
    required this.globalMin,
    required this.globalMax,
    required this.useCelsius,
    required this.now,
  });

  final ForecastDay day;
  final double globalMin;
  final double globalMax;
  final bool useCelsius;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final dt =
        DateTime.fromMillisecondsSinceEpoch(day.dateEpoch * 1000);
    final dayLabel = Formatters.formatDayLabel(dt, now);
    final minC = Formatters.convertTemp(day.day.minTempC, useCelsius: useCelsius);
    final maxC = Formatters.convertTemp(day.day.maxTempC, useCelsius: useCelsius);
    final unit = Formatters.unitSymbol(useCelsius: useCelsius);

    return Semantics(
      label: NimbusStrings.dailyForecast(
        dayLabel,
        '${Formatters.formatTemp(maxC)}$unit',
        '${Formatters.formatTemp(minC)}$unit',
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: NimbusSpacing.md),
        child: Row(
          children: [
            // Day name
            SizedBox(
              width: 72,
              child: Text(dayLabel, style: NimbusTypography.dailyDay),
            ),

            // Condition icon
            WeatherIcon(
              conditionCode: day.day.condition.code,
              isDay: true,
              size: 20,
              opacity: 0.75,
            ),

            const SizedBox(width: NimbusSpacing.sm),

            // Rain chance
            SizedBox(
              width: 32,
              child: day.day.dailyChanceOfRain > 0
                  ? Text(
                      '${day.day.dailyChanceOfRain}%',
                      style: NimbusTypography.rainChance,
                    )
                  : const SizedBox.shrink(),
            ),

            const SizedBox(width: NimbusSpacing.sm),

            // Min temp
            SizedBox(
              width: 32,
              child: Text(
                '${Formatters.formatTemp(minC)}°',
                style: NimbusTypography.dailyTemp,
                textAlign: TextAlign.end,
              ),
            ),

            const SizedBox(width: NimbusSpacing.sm),

            // Proportional range bar
            Expanded(
              child: _TempRangeBar(
                min: minC,
                max: maxC,
                globalMin: globalMin,
                globalMax: globalMax,
              ),
            ),

            const SizedBox(width: NimbusSpacing.sm),

            // Max temp
            SizedBox(
              width: 32,
              child: Text(
                '${Formatters.formatTemp(maxC)}°',
                style: NimbusTypography.dailyDay,
                textAlign: TextAlign.start,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TempRangeBar extends StatelessWidget {
  const _TempRangeBar({
    required this.min,
    required this.max,
    required this.globalMin,
    required this.globalMax,
  });

  final double min;
  final double max;
  final double globalMin;
  final double globalMax;

  @override
  Widget build(BuildContext context) {
    final range = (globalMax - globalMin).abs();
    final effectiveRange = range < 1 ? 1.0 : range;
    final startFraction = ((min - globalMin) / effectiveRange).clamp(0.0, 1.0);
    final endFraction = ((max - globalMin) / effectiveRange).clamp(0.0, 1.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final left = startFraction * totalWidth;
        final barWidth = (endFraction - startFraction) * totalWidth;

        return SizedBox(
          height: 4,
          child: Stack(
            children: [
              // Background track
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: NimbusColors.white10,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Active range
              Positioned(
                left: left,
                width: barWidth.clamp(4.0, totalWidth),
                top: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: NimbusColors.white70,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
