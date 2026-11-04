# SW-012 — Applet lifecycle, background, and resume

| Field | Value |
|---|---|
| Status | Not started |
| Milestone | M3 |
| Area | `area/runtime` |
| Depends on | SW-003 |
| Blocks | SW-016 |
| Owner | unassigned |
| Branch | `switch-port` |

## Goal

Handle Switch applet lifecycle events (focus loss, suspend, resume, dock,
handheld, exit) without crashing, losing saves, or leaving audio/renderer
threads in a bad state.

## Context

Android ends an active experimental match on background rather than leaving
peers waiting. Switch homebrew can be suspended by the HOME button, the
console can sleep, and the applet type changes memory/audio behavior. The
runtime already has ownership and teardown contracts that must be respected.

## Scope

- In scope: focus gain/loss, suspend/resume, dock/undock, exit, applet mode
  transitions, audio/renderer pause, save flush.
- Out of scope: online disconnect policy (SW-019).

## Acceptance criteria

- [ ] Pressing HOME and resuming does not crash or duplicate audio.
- [ ] Console sleep/wake resumes to a valid frame.
- [ ] Dock/undock triggers a clean surface resize.
- [ ] A pending save is flushed before suspend/exit.
- [ ] Exiting returns to the homebrew menu cleanly.
- [ ] No thread or GPU resource leak across three suspend/resume cycles.

## Implementation notes

Use libnx applet hooks (`appletMainLoop`, focus handlers) or the SDL2 event
equivalents. Coordinate with the existing save-lease and renderer-snapshot
ownership; do not tear down the renderer while guest state still references it.

Decide the policy for an active race on suspend: pause locally, or end the
session. Phase 1 is offline, so pausing is acceptable.

## Relevant existing code

- `runtime-recomp/src/switch/switch_main.cpp`
- `runtime-recomp/src/game/game_main.cpp`
- `runtime-recomp/src/game/startup_flow.*`
- `runtime-recomp/src/game/runtime_save_routing.*`
- `runtime-recomp/src/game/renderer_snapshot.*`

## Switch-specific risks

- Applet mode can be suspended at any instruction, including mid-save.
- Audio device may be invalidated on resume.
- Dock/undock changes the surface size while RT64 holds references.
- HOME may not deliver a clean shutdown event to a busy loop.

## Validation

Device check: HOME/resume, sleep/wake, dock/undock, exit — three cycles each.

## Open questions

- Should the app request background execution, or suspend immediately?
- What is the expected behavior for an in-progress race on resume?

## Changelog

| Date | Change |
|---|---|
| 2026-11-03 | Created. |
