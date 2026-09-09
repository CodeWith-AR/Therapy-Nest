import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/accessibility_settings.dart';
import '../viewmodels/accessibility_view_model.dart';

/// Redesigned Accessibility sub-settings page matching mockup perfectly.
/// Features clean custom sliders, test voice buttons, a grid layout selector
/// for tap target sizes, and a live scaling preview footer at the bottom.
class AccessibilitySettingsPage extends StatelessWidget {
  const AccessibilitySettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AccessibilityViewModel>();
    final a11y = vm.accessibility;

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
          AppStrings.a11yTitle,
          style: AppTextStyles.appBarTitle.copyWith(color: AppColors.ink),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: AppColors.hairline,
            height: 1.0,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.d16,
          vertical: AppDimens.d20,
        ),
        children: [
          // ── Text Size Card ─────────────────────────────────────────
          _buildCard(
            context,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.a11yTextSize,
                            style: AppTextStyles.titleLg.copyWith(color: AppColors.ink),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            AppStrings.a11yTextSizeDesc,
                            style: AppTextStyles.bodySm.copyWith(color: AppColors.muted),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppDimens.d12),
                    Text(
                      'Aa',
                      style: AppTextStyles.displayLg.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.d16),
                Row(
                  children: [
                    Text(
                      'A',
                      style: AppTextStyles.bodySm.copyWith(
                        color: AppColors.muted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Expanded(
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: AppColors.primary,
                          thumbColor: AppColors.primary,
                          inactiveTrackColor: AppColors.hairline,
                          overlayColor: AppColors.primary.withValues(alpha: 0.12),
                        ),
                        child: Slider(
                          value: a11y.textScaleIndex.toDouble(),
                          min: 0,
                          max: (AccessibilitySettings.textScaleLabels.length - 1).toDouble(),
                          divisions: AccessibilitySettings.textScaleLabels.length - 1,
                          onChanged: (v) {
                            final idx = v.round();
                            vm.setTextScaleFactor(AccessibilitySettings.textScaleValues[idx]);
                          },
                        ),
                      ),
                    ),
                    Text(
                      'A',
                      style: AppTextStyles.titleLg.copyWith(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppDimens.d8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Small',
                        style: AppTextStyles.caption.copyWith(color: AppColors.muted),
                      ),
                      Text(
                        'Maximum',
                        style: AppTextStyles.caption.copyWith(color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.d16),

          // ── Reading Speed Card ─────────────────────────────────────
          _buildCard(
            context,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.a11yTtsSpeed,
                  style: AppTextStyles.titleLg.copyWith(color: AppColors.ink),
                ),
                const SizedBox(height: 2),
                Text(
                  AppStrings.a11yTtsSpeedDesc,
                  style: AppTextStyles.bodySm.copyWith(color: AppColors.muted),
                ),
                const SizedBox(height: AppDimens.d16),
                Row(
                  children: [
                    Text(
                      '0.5x',
                      style: AppTextStyles.caption.copyWith(color: AppColors.muted),
                    ),
                    Expanded(
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: AppColors.primary,
                          thumbColor: AppColors.primary,
                          inactiveTrackColor: AppColors.hairline,
                          overlayColor: AppColors.primary.withValues(alpha: 0.12),
                        ),
                        child: Slider(
                          value: a11y.ttsSpeed,
                          min: 0.5,
                          max: 1.5,
                          divisions: 10,
                          onChanged: (v) => vm.setTtsSpeed(double.parse(v.toStringAsFixed(1))),
                        ),
                      ),
                    ),
                    Text(
                      '1.5x',
                      style: AppTextStyles.caption.copyWith(color: AppColors.muted),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.d16),
                SizedBox(
                  width: double.infinity,
                  height: AppDimens.touchNormal,
                  child: ElevatedButton.icon(
                    onPressed: () => vm.testTts(),
                    icon: const Icon(Icons.volume_up_rounded, size: AppDimens.iconMd),
                    label: const Text(AppStrings.a11yTtsTest),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                      ),
                      textStyle: AppTextStyles.titleSm,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.d16),

          // ── Tap Area Size Card ─────────────────────────────────────
          _buildCard(
            context,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.a11yTouchTarget,
                  style: AppTextStyles.titleLg.copyWith(color: AppColors.ink),
                ),
                const SizedBox(height: 2),
                Text(
                  AppStrings.a11yTouchTargetDesc,
                  style: AppTextStyles.bodySm.copyWith(color: AppColors.muted),
                ),
                const SizedBox(height: AppDimens.d16),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: AppDimens.d12,
                    mainAxisSpacing: AppDimens.d12,
                    childAspectRatio: 2.2,
                  ),
                  itemCount: AccessibilitySettings.touchTargetLabels.length,
                  itemBuilder: (context, index) {
                    final label = AccessibilitySettings.touchTargetLabels[index];
                    final val = AccessibilitySettings.touchTargetValues[index];
                    final isSelected = a11y.touchTargetIndex == index;

                    return InkWell(
                      onTap: () => vm.setTouchTargetScale(val),
                      borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primaryLight : AppColors.surfaceSoft,
                          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.hairline,
                            width: isSelected ? 2.0 : 1.0,
                          ),
                        ),
                        child: Text(
                          label,
                          style: AppTextStyles.bodyLg.copyWith(
                            color: isSelected ? AppColors.primary : AppColors.body,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.d16),

          // ── High Contrast Card ─────────────────────────────────────
          _buildCard(
            context,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.a11yHighContrast,
                        style: AppTextStyles.titleLg.copyWith(
                          color: a11y.highContrastMode ? AppColors.hcText : AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        AppStrings.a11yHighContrastDesc,
                        style: AppTextStyles.bodySm.copyWith(
                          color: a11y.highContrastMode ? AppColors.hcMuted : AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: a11y.highContrastMode,
                  activeTrackColor: AppColors.hcPrimary,
                  onChanged: (v) => vm.setHighContrastMode(v),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.d16),

          // ── Voice Input Card ───────────────────────────────────────
          _buildCard(
            context,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.a11yVoiceInput,
                        style: AppTextStyles.titleLg.copyWith(
                          color: a11y.highContrastMode ? AppColors.hcText : AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        AppStrings.a11yVoiceInputDesc,
                        style: AppTextStyles.bodySm.copyWith(
                          color: a11y.highContrastMode ? AppColors.hcMuted : AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: a11y.voiceInputMode,
                  activeTrackColor: a11y.highContrastMode ? AppColors.hcPrimary : AppColors.primary,
                  onChanged: (v) => vm.setVoiceInputMode(v),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.d16),

          // ── Reduce Motion Card ─────────────────────────────────────
          _buildCard(
            context,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.a11yReduceMotion,
                        style: AppTextStyles.titleLg.copyWith(
                          color: a11y.highContrastMode ? AppColors.hcText : AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        AppStrings.a11yReduceMotionDesc,
                        style: AppTextStyles.bodySm.copyWith(
                          color: a11y.highContrastMode ? AppColors.hcMuted : AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: a11y.reduceMotion,
                  activeTrackColor: a11y.highContrastMode ? AppColors.hcPrimary : AppColors.primary,
                  onChanged: (v) => vm.setReduceMotion(v),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.d32),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.d16,
          vertical: AppDimens.d16,
        ),
        decoration: BoxDecoration(
          color: a11y.highContrastMode ? AppColors.hcBackground : AppColors.surfaceSoft,
          border: Border(
            top: BorderSide(
              color: a11y.highContrastMode ? AppColors.hcBorder : AppColors.hairline,
              width: a11y.highContrastMode ? 2.0 : 1.0,
            ),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'LIVE PREVIEW',
                style: AppTextStyles.label.copyWith(
                  color: a11y.highContrastMode ? AppColors.hcText : AppColors.muted,
                  letterSpacing: 1.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppDimens.d8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppDimens.d16),
                decoration: BoxDecoration(
                  color: a11y.highContrastMode ? AppColors.hcSurface : AppColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                  border: Border.all(
                    color: a11y.highContrastMode ? AppColors.hcBorder : AppColors.hairlineSoft,
                    width: a11y.highContrastMode ? 2.0 : 1.0,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'The quick brown fox jumps over the lazy dog.',
                      style: AppTextStyles.bodyLg.copyWith(
                        color: a11y.highContrastMode ? AppColors.hcText : AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: AppDimens.d12),
                    ElevatedButton(
                      onPressed: () {},
                      child: Text(
                        'Interactive Button (${(AppDimens.touchNormal * a11y.touchTargetScale).round()}dp)',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, {required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.d16),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        border: Border.all(color: AppColors.hairlineSoft),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}
