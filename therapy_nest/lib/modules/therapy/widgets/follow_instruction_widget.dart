import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/exercise_item_model.dart';

/// 6D — Auditory Comprehension / Follow Instructions.
///
/// TTS speaks a command (e.g. "Touch the small red circle on the right").
/// Screen shows a grid of colored shapes. User taps the correct one(s).
///
/// Difficulty scales via command complexity (1-step → 3-step) and
/// spatial language (left/right/above/below).
///
/// Stimulus schema:
/// ```json
/// {
///   "instruction": "Touch the small red circle",
///   "shapes": [
///     {"type": "circle", "color": "red", "size": "small", "label": "A"},
///     {"type": "square", "color": "blue", "size": "large", "label": "B"},
///     ...
///   ],
///   "correctIndices": [0]
/// }
/// ```
class FollowInstructionWidget extends StatefulWidget {
  const FollowInstructionWidget({
    super.key,
    required this.item,
    required this.onAnswer,
  });

  final ExerciseItemModel item;
  final void Function(String answer) onAnswer;

  @override
  State<FollowInstructionWidget> createState() =>
      _FollowInstructionWidgetState();
}

class _FollowInstructionWidgetState extends State<FollowInstructionWidget> {
  _Phase _phase = _Phase.listening;
  bool _answered = false;
  bool _ttsAvailable = true;

  late FlutterTts _tts;
  late String _instruction;
  late List<Map<String, dynamic>> _shapes;
  late Set<int> _correctIndices;

  final Set<int> _tappedIndices = {};

  @override
  void initState() {
    super.initState();
    _tts = FlutterTts();
    _parseStimulus();
    _speakInstruction();
  }

  @override
  void didUpdateWidget(covariant FollowInstructionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.id != widget.item.id) {
      _tts.stop();
      _phase = _Phase.listening;
      _answered = false;
      _tappedIndices.clear();
      _parseStimulus();
      _speakInstruction();
    }
  }

  void _parseStimulus() {
    final stimulus = widget.item.stimulus;
    _instruction = (stimulus['instruction'] as String?) ?? '';
    final rawShapes = (stimulus['shapes'] as List?) ?? [];
    _shapes = rawShapes
        .map((s) => Map<String, dynamic>.from(s as Map))
        .toList();
    final rawCorrect = (stimulus['correctIndices'] as List?) ?? [];
    _correctIndices = rawCorrect.map((e) => e as int).toSet();
  }

  Future<void> _speakInstruction() async {
    try {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.45);
      await _tts.setPitch(1.0);

      _tts.setCompletionHandler(() {
        if (mounted) {
          setState(() => _phase = _Phase.tapping);
        }
      });

      await _tts.speak(_instruction);
    } catch (_) {
      // TTS unavailable — fall back to text
      _ttsAvailable = false;
      if (mounted) {
        setState(() => _phase = _Phase.tapping);
      }
    }
  }

  void _replayInstruction() {
    _tts.speak(_instruction);
  }

  void _onShapeTap(int index) {
    if (_answered || _phase != _Phase.tapping) return;

    setState(() {
      if (_tappedIndices.contains(index)) {
        _tappedIndices.remove(index);
      } else {
        _tappedIndices.add(index);
      }
    });
  }

  void _submitAnswer() {
    if (_answered) return;

    setState(() {
      _answered = true;
      _phase = _Phase.result;
    });

    final hits = _tappedIndices.intersection(_correctIndices).length;
    widget.onAnswer('$hits/${_correctIndices.length}');
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (_phase) {
      case _Phase.listening:
        return _buildListening();
      case _Phase.tapping:
        return _buildTapping();
      case _Phase.result:
        return _buildResult();
    }
  }

  // ── Listening ──────────────────────────────────────────────────────

  Widget _buildListening() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.hearing_rounded,
          size: AppDimens.iconXl,
          color: AppColors.info,
        ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
              begin: const Offset(1, 1),
              end: const Offset(1.15, 1.15),
              duration: 800.ms,
            ),
        const SizedBox(height: AppDimens.d20),
        Text(
          'Listen carefully…',
          style: AppTextStyles.titleLg.copyWith(color: AppColors.ink),
        ),
        const SizedBox(height: AppDimens.d12),
        if (!_ttsAvailable)
          Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppDimens.d16),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                ),
                child: Text(
                  _instruction,
                  style:
                      AppTextStyles.bodyLg.copyWith(color: AppColors.bodyStrong),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: AppDimens.d16),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => setState(() => _phase = _Phase.tapping),
                  borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                  child: Container(
                    height: AppDimens.touchSmall,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppDimens.d32),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                    ),
                    child: Text(
                      'Ready',
                      style: AppTextStyles.button.copyWith(
                          color: AppColors.onPrimary),
                    ),
                  ),
                ),
              ),
            ],
          )
        else
          Text(
            'The instruction is being spoken…',
            style: AppTextStyles.bodySm.copyWith(color: AppColors.muted),
          ),
      ],
    );
  }

  // ── Tapping ────────────────────────────────────────────────────────

  Widget _buildTapping() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Replay button + instruction text fallback
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _replayInstruction,
                borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                child: Container(
                  width: AppDimens.d40,
                  height: AppDimens.d40,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.volume_up_rounded,
                    size: AppDimens.iconSm,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppDimens.d12),
            Flexible(
              child: Text(
                'Tap the correct shape(s)',
                style: AppTextStyles.titleSm.copyWith(color: AppColors.body),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimens.d20),

        // Shapes grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _shapes.length <= 4 ? 2 : 3,
            mainAxisSpacing: AppDimens.d12,
            crossAxisSpacing: AppDimens.d12,
          ),
          itemCount: _shapes.length,
          itemBuilder: (context, index) {
            final shape = _shapes[index];
            final isSelected = _tappedIndices.contains(index);

            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _onShapeTap(index),
                borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryLight
                        : AppColors.surfaceWhite,
                    borderRadius:
                        BorderRadius.circular(AppDimens.radiusMd),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.hairline,
                      width: isSelected ? 2.5 : 1.0,
                    ),
                  ),
                  child: Center(
                    child: _ShapeIcon(shape: shape),
                  ),
                ),
              ),
            ).animate().fadeIn(
                  duration: 200.ms,
                  delay: Duration(milliseconds: 40 * index),
                );
          },
        ),
        const SizedBox(height: AppDimens.d20),

        // Submit button
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _tappedIndices.isNotEmpty ? _submitAnswer : null,
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            child: Container(
              width: double.infinity,
              height: AppDimens.touchSmall,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _tappedIndices.isNotEmpty
                    ? AppColors.primary
                    : AppColors.primaryDisabled,
                borderRadius: BorderRadius.circular(AppDimens.radiusMd),
              ),
              child: Text(
                'Submit',
                style:
                    AppTextStyles.button.copyWith(color: AppColors.onPrimary),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Result ─────────────────────────────────────────────────────────

  Widget _buildResult() {
    final hits = _tappedIndices.intersection(_correctIndices).length;
    final falseAlarms =
        _tappedIndices.difference(_correctIndices).length;
    final perfect = hits == _correctIndices.length && falseAlarms == 0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          perfect
              ? Icons.check_circle_rounded
              : Icons.info_outline_rounded,
          size: AppDimens.iconXl,
          color: perfect ? AppColors.success : AppColors.warning,
        ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
        const SizedBox(height: AppDimens.d16),
        Text(
          perfect ? 'Perfect!' : 'Results',
          style: AppTextStyles.titleLg.copyWith(color: AppColors.ink),
        ),
        const SizedBox(height: AppDimens.d12),
        _ResultRow(
            label: 'Correct taps',
            value: '$hits / ${_correctIndices.length}'),
        if (falseAlarms > 0)
          _ResultRow(label: 'Incorrect taps', value: '$falseAlarms'),
      ],
    ).animate().fadeIn(duration: 400.ms);
  }
}

// ── Shape rendering ──────────────────────────────────────────────────

class _ShapeIcon extends StatelessWidget {
  const _ShapeIcon({required this.shape});
  final Map<String, dynamic> shape;

  @override
  Widget build(BuildContext context) {
    final type = (shape['type'] as String?) ?? 'circle';
    final colorStr = (shape['color'] as String?) ?? 'red';
    final sizeStr = (shape['size'] as String?) ?? 'medium';
    final label = (shape['label'] as String?) ?? '';

    final color = _colorFromString(colorStr);
    final dimension = _dimensionFromSize(sizeStr);

    Widget shapeWidget;
    switch (type) {
      case 'square':
        shapeWidget = Container(
          width: dimension,
          height: dimension,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppDimens.radiusXs),
          ),
        );
        break;
      case 'triangle':
        shapeWidget = CustomPaint(
          size: Size(dimension, dimension),
          painter: _TrianglePainter(color: color),
        );
        break;
      case 'star':
        shapeWidget = Icon(
          Icons.star_rounded,
          size: dimension,
          color: color,
        );
        break;
      case 'circle':
      default:
        shapeWidget = Container(
          width: dimension,
          height: dimension,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        shapeWidget,
        if (label.isNotEmpty) ...[
          const SizedBox(height: AppDimens.d4),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(color: AppColors.muted),
          ),
        ],
      ],
    );
  }

  static Color _colorFromString(String c) {
    switch (c.toLowerCase()) {
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
      case 'orange':
        return AppColors.warning;
      default:
        return AppColors.body;
    }
  }

  static double _dimensionFromSize(String s) {
    switch (s.toLowerCase()) {
      case 'small':
        return AppDimens.d24;
      case 'large':
        return AppDimens.d48;
      case 'medium':
      default:
        return AppDimens.d32;
    }
  }
}

class _TrianglePainter extends CustomPainter {
  const _TrianglePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TrianglePainter old) => old.color != color;
}

// ── Shared helpers ──────────────────────────────────────────────────

class _ResultRow extends StatelessWidget {
  const _ResultRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimens.d4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$label: ',
            style: AppTextStyles.bodyMd.copyWith(color: AppColors.body),
          ),
          Text(
            value,
            style: AppTextStyles.titleSm.copyWith(color: AppColors.ink),
          ),
        ],
      ),
    );
  }
}

enum _Phase { listening, tapping, result }
