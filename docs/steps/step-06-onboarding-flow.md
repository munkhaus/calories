# Step 06 — Onboarding flow (mobile-first wizard)

## Context & scope
Build the real onboarding wizard to collect units, demographics, activity, and goal/pace. Compute target calories using the calculator and persist profile/goal. Ensure startup redirects based on completion flag (already wired).

## Implement
- Replace `Stepper` with `PageView` + `PageController` wizard.
- Screens (one primary task per screen)
  - Units (metric/imperial)
  - Profile (age, sex)
  - Height
  - Weight
  - Activity level
  - Goal mode (lose/maintain/gain) + pace (kcal/day)
  - Review & confirm
- UI/UX
  - Top: linear progress bar or dots indicator; concise title/description.
  - Bottom: persistent Back/Next (Continue) bar; Skip where safe; disabled Next until valid.
  - Inputs: numeric keypad for numbers; inline validation; sensible defaults.
  - Save-as-you-go: store interim state in `LocalStorage` to survive relaunch.
- Logic
  - Use `CalorieCalculator` to compute target calories at review.
  - Persist `UserProfile` and `Goal` via `IProfileService` and `IGoalService`.
  - Set `onboardingCompleted` in `LocalStorage` and redirect to `/today`.

## Verify
- Commands: `flutter analyze`, `flutter test`
- Unit tests
  - Calculator inputs produce expected ranges for typical values.
  - Services: save profile/goal then load matches input.
- Manual
  - Complete onboarding → app lands on Today; relaunch keeps state.
  - Edit profile in Settings (later) recomputes target.

## Acceptance criteria
- Multi-step onboarding collects required inputs and persists profile/goal.
- Target calories calculated and visible on review.
- Post-completion app opens at `/today`.
- Analyzer/tests green.
