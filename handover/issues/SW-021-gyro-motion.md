# SW-021 — Gyro and motion steering (deferred)

| Field | Value |
|---|---|
| Status | **Deferred** (phase 2+) |
| Milestone | M6 |
| Area | `area/input` |
| Depends on | SW-007 |
| Blocks | — |
| Owner | unassigned |
| Branch | `switch-port` |

## Goal

Add optional motion steering using Joy-Con/Pro Controller gyro, integrated with
the existing motion policy rather than as a separate control path.

## Context

The project already has motion steering policy hooks for desktop/mobile
controllers. Switch exposes gyro through libnx HID / SDL2 sensor APIs. Phase 1
is controller-stick only; gyro is explicitly deferred in the approved plan.

## Scope

- In scope: sensor read, calibration, deadzone/smoothing, enable/disable
  setting, and interaction with steering-wheel policy.
- Out of scope: IR camera, HD rumble-based feedback, motion in menus.

## Acceptance criteria

- [ ] Gyro is opt-in and off by default.
- [ ] Joy-Con and Pro Controller motion both work.
- [ ] Calibration/drift handling is usable.
- [ ] Motion steering does not fight the analog stick when both are active.
- [ ] Toggling it at runtime does not require a restart.
- [ ] Handheld mode behaves sensibly.

## Implementation notes

Reuse `motion_steering_policy.hpp`; do not add a parallel steering model. Check
whether devkitPro SDL2 exposes the sensor API or whether libnx HID sixaxis is
required.

## Relevant existing code

- `runtime-recomp/src/game/motion_steering_policy.hpp`
- `runtime-recomp/src/game/steering_wheel_policy.hpp`
- `runtime-recomp/src/game/runtime_input.*`
- `docs/CONTROLLERS.md`

## Switch-specific risks

- Sensor axes/orientation differ between Joy-Con and Pro Controller.
- Drift varies per unit; calibration UI may be needed.
- Handheld mode couples controller and screen motion.
- Extra sensor polling can affect battery/frame time.

## Validation

Device check: enable gyro, steer a full race with each controller type, disable
at runtime, and test handheld.

## Open questions

- Should gyro combine with the stick (hybrid) or replace it?
- Is a calibration wizard required for phase 2?

## Changelog

| Date | Change |
|---|---|
| 2026-11-03 | Created; deferred by the phase-1 plan. |
