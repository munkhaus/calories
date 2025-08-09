# Step 13 — Goals editor

## Context & scope
Add a basic Goals editor to adjust mode/pace/target and recompute via CalorieCalculator.

## Implement
- UI form on Goals: mode (lose/maintain/gain), pace (kcal/day), target (computed)
- Persist to GoalService; snackbar confirm; validation ranges

## Verify
- Unit: calculator recompute; service save/load
- Widget: edit flow recomputes target and persists
- Commands: flutter analyze, flutter test

## DoD
- Editing goals updates Today target after save
- Validations enforced
- Tests green
