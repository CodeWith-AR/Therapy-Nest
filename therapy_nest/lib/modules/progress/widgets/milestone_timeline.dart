import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/functional_milestone_model.dart';

/// Vertical timeline of functional recovery milestones grouped by cognitive domain.
///
/// Matches the mockup timeline design exactly, featuring:
/// - Group headers with matching icons.
/// - Completed milestone cards in green with checkmark and star.
/// - Current milestone cards in primary with progress bar and animated ping indicator.
/// - Locked upcoming cards with padlocks.
/// - Encouraging trophy footer banner.
class MilestoneTimeline extends StatelessWidget {
  const MilestoneTimeline({
    super.key,
    required this.milestones,
    required this.currentThetas,
  });

  final List<FunctionalMilestoneModel> milestones;

  /// Map of domain code → current θ, for calculating progress fractions.
  final Map<String, double> currentThetas;

  @override
  Widget build(BuildContext context) {
    if (milestones.isEmpty) {
      return const SizedBox.shrink();
    }

    // 1. Group milestones by domain
    final Map<String, List<FunctionalMilestoneModel>> grouped = {};
    for (final m in milestones) {
      final code = m.domainCode;
      if (!grouped.containsKey(code)) {
        grouped[code] = [];
      }
      grouped[code]!.add(m);
    }

    // Fixed order of domains for consistency
    final domainCodes = ['language', 'reading_writing', 'memory', 'attention', 'speech', 'math'];

    return Stack(
      children: [
        // Ambient background waving decoration
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          height: 120,
          child: Opacity(
            opacity: 0.05,
            child: CustomPaint(
              painter: _WavePainter(AppColors.primary),
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Title
            Text(
              'Your Recovery Milestones',
              style: AppTextStyles.displayLg.copyWith(
                color: AppColors.ink,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppDimens.d4),
            Text(
              "Celebrate how far you've come and see what's next on your journey.",
              style: AppTextStyles.bodyMd.copyWith(color: AppColors.muted),
            ),
            const SizedBox(height: AppDimens.d24),

            // Timeline container
            Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: Stack(
                children: [
                  // Global Vertical Timeline Line
                  Positioned(
                    left: 20,
                    top: 10,
                    bottom: 120, // stop line before motivational footer
                    width: 2,
                    child: Container(color: AppColors.hairlineSoft),
                  ),

                  Column(
                    children: domainCodes.where((code) => grouped.containsKey(code)).map((code) {
                      final domainMilestones = grouped[code]!;
                      // Sort by threshold ascending
                      domainMilestones.sort((a, b) => a.thetaThreshold.compareTo(b.thetaThreshold));
                      return _buildDomainSection(code, domainMilestones);
                    }).toList(),
                  ),
                ],
              ),
            ),

            // Motivational Footer Banner
            Container(
              margin: const EdgeInsets.only(top: AppDimens.d24),
              padding: const EdgeInsets.all(AppDimens.d20),
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                border: Border.all(color: AppColors.primaryLight),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.emoji_events_outlined,
                    color: AppColors.primary,
                    size: 32,
                  ),
                  const SizedBox(height: AppDimens.d8),
                  Text(
                    "You're doing amazing!",
                    style: AppTextStyles.titleLg.copyWith(
                      color: AppColors.ink,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppDimens.d4),
                  Text(
                    'Consistency is the key to recovery. Keep up the great work.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMd.copyWith(color: AppColors.muted),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimens.d32),
          ],
        ),
      ],
    );
  }

  Widget _buildDomainSection(String domainCode, List<FunctionalMilestoneModel> domainMilestones) {
    final domainColor = _getDomainColor(domainCode);
    final domainIcon = _getDomainIcon(domainCode);
    final domainName = _getDomainName(domainCode);

    // Find index of first locked milestone
    int firstLockedIdx = domainMilestones.indexWhere((m) => !m.isAchieved);
    if (firstLockedIdx == -1) {
      firstLockedIdx = domainMilestones.length; // all achieved
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Group Domain Header with icon on the timeline line
        Padding(
          padding: const EdgeInsets.only(bottom: AppDimens.d16, top: AppDimens.d8),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: domainColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: domainColor.withValues(alpha: 0.28),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: domainColor.withValues(alpha: 0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                alignment: Alignment.center,
                child: Icon(
                  domainIcon,
                  color: domainColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppDimens.d12),
              Text(
                domainName,
                style: AppTextStyles.titleLg.copyWith(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        // Milestones rows
        Padding(
          padding: const EdgeInsets.only(left: 20.0), // Align with timeline line
          child: Column(
            children: List.generate(domainMilestones.length, (idx) {
              final m = domainMilestones[idx];
              final currentTheta = currentThetas[m.domainCode] ?? -3.0;

              if (idx < firstLockedIdx) {
                // Completed
                return _CompletedMilestoneCard(
                  milestone: m,
                  domainColor: domainColor,
                );
              } else if (idx == firstLockedIdx) {
                // Current
                return _CurrentMilestoneCard(
                  milestone: m,
                  progress: m.progressFraction(currentTheta),
                  domainColor: domainColor,
                );
              } else {
                // Locked / Upcoming
                return _LockedMilestoneCard(
                  milestone: m,
                  domainColor: domainColor,
                );
              }
            }),
          ),
        ),
      ],
    );
  }

  IconData _getDomainIcon(String domainCode) {
    return switch (domainCode.toLowerCase()) {
      'language' => Icons.chat_bubble_rounded,
      'memory' => Icons.psychology_rounded,
      'attention' => Icons.center_focus_strong_rounded,
      'speech' => Icons.record_voice_over_rounded,
      'reading_writing' => Icons.menu_book_rounded,
      'math' => Icons.calculate_rounded,
      _ => Icons.stars_rounded,
    };
  }

  Color _getDomainColor(String domainCode) {
    return switch (domainCode.toLowerCase()) {
      'language' => AppColors.primary,
      'memory' => AppColors.accentPurple,
      'attention' => AppColors.accentTeal,
      'speech' => AppColors.accentGreen,
      'reading_writing' => AppColors.info,
      'math' => AppColors.warning,
      _ => AppColors.primary,
    };
  }

  String _getDomainName(String domainCode) {
    return switch (domainCode.toLowerCase()) {
      'language' => 'Language',
      'memory' => 'Memory',
      'attention' => 'Attention',
      'speech' => 'Speech',
      'reading_writing' => 'Reading & Writing',
      'math' => 'Math',
      _ => domainCode,
    };
  }
}

// ── Completed Milestone Card ─────────────────────────────────────────

class _CompletedMilestoneCard extends StatelessWidget {
  const _CompletedMilestoneCard({
    required this.milestone,
    required this.domainColor,
  });

  final FunctionalMilestoneModel milestone;
  final Color domainColor;

  @override
  Widget build(BuildContext context) {
    final dateStr = milestone.achievedAt != null
        ? DateFormat('MMM dd').format(milestone.achievedAt!)
        : 'Achieved';

    return Padding(
      padding: const EdgeInsets.only(left: 18.0, bottom: AppDimens.d16),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Timeline node circle indicator in domain color
          Positioned(
            left: -26,
            top: 14,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: domainColor,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.canvas, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: domainColor.withValues(alpha: 0.2),
                    blurRadius: 3,
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.check,
                size: 8,
                color: AppColors.onPrimary,
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimens.d16),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
              border: Border.all(color: AppColors.hairlineSoft),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: domainColor.withValues(alpha: 0.12),
                        borderRadius:
                            BorderRadius.circular(AppDimens.radiusFull),
                        border: Border.all(
                          color: domainColor.withValues(alpha: 0.25),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            size: 12,
                            color: domainColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'ACHIEVED $dateStr'.toUpperCase(),
                            style: AppTextStyles.caption.copyWith(
                              color: domainColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.star_rounded,
                      color: domainColor,
                      size: 18,
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.d4),
                Text(
                  milestone.name,
                  style: AppTextStyles.bodyLg.copyWith(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  milestone.description,
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Current Milestone Card ───────────────────────────────────────────

class _CurrentMilestoneCard extends StatefulWidget {
  const _CurrentMilestoneCard({
    required this.milestone,
    required this.progress,
    required this.domainColor,
  });

  final FunctionalMilestoneModel milestone;
  final double progress;
  final Color domainColor;

  @override
  State<_CurrentMilestoneCard> createState() => _CurrentMilestoneCardState();
}

class _CurrentMilestoneCardState extends State<_CurrentMilestoneCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pingController;

  @override
  void initState() {
    super.initState();
    _pingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _pingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int progressPercent = (widget.progress * 100).toInt();

    // Simulated estimation flag
    final String estimation = progressPercent >= 80
        ? 'Est. 1 week'
        : progressPercent >= 50
            ? 'Est. 2 more weeks'
            : 'Est. 3 weeks';

    return Padding(
      padding: const EdgeInsets.only(left: 18.0, bottom: AppDimens.d16),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Timeline pulsating node indicator in domain color
          Positioned(
            left: -27,
            top: 14,
            child: Stack(
              alignment: Alignment.center,
              children: [
                ScaleTransition(
                  scale: Tween<double>(begin: 1.0, end: 2.2).animate(
                    CurvedAnimation(
                        parent: _pingController, curve: Curves.easeOut),
                  ),
                  child: FadeTransition(
                    opacity: Tween<double>(begin: 0.6, end: 0.0).animate(
                      CurvedAnimation(
                          parent: _pingController, curve: Curves.easeOut),
                    ),
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: widget.domainColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: widget.domainColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.canvas, width: 2),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimens.d16),
            decoration: BoxDecoration(
              color: AppColors.surfaceWhite,
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
              border: Border.all(
                color: widget.domainColor.withValues(alpha: 0.25),
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.domainColor.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: widget.domainColor.withValues(alpha: 0.12),
                        borderRadius:
                            BorderRadius.circular(AppDimens.radiusFull),
                        border: Border.all(
                          color: widget.domainColor.withValues(alpha: 0.25),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'CURRENT GOAL',
                        style: AppTextStyles.caption.copyWith(
                          color: widget.domainColor,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSoft,
                        borderRadius:
                            BorderRadius.circular(AppDimens.radiusFull),
                      ),
                      child: Text(
                        estimation,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.body,
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.d8),
                Text(
                  widget.milestone.name,
                  style: AppTextStyles.bodyLg.copyWith(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: AppDimens.d12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                  child: LinearProgressIndicator(
                    value: widget.progress.clamp(0.0, 1.0),
                    minHeight: 6,
                    backgroundColor:
                        widget.domainColor.withValues(alpha: 0.12),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      widget.domainColor,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progress',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.muted,
                      ),
                    ),
                    Text(
                      '$progressPercent%',
                      style: AppTextStyles.caption.copyWith(
                        color: widget.domainColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Locked Milestone Card ────────────────────────────────────────────

class _LockedMilestoneCard extends StatelessWidget {
  const _LockedMilestoneCard({
    required this.milestone,
    required this.domainColor,
  });

  final FunctionalMilestoneModel milestone;
  final Color domainColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 18.0, bottom: AppDimens.d16),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Timeline locked node indicator
          Positioned(
            left: -26,
            top: 14,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: AppColors.canvas,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.hairline, width: 2),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimens.d16),
            decoration: BoxDecoration(
              color: AppColors.surfaceSoft.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
              border: Border.all(color: AppColors.hairlineSoft),
            ),
            child: Opacity(
              opacity: 0.6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'UPCOMING',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.muted,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Icon(
                        Icons.lock_outline_rounded,
                        color: AppColors.mutedSoft,
                        size: 16,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimens.d4),
                  Text(
                    milestone.name,
                    style: AppTextStyles.bodyLg.copyWith(
                      color: AppColors.muted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Custom Painter to draw waving decorative background ───────────────

class _WavePainter extends CustomPainter {
  final Color waveColor;

  _WavePainter(this.waveColor);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = waveColor.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height * 0.5);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.3,
      size.width * 0.5,
      size.height * 0.5,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.7,
      size.width,
      size.height * 0.5,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
