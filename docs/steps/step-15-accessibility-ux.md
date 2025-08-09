# Step 15 — Accessibility & UX refinements

## Context & scope
Ensure a11y and UX quality: semantics, focus, contrast, reduce motion, haptics.

## Implement
- Add semantic labels to charts/buttons; ensure focus order; increase tap targets where needed
- Respect reduce motion; add subtle haptics on success actions

## Verify
- Widget: semantics checks exist on key widgets
- Manual: check with VoiceOver/TalkBack locally
- Commands: flutter analyze, flutter test

## DoD
- Key flows accessible; semantics present; no major a11y violations
- Tests green
