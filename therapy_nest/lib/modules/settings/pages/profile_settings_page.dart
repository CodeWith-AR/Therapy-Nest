import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../app/routes/app_routes.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../modules/auth/viewmodels/auth_view_model.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../../data/models/patient_profile_model.dart';

/// Redesigned Profile settings page matching mockup perfectly.
/// Exposes structured modal dialog selectors for goals and schedules, ensuring users
/// select predefined, correct clinical options rather than typing arbitrary text.
class ProfileSettingsPage extends StatefulWidget {
  const ProfileSettingsPage({super.key});

  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  late final TextEditingController _nameController;
  late final TextEditingController _goalsController;
  late final TextEditingController _scheduleController;
  bool _hasChanges = false;
  bool _isLoading = false;
  String? _avatarUrl;

  List<String> _selectedGoals = [];
  int _sessionsPerWeek = 3;
  int _minutesPerSession = 20;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthViewModel>().currentUser;
    _nameController = TextEditingController(text: user?.fullName ?? '');
    _goalsController = TextEditingController();
    _scheduleController = TextEditingController();

    _loadPatientProfile();
  }

  static const Map<String, String> _goalLabels = {
    'speaking': 'Speaking more clearly',
    'understanding': 'Understanding conversations',
    'reading': 'Reading and writing',
    'memory': 'Memory and focus',
    'math': 'Everyday math (money, time)',
    'problem_solving': 'Problem solving',
  };

  String _formatGoalsDisplay(List<String> goals) {
    if (goals.isEmpty) return '';
    final labels = goals.map((g) {
      final match = _goalLabels.entries.firstWhere(
        (e) => e.key == g || e.value.toLowerCase() == g.toLowerCase(),
        orElse: () => MapEntry(g, g),
      );
      return match.value;
    }).toList();
    return labels.join(', ');
  }

  Future<void> _loadPatientProfile() async {
    final authViewModel = context.read<AuthViewModel>();
    final profileRepo = context.read<ProfileRepository>();
    final userId = authViewModel.currentUser?.id;
    if (userId == null) return;

    setState(() => _isLoading = true);

    // 1. Resolve avatar: Local cache first, then remote
    String? resolvedAvatarUrl;
    try {
      final prefs = await SharedPreferences.getInstance();
      final localAvatar = prefs.getString('avatar_local_$userId');
      if (localAvatar != null && localAvatar.isNotEmpty && File(localAvatar).existsSync()) {
        resolvedAvatarUrl = localAvatar;
      }
    } catch (_) {}

    try {
      final userRow = await Supabase.instance.client
          .from('user_profiles')
          .select('avatar_url')
          .eq('id', userId)
          .maybeSingle();
      final remoteAvatar = userRow?['avatar_url'] as String?;
      if (remoteAvatar != null && remoteAvatar.isNotEmpty) {
        resolvedAvatarUrl = remoteAvatar;
      }
    } catch (_) {
      // Column avatar_url might not exist yet or offline; gracefully fallback
    }

    // 2. Load patient profile independently
    PatientProfileModel? profile;
    try {
      profile = await profileRepo.getPatientProfile(userId);
    } catch (e) {
      debugPrint('[ProfileSettings] Failed to fetch patient profile: $e');
    }

    if (mounted) {
      setState(() {
        _avatarUrl = resolvedAvatarUrl;
        if (profile != null) {
          _selectedGoals = List<String>.from(profile.goals);
          _sessionsPerWeek = profile.sessionsPerWeek;
          _minutesPerSession = profile.minutesPerSession;
        }
        _goalsController.text = _formatGoalsDisplay(_selectedGoals);
        _scheduleController.text = _formatScheduleText(_sessionsPerWeek, _minutesPerSession);
        _isLoading = false;
        _hasChanges = false;
      });
      _nameController.addListener(_markDirty);
    }
  }

  String _formatScheduleText(int sessions, int minutes) {
    final frequencyText = switch (sessions) {
      7 => 'Every day',
      5 => '5 days a week',
      3 => '3 days a week',
      _ => 'Whenever I can',
    };
    final durationText = switch (minutes) {
      15 => 'Flexible',
      _ => '$minutes min',
    };
    return '$frequencyText, $durationText';
  }

  void _markDirty() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
  }

  Future<void> _savePracticeSetup({String? successMessage}) async {
    final authViewModel = context.read<AuthViewModel>();
    final profileRepo = context.read<ProfileRepository>();
    final userId = authViewModel.currentUser?.id;
    if (userId == null) return;

    try {
      final existingProfile = await profileRepo.getPatientProfile(userId);
      final updatedProfile = (existingProfile ?? PatientProfileModel(userId: userId)).copyWith(
        goals: _selectedGoals,
        sessionsPerWeek: _sessionsPerWeek,
        minutesPerSession: _minutesPerSession,
      );
      await profileRepo.savePatientProfile(updatedProfile);

      if (mounted && successMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              successMessage,
              style: AppTextStyles.bodySm.copyWith(color: AppColors.onPrimary),
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('[ProfileSettings] Failed to save practice setup: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _pickAndUploadAvatar() async {
    final userId = context.read<AuthViewModel>().currentUser?.id;
    if (userId == null) return;
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (pickedFile == null) return;

    setState(() => _isLoading = true);

    try {
      final bytes = await pickedFile.readAsBytes();
      final fileExt = pickedFile.name.split('.').last.toLowerCase();

      // 1. Immediately cache image to device local storage
      final appDir = await getApplicationDocumentsDirectory();
      final localFile = File('${appDir.path}/avatar_$userId.$fileExt');
      await localFile.writeAsBytes(bytes);

      // Save local path to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('avatar_local_$userId', localFile.path);

      // Update UI immediately with local file!
      if (mounted) {
        setState(() => _avatarUrl = localFile.path);
      }

      // 2. Attempt remote sync to Supabase Storage bucket 'avatars'
      bool remoteSynced = false;
      try {
        final remotePath = '$userId/avatar.$fileExt';
        await Supabase.instance.client.storage
            .from('avatars')
            .uploadBinary(
              remotePath,
              bytes,
              fileOptions: const FileOptions(upsert: true),
            );

        final publicUrl = Supabase.instance.client.storage
            .from('avatars')
            .getPublicUrl(remotePath);

        try {
          await Supabase.instance.client
              .from('user_profiles')
              .update({'avatar_url': publicUrl})
              .eq('id', userId);
        } catch (_) {}

        remoteSynced = true;
        if (mounted) {
          setState(() => _avatarUrl = publicUrl);
          await context.read<AuthViewModel>().checkAuth();
        }
      } catch (storageError) {
        debugPrint('[ProfileSettings] Remote avatar upload skipped/failed: $storageError');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              remoteSynced
                  ? 'Profile picture updated and synced!'
                  : 'Profile picture saved locally! (Run Supabase SQL migration for cloud sync)',
              style: AppTextStyles.bodySm.copyWith(color: AppColors.onPrimary),
            ),
            backgroundColor: remoteSynced ? AppColors.success : AppColors.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update picture: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _goalsController.dispose();
    _scheduleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthViewModel>().currentUser;
    final name = user?.fullName ?? 'User';
    final email = user?.email ?? '';

    final initials = name.isNotEmpty
        ? name
            .split(' ')
            .where((w) => w.isNotEmpty)
            .take(2)
            .map((w) => w[0].toUpperCase())
            .join()
        : '?';

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.canvas,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: AppColors.ink),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          AppStrings.profileTitle,
          style: AppTextStyles.appBarTitle.copyWith(color: AppColors.ink),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: AppColors.hairline,
            height: 1.0,
          ),
        ),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppDimens.d16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else if (_hasChanges)
            TextButton(
              onPressed: _saveProfile,
              child: Text(
                AppStrings.save,
                style: AppTextStyles.buttonSm.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.d16,
          vertical: AppDimens.d20,
        ),
        children: [
          // ── Profile Header Section ───────────────────────────────────
          Center(
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 128,
                      height: 128,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryLight,
                        border: Border.all(color: AppColors.hairline),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: _avatarUrl != null && _avatarUrl!.isNotEmpty
                            ? (_avatarUrl!.startsWith('http')
                                ? Image.network(
                                    _avatarUrl!,
                                    fit: BoxFit.cover,
                                    width: 128,
                                    height: 128,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Center(
                                        child: Text(
                                          initials,
                                          style: AppTextStyles.displayLg.copyWith(
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      );
                                    },
                                  )
                                : Image.file(
                                    File(_avatarUrl!),
                                    fit: BoxFit.cover,
                                    width: 128,
                                    height: 128,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Center(
                                        child: Text(
                                          initials,
                                          style: AppTextStyles.displayLg.copyWith(
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      );
                                    },
                                  ))
                            : Center(
                                child: Text(
                                  initials,
                                  style: AppTextStyles.displayLg.copyWith(
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickAndUploadAvatar,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.edit_rounded,
                            color: AppColors.onPrimary,
                            size: AppDimens.iconSm,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.d16),
                Text(
                  name,
                  style: AppTextStyles.displayLg.copyWith(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppDimens.d4),
                Text(
                  email,
                  style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.d32),

          // ── Personal Information Section ─────────────────────────────
          _buildSectionHeader('Personal Information'),
          const SizedBox(height: AppDimens.d8),
          _GroupCard(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppDimens.d16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppDimens.d8),
                      child: Text(
                        AppStrings.profileUpdateName.toUpperCase(),
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.muted,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    TextFormField(
                      controller: _nameController,
                      onChanged: (_) {
                        setState(() {});
                        _markDirty();
                      },
                      style: AppTextStyles.bodyLg.copyWith(color: AppColors.ink),
                      decoration: InputDecoration(
                        hintText: 'Jane Doe',
                        hintStyle: AppTextStyles.bodyLg.copyWith(
                          color: AppColors.mutedSoft,
                        ),
                        filled: true,
                        fillColor: AppColors.surfaceSoft,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        suffixIcon: _nameController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  Icons.cancel_rounded,
                                  color: AppColors.mutedSoft,
                                  size: 20,
                                ),
                                onPressed: () {
                                  _nameController.clear();
                                  setState(() {});
                                  _markDirty();
                                },
                              )
                            : null,
                        border: UnderlineInputBorder(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8),
                          ),
                          borderSide: BorderSide(color: AppColors.hairline),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8),
                          ),
                          borderSide: BorderSide(color: AppColors.hairline),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8),
                          ),
                          borderSide: BorderSide(color: AppColors.primary, width: 2),
                        ),
                        errorBorder: UnderlineInputBorder(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8),
                          ),
                          borderSide: BorderSide(color: AppColors.error),
                        ),
                        focusedErrorBorder: UnderlineInputBorder(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8),
                          ),
                          borderSide: BorderSide(color: AppColors.error, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.d24),

          // ── Practice Setup Section ───────────────────────────────────
          _buildSectionHeader('Practice Setup'),
          const SizedBox(height: AppDimens.d8),
          _GroupCard(
            children: [
              _ClickableEditRow(
                title: 'Practice Goals',
                value: _goalsController.text.isNotEmpty
                    ? _goalsController.text
                    : 'No goals set',
                onTap: () => _editGoals(context),
              ),
              _buildDivider(),
              _ClickableEditRow(
                title: 'Practice Schedule',
                value: _scheduleController.text.isNotEmpty
                    ? _scheduleController.text
                    : 'No schedule set',
                onTap: () => _editSchedule(context),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.d24),

          // ── Data & Privacy Section ───────────────────────────────────
          _buildSectionHeader('Data & Privacy'),
          const SizedBox(height: AppDimens.d8),
          _GroupCard(
            children: [
              InkWell(
                onTap: _downloadData,
                borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                child: Padding(
                  padding: const EdgeInsets.all(AppDimens.d16),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.canvas,
                          border: Border.all(color: AppColors.hairline),
                        ),
                        child: Icon(
                          Icons.download_rounded,
                          color: AppColors.primary,
                          size: AppDimens.iconMd,
                        ),
                      ),
                      const SizedBox(width: AppDimens.d12),
                      Expanded(
                        child: Text(
                          AppStrings.profileDownloadData,
                          style: AppTextStyles.bodyLg.copyWith(
                            color: AppColors.ink,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.muted,
                        size: AppDimens.iconMd,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.d32),

          // ── Delete Account Section ───────────────────────────────────
          InkWell(
            onTap: _confirmDeleteAccount,
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            child: Container(
              height: AppDimens.touchMin,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.delete_forever_rounded,
                    color: AppColors.error,
                    size: AppDimens.iconMd,
                  ),
                  const SizedBox(width: AppDimens.d8),
                  Text(
                    AppStrings.profileDeleteAccount,
                    style: AppTextStyles.bodyLg.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppDimens.d8),
          Text(
            'This action cannot be undone. Please proceed with caution.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySm.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: AppDimens.d40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: AppDimens.d16),
      child: Text(
        title.toUpperCase(),
        style: AppTextStyles.label.copyWith(
          color: AppColors.muted,
          letterSpacing: 1.0,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: AppDimens.d16),
      color: AppColors.hairline,
    );
  }

  Future<void> _editGoals(BuildContext context) async {
    final updatedGoals = await showDialog<List<String>>(
      context: context,
      builder: (ctx) => _EditGoalsDialog(initialGoals: _selectedGoals),
    );
    if (updatedGoals != null && mounted) {
      setState(() {
        _selectedGoals = updatedGoals;
        _goalsController.text = _formatGoalsDisplay(_selectedGoals);
        _hasChanges = true;
      });
      await _savePracticeSetup(successMessage: 'Practice goals updated successfully!');
      if (mounted) {
        setState(() => _hasChanges = false);
      }
    }
  }

  Future<void> _editSchedule(BuildContext context) async {
    final result = await showDialog<Map<String, int>>(
      context: context,
      builder: (ctx) => _EditScheduleDialog(
        initialSessions: _sessionsPerWeek,
        initialMinutes: _minutesPerSession,
      ),
    );
    if (result != null && mounted) {
      setState(() {
        _sessionsPerWeek = result['sessions'] ?? 3;
        _minutesPerSession = result['minutes'] ?? 20;
        _scheduleController.text = _formatScheduleText(_sessionsPerWeek, _minutesPerSession);
        _hasChanges = true;
      });
      await _savePracticeSetup(successMessage: 'Practice schedule updated successfully!');
      if (mounted) {
        setState(() => _hasChanges = false);
      }
    }
  }

  Future<void> _saveProfile() async {
    final authViewModel = context.read<AuthViewModel>();
    final profileRepo = context.read<ProfileRepository>();
    final userId = authViewModel.currentUser?.id;
    if (userId == null) return;

    setState(() => _isLoading = true);

    try {
      final name = _nameController.text.trim();

      // 1. Update name in user_profiles
      await Supabase.instance.client
          .from('user_profiles')
          .update({'full_name': name})
          .eq('id', userId);

      await authViewModel.checkAuth();

      // 2. Save patient profile
      final existingProfile = await profileRepo.getPatientProfile(userId);
      final updatedProfile = (existingProfile ?? PatientProfileModel(userId: userId)).copyWith(
        goals: _selectedGoals,
        sessionsPerWeek: _sessionsPerWeek,
        minutesPerSession: _minutesPerSession,
      );

      await profileRepo.savePatientProfile(updatedProfile);

      setState(() => _hasChanges = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppStrings.profileSaved,
              style: AppTextStyles.bodySm.copyWith(color: AppColors.onPrimary),
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to save profile: $e',
              style: AppTextStyles.bodySm.copyWith(color: AppColors.onPrimary),
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _downloadData() async {
    final authViewModel = context.read<AuthViewModel>();
    final profileRepo = context.read<ProfileRepository>();
    final userId = authViewModel.currentUser?.id;
    if (userId == null) return;

    setState(() => _isLoading = true);

    try {
      final profile = await profileRepo.getPatientProfile(userId);
      final user = authViewModel.currentUser;

      final exportData = {
        'exported_at': DateTime.now().toIso8601String(),
        'user': {
          'id': user?.id,
          'email': user?.email,
          'full_name': user?.fullName,
          'role': user?.role,
        },
        'profile': profile?.toJson() ?? {},
      };

      final jsonStr = const JsonEncoder.withIndent('  ').convert(exportData);

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.canvas,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusLg),
              side: BorderSide(color: AppColors.hairlineSoft),
            ),
            title: Text(
              'Exported Profile Data',
              style: AppTextStyles.titleLg.copyWith(
                color: AppColors.ink,
                fontWeight: FontWeight.w600,
              ),
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: Container(
                padding: const EdgeInsets.all(AppDimens.d12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSoft,
                  borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                  border: Border.all(color: AppColors.hairline),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    jsonStr,
                    style: AppTextStyles.caption.copyWith(
                      fontFamily: 'monospace',
                      color: AppColors.ink,
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Close',
                  style: AppTextStyles.buttonSm.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to export data: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _confirmDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          AppStrings.profileDeleteConfirmTitle,
          style: AppTextStyles.titleLg.copyWith(color: AppColors.ink),
        ),
        content: Text(
          AppStrings.profileDeleteConfirmBody,
          style: AppTextStyles.bodyMd.copyWith(color: AppColors.body),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              AppStrings.profileDeleteConfirmButton,
              style: AppTextStyles.buttonSm.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      _secondConfirmDeleteAccount();
    }
  }

  Future<void> _secondConfirmDeleteAccount() async {
    final deleteController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          AppStrings.profileDeleteSecondTitle,
          style: AppTextStyles.titleLg.copyWith(color: AppColors.ink),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.profileDeleteSecondBody,
              style: AppTextStyles.bodyMd.copyWith(color: AppColors.body),
            ),
            const SizedBox(height: AppDimens.d16),
            TextField(
              controller: deleteController,
              autofocus: true,
              style: AppTextStyles.bodyMd.copyWith(color: AppColors.ink),
              decoration: InputDecoration(
                hintText: 'Type DELETE to confirm',
                hintStyle: AppTextStyles.bodyMd.copyWith(
                  color: AppColors.mutedSoft,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () {
              if (deleteController.text.trim().toUpperCase() == 'DELETE') {
                Navigator.of(ctx).pop(true);
              }
            },
            child: Text(
              AppStrings.profileDeleteConfirmButton,
              style: AppTextStyles.buttonSm.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    deleteController.dispose();

    if (confirmed == true && mounted) {
      await _performAccountDeletion();
    }
  }

  Future<void> _performAccountDeletion() async {
    final authViewModel = context.read<AuthViewModel>();
    final userId = authViewModel.currentUser?.id;
    if (userId == null) return;
    setState(() => _isLoading = true);
    try {
      final client = Supabase.instance.client;
      // 1. Cascade delete user data
      await client.from('exercise_attempts').delete().eq('patient_id', userId);
      await client.from('therapy_sessions').delete().eq('patient_id', userId);
      await client.from('ability_estimates').delete().eq('patient_id', userId);
      await client.from('patient_profiles').delete().eq('user_id', userId);
      await client.from('user_profiles').delete().eq('id', userId);
      // 2. Sign out
      await authViewModel.logout();
      if (mounted) {
        context.go(AppRoutes.login);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete account: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

// ── Group Card Wrapper Widget ───────────────────────────────────────────

class _GroupCard extends StatelessWidget {
  const _GroupCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(color: AppColors.hairlineSoft),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }
}

// ── Clickable Row for Goals/Schedule updates ────────────────────────────

class _ClickableEditRow extends StatelessWidget {
  const _ClickableEditRow({
    required this.title,
    required this.value,
    required this.onTap,
  });

  final String title;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.d16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyLg.copyWith(
                      color: AppColors.ink,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppDimens.d4),
                  Text(
                    value,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySm.copyWith(
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppDimens.d12),
            Icon(
              Icons.edit_rounded,
              color: AppColors.mutedSoft,
              size: AppDimens.iconMd,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Edit Goals Dialog Widget ───────────────────────────────────────────

class _EditGoalsDialog extends StatefulWidget {
  const _EditGoalsDialog({required this.initialGoals});
  final List<String> initialGoals;

  @override
  State<_EditGoalsDialog> createState() => _EditGoalsDialogState();
}

class _EditGoalsDialogState extends State<_EditGoalsDialog> {
  late final List<String> _tempGoals;

  /// Bidirectional mapping: onboarding IDs ↔ display labels.
  static const Map<String, String> _goalMap = {
    'speaking': 'Speaking more clearly',
    'understanding': 'Understanding conversations',
    'reading': 'Reading and writing',
    'memory': 'Memory and focus',
    'math': 'Everyday math (money, time)',
    'problem_solving': 'Problem solving',
  };

  @override
  void initState() {
    super.initState();
    // Normalize incoming goals (handle both IDs and legacy label strings)
    _tempGoals = widget.initialGoals.map((g) {
      final match = _goalMap.entries.firstWhere(
        (e) => e.key == g || e.value.toLowerCase() == g.toLowerCase(),
        orElse: () => MapEntry(g, g),
      );
      return match.key;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.canvas,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        side: BorderSide(color: AppColors.hairlineSoft),
      ),
      title: Text(
        'Select Practice Goals',
        style: AppTextStyles.titleLg.copyWith(
          color: AppColors.ink,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _goalMap.entries.map((entry) {
              final goalId = entry.key;
              final goalLabel = entry.value;
              final isChecked = _tempGoals.contains(goalId);
              return Padding(
                padding: const EdgeInsets.only(bottom: AppDimens.d8),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      if (isChecked) {
                        _tempGoals.remove(goalId);
                      } else {
                        _tempGoals.add(goalId);
                      }
                    });
                  },
                  borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: isChecked ? AppColors.primaryLight : AppColors.surfaceSoft,
                      borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                      border: Border.all(
                        color: isChecked ? AppColors.primary : AppColors.hairline,
                        width: isChecked ? 2.0 : 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isChecked ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                          color: isChecked ? AppColors.primary : AppColors.mutedSoft,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            goalLabel,
                            style: AppTextStyles.bodyMd.copyWith(
                              color: isChecked ? AppColors.primary : AppColors.ink,
                              fontWeight: isChecked ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            AppStrings.cancel,
            style: AppTextStyles.buttonSm.copyWith(color: AppColors.muted),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_tempGoals),
          child: Text(
            AppStrings.save,
            style: AppTextStyles.buttonSm.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Edit Schedule Dialog Widget ────────────────────────────────────────

class _EditScheduleDialog extends StatefulWidget {
  const _EditScheduleDialog({
    required this.initialSessions,
    required this.initialMinutes,
  });
  final int initialSessions;
  final int initialMinutes;

  @override
  State<_EditScheduleDialog> createState() => _EditScheduleDialogState();
}

class _EditScheduleDialogState extends State<_EditScheduleDialog> {
  late int _tempSessions;
  late int _tempMinutes;

  final List<Map<String, dynamic>> _frequencies = const [
    {'label': 'Every day', 'val': 7},
    {'label': '5 days a week', 'val': 5},
    {'label': '3 days a week', 'val': 3},
    {'label': 'Whenever I can', 'val': 1},
  ];

  final List<Map<String, dynamic>> _durations = const [
    {'label': '10 min', 'val': 10},
    {'label': '20 min', 'val': 20},
    {'label': '30 min', 'val': 30},
    {'label': 'Flexible', 'val': 15},
  ];

  @override
  void initState() {
    super.initState();
    _tempSessions = widget.initialSessions;
    _tempMinutes = widget.initialMinutes;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.canvas,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        side: BorderSide(color: AppColors.hairlineSoft),
      ),
      title: Text(
        'Select Practice Schedule',
        style: AppTextStyles.titleLg.copyWith(
          color: AppColors.ink,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
                child: Text(
                  'How often would you like to practice?',
                  style: AppTextStyles.bodyLg.copyWith(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ..._frequencies.map((freq) {
                final isSelected = _tempSessions == freq['val'];
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppDimens.d8),
                  child: InkWell(
                    onTap: () {
                      setState(() => _tempSessions = freq['val'] as int);
                    },
                    borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primaryLight : AppColors.surfaceSoft,
                        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.hairline,
                          width: isSelected ? 2.0 : 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                            color: isSelected ? AppColors.primary : AppColors.mutedSoft,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            freq['label'] as String,
                            style: AppTextStyles.bodyMd.copyWith(
                              color: isSelected ? AppColors.primary : AppColors.ink,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Divider(color: AppColors.hairline),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
                child: Text(
                  'How long per session?',
                  style: AppTextStyles.bodyLg.copyWith(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ..._durations.map((dur) {
                final isSelected = _tempMinutes == dur['val'];
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppDimens.d8),
                  child: InkWell(
                    onTap: () {
                      setState(() => _tempMinutes = dur['val'] as int);
                    },
                    borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primaryLight : AppColors.surfaceSoft,
                        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.hairline,
                          width: isSelected ? 2.0 : 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                            color: isSelected ? AppColors.primary : AppColors.mutedSoft,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            dur['label'] as String,
                            style: AppTextStyles.bodyMd.copyWith(
                              color: isSelected ? AppColors.primary : AppColors.ink,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            AppStrings.cancel,
            style: AppTextStyles.buttonSm.copyWith(color: AppColors.muted),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop({
            'sessions': _tempSessions,
            'minutes': _tempMinutes,
          }),
          child: Text(
            AppStrings.save,
            style: AppTextStyles.buttonSm.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
