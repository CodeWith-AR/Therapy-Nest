import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_toast.dart';
import '../viewmodels/auth_view_model.dart';

/// Redesigned Register Page matching the mockup register screen perfectly.
/// Features a custom AppBar, Georgia header, info disclaimer box,
/// small caps labels above inputs, bottom hairline borders, and custom checkbox.
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _acceptedTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_acceptedTerms) {
      AppToast.warning(context, AppStrings.acceptTerms);
      return;
    }

    final authVM = context.read<AuthViewModel>();
    final success = await authVM.register(
      _emailController.text,
      _passwordController.text,
      _nameController.text,
    );

    if (!mounted) return;

    if (success) {
      context.go(AppRoutes.onboarding);
    } else if (authVM.error != null) {
      AppToast.error(context, authVM.error!.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select<AuthViewModel, bool>((vm) => vm.isLoading);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.canvas,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.ink),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
        ),
        title: Text(
          'Profile',
          style: AppTextStyles.appBarTitle.copyWith(
            color: AppColors.ink,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: AppColors.hairlineSoft,
            height: 1.0,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppDimens.d24, vertical: AppDimens.d16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Header ─────────────────────────────────────────
                  Text(
                    'Create Account',
                    style: AppTextStyles.displayLg.copyWith(
                      color: AppColors.ink,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppDimens.d4),
                  Text(
                    'Join Therapy Nest to start your journey.',
                    style: AppTextStyles.bodyLg.copyWith(
                      color: AppColors.muted,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppDimens.d24),

                  // ── Info Box Banner ────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(AppDimens.d16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSoft,
                      borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                      border: Border.all(color: AppColors.hairlineSoft),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 22,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: AppDimens.d12),
                        Expanded(
                          child: Text(
                            'Therapy Nest is a practice companion, not a replacement for professional therapy.',
                            style: AppTextStyles.bodyMd.copyWith(
                              color: AppColors.muted,
                              height: 1.45,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimens.d32),

                  // ── Full Name Input ────────────────────────────────
                  _buildInputLabel('FULL NAME'),
                  _buildTextField(
                    controller: _nameController,
                    hint: 'Jane Doe',
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                    validator: Validators.fullName,
                  ),
                  const SizedBox(height: AppDimens.d20),

                  // ── Email Input ────────────────────────────────────
                  _buildInputLabel('EMAIL ADDRESS'),
                  _buildTextField(
                    controller: _emailController,
                    hint: 'jane@example.com',
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: Validators.email,
                  ),
                  const SizedBox(height: AppDimens.d20),

                  // ── Password Input ─────────────────────────────────
                  _buildInputLabel('PASSWORD'),
                  _buildTextField(
                    controller: _passwordController,
                    hint: '••••••••',
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.next,
                    validator: Validators.password,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        size: 20,
                        color: AppColors.muted,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  const SizedBox(height: AppDimens.d20),

                  // ── Confirm Password Input ─────────────────────────
                  _buildInputLabel('CONFIRM PASSWORD'),
                  _buildTextField(
                    controller: _confirmPasswordController,
                    hint: '••••••••',
                    obscureText: _obscureConfirm,
                    textInputAction: TextInputAction.done,
                    validator: (v) => Validators.confirmPassword(v, _passwordController.text),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                        size: 20,
                        color: AppColors.muted,
                      ),
                      onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                    onFieldSubmitted: (_) => _handleRegister(),
                  ),
                  const SizedBox(height: AppDimens.d24),

                  // ── Terms & Conditions Checkbox ────────────────────
                  GestureDetector(
                    onTap: () => setState(() => _acceptedTerms = !_acceptedTerms),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: _acceptedTerms ? AppColors.primary : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: _acceptedTerms ? AppColors.primary : AppColors.mutedSoft,
                                width: 2,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: _acceptedTerms
                                ? const Icon(
                                    Icons.check,
                                    size: 16,
                                    color: AppColors.onPrimary,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text.rich(
                              TextSpan(
                                text: 'I agree to the ',
                                style: AppTextStyles.bodyMd.copyWith(
                                  color: AppColors.muted,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Terms of Service',
                                    style: AppTextStyles.bodyMd.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.underline,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () async {
                                        final uri = Uri.parse(
                                            'https://therapy-nest-web.vercel.app/terms');
                                        if (await canLaunchUrl(uri)) {
                                          await launchUrl(uri,
                                              mode: LaunchMode.externalApplication);
                                        }
                                      },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimens.d24),

                  // ── Submit Register Button ─────────────────────────
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _handleRegister,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(Colors.white),
                              ),
                            )
                          : Text(
                              'Create Account',
                              style: AppTextStyles.button.copyWith(color: AppColors.onPrimary),
                            ),
                    ),
                  ),
                  const SizedBox(height: AppDimens.d32),

                  // ── Login Footer Redirect ──────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: AppTextStyles.bodyMd.copyWith(color: AppColors.muted),
                      ),
                      GestureDetector(
                        onTap: () {
                          if (Navigator.of(context).canPop()) {
                            context.pop();
                          } else {
                            context.go(AppRoutes.login);
                          }
                        },
                        child: Text(
                          'Sign In',
                          style: AppTextStyles.bodyMd.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.primary.withValues(alpha: 0.3),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimens.d24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.d8),
      child: Text(
        text,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.muted,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    bool obscureText = false,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    String? Function(String?)? validator,
    Widget? suffixIcon,
    ValueChanged<String>? onFieldSubmitted,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      onFieldSubmitted: onFieldSubmitted,
      style: AppTextStyles.bodyLg.copyWith(color: AppColors.ink),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.bodyLg.copyWith(color: AppColors.mutedSoft),
        filled: true,
        fillColor: AppColors.surfaceSoft,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        suffixIcon: suffixIcon,
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
    );
  }
}
