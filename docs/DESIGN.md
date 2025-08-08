## UI/UX Design Spec (Ease & Usability)

### Theme
- Material 3 with light/dark; optional dynamic color.
- Tokens via `KSizes` for spacing/typography/radii; no magic numbers.
- Color states: under/on/over goal; contrast AA.

### Navigation
- Bottom Navigation (≤5): Today, Log, Trends, Goals, Settings.
- Center FAB: opens bottom sheet (Food, Water, Weight, Note).
- Deep links: `/log/add`, `/today`; preserve tab state.

### Onboarding (mobile-first wizard)
- 5–7 full-screen pages: Units → Profile (age/sex) → Height → Weight → Activity → Goal/Pace → Review.
- Navigation: persistent bottom bar with Back and Next/Continue; optional Skip where safe.
- Progress: top linear progress or dots indicator; page title with brief value framing.
- Inputs: one primary task per screen; numeric keypad for numbers; inline validation; sensible defaults.
- Persistence: save-as-you-go to `LocalStorage` to avoid losing progress; restore partially completed flows.
- Finish: compute target calories/macros; persist profile/goal; set onboardingComplete; CTA “Start tracking”.
- Permissions: requested at moment-of-value only (e.g., reminders later in Goals/Settings).

### Today
- Hero: calories remaining ring + macro bars; primary “Add” CTA.
- Meals list with empty states; recents/favorites chips.
- Quick water add; subtle streak indicator.

### Log
- Search-first; debounced; recents/favorites on top.
- Portion controls with unit selector; prepare slot for barcode.

### Trends
- 7/30d kcal vs target line/area; adherence %; weight trend line.
- Insight cards: avg deficit/surplus, best day.

### Goals & Settings
- Goal editor with presets (macro ratios); units; reminders; data export (later).

### Accessibility & Usability
- Min tap target 44x44; scalable text; semantic labels; focus order.
- Reduce motion respected; subtle haptics on success.
- Friendly empty/error states.

### Flutter components
- `NavigationBar` + `Scaffold` with center `FloatingActionButton`.
- Onboarding wizard: `PageView` (or `PageController`) + `LinearProgressIndicator`/dots indicator; bottom CTA bar.
- `showModalBottomSheet` for Add actions; `Card`-based layout via shared components.
- Charts via `fl_chart` with accessible labels.

### Verification checklist (per screen)
- Analyzer/tests green; tap targets ≥ 44x44; contrast AA; screen-reader labels; back behavior correct.


