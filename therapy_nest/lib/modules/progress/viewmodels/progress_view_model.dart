import 'package:flutter/foundation.dart';

import '../../../core/errors/api_error_mapper.dart';
import '../../../core/errors/failure.dart';
import '../../../core/utils/logger.dart';
import '../../../data/models/achievement_model.dart';
import '../../../data/models/domain_ability_model.dart';
import '../../../data/models/functional_milestone_model.dart';
import '../../../data/models/review_item_model.dart';
import '../../../data/models/weekly_stats_model.dart';
import '../../../data/repositories/progress_repository.dart';

/// ViewModel for the Progress module (Home + Progress + Domain Detail).
///
/// Follows the standard ChangeNotifier pattern:
/// `isLoading = true → try/catch → notifyListeners()`.
class ProgressViewModel extends ChangeNotifier {
  ProgressViewModel(this._repo);

  final ProgressRepository _repo;

  // ── State ──────────────────────────────────────────────────────────
  WeeklyStatsModel? weeklyStats;
  List<DomainAbilityModel> domainAbilities = [];
  List<AchievementModel> recentAchievements = [];
  List<SessionHistoryModel> recentSessions = [];
  List<FunctionalMilestoneModel> milestones = [];
  Map<String, List<double>> accuracyTrends = {};

  // Domain detail state
  List<double> domainAccuracyHistory = [];
  Map<String, double> exerciseTypeAccuracy = {};
  List<ReviewItemModel> itemsToReview = [];
  String? selectedDomainCode;

  bool isLoading = false;
  bool isLoadingMore = false;
  Failure? error;

  int _sessionOffset = 0;
  bool hasMoreSessions = true;
  static const int _pageSize = 10;

  // ── Dashboard Load ─────────────────────────────────────────────────

  /// Loads all home/progress data in parallel.
  Future<void> loadDashboard() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _repo.getWeeklyStats(),
        _repo.getDomainAbilities(),
        _repo.getAchievements(),
        _repo.getSessionHistory(limit: _pageSize, offset: 0),
        _repo.getFunctionalMilestones(),
      ]);

      weeklyStats = results[0] as WeeklyStatsModel;
      domainAbilities = results[1] as List<DomainAbilityModel>;
      recentAchievements = results[2] as List<AchievementModel>;
      recentSessions = results[3] as List<SessionHistoryModel>;
      milestones = results[4] as List<FunctionalMilestoneModel>;

      _sessionOffset = recentSessions.length;
      hasMoreSessions = recentSessions.length >= _pageSize;

      // Show dashboard data immediately — don't wait for trends
      isLoading = false;
      error = null;
      notifyListeners();

      // Load accuracy trends in parallel (background)
      if (domainAbilities.isNotEmpty) {
        final trendResults = await Future.wait(
          domainAbilities.map(
            (a) => _repo.getAccuracyTrend(a.domainCode, sessions: 30),
          ),
        );

        accuracyTrends = {};
        for (int i = 0; i < domainAbilities.length; i++) {
          if (trendResults[i].isNotEmpty) {
            accuracyTrends[domainAbilities[i].domainCode] = trendResults[i];
          }
        }
        notifyListeners();
      }
    } catch (e) {
      error = ApiErrorMapper.map(e);
      AppLogger.error(
        'Failed to load dashboard',
        error: e,
        tag: 'ProgressViewModel',
      );
      isLoading = false;
      notifyListeners();
    }
  }

  // ── Domain Detail ──────────────────────────────────────────────────

  /// Loads domain-specific history, accuracy breakdown, and review items.
  Future<void> loadDomainDetail(String domainCode) async {
    isLoading = true;
    selectedDomainCode = domainCode;
    error = null;
    notifyListeners();

    try {
      if (domainAbilities.isEmpty) {
        domainAbilities = await _repo.getDomainAbilities();
      }

      final results = await Future.wait([
        _repo.getAccuracyTrend(domainCode, sessions: 30),
        _repo.getExerciseTypeAccuracy(domainCode),
        _repo.getReviewItems(domainCode, minHints: 2),
      ]);

      domainAccuracyHistory = results[0] as List<double>;
      exerciseTypeAccuracy = results[1] as Map<String, double>;
      itemsToReview = results[2] as List<ReviewItemModel>;

      error = null;
    } catch (e) {
      error = ApiErrorMapper.map(e);
      AppLogger.error(
        'Failed to load domain detail: $domainCode',
        error: e,
        tag: 'ProgressViewModel',
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ── Pagination ─────────────────────────────────────────────────────

  /// Loads the next page of session history.
  Future<void> loadMoreSessions() async {
    if (isLoadingMore || !hasMoreSessions) return;

    isLoadingMore = true;
    notifyListeners();

    try {
      final more = await _repo.getSessionHistory(
        limit: _pageSize,
        offset: _sessionOffset,
      );

      recentSessions = [...recentSessions, ...more];
      _sessionOffset += more.length;
      hasMoreSessions = more.length >= _pageSize;
    } catch (e) {
      AppLogger.error(
        'Failed to load more sessions',
        error: e,
        tag: 'ProgressViewModel',
      );
    } finally {
      isLoadingMore = false;
      notifyListeners();
    }
  }

  // ── Computed Helpers ───────────────────────────────────────────────

  /// Returns the domain ability for a given code, or null.
  DomainAbilityModel? domainAbility(String domainCode) {
    try {
      return domainAbilities.firstWhere((a) => a.domainCode == domainCode);
    } catch (_) {
      return null;
    }
  }

  /// Returns unlocked achievements sorted by unlock date (newest first).
  List<AchievementModel> get unlockedAchievements =>
      recentAchievements.where((a) => a.isUnlocked).toList()
        ..sort((a, b) =>
            (b.unlockedAt ?? DateTime(2000)).compareTo(a.unlockedAt ?? DateTime(2000)));

  /// Returns the next unachieved milestone for a domain, or null.
  FunctionalMilestoneModel? nextMilestone(String domainCode) {
    try {
      return milestones.firstWhere(
        (m) => m.domainCode == domainCode && !m.isAchieved,
      );
    } catch (_) {
      return null;
    }
  }
}
