---
name: flutter-provider-architecture
description: >
  Use this skill when building, reviewing, or extending any Flutter mobile
  application that follows the Provider + go_router architecture pattern.
  Covers folder structure, architecture rules, data layer contracts, routing,
  bottom-nav / tab back-stack handling, back-button behavior, the
  Facebook-pattern bottom nav (icon bounce + directional slide transition),
  the shared interactive-component catalog (text fields, buttons, switches,
  checkboxes, radios, dialogs, progress indicators, etc.) for app-wide
  consistency, dependency injection, WebSocket setup, module blueprint, and
  coding standards. Trigger whenever the user mentions a new Flutter app, a
  new feature module, a ViewModel, a repository, routing, bottom navigation,
  back button behavior, page transitions, forms, or any UI consistency
  concern, or any layer of a Flutter project using this stack.
stack: Flutter · Dart · Provider (ChangeNotifier) · go_router · animations · REST · WebSocket (optional)
---

# Flutter Provider Architecture Skill

## Architecture Principles (Non-Negotiable)

### Rule A — No business logic in UI
- **Pages (Widgets):** UI rendering only — no logic
- **ViewModels (ChangeNotifier):** state + UI logic only
- **Repositories:** data access only — no UI logic

### Rule B — No inline styles, no raw Material input widgets
- No inline `Color(0xFF...)`, `TextStyle(...)`, `Duration(...)`, or `Curves.*` anywhere
- No raw Material input/interactive/feedback widgets (`TextField`,
  `Checkbox`, `Switch`, `Radio`, `Slider`, `SegmentedButton`,
  `ToggleButtons`, `AlertDialog`, `SnackBar`, `ProgressIndicator`, list-tile
  variants, buttons, etc.) instantiated directly inside a page or feature
  widget — always the matching `core/widgets/app_*.dart` wrapper
- All styles/motion/components come from `core/constants/` and
  `core/widgets/` — see `design.md` for the full token and component
  catalog. This is what keeps every screen's text fields, buttons, and
  dialogs identical to every other screen's, instead of drifting apart
  page by page.

### Rule C — No direct API calls from UI or ViewModels
- ViewModels call → Repositories
- Repositories call → `ApiClient`

### Rule D — One-way data flow
```
Widget → ViewModel (Provider) → Repository → ApiClient / WsClient → Backend
```

---

## Folder Structure

```
lib/
  main.dart
  app/
    app.dart
    config/
      env.dart               # Environment variables (base URL, keys)
      app_config.dart        # App-wide configuration object
    routes/
      app_routes.dart        # All route path constants
      app_router.dart        # go_router setup + fadePage helper
      app_shell.dart          # Bottom-nav shell: back-button handling, icon
                               # bounce, directional slide (generic, reusable)
      route_guards.dart      # Guard functions (auth, role, etc.)
    di/
      app_providers.dart     # Composition root — all DI wiring
  core/
    constants/
      app_colors.dart
      app_text_styles.dart
      app_dimens.dart
      app_motion.dart        # Animation durations/curves — see design.md
      app_assets.dart
      app_strings.dart
    theme/
      theme.dart
      typography.dart
    utils/
      logger.dart
      validators.dart
      formatters.dart
      debouncer.dart
      extensions.dart
    widgets/
      app_button.dart              # primary/secondary/text/destructive/icon
      app_text_field.dart
      app_form_label.dart
      app_switch.dart
      app_switch_list_tile.dart
      app_checkbox.dart
      app_checkbox_list_tile.dart
      app_radio.dart
      app_radio_list_tile.dart
      app_segmented_button.dart
      app_toggle_buttons.dart
      app_slider.dart
      app_progress_indicator.dart
      app_loader.dart
      app_dialog.dart
      app_alert_dialog.dart
      app_toast.dart
      app_empty_state.dart
      app_avatar.dart
      app_divider.dart
      app_chip.dart
      app_bottom_sheet.dart
    errors/
      failure.dart
      api_error_mapper.dart
  data/
    api/
      api_client.dart        # HTTP client wrapper
      api_endpoints.dart     # Endpoint string constants only
      api_headers.dart       # Header builders
      api_response.dart      # Generic response wrapper
    realtime/                # Optional — include if app uses WebSockets
      ws_client.dart
      ws_events.dart
      ws_message.dart
    models/                  # Pure data classes (no logic)
      # e.g. user_model.dart, product_model.dart, order_model.dart
    repositories/            # One file per domain
      # e.g. auth_repository.dart, product_repository.dart
    storage/
      local_store.dart       # SharedPreferences wrapper
      token_store.dart       # Auth token read/write
      cache_store.dart       # Optional response cache
  modules/
    # One folder per feature:
    auth/
      pages/
      viewmodels/
      widgets/
    onboarding/
      pages/
      viewmodels/
      widgets/
    home/
      pages/
      viewmodels/
      widgets/
    # ... repeat for every feature
  l10n/       # Optional — ARB files for localization
  generated/  # Optional — generated code (l10n, json_serializable, etc.)
```

---

## Routing (go_router)

### Route constants
**File:** `app/routes/app_routes.dart`

All route path strings live here — nowhere else.

```dart
class AppRoutes {
  static const String splash    = '/splash';
  static const String login     = '/auth/login';
  static const String otp       = '/auth/otp';
  static const String onboarding = '/onboarding';
  static const String home      = '/home';
  // Add app-specific paths here
}
```

### Router
**File:** `app/routes/app_router.dart`

- Configures `GoRouter`
- All redirects and guards centralized here
- Every pushed route uses the shared `fadePage()` helper (see `design.md §4`)
- Any bottom-nav / tab section is wired as a `StatefulShellRoute.indexedStack`
  whose `builder` returns `AppShell(navigationShell: navigationShell,
  navItems: <the app's own list>)` (see **Navigation & Back Stack
  Architecture** below) — never a plain `GoRoute` per tab with manual
  `IndexedStack`/`setState` switching.

### Guards
**File:** `app/routes/route_guards.dart`

Pure helper functions — no navigation code inside guards.

```dart
// Common guards — add/remove per app requirements
String? authGuard(BuildContext context, GoRouterState state) { ... }
String? onboardingGuard(BuildContext context, GoRouterState state) { ... }
String? roleGuard(BuildContext context, GoRouterState state, String role) { ... }
```

Guards are wired via `redirect` in `app_router.dart`.

---

## Navigation & Back Stack Architecture (Non-Negotiable)

Applies to any screen reachable from a bottom navigation bar, tab bar, or
drawer — i.e. any UI with multiple "root" sections the user switches
between. Written generically here (`navItems`, branch index) — no app
should hardcode tab names/count in this layer; that only lives in
whatever list each project passes into `AppShell`.

**Dependency:** `flutter pub add animations` (official Material Motion
package — gives us `PageTransitionSwitcher` + `SharedAxisTransition`).

### Rule E — Tab roots use `StatefulShellRoute.indexedStack`
Never swap tab bodies with `IndexedStack`/`setState` off a plain `int`
index — that has no `Navigator` behind it, so nothing is ever pushed and
there's nothing for the back button to pop. Each tab is a **branch** with
its own `GlobalKey<NavigatorState>`, so pages pushed inside a tab (e.g.
Profile pushed from Home) live on that tab's own back stack, independent
of the other tabs.

### Rule F — One centralized back handler, never per-page overrides
The hardware/gesture back button and the AppBar's auto back icon must
resolve to the exact same pop. This is wired **once**, in the shell
widget that hosts the bottom nav — never duplicated with
`PopScope`/`WillPopScope` on individual pages.

Back-button resolution order, every time:
1. Active tab's Navigator can pop (a page is pushed on top of it) → pop it.
2. Active tab isn't the first/home tab → switch to the home tab.
3. Already on the home tab's root → exit the app.

### Rule G — Bottom nav visual treatment (Facebook-pattern)
Icon-only, minimal chrome — no pill/shape background, no icon fill-swap.

- Selected icon tints `AppColors.primary`; unselected uses `AppColors.textSecondary`.
- Labels supplied (for accessibility) but visually hidden via `NavigationDestinationLabelBehavior.alwaysHide`.
- Tap gives a small scale-bounce — one shared `_BouncyNavIcon` widget, driven by `AppMotion.navBounce` / `AppMotion.bounceCurve`. Never hand-rolled per icon/page.

### Rule H — Directional slide between branches (Shared Axis – Horizontal)
Tab switches are never an instant cut and never `fadePage()` (that's
reserved for pushed routes, §4 of `design.md`). They use
`PageTransitionSwitcher` + `SharedAxisTransition(transitionType:
.horizontal)`. Direction is derived every build by comparing the new
branch index to the previously rendered one — moving to a higher index
slides new content in from the right (old content exits left); moving to
a lower index does the reverse. This must stay index-driven and generic
— never a hardcoded direction per named tab.

### File: `app/routes/app_shell.dart`
Single owner of bottom-nav UI, tap feedback, tab-switch transition, and
back-button behavior for the whole app. Fully generic — reused as-is
across projects; only the `navItems` list passed into it changes.

```dart
/// One entry per StatefulShellBranch, in the same order as the branches
/// list in app_router.dart. This is the only per-app configuration —
/// everything else in this file is reusable unchanged.
class NavItem {
  const NavItem({
    required this.icon,
    required this.label,
    required this.navigatorKey,
  });

  final IconData icon;
  final String label; // accessibility label — not rendered (icon-only style)
  final GlobalKey<NavigatorState> navigatorKey;
}

class _BouncyNavIcon extends StatelessWidget {
  const _BouncyNavIcon({required this.icon, required this.selected});
  final IconData icon;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: selected ? 1.15 : 1.0,
      duration: AppMotion.navBounce,
      curve: AppMotion.bounceCurve,
      child: Icon(
        icon,
        color: selected ? AppColors.primary : AppColors.textSecondary,
      ),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({
    required this.navigationShell,
    required this.navItems,
    super.key,
  });

  final StatefulNavigationShell navigationShell;
  final List<NavItem> navItems;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _previousIndex = 0;

  void _handleBack(BuildContext context) {
    final currentKey =
        widget.navItems[widget.navigationShell.currentIndex].navigatorKey;

    // 1. Something pushed on top of this tab -> pop it first.
    if (currentKey.currentState?.canPop() ?? false) {
      currentKey.currentState!.pop();
      return;
    }
    // 2. Not on the home (first) tab -> go there first.
    if (widget.navigationShell.currentIndex != 0) {
      widget.navigationShell.goBranch(0);
      return;
    }
    // 3. Already on home root -> actually exit.
    SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = widget.navigationShell.currentIndex;
    final movingForward = currentIndex >= _previousIndex;
    _previousIndex = currentIndex;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBack(context);
      },
      child: Scaffold(
        body: PageTransitionSwitcher(
          duration: AppMotion.branchSlide,
          reverse: !movingForward, // flips slide direction on back-navigation
          transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
            return SharedAxisTransition(
              animation: primaryAnimation,
              secondaryAnimation: secondaryAnimation,
              transitionType: SharedAxisTransitionType.horizontal,
              child: child,
            );
          },
          child: KeyedSubtree(
            key: ValueKey(currentIndex), // signals a "page" changed
            child: widget.navigationShell,
          ),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: currentIndex,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
          onDestinationSelected: (index) => widget.navigationShell.goBranch(
            index,
            initialLocation: index == currentIndex,
          ),
          destinations: [
            for (var i = 0; i < widget.navItems.length; i++)
              NavigationDestination(
                icon: _BouncyNavIcon(
                  icon: widget.navItems[i].icon,
                  selected: currentIndex == i,
                ),
                label: widget.navItems[i].label,
              ),
          ],
        ),
      ),
    );
  }
}
```

### Wiring it up in `app_router.dart` (per-app — the only part that changes)

```dart
final homeNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'home');
final tab2NavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'tab2');
final tab3NavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'tab3');

// This list's order must match the StatefulShellBranch order below.
final _navItems = [
  NavItem(icon: Icons.home, label: 'Home', navigatorKey: homeNavigatorKey),
  NavItem(icon: Icons.explore, label: 'Explore', navigatorKey: tab2NavigatorKey),
  NavItem(icon: Icons.settings, label: 'Settings', navigatorKey: tab3NavigatorKey),
];

StatefulShellRoute.indexedStack(
  builder: (context, state, navigationShell) =>
      AppShell(navigationShell: navigationShell, navItems: _navItems),
  branches: [
    StatefulShellBranch(
      navigatorKey: homeNavigatorKey,
      routes: [
        GoRoute(
          path: AppRoutes.home,
          pageBuilder: (context, state) => fadePage(child: const HomePage(), state: state),
          routes: [
            // Pages pushed from Home (e.g. Profile) nest here, so they
            // live on Home's own back stack, not a new tab or a new stack.
          ],
        ),
      ],
    ),
    StatefulShellBranch(navigatorKey: tab2NavigatorKey, routes: [ /* ... */ ]),
    StatefulShellBranch(navigatorKey: tab3NavigatorKey, routes: [ /* ... */ ]),
  ],
),
```

Swap the icons/labels/route count for whatever the project needs —
`AppShell` itself never needs to change.

---

## Dependency Injection (Provider)

**File:** `app/di/app_providers.dart`

This is the **only** place where dependencies are wired. Nothing else creates repositories or services.

```dart
List<SingleChildWidget> appProviders() => [
  // Infrastructure
  Provider<LocalStore>(create: (_) => LocalStore()),
  Provider<TokenStore>(create: (_) => TokenStore()),
  Provider<ApiClient>(create: (ctx) => ApiClient(ctx.read())),

  // Optional — WebSocket
  Provider<WsClient>(create: (ctx) => WsClient(ctx.read())),

  // Repositories
  Provider<AuthRepository>(create: (ctx) => AuthRepository(ctx.read())),
  // ... all repositories

  // App-wide ViewModels
  ChangeNotifierProvider<SessionViewModel>(create: (ctx) => SessionViewModel(ctx.read())),
];
```

`appProviders()` wraps `MyApp` with `MultiProvider` in `main.dart`.

### Feature ViewModels
- Provide at **route/page level** (preferred)
- Provide app-wide only when truly shared across multiple top-level sections

### UI consumption rules

```dart
// Reactive rebuild — use in build()
context.watch<MyViewModel>()
context.select<MyViewModel, T>((vm) => vm.someField)  // preferred — narrow rebuild

// Action only — use in callbacks
context.read<MyViewModel>().doSomething()
```

---

## Data Layer Contracts

### ApiClient
**File:** `data/api/api_client.dart`

Responsibilities:
1. Build request URL from base URL + endpoint
2. Attach auth headers
3. Parse JSON response
4. Normalize errors → `Failure`
5. Return `ApiResponse<T>`

```dart
class ApiClient {
  Future<ApiResponse<T>> get<T>(String endpoint, ...) async { ... }
  Future<ApiResponse<T>> post<T>(String endpoint, Map body, ...) async { ... }
  Future<ApiResponse<T>> put<T>(String endpoint, Map body, ...) async { ... }
  Future<ApiResponse<T>> delete<T>(String endpoint, ...) async { ... }
}
```

### Endpoints
**File:** `data/api/api_endpoints.dart`

Only string constants — no logic.

```dart
class ApiEndpoints {
  static const String login   = '/auth/login';
  static const String profile = '/user/profile';
  // Add endpoints per app
}
```

### Repositories
**Folder:** `data/repositories/`

Rules:
- Accept `ApiClient` (and optionally `WsClient`) via constructor
- Return **model objects**, never raw JSON
- No UI logic, no navigation

```dart
// Pattern
class ProductRepository {
  final ApiClient _api;
  ProductRepository(this._api);

  Future<List<ProductModel>> getProducts() async { ... }
  Future<ProductModel> getProduct(String id) async { ... }
  Future<ProductModel> createProduct(ProductModel data) async { ... }
}
```

---

## WebSocket Architecture (Optional)

Include only if the app requires real-time features (chat, live updates, notifications).

### WsClient
**File:** `data/realtime/ws_client.dart`

Responsibilities:
- `connect()` / `disconnect()`
- Auth handshake on connect
- Subscribe / unsubscribe to rooms or topics
- Send messages
- Expose typed `Stream` listeners
- Reconnect with exponential backoff (capped)

### Ws Events
**File:** `data/realtime/ws_events.dart`

All event name strings declared in one place.

```dart
class WsEvents {
  static const String chatNewMessage     = 'chat:new_message';
  static const String chatTyping         = 'chat:typing';
  static const String orderStatusUpdated = 'order:status_updated';
  // Add per app
}
```

### Repositories using WsClient

Repositories that mix REST and real-time (e.g., `ChatRepository`) inject both `ApiClient` and `WsClient`:

```dart
class ChatRepository {
  final ApiClient _api;
  final WsClient _ws;
  ChatRepository(this._api, this._ws);

  // REST: history, thread list
  Future<List<MessageModel>> getThreadHistory(String threadId) async { ... }

  // Real-time: stream
  Stream<MessageModel> get incomingMessages => _ws.on(WsEvents.chatNewMessage);
}
```

---

## Module Blueprint

Every feature follows the same three-folder structure:

```
modules/<feature>/
  pages/        ← Screens only — UI rendering, no logic
  viewmodels/   ← ChangeNotifiers — state + UI logic, calls repositories
  widgets/      ← UI components scoped to this feature only
```

### Rules
- Pages call ViewModel methods via `context.read<VM>().method()`
- Pages read state via `context.watch<VM>()` or `context.select<VM, T>(...)`
- ViewModels call Repositories — never `ApiClient` or `WsClient` directly
- Pages never call `ApiClient` or `WsClient` directly
- Pages build forms/UI exclusively from `core/widgets/app_*.dart` (see
  `design.md §3`) — a feature's `widgets/` folder is for composing those
  shared components into feature-specific layouts, never for redefining
  a text field, button, checkbox, etc. from scratch

### ViewModel pattern

```dart
class ProductViewModel extends ChangeNotifier {
  final ProductRepository _repo;
  ProductViewModel(this._repo);

  List<ProductModel> products = [];
  bool isLoading = false;
  Failure? error;

  Future<void> loadProducts() async {
    isLoading = true;
    notifyListeners();
    try {
      products = await _repo.getProducts();
      error = null;
    } catch (e) {
      error = ApiErrorMapper.map(e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
```

---

## Error Handling

### Failure model
**File:** `core/errors/failure.dart`

```dart
abstract class Failure {
  final String message;
  const Failure(this.message);
}

class NetworkFailure      extends Failure { const NetworkFailure() : super('No internet connection'); }
class TimeoutFailure      extends Failure { const TimeoutFailure() : super('Request timed out'); }
class UnauthorizedFailure extends Failure { const UnauthorizedFailure() : super('Session expired'); }
class ValidationFailure   extends Failure { const ValidationFailure(String msg) : super(msg); }
class UnknownFailure      extends Failure { const UnknownFailure() : super('Something went wrong'); }
```

**File:** `core/errors/api_error_mapper.dart` — maps HTTP status codes and exceptions to `Failure` types.

---

## Coding Standards Checklist

### ✅ Required
- [ ] Provider + ChangeNotifier for all state management
- [ ] `context.select` to minimize unnecessary widget rebuilds
- [ ] All data access through Repositories
- [ ] Design tokens only for colors, text, spacing (`AppColors`, `AppTextStyles`, `AppDimens`)
- [ ] `AppMotion.*` for every animation duration/curve — no inline `Duration`/`Curves.*`
- [ ] Every text field, button, switch, checkbox, radio, slider, dialog, snackbar, and progress indicator comes from `core/widgets/app_*.dart` (`design.md §3`) — never instantiated raw in a page
- [ ] All selection/input controls follow the shared Component State Tokens (`design.md §3`) for default/selected/error/disabled
- [ ] One button hierarchy only: `AppButton.primary/secondary/text/destructive/icon`
- [ ] Modules are isolated — no cross-module widget/ViewModel imports
- [ ] All WebSocket logic inside `WsClient` + relevant Repository
- [ ] All route paths in `app_routes.dart`
- [ ] All validators in `core/utils/validators.dart`
- [ ] All environment values in `app_config.dart` / `env.dart`
- [ ] Bottom-nav / tab roots built with `StatefulShellRoute.indexedStack`, one `Navigator` per branch
- [ ] Back button (hardware/gesture) and AppBar back icon both resolve through the single `PopScope` handler in `app_shell.dart`
- [ ] Bottom nav is icon-only with `_BouncyNavIcon` tap feedback (Rule G)
- [ ] Tab switches animate via `PageTransitionSwitcher` + `SharedAxisTransition(.horizontal)`, direction derived from index comparison (Rule H)
- [ ] `AppShell`/`NavItem` kept generic — per-app config is only the `navItems` list, never hardcoded tab logic

### ❌ Forbidden
- GetX, Bloc, Riverpod, or any other state management mixed in
- API calls from Pages or ViewModels directly
- WebSocket code scattered across UI files
- Inline colors, text styles, spacing, or motion values
- Raw `TextField`, `Checkbox`, `Switch`, `Radio`, `Slider`, `SegmentedButton`, `ToggleButtons`, `AlertDialog`, `SnackBar`, `ProgressIndicator`, list-tile variants, or ad hoc `ElevatedButton`/`OutlinedButton`/`TextButton` calls inside page/feature code
- A page or feature defining its own one-off styling for a control that already has an `app_*.dart` wrapper
- Creating repositories inside pages
- Hardcoded strings or asset paths in widgets
- Mixing multiple state management approaches
- Swapping bottom-nav tabs via `IndexedStack`/`setState` without a per-tab `Navigator`
- `PopScope`/`WillPopScope` added on individual pages to hack around back behavior instead of using `app_shell.dart`
- Instant/no-animation tab switches, or `fadePage()` used for tab switches instead of pushed routes
- Pill/shape indicators, labels, or icon fill-swap on the bottom nav without a documented design override
