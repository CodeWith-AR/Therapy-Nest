import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/errors/api_error_mapper.dart';
import '../../core/utils/logger.dart';
import '../local_db/app_database.dart';
import '../models/user_model.dart';
import '../storage/local_store.dart';
import '../storage/token_store.dart';

/// Handles all authentication operations via Supabase Auth.
class AuthRepository {
  AuthRepository(this._tokenStore, this._db, this._localStore);

  final TokenStore _tokenStore;
  final AppDatabase _db;
  final LocalStore _localStore;
  SupabaseClient get _client => Supabase.instance.client;

  /// Sign in with email and password.
  Future<UserModel> login(String email, String password) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      if (response.session != null) {
        await _tokenStore.setAccessToken(response.session!.accessToken);
        if (response.session!.refreshToken != null) {
          await _tokenStore.setRefreshToken(response.session!.refreshToken!);
        }
      }

      final user = _userFromAuth(response.user!);
      await _handleUserSwitch(user.id);
      return user;
    } catch (e) {
      AppLogger.error('Login failed', error: e, tag: 'AuthRepository');
      throw ApiErrorMapper.map(e);
    }
  }

  /// Sign in with Google OAuth.
  Future<void> loginWithGoogle() async {
    try {
      await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'com.therapynest.app://login-callback',
      );
    } catch (e) {
      AppLogger.error('Google login failed', error: e, tag: 'AuthRepository');
      throw ApiErrorMapper.map(e);
    }
  }

  /// Register a new user with email and password.
  Future<UserModel> register(
    String email,
    String password,
    String fullName,
  ) async {
    try {
      final response = await _client.auth.signUp(
        email: email.trim(),
        password: password,
        data: {'full_name': fullName.trim()},
      );

      if (response.session != null) {
        await _tokenStore.setAccessToken(response.session!.accessToken);
        if (response.session!.refreshToken != null) {
          await _tokenStore.setRefreshToken(response.session!.refreshToken!);
        }
      }

      final user = _userFromAuth(response.user!);
      // New account: clean slate for onboarding, assessments, and local data
      await _db.clearUserData();
      await _localStore.remove('onboarding_complete');
      await _localStore.setLastUserId(user.id);
      return user;
    } catch (e) {
      AppLogger.error('Registration failed', error: e, tag: 'AuthRepository');
      throw ApiErrorMapper.map(e);
    }
  }

  /// Sign out the current user.
  Future<void> logout() async {
    try {
      await _client.auth.signOut();
      await _tokenStore.clearTokens();
      await _db.clearUserData();
      await _localStore.remove('onboarding_complete');
    } catch (e) {
      AppLogger.error('Logout failed', error: e, tag: 'AuthRepository');
      await _tokenStore.clearTokens();
      await _db.clearUserData();
      await _localStore.remove('onboarding_complete');
    }
  }

  Future<void> _handleUserSwitch(String currentUserId) async {
    final lastUserId = await _localStore.lastUserId;
    if (lastUserId != null && lastUserId != currentUserId) {
      await _db.clearUserData();
      await _localStore.remove('onboarding_complete');
    }
    await _localStore.setLastUserId(currentUserId);
  }

  /// Get the currently authenticated user.
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;

      // Fetch profile from user_profiles table
      final profileData = await _client
          .from('user_profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (profileData != null) {
        return UserModel(
          id: user.id,
          email: user.email ?? '',
          fullName: profileData['full_name'] as String?,
          avatarUrl: profileData['avatar_url'] as String?,
          role: profileData['role'] as String? ?? 'patient',
          locale: profileData['locale'] as String? ?? 'en-US',
          createdAt: profileData['created_at'] != null
              ? DateTime.parse(profileData['created_at'] as String)
              : DateTime.now(),
          lastLoginAt: profileData['last_login_at'] != null
              ? DateTime.parse(profileData['last_login_at'] as String)
              : null,
        );
      }

      return _userFromAuth(user);
    } catch (e) {
      AppLogger.error('Get current user failed',
          error: e, tag: 'AuthRepository');
      return null;
    }
  }

  /// Send a password reset email.
  Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email.trim());
    } catch (e) {
      AppLogger.error('Password reset failed',
          error: e, tag: 'AuthRepository');
      throw ApiErrorMapper.map(e);
    }
  }

  /// Whether a session exists (may not be valid).
  bool get hasSession => _client.auth.currentSession != null;

  /// Convert Supabase [User] to [UserModel].
  UserModel _userFromAuth(User user) {
    return UserModel(
      id: user.id,
      email: user.email ?? '',
      fullName: user.userMetadata?['full_name'] as String?,
      role: 'patient',
      locale: 'en-US',
      createdAt: DateTime.tryParse(user.createdAt) ?? DateTime.now(),
    );
  }
}
