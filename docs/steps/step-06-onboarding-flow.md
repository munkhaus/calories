# Step 06 — Onboarding flow (data + routing)

## Context & scope
Build the real onboarding wizard to collect units, demographics, activity, and goal/pace. Compute target calories using the calculator and persist profile/goal. Ensure startup redirects based on completion flag (already wired).

## Implement
- Screens (wizard pages)
  - Units (metric/imperial)
  - Demographics (age, sex, height, weight)
  - Activity level
  - Goal mode (lose/maintain/gain) + pace (kcal/day)
  - Review & confirm
- Logic
  - Use `CalorieCalculator` to compute target calories at review.
  - Persist `UserProfile` and `Goal` via `ProfileService` and `GoalService`.
  - Set onboardingCompleted in `LocalStorage` and redirect to `/today`.
- UX
  - Progress indicator, back/next, validation, save-as-you-go.
  - Ask permissions at moment-of-value (notifications optional, later).

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
