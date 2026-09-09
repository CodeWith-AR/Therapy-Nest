import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';

/// Memory domain: displays a sequence of colored shapes, then hides them.
///
/// Shows each shape for a brief interval, then calls [onComplete]
/// when the display phase ends. The parent should then show
/// the answer options.
class SequenceDisplay extends StatefulWidget {
  const SequenceDisplay({
    super.key,
    required this.sequence,
    required this.displayDurationMs,
    required this.onComplete,
  });

  /// List of shape identifiers like 'red_circle', 'blue_square', etc.
  final List<String> sequence;

  /// Total display time in milliseconds.
  final int displayDurationMs;

  /// Called when the display phase is complete.
  final VoidCallback onComplete;

  @override
  State<SequenceDisplay> createState() => _SequenceDisplayState();
}

class _SequenceDisplayState extends State<SequenceDisplay> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(
      Duration(milliseconds: widget.displayDurationMs),
      widget.onComplete,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: widget.sequence.asMap().entries.map((entry) {
            final index = entry.key;
            final shape = entry.value;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimens.d8),
              child: _ShapeWidget(shape: shape)
                  .animate()
                  .fadeIn(
                    delay: Duration(milliseconds: index * 300),
                    duration: 400.ms,
                  )
                  .scale(
                    begin: const Offset(0.5, 0.5),
                    end: const Offset(1.0, 1.0),
                    delay: Duration(milliseconds: index * 300),
                    duration: 400.ms,
                  ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// Renders an individual shape+color combo based on its string identifier.
class _ShapeWidget extends StatelessWidget {
  const _ShapeWidget({required this.shape});

  final String shape;

  @override
  Widget build(BuildContext context) {
    final parts = shape.split('_');
    final colorName = parts.isNotEmpty ? parts[0] : 'red';
    final shapeName = parts.length > 1 ? parts[1] : 'circle';

    final color = _colorFromName(colorName);

    return SizedBox(
      width: AppDimens.d48,
      height: AppDimens.d48,
      child: CustomPaint(
        painter: _ShapePainter(color: color, shapeName: shapeName),
      ),
    );
  }

  Color _colorFromName(String name) {
    switch (name) {
      case 'red':
        return AppColors.error;
      case 'blue':
        return AppColors.primary;
      case 'green':
        return AppColors.success;
      case 'yellow':
        return AppColors.accentAmber;
      default:
        return AppColors.muted;
    }
  }
}

class _ShapePainter extends CustomPainter {
  _ShapePainter({required this.color, required this.shapeName});

  final Color color;
  final String shapeName;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    switch (shapeName) {
      case 'circle':
        canvas.drawCircle(
          Offset(size.width / 2, size.height / 2),
          size.width / 2,
          paint,
        );
        break;
      case 'square':
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(0, 0, size.width, size.height),
            Radius.circular(AppDimens.radiusXs),
          ),
          paint,
        );
        break;
      case 'triangle':
        final path = Path()
          ..moveTo(size.width / 2, 0)
          ..lineTo(size.width, size.height)
          ..lineTo(0, size.height)
          ..close();
        canvas.drawPath(path, paint);
        break;
      case 'star':
        _drawStar(canvas, size, paint);
        break;
      default:
        canvas.drawCircle(
          Offset(size.width / 2, size.height / 2),
          size.width / 2,
          paint,
        );
    }
  }

  void _drawStar(Canvas canvas, Size size, Paint paint) {
    final path = Path();
    final cx = size.width / 2;
    final cy = size.height / 2;
    final outerR = size.width / 2;
    final innerR = outerR * 0.4;

    for (int i = 0; i < 5; i++) {
      final outerAngle = (i * 72 - 90) * 3.14159 / 180;
      final innerAngle = ((i * 72) + 36 - 90) * 3.14159 / 180;

      if (i == 0) {
        path.moveTo(
          cx + outerR * _cos(outerAngle),
          cy + outerR * _sin(outerAngle),
        );
      } else {
        path.lineTo(
          cx + outerR * _cos(outerAngle),
          cy + outerR * _sin(outerAngle),
        );
      }
      path.lineTo(
        cx + innerR * _cos(innerAngle),
        cy + innerR * _sin(innerAngle),
      );
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  double _cos(double radians) => radians == 0 ? 1.0 : _mathCos(radians);
  double _sin(double radians) => radians == 0 ? 0.0 : _mathSin(radians);

  // Simple trig wrappers
  static double _mathCos(double r) {
    return r.abs() < 0.001 ? 1.0 : _taylorCos(r);
  }

  static double _mathSin(double r) {
    return r.abs() < 0.001 ? 0.0 : _taylorSin(r);
  }

  // We use dart:math indirectly via the cos/sin in the import
  static double _taylorCos(double x) {
    // Fallback to a reasonable approximation
    // In practice, dart:math is available
    double result = 1.0;
    double term = 1.0;
    for (int i = 1; i <= 10; i++) {
      term *= -x * x / ((2 * i - 1) * (2 * i));
      result += term;
    }
    return result;
  }

  static double _taylorSin(double x) {
    double result = x;
    double term = x;
    for (int i = 1; i <= 10; i++) {
      term *= -x * x / ((2 * i) * (2 * i + 1));
      result += term;
    }
    return result;
  }

  @override
  bool shouldRepaint(covariant _ShapePainter oldDelegate) =>
      color != oldDelegate.color || shapeName != oldDelegate.shapeName;
}

/// Renders a selectable sequence option (used for answer choices).
class SequenceOptionWidget extends StatelessWidget {
  const SequenceOptionWidget({
    super.key,
    required this.sequenceString,
    this.isSelected = false,
  });

  /// Comma-separated shape identifiers: "red_circle, blue_square"
  final String sequenceString;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final shapes =
        sequenceString.split(', ').map((s) => s.trim()).toList();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.d12,
        vertical: AppDimens.d8,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.hairline,
          width: isSelected ? 2.0 : 1.0,
        ),
        color: isSelected
            ? AppColors.primaryLight
            : AppColors.surfaceWhite,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: shapes
            .map((s) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: SizedBox(
                    width: AppDimens.d24,
                    height: AppDimens.d24,
                    child: _ShapeWidget(shape: s),
                  ),
                ))
            .toList(),
      ),
    );
  }
}
