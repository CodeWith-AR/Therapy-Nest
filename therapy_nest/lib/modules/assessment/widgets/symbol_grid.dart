import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_text_styles.dart';

/// Attention domain: grid of symbols where user finds and taps targets.
///
/// Highlights tapped targets and tracks found count. Calls [onTargetTapped]
/// each time the user taps a target symbol. Non-target taps are ignored
/// but show a brief shake feedback.
class SymbolGrid extends StatefulWidget {
  const SymbolGrid({
    super.key,
    required this.grid,
    required this.target,
    required this.gridCols,
    required this.onTargetTapped,
    required this.foundCount,
    required this.targetCount,
  });

  final List<String> grid;
  final String target;
  final int gridCols;
  final VoidCallback onTargetTapped;
  final int foundCount;
  final int targetCount;

  @override
  State<SymbolGrid> createState() => _SymbolGridState();
}

class _SymbolGridState extends State<SymbolGrid> {
  final Set<int> _tappedIndices = {};
  final Set<int> _wrongTapIndices = {};

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Target indicator
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.d16,
            vertical: AppDimens.d8,
          ),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(AppDimens.radiusFull),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Find: ',
                style: AppTextStyles.label.copyWith(color: AppColors.body),
              ),
              Text(
                widget.target,
                style: AppTextStyles.titleLg.copyWith(color: AppColors.primary),
              ),
              const SizedBox(width: AppDimens.d12),
              Text(
                '${widget.foundCount}/${widget.targetCount}',
                style: AppTextStyles.caption.copyWith(color: AppColors.muted),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimens.d16),
        // Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: widget.gridCols,
            crossAxisSpacing: AppDimens.d8,
            mainAxisSpacing: AppDimens.d8,
          ),
          itemCount: widget.grid.length,
          itemBuilder: (context, index) {
            final symbol = widget.grid[index];
            final isTarget = symbol == widget.target;
            final isTapped = _tappedIndices.contains(index);
            final isWrongTap = _wrongTapIndices.contains(index);

            return _SymbolCell(
              symbol: symbol,
              isTarget: isTarget,
              isTapped: isTapped,
              isWrongTap: isWrongTap,
              onTap: () => _handleTap(index, isTarget),
            );
          },
        ),
      ],
    );
  }

  void _handleTap(int index, bool isTarget) {
    if (_tappedIndices.contains(index)) return; // Already tapped

    if (isTarget) {
      setState(() {
        _tappedIndices.add(index);
      });
      widget.onTargetTapped();
    } else {
      // Wrong tap — brief visual feedback
      setState(() {
        _wrongTapIndices.add(index);
      });
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _wrongTapIndices.remove(index);
          });
        }
      });
    }
  }
}

class _SymbolCell extends StatelessWidget {
  const _SymbolCell({
    required this.symbol,
    required this.isTarget,
    required this.isTapped,
    required this.isWrongTap,
    required this.onTap,
  });

  final String symbol;
  final bool isTarget;
  final bool isTapped;
  final bool isWrongTap;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color borderColor;

    if (isTapped) {
      bgColor = AppColors.success.withValues(alpha: 0.15);
      borderColor = AppColors.success;
    } else if (isWrongTap) {
      bgColor = AppColors.error.withValues(alpha: 0.1);
      borderColor = AppColors.error.withValues(alpha: 0.4);
    } else {
      bgColor = AppColors.surfaceWhite;
      borderColor = AppColors.hairlineSoft;
    }

    Widget cell = Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(AppDimens.radiusSm),
      child: InkWell(
        onTap: isTapped ? null : onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusSm),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.radiusSm),
            border: Border.all(color: borderColor),
          ),
          alignment: Alignment.center,
          child: Text(
            symbol,
            style: AppTextStyles.displayMd.copyWith(
              color: isTapped ? AppColors.success : AppColors.ink,
            ),
          ),
        ),
      ),
    );

    if (isTapped) {
      cell = cell
          .animate()
          .scale(
            begin: const Offset(1.0, 1.0),
            end: const Offset(1.1, 1.1),
            duration: 150.ms,
          )
          .then()
          .scale(
            begin: const Offset(1.1, 1.1),
            end: const Offset(1.0, 1.0),
            duration: 150.ms,
          );
    }

    if (isWrongTap) {
      cell = cell.animate().shakeX(
            hz: 4,
            amount: 3,
            duration: 400.ms,
          );
    }

    return cell;
  }
}
