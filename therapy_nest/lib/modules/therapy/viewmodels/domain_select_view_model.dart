import 'package:flutter/foundation.dart';

import '../../../core/errors/failure.dart';
import '../../../core/utils/logger.dart';
import '../../../data/repositories/exercise_repository.dart';

/// Manages domain selection before starting a therapy session.
///
/// Loads available domains with their current θ estimates
/// and allows multi-select toggling.
///
/// Provided at route level (not app-wide).
class DomainSelectViewModel extends ChangeNotifier {
  DomainSelectViewModel(this._exerciseRepo);

  final ExerciseRepository _exerciseRepo;

  // ── State ──────────────────────────────────────────────────────────

  /// All available therapy domains.
  List<String> _availableDomains = [];
  List<String> get availableDomains => List.unmodifiable(_availableDomains);

  /// Currently selected domains.
  final Set<String> _selectedDomains = {};
  List<String> get selectedDomains => _selectedDomains.toList();

  /// Per-domain θ estimates (from last session / baseline).
  Map<String, double> _domainThetas = {};
  Map<String, double> get domainThetas => Map.unmodifiable(_domainThetas);

  /// Loading state.
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Last error.
  Failure? _error;
  Failure? get error => _error;

  // ── Derived State ─────────────────────────────────────────────────

  /// Whether at least one domain is selected.
  bool get canStartSession => _selectedDomains.isNotEmpty;

  /// Whether a domain is currently selected.
  bool isDomainSelected(String domain) => _selectedDomains.contains(domain);

  /// Normalized θ for display as a progress fraction (0.0 to 1.0).
  /// Maps θ [-3, 3] → [0, 1].
  double thetaProgress(String domain) {
    final theta = _domainThetas[domain] ?? 0.0;
    return ((theta + 3.0) / 6.0).clamp(0.0, 1.0);
  }

  // ── Actions ────────────────────────────────────────────────────────

  /// Loads domain data — available domains and their θ estimates.
  Future<void> loadDomainData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _availableDomains = List.from(ExerciseRepository.allDomains);
      _domainThetas = await _exerciseRepo.getAbilityEstimates();

      // Ensure all domains have a default θ
      for (final domain in _availableDomains) {
        _domainThetas.putIfAbsent(domain, () => 0.0);
      }

      AppLogger.info(
        'Domain data loaded: ${_availableDomains.length} domains',
        tag: 'DomainSelectVM',
      );
    } catch (e) {
      _error = const UnknownFailure('Failed to load domain data');
      AppLogger.error(
        'Load domain data failed',
        error: e,
        tag: 'DomainSelectVM',
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Toggles selection of a domain.
  void toggleDomain(String domain) {
    if (_selectedDomains.contains(domain)) {
      _selectedDomains.remove(domain);
    } else {
      _selectedDomains.add(domain);
    }
    notifyListeners();
  }

  /// Selects all domains.
  void selectAll() {
    _selectedDomains.addAll(_availableDomains);
    notifyListeners();
  }

  /// Deselects all domains.
  void deselectAll() {
    _selectedDomains.clear();
    notifyListeners();
  }
}
