import 'package:flutter/material.dart';
import '../sky/sky_palette.dart';
import '../tokens/colors.dart';
import 'weather_motion_painter.dart';

export 'weather_motion_painter.dart';

/// The animated sky background that wraps every screen.
/// Uses TweenAnimationBuilder to smoothly interpolate gradient colors
/// when the palette changes (AnimatedContainer doesn't tween gradients).
class SkyBackground extends StatelessWidget {
  const SkyBackground({
    super.key,
    required this.palette,
    required this.child,
    this.effect = WeatherEffect.auto,
    this.reduceMotion = false,
  });

  final SkyPalette palette;
  final Widget child;
  final WeatherEffect effect;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    return _AnimatedGradient(
      palette: palette,
      effect: effect,
      reduceMotion: reduceMotion,
      child: child,
    );
  }
}

class _AnimatedGradient extends StatefulWidget {
  const _AnimatedGradient({
    required this.palette,
    required this.child,
    required this.effect,
    required this.reduceMotion,
  });

  final SkyPalette palette;
  final Widget child;
  final WeatherEffect effect;
  final bool reduceMotion;

  @override
  State<_AnimatedGradient> createState() => _AnimatedGradientState();
}

class _AnimatedGradientState extends State<_AnimatedGradient>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _controller;
  late SkyPalette _from;
  late SkyPalette _to;
  late AnimationController _motion;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _from = widget.palette;
    _to = widget.palette;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _motion = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    );
    if (!widget.reduceMotion) _motion.repeat();
  }

  @override
  void didUpdateWidget(_AnimatedGradient oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.palette != widget.palette) {
      _from = oldWidget.palette;
      _to = widget.palette;
      _controller
        ..reset()
        ..forward();
    }
    if (oldWidget.reduceMotion != widget.reduceMotion) {
      if (widget.reduceMotion) {
        _motion.stop();
      } else {
        _motion.repeat();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    _motion.dispose();
    super.dispose();
  }

  Color _lerp(Color a, Color b, double t) => Color.lerp(a, b, t)!;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (widget.reduceMotion) return;
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _motion.stop();
    } else if (state == AppLifecycleState.resumed) {
      _motion.repeat();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_controller, _motion]),
      builder: (context, _) {
        final t = Curves.easeInOut.transform(_controller.value);
        final currentTop = _lerp(_from.top, _to.top, t);
        final currentBottom = _lerp(_from.bottom, _to.bottom, t);
        final currentScrim = _from.scrimOpacity +
            (_to.scrimOpacity - _from.scrimOpacity) * t;

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [currentTop, currentBottom],
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: RepaintBoundary(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 600),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    child: CustomPaint(
                      key: ValueKey<WeatherEffect>(widget.effect),
                      painter: WeatherMotionPainter(
                        effect: widget.effect,
                        progress: _motion.value,
                        reduceMotion: widget.reduceMotion,
                      ),
                    ),
                  ),
                ),
              ),
              if (currentScrim > 0)
                Positioned.fill(
                  child: Container(
                    color: Color.fromRGBO(0, 0, 0, currentScrim),
                  ),
                ),
              widget.child,
            ],
          ),
        );
      },
    );
  }
}

/// Default sky used on loading / onboarding when no weather data yet.
class DefaultSkyBackground extends StatelessWidget {
  const DefaultSkyBackground({
    super.key,
    required this.child,
    this.reduceMotion = false,
  });

  final Widget child;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isDay = now.hour >= 6 && now.hour < 20;
    return SkyBackground(
      palette: isDay ? SkyPalettes.clearDay : SkyPalettes.clearNight,
      reduceMotion: reduceMotion,
      child: child,
    );
  }
}

/// A slim banner shown at the top of the screen when offline.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        width: double.infinity,
        color: NimbusColors.offlineBg,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Row(
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              size: 14,
              color: NimbusColors.white70,
            ),
            const SizedBox(width: 8),
            Text(
              'No internet connection',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: NimbusColors.white70,
                    fontFamily: 'Manrope',
                    fontSize: 12,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
