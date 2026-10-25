import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/strings.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/weather_models.dart';
import '../../design/sky/sky_palette.dart';
import '../../design/tokens/colors.dart';
import '../../design/tokens/spacing.dart';
import '../../design/tokens/typography.dart';
import '../../design/widgets/sky_background.dart';
import '../../design/widgets/press_scale.dart';
import '../home/home_controller.dart';
import '../../core/settings/settings_controller.dart';

class DetailsScreen extends ConsumerWidget {
  const DetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeControllerProvider);
    final settings = ref.watch(settingsProvider);
    final weather = state.weather;

    if (weather == null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: DefaultSkyBackground(
          reduceMotion:
              settings.reduceMotion || MediaQuery.of(context).disableAnimations,
          child: Center(
            child: CircularProgressIndicator(
                strokeWidth: 1.5, color: NimbusColors.white50),
          ),
        ),
      );
    }

    final palette = paletteFromCondition(
      weather.current.condition.code,
      weather.current.isDay,
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SkyBackground(
        palette: palette,
        reduceMotion:
            settings.reduceMotion || MediaQuery.of(context).disableAnimations,
        child: CustomScrollView(
          slivers: [
            // App bar
            SliverSafeArea(
              bottom: false,
              sliver: SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: NimbusSpacing.base,
                    vertical: NimbusSpacing.base,
                  ),
                  child: Row(
                    children: [
                      Semantics(
                        button: true,
                        label: 'Back',
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            context.pop();
                          },
                          child: Container(
                            width: 48,
                            height: 48,
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.arrow_back_rounded,
                              color: NimbusColors.white70,
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: NimbusSpacing.sm),
                      Text(
                        weather.location.name,
                        style: NimbusTypography.condition,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: NimbusSpacing.xl),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // UV Gauge
                  _DetailsSection(
                    label: NimbusStrings.uvIndex,
                    delay: 0,
                    child: _UvGauge(uv: weather.current.uv),
                  ),

                  _divider(),

                  // Wind
                  _DetailsSection(
                    label: NimbusStrings.wind,
                    delay: 40,
                    child: _WindDetail(
                      kph: weather.current.windKph,
                      dir: weather.current.windDir,
                      degree: weather.current.windDegree,
                      useKph: settings.useKph,
                    ),
                  ),

                  _divider(),

                  // Humidity
                  _DetailsSection(
                    label: NimbusStrings.humidity,
                    delay: 80,
                    child: _ValueWithExplanation(
                      value: '${weather.current.humidity}%',
                      explanation: Formatters.humidityExplanation(
                          weather.current.humidity),
                      semanticLabel:
                          NimbusStrings.humiditySemantic(weather.current.humidity),
                    ),
                  ),

                  _divider(),

                  // Pressure
                  _DetailsSection(
                    label: NimbusStrings.pressure,
                    delay: 120,
                    child: _ValueWithExplanation(
                      value: '${weather.current.pressureMb.round()} mb',
                      explanation: _pressureExplanation(weather.current.pressureMb),
                    ),
                  ),

                  _divider(),

                  // Visibility
                  _DetailsSection(
                    label: NimbusStrings.visibility,
                    delay: 160,
                    child: _ValueWithExplanation(
                      value: '${weather.current.visKm.round()} km',
                      explanation:
                          Formatters.visibilityExplanation(weather.current.visKm),
                    ),
                  ),

                  _divider(),

                  // Dew point
                  _DetailsSection(
                    label: NimbusStrings.dewPoint,
                    delay: 200,
                    child: _ValueWithExplanation(
                      value:
                          '${Formatters.convertTemp(weather.current.dewpointC, useCelsius: settings.useCelsius).round()}${Formatters.unitSymbol(useCelsius: settings.useCelsius)}',
                      explanation:
                          'Moisture in the air. Above 16°C feels humid.',
                    ),
                  ),

                  _divider(),

                  // Precipitation
                  _DetailsSection(
                    label: NimbusStrings.precipitation,
                    delay: 240,
                    child: _ValueWithExplanation(
                      value: '${weather.current.precipMm} mm',
                      explanation: weather.current.precipMm == 0
                          ? 'No precipitation in the last hour.'
                          : 'Precipitation recorded in the last hour.',
                    ),
                  ),

                  // Air quality
                  if (weather.current.airQuality != null) ...[
                    _divider(),
                    _DetailsSection(
                      label: NimbusStrings.airQuality,
                      delay: 280,
                      child: _AqiDetail(aqi: weather.current.airQuality!),
                    ),
                  ],

                  // Sunrise / Sunset
                  if (weather.forecast.forecastDays.isNotEmpty) ...[
                    _divider(),
                    _DetailsSection(
                      label: 'SUN',
                      delay: 320,
                      child: _SunriseSunsetDetail(
                        astro: weather.forecast.forecastDays.first.astro,
                        localtimeEpoch: weather.location.localtimeEpoch,
                      ),
                    ),

                    _divider(),

                    // Moon
                    _DetailsSection(
                      label: NimbusStrings.moonPhase,
                      delay: 360,
                      child: _ValueWithExplanation(
                        value: Formatters.moonPhaseLabel(
                            weather.forecast.forecastDays.first.astro.moonPhase),
                        explanation:
                            '${weather.forecast.forecastDays.first.astro.moonIllumination}% illuminated',
                      ),
                    ),
                  ],

                  _divider(),
                  const _Attribution(),

                  const SizedBox(height: NimbusSpacing.xxl),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() => Divider(
        height: 1,
        thickness: 0.5,
        color: NimbusColors.divider,
      );

  String _pressureExplanation(double mb) {
    if (mb < 1000) return 'Low pressure — stormy weather likely.';
    if (mb < 1013) return 'Below average — unsettled conditions.';
    if (mb < 1020) return 'Near normal pressure.';
    return 'High pressure — fair weather likely.';
  }
}

// ---------------------------------------------------------------------------
// Section wrapper
// ---------------------------------------------------------------------------

class _DetailsSection extends StatelessWidget {
  const _DetailsSection({
    required this.label,
    required this.child,
    required this.delay,
  });

  final String label;
  final Widget child;
  final int delay;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: NimbusSpacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: NimbusTypography.sectionHeading),
          const SizedBox(height: NimbusSpacing.sm),
          child,
        ],
      ),
    )
        .animate(delay: delay.ms)
        .fadeIn(duration: 400.ms, curve: Curves.easeOutCubic)
        .slideY(begin: 0.06, end: 0, duration: 400.ms);
  }
}

class _Attribution extends StatelessWidget {
  const _Attribution();

  @override
  Widget build(BuildContext context) => Semantics(
        link: true,
        label: NimbusStrings.poweredBy,
        child: GestureDetector(
          onTap: () async {
            await Clipboard.setData(
              const ClipboardData(text: NimbusStrings.weatherApiUrl),
            );
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text(NimbusStrings.linkCopied)),
              );
            }
          },
          child: Text(
            NimbusStrings.poweredBy,
            style: NimbusTypography.detailExplanation.copyWith(
              decoration: TextDecoration.underline,
              color: NimbusColors.white70,
            ),
          ),
        ),
      );
}

// ---------------------------------------------------------------------------
// UV Gauge
// ---------------------------------------------------------------------------

class _UvGauge extends StatelessWidget {
  const _UvGauge({required this.uv});

  final double uv;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: NimbusStrings.uvSemantic(uv),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                uv.round().toString(),
                style: NimbusTypography.detailValue,
              ),
              const SizedBox(width: NimbusSpacing.sm),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  Formatters.uvCategory(uv),
                  style: NimbusTypography.caption,
                ),
              ),
            ],
          ),
          const SizedBox(height: NimbusSpacing.sm),
          // Gauge bar
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: SizedBox(
              height: 6,
              width: double.infinity,
              child: CustomPaint(
                painter: _UvGaugePainter(uv: uv),
                size: Size.infinite,
              ),
            ),
          ),
          const SizedBox(height: NimbusSpacing.sm),
          Text(
            Formatters.uvExplanation(uv),
            style: NimbusTypography.detailExplanation,
          ),
          // Labels
          const SizedBox(height: NimbusSpacing.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['Low', 'Mod', 'High', 'V.High', 'Ext']
                .map((l) => Text(l, style: NimbusTypography.detailExplanation))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _UvGaugePainter extends CustomPainter {
  const _UvGaugePainter({required this.uv});

  final double uv;

  @override
  void paint(Canvas canvas, Size size) {
    // Gradient bar
    final gradient = const LinearGradient(
      colors: [
        Color(0xFF4CAF50), // Green (low)
        Color(0xFFFFEB3B), // Yellow (moderate)
        Color(0xFFF57C00), // Orange (high)
        Color(0xFFD32F2F), // Red (very high)
        Color(0xFF7B1FA2), // Purple (extreme)
      ],
    );
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()..shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);

    // Indicator line
    final fraction = (uv / 11).clamp(0.0, 1.0);
    final x = fraction * size.width;
    final indicatorPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(x, 0), Offset(x, size.height), indicatorPaint);
  }

  @override
  bool shouldRepaint(_UvGaugePainter old) => old.uv != uv;
}

// ---------------------------------------------------------------------------
// Wind detail with animated direction arrow
// ---------------------------------------------------------------------------

class _WindDetail extends StatefulWidget {
  const _WindDetail({
    required this.kph,
    required this.dir,
    required this.degree,
    required this.useKph,
  });

  final double kph;
  final String dir;
  final int degree;
  final bool useKph;

  @override
  State<_WindDetail> createState() => _WindDetailState();
}

class _WindDetailState extends State<_WindDetail>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _rotation;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _rotation = Tween<double>(
      begin: 0,
      end: widget.degree * math.pi / 180,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: NimbusStrings.windSemantic(
        widget.useKph ? widget.kph : Formatters.kphToMph(widget.kph),
        widget.dir,
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${(widget.useKph ? widget.kph : Formatters.kphToMph(widget.kph)).round()} ${widget.useKph ? "km/h" : "mph"}',
                style: NimbusTypography.detailValue,
              ),
              Text(
                widget.dir,
                style: NimbusTypography.detailExplanation,
              ),
            ],
          ),
          const SizedBox(width: NimbusSpacing.xl),
          // Animated direction arrow
          AnimatedBuilder(
            animation: _rotation,
            builder: (context, _) {
              return Transform.rotate(
                angle: _rotation.value,
                child: const Icon(
                  Icons.navigation_rounded,
                  color: NimbusColors.white50,
                  size: 32,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Generic value + explanation
// ---------------------------------------------------------------------------

class _ValueWithExplanation extends StatelessWidget {
  const _ValueWithExplanation({
    required this.value,
    required this.explanation,
    this.semanticLabel,
  });

  final String value;
  final String explanation;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel ?? '$value. $explanation',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: NimbusTypography.detailValue),
          const SizedBox(height: NimbusSpacing.xs),
          Text(explanation, style: NimbusTypography.detailExplanation),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Air quality
// ---------------------------------------------------------------------------

class _AqiDetail extends StatelessWidget {
  const _AqiDetail({required this.aqi});

  final AirQuality aqi;

  @override
  Widget build(BuildContext context) {
    final label = Formatters.aqiLabel(aqi.usEpaIndex);

    return Semantics(
      label: NimbusStrings.aqiSemantic(label),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                aqi.usEpaIndex.toString(),
                style: NimbusTypography.detailValue,
              ),
              const SizedBox(width: NimbusSpacing.sm),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(label, style: NimbusTypography.caption),
              ),
            ],
          ),
          const SizedBox(height: NimbusSpacing.sm),
          // AQI gradient scale bar
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: SizedBox(
              height: 6,
              width: double.infinity,
              child: CustomPaint(
                painter: _AqiGaugePainter(index: aqi.usEpaIndex),
                size: Size.infinite,
              ),
            ),
          ),
          const SizedBox(height: NimbusSpacing.sm),
          Text(
            'PM2.5: ${aqi.pm25.toStringAsFixed(1)} µg/m³  ·  PM10: ${aqi.pm10.toStringAsFixed(1)} µg/m³',
            style: NimbusTypography.detailExplanation,
          ),
        ],
      ),
    );
  }
}

class _AqiGaugePainter extends CustomPainter {
  const _AqiGaugePainter({required this.index});

  final int index;

  @override
  void paint(Canvas canvas, Size size) {
    final gradient = const LinearGradient(
      colors: [
        Color(0xFF4CAF50),
        Color(0xFFFFEB3B),
        Color(0xFFF57C00),
        Color(0xFFD32F2F),
        Color(0xFF7B1FA2),
        Color(0xFF4A0000),
      ],
    );
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(rect, Paint()..shader = gradient.createShader(rect));

    final fraction = ((index - 1) / 5).clamp(0.0, 1.0);
    final x = fraction * size.width;
    canvas.drawLine(
      Offset(x, 0),
      Offset(x, size.height),
      Paint()
        ..color = Colors.white
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(_AqiGaugePainter old) => old.index != index;
}

// ---------------------------------------------------------------------------
// Sunrise / Sunset arc
// ---------------------------------------------------------------------------

class _SunriseSunsetDetail extends StatelessWidget {
  const _SunriseSunsetDetail({
    required this.astro,
    required this.localtimeEpoch,
  });

  final Astronomy astro;
  final int localtimeEpoch;

  @override
  Widget build(BuildContext context) {
    final now = localtimeEpoch > 0
        ? DateTime.fromMillisecondsSinceEpoch(localtimeEpoch * 1000)
        : DateTime.now();

    final sunrise = Formatters.parseTimeString(astro.sunrise, now);
    final sunset = Formatters.parseTimeString(astro.sunset, now);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _SunTime(
              label: NimbusStrings.sunrise,
              time: astro.sunrise,
            ),
            const SizedBox(width: NimbusSpacing.xl),
            _SunTime(
              label: NimbusStrings.sunset,
              time: astro.sunset,
            ),
          ],
        ),
        const SizedBox(height: NimbusSpacing.base),
        SizedBox(
          height: 80,
          width: double.infinity,
          child: CustomPaint(
            painter: _SunArcPainter(
              now: now,
              sunrise: sunrise,
              sunset: sunset,
            ),
            size: Size.infinite,
          ),
        ),
      ],
    );
  }
}

class _SunTime extends StatelessWidget {
  const _SunTime({required this.label, required this.time});

  final String label;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: NimbusTypography.sectionHeading),
        Text(time, style: NimbusTypography.detailValue),
      ],
    );
  }
}

class _SunArcPainter extends CustomPainter {
  const _SunArcPainter({
    required this.now,
    required this.sunrise,
    required this.sunset,
  });

  final DateTime now;
  final DateTime? sunrise;
  final DateTime? sunset;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height;
    final rx = size.width * 0.45;
    final ry = size.height * 0.9;

    final arcPaint = Paint()
      ..color = NimbusColors.white.withAlpha(30)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Draw the full arc (half ellipse)
    final path = Path()
      ..moveTo(cx - rx, cy)
      ..addArc(
        Rect.fromCenter(
            center: Offset(cx, cy), width: rx * 2, height: ry * 2),
        math.pi,
        math.pi,
      );
    canvas.drawPath(path, arcPaint);

    // Sun position on arc
    if (sunrise != null && sunset != null) {
      final total = sunset!.difference(sunrise!).inSeconds.toDouble();
      final elapsed = now.difference(sunrise!).inSeconds.toDouble();
      final progress = (elapsed / total).clamp(0.0, 1.0);

      // Angle from left (π) to right (0), going upward
      final angle = math.pi + progress * math.pi;
      final sunX = cx + rx * math.cos(angle);
      final sunY = cy + ry * math.sin(angle);

      // Glow
      canvas.drawCircle(
        Offset(sunX, sunY),
        10,
        Paint()..color = NimbusColors.accent.withAlpha(40),
      );
      canvas.drawCircle(
        Offset(sunX, sunY),
        5,
        Paint()
          ..color = NimbusColors.accent.withAlpha(180)
          ..style = PaintingStyle.fill,
      );
    }

    // Horizon line
    canvas.drawLine(
      Offset(cx - rx - 8, cy),
      Offset(cx + rx + 8, cy),
      Paint()
        ..color = NimbusColors.white.withAlpha(20)
        ..strokeWidth = 0.5,
    );
  }

  @override
  bool shouldRepaint(_SunArcPainter old) =>
      old.now != now || old.sunrise != sunrise || old.sunset != sunset;
}
