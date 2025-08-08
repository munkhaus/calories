# Step 03 — Theme, tokens, and shared components

## Context & scope
Establish a consistent, accessible visual language using Material 3 and project tokens. Create shared building blocks to keep screens consistent and ready for future features.

## Implement
- Material 3 theme
  - Ensure `ThemeData(useMaterial3: true)` with `ColorScheme.fromSeed(seedColor: Colors.teal)`.
  - Provide `ThemeData.dark()` equivalent via `colorScheme: ColorScheme.fromSeed(brightness: Brightness.dark, seedColor: Colors.teal)`.
  - Optional: add high-contrast check and dynamic color later (Android 12+).
- Typography & tokens
  - Continue using `KSizes` for spacing, radii, icon and font sizes; remove magic numbers from screens.
  - Define common paddings: `EdgeInsets.all(KSizes.margin4x)` etc.
- Shared components
  - `lib/core/ui/app_scaffold.dart`: wraps `Scaffold` with common `SafeArea`, optional padding, consistent background, supports FAB/NavigationBar as given by shell.
  - `lib/core/ui/app_card.dart`: a `Card` with consistent shape (`RoundedRectangleBorder` with `KSizes.radiusDefault`) and default padding using `KSizes`.
- Apply components
  - Update placeholder pages (`TodayPage`, `LogPage`, `TrendsPage`, `GoalsPage`, `SettingsPage`) to compose `AppCard` sections where applicable.
  - Keep content minimal; this step is about structure and consistency.
- Accessibility
  - Ensure min tap target ≥ 44x44; verify text scales with system settings.

## Verify
- Commands
  - `flutter analyze`
  - `flutter test`
  - Optional quick grep to catch magic numbers in UI spacing:
    - `rg "EdgeInsets\.(all|symmetric|only)\((?:[0-9]|[1-9][0-9])" lib/` (review and convert to `KSizes`)
    - `rg "SizedBox\((height|width):\s*[0-9]+" lib/` (review)
- Manual checks
  - Switch light/dark theme (system) and verify contrast and legibility.
  - Inspect cards and paddings for consistency across screens.
  - Confirm tap targets on FAB and NavigationBar meet size expectations.

## Acceptance criteria
- Material 3 theme with seed color applied in light/dark.
- Shared `AppScaffold` and `AppCard` exist and are used by placeholder screens.
- No obvious magic-number spacing in updated screens; analyzer/tests green.
