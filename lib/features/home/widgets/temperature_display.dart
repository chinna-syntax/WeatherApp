import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/utils/formatters.dart';
import '../../../design/tokens/colors.dart';
import '../../../design/tokens/typography.dart';

/// Giant animated temperature display.
/// Animates from 0 to the actual value on first render (count-up effect).
class TemperatureDisplay extends StatefulWidget {
  const TemperatureDisplay({
    super.key,
    required this.tempC,
    required this.useCelsius,
  });

  final double tempC;
  final bool useCelsius;

  @override
  State<TemperatureDisplay> createState() => _TemperatureDisplayState();
}

class _TemperatureDisplayState extends State<TemperatureDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _previousTemp = 0;

  double get _targetTemp =>
      widget.useCelsius ? widget.tempC : widget.tempC * 9 / 5 + 32;

  String get _unit => widget.useCelsius ? '°' : '°F';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animation = Tween<double>(
      begin: 0,
      end: _targetTemp,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    _controller.forward();
  }

  @override
  void didUpdateWidget(TemperatureDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tempC != widget.tempC ||
        oldWidget.useCelsius != widget.useCelsius) {
      _previousTemp =
          oldWidget.useCelsius ? oldWidget.tempC : oldWidget.tempC * 9 / 5 + 32;
      _animation = Tween<double>(
        begin: _previousTemp,
        end: _targetTemp,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ));
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        final displayTemp = Formatters.formatTemp(_animation.value);
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              displayTemp,
              style: NimbusTypography.temperatureHero,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                _unit,
                style: NimbusTypography.temperatureHero.copyWith(
                  fontSize: 48,
                  fontWeight: FontWeight.w300,
                  color: NimbusColors.white70,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
