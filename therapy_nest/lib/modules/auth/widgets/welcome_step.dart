import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_toast.dart';
import '../viewmodels/onboarding_view_model.dart';

/// Redesigned Onboarding Step 5 — Welcome summary + "Start your first session" CTA.
/// Displays a static celebration card, plan summary badges, and final action buttons.
class WelcomeStep extends StatelessWidget {
  const WelcomeStep({super.key});

  static const Map<String, String> _goalLabels = {
    'speaking': 'Speaking more clearly',
    'understanding': 'Understanding conversations',
    'reading': 'Reading and writing',
    'memory': 'Memory and focus',
    'math': 'Everyday math (money, time)',
    'problem_solving': 'Problem solving',
  };

  static const Map<String, String> _conditionLabels = {
    'stroke': 'Stroke Survivor',
    'aphasia': 'Aphasia',
    'tbi': 'Traumatic Brain Injury (TBI)',
    'dementia': 'Dementia / Memory Concerns',
    'parkinsons': 'Parkinson\'s Disease',
    'other': 'Other / Prefer Not to Say',
  };

  static const Map<String, IconData> _conditionIcons = {
    'stroke': Icons.psychology_rounded,
    'aphasia': Icons.record_voice_over_rounded,
    'tbi': Icons.psychology_rounded,
    'dementia': Icons.memory_rounded,
    'parkinsons': Icons.accessibility_new_rounded,
    'other': Icons.more_horiz_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OnboardingViewModel>();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.d24, vertical: AppDimens.d8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Celebration Card ──────────────────────────────────────
          AspectRatio(
            aspectRatio: 4 / 3,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: const EdgeInsets.all(AppDimens.d20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Badge circular base
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceWhite,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.verified_rounded,
                        size: 48,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: AppDimens.d16),
                    Text(
                      'Your personalized plan is ready!',
                      style: AppTextStyles.displayMd.copyWith(
                        color: AppColors.ink,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppDimens.d20),

          // ── Plan Summary Card ──────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(AppDimens.d20),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.hairlineSoft),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    Icon(Icons.analytics_rounded, color: AppColors.primary),
                    const SizedBox(width: AppDimens.d8),
                    Text(
                      'Your Plan Summary',
                      style: AppTextStyles.titleLg.copyWith(
                        color: AppColors.ink,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.d12),
                Container(height: 1, color: AppColors.hairlineSoft),
                const SizedBox(height: AppDimens.d16),

                // Focus Areas Section
                _buildSectionLabel('Focus Areas'),
                const SizedBox(height: AppDimens.d8),
                if (vm.conditions.isEmpty)
                  _buildEmptyChip('No focus areas selected')
                else
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: vm.conditions.map((code) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSoft,
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(color: AppColors.hairlineSoft),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _conditionIcons[code] ?? Icons.psychology_rounded,
                              size: 14,
                              color: AppColors.accentTeal,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              _conditionLabels[code] ?? code,
                              style: AppTextStyles.bodySm.copyWith(
                                color: AppColors.ink,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                const SizedBox(height: AppDimens.d16),

                // Goals Section
                _buildSectionLabel('Goals'),
                const SizedBox(height: AppDimens.d8),
                if (vm.goals.isEmpty)
                  _buildEmptyChip('No specific goals selected')
                else
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: vm.goals.map((goal) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.flag_rounded,
                              size: 14,
                              color: AppColors.onPrimary,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              _goalLabels[goal] ?? goal,
                              style: AppTextStyles.bodySm.copyWith(
                                color: AppColors.onPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                const SizedBox(height: AppDimens.d16),

                // Recommended Schedule Section
                _buildSectionLabel('Recommended Schedule'),
                const SizedBox(height: AppDimens.d8),
                Container(
                  padding: const EdgeInsets.all(AppDimens.d12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSoft,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.hairlineSoft),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.calendar_month_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _formatFrequency(vm.sessionsPerWeek),
                              style: AppTextStyles.bodyMd.copyWith(
                                color: AppColors.ink,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _formatDuration(vm.minutesPerSession),
                              style: AppTextStyles.bodySm.copyWith(
                                color: AppColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.d24),

          // ── Action Buttons ─────────────────────────────────────────
          SizedBox(
            height: 60,
            child: ElevatedButton(
              onPressed: vm.isLoading ? null : () => _completeAndNavigate(context, vm),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: vm.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Start Your First Session',
                          style: AppTextStyles.button.copyWith(color: AppColors.onPrimary),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded, size: 20),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: AppDimens.d24),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.d8),
      child: Text(
        text.toUpperCase(),
        style: AppTextStyles.caption.copyWith(
          color: AppColors.muted,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildEmptyChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        text,
        style: AppTextStyles.bodySm.copyWith(color: AppColors.muted),
      ),
    );
  }

  static String _formatFrequency(int sessions) {
    return switch (sessions) {
      7 => 'Every day',
      5 => '5 days a week',
      3 => '3 days a week',
      _ => 'Whenever you can',
    };
  }

  static String _formatDuration(int minutes) {
    return switch (minutes) {
      10 => '10 minutes per session',
      20 => '20 minutes per session',
      30 => '30 minutes per session',
      _ => 'Flexible session length',
    };
  }

  Future<void> _completeAndNavigate(BuildContext context, OnboardingViewModel vm) async {
    final success = await vm.completeOnboarding();
    if (context.mounted) {
      if (success) {
        context.go(AppRoutes.assessment);
      } else if (vm.error != null) {
        AppToast.error(context, vm.error!.message);
      }
    }
  }
}
