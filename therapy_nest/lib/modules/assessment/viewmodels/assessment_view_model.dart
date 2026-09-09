import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../../core/errors/failure.dart';
import '../../../core/utils/logger.dart';
import '../../../data/models/assessment_item_model.dart';
import '../../../data/models/assessment_result_model.dart';
import '../../../data/repositories/assessment_repository.dart';

/// Manages the full baseline assessment flow across all domains.
///
/// Tracks answers, computes θ per domain, and persists results.
/// Provided at route level (not app-wide) since it's only needed
/// during the assessment flow.
class AssessmentViewModel extends ChangeNotifier {
  AssessmentViewModel(this._repo);

  final AssessmentRepository _repo;
  final FlutterTts _tts = FlutterTts();

  // ── State ──────────────────────────────────────────────────────────

  /// All domains in order.
  List<String> get domainOrder => AssessmentRepository.domainOrder;

  /// Index into [domainOrder] for the current domain.
  int _currentDomainIndex = 0;
  int get currentDomainIndex => _currentDomainIndex;

  /// Current domain string.
  String get currentDomain => domainOrder[_currentDomainIndex];

  /// Items for the current domain.
  List<AssessmentItemModel> _currentItems = [];
  List<AssessmentItemModel> get currentItems => _currentItems;

  /// Index into [_currentItems].
  int _currentItemIndex = 0;
  int get currentItemIndex => _currentItemIndex;

  /// The current item being presented.
  AssessmentItemModel? get currentItem =>
      _currentItems.isNotEmpty && _currentItemIndex < _currentItems.length
          ? _currentItems[_currentItemIndex]
          : null;

  /// User's answers per item ID → answer string.
  final Map<String, String> _answers = {};

  /// Per-domain correct counts.
  final Map<String, int> _domainCorrectCounts = {};

  /// Per-domain total counts.
  final Map<String, int> _domainTotalCounts = {};

  /// Completed domain results.
  final List<AssessmentResultModel> _results = [];
  List<AssessmentResultModel> get results => List.unmodifiable(_results);

  /// Whether the full assessment is complete.
  bool _isComplete = false;
  bool get isComplete => _isComplete;

  /// Whether a save operation is in progress.
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Last error, if any.
  Failure? _error;
  Failure? get error => _error;

  /// Whether the last answer was correct (for UI feedback).
  bool? _lastAnswerCorrect;
  bool? get lastAnswerCorrect => _lastAnswerCorrect;

  /// Whether we're showing feedback before advancing.
  bool _showingFeedback = false;
  bool get showingFeedback => _showingFeedback;

  /// Timestamp when the current domain started.
  int _domainStartTimeMs = 0;

  /// For attention items: found target count per item.
  int _attentionFoundCount = 0;
  int get attentionFoundCount => _attentionFoundCount;

  /// For attention items: required target count.
  int get attentionTargetCount {
    final item = currentItem;
    if (item == null) return 0;
    return (item.stimulus['targetCount'] as int?) ?? 0;
  }

  /// For memory items: whether the sequence is still being displayed.
  bool _showingSequence = false;
  bool get showingSequence => _showingSequence;

  // ── Derived State ──────────────────────────────────────────────────

  /// Overall progress fraction (0.0 to 1.0).
  double get overallProgress {
    final totalDomains = domainOrder.length;
    if (totalDomains == 0) return 0.0;
    // Count completed domains + partial progress in current domain
    final completedDomains = _currentDomainIndex;
    final currentFraction = _currentItems.isNotEmpty
        ? _currentItemIndex / _currentItems.length
        : 0.0;
    return (completedDomains + currentFraction) / totalDomains;
  }

  /// Progress fraction within the current domain.
  double get domainProgress {
    if (_currentItems.isEmpty) return 0.0;
    return _currentItemIndex / _currentItems.length;
  }

  /// Friendly name for a domain key.
  static String domainDisplayName(String domain) {
    switch (domain) {
      case AssessmentRepository.domainLanguage:
        return 'Language';
      case AssessmentRepository.domainReadingWriting:
        return 'Reading & Writing';
      case AssessmentRepository.domainMemory:
        return 'Memory';
      case AssessmentRepository.domainAttention:
        return 'Attention';
      case AssessmentRepository.domainSpeech:
        return 'Speech';
      case AssessmentRepository.domainMath:
        return 'Math';
      default:
        return domain;
    }
  }

  // ── Actions ────────────────────────────────────────────────────────

  /// Initializes the assessment — loads items for the first domain.
  void startAssessment() {
    _currentDomainIndex = 0;
    _currentItemIndex = 0;
    _answers.clear();
    _domainCorrectCounts.clear();
    _domainTotalCounts.clear();
    _results.clear();
    _isComplete = false;
    _error = null;
    _lastAnswerCorrect = null;
    _showingFeedback = false;

    _initTts();
    _loadCurrentDomain();
    notifyListeners();
  }

  /// Submits an answer for the current item.
  ///
  /// Shows brief feedback, then advances to next item or domain.
  Future<void> submitAnswer(String answer) async {
    final item = currentItem;
    if (item == null || _showingFeedback) return;

    _answers[item.id] = answer;
    _lastAnswerCorrect = item.isCorrect(answer);

    if (_lastAnswerCorrect!) {
      _domainCorrectCounts[currentDomain] =
          (_domainCorrectCounts[currentDomain] ?? 0) + 1;
    }

    _showingFeedback = true;
    notifyListeners();

    // Brief feedback delay
    await Future<void>.delayed(const Duration(milliseconds: 800));

    _showingFeedback = false;
    _lastAnswerCorrect = null;
    _advance();
  }

  /// For attention domain: records a target tap.
  /// Returns true when all targets are found.
  bool tapAttentionTarget() {
    _attentionFoundCount++;
    notifyListeners();

    if (_attentionFoundCount >= attentionTargetCount) {
      // All targets found — score as correct
      submitAnswer(currentItem!.correctAnswer);
      return true;
    }
    return false;
  }

  /// For memory domain: marks the sequence display phase as complete.
  void onSequenceDisplayComplete() {
    _showingSequence = false;
    notifyListeners();
  }

  /// Skips the current domain entirely (θ = 0, neutral).
  void skipDomain() {
    final domain = currentDomain;
    final items = _currentItems;

    _results.add(AssessmentResultModel(
      userId: '', // filled during save
      domain: domain,
      correctCount: 0,
      totalItems: items.length,
      thetaInitial: 0.0,
      totalTimeMs: _elapsedDomainMs(),
      completedAt: DateTime.now(),
      skipped: true,
    ));

    _advanceDomain();
  }

  /// Saves all results to Supabase. Can be retried from completion page.
  Future<void> saveResults() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repo.saveResults(_results);
    } catch (e) {
      _error = const UnknownFailure('Failed to save results. You can retry.');
      AppLogger.error('Save results failed', error: e, tag: 'AssessmentVM');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Speaks text aloud via TTS (for instructions and auditory items).
  Future<void> speak(String text) async {
    try {
      await _tts.speak(text);
    } catch (e) {
      AppLogger.error('TTS failed', error: e, tag: 'AssessmentVM');
    }
  }

  /// Stops any ongoing TTS speech.
  Future<void> stopSpeaking() async {
    try {
      await _tts.stop();
    } catch (e) {
      // Ignore
    }
  }

  // ── Private Helpers ────────────────────────────────────────────────

  void _initTts() {
    _tts.setLanguage('en-US');
    _tts.setSpeechRate(0.45); // Slow for aphasia patients
    _tts.setVolume(1.0);
    _tts.setPitch(1.0);
  }

  void _loadCurrentDomain() {
    _currentItems = _repo.getAssessmentItems(currentDomain);
    _currentItemIndex = 0;
    _domainStartTimeMs = DateTime.now().millisecondsSinceEpoch;
    _attentionFoundCount = 0;

    // If memory domain, start showing the sequence
    if (currentItem?.taskType == AssessmentTaskType.sequenceRecall) {
      _showingSequence = true;
    }

    AppLogger.info(
      'Loaded domain: $currentDomain (${_currentItems.length} items)',
      tag: 'AssessmentVM',
    );
  }

  void _advance() {
    _currentItemIndex++;

    if (_currentItemIndex >= _currentItems.length) {
      // Domain complete — compute result
      _completeDomain();
    } else {
      // Reset per-item state
      _attentionFoundCount = 0;
      if (currentItem?.taskType == AssessmentTaskType.sequenceRecall) {
        _showingSequence = true;
      }
      notifyListeners();
    }
  }

  void _completeDomain() {
    final domain = currentDomain;
    final correct = _domainCorrectCounts[domain] ?? 0;
    final total = _currentItems.length;

    _results.add(AssessmentResultModel(
      userId: '', // filled during save
      domain: domain,
      correctCount: correct,
      totalItems: total,
      thetaInitial: AssessmentResultModel.computeTheta(correct, total),
      totalTimeMs: _elapsedDomainMs(),
      completedAt: DateTime.now(),
    ));

    _advanceDomain();
  }

  void _advanceDomain() {
    _currentDomainIndex++;

    if (_currentDomainIndex >= domainOrder.length) {
      // All domains done
      _isComplete = true;
      _tts.stop();
      notifyListeners();
    } else {
      _loadCurrentDomain();
      notifyListeners();
    }
  }

  int _elapsedDomainMs() {
    return DateTime.now().millisecondsSinceEpoch - _domainStartTimeMs;
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }
}
