# SW-003 — Core runtime CPU bring-up (no GPU)

| Field | Value |
|---|---|
| Status | Not started |
| Milestone | M1 |
| Area | `area/runtime` |
| Depends on | SW-001, SW-002 |
| Blocks | SW-004, SW-005, SW-006, SW-007, SW-008 |
| Owner | unassigned |
| Branch | `switch-port` |

## Goal

Cross-compile and run `DKRPortGame` on the Switch with generated payloads,
SDL2 audio/input, saves, and the null renderer — no Vulkan, no RT64. This proves
the CPU side of the port before graphics work starts.

## Context

`runtime-recomp/CMakeLists.txt` has only two Switch branches today
(`BUILD_TESTING` and the `SwitchPlatform.cmake` include). `DKRPortGame` has no
Switch sources or link rules. `switch_main.cpp` exists; `game_main.cpp` has no
`__SWITCH__` entry branch.

## Scope

- In scope: the first `DKRPortGame` Switch build, entry point, platform glue,
  feature gates, and a debug-console boot to the launcher.
- Out of scope: rendering (SW-008), UI polish (SW-010), performance (SW-011).

## Acceptance criteria

- [ ] `cmake --preset switch` configures with `DKR_RUNTIME_BUILD_RT64=OFF`.
- [ ] `DKRPortGame` links for aarch64 with no Vulkan symbols required.
- [ ] `game_main.cpp` has a `__SWITCH__` branch that reaches the launcher.
- [ ] `switch_platform.cpp` provides diagnostics, memory-pressure trim, and
      build identity (modeled on `android_platform.cpp`).
- [ ] `switch_compat.c` exists only if the link reports missing newlib symbols.
- [ ] Gameplay-affecting gates are forced OFF: netplay, legacy mod worker,
      experimental rollback, qualification executables.
- [ ] Device boots to the launcher over the debug console.

## Implementation notes

Mirror the Android/iOS branches:

- `runtime-recomp/CMakeLists.txt`: add `if(DKR_SWITCH)` around sources, link
  `SDL2::SDL2`, and swap `rt64_application_window.cpp` only when RT64 is on.
- `game_main.cpp`: `#elif defined(__SWITCH__)` entry.
- Replace the desktop SDL3 input worker with in-process SDL2 input
  (`DKR_RUNTIME_BUILD_SDL3_INPUT_HOST=OFF`).
- Keep `DKR_RUNTIME_BUILD_RT64` as an option so M1 and M2 can be tested
  independently.

Exceptions and RTTI are already asserted by `SwitchPlatform.cmake`; do not
re-enable `-fno-exceptions`/`-fno-rtti`.

## Relevant existing code

- `runtime-recomp/CMakeLists.txt` — platform branches, `DKRPortGame` target.
- `runtime-recomp/src/game/game_main.cpp` — entry point.
- `runtime-recomp/src/switch/switch_main.cpp` — libnx applet setup.
- `runtime-recomp/cmake/SwitchPlatform.cmake` — forced option gates.
- `runtime-recomp/src/android/android_platform.cpp` — platform glue precedent.
- `runtime-recomp/src/game/null_renderer.*` — no-GPU renderer.

## Switch-specific risks

- newlib gaps (`getrandom`, `posix_memalign`, `sysconf`, `regcomp`).
- `std::filesystem` and `std::jthread` behavior on devkitA64 newlib 4.6.
- Thread stacks and TLS model (`local-exec`) can surface as link/runtime errors.
- Homebrew has no subprocess model; the legacy mod worker must not be linked.

## Validation

```powershell
cmake --preset switch --fresh -DDKR_RUNTIME_BUILD_RT64=OFF
cmake --build build/switch
```

Device check: launcher appears on the debug console; no crash on startup.

## Open questions

- Should M1 use the null renderer or a minimal SDL2 software frame for
  navigation?
- Which launcher paths still depend on host-only helpers?

## Changelog

| Date | Change |
|---|---|
| 2026-11-03 | Created from the M1 gap analysis. |
