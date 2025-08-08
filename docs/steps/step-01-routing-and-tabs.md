# Step 01 — Routing skeleton and tabs

## Context & scope
Create the base navigation: bottom tabs and shell layout. Replace the counter page with tabbed pages for Today, Log, Trends, Goals, Settings. Implement a temporary in-memory onboarding gate.

## Implement
- Create feature dirs and placeholder pages:
  - `lib/{onboarding,today,log,trends,goals,settings}/presentation`
- Build `ShellRoute` layout with `NavigationBar` and center FAB.
- Define routes:
  - `/` → redirect to `/onboarding` or `/today` (temp flag)
  - `/today`, `/log`, `/trends`, `/goals`, `/settings`
- Wire basic titles/icons; ensure back behavior is correct.

## Verify
- Commands
  - `flutter analyze`
  - `flutter test`
  - `flutter run -d chrome` (or mobile)
- Manual checks
  - App launches into `/today` when onboarding complete flag is set.
  - Tabs switch screens and preserve state.
  - Back button pops within tab and does not exit unexpectedly.

## Acceptance criteria
- App builds and runs on iOS/Android/Web.
- Bottom navigation works; FAB visible (can be a no-op for now).
- No analyzer issues; tests still pass.
