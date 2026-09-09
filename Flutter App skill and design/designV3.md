# Flutter Design System
> Universal design token and UI standards for Flutter apps using Provider + go_router architecture

---

## 1. Design Tokens

All tokens are defined **once** in `core/constants/` and imported everywhere.  
Inline values (`Color(0xFF...)`, `TextStyle(...)`, hardcoded numbers) are strictly forbidden.

### Colors
**File:** `core/constants/app_colors.dart`

```dart
class AppColors {
  static const Color primary       = Color(0xFF0057FF);
  static const Color primaryLight  = Color(0xFFE8F0FF);
  static const Color secondary     = Color(0xFF00C896);
  static const Color error         = Color(0xFFD32F2F);
  static const Color warning       = Color(0xFFFFA000);
  static const Color success       = Color(0xFF388E3C);
  static const Color background    = Color(0xFFF5F5F5);
  static const Color surface       = Color(0xFFFFFFFF);
  static const Color textPrimary   = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B6B6B);
  static const Color border        = Color(0xFFE0E0E0);
  static const Color disabled      = Color(0xFFBDBDBD);
}
```

### Typography
**File:** `core/constants/app_text_styles.dart`

```dart
class AppTextStyles {
  static const TextStyle heading1   = TextStyle(fontSize: 28, fontWeight: FontWeight.w700);
  static const TextStyle heading2   = TextStyle(fontSize: 22, fontWeight: FontWeight.w600);
  static const TextStyle heading3   = TextStyle(fontSize: 18, fontWeight: FontWeight.w600);
  static const TextStyle bodyLarge  = TextStyle(fontSize: 16, fontWeight: FontWeight.w400);
  static const TextStyle bodyMedium = TextStyle(fontSize: 14, fontWeight: FontWeight.w400);
  static const TextStyle bodySmall  = TextStyle(fontSize: 12, fontWeight: FontWeight.w400);
  static const TextStyle label      = TextStyle(fontSize: 13, fontWeight: FontWeight.w500);
  static const TextStyle caption    = TextStyle(fontSize: 11, fontWeight: FontWeight.w400);
  static const TextStyle button     = TextStyle(fontSize: 15, fontWeight: FontWeight.w600);
}
```

### Spacing / Dimensions
**File:** `core/constants/app_dimens.dart`

```dart
class AppDimens {
  static const double d4  = 4;
  static const double d8  = 8;
  static const double d12 = 12;
  static const double d16 = 16;
  static const double d20 = 20;
  static const double d24 = 24;
  static const double d32 = 32;
  static const double d40 = 40;
  static const double d48 = 48;
  static const double d64 = 64;

  // Border radius
  static const double radiusSm   = 6;
  static const double radiusMd   = 12;
  static const double radiusLg   = 20;
  static const double radiusFull = 999;

  // Icon sizes
  static const double iconSm = 16;
  static const double iconMd = 24;
  static const double iconLg = 32;
}
```

### Motion
**File:** `core/constants/app_motion.dart`

Every animation duration and curve in the app — nav bar taps, branch/tab
transitions, control state changes, loaders, dialogs — comes from here.
No app screen or widget declares its own `Duration(milliseconds: ...)` or
`Curves.*` inline.

```dart
class AppMotion {
  static const Duration navBounce    = Duration(milliseconds: 150);
  static const Duration branchSlide  = Duration(milliseconds: 280);
  static const Duration controlState = Duration(milliseconds: 150); // check/switch/focus transitions
  static const Curve bounceCurve     = Curves.easeOutBack;
  static const Curve slideCurve      = Curves.easeInOutCubic;
  static const Curve stateCurve      = Curves.easeOut;
}
```

### Assets
**File:** `core/constants/app_assets.dart`

```dart
class AppAssets {
  static const String logo        = 'assets/images/logo.png';
  static const String placeholder = 'assets/images/placeholder.png';
  static const String icHome      = 'assets/icons/ic_home.svg';
  static const String animLoading = 'assets/animations/loading.json';
}
```

### Strings
**File:** `core/constants/app_strings.dart`

All static user-facing strings live here. For multi-language support, move to `l10n/`.

---

## 2. Theme

**File:** `core/theme/theme.dart`  
**Companion:** `core/theme/typography.dart`

- Builds a single `ThemeData` consumed by `MaterialApp`
- Global styles for buttons, inputs, and app bars defined here
- `typography.dart` maps `AppTextStyles` tokens into Flutter's `TextTheme`

```dart
ThemeData buildAppTheme() => ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
  textTheme: buildTextTheme(),
  elevatedButtonTheme: ElevatedButtonThemeData(...),
  inputDecorationTheme: InputDecorationTheme(...),
  appBarTheme: AppBarTheme(...),
);
```

---

## 3. Shared Widgets

**Folder:** `core/widgets/`

**Rule:** every interactive or feedback widget in the app — text input,
selection controls, buttons, dialogs, progress indicators — is used
through its wrapper here. **Never** instantiate the raw Material widget
(`TextField`, `Checkbox`, `Switch`, `Radio`, `Slider`, `AlertDialog`,
`SnackBar`, `CircularProgressIndicator`, `SegmentedButton`, etc.) directly
inside a page, feature widget, or ViewModel. This is what keeps Login's
text field identical to Signup's, Settings' switches identical to
Onboarding's — one definition, used everywhere.

| Widget | Wraps | Purpose |
|---|---|---|
| `app_button.dart` | `FilledButton` / `OutlinedButton` / `TextButton` / `IconButton` | Primary / secondary / tertiary / icon / destructive — see Button Hierarchy below |
| `app_text_field.dart` | `TextField` / `TextFormField` | Styled input with validation and error display |
| `app_form_label.dart` | `Text` | Field label shown above/beside every input, optional required marker |
| `app_switch.dart` | `Switch` | On/off toggle |
| `app_switch_list_tile.dart` | `SwitchListTile` | Switch with label/subtitle row |
| `app_checkbox.dart` | `Checkbox` | Boolean selection |
| `app_checkbox_list_tile.dart` | `CheckboxListTile` | Checkbox with label/subtitle row |
| `app_radio.dart` | `Radio<T>` | Single choice from a set |
| `app_radio_list_tile.dart` | `RadioListTile<T>` | Radio with label/subtitle row |
| `app_segmented_button.dart` | `SegmentedButton<T>` | Compact exclusive/multi choice, 2–5 options |
| `app_toggle_buttons.dart` | `ToggleButtons` | Icon-only or short-label multi-toggle group |
| `app_slider.dart` | `Slider` | Continuous/discrete value picker |
| `app_progress_indicator.dart` | `CircularProgressIndicator` / `LinearProgressIndicator` | Inline/small-space loading |
| `app_loader.dart` | (built on `app_progress_indicator.dart`) | Full-screen loading |
| `app_dialog.dart` | `Dialog` | Generic modal container (custom content) |
| `app_alert_dialog.dart` | `AlertDialog` | Confirm / destructive action prompts |
| `app_toast.dart` | `SnackBar` | Transient, non-blocking feedback |
| `app_empty_state.dart` | — | Empty / no-data placeholder with icon + message |
| `app_avatar.dart` | `CircleAvatar` | User/entity avatar with fallback initials |
| `app_divider.dart` | `Divider` | Styled divider with optional label |
| `app_chip.dart` | `Chip` | Tag / status chip |
| `app_bottom_sheet.dart` | `showModalBottomSheet` | Reusable bottom sheet wrapper |

### Component State Tokens

Every selection/input control above reads the **same** states from the
**same** tokens — this table is the single source of truth, not a
per-widget, per-page decision:

| State | Border / track | Fill / thumb | Label / text |
|---|---|---|---|
| Default (unselected/empty) | `AppColors.border` | `AppColors.surface` | `AppColors.textSecondary` |
| Selected / checked / on / focused | `AppColors.primary` | `AppColors.primary` | `AppColors.textPrimary` |
| Error | `AppColors.error` | — | `AppColors.error` |
| Disabled | `AppColors.disabled` | `AppColors.disabled` | `AppColors.disabled` |

State transitions (focus ring appearing, check filling in, switch thumb
sliding, slider thumb growing) animate with `AppMotion.controlState` /
`AppMotion.stateCurve` — never a bespoke duration per widget.

### Button Hierarchy

`app_button.dart` exposes named constructors instead of ad hoc
`ElevatedButton`/`OutlinedButton` calls scattered per page:

| Variant | Material base | Use for |
|---|---|---|
| `AppButton.primary()` | `FilledButton` | The one main action per screen (Sign in, Save, Continue) |
| `AppButton.secondary()` | `OutlinedButton` | Secondary action alongside a primary one |
| `AppButton.text()` | `TextButton` | Low-emphasis action (Cancel, Skip) |
| `AppButton.destructive()` | `FilledButton` (error color) | Delete / irreversible actions |
| `AppButton.icon()` | `IconButton` | Icon-only action, sized `AppDimens.iconMd` |

All variants share `AppDimens.radiusMd` corner radius and
`AppTextStyles.button` — the only thing that changes between them is
which color token drives them, never the shape or type scale. A screen
should never have more than one `AppButton.primary()` visible at once.

### Dialogs & Feedback

| Situation | Widget |
|---|---|
| Confirm / destructive action | `app_alert_dialog.dart` — destructive action always uses `AppButton.destructive()` |
| Custom modal content | `app_dialog.dart` |
| Transient success/info/error message | `app_toast.dart` |
| Inline/small-space loading | `app_progress_indicator.dart` |
| Full-screen loading | `app_loader.dart` |

---

## 4. Screen Transitions

**Requirement:** All screen transitions use **fade animation** by default.

**File:** `app/routes/app_router.dart`

```dart
CustomTransitionPage<T> fadePage<T>({
  required Widget child,
  required GoRouterState state,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}
```

Every route uses:
```dart
pageBuilder: (context, state) => fadePage(child: SomePage(), state: state)
```

> **Note:** `fadePage()` governs the transition *animation* for pushed
> routes, including ones nested inside a bottom-nav tab (e.g. Home →
> Profile). It does not govern back-button *behavior*, and it is **not**
> used for switching bottom-nav tabs — that uses the directional slide in
> §7 below. See `skill.md § Navigation & Back Stack Architecture`.

---

## 5. State & Error UX

| App State | Widget to Use |
|-----------|--------------|
| Loading | `app_loader.dart` (full-screen) / `app_progress_indicator.dart` (inline) |
| Empty / no data | `app_empty_state.dart` |
| Success / info feedback | `app_toast.dart` |
| Blocking confirmation | `app_alert_dialog.dart` |
| Form field error | inline inside `app_text_field.dart`, using the Error row of the state tokens table in §3 |

---

## 6. Form Validation

**File:** `core/utils/validators.dart`

All validator functions live here. No inline validation logic inside pages or ViewModels.

```dart
class Validators {
  static String? email(String? v)               { ... }
  static String? phone(String? v)               { ... }
  static String? required(String? v)            { ... }
  static String? minLength(String? v, int min)  { ... }
  static String? password(String? v)            { ... }
}
```

---

## 7. Bottom Navigation Bar Style

**Pattern:** icon-only, minimal chrome (Facebook-pattern). This is the
default bottom-nav treatment for every app built with this design
system — no pill/shape background, no elevation gimmicks, no
outline↔filled icon swap, unless a project explicitly calls for a
different style (e.g. a pill-indicator/MIUI-style bar), in which case the
override still goes through `AppColors`/`AppMotion` tokens, never inline
values.

- **Selected state:** icon tints `AppColors.primary`; unselected icons
  use `AppColors.textSecondary`. No shape or background change.
- **Labels:** hidden by default
  (`NavigationDestinationLabelBehavior.alwaysHide`) — label text is still
  supplied per destination for accessibility/tooltips, just not rendered.
- **Tap feedback:** a small scale-bounce, not a color sweep or shape
  morph. One shared icon widget (`_BouncyNavIcon`) handles this for every
  destination, driven by `AppMotion.navBounce` / `AppMotion.bounceCurve`
  — never hand-rolled per icon.
- **Tab-switch transition:** a directional slide (Shared Axis –
  Horizontal), not an instant cut. Moving to a tab to the right slides
  the new content in from the right (old content exits left); moving to
  a tab to the left does the reverse. Direction is derived automatically
  from tab index — never hardcoded per tab.

Full implementation (`app_shell.dart`, generic across any number/order of
tabs) lives in `skill.md § Navigation & Back Stack Architecture`.

---

## 8. Enforcement Rules

| ✅ Required | ❌ Forbidden |
|------------|------------|
| `AppColors.*` for all colors | Inline `Color(0xFF...)` |
| `AppTextStyles.*` for all text styles | Inline `TextStyle(...)` |
| `AppDimens.*` for all spacing and sizing | Hardcoded numeric values |
| `AppMotion.*` for all animation durations and curves | Inline `Duration(milliseconds: ...)` or `Curves.*` |
| Interactive/input widgets only via `core/widgets/app_*.dart` (§3) | Raw `TextField`, `Checkbox`, `Switch`, `Radio`, `Slider`, `AlertDialog`, `SnackBar`, `ProgressIndicator`, `SegmentedButton`, `ToggleButtons`, list-tile variants instantiated directly in pages |
| One button hierarchy: `AppButton.primary/secondary/text/destructive/icon` | Ad hoc `ElevatedButton`/`OutlinedButton`/`TextButton` mixed per page |
| All controls follow the shared Component State Tokens (§3) | Per-page custom colors/borders for checked/error/disabled states |
| Icon-only bottom nav (§7) with `_BouncyNavIcon` + directional slide | Custom pill/shape indicators or instant tab cuts without a documented reason |
| `Validators.*` for all form validation | Inline validation logic |
| `AppAssets.*` for all asset paths | Hardcoded string paths |
| Back-button behavior only via `app_shell.dart`'s `PopScope` (see `skill.md`) | Per-page `WillPopScope`/`PopScope` overrides |
