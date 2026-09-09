import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/services/speech_service.dart';
import '../../settings/viewmodels/accessibility_view_model.dart';
import '../viewmodels/therapy_session_view_model.dart';
import '../../../data/models/exercise_item_model.dart';
import '../widgets/cue_banner.dart';
import '../widgets/exercise_card_renderer.dart';
import '../widgets/feedback_overlay.dart';
import '../widgets/session_progress_bar.dart';

/// Main therapy session page — presents exercises one at a time.
///
/// Route: `/therapy/session`
/// Receives selected domains via `GoRouter.extra`.
class SessionPage extends StatefulWidget {
  const SessionPage({super.key, required this.domains});

  /// Domains selected by the user for this session.
  final List<String> domains;

  @override
  State<SessionPage> createState() => _SessionPageState();
}

class _SessionPageState extends State<SessionPage> {
  int _itemStartTimeMs = 0;
  bool _navigatedToResults = false;

  @override
  void initState() {
    super.initState();
    _navigatedToResults = false;
    // Synchronously clear previous session state before scheduling startSession
    context.read<TherapySessionViewModel>().reset();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<TherapySessionViewModel>().startSession(widget.domains);
        _itemStartTimeMs = DateTime.now().millisecondsSinceEpoch;
      }
    });
  }

  @override
  void didUpdateWidget(SessionPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.domains != widget.domains) {
      _navigatedToResults = false;
      context.read<TherapySessionViewModel>().reset();
      context.read<TherapySessionViewModel>().startSession(widget.domains);
      _itemStartTimeMs = DateTime.now().millisecondsSinceEpoch;
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TherapySessionViewModel>();

    // Navigate to results ONLY when an active session genuinely completes all items
    if (vm.isComplete &&
        !vm.isLoading &&
        vm.sessionQueue.isNotEmpty &&
        vm.currentIndex >= vm.sessionQueue.length &&
        !_navigatedToResults) {
      _navigatedToResults = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.go(AppRoutes.sessionResult);
        }
      });
    }

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : vm.currentItem == null
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                  children: [
                    // ── Main Content ──────────────────────────────────
                    Column(
                      children: [
                        // Progress bar
                        SessionProgressBar(
                          currentIndex: vm.currentIndex,
                          totalItems: vm.totalItems,
                          domainLabel: _domainDisplayName(
                            vm.currentItem!.domain,
                          ),
                          isLargePrint: vm.isLargePrint,
                          onFontToggle: vm.toggleLargePrint,
                        ),

                        // ── Cue Banner ────────────────────────────────
                        if (vm.cueLevel > 0 && vm.currentCueText != null)
                          CueBanner(
                            key: ValueKey('cue_${vm.cueLevel}'),
                            cueText: vm.currentCueText!,
                            cueLevel: vm.cueLevel,
                            cueType: vm.currentCueType,
                          ),

                        // ── Exercise Card ─────────────────────────────
                        Expanded(
                          child: Builder(
                            builder: (context) {
                              final baseScale = context
                                  .watch<AccessibilityViewModel>()
                                  .textScaleFactor;
                              final effectiveScale = vm.isLargePrint
                                  ? (baseScale * 1.35).clamp(1.0, 2.0)
                                  : baseScale;
                              return MediaQuery(
                                data: MediaQuery.of(context).copyWith(
                                  textScaler: TextScaler.linear(effectiveScale),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(AppDimens.d20),
                              child: Center(
                                child: SingleChildScrollView(
                                  child: ExerciseCardRenderer(
                                    key: ValueKey(vm.currentItem!.id),
                                    item: vm.currentItem!,
                                    onAnswer: (answer) {
                                      final responseTimeMs =
                                          DateTime.now().millisecondsSinceEpoch -
                                              _itemStartTimeMs;
                                      context
                                          .read<TherapySessionViewModel>()
                                          .submitAnswer(answer, responseTimeMs);
                                      _itemStartTimeMs =
                                          DateTime.now().millisecondsSinceEpoch;
                                    },
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                        // ── Bottom Actions ────────────────────────────
                        _BottomActions(
                          cueLevel: vm.cueLevel,
                          item: vm.currentItem,
                          voiceInputEnabled: context.watch<AccessibilityViewModel>().voiceInputMode,
                          onVoiceAnswer: (voiceAnswer) {
                            final responseTimeMs = DateTime.now().millisecondsSinceEpoch - _itemStartTimeMs;
                            context.read<TherapySessionViewModel>().submitAnswer(voiceAnswer, responseTimeMs);
                            _itemStartTimeMs = DateTime.now().millisecondsSinceEpoch;
                          },
                          onHintTap: () => context
                              .read<TherapySessionViewModel>()
                              .requestCue(),
                          onSkipTap: () => context
                              .read<TherapySessionViewModel>()
                              .skipItem(),
                        ),
                      ],
                    ),

                    // ── Feedback Overlay ───────────────────────────────
                    if (vm.showingFeedback && vm.lastAnswerCorrect != null)
                      Positioned.fill(
                        child: FeedbackOverlay(
                          isCorrect: vm.lastAnswerCorrect!,
                          isStreakMilestone: vm.streakMilestone,
                          streakCount: vm.streak,
                        ),
                      ),
                  ],
                ),
    );
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

/// Bottom action bar — "Need a hint?" + "Skip" + optional Voice Input buttons.
class _BottomActions extends StatelessWidget {
  const _BottomActions({
    required this.cueLevel,
    required this.onHintTap,
    required this.onSkipTap,
    this.item,
    this.voiceInputEnabled = false,
    this.onVoiceAnswer,
  });

  final int cueLevel;
  final ExerciseItemModel? item;
  final VoidCallback onHintTap;
  final VoidCallback onSkipTap;
  final bool voiceInputEnabled;
  final ValueChanged<String>? onVoiceAnswer;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.d24,
        AppDimens.d12,
        AppDimens.d24,
        AppDimens.d24,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        border: Border(
          top: BorderSide(color: AppColors.hairlineSoft, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // ── Hint Button ─────────────────────────────────────
            Expanded(
              child: OutlinedButton.icon(
                onPressed: cueLevel >= 4 ? null : onHintTap,
                icon: Icon(
                  Icons.lightbulb_outline_rounded,
                  size: AppDimens.iconSm,
                  color: cueLevel >= 4
                      ? AppColors.muted
                      : AppColors.accentAmber,
                ),
                label: Text(
                  cueLevel >= 4
                      ? AppStrings.therapyAllHintsUsed
                      : AppStrings.therapyNeedHint,
                  style: AppTextStyles.buttonSm.copyWith(
                    color: cueLevel >= 4
                        ? AppColors.muted
                        : AppColors.body,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: cueLevel >= 4
                        ? AppColors.hairline
                        : AppColors.hairline,
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: AppDimens.d12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppDimens.radiusMd),
                  ),
                ),
              ),
            ),
            if (voiceInputEnabled) ...[
              const SizedBox(width: AppDimens.d12),
              _VoiceInputButton(onAnswer: onVoiceAnswer, item: item),
            ],
            const SizedBox(width: AppDimens.d12),

            // ── Skip Button ─────────────────────────────────────
            TextButton(
              onPressed: onSkipTap,
              child: Text(
                AppStrings.therapySkip,
                style: AppTextStyles.buttonSm.copyWith(
                  color: AppColors.muted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VoiceInputButton extends StatelessWidget {
  const _VoiceInputButton({this.onAnswer, this.item});
  final ValueChanged<String>? onAnswer;
  final ExerciseItemModel? item;

  @override
  Widget build(BuildContext context) {
    final speech = context.watch<SpeechService>();
    final isListening = speech.isListening;
    final isProcessing = speech.isProcessing;

    return OutlinedButton.icon(
      onPressed: isProcessing
          ? null
          : () async {
              if (isListening) {
                final expected = item?.correctAnswer;
                final options = (item?.stimulus['options'] as List?)
                    ?.map((e) => e.toString())
                    .toList();
                final transcription = await speech.stopListening(
                  expectedText: expected,
                  options: options,
                );
                if (transcription.trim().isNotEmpty && onAnswer != null) {
                  onAnswer!(transcription.trim());
                }
              } else {
                await speech.startListening();
              }
            },
      icon: isProcessing
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(
              isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
              size: AppDimens.iconSm,
              color: isListening ? AppColors.error : AppColors.primary,
            ),
      label: Text(
        isProcessing
            ? 'Processing...'
            : isListening
                ? 'Stop'
                : 'Speak',
        style: AppTextStyles.buttonSm.copyWith(
          color: isListening ? AppColors.error : AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: OutlinedButton.styleFrom(
        minimumSize: Size(0, AppDimens.touchNormal),
        side: BorderSide(
          color: isListening ? AppColors.error : AppColors.primary,
          width: isListening ? 2.0 : 1.0,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.d12,
          vertical: AppDimens.d12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        ),
      ),
    );
  }
}
