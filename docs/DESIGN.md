## UI/UX Design Spec (Ease & Usability)

### Theme
- Material 3 with light/dark; optional dynamic color.
- Tokens via `KSizes` for spacing/typography/radii; no magic numbers.
- Color states: under/on/over goal; contrast AA.

### Typography
- Font: system (SF Pro/Roboto) or Inter as fallback.
- Type scale (examples): 32–36 Today headline, 20–22 section titles, 16 body, 14 secondary.
- Weights: 600 key numbers (remaining kcal), 500 section titles, 400 body.
- Line height ≥ 1.25; min text size 14 for labels.

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
- Hero: large remaining kcal with ring progress and short delta vs target; primary “Add” CTA.
- Macro chips beneath hero (carb/protein/fat) using compact pill chips; tap to expand details.
- Quick-add chips for Recents/Favorites; templates surfaced contextually; empty states with guidance.
- Inline coach tip (short, contextual) when helpful.
- Quick water add; subtle streak indicator.

### Log
- Search-first with prominent search field; debounced results.
- Recents/Favorites as pill chips above results (pinned first); long-press to pin/unpin.
- Portion controls with unit selector; templates for frequent meals.
- Undo snackbar on add/delete; consistent quick-add affordances.

### Trends
- Range toggle segmented control (7/30 days); kcal vs target line/area.
- Adherence % (days within ±10% target); streak badge.
- Weight trend; insight cards (avg deficit/surplus, best day).
 - Optional overlays: BMI trend/last BMI with category label.

### Goals & Settings
- Goal editor: mode presets (lose/maintain/gain), pace slider, live impact preview; macro presets.
- Units; reminders; privacy text; data export (later).

### Accessibility & Usability
- Min tap target 44x44; scalable text; semantic labels for rings/charts; focus order.
- Reduce motion respected; subtle haptics on success; dark mode supported.
- Friendly empty/error states.

### Motion & Microinteractions
- Bottom sheet uses medium depth with drag handle; slight spring on open/close.
- Snackbars confirm add/delete with undo; lightweight haptic for success.

### Imagery & Icons
- Prefer MD3 icons (outlined). Avoid stock photos.
- Empty states may include subtle monochrome illustrations; do not compete with data.

### Inspiration & competitive patterns (applied)
- From Good Housekeeping’s roundup: emphasize ease of logging, hydration tracking, macro clarity; avoid over-reliance on crowd-sourced DB accuracy by prioritizing manual entry + recents/favorites; keep core features free in MVP and defer barcode scanning to post-MVP. Also include mindful-eating nudges and overall lifestyle framing (sleep/activity) as future insights. [Good Housekeeping best calorie-counting apps](https://www.goodhousekeeping.com/health-products/g28246667/best-calorie-counting-apps/)
- From Nutrio UI kit: large hero number, rounded cards, pill chips for filters, segmented controls for periods, and a modal add sheet with clear iconography. Adopt these visual patterns within Material 3 for a modern, mobile-first look. [Nutrio Calorie Counter App UI Kit](https://dribbble.com/shots/24692953-Nutrio-Calorie-Counter-App-UI-Kit)

### Flutter components
- `NavigationBar` + `Scaffold` with center `FloatingActionButton`.
- Onboarding wizard: `PageView` (or `PageController`) + `LinearProgressIndicator`/dots indicator; bottom CTA bar.
- `showModalBottomSheet` for Add actions; `Card`-based layout via shared components.
- Charts via `fl_chart` with accessible labels.

### Verification checklist (per screen)
- Analyzer/tests green; tap targets ≥ 44x44; contrast AA; screen-reader labels; back behavior correct.


