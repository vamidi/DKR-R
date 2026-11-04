# SW-010 — Launcher and in-game UI

| Field | Value |
|---|---|
| Status | Not started |
| Milestone | M3 |
| Area | `area/ui` |
| Depends on | SW-008 |
| Blocks | SW-014, SW-016 |
| Owner | unassigned |
| Branch | `switch-port` |

## Goal

Make the launcher and in-game UI usable with a controller on the Switch,
including ROM import, play, settings, saves, and the return-to-launcher flow.

## Context

The desktop UI is ImGui over SDL2; Android adds a mobile drawer and touch
layout. Switch is controller-first with a 16:9 display and no keyboard/mouse
assumption. Touch exists but should not be required.

## Scope

- In scope: launcher navigation, text legibility at handheld/docked sizes,
  settings pages that matter on Switch, save/ROM import screens, overlays,
  on-screen prompts, and the return-to-launcher flow.
- Out of scope: mobile touch layout (Android-only), netplay UI (SW-019), mod
  library (SW-020).

## Acceptance criteria

- [ ] Launcher is fully navigable with a Pro Controller and in handheld mode.
- [ ] Text is legible at handheld and docked resolutions.
- [ ] ROM import and play flow work without a mouse or keyboard.
- [ ] Settings changes persist and apply.
- [ ] Return to launcher from gameplay is clean (no leaked renderer state).
- [ ] Error dialogs are actionable on the console.

## Implementation notes

Reuse `runtime_ui` and the existing ImGui backend; do not fork the UI. Add a
Switch-specific layout policy only where the form factor requires it (for
example, safe-area margins and larger focus rings).

Check whether the ImGui SDL2 backend can use the Switch's touch input without
pulling in the Android rotation layer.

## Relevant existing code

- `runtime-recomp/src/game/startup_flow.*`
- `runtime-recomp/src/game/runtime_ui.*`
- `runtime-recomp/src/game/runtime_play_ui.inl`
- `runtime-recomp/src/game/runtime_settings_ui.inl`
- `runtime-recomp/src/game/launcher_*`
- `runtime-recomp/src/game/application_layout.hpp`
- `docs/LAUNCHER.md`

## Switch-specific risks

- 1280x720 handheld vs 1920x1080 docked scaling.
- No reliable keyboard; text entry needs an on-screen keyboard or preset list.
- Focus/navigation semantics differ from mouse hover.
- UI redraw cost matters while the GPU is still untuned.

## Validation

Device check: complete launcher → import → play → settings → quit loop with a
controller only, in both handheld and docked modes.

## Open questions

- Is a Switch-specific "TV/Handheld" settings page needed?
- Should touch be supported in phase 1 for menus?

## Changelog

| Date | Change |
|---|---|
| 2026-11-03 | Created. |
