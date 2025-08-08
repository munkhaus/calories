# Step 05 — Persistence scaffolding (Hive boxes and services)

## Context & scope
Introduce offline-first persistence for core models using Hive. Define boxes and repository-like services for profile, goal, and logging food entries, and wire them via DI. This enables onboarding to save profile/goal and Today/Log screens to read/write entries.

## Implement
- Boxes (Hive)
  - Open boxes at startup (in `LocalStorage` or a dedicated `HiveBoxes` helper):
    - `profiles`, `goals`, `food_entries`, `weights`, `water` (strings → JSON maps)
  - Keying:
    - `profiles`: key by user id (single-user MVP can use `default`)
    - `goals`: key by goal id (or `current`)
    - `food_entries`: key by entry id; maintain auxiliary date index map `{date: [ids...]}` for quick day queries
- Services (repositories)
  - `ProfileService`
    - getProfile(): `UserProfile?`
    - saveProfile(UserProfile)
  - `GoalService`
    - getGoal(): `Goal?`
    - saveGoal(Goal)
  - `LogService`
    - addEntry(FoodEntry)
    - getEntriesByDate(String yyyyMmDd): `List<FoodEntry>`
    - deleteEntry(String id)
  - Store JSON with `toJson()`; reconstruct with `fromJson()`; validate ids/fields
- DI wiring
  - Register services as lazy singletons in `service_locator.dart`
  - Ensure boxes are opened once during app init
- Simple UI hook (optional for manual verify)
  - On `/log/add` stub, add a temporary "Save demo entry" button that writes a `FoodEntry` for today

## Verify
- Commands
  - `flutter analyze`
  - `flutter test`
- Unit tests
  - ProfileService: save + load roundtrip
  - LogService: add two entries for today, query by date returns both; delete works
- Manual checks
  - Run app, complete onboarding; add a demo entry; hot-restart or relaunch → entry remains

## Acceptance criteria
- Boxes open at startup without errors; services registered via DI
- Saving/loading profile and goal works
- Adding/querying/deleting food entries by date works and persists across app restarts
- Analyzer/tests green
