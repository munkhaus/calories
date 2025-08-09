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
- Progress: top linear progress or dots indicator; brief value framing per page.
- Inputs: single task per screen; numeric keyboards; inline validation; defaults.
- Live preview: show computed target at Review and update as inputs change.
- Persistence: save-as-you-go; restore mid-flow.
- Finish: compute target; persist profile/goal; set onboardingComplete; CTA “Start tracking”.
- Permissions: moment-of-value only.

### Today
- Hero: calories remaining ring + macro bars; delta vs target; primary “Add” CTA.
- Quick-add row (common snacks/templates); empty states with guidance.
- Inline coach tip (short, contextual) when helpful.
- Quick water add; subtle streak indicator.

### Log
- Search-first; debounced; recents/favorites chips above results.
- Portion controls with unit selector; templates for frequent meals.
- Undo snackbar on add/delete; consistent quick-add affordances.

### Trends
- Range toggle (7/30 days); kcal vs target line/area.
- Adherence % (days within ±10% target); streak badge.
- Weight trend; insight cards (avg deficit/surplus, best day).

### Goals & Settings
- Goal editor: mode presets (lose/maintain/gain), pace slider, live impact preview; macro presets.
- Units; reminders; privacy text; data export (later).

### Accessibility & Usability
- Min tap target 44x44; scalable text; semantic labels for rings/charts; focus order.
- Reduce motion respected; subtle haptics on success; dark mode supported.
- Friendly empty/error states.

### Flutter components
- `NavigationBar` + `Scaffold` with center `FloatingActionButton`.
- Onboarding wizard: `PageView` (or `PageController`) + `LinearProgressIndicator`/dots indicator; bottom CTA bar.
- `showModalBottomSheet` for Add actions; `Card`-based layout via shared components.
- Charts via `fl_chart` with accessible labels.

### Verification checklist (per screen)
- Analyzer/tests green; tap targets ≥ 44x44; contrast AA; screen-reader labels; back behavior correct.


