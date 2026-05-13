// lib/core/widgets/shimmer_loading.dart
// Lightweight shimmer animation widget used by skeleton placeholders.
// Implemented with a [ShaderMask] + [LinearGradient] sweep so it works
// without any third-party shimmer package.

import 'package:flutter/material.dart';
import 'package:movie_watchlist/core/theme/app_colors.dart';

/// Wraps [child] in a repeating left-to-right shimmer gradient animation.
///
/// The gradient sweeps from [AppColors.surfaceLight] through
/// [AppColors.shimmerHighlight] and back, creating the classic loading effect.
/// [period] controls the speed of one full sweep (default 1500 ms).
class ShimmerLoading extends StatefulWidget {
  final Widget child;
  final Duration period;
  const ShimmerLoading({
    super.key,
    required this.child,
    this.period = const Duration(milliseconds: 1500),
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Repeat indefinitely until the widget is disposed
    _controller = AnimationController(vsync: this, duration: widget.period)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            // Shift the gradient start/end positions based on the animation value
            // so the highlight sweeps from left to right across the widget.
            return LinearGradient(
              begin: Alignment(-1.0 + _controller.value * 2, 0),
              end: Alignment(1.0 + _controller.value * 2, 0),
              colors: [AppColors.surfaceLight, AppColors.shimmerHighlight, AppColors.surfaceLight],
              stops: const [0.0, 0.5, 1.0],
            ).createShader(bounds);
          },
          child: child!,
        );
      },
      child: widget.child,
    );
  }
}
