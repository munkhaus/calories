# Step 11 — Recents & Favorites completion (pin, promotion, usage)

## Context & scope
Complete Recents/Favorites by adding pin/unpin, usage metrics, and auto-promotion.

## Implement
- UI: pin/unpin affordance on chips (long-press or icon)
- Sort: pinned first, then by timesUsed desc, lastUsedAt desc
- Persist: update usage on add; store in Hive
- Auto-promote: if used ≥3 times within last 7 days → move to Favorites

## Verify
- Unit: promotion rule; LRU capping
- Widget: pin/unpin persists across app restarts
- Commands: flutter analyze, flutter test

## DoD
- Pin/unpin works and persists
- Recents/Favorites order stable by rules
- Tests green
