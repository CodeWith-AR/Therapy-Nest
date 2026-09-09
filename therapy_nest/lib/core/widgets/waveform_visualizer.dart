import 'dart:math';

import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Real-time animated bars showing live audio amplitude.
///
/// Displays 16 soft-blue vertical bars that animate to simulate
/// waveform activity. When [isActive] is true the bars animate
/// with a smooth sine-wave pattern; when false they shrink to a
/// resting height.
///
/// Uses [CustomPainter] for performance.
class WaveformVisualizer extends StatefulWidget {
  const WaveformVisualizer({
    super.key,
    this.isActive = false,
    this.height = 60.0,
    this.barCount = 16,
  });

  /// Whether the waveform should animate (recording in progress).
  final bool isActive;

  /// Total height of the visualizer.
  final double height;

  /// Number of bars to render.
  final int barCount;

  @override
  State<WaveformVisualizer> createState() => _WaveformVisualizerState();
}

class _WaveformVisualizerState extends State<WaveformVisualizer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    if (widget.isActive) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant WaveformVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.isActive && _controller.isAnimating) {
      _controller.stop();
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
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          size: Size(double.infinity, widget.height),
          painter: _WaveformPainter(
            progress: _controller.value,
            barCount: widget.barCount,
            isActive: widget.isActive,
            barColor: AppColors.primary.withValues(alpha: 0.55),
            activeBarColor: AppColors.primary,
          ),
        );
      },
    );
  }
}

/// A convenience alias — Flutter's [AnimatedBuilder] is the same as
/// the old [AnimatedWidget] pattern but takes an explicit builder.
class AnimatedBuilder extends AnimatedWidget {
  const AnimatedBuilder({
    super.key,
    required Animation<double> animation,
    required this.builder,
  }) : super(listenable: animation);

  final Widget Function(BuildContext context, Widget? child) builder;

  @override
  Widget build(BuildContext context) => builder(context, null);
}

// ─────────────────────────────────────────────────────────────────────────────
// Custom painter for waveform bars
// ─────────────────────────────────────────────────────────────────────────────

class _WaveformPainter extends CustomPainter {
  _WaveformPainter({
    required this.progress,
    required this.barCount,
    required this.isActive,
    required this.barColor,
    required this.activeBarColor,
  });

  final double progress;
  final int barCount;
  final bool isActive;
  final Color barColor;
  final Color activeBarColor;

  static const double _barWidth = 4.0;
  static const double _barGap = 3.0;
  static const double _minBarHeight = 4.0;
  static const double _cornerRadius = 2.0;

  @override
  void paint(Canvas canvas, Size size) {
    final totalBarWidth = _barWidth + _barGap;
    final totalWidth = totalBarWidth * barCount - _barGap;
    final startX = (size.width - totalWidth) / 2;

    final paint = Paint()
      ..style = PaintingStyle.fill;

    for (int i = 0; i < barCount; i++) {
      double normalizedHeight;

      if (isActive) {
        // Smooth sine-wave pattern with phase offset per bar
        final phase = (progress * 2 * pi) + (i * pi / barCount * 2.5);
        normalizedHeight =
            0.3 + 0.7 * ((sin(phase) + 1) / 2); // range 0.3–1.0
        paint.color = activeBarColor.withValues(
          alpha: 0.4 + 0.6 * normalizedHeight,
        );
      } else {
        // Resting state — subtle idle bars
        normalizedHeight = 0.15 + 0.1 * sin(i * 0.8);
        paint.color = barColor;
      }

      final barHeight = max(
        _minBarHeight,
        size.height * normalizedHeight,
      );

      final x = startX + i * totalBarWidth;
      final y = (size.height - barHeight) / 2;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, _barWidth, barHeight),
          const Radius.circular(_cornerRadius),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter old) =>
      old.progress != progress || old.isActive != isActive;
}
