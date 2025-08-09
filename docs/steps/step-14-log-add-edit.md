# Step 14 — Log Add/Edit flows

## Context & scope
Complete manual Add/Edit/Delete of food entries.

## Implement
- Add page: fields name, calories, mealType, date/time; Save adds entry
- Edit page: `/log/edit/:id` prefill; Save updates; Delete removes
- Update Recents usage on add

## Verify
- Widget: add/edit/delete updates Today totals
- Integration: add → Today reflects
- Commands: flutter analyze, flutter test, optional integration on iOS sim

## DoD
- Add and Edit flows operational and persisted
- Recents usage increments on add
- Tests green
