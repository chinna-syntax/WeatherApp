import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../tokens/colors.dart';

/// Skeleton shimmer used in loading states.
/// Renders rectangular shimmer blocks over the sky gradient.
class NimbusShimmer extends StatefulWidget {
  const NimbusShimmer({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  final double width;
  final double height;
  final double borderRadius;

  @override
  State<NimbusShimmer> createState() => _NimbusShimmerState();
}

class _NimbusShimmerState extends State<NimbusShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
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
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            color: Color.lerp(
              NimbusColors.shimmerBase,
              NimbusColors.shimmerHighlight,
              _animation.value,
            ),
          ),
        );
      },
    );
  }
}

/// Full-screen loading skeleton for the home screen.
class HomeScreenSkeleton extends StatelessWidget {
  const HomeScreenSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 64),
              // City name
              const NimbusShimmer(width: 200, height: 40, borderRadius: 6),
              const SizedBox(height: 12),
              // Condition
              const NimbusShimmer(width: 140, height: 20, borderRadius: 4),
              const SizedBox(height: 48),
              // Temperature
              const NimbusShimmer(width: 220, height: 120, borderRadius: 8),
              const SizedBox(height: 24),
              // Feels like
              const NimbusShimmer(width: 160, height: 18, borderRadius: 4),
              const Spacer(),
              // Stats row
              Row(
                children: [
                  const Expanded(
                    child: NimbusShimmer(
                      width: double.infinity,
                      height: 56,
                      borderRadius: 4,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: NimbusShimmer(
                      width: double.infinity,
                      height: 56,
                      borderRadius: 4,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: NimbusShimmer(
                      width: double.infinity,
                      height: 56,
                      borderRadius: 4,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms);
  }
}
