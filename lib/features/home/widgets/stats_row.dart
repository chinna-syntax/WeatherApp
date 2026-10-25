import 'package:flutter/material.dart';
import '../../../core/strings.dart';
import '../../../core/utils/formatters.dart';
import '../../../design/tokens/colors.dart';
import '../../../design/tokens/spacing.dart';
import '../../../design/tokens/typography.dart';

/// Three-stat row: Humidity | Wind | UV
/// Separated by thin vertical lines, no boxed cards.
class StatsRow extends StatelessWidget {
  const StatsRow({
    super.key,
    required this.humidity,
    required this.windKph,
    required this.windDir,
    required this.uv,
    required this.useKph,
  });

  final int humidity;
  final double windKph;
  final String windDir;
  final double uv;
  final bool useKph;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Builder(
        builder: (context) {
          final windValue =
              useKph ? windKph : Formatters.kphToMph(windKph);
          final unit = useKph ? 'kph' : 'mph';
          return Row(
            children: [
              Expanded(
                child: Semantics(
                  label: NimbusStrings.humiditySemantic(humidity),
                  child: _StatCell(
                    label: NimbusStrings.humidity,
                    value: '$humidity%',
                    sub: null,
                  ),
                ),
              ),
              const _VertDivider(),
              Expanded(
                child: Semantics(
                  label: NimbusStrings.windSemantic(windValue, windDir),
                  child: _StatCell(
                    label: NimbusStrings.wind,
                    value: '${windValue.round()} $unit',
                    sub: windDir,
                  ),
                ),
              ),
              const _VertDivider(),
              Expanded(
                child: Semantics(
                  label: NimbusStrings.uvSemantic(uv),
                  child: _StatCell(
                    label: NimbusStrings.uvIndex,
                    value: uv.round().toString(),
                    sub: Formatters.uvCategory(uv),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({
    required this.label,
    required this.value,
    this.sub,
  });

  final String label;
  final String value;
  final String? sub;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: NimbusSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: NimbusTypography.statLabel),
          const SizedBox(height: NimbusSpacing.xs),
          Text(value, style: NimbusTypography.statValue),
          if (sub != null && sub!.isNotEmpty)
            Text(
              sub!,
              style: NimbusTypography.statLabel.copyWith(
                color: NimbusColors.white30,
                letterSpacing: 0.5,
                fontSize: 9,
              ),
            ),
        ],
      ),
    );
  }
}

class _VertDivider extends StatelessWidget {
  const _VertDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      margin: const EdgeInsets.symmetric(vertical: NimbusSpacing.sm),
      color: NimbusColors.divider,
    );
  }
}
