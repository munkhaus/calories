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

## Tech stack & conventions (align with template)
- Routing: `go_router` via `lib/core/router/app_router.dart` (named routes)
- DI: `get_it` via `lib/core/di/service_locator.dart`
- Models: `freezed` + `json_serializable` with immutable DTOs
- UI: Material 3, tokens in `KSizes` for spacing/typography/radii; no magic numbers
- State: `ChangeNotifier` services injected via `get_it` (upgrade path to Riverpod later)
- Linting: `flutter_lints` + `very_good_analysis`

## Navigation map (routes & tabs)
- Tabs: Today (`/today`), Log (`/log`), Trends (`/trends`), Goals (`/goals`), Settings (`/settings`)
- Global Add FAB: opens bottom sheet; deep link `/log/add`
- Onboarding: `/onboarding/*` with substeps: units, profile, activity, goal, reminders
- Edit flows: `/log/edit/:id`, `/goals/edit`, `/settings/profile`
- Start-up: redirect `/` → onboarding if incomplete else `/today`

## Design system specifics
- Color: seed color teal (adjustable), light/dark themes, high-contrast check
- Type: system font; sizes from `KSizes.fontSize{S|M|L|XL}`
- Spacing: base-4 scale from `KSizes.margin{1x..8x}`; components use `KSizes.buttonHeight`, `radiusDefault`
- Components: calories ring (3 states), macro bars with target ticks, add bottom sheet, cards with consistent padding/radius
- Haptics: subtle on add/delete/success

## Data model details (MVP)
- UserProfile
  - id (uuid), units (metric/imperial), age, sex, heightCm, weightKg, activityLevel
- Goal
  - id, startDate, mode (lose/maintain/gain), pace (kcal/day), targetCalories, macroRatio (carb/protein/fat)
- FoodEntry
  - id, date (yyyy-mm-dd), dateTime, mealType, name, calories, macros {c,p,f}, portion {value, unit}, source {manual,db,barcode}
- DailyTotals
  - date, calorieTotal, macrosTotal, deltaFromGoal
- WeightEntry
  - date, weightKg, note?
- WaterEntry
  - date, milliliters

Implementation notes:
- Use `freezed` models with `toJson/fromJson`; store dates as ISO strings, enums as strings.
- Provide `copyWith` for edits; validate value ranges in constructors.

## Persistence & storage
- Local DB: Hive (offline-first) with boxes: `profiles`, `goals`, `food_entries`, `weights`, `water`
- Keys: `id` as key for entries; composite index for date queries (via secondary maps)
- Migrations: versioned adapters; provide lightweight migration function per box
- Backups/Export: JSON export in Settings (post-MVP nice-to-have)

## State management
- Services: `ProfileService`, `GoalService`, `LogService` (food), `TrendsService`
- Presentation: lightweight `ChangeNotifier` view models per screen
- DI: register services as lazy singletons in `service_locator.dart`

## Testing & CI
- Unit: calorie calculator (Mifflin–St Jeor → TDEE), services logic
- Widget: Today totals update, Onboarding stepper navigation, Add flow validations
- Golden: key components (calories ring, macro bars) stable visuals
- CI: run analyze + tests on PR via `.github/workflows/ci.yml`; require green to merge

## Platform targets & defaults
- Platforms: iOS 15+, Android 8+; Web best-effort for demos
- Localization: English only MVP; prepare for i18n (string centralization)
- Analytics: none in MVP; add later if needed

## Defaults & calculations
- Calorie math: Mifflin–St Jeor for BMR; TDEE via activity multiplier; adjust with pace (e.g., -500 kcal/day)
- Macro default: 40/30/30 (carb/protein/fat) with presets; allow manual override in Goals
- Meals: Breakfast, Lunch, Dinner, Snack

## Package backlog (to add when implementing)
- Hive: `hive`, `hive_flutter`, build adapters via `build_runner`
- Charts: `fl_chart` (trends)
- Barcode (post-MVP): `mobile_scanner` or ML Kit
- Date utils: `intl`

