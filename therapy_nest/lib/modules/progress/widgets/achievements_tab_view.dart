import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/achievement_model.dart';
import '../../../data/models/weekly_stats_model.dart';

/// Achievements tab view matching the mockup achievements screen perfectly.
/// Displays unlocked achievements with custom emojis, and locked upcoming milestones
/// with progress bars.
class AchievementsTabView extends StatelessWidget {
  const AchievementsTabView({
    super.key,
    required this.achievements,
    this.weeklyStats,
  });

  final List<AchievementModel> achievements;
  final WeeklyStatsModel? weeklyStats;

  String _getAchievementEmoji(String id) {
    return switch (id) {
      'streak_3' || 'streak_7' || 'streak_30' || 'streak_100' => '🔥',
      'sessions_1' || 'sessions_10' || 'sessions_50' => '⭐',
      'sessions_100' => '🏆',
      'accuracy_perfect' => '💎',
      'accuracy_sharp' => '🎯',
      _ => '🏅',
    };
  }

  @override
  Widget build(BuildContext context) {
    final unlocked = achievements.where((a) => a.isUnlocked).toList();
    final locked = achievements.where((a) => !a.isUnlocked).toList();

    // Stats for progress calculations
    final currentStreak = weeklyStats?.currentStreak ?? 0;
    final totalSessions = weeklyStats?.totalSessions ?? 0;
    final avgAccuracy = weeklyStats?.averageAccuracy ?? 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Title Section ──────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppDimens.d8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Your Achievements ',
                    style: AppTextStyles.displayLg.copyWith(
                      color: AppColors.ink,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Text(
                    '🏆',
                    style: TextStyle(fontSize: 28),
                  ),
                ],
              ),
              const SizedBox(height: AppDimens.d4),
              Text(
                'Celebrate your milestones on the path to well-being.',
                style: AppTextStyles.bodyMd.copyWith(
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimens.d20),

        // ── Unlocked Section ───────────────────────────────────────────
        if (unlocked.isNotEmpty) ...[
          _buildSectionHeader('Unlocked'),
          const SizedBox(height: AppDimens.d16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppDimens.d16,
              mainAxisSpacing: AppDimens.d16,
              mainAxisExtent: 200,
            ),
            itemCount: unlocked.length,
            itemBuilder: (context, idx) {
              final a = unlocked[idx];
              final dateStr = a.unlockedAt != null
                  ? DateFormat('MMM d').format(a.unlockedAt!)
                  : '';
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                  border: Border.all(color: AppColors.hairlineSoft),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(AppDimens.d16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.canvas,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.hairline),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _getAchievementEmoji(a.id),
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                    const SizedBox(height: AppDimens.d12),
                    Text(
                      a.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyMd.copyWith(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      a.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySm.copyWith(
                        color: AppColors.muted,
                      ),
                    ),
                    const Spacer(),
                    if (dateStr.isNotEmpty)
                      Text(
                        'Unlocked $dateStr'.toUpperCase(),
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.mutedSoft,
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                          letterSpacing: 0.5,
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: AppDimens.d32),
        ],

        // ── Coming Up Next Section ─────────────────────────────────────
        if (locked.isNotEmpty) ...[
          _buildSectionHeader('Coming Up Next'),
          const SizedBox(height: AppDimens.d16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppDimens.d16,
              mainAxisSpacing: AppDimens.d16,
              mainAxisExtent: 205,
            ),
            itemCount: locked.length,
            itemBuilder: (context, idx) {
              final a = locked[idx];
              final (current, target) = _getLockedProgress(a.id, currentStreak, totalSessions, avgAccuracy);
              final progress = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;

              return Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceSoft.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                  border: Border.all(color: AppColors.hairlineSoft),
                ),
                padding: const EdgeInsets.all(AppDimens.d16),
                child: Stack(
                  children: [
                    // Lock icon on top right
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Icon(
                        Icons.lock_outline_rounded,
                        color: AppColors.mutedSoft,
                        size: 18,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceSoft,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.hairline),
                          ),
                          alignment: Alignment.center,
                          child: Opacity(
                            opacity: 0.5,
                            child: Text(
                              _getAchievementEmoji(a.id),
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppDimens.d12),
                        Text(
                          a.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyMd.copyWith(
                            color: AppColors.muted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          a.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodySm.copyWith(
                            color: AppColors.mutedSoft,
                          ),
                        ),
                        const Spacer(),
                        if (target > 0) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${current.toInt()}/${target.toInt()}',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.muted,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppDimens.d4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 5,
                              backgroundColor: AppColors.surfaceCard,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.muted,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: AppDimens.d24),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: AppColors.hairline)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.d12),
          child: Text(
            title.toUpperCase(),
            style: AppTextStyles.label.copyWith(
              color: AppColors.muted,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
            ),
          ),
        ),
        Expanded(child: Container(height: 1, color: AppColors.hairline)),
      ],
    );
  }

  (double current, double target) _getLockedProgress(
    String id,
    int currentStreak,
    int totalSessions,
    double avgAccuracy,
  ) {
    return switch (id) {
      'streak_3' => (currentStreak.toDouble(), 3.0),
      'streak_7' => (currentStreak.toDouble(), 7.0),
      'streak_30' => (currentStreak.toDouble(), 30.0),
      'streak_100' => (currentStreak.toDouble(), 100.0),
      'sessions_1' => (totalSessions.toDouble(), 1.0),
      'sessions_10' => (totalSessions.toDouble(), 10.0),
      'sessions_50' => (totalSessions.toDouble(), 50.0),
      'sessions_100' => (totalSessions.toDouble(), 100.0),
      'accuracy_perfect' => (0.0, 0.0), // Boolean trigger, no numerical progress bar
      'accuracy_sharp' => (avgAccuracy, 90.0),
      _ => (0.0, 0.0),
    };
  }
}
