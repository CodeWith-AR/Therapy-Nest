import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/exercise_item_model.dart';

/// Visual sequence memory exercise — grid-tap recall variant.
///
/// 1. Shows a sequence of colored shapes one at a time for [displayTimeMs].
/// 2. After display, presents all shapes on a grid.
/// 3. User taps shapes in the correct order to recall the sequence.
class VisualSequenceWidget extends StatefulWidget {
  const VisualSequenceWidget({
    super.key,
    required this.item,
    required this.onAnswer,
  });

  final ExerciseItemModel item;
  final void Function(String answer) onAnswer;

  @override
  State<VisualSequenceWidget> createState() => _VisualSequenceWidgetState();
}

class _VisualSequenceWidgetState extends State<VisualSequenceWidget> {
  bool _showingSequence = true;
  int _currentShapeIndex = 0;
  Timer? _displayTimer;
  bool _answered = false;

  late List<String> _sequence;
  late int _displayTimeMs;
  late List<String> _gridShapes;
  final List<String> _tappedOrder = [];

  @override
  void initState() {
    super.initState();
    _parseStimulus();
    _startSequenceDisplay();
  }

  @override
  void didUpdateWidget(covariant VisualSequenceWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.id != widget.item.id) {
      _displayTimer?.cancel();
      _answered = false;
      _currentShapeIndex = 0;
      _showingSequence = true;
      _tappedOrder.clear();
      _parseStimulus();
      _startSequenceDisplay();
    }
  }

  void _parseStimulus() {
    final stimulus = widget.item.stimulus;
    _sequence = List<String>.from(stimulus['sequence'] as List? ?? []);
    _displayTimeMs = (stimulus['displayTimeMs'] as int?) ?? 3000;
    // Grid shows all shapes from the sequence (shuffled) for tap-recall
    _gridShapes = List<String>.from(_sequence)..shuffle();
  }

  void _startSequenceDisplay() {
    if (_sequence.isEmpty) {
      setState(() => _showingSequence = false);
      return;
    }

    final perItemMs = _displayTimeMs ~/ _sequence.length;

    _displayTimer = Timer.periodic(
      Duration(milliseconds: perItemMs),
      (timer) {
        if (_currentShapeIndex >= _sequence.length - 1) {
          timer.cancel();
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              setState(() => _showingSequence = false);
            }
          });
        } else {
          setState(() => _currentShapeIndex++);
        }
      },
    );
  }

  @override
  void dispose() {
    _displayTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_showingSequence) {
      return _buildSequenceDisplay();
    }
    return _buildGridRecall();
  }

  Widget _buildSequenceDisplay() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Watch the sequence carefully',
          style: AppTextStyles.titleMd.copyWith(color: AppColors.ink),
        ),
        const SizedBox(height: AppDimens.d32),
        if (_sequence.isNotEmpty && _currentShapeIndex < _sequence.length)
          _ShapeIcon(
            shapeName: _sequence[_currentShapeIndex],
            size: AppDimens.d96,
          ).animate().scale(
                duration: 300.ms,
                curve: Curves.easeOutBack,
              ),
        const SizedBox(height: AppDimens.d24),
        // Progress dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_sequence.length, (i) {
            return Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.symmetric(horizontal: AppDimens.d4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i <= _currentShapeIndex
                    ? AppColors.primary
                    : AppColors.hairline,
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildGridRecall() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Tap the shapes in the correct order',
          style: AppTextStyles.titleMd.copyWith(color: AppColors.ink),
          textAlign: TextAlign.center,
        ).animate().fadeIn(duration: 300.ms),
        const SizedBox(height: AppDimens.d12),

        // Show tapped order so far
        if (_tappedOrder.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.d12,
              vertical: AppDimens.d8,
            ),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Your order: ',
                  style: AppTextStyles.caption.copyWith(color: AppColors.body),
                ),
                ..._tappedOrder.map((s) => Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppDimens.d4),
                      child: _ShapeIcon(shapeName: s, size: AppDimens.iconMd),
                    )),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.d16),
        ],

        // Grid of shapes to tap
        Wrap(
          alignment: WrapAlignment.center,
          spacing: AppDimens.d12,
          runSpacing: AppDimens.d12,
          children: _gridShapes.asMap().entries.map((entry) {
            final index = entry.key;
            final shape = entry.value;
            // Track which grid indices have been tapped
            final tappedIndices = <int>[];
            for (var i = 0; i < _tappedOrder.length; i++) {
              for (var gi = 0; gi < _gridShapes.length; gi++) {
                if (_gridShapes[gi] == _tappedOrder[i] &&
                    !tappedIndices.contains(gi)) {
                  tappedIndices.add(gi);
                  break;
                }
              }
            }
            final isTapped = tappedIndices.contains(index);

            return _GridShapeButton(
              shapeName: shape,
              isTapped: isTapped,
              isDisabled: _answered || isTapped,
              onTap: () => _onShapeTap(shape),
            ).animate().fadeIn(
                  duration: 300.ms,
                  delay: Duration(milliseconds: 50 + index * 60),
                );
          }).toList(),
        ),
      ],
    );
  }

  void _onShapeTap(String shape) {
    if (_answered) return;
    setState(() {
      _tappedOrder.add(shape);
    });

    // Check if all shapes have been tapped
    if (_tappedOrder.length >= _sequence.length) {
      setState(() => _answered = true);
      final answer = _tappedOrder.join(', ');
      widget.onAnswer(answer);
    }
  }
}

// ── Shared shape rendering helpers ──────────────────────────────────

class _ShapeIcon extends StatelessWidget {
  const _ShapeIcon({required this.shapeName, this.size = 32});

  final String shapeName;
  final double size;

  @override
  Widget build(BuildContext context) {
    final parts = shapeName.split('_');
    final colorName = parts.isNotEmpty ? parts[0] : 'gray';
    final shape = parts.length > 1 ? parts[1] : 'circle';
    final color = _getColor(colorName);

    switch (shape) {
      case 'circle':
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        );
      case 'square':
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(size * 0.15),
          ),
        );
      case 'triangle':
        return CustomPaint(
          size: Size(size, size),
          painter: _TrianglePainter(color: color),
        );
      case 'star':
        return Icon(Icons.star_rounded, size: size, color: color);
      default:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        );
    }
  }

  Color _getColor(String name) {
    switch (name) {
      case 'red':
        return AppColors.error;
      case 'blue':
        return AppColors.primary;
      case 'green':
        return AppColors.success;
      case 'yellow':
        return AppColors.accentAmber;
      case 'purple':
        return AppColors.accentPurple;
      case 'teal':
        return AppColors.accentTeal;
      default:
        return AppColors.muted;
    }
  }
}

class _TrianglePainter extends CustomPainter {
  _TrianglePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GridShapeButton extends StatelessWidget {
  const _GridShapeButton({
    required this.shapeName,
    required this.isTapped,
    required this.isDisabled,
    required this.onTap,
  });

  final String shapeName;
  final bool isTapped;
  final bool isDisabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isDisabled ? null : onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: AppDimens.touchMin,
          height: AppDimens.touchMin,
          decoration: BoxDecoration(
            color: isTapped
                ? AppColors.surfaceSoft
                : AppColors.canvas,
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            border: Border.all(
              color: isTapped ? AppColors.primary : AppColors.hairline,
              width: isTapped ? 2.0 : 1.0,
            ),
          ),
          child: Center(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: isTapped ? 0.3 : 1.0,
              child: _ShapeIcon(
                shapeName: shapeName,
                size: AppDimens.iconLg,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
