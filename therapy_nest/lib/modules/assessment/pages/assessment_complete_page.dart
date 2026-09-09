import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_toast.dart';
import '../viewmodels/assessment_view_model.dart';
import '../widgets/score_summary_card.dart';

/// Celebration + score summary page shown after assessment completion.
///
/// - Animated checkmark hero
/// - Per-domain score bars (friendly, visual — not numeric)
/// - Encouraging copy
/// - "Continue to Home" CTA
/// - Auto-saves results on load; retry available on failure
class AssessmentCompletePage extends StatefulWidget {
  const AssessmentCompletePage({super.key});

  @override
  State<AssessmentCompletePage> createState() => _AssessmentCompletePageState();
}

class _AssessmentCompletePageState extends State<AssessmentCompletePage> {
  bool _hasSaved = false;

  @override
  void initState() {
    super.initState();
    // Auto-save results when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _saveResults();
    });
  }

  Future<void> _saveResults() async {
    if (_hasSaved) return;
    _hasSaved = true;

    final vm = context.read<AssessmentViewModel>();
    await vm.saveResults();

    if (mounted) {
      if (vm.error != null) {
        AppToast.warning(context, 'Results saved locally. Will sync later.');
      } else {
        AppToast.success(context, 'Results saved successfully!');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AssessmentViewModel>();
    final results = vm.results;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.d24),
          child: Column(
            children: [
              const SizedBox(height: AppDimens.d32),

              // ── Celebration hero ──
              _CelebrationHero()
                  .animate()
                  .fadeIn(duration: 600.ms)
                  .scale(
                    begin: const Offset(0.6, 0.6),
                    end: const Offset(1.0, 1.0),
                    duration: 600.ms,
                    curve: Curves.easeOutBack,
                  ),

              const SizedBox(height: AppDimens.d24),

              // ── Title ──
              Text(
                AppStrings.assessmentCompleteTitle,
                style: AppTextStyles.displayMd.copyWith(color: AppColors.ink),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 300.ms, duration: 500.ms),

              const SizedBox(height: AppDimens.d8),

              Text(
                AppStrings.assessmentCompleteBody,
                style: AppTextStyles.bodyLg.copyWith(color: AppColors.body),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 500.ms, duration: 500.ms),

              const SizedBox(height: AppDimens.d24),

              // ── Results section ──
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  AppStrings.assessmentYourResults,
                  style:
                      AppTextStyles.titleSm.copyWith(color: AppColors.muted),
                ).animate().fadeIn(delay: 700.ms, duration: 400.ms),
              ),

              const SizedBox(height: AppDimens.d12),

              // ── Score cards ──
              Expanded(
                child: ListView.separated(
                  itemCount: results.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppDimens.d8),
                  itemBuilder: (context, index) {
                    return ScoreSummaryCard(result: results[index])
                        .animate()
                        .fadeIn(
                          delay: Duration(milliseconds: 800 + index * 100),
                          duration: 400.ms,
                        )
                        .slideY(
                          begin: 0.1,
                          end: 0,
                          delay: Duration(milliseconds: 800 + index * 100),
                          duration: 400.ms,
                        );
                  },
                ),
              ),

              const SizedBox(height: AppDimens.d16),

              // ── Save status / retry ──
              if (vm.isLoading)
                Padding(
                  padding:
                      const EdgeInsets.only(bottom: AppDimens.d8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: AppDimens.iconSm,
                        height: AppDimens.iconSm,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primary),
                        ),
                      ),
                      const SizedBox(width: AppDimens.d8),
                      Text(
                        'Saving results...',
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.muted),
                      ),
                    ],
                  ),
                ),

              if (vm.error != null && !vm.isLoading)
                Padding(
                  padding:
                      const EdgeInsets.only(bottom: AppDimens.d8),
                  child: AppButton(
                    label: AppStrings.retry,
                    variant: AppButtonVariant.outlined,
                    icon: Icons.refresh_rounded,
                    onPressed: () {
                      _hasSaved = false;
                      _saveResults();
                    },
                  ),
                ),

              // ── Continue button ──
              AppButton(
                label: AppStrings.assessmentCompleteAction,
                icon: Icons.arrow_forward_rounded,
                onPressed: () => context.go(AppRoutes.home),
              ),

              const SizedBox(height: AppDimens.d32),
            ],
          ),
        ),
      ),
    );
  }
}

/// Animated celebration circle with checkmark.
class _CelebrationHero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer ring
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.accentGreen.withValues(alpha: 0.3),
              width: 4,
            ),
          ),
        ),
        // Inner filled circle
        Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.accentGreen,
                AppColors.accentTeal,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.accentGreen.withValues(alpha: 0.3),
                blurRadius: AppDimens.d24,
                offset: const Offset(0, AppDimens.d8),
              ),
            ],
          ),
          child: const Icon(
            Icons.check_rounded,
            size: AppDimens.d48,
            color: AppColors.onPrimary,
          ),
        ),
        // Sparkle decorations
        Positioned(
          top: 5,
          right: 15,
          child: Icon(
            Icons.auto_awesome,
            size: AppDimens.iconSm,
            color: AppColors.accentAmber,
          )
              .animate(
                onPlay: (c) => c.repeat(),
              )
              .scale(
                begin: const Offset(0.8, 0.8),
                end: const Offset(1.2, 1.2),
                duration: 1200.ms,
              )
              .then()
              .scale(
                begin: const Offset(1.2, 1.2),
                end: const Offset(0.8, 0.8),
                duration: 1200.ms,
              ),
        ),
        Positioned(
          bottom: 8,
          left: 10,
          child: Icon(
            Icons.auto_awesome,
            size: AppDimens.iconSm,
            color: AppColors.accentPurple,
          )
              .animate(
                onPlay: (c) => c.repeat(),
              )
              .scale(
                begin: const Offset(1.0, 1.0),
                end: const Offset(1.3, 1.3),
                duration: 1400.ms,
              )
              .then()
              .scale(
                begin: const Offset(1.3, 1.3),
                end: const Offset(1.0, 1.0),
                duration: 1400.ms,
              ),
        ),
      ],
    );
  }
}
