# SW-007 — Input and controller mapping

| Field | Value |
|---|---|
| Status | Not started |
| Milestone | M1 (bring-up), M3 (qualification) |
| Area | `area/input` |
| Depends on | SW-003 |
| Blocks | SW-019, SW-021 |
| Owner | unassigned |
| Branch | `switch-port` |

## Goal

Map Joy-Con, Pro Controller, and handheld controls to the N64 pad with the
project's existing profiles, deadlines, and assignment policy.

## Context

Desktop uses a separate SDL3 input worker; Android uses in-process SDL2. The
Switch build is in-process SDL2 (or libnx HID) and must feed the same
`runtime_input` contract. DKR-R's controller routing includes profiles,
assignment, and motion policies.

## Scope

- In scope: button mapping, analog stick deadzone/range, rumble, multiple
  controllers, handheld mode, hot-plug, and controller assignment.
- Out of scope: gyro steering (SW-021), touch UI (Switch has touch but the
  phase-1 UI is controller-first).

## Acceptance criteria

- [ ] Pro Controller and Joy-Con both drive the game.
- [ ] Handheld controls work with no paired controller.
- [ ] Analog steering/acceleration feel correct against desktop.
- [ ] Menu navigation, pause, and quick restart work on a controller only.
- [ ] Hot-plugging a controller does not freeze or duplicate input.
- [ ] Controller profiles/assignment survive relaunch.

## Implementation notes

Use the existing N64-to-modern mapping policy rather than a new table. Verify
whether devkitPro SDL2's gamepad layer covers all buttons/rumble; fall back to
libnx HID only for gaps. Keep the SDL3 worker out of the Switch build.

Watch for the Switch's inverted face-button labels (A/B, X/Y) versus the N64
layout; the mapping policy should own that decision.

## Relevant existing code

- `runtime-recomp/src/game/runtime_input.*`
- `runtime-recomp/src/game/controller_mapping_policy.hpp`
- `runtime-recomp/src/game/controller_assignment_policy.hpp`
- `runtime-recomp/src/game/input_backend_policy.hpp`
- `runtime-recomp/src/input/sdl3_input_host.cpp` (desktop-only reference)
- `docs/CONTROLLERS.md`

## Switch-specific risks

- SDL2 portlib gamepad support may lag libnx HID features.
- Joy-Con split mode reports two half-controllers; assignment must not double
  input.
- Rumble API differences between SDL2 and libnx.
- Handheld mode changes the active controller set at runtime.

## Validation

Device check: each controller type, handheld, hot-plug, menu + race, relaunch.

## Open questions

- Is rumble in phase 1 or deferred with gyro?
- Should the Switch default to a specific N64 button layout, or reuse the
  desktop default?

## Changelog

| Date | Change |
|---|---|
| 2026-11-03 | Created. |
