import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';

/// Intro page explaining what the baseline assessment is and why it matters.
///
/// Friendly hero, estimated time, and a primary "Begin Assessment" CTA.
class AssessmentIntroPage extends StatelessWidget {
  const AssessmentIntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: AppColors.ink),
          tooltip: 'Back to Home',
          onPressed: () => context.go(AppRoutes.home),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.d24),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // ── Hero illustration ──
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.psychology_rounded,
                  size: AppDimens.d64,
                  color: AppColors.primary,
                ),
              )
                  .animate()
                  .fadeIn(duration: 600.ms)
                  .scale(
                    begin: const Offset(0.8, 0.8),
                    end: const Offset(1.0, 1.0),
                    duration: 600.ms,
                    curve: Curves.easeOutBack,
                  ),

              const SizedBox(height: AppDimens.d32),

              // ── Title ──
              Text(
                AppStrings.assessmentIntroTitle,
                style: AppTextStyles.displayMd.copyWith(color: AppColors.ink),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 200.ms, duration: 500.ms),

              const SizedBox(height: AppDimens.d16),

              // ── Body ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppDimens.d8),
                child: Text(
                  AppStrings.assessmentIntroBody,
                  style: AppTextStyles.bodyLg.copyWith(color: AppColors.body),
                  textAlign: TextAlign.center,
                ),
              ).animate().fadeIn(delay: 400.ms, duration: 500.ms),

              const SizedBox(height: AppDimens.d24),

              // ── Time badge ──
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.d16,
                  vertical: AppDimens.d8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accentTeal.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.timer_rounded,
                      size: AppDimens.iconSm,
                      color: AppColors.accentTeal,
                    ),
                    const SizedBox(width: AppDimens.d8),
                    Text(
                      AppStrings.assessmentIntroTime,
                      style: AppTextStyles.label
                          .copyWith(color: AppColors.accentTeal),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 600.ms, duration: 500.ms),

              const Spacer(flex: 1),

              // ── Domain preview chips ──
              Wrap(
                spacing: AppDimens.d8,
                runSpacing: AppDimens.d8,
                alignment: WrapAlignment.center,
                children: const [
                  _DomainChip(
                      icon: Icons.translate_rounded,
                      label: AppStrings.domainLanguage),
                  _DomainChip(
                      icon: Icons.auto_stories_rounded,
                      label: AppStrings.domainReadingWriting),
                  _DomainChip(
                      icon: Icons.psychology_rounded,
                      label: AppStrings.domainMemory),
                  _DomainChip(
                      icon: Icons.center_focus_strong_rounded,
                      label: AppStrings.domainAttention),
                  _DomainChip(
                      icon: Icons.mic_rounded,
                      label: AppStrings.domainSpeech),
                  _DomainChip(
                      icon: Icons.calculate_rounded,
                      label: AppStrings.domainMath),
                ],
              ).animate().fadeIn(delay: 800.ms, duration: 500.ms),

              const Spacer(flex: 2),

              // ── Begin button ──
              AppButton(
                label: AppStrings.assessmentIntroStart,
                icon: Icons.play_arrow_rounded,
                onPressed: () =>
                    context.go(AppRoutes.assessmentExercise),
              ).animate().fadeIn(delay: 1000.ms, duration: 500.ms),

              const SizedBox(height: AppDimens.d32),
            ],
          ),
        ),
      ),
    );
  }
}

class _DomainChip extends StatelessWidget {
  const _DomainChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.d12,
        vertical: AppDimens.d8,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(AppDimens.radiusFull),
        border: Border.all(color: AppColors.hairlineSoft),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppDimens.iconSm, color: AppColors.primary),
          const SizedBox(width: AppDimens.d4),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(color: AppColors.body),
          ),
        ],
      ),
    );
  }
}
