import 'package:flutter/material.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';

/// Small uppercase section heading with optional trailing action.
class SectionHeading extends StatelessWidget {
  const SectionHeading({
    super.key,
    required this.label,
    this.trailing,
  });

  final String label;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: NimbusSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(label.toUpperCase(), style: NimbusTypography.sectionHeading),
          if (trailing != null) ...[
            const Spacer(),
            trailing!,
          ],
        ],
      ),
    );
  }
}
