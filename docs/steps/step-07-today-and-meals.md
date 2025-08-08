# Step 07 — Today summary and meals (manual logging)

## Context & scope
Show a clear Today dashboard (calories remaining ring, macro bars) and allow manual logging of meals (add/edit/delete). Update totals instantly and persist entries.

## Implement
- UI
  - Today: calories remaining ring; macro bars with goal ticks; sections for Breakfast/Lunch/Dinner/Snack with empty states.
  - Entry form: name, meal type, calories, optional macros, portion/unit; edit/delete actions.
- Logic
  - Add/edit/delete via `LogService`; optimistic update of totals and list.
  - Compute DailyTotals from entries; remaining = goal.targetCalories − sum(entries).
- Persistence
  - Save `FoodEntry` to Hive via `LogService`; query by date for Today list.
- Tests
  - Widget: adding an entry increases totals; deleting reduces totals.
  - Service: add two entries for date; query returns both; delete removes one.

## Verify
- Commands: `flutter analyze`, `flutter test`
- Manual: add an entry; see Today totals update; relaunch app and entry persists.

## Acceptance criteria
- Today shows totals and meal sections with entries.
- Manual add/edit/delete updates Today instantly and persists to storage.
- Analyzer/tests green.
