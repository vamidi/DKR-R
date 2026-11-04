# SW-008 — Graphics: RT64 over nxvk

| Field | Value |
|---|---|
| Status | Not started |
| Milestone | M2 |
| Area | `area/graphics` |
| Depends on | SW-003, SW-001 |
| Blocks | SW-009, SW-010, SW-011, SW-014 |
| Owner | unassigned |
| Branch | `switch-port` |

## Goal

Render DKR-R through RT64's Vulkan backend using the nxvk portlib (Mesa NVK on
Tegra X1), presenting to the Switch's VI display.

## Context

`FindNXVK.cmake` and `HostShaders.cmake` exist, and `extern/nxvk` is pinned at
`c3abea1efde` (VERSION 26.2.2), but the portlib is not installed
(`nxvk.pc` absent). There is no `switch_rt64_window.cpp` and no
`rt64_renderer.cpp` Switch branch. This is the highest-risk milestone.

## Scope

- In scope: nxvk portlib build/install, Vulkan instance/device creation, VI_NN
  surface/presentation, swapchain, resize/dock, RT64 renderer integration,
  first rendered menu.
- Out of scope: shader cache packaging (SW-009), UI polish (SW-010),
  performance tuning (SW-011).

## Acceptance criteria

- [ ] `scripts/Build-NXVK.ps1` completes and installs `nxvk.pc` plus
      `libnvk*.a` into the devkitPro portlibs.
- [ ] `FindNXVK.cmake` creates `nxvk::nxvk` and the link succeeds.
- [ ] A minimal Vulkan probe creates an instance/device and presents a clear
      frame on device.
- [ ] `switch_rt64_window.cpp` supplies the native window handle to RT64.
- [ ] `rt64_renderer.cpp` has a `__SWITCH__` presentation branch.
- [ ] Dock/undock resize does not crash or leak.
- [ ] First rendered DKR-R menu appears on device.

## Implementation notes

Do the Vulkan probe before wiring RT64: it isolates driver problems from RT64
feature requirements. The plan's risk list names compute shaders, storage
buffers, and float formats on GM20B as the unknowns.

`switch_rt64_window.cpp` replaces `rt64_application_window.cpp` the same way
`android_rt64_window.cpp` does at `runtime-recomp/CMakeLists.txt:405-430`.
Get the native window via SDL2 WM info (VI_NN) or libnx directly, matching what
nxvk expects.

Any RT64/plume change goes through `patches/switch/` and `dkr_stage_patch`;
never edit `extern/rt64` in place.

## Relevant existing code

- `runtime-recomp/cmake/switch/FindNXVK.cmake`
- `runtime-recomp/cmake/switch/HostShaders.cmake`
- `runtime-recomp/src/game/rt64_renderer.*`
- `runtime-recomp/src/game/f3ddkr_rt64.*`
- `runtime-recomp/src/game/renderer_snapshot.*`
- `runtime-recomp/src/android/android_rt64_window.cpp` — window swap precedent.
- `scripts/Build-NXVK.ps1`
- `docs/GRAPHICS.md`, `docs/F3DDKR.md`

## Switch-specific risks

- nxvk maturity: the driver requires
  `NVK_I_WANT_A_BROKEN_VULKAN_DRIVER=1` (already set in `switch_main.cpp`).
- Maxwell GM20B feature gaps may force RT64 fallbacks.
- Applet heap and surface memory pressure at 1080p.
- GPL-2.0+ nxvk static linking has licensing consequences (SW-015).

## Validation

```powershell
powershell -ExecutionPolicy Bypass -File scripts/Build-NXVK.ps1
Test-Path C:\devkitPro\portlibs\switch\lib\pkgconfig\nxvk.pc
cmake --preset switch --fresh
cmake --build build/switch
```

Device check: probe frame, then first game menu, dock/undock.

## Open questions

- Which RT64 backend path does nxvk support best: Vulkan via plume/volk shim,
  or a direct ICD entry point?
- Is a compute-shader fallback needed, or can RT64 run without it?
- Target resolution/upscale defaults for handheld and docked?

## Changelog

| Date | Change |
|---|---|
| 2026-11-03 | Created; documents the nxvk portlib gap and the probe-first plan. |
