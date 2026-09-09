import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/routes/route_guards.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_toast.dart';
import '../viewmodels/auth_view_model.dart';

/// Redesigned Login Page matching the mockup login screen perfectly.
/// Features a no-AppBar layout, Therapy Nest logo + Georgia title, card container,
/// with inputs and labels matching the Register Page design system exactly.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authVM = context.read<AuthViewModel>();
    final success = await authVM.login(
      _emailController.text,
      _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      final destination = await resolvePostAuthRoute(context);
      if (!mounted) return;
      context.go(destination);
    } else if (authVM.error != null) {
      AppToast.error(context, authVM.error!.message);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    await context.read<AuthViewModel>().loginWithGoogle();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select<AuthViewModel, bool>((vm) => vm.isLoading);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppDimens.d24, vertical: AppDimens.d16),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppDimens.d16),

                  // ── Logo Section ───────────────────────────────────
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceWhite,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.asset(
                        AppAssets.logo,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimens.d20),

                  // ── Brand Title & Subtitle ─────────────────────────
                  Text(
                    'Therapy Nest',
                    style: AppTextStyles.displayLg.copyWith(
                      color: AppColors.ink,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Your safe space for growth.',
                    style: AppTextStyles.bodyMd.copyWith(
                      color: AppColors.muted,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppDimens.d32),

                  // ── Form Input Card Container ──────────────────────
                  Container(
                    padding: const EdgeInsets.all(AppDimens.d20),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCard,
                      borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                      border: Border.all(color: AppColors.hairlineSoft),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Email Input
                        _buildInputLabel('EMAIL ADDRESS'),
                        _buildTextField(
                          controller: _emailController,
                          hint: 'jane@example.com',
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          validator: Validators.email,
                        ),
                        const SizedBox(height: AppDimens.d20),

                        // Password Input
                        _buildInputLabel('PASSWORD'),
                        _buildTextField(
                          controller: _passwordController,
                          hint: '••••••••',
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          validator: Validators.password,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                              size: 20,
                              color: AppColors.muted,
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                          onFieldSubmitted: (_) => _handleLogin(),
                        ),
                        const SizedBox(height: AppDimens.d8),

                        // Forgot Password Link
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () => context.push(AppRoutes.forgotPassword),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                'Forgot password?',
                                style: AppTextStyles.bodyMd.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                  decorationColor: AppColors.primary.withValues(alpha: 0.3),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppDimens.d24),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _handleLogin,
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
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Sign In',
                                        style: AppTextStyles.button.copyWith(color: AppColors.onPrimary),
                                      ),
                                      const SizedBox(width: 8),
                                      const Icon(Icons.arrow_forward_rounded, size: 18),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimens.d24),

                  // ── Divider ──
                  Row(
                    children: [
                      Expanded(child: Container(height: 1, color: AppColors.hairline)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'Or',
                          style: AppTextStyles.caption.copyWith(color: AppColors.muted),
                        ),
                      ),
                      Expanded(child: Container(height: 1, color: AppColors.hairline)),
                    ],
                  ),
                  const SizedBox(height: AppDimens.d24),

                  // ── Google Sign In Button ──
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      onPressed: isLoading ? null : _handleGoogleSignIn,
                      style: OutlinedButton.styleFrom(
                        backgroundColor: AppColors.surfaceWhite,
                        foregroundColor: AppColors.ink,
                        side: BorderSide(color: AppColors.hairline),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomPaint(
                            size: const Size(20, 20),
                            painter: _GoogleLogoPainter(),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Continue with Google',
                            style: AppTextStyles.bodyMd.copyWith(
                              color: AppColors.ink,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimens.d32),

                  // ── Footer Link ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: AppTextStyles.bodyMd.copyWith(color: AppColors.muted),
                      ),
                      GestureDetector(
                        onTap: () => context.push(AppRoutes.register),
                        child: Text(
                          'Register',
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

// ── Google Logo Vector Painter ──────────────────────────────────────────

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    final paintBlue = Paint()..color = const Color(0xFF4285F4)..style = PaintingStyle.fill;
    final paintGreen = Paint()..color = const Color(0xFF34A853)..style = PaintingStyle.fill;
    final paintYellow = Paint()..color = const Color(0xFFFBBC05)..style = PaintingStyle.fill;
    final paintRed = Paint()..color = const Color(0xFFEA4335)..style = PaintingStyle.fill;

    // Blue Path (G middle and bar)
    final pathBlue = Path()
      ..moveTo(w * 0.94, h * 0.51)
      ..cubicTo(w * 0.94, h * 0.48, w * 0.94, h * 0.44, w * 0.93, h * 0.41)
      ..lineTo(w * 0.50, h * 0.41)
      ..lineTo(w * 0.50, h * 0.59)
      ..lineTo(w * 0.75, h * 0.59)
      ..cubicTo(w * 0.74, h * 0.65, w * 0.70, h * 0.70, w * 0.65, h * 0.74)
      ..lineTo(w * 0.65, h * 0.74)
      ..lineTo(w * 0.80, h * 0.85)
      ..cubicTo(w * 0.89, h * 0.77, w * 0.94, h * 0.65, w * 0.94, h * 0.51)
      ..close();
    canvas.drawPath(pathBlue, paintBlue);

    // Green Path (Bottom)
    final pathGreen = Path()
      ..moveTo(w * 0.50, h * 0.96)
      ..cubicTo(w * 0.62, h * 0.96, w * 0.73, h * 0.92, w * 0.80, h * 0.85)
      ..lineTo(w * 0.65, h * 0.74)
      ..cubicTo(w * 0.61, h * 0.76, w * 0.56, h * 0.78, w * 0.50, h * 0.78)
      ..cubicTo(w * 0.38, h * 0.78, w * 0.28, h * 0.70, w * 0.24, h * 0.59)
      ..lineTo(w * 0.09, h * 0.71)
      ..cubicTo(w * 0.17, h * 0.86, w * 0.32, h * 0.96, w * 0.50, h * 0.96)
      ..close();
    canvas.drawPath(pathGreen, paintGreen);

    // Yellow Path (Left)
    final pathYellow = Path()
      ..moveTo(w * 0.24, h * 0.59)
      ..cubicTo(w * 0.23, h * 0.56, w * 0.23, h * 0.53, w * 0.23, h * 0.50)
      ..cubicTo(w * 0.23, h * 0.47, w * 0.23, h * 0.44, w * 0.24, h * 0.41)
      ..lineTo(w * 0.24, h * 0.41)
      ..lineTo(w * 0.09, h * 0.29)
      ..cubicTo(w * 0.03, h * 0.35, 0.00, h * 0.42, 0.00, h * 0.50)
      ..cubicTo(0.00, h * 0.58, w * 0.03, h * 0.65, w * 0.09, h * 0.71)
      ..lineTo(w * 0.24, h * 0.59)
      ..close();
    canvas.drawPath(pathYellow, paintYellow);

    // Red Path (Top)
    final pathRed = Path()
      ..moveTo(w * 0.50, h * 0.22)
      ..cubicTo(w * 0.57, h * 0.22, w * 0.63, h * 0.25, w * 0.68, h * 0.29)
      ..lineTo(w * 0.81, h * 0.16)
      ..cubicTo(w * 0.73, h * 0.09, w * 0.62, h * 0.04, w * 0.50, h * 0.04)
      ..cubicTo(w * 0.32, h * 0.04, w * 0.17, h * 0.14, w * 0.09, h * 0.29)
      ..lineTo(w * 0.24, h * 0.41)
      ..cubicTo(w * 0.28, h * 0.30, w * 0.38, h * 0.22, w * 0.50, h * 0.22)
      ..close();
    canvas.drawPath(pathRed, paintRed);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
