import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimens.dart';

/// A large circular microphone button with three visual states:
///
/// - **idle** — grey mic icon with subtle shadow
/// - **listening** — red pulsing ring animation
/// - **processing** — circular progress spinner
///
/// Minimum 80 × 80 dp touch target (WCAG / motor-impaired accessible).
class MicrophoneButton extends StatelessWidget {
  const MicrophoneButton({
    super.key,
    required this.state,
    required this.onTap,
  });

  /// Current button state.
  final MicButtonState state;

  /// Tap callback — toggles recording on/off.
  final VoidCallback onTap;

  static const double _size = 80.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: state == MicButtonState.processing ? null : onTap,
      child: SizedBox(
        width: _size,
        height: _size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Pulsing ring (listening state only)
            if (state == MicButtonState.listening)
              _PulsingRing(size: _size),

            // Main circle
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: _size,
              height: _size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _backgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: _shadowColor,
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: _buildIcon(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color get _backgroundColor {
    switch (state) {
      case MicButtonState.idle:
        return AppColors.surfaceSoft;
      case MicButtonState.listening:
        return AppColors.error;
      case MicButtonState.processing:
        return AppColors.surfaceSoft;
    }
  }

  Color get _shadowColor {
    switch (state) {
      case MicButtonState.idle:
        return AppColors.ink.withValues(alpha: 0.08);
      case MicButtonState.listening:
        return AppColors.error.withValues(alpha: 0.30);
      case MicButtonState.processing:
        return AppColors.ink.withValues(alpha: 0.06);
    }
  }

  Widget _buildIcon() {
    switch (state) {
      case MicButtonState.idle:
        return Icon(
          Icons.mic_rounded,
          size: AppDimens.iconLg,
          color: AppColors.muted,
        );
      case MicButtonState.listening:
        return Icon(
          Icons.stop_rounded,
          size: AppDimens.iconLg,
          color: AppColors.onPrimary,
        );
      case MicButtonState.processing:
        return SizedBox(
          width: AppDimens.iconMd,
          height: AppDimens.iconMd,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation(AppColors.primary),
          ),
        );
    }
  }
}

/// The three states of the microphone button.
enum MicButtonState {
  /// Not recording — grey mic icon.
  idle,

  /// Actively recording — red with pulsing ring.
  listening,

  /// Transcription in progress — spinner.
  processing,
}

// ─────────────────────────────────────────────────────────────────────────────
// Pulsing ring animation (calming, not stressful)
// ─────────────────────────────────────────────────────────────────────────────

class _PulsingRing extends StatelessWidget {
  const _PulsingRing({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size + 24,
      height: size + 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.35),
          width: 3,
        ),
      ),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scale(
          begin: const Offset(0.85, 0.85),
          end: const Offset(1.05, 1.05),
          duration: 1200.ms,
          curve: Curves.easeInOut,
        )
        .fadeIn(duration: 300.ms);
  }
}
