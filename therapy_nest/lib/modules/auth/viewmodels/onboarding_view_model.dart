import 'package:flutter/foundation.dart';

import '../../../core/errors/api_error_mapper.dart';
import '../../../core/errors/failure.dart';
import '../../../core/utils/logger.dart';
import '../../../data/models/patient_profile_model.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../../data/storage/local_store.dart';

/// Page-level ViewModel for the 5-step onboarding flow.
class OnboardingViewModel extends ChangeNotifier {
  OnboardingViewModel({
    required ProfileRepository profileRepo,
    required LocalStore localStore,
    required String userId,
  })  : _profileRepo = profileRepo,
        _localStore = localStore,
        _userId = userId;

  final ProfileRepository _profileRepo;
  final LocalStore _localStore;
  final String _userId;

  // ── State ──────────────────────────────────────────────────────────
  int _currentStep = 0;
  bool _isLoading = false;
  Failure? _error;

  // Draft profile data collected across steps
  List<String> _conditions = [];
  final Map<String, int> _severityMap = {
    'speech': 3,
    'comprehension': 3,
    'reading': 3,
    'memory': 3,
    'math': 3,
  };
  List<String> _goals = [];
  int _sessionsPerWeek = 3;
  int _minutesPerSession = 20;

  // ── Getters ────────────────────────────────────────────────────────
  int get currentStep => _currentStep;
  int get totalSteps => 5;
  bool get isLoading => _isLoading;
  Failure? get error => _error;
  bool get isFirstStep => _currentStep == 0;
  bool get isLastStep => _currentStep == totalSteps - 1;

  List<String> get conditions => _conditions;
  Map<String, int> get severityMap => Map.unmodifiable(_severityMap);
  List<String> get goals => _goals;
  int get sessionsPerWeek => _sessionsPerWeek;
  int get minutesPerSession => _minutesPerSession;

  // ── Step Navigation ────────────────────────────────────────────────
  void nextStep() {
    if (_currentStep < totalSteps - 1) {
      _currentStep++;
      notifyListeners();
    }
  }

  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  void goToStep(int step) {
    if (step >= 0 && step < totalSteps) {
      _currentStep = step;
      notifyListeners();
    }
  }

  // ── Data Setters ───────────────────────────────────────────────────
  void setConditions(List<String> conditions) {
    _conditions = List.from(conditions);
    notifyListeners();
  }

  void toggleCondition(String condition) {
    final updated = List<String>.from(_conditions);
    if (updated.contains(condition)) {
      updated.remove(condition);
    } else {
      updated.add(condition);
    }
    _conditions = updated;
    notifyListeners();
  }

  void setSeverity(String domain, int level) {
    _severityMap[domain] = level.clamp(1, 5);
    notifyListeners();
  }

  void setGoals(List<String> goals) {
    _goals = List.from(goals);
    notifyListeners();
  }

  void toggleGoal(String goal) {
    final updated = List<String>.from(_goals);
    if (updated.contains(goal)) {
      updated.remove(goal);
    } else {
      updated.add(goal);
    }
    _goals = updated;
    notifyListeners();
  }

  void setSchedule({int? sessionsPerWeek, int? minutesPerSession}) {
    if (sessionsPerWeek != null) _sessionsPerWeek = sessionsPerWeek;
    if (minutesPerSession != null) _minutesPerSession = minutesPerSession;
    notifyListeners();
  }

  // ── Finalize ───────────────────────────────────────────────────────
  Future<bool> completeOnboarding() async {
    _isLoading = true;
    notifyListeners();

    try {
      final profile = PatientProfileModel(
        userId: _userId,
        conditions: _conditions,
        severityMap: _severityMap,
        goals: _goals,
        sessionsPerWeek: _sessionsPerWeek,
        minutesPerSession: _minutesPerSession,
        dominantLanguage: 'en-US',
        consentResearch: false,
        consentDataSharing: false,
        onboardingCompletedAt: DateTime.now(),
      );

      await _profileRepo.savePatientProfile(profile);
      await _localStore.setOnboardingComplete(true);

      _error = null;
      AppLogger.info('Onboarding completed', tag: 'OnboardingViewModel');
      return true;
    } catch (e) {
      _error = ApiErrorMapper.map(e);
      AppLogger.error('Onboarding failed', error: e, tag: 'OnboardingViewModel');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Build a summary of selected goals for the welcome step.
  PatientProfileModel get draftProfile => PatientProfileModel(
        userId: _userId,
        conditions: _conditions,
        severityMap: _severityMap,
        goals: _goals,
        sessionsPerWeek: _sessionsPerWeek,
        minutesPerSession: _minutesPerSession,
      );
}
