# Step 08 — Recents & Favorites and quick add

## Context & scope
Speed up logging by surfacing Recents and Favorites with one-tap quick adds. Persist usage and allow pinning.

## Implement
- Data
  - `favorites` Hive box keyed by food id; value = FavoriteItem JSON (id, name, default portion/unit, macros, timesUsed, lastUsedAt, pinned).
  - Recents: per-day LRU id list stored in `food_entries` box as `date_index_<yyyy-mm-dd>` (already exists); expose most-used last N across recent days.
- Service API (LogService)
  - on addEntry: update usage for that id, set lastUsedAt; if above threshold or pinned, ensure exists in favorites.
  - getRecents({limit}) → List<FoodEntry> from latest date indices.
  - getFavorites({limit, onlyPinned}) → List<FavoriteItem> ordered by pinned desc, lastUsedAt desc.
  - pinFavorite(id, pinned: bool)
- UI
  - Log page: two rows of chips/cards: Favorites (pinned first), Recents.
  - Add page: same rows above search field; long-press chip to pin/unpin.
  - Quick add duplicates last used portion and updates totals immediately.

## Verify
- Analyzer/tests
  - Unit test: adding same id multiple times increments timesUsed and updates lastUsedAt; pin persists.
  - UI smoke: chips render; tapping adds an entry; long-press toggles pin.
- Manual
  - Add an item twice → appears in Recents; pin it → appears in Favorites and remains after relaunch.

## Acceptance criteria
- Favorites and Recents are persisted and ordered as expected.
- Quick-add via chips works and updates Today totals instantly.
- Analyzer/tests green.
