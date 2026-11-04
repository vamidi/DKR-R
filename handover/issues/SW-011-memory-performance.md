# SW-011 — Memory ceilings and performance

| Field | Value |
|---|---|
| Status | Not started |
| Milestone | M3 |
| Area | `area/performance` |
| Depends on | SW-003, SW-008 |
| Blocks | SW-014, SW-016 |
| Owner | unassigned |
| Branch | `switch-port` |

## Goal

Keep DKR-R within the Switch's applet memory budget and reach a stable
frame rate on Tegra X1 in handheld and docked modes.

## Context

The applet heap is roughly 1.8 GB and the texture/upscaler budgets can exceed
it. Android already has memory-pressure ceilings (`android_memory_*`). Switch
also needs applet heap sizing, optional clock boost, and track-level profiling.

## Scope

- In scope: heap sizing, texture-cache trim, graphics presets, frame pacing,
  docked/handheld defaults, profiling on representative tracks.
- Out of scope: renderer feature work (SW-008), UI layout (SW-010).

## Acceptance criteria

- [ ] Peak memory stays under the measured applet budget in both modes.
- [ ] Texture-cache trim prevents OOM on the heaviest tracks.
- [ ] A stable target frame rate is defined and measured per mode.
- [ ] Startup time is measured and documented.
- [ ] Graphics presets are tuned for Switch defaults.
- [ ] No leak across repeated launcher ↔ race cycles.

## Implementation notes

Model the ceilings on `android_memory_budget.hpp` / `android_memory_policy.hpp`
but measure the Switch's actual available heap; do not copy Android numbers.
Use the existing performance trace/telemetry hooks.

Test the known heavy scenes (water, lava, split-screen) called out in the
desktop performance docs.

## Relevant existing code

- `runtime-recomp/src/game/android_memory_budget.hpp`
- `runtime-recomp/src/game/android_memory_policy.hpp`
- `runtime-recomp/src/game/render_resource_policy.hpp`
- `runtime-recomp/src/game/graphics_snapshot_pool.hpp`
- `runtime-recomp/src/game/performance_trace.*`
- `runtime-recomp/src/game/track_performance.hpp`
- `docs/TRACK-PERFORMANCE.md`, `docs/CPU-POWER-OPTIMISATION.md`

## Switch-specific risks

- Applet vs application mode changes available memory.
- Thermal throttling on sustained play.
- Docked mode increases resolution and memory pressure.
- `svcSetThreadCoreMask`/clock APIs may not be available in all applet modes.

## Validation

Device check: profile heavy tracks in both modes; run a repeated launcher/race
cycle and watch memory.

## Open questions

- What is the minimum acceptable frame rate: 30 or 60?
- Is a dynamic resolution scaler in scope, or a fixed preset?

## Changelog

| Date | Change |
|---|---|
| 2026-11-03 | Created. |
