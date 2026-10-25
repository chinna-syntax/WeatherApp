import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/errors/app_failure.dart';
import '../../../design/tokens/colors.dart';
import '../../../design/tokens/spacing.dart';
import '../../../design/tokens/typography.dart';

class HomeErrorView extends StatelessWidget {
  const HomeErrorView({
    super.key,
    required this.failure,
    required this.onRetry,
  });

  final AppFailure failure;
  final VoidCallback onRetry;

  IconData get _iconData {
    if (failure is NetworkFailure) return Icons.wifi_off_rounded;
    if (failure is TimeoutFailure) return Icons.access_time_outlined;
    if (failure is InvalidLocationFailure) return Icons.location_off_outlined;
    if (failure is ApiKeyFailure) return Icons.vpn_key_off_outlined;
    return Icons.cloud_off_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: NimbusSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              _iconData,
              size: 48,
              color: NimbusColors.white50,
            )
                .animate()
                .fadeIn(duration: 400.ms)
                .slideY(begin: 0.2, end: 0, duration: 400.ms),
            const SizedBox(height: NimbusSpacing.base),
            Text(
              failure.message,
              style: NimbusTypography.errorText,
            )
                .animate(delay: 60.ms)
                .fadeIn(duration: 400.ms)
                .slideY(begin: 0.2, end: 0, duration: 400.ms),
            const SizedBox(height: NimbusSpacing.xl),
            _RetryButton(onRetry: onRetry)
                .animate(delay: 120.ms)
                .fadeIn(duration: 400.ms),
          ],
        ),
      ),
    );
  }
}

class _RetryButton extends StatelessWidget {
  const _RetryButton({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onRetry();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: NimbusSpacing.lg,
          vertical: NimbusSpacing.md,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: NimbusColors.white30),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          'Try again',
          style: NimbusTypography.buttonLabel.copyWith(
            color: NimbusColors.white,
          ),
        ),
      ),
    );
  }
}
