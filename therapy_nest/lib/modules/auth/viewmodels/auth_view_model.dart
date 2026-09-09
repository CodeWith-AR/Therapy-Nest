import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/api_error_mapper.dart';
import '../../../core/errors/failure.dart';
import '../../../core/utils/logger.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';

/// App-wide authentication state — provided at the root level.
class AuthViewModel extends ChangeNotifier {
  AuthViewModel(this._repo) {
    _initAuthListener();
  }

  final AuthRepository _repo;
  StreamSubscription<AuthState>? _authSubscription;

  UserModel? _currentUser;
  bool _isLoading = false;
  Failure? _error;

  // ── Getters ────────────────────────────────────────────────────────
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  Failure? get error => _error;
  bool get isLoggedIn => _currentUser != null;

  // ── Actions ────────────────────────────────────────────────────────

  /// Check if user has an existing session and load profile.
  Future<void> checkAuth() async {
    _setLoading(true);
    try {
      _currentUser = await _repo.getCurrentUser();
      _error = null;
      AppLogger.info(
        'Auth check: ${_currentUser != null ? "logged in" : "not logged in"}',
        tag: 'AuthViewModel',
      );
    } catch (e) {
      _error = ApiErrorMapper.map(e);
      _currentUser = null;
    } finally {
      _setLoading(false);
    }
  }

  /// Sign in with email and password.
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    try {
      _currentUser = await _repo.login(email, password);
      _error = null;
      return true;
    } catch (e) {
      _error = ApiErrorMapper.map(e);
      _currentUser = null;
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Sign in with Google OAuth.
  Future<void> loginWithGoogle() async {
    _setLoading(true);
    try {
      await _repo.loginWithGoogle();
      _error = null;
    } catch (e) {
      _error = ApiErrorMapper.map(e);
    } finally {
      _setLoading(false);
    }
  }

  /// Register a new user.
  Future<bool> register(
      String email, String password, String fullName) async {
    _setLoading(true);
    try {
      _currentUser = await _repo.register(email, password, fullName);
      _error = null;
      return true;
    } catch (e) {
      _error = ApiErrorMapper.map(e);
      _currentUser = null;
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Sign out the current user.
  Future<void> logout() async {
    _setLoading(true);
    try {
      await _repo.logout();
      _currentUser = null;
      _error = null;
    } catch (e) {
      _error = ApiErrorMapper.map(e);
    } finally {
      _setLoading(false);
    }
  }

  /// Send a password reset email.
  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    try {
      await _repo.resetPassword(email);
      _error = null;
      return true;
    } catch (e) {
      _error = ApiErrorMapper.map(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Clear any error state.
  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _initAuthListener() {
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      AppLogger.info('Auth state changed: $event', tag: 'AuthViewModel');

      if (event == AuthChangeEvent.signedIn || event == AuthChangeEvent.tokenRefreshed) {
        if (session != null) {
          _currentUser = await _repo.getCurrentUser();
          notifyListeners();
        }
      } else if (event == AuthChangeEvent.signedOut) {
        _currentUser = null;
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
