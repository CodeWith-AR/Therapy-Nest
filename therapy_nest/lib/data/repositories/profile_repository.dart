import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/errors/api_error_mapper.dart';
import '../../core/utils/logger.dart';
import '../models/patient_profile_model.dart';

/// Handles patient profile CRUD operations via Supabase.
class ProfileRepository {
  SupabaseClient get _client => Supabase.instance.client;

  /// Save a new patient profile (upsert).
  Future<void> savePatientProfile(PatientProfileModel profile) async {
    try {
      await _client.from('patient_profiles').upsert(profile.toJson());
      AppLogger.info('Patient profile saved', tag: 'ProfileRepository');
    } catch (e) {
      AppLogger.error('Save profile failed',
          error: e, tag: 'ProfileRepository');
      throw ApiErrorMapper.map(e);
    }
  }

  /// Get the patient profile for a given user ID.
  Future<PatientProfileModel?> getPatientProfile(String userId) async {
    try {
      final data = await _client
          .from('patient_profiles')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (data == null) return null;
      return PatientProfileModel.fromJson(data);
    } catch (e) {
      AppLogger.error('Get profile failed',
          error: e, tag: 'ProfileRepository');
      return null;
    }
  }

  /// Update an existing patient profile.
  Future<void> updateProfile(PatientProfileModel profile) async {
    try {
      await _client
          .from('patient_profiles')
          .update(profile.toJson())
          .eq('user_id', profile.userId);
      AppLogger.info('Patient profile updated', tag: 'ProfileRepository');
    } catch (e) {
      AppLogger.error('Update profile failed',
          error: e, tag: 'ProfileRepository');
      throw ApiErrorMapper.map(e);
    }
  }
}
