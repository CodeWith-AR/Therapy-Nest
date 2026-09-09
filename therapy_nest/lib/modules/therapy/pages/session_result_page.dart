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
import '../../../core/widgets/celebration_overlay.dart';
import '../../../modules/progress/viewmodels/progress_view_model.dart';
import '../../../modules/settings/viewmodels/accessibility_view_model.dart';
import '../viewmodels/therapy_session_view_model.dart';

/// Session results page — displays completion summary with stats.
///
/// Route: `/therapy/session/result`
///
/// If the session unlocked any achievements (Module 14), shows a
/// [CelebrationOverlay] on top, cycling through each badge.
class SessionResultPage extends StatefulWidget {
  const SessionResultPage({super.key});

  @override
  State<SessionResultPage> createState() => _SessionResultPageState();
}

class _SessionResultPageState extends State<SessionResultPage> {
  /// Index into the newly unlocked achievements being displayed.
  int _celebrationIndex = 0;

  /// Whether the celebration overlay is currently visible.
  bool _showCelebration = false;

  @override
  void initState() {
    super.initState();
    // Refresh dashboard data and show celebration overlay after frame renders
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      try {
        context.read<ProgressViewModel>().loadDashboard();
      } catch (_) {}
      final vm = context.read<TherapySessionViewModel>();
      if (vm.newlyUnlocked.isNotEmpty) {
        setState(() {
          _showCelebration = true;
          _celebrationIndex = 0;
        });
      }
    });
  }

  void _dismissCelebration() {
    final vm = context.read<TherapySessionViewModel>();
    if (_celebrationIndex < vm.newlyUnlocked.length - 1) {
      // Show next achievement
      setState(() => _celebrationIndex++);
    } else {
      // All shown — dismiss overlay
      setState(() => _showCelebration = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TherapySessionViewModel>();
    final summary = vm.sessionSummary;
    final reduceMotion =
        context.select<AccessibilityViewModel, bool>((a) => a.reduceMotion);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Stack(
        children: [
          // ── Main Content ───────────────────────────────────────
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimens.d24),
              child: Column(
                children: [
                  const SizedBox(height: AppDimens.d24),

                  // ── Celebration Header ──────────────────────────
                  _CelebrationHeader(
                      accuracyPercent: summary.accuracyPercent),
                  const SizedBox(height: AppDimens.d32),

                  // ── Stats Cards ─────────────────────────────────
                  _StatsSummary(
                    totalItems: summary.totalItems,
                    correctCount: summary.correctCount,
                    accuracyPercent: summary.accuracyPercent,
                    duration: summary.formattedDuration,
                    longestStreak: summary.longestStreak,
                  ),
                  const SizedBox(height: AppDimens.d24),

                  // ── Per-Domain θ Changes ────────────────────────
                  if (summary.thetaChanges.isNotEmpty) ...[
                    _DomainThetaSection(
                        thetaChanges: summary.thetaChanges),
                    const SizedBox(height: AppDimens.d24),
                  ],

                  // ── Motivational Copy ───────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppDimens.d20),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius:
                          BorderRadius.circular(AppDimens.radiusMd),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.emoji_events_rounded,
                          size: AppDimens.iconXl,
                          color: AppColors.accentAmber,
                        ),
                        const SizedBox(height: AppDimens.d8),
                        Text(
                          AppStrings.therapySessionMotivational,
                          style: AppTextStyles.bodyMd.copyWith(
                            color: AppColors.primaryDark,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 500.ms, delay: 400.ms),
                  const SizedBox(height: AppDimens.d32),

                  // ── Action Buttons ──────────────────────────────
                  AppButton(
                    label: AppStrings.therapyContinuePracticing,
                    onPressed: () {
                      context.read<TherapySessionViewModel>().reset();
                      try {
                        context.read<ProgressViewModel>().loadDashboard();
                      } catch (_) {}
                      context.go(AppRoutes.domainSelect);
                    },
                  ),
                  const SizedBox(height: AppDimens.d12),
                  TextButton(
                    onPressed: () {
                      context.read<TherapySessionViewModel>().reset();
                      try {
                        context.read<ProgressViewModel>().loadDashboard();
                      } catch (_) {}
                      context.go(AppRoutes.home);
                    },
                    child: Text(
                      AppStrings.therapyGoHome,
                      style: AppTextStyles.buttonSm.copyWith(
                        color: AppColors.muted,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimens.d16),
                ],
              ),
            ),
          ),

          // ── Achievement Celebration Overlay (Module 14) ────────
          if (_showCelebration &&
              _celebrationIndex < vm.newlyUnlocked.length)
            CelebrationOverlay(
              achievement: vm.newlyUnlocked[_celebrationIndex],
              onDismiss: _dismissCelebration,
              reduceMotion: reduceMotion,
            ),
        ],
      ),
    );
  }
}

/// Celebration header with icon and title based on accuracy.
class _CelebrationHeader extends StatelessWidget {
  const _CelebrationHeader({required this.accuracyPercent});
  final double accuracyPercent;

  @override
  Widget build(BuildContext context) {
    final isGreat = accuracyPercent >= 80;
    final isGood = accuracyPercent >= 60;

    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: isGreat
                ? AppColors.success.withValues(alpha: 0.15)
                : isGood
                    ? AppColors.accentAmber.withValues(alpha: 0.15)
                    : AppColors.primaryLight,
            shape: BoxShape.circle,
          ),
          child: Icon(
            isGreat
                ? Icons.celebration_rounded
                : isGood
                    ? Icons.star_rounded
                    : Icons.thumb_up_rounded,
            size: 48,
            color: isGreat
                ? AppColors.success
                : isGood
                    ? AppColors.accentAmber
                    : AppColors.primary,
          ),
        )
            .animate()
            .scale(duration: 500.ms, curve: Curves.easeOutBack)
            .then()
            .shimmer(
              duration: 800.ms,
              color: AppColors.surfaceWhite.withValues(alpha: 0.3),
            ),
        const SizedBox(height: AppDimens.d16),
        Text(
          isGreat
              ? AppStrings.therapyResultGreat
              : isGood
                  ? AppStrings.therapyResultGood
                  : AppStrings.therapyResultKeepGoing,
          style: AppTextStyles.displaySm.copyWith(color: AppColors.ink),
          textAlign: TextAlign.center,
        ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
      ],
    );
  }
}

/// Stats summary grid: items, accuracy, time, streak.
class _StatsSummary extends StatelessWidget {
  const _StatsSummary({
    required this.totalItems,
    required this.correctCount,
    required this.accuracyPercent,
    required this.duration,
    required this.longestStreak,
  });

  final int totalItems;
  final int correctCount;
  final double accuracyPercent;
  final String duration;
  final int longestStreak;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: AppDimens.d12,
      mainAxisSpacing: AppDimens.d12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.4,
      children: [
        _StatCard(
          icon: Icons.check_circle_rounded,
          iconColor: AppColors.success,
          label: 'Correct',
          value: '$correctCount / $totalItems',
        ),
        _StatCard(
          icon: Icons.percent_rounded,
          iconColor: AppColors.primary,
          label: 'Accuracy',
          value: '${accuracyPercent.toStringAsFixed(0)}%',
        ),
        _StatCard(
          icon: Icons.timer_rounded,
          iconColor: AppColors.accentTeal,
          label: 'Duration',
          value: duration,
        ),
        _StatCard(
          icon: Icons.local_fire_department_rounded,
          iconColor: AppColors.accentAmber,
          label: 'Best Streak',
          value: '$longestStreak',
        ),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 300.ms);
  }
}

/// Single stat card in the results grid.
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.d12,
        vertical: AppDimens.d8,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(color: AppColors.hairlineSoft),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: AppDimens.iconMd, color: iconColor),
          const SizedBox(height: AppDimens.d4),
          Text(
            value,
            style: AppTextStyles.titleLg.copyWith(
              color: AppColors.ink,
              fontSize: 18, // slightly more compact for small screens
            ),
          ),
          const SizedBox(height: AppDimens.d4),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

/// Per-domain θ change display.
class _DomainThetaSection extends StatelessWidget {
  const _DomainThetaSection({required this.thetaChanges});

  final Map<String, Map<String, double>> thetaChanges;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimens.d20),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(color: AppColors.hairlineSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.therapyAbilityChanges,
            style: AppTextStyles.titleSm.copyWith(color: AppColors.ink),
          ),
          const SizedBox(height: AppDimens.d16),
          ...thetaChanges.entries.map((entry) {
            final domain = entry.key;
            final before = entry.value['before'] ?? 0.0;
            final after = entry.value['after'] ?? 0.0;
            final change = after - before;
            final isPositive = change >= 0;
            final percentChange = change / 6.0 * 100;
            final sign = isPositive ? '+' : '';

            return Padding(
              padding: const EdgeInsets.only(bottom: AppDimens.d12),
              child: Row(
                children: [
                  // Domain name
                  Expanded(
                    flex: 2,
                    child: Text(
                      _domainDisplayName(domain),
                      style: AppTextStyles.bodyMd.copyWith(
                        color: AppColors.body,
                      ),
                    ),
                  ),

                  // Change indicator
                  Icon(
                    isPositive
                        ? Icons.trending_up_rounded
                        : Icons.trending_down_rounded,
                    size: AppDimens.iconSm,
                    color: isPositive ? AppColors.success : AppColors.error,
                  ),
                  const SizedBox(width: AppDimens.d4),
                  Text(
                    '$sign${percentChange.toStringAsFixed(1)}% ($sign${change.toStringAsFixed(2)} θ)',
                    style: AppTextStyles.bodySm.copyWith(
                      color: isPositive ? AppColors.success : AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 350.ms);
  }

  String _domainDisplayName(String domain) {
    switch (domain) {
      case 'language':
        return AppStrings.domainLanguage;
      case 'reading_writing':
        return AppStrings.domainReadingWriting;
      case 'memory':
        return AppStrings.domainMemory;
      case 'attention':
        return AppStrings.domainAttention;
      case 'speech':
        return AppStrings.domainSpeech;
      case 'math':
        return AppStrings.domainMath;
      default:
        return domain;
    }
  }
}
