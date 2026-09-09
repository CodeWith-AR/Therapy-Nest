import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/assessment_item_model.dart';

/// White card that renders the stimulus content based on task type.
///
/// Adapts its display for different modalities:
/// - multipleChoice / auditoryChoice: Large icon + label
/// - numberRecognition: Large text display
/// - sequenceRecall / symbolSearch: handled by dedicated widgets
class StimulusCard extends StatelessWidget {
  const StimulusCard({
    super.key,
    required this.item,
  });

  final AssessmentItemModel item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimens.d32),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.06),
            blurRadius: AppDimens.d16,
            offset: const Offset(0, AppDimens.d4),
          ),
        ],
      ),
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    switch (item.taskType) {
      case AssessmentTaskType.multipleChoice:
        return _buildIconStimulus(context);
      case AssessmentTaskType.auditoryChoice:
        return _buildAuditoryStimulus(context);
      case AssessmentTaskType.numberRecognition:
        return _buildNumberStimulus(context);
      case AssessmentTaskType.sequenceRecall:
      case AssessmentTaskType.symbolSearch:
      case AssessmentTaskType.speechRepetition:
        // These task types use dedicated widgets, this is fallback.
        return _buildGenericStimulus(context);
    }
  }

  Widget _buildIconStimulus(BuildContext context) {
    final iconCode = item.stimulus['icon'] as int?;
    final label = item.stimulus['label'] as String? ?? '';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (iconCode != null)
          Icon(
            IconData(iconCode, fontFamily: 'MaterialIcons'),
            size: AppDimens.d96,
            color: AppColors.primary,
          ),
        const SizedBox(height: AppDimens.d24),
        Text(
          label,
          style: AppTextStyles.titleLg.copyWith(color: AppColors.ink),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildAuditoryStimulus(BuildContext context) {
    final label = item.stimulus['label'] as String? ?? '';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: AppDimens.d96,
          height: AppDimens.d96,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.volume_up_rounded,
            size: AppDimens.iconXl,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: AppDimens.d24),
        Text(
          label,
          style: AppTextStyles.titleLg.copyWith(color: AppColors.ink),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimens.d8),
        Text(
          'Tap speaker to replay',
          style: AppTextStyles.bodySm.copyWith(color: AppColors.muted),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildNumberStimulus(BuildContext context) {
    final display = item.stimulus['display'] as String? ?? '';
    final label = item.stimulus['label'] as String? ?? '';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          display,
          style: AppTextStyles.displayXl.copyWith(
            color: AppColors.ink,
            fontSize: display.length > 3 ? 36 : 64,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimens.d24),
        Text(
          label,
          style: AppTextStyles.titleLg.copyWith(color: AppColors.ink),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildGenericStimulus(BuildContext context) {
    final label = item.stimulus['label'] as String? ?? item.domain;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.quiz_rounded,
          size: AppDimens.d64,
          color: AppColors.primary,
        ),
        const SizedBox(height: AppDimens.d16),
        Text(
          label,
          style: AppTextStyles.titleLg.copyWith(color: AppColors.ink),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
