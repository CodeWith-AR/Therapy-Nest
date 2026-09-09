import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:uuid/uuid.dart';

import '../../../core/errors/failure.dart';
import '../../../core/utils/logger.dart';
import '../../../core/services/gamification_service.dart';
import '../../../core/services/notification_service.dart';
import '../../../data/models/ability_estimate_model.dart';
import '../../../data/models/achievement_definitions.dart';
import '../../../data/models/attempt_model.dart';
import '../../../data/models/exercise_item_model.dart';
import '../../../data/models/session_model.dart';
import '../../../data/models/session_summary_model.dart';
import '../../../data/repositories/exercise_repository.dart';
import '../../../data/repositories/progress_repository.dart';
import '../../../data/repositories/session_repository.dart';

/// Core adaptive exercise engine ViewModel.
///
/// Runs the full therapy session loop:
/// 1. Load items adaptively per domain θ
/// 2. Present items one at a time
/// 3. Capture response + apply cueing hierarchy
/// 4. Update θ via Elo formula
/// 5. Advance to next item or complete session
/// 6. Check achievements and trigger celebrations (Module 14)
///
/// Provided at route level via ShellRoute (not app-wide).
class TherapySessionViewModel extends ChangeNotifier {
  TherapySessionViewModel(
    this._exerciseRepo,
    this._sessionRepo,
    this._gamificationService,
    this._notificationService,
    this._progressRepo,
  );

  final ExerciseRepository _exerciseRepo;
  final SessionRepository _sessionRepo;
  final GamificationService _gamificationService;
  final NotificationService _notificationService;
  final ProgressRepository _progressRepo;
  final FlutterTts _tts = FlutterTts();
  static const _uuid = Uuid();

  // ── Constants ──────────────────────────────────────────────────────

  /// IRT Rasch update learning rate for θ updates.
  static const double _kFactor = 0.20;

  /// Default number of items per session.
  static const int defaultItemCount = 10;

  /// Items per domain (distributed evenly across selected domains).
  int _itemsPerDomain(int domainCount) =>
      (defaultItemCount / domainCount).ceil();

  // ── State ──────────────────────────────────────────────────────────

  /// The active session metadata.
  SessionModel? _activeSession;
  SessionModel? get activeSession => _activeSession;

  /// Queue of items for the current session.
  List<ExerciseItemModel> _sessionQueue = [];
  List<ExerciseItemModel> get sessionQueue => _sessionQueue;

  /// Current index into [_sessionQueue].
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  /// The current item being presented.
  ExerciseItemModel? get currentItem =>
      _sessionQueue.isNotEmpty && _currentIndex < _sessionQueue.length
          ? _sessionQueue[_currentIndex]
          : null;

  /// Current cueing level (0 = no cue, 1–4 = graduated hints).
  int _cueLevel = 0;
  int get cueLevel => _cueLevel;

  /// Whether the session is complete.
  bool _isComplete = false;
  bool get isComplete => _isComplete;

  /// Whether large-print mode is active (1.5× text scaling).
  bool _isLargePrint = false;
  bool get isLargePrint => _isLargePrint;

  /// Toggles large-print mode for accessibility.
  void toggleLargePrint() {
    _isLargePrint = !_isLargePrint;
    notifyListeners();
  }

  /// Live ability estimates per domain.
  Map<String, double> _domainThetaMap = {};
  Map<String, double> get domainThetaMap => Map.unmodifiable(_domainThetaMap);

  /// Snapshot of θ at session start (for result comparison).
  Map<String, double> _thetaBeforeSession = {};

  /// Current streak of consecutive correct answers.
  int _streak = 0;
  int get streak => _streak;

  /// Longest streak during this session.
  int _longestStreak = 0;

  /// Whether the last answer was correct (for UI feedback).
  bool? _lastAnswerCorrect;
  bool? get lastAnswerCorrect => _lastAnswerCorrect;

  /// Whether feedback animation is showing.
  bool _showingFeedback = false;
  bool get showingFeedback => _showingFeedback;

  /// Whether a streak milestone was just hit (5, 10, ...).
  bool _streakMilestone = false;
  bool get streakMilestone => _streakMilestone;

  /// Loading state.
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Last error.
  Failure? _error;
  Failure? get error => _error;

  /// All attempts recorded during this session.
  final List<AttemptModel> _attempts = [];
  List<AttemptModel> get attempts => List.unmodifiable(_attempts);

  /// Achievements unlocked during this session (populated by endSession).
  List<AchievementDef> _newlyUnlocked = [];
  List<AchievementDef> get newlyUnlocked => List.unmodifiable(_newlyUnlocked);

  /// Session start timestamp (for total time calculation).
  int _sessionStartTimeMs = 0;

  // ── Derived State ─────────────────────────────────────────────────

  /// Progress fraction (0.0 to 1.0).
  double get progress =>
      _sessionQueue.isNotEmpty ? _currentIndex / _sessionQueue.length : 0.0;

  /// Total items in the session.
  int get totalItems => _sessionQueue.length;

  /// Number of correct answers so far.
  int get correctCount => _attempts.where((a) => a.isCorrect).length;

  /// Current cue text for the current item, or null if no cue active.
  String? get currentCueText {
    final item = currentItem;
    if (item == null || _cueLevel == 0) return null;
    final cue = item.cues.where(
      (c) => c['level'] == _cueLevel.toString(),
    );
    return cue.isNotEmpty ? cue.first['text'] : null;
  }

  /// Current cue type (semantic, phonemic, visual, model).
  String? get currentCueType {
    final item = currentItem;
    if (item == null || _cueLevel == 0) return null;
    final cue = item.cues.where(
      (c) => c['level'] == _cueLevel.toString(),
    );
    return cue.isNotEmpty ? cue.first['type'] : null;
  }

  /// Computed session summary (available after session ends).
  SessionSummaryModel get sessionSummary {
    final totalTimeMs =
        DateTime.now().millisecondsSinceEpoch - _sessionStartTimeMs;

    final domains = _activeSession?.targetDomains ?? [];
    final thetaChanges = <String, Map<String, double>>{};
    for (final domain in domains) {
      thetaChanges[domain] = {
        'before': _thetaBeforeSession[domain] ?? 0.0,
        'after': _domainThetaMap[domain] ?? 0.0,
      };
    }

    final correct = _attempts.where((a) => a.isCorrect).length;
    final total = _attempts.length;

    return SessionSummaryModel(
      totalItems: total,
      correctCount: correct,
      accuracyPercent: total > 0 ? (correct / total * 100) : 0.0,
      totalTimeMs: totalTimeMs,
      domains: domains,
      thetaChanges: thetaChanges,
      longestStreak: _longestStreak,
    );
  }

  // ── Actions ────────────────────────────────────────────────────────

  /// Synchronously resets the session state so that subsequent sessions start fresh.
  void reset() {
    _activeSession = null;
    _sessionQueue = [];
    _currentIndex = 0;
    _cueLevel = 0;
    _isComplete = false;
    _streak = 0;
    _longestStreak = 0;
    _lastAnswerCorrect = null;
    _showingFeedback = false;
    _streakMilestone = false;
    _attempts.clear();
    _newlyUnlocked.clear();
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  /// Starts a new therapy session with the given domains.
  Future<void> startSession(List<String> domains) async {
    _isLoading = true;
    _isComplete = false;
    _currentIndex = 0;
    _sessionQueue = [];
    _error = null;
    notifyListeners();

    try {
      // Load current θ estimates
      _domainThetaMap = await _exerciseRepo.getAbilityEstimates();
      _thetaBeforeSession = Map.from(_domainThetaMap);

      // Ensure all domains have a default θ
      for (final domain in domains) {
        _domainThetaMap.putIfAbsent(domain, () => 0.0);
        _thetaBeforeSession.putIfAbsent(domain, () => 0.0);
      }

      // Build session queue — items per domain, selected adaptively
      _sessionQueue = [];
      final perDomain = _itemsPerDomain(domains.length);
      for (final domain in domains) {
        final theta = _domainThetaMap[domain] ?? 0.0;
        final items = _exerciseRepo.getItemsForDomain(domain, theta, perDomain);
        _sessionQueue.addAll(items);
      }

      // Shuffle for variety across domains
      _sessionQueue.shuffle(Random());

      // Create session record
      _activeSession = await _sessionRepo.startSession(
        domains,
        _sessionQueue.length,
      );

      // Reset state
      _currentIndex = 0;
      _cueLevel = 0;
      _isComplete = false;
      _streak = 0;
      _longestStreak = 0;
      _lastAnswerCorrect = null;
      _showingFeedback = false;
      _streakMilestone = false;
      _attempts.clear();
      _sessionStartTimeMs = DateTime.now().millisecondsSinceEpoch;

      _initTts();

      AppLogger.info(
        'Session started: ${_activeSession!.id} '
        '(${_sessionQueue.length} items, domains: $domains)',
        tag: 'TherapySessionVM',
      );
    } catch (e) {
      _error = const UnknownFailure('Failed to start session');
      AppLogger.error('Start session failed', error: e, tag: 'TherapySessionVM');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Submits an answer for the current item.
  ///
  /// Scores the response, calculates partial score based on cueing,
  /// updates θ, records the attempt, and advances.
  Future<void> submitAnswer(dynamic response, int responseTimeMs) async {
    final item = currentItem;
    if (item == null || _showingFeedback) return;

    final responseStr = response.toString();
    bool isCorrect;

    if (item.domain == 'speech') {
      if (item.exerciseTypeCode == 'script_training') {
        if (responseStr.startsWith('accuracy:')) {
          final accVal = double.tryParse(responseStr.split(':')[1]) ?? 0.0;
          isCorrect = accVal >= 0.80;
        } else {
          isCorrect = false;
        }
      } else {
        // Word repetition, phrase repetition, oral reading
        isCorrect = item.acceptedAnswers.any((ans) {
          final sim = _jaroWinkler(
            ans.toLowerCase().trim(),
            responseStr.toLowerCase().trim(),
          );
          return sim >= 0.75;
        });
      }
    } else {
      isCorrect = item.isCorrect(responseStr);
      // Voice input tolerance: check substring and Jaro-Winkler match
      if (!isCorrect) {
        final cleanResponse = responseStr
            .toLowerCase()
            .replaceAll(RegExp(r'[^\w\s]'), '')
            .trim();
        for (final ans in item.acceptedAnswers) {
          final cleanAns =
              ans.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '').trim();
          if (cleanResponse == cleanAns ||
              cleanResponse.contains(cleanAns) ||
              cleanAns.contains(cleanResponse) ||
              _jaroWinkler(cleanAns, cleanResponse) >= 0.75) {
            isCorrect = true;
            break;
          }
        }
      }
    }

    // Calculate partial score based on cue level
    final partialScore = _calculatePartialScore(isCorrect, _cueLevel);

    // Get θ before this attempt
    final domain = item.domain;
    final thetaBefore = _domainThetaMap[domain] ?? 0.0;

    // Update θ via 1PL Rasch model with partial scoring based on cue level
    final thetaAfter = _updateTheta(partialScore, thetaBefore, item.difficulty);
    _domainThetaMap[domain] = thetaAfter;

    // Record attempt
    final attempt = AttemptModel(
      id: _uuid.v4(),
      sessionId: _activeSession?.id ?? '',
      exerciseItemId: item.id,
      domain: domain,
      response: {'selected': responseStr},
      isCorrect: isCorrect,
      partialScore: partialScore,
      responseTimeMs: responseTimeMs,
      hintCount: _cueLevel,
      thetaBefore: thetaBefore,
      thetaAfter: thetaAfter,
      createdAt: DateTime.now(),
    );
    _attempts.add(attempt);

    // Persist attempt
    _exerciseRepo.saveAttempt(attempt);

    // Update streak
    if (isCorrect) {
      _streak++;
      if (_streak > _longestStreak) _longestStreak = _streak;
      _streakMilestone = (_streak % 5 == 0 && _streak > 0);
    } else {
      _streak = 0;
      _streakMilestone = false;
    }

    // Show feedback
    _lastAnswerCorrect = isCorrect;
    _showingFeedback = true;
    notifyListeners();

    // TTS feedback
    if (isCorrect) {
      _speak('Great job!');
    } else if (_cueLevel >= 4) {
      _speak('The answer is ${item.correctAnswer}');
    } else {
      _speak("Let's try that again");
    }

    // Brief feedback delay
    await Future<void>.delayed(const Duration(milliseconds: 1200));

    _showingFeedback = false;
    _lastAnswerCorrect = null;
    _streakMilestone = false;

    // Advance to next item
    _advance();
  }

  /// Requests the next hint/cue for the current item.
  ///
  /// Increments cue level from 0→4. At level 4, the full answer
  /// is revealed and the user is asked to repeat.
  void requestCue() {
    if (_cueLevel >= 4) return;
    _cueLevel++;

    if (_cueLevel == 4) {
      // Full model — speak the answer
      final answer = currentItem?.correctAnswer ?? '';
      _speak('The answer is $answer');
    }

    notifyListeners();
  }

  /// Skips the current item without θ penalty.
  void skipItem() {
    if (_showingFeedback) return;

    final item = currentItem;
    if (item == null) return;

    // Record a skip attempt with 0 score
    final domain = item.domain;
    final theta = _domainThetaMap[domain] ?? 0.0;

    final attempt = AttemptModel(
      id: _uuid.v4(),
      sessionId: _activeSession?.id ?? '',
      exerciseItemId: item.id,
      domain: domain,
      response: {'skipped': true},
      isCorrect: false,
      partialScore: 0.0,
      responseTimeMs: 0,
      hintCount: _cueLevel,
      thetaBefore: theta,
      thetaAfter: theta, // No θ change on skip
      createdAt: DateTime.now(),
    );
    _attempts.add(attempt);
    _exerciseRepo.saveAttempt(attempt);

    // Reset streak
    _streak = 0;

    _advance();
  }

  /// Ends the session and persists final state.
  ///
  /// After persisting θ estimates, runs the gamification check (Module 14):
  /// streak thresholds, session count, accuracy, functional landmarks.
  /// Newly unlocked achievements are stored in [_newlyUnlocked] for the
  /// celebration overlay on the results page.
  Future<void> endSession() async {
    if (_activeSession == null) return;

    final endedAt = DateTime.now();

    try {
      await _sessionRepo.endSession(_activeSession!.id, endedAt);

      // Persist final θ estimates ONLY for domains practiced in this session
      final targetDomains = _activeSession?.targetDomains ?? [];
      for (final domain in targetDomains) {
        final theta = _domainThetaMap[domain];
        if (theta != null) {
          final estimate = AbilityEstimateModel(
            patientId: _activeSession!.patientId,
            domainCode: domain,
            theta: theta,
            updatedAt: endedAt,
          );
          await _exerciseRepo.updateAbilityEstimate(estimate);
        }
      }

      // ── Module 14: Gamification Check ─────────────────────────────

      // Compute current streak from session dates
      final streak = await _progressRepo.computeStreak();

      // Get total completed session count
      final weeklyStats = await _progressRepo.getWeeklyStats();
      final history = await _progressRepo.getSessionHistory(limit: 1000);
      final totalSessions = history.length;

      // Calculate session accuracy
      final correct = _attempts.where((a) => a.isCorrect).length;
      final total = _attempts.length;
      final sessionAccuracy = total > 0 ? (correct / total * 100) : 0.0;
      final isPerfectSession = total > 0 && correct == total;

      // Calculate overall accuracy
      final overallAccuracy = weeklyStats.averageAccuracy;

      // Check for newly unlocked achievements
      _newlyUnlocked = await _gamificationService.checkAchievements(
        currentStreak: streak,
        totalSessions: totalSessions,
        sessionAccuracy: sessionAccuracy,
        overallAccuracy: overallAccuracy,
        isPerfectSession: isPerfectSession,
      );

      // Fire milestone notifications for newly unlocked achievements
      for (final achievement in _newlyUnlocked) {
        _notificationService.showMilestoneNotification(achievement.name);
      }

      // Reset inactivity reminder (3 days from now)
      _notificationService.scheduleInactivityReminder();

      // Request notification permission after first session
      if (totalSessions <= 1) {
        _notificationService.requestPermission();
      }

      AppLogger.info(
        'Session ended: ${_activeSession!.id} '
        '(${_newlyUnlocked.length} achievements unlocked)',
        tag: 'TherapySessionVM',
      );
    } catch (e) {
      AppLogger.error(
        'End session failed',
        error: e,
        tag: 'TherapySessionVM',
      );
    }
  }

  // ── 1PL Rasch IRT Math ─────────────────────────────────────────────

  /// Expected probability of success given ability θ and item difficulty b.
  /// 1PL Rasch model: P = 1 / (1 + e^(b - θ)).
  double _expectedSuccess(double theta, double itemDifficulty) {
    final diff = (itemDifficulty - theta).clamp(-7.0, 7.0);
    return 1.0 / (1.0 + exp(diff));
  }

  /// Updates θ based on response score (0.0 to 1.0) and difficulty.
  /// Returns the new θ, clamped to [-3.0, 3.0].
  double _updateTheta(double outcomeScore, double theta, double itemDifficulty) {
    final expected = _expectedSuccess(theta, itemDifficulty);
    final newTheta = theta + _kFactor * (outcomeScore - expected);
    return newTheta.clamp(-3.0, 3.0);
  }

  // ── Cueing Score Calculation ───────────────────────────────────────

  /// Calculates partial score based on correctness and cue level.
  double _calculatePartialScore(bool isCorrect, int cueLevel) {
    if (!isCorrect) return 0.0;
    if (cueLevel == 0) return 1.0;
    if (cueLevel <= 2) return 0.7;
    return 0.3; // levels 3-4
  }

  // ── Private Helpers ────────────────────────────────────────────────

  void _advance() {
    _currentIndex++;
    _cueLevel = 0;

    if (_currentIndex >= _sessionQueue.length) {
      _isComplete = true;
      endSession();
      _tts.stop();
    }

    notifyListeners();
  }

  void _initTts() {
    _tts.setLanguage('en-US');
    _tts.setSpeechRate(0.45); // Slow for therapy patients
    _tts.setVolume(1.0);
    _tts.setPitch(1.0);
  }

  Future<void> _speak(String text) async {
    try {
      await _tts.speak(text);
    } catch (e) {
      AppLogger.error('TTS failed', error: e, tag: 'TherapySessionVM');
    }
  }

  static double _jaroWinkler(String s1, String s2) {
    if (s1 == s2) return 1.0;
    if (s1.isEmpty || s2.isEmpty) return 0.0;

    final maxDist = (max(s1.length, s2.length) / 2).floor() - 1;
    if (maxDist < 0) return 0.0;

    final s1Matches = List<bool>.filled(s1.length, false);
    final s2Matches = List<bool>.filled(s2.length, false);

    int matches = 0;
    int transpositions = 0;

    // Find matching characters
    for (int i = 0; i < s1.length; i++) {
      final start = max(0, i - maxDist);
      final end = min(i + maxDist + 1, s2.length);

      for (int j = start; j < end; j++) {
        if (s2Matches[j] || s1[i] != s2[j]) continue;
        s1Matches[i] = true;
        s2Matches[j] = true;
        matches++;
        break;
      }
    }

    if (matches == 0) return 0.0;

    // Count transpositions
    int k = 0;
    for (int i = 0; i < s1.length; i++) {
      if (!s1Matches[i]) continue;
      while (!s2Matches[k]) {
        k++;
      }
      if (s1[i] != s2[k]) transpositions++;
      k++;
    }

    final jaro = (matches / s1.length +
            matches / s2.length +
            (matches - transpositions / 2) / matches) /
        3.0;

    // Winkler modification — boost for common prefix (up to 4 chars)
    int prefixLen = 0;
    final maxPrefix = min(4, min(s1.length, s2.length));
    for (int i = 0; i < maxPrefix; i++) {
      if (s1[i] == s2[i]) {
        prefixLen++;
      } else {
        break;
      }
    }

    return jaro + (prefixLen * 0.1 * (1.0 - jaro));
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }
}
