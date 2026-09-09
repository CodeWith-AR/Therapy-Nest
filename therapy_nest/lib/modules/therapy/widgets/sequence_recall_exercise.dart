import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/exercise_item_model.dart';

/// Sequence recall exercise widget.
///
/// 1. Shows a sequence of colored shapes one at a time.
/// 2. After display phase, shows recall options.
/// 3. User selects the correct sequence order.
class SequenceRecallExercise extends StatefulWidget {
  const SequenceRecallExercise({
    super.key,
    required this.item,
    required this.onAnswer,
  });

  final ExerciseItemModel item;
  final void Function(String answer) onAnswer;

  @override
  State<SequenceRecallExercise> createState() => _SequenceRecallExerciseState();
}

class _SequenceRecallExerciseState extends State<SequenceRecallExercise> {
  bool _showingSequence = true;
  int _currentShapeIndex = 0;
  Timer? _displayTimer;
  String? _selectedOption;
  bool _answered = false;

  late final List<String> _sequence;
  late final int _displayTimeMs;
  late final List<String> _options;

  @override
  void initState() {
    super.initState();
    _parseStimulus();
    _startSequenceDisplay();
  }

  @override
  void didUpdateWidget(covariant SequenceRecallExercise oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.id != widget.item.id) {
      _displayTimer?.cancel();
      _selectedOption = null;
      _answered = false;
      _currentShapeIndex = 0;
      _showingSequence = true;
      _parseStimulus();
      _startSequenceDisplay();
    }
  }

  void _parseStimulus() {
    final stimulus = widget.item.stimulus;
    _sequence = List<String>.from(stimulus['sequence'] as List? ?? []);
    _displayTimeMs = (stimulus['displayTimeMs'] as int?) ?? 3000;
    _options = List<String>.from(stimulus['options'] as List? ?? []);
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
          // Brief pause after last shape, then show options
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
    return _buildRecallOptions();
  }

  Widget _buildSequenceDisplay() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Remember this sequence',
          style: AppTextStyles.titleMd.copyWith(color: AppColors.ink),
        ),
        const SizedBox(height: AppDimens.d32),

        // Show current shape
        if (_sequence.isNotEmpty && _currentShapeIndex < _sequence.length)
          _ShapeWidget(
            shapeName: _sequence[_currentShapeIndex],
            size: 80,
          ).animate(
            onComplete: (_) {},
          ).scale(
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

  Widget _buildRecallOptions() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'What was the sequence?',
          style: AppTextStyles.titleMd.copyWith(color: AppColors.ink),
          textAlign: TextAlign.center,
        ).animate().fadeIn(duration: 300.ms),
        const SizedBox(height: AppDimens.d24),

        ..._options.asMap().entries.map((entry) {
          final index = entry.key;
          final option = entry.value;
          final shapes = option.split(', ');
          final isSelected = _selectedOption == option;

          return Padding(
            padding: const EdgeInsets.only(bottom: AppDimens.d12),
            child: _SequenceOptionButton(
              shapes: shapes,
              isSelected: isSelected,
              isDisabled: _answered,
              onTap: () => _onOptionTap(option),
            ),
          ).animate().fadeIn(
                duration: 300.ms,
                delay: Duration(milliseconds: 100 + index * 80),
              );
        }),
      ],
    );
  }

  void _onOptionTap(String option) {
    if (_answered) return;
    setState(() {
      _selectedOption = option;
      _answered = true;
    });
    widget.onAnswer(option);
  }
}

/// Renders a colored shape based on its string name.
class _ShapeWidget extends StatelessWidget {
  const _ShapeWidget({
    required this.shapeName,
    this.size = 32,
  });

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
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
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
        return Icon(
          Icons.star_rounded,
          size: size,
          color: color,
        );
      default:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
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
      default:
        return AppColors.muted;
    }
  }
}

/// Triangle painter for shape rendering.
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

/// Option button for sequence recall — shows shapes inline.
class _SequenceOptionButton extends StatelessWidget {
  const _SequenceOptionButton({
    required this.shapes,
    required this.isSelected,
    required this.isDisabled,
    required this.onTap,
  });

  final List<String> shapes;
  final bool isSelected;
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
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.d16,
            vertical: AppDimens.d12,
          ),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryLight : AppColors.canvas,
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.hairline,
              width: isSelected ? 2.0 : 1.0,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: shapes.map((s) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppDimens.d4),
                child: _ShapeWidget(shapeName: s.trim(), size: 28),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
