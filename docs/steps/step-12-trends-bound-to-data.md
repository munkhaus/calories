# Step 12 — Trends bound to real data

## Context & scope
Bind Trends charts to real logged data with 7/30d ranges, adherence %, and streaks.

## Implement
- Aggregation service: totals/day for a date range; adherence (within ±10% target); longest current streak
- UI: Segmented control 7d/30d; line/area chart for kcal vs target; adherence and streak indicators

## Verify
- Unit: aggregation math, adherence %, streaks
- Widget: range switch updates chart/metrics using fixtures
- Commands: flutter analyze, flutter test

## DoD
- Trends reflects real data for 7/30 days
- Adherence and streaks visible
- Tests green
