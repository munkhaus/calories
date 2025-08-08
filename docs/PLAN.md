## MVP Objective
Ship a calorie counter MVP with onboarding, daily logging, and trends, ready for internal testing.

## Milestones (6 Weeks)

### Week 1 — Foundation: Routing, Design System, Placeholders
- Routes: `/onboarding/*`, `/today`, `/log/add`, `/trends`, `/goals`, `/settings`
- Bottom tabs + global Add FAB
- Material 3 theme, colors, type, spacing
- Placeholder screens wired via router
- DoD: builds on iOS/Android/Web; lints/tests/CI green

### Week 2 — Onboarding + Calorie Target
- Steps: units → demographics → activity → goal (lose/maintain/gain, pace)
- Compute BMR (Mifflin–St Jeor) → TDEE → daily target; default macro split
- Persist profile/goal locally
- DoD: app lands on Today after completion; editing profile recalculates target; unit tests for calc

### Week 3 — Today Screen + Meals + Quick Add
- Calories remaining ring, macro bars, goal delta
- Meal sections (Breakfast/Lunch/Dinner/Snack)
- Manual entry add/edit/delete; water quick add
- DoD: optimistic updates; empty states; widget tests for totals

### Week 4 — Add Flow (Search/Recents) + Data Model
- Search-first add with Recents/Favorites; manual fallback
- Portion/unit selector; duplicate; meal templates
- Finalize local DB (Isar/Hive) with migrations
- DoD: typical item logged <10s; recents visible after first day; schema migration-safe

### Week 5 — Trends & Insights
- Weekly/monthly kcal vs target chart; adherence %
- Weight entries + line chart; streak indicator
- DoD: trends reflect logged data; 7/30d filters; insight cards (avg deficit/surplus)

### Week 6 — Polish, Accessibility, Release Prep
- A11y labels, dynamic type, contrast; haptics
- Error/empty states; loading skeletons
- Icons, splash, versioning, release notes
- DoD: internal builds on TestFlight/Play Internal; crash-free >99.5% (internal)

## Information Architecture
- Bottom tabs: Today, Log, Trends, Goals, Settings
- Global Add (Food, Water, Weight, Note, Template)
- Deep links: `calories://today`, `calories://add`

## Data Model (MVP)
- UserProfile: demographics, units, activityLevel
- Goal: targetCalories, macroRatio, startDate, pace
- FoodEntry: id, dateTime, mealType, name, calories, macros, portion
- DailyTotals: date, totals, deltaFromGoal
- WeightEntry: date, weight
- WaterEntry: date, ml

## QA Pass (weekly)
- Onboarding persists and routes to Today
- Add/edit/delete entries update totals; day rollover OK
- Trends match sample data; app relaunch restores state
- Offline basic usage OK

## Risks & Mitigation
- Food DB: start manual + recents; add Open Food Facts later
- Web parity: best-effort; prioritize iOS/Android
- Scope creep: lock MVP; defer barcode/health integrations post-MVP

## Metrics (internal)
- Retention proxy (sessions), days logged/week, items logged/day
- Add-flow completion rate, adherence %, crash-free sessions


