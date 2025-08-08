# Step 02 — Global Add FAB and add flow stub

## Context & scope
Introduce the global Add entry point. The FAB opens an action sheet (Food, Water, Weight, Note) and a stub add screen at `/log/add`. No persistence yet; this is purely navigation and UX scaffolding.

## Implement
- Bottom sheet
  - Hook the center FAB to `showModalBottomSheet` with large actions: Food, Water, Weight, Note.
  - Ensure actions are accessible (labels) and ≥44x44 hit targets.
- Route & page
  - Add route `/log/add` in the router (under the shell) and create a simple `LogAddPage` with placeholder controls (e.g., text field + save button; save is a no-op for now).
  - Navigate to `/log/add` when selecting Food from the sheet.
- Deep link
  - Verify navigating directly to `/log/add` shows the page within the shell.
- Back behavior
  - Dismiss sheet on backdrop tap/drag; back from `/log/add` returns to `Log` tab.

## Verify
- Commands
  - `flutter analyze`
  - `flutter test`
  - `flutter run -d chrome`
- Manual checks
  - Tapping FAB opens the action sheet.
  - Tapping Food navigates to `/log/add`.
  - Visiting `/log/add` via deep link renders inside the shell; back returns to `Log` tab.
  - All actions are labeled and meet 44x44 minimum touch size.

## Acceptance criteria
- FAB action sheet appears and is dismissible.
- `/log/add` page is reachable from the sheet and via deep link.
- Back behavior correct; analyzer/tests green.
