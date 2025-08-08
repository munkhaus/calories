## MVP Objective
Ship a calorie counter MVP with onboarding, daily logging, and trends, ready for internal testing.

See also: `docs/DESIGN.md` for concrete UI/UX spec.

## Core MVP scope (focus)
- In scope:
  - Onboarding (units, demographics, activity, goal) with target kcal/macros
  - Today dashboard (calories ring, macro bars), meal logging (manual), water quick add
  - Trends basics (weekly/monthly kcal vs target, adherence), weight entries
  - Local persistence (Hive), offline-first, English, iOS/Android
  - Navigation (tabs + add flow), theme (Material 3), DI, tests, CI
- Out of scope (post-MVP):
  - Barcode scanning and public food DB search
  - Wearables/HealthKit/Google Fit
  - Home screen widgets, voice/Siri/Shortcuts
  - AI/vision food logging, social features, cloud sync

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

Status: Hive is initialized and used for an `onboardingCompleted` flag to support routing. Full boxes and repositories for profile/goal/entries remain planned for Step 5.

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

## Step-by-step implementation & verification

Follow these steps in order. After each step, the app should build and the verification checks should pass before moving on.

Per-step verify commands:
- Run: `flutter analyze` (no issues), `flutter test` (all pass), and launch on one device (`flutter run -d chrome` or mobile)

Step 0 — Baseline (already done)
- Implement: Ensure template builds from clean clone.
- Verify: App runs; analyzer/tests green.

Step 1 — Routing skeleton and tabs
- Implement:
  - Create feature directories: `lib/{onboarding,today,log,trends,goals,settings}/presentation`.
  - Add placeholder pages for: Today, Log, Trends, Goals, Settings.
  - Replace `MyHomePage` with a `ShellRoute` tab scaffold (GoRouter) and start destination `/today`.
  - Redirect `/` to onboarding if not completed (temporary in-memory flag), else `/today`.
- Verify:
  - App launches to Today; bottom tabs switch screens; back button behavior correct.
  - Run analyzer/tests; commit.

Step 2 — Global Add FAB and add flow stub
- Implement:
  - Place a centered FAB in tab scaffold.
  - On tap, open bottom sheet with actions: Food, Water, Weight, Note (stub routes).
  - Add route `/log/add` and a simple add page.
- Verify:
  - FAB opens sheet; navigating to `/log/add` works via deep link and UI.
  - Analyzer/tests; commit.

Step 3 — Theme and design tokens
- Implement:
  - Configure Material 3 with teal seed; light/dark themes.
  - Ensure all paddings/radii/font sizes use `KSizes` (no magic numbers).
  - Create shared components: `AppScaffold`, `AppCard` (with consistent padding, radius).
- Verify:
  - Visual consistency across all pages; analyzer clean; commit.

Step 4 — Models: Profile, Goal, Entries (freezed)
- Implement:
  - Define `UserProfile`, `Goal`, `FoodEntry`, `DailyTotals`, `WeightEntry`, `WaterEntry` with `freezed` and `json_serializable`.
  - Add calorie calculator (Mifflin–St Jeor → TDEE) utility.
- Verify:
  - Unit tests for calculator and model JSON roundtrip.
  - Analyzer/tests; commit.

Step 5 — Persistence scaffolding (Hive)
- Implement:
  - Add `hive`, `hive_flutter`; initialize in `main()`.
  - Create adapters/boxes and simple repository interfaces: `ProfileService`, `GoalService`, `LogService`.
  - Register services in `service_locator.dart`.
- Verify:
  - Save/load a dummy profile and a food entry; survives app restart.
  - Analyzer/tests; commit.

Note: Minimal Hive init was introduced earlier to persist onboarding completion. This step still delivers the full schema (boxes, adapters, services).

Step 6 — Onboarding flow (data + routing)
- Implement:
  - Wizard pages for: units → demographics → activity → goal/pace → review.
  - On finish: compute targetCalories, default macros; persist profile/goal; set onboarding complete.
  - Start-up redirect logic using persisted flag.
- Verify:
  - Complete onboarding; relaunch app lands on Today.
  - Unit tests for calculator inputs; analyzer/tests; commit.

Step 7 — Today summary and meals (manual logging)
- Implement:
  - Calories remaining ring and macro bars bound to today’s totals.
  - Meal sections (Breakfast/Lunch/Dinner/Snack) with empty states.
  - Manual add/edit/delete entry screen; optimistic updates via `LogService`.
- Verify:
  - Adding/editing/deleting updates totals instantly; day rollover keeps history.
  - Widget tests for totals; analyzer/tests; commit.

Step 8 — Recents and quick add
- Implement:
  - Track recents/favorites in `LogService`.
  - Quick-add chips in add screen; duplicate last item.
- Verify:
  - Recent items appear after first day; quick add updates totals.
  - Analyzer/tests; commit.

Step 9 — Trends basics
- Implement:
  - Weekly/monthly kcal vs target line/area chart using `fl_chart`.
  - Adherence %, streak indicator; weight chart bound to `WeightEntry` data.
- Verify:
  - Charts reflect logged data; 7/30d filters; analyzer/tests; commit.

Step 10 — Polish and release prep (MVP)
- Implement:
  - Accessibility labels, dynamic type, contrast; error/empty states; haptics.
  - App icon/splash; versioning; privacy text in Settings.
- Verify:
  - Manual QA on iOS/Android; CI green; archive builds succeed.
  - Commit and tag `v0.1.0`.

Per-step commit message format: `feat(step-x): <summary>` or `chore(step-x): <summary>`.

### Steps index
- Step 01 — Routing skeleton and tabs: `docs/steps/step-01-routing-and-tabs.md`
- Step 02 — Global Add FAB and add flow stub: `docs/steps/step-02-add-flow.md`
- Step 03 — Theme, tokens, and shared components: `docs/steps/step-03-theme-and-components.md`
- Step 04 — Domain models and calorie calculator: `docs/steps/step-04-models-and-calculator.md`
- Step 05 — Persistence scaffolding (Hive): `docs/steps/step-05-persistence-hive.md`
- Template for future steps: `docs/steps/_template.md`

Progress log lives in: `docs/PROGRESS.md`

## Extensibility and architecture notes
- Routing: new features mount under their own route roots (e.g., `/barcode`, `/recipes`) without breaking tabs.
- Services: feature services behind interfaces (e.g., `IFoodLookupService`) so we can swap implementations (local/manual → Open Food Facts).
- Data: Hive boxes versioned; new boxes use separate adapters to avoid breaking existing data.
- UI: shared components (`AppScaffold`, `AppCard`, tokens in `KSizes`) ensure consistent look when adding new screens.
- Permissions: request at time-of-value (e.g., prompt for camera only when opening barcode scan).

## Post-MVP feature backlog (implementable later)
- Barcode scanning + Open Food Facts (Effort: M)
  - How: `mobile_scanner` → scan EAN → fetch `https://world.openfoodfacts.org/api/v2/product/{barcode}.json` with `dio` → map to `FoodEntry` → cache by barcode in Hive.
  - Prereqs: none; integrates with Log add flow.

- Food text search (Open Food Facts) (Effort: M)
  - How: `/cgi/search.pl` query with pagination; debounce; recents cache; offline last results.
  - Prereqs: shared DTOs and mapping; integrates with same add screen.

- Recipe builder & templates (Effort: M)
  - How: `Recipe` model (list of `FoodEntry` with grams/units) → totals per serving → save & quick-add.
  - Prereqs: Today/log storage; adds new `recipes` box.

- Water tracking enhancements (Effort: S)
  - How: configurable increment, daily goal, reminders via `flutter_local_notifications`.
  - Prereqs: existing `WaterEntry`.

- Weight tracking trends (Effort: S)
  - How: `fl_chart` line chart with smoothing; rate vs plan; edit history.
  - Prereqs: `WeightEntry` data.

- Smart reminders (Effort: M)
  - How: schedule meal/water notifications; snooze; timezone-aware.
  - Prereqs: local notifications setup.

- Wearables (HealthKit/Google Fit) (Effort: M-L)
  - How: `health` plugin to read/write weight/energy; surface source attribution; graceful fallback.
  - Prereqs: permissions UX; settings toggles.

- Home/lock screen widgets (Effort: M)
  - How: `home_widget` to show remaining kcal and quick-add actions; periodic updates.
  - Prereqs: Today totals service.

- Export/Import JSON (Effort: S)
  - How: serialize Hive contents per box; `share_plus` for export; import with duplicate checks.
  - Prereqs: stable model JSON.

- AI photo logging (Effort: L, R&D)
  - How: capture photo → client-side segmentation/count (optional) → server/Lite model for classification → manual confirm → log.
  - Prereqs: out of MVP; gated behind experiments.

Backlog integration rule: ship one feature per minor release without regressing MVP flows; analyzer/tests must remain green; add feature flags when risky.

