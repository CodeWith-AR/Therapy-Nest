import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/app_toast.dart';
import '../viewmodels/auth_view_model.dart';

/// Forgot password page — enter email to receive reset link.
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleReset() async {
    if (!_formKey.currentState!.validate()) return;

    final authVM = context.read<AuthViewModel>();
    final success = await authVM.resetPassword(_emailController.text);

    if (!mounted) return;

    if (success) {
      AppToast.success(context, AppStrings.resetSent);
      context.pop();
    } else if (authVM.error != null) {
      AppToast.error(context, authVM.error!.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select<AuthViewModel, bool>((vm) => vm.isLoading);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimens.d24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Back button ────────────────────────────────
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      onPressed: () => context.pop(),
                    ),
                  ),

                  const SizedBox(height: AppDimens.d32),

                  // ── Icon ───────────────────────────────────────
                  Icon(
                    Icons.lock_reset_rounded,
                    size: AppDimens.d64,
                    color: AppColors.primary,
                  ),

                  const SizedBox(height: AppDimens.d24),

                  // ── Header ─────────────────────────────────────
                  Text(
                    AppStrings.resetPassword,
                    style: AppTextStyles.displayMd.copyWith(
                      color: AppColors.ink,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppDimens.d8),
                  Text(
                    'Enter your email and we\'ll send you a link to reset your password',
                    style: AppTextStyles.bodyMd.copyWith(
                      color: AppColors.muted,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: AppDimens.d40),

                  // ── Email ──────────────────────────────────────
                  AppTextField(
                    controller: _emailController,
                    label: AppStrings.email,
                    hint: 'your@email.com',
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    prefixIcon: Icon(Icons.email_outlined,
                        size: AppDimens.iconMd, color: AppColors.muted),
                    validator: Validators.email,
                    onFieldSubmitted: (_) => _handleReset(),
                  ),

                  const SizedBox(height: AppDimens.d32),

                  // ── Send Reset Button ──────────────────────────
                  AppButton(
                    label: 'Send Reset Link',
                    onPressed: _handleReset,
                    isLoading: isLoading,
                  ),

                  const SizedBox(height: AppDimens.d24),

                  // ── Back to Login ──────────────────────────────
                  Center(
                    child: GestureDetector(
                      onTap: () => context.pop(),
                      child: Text(
                        'Back to Sign In',
                        style: AppTextStyles.titleSm.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
