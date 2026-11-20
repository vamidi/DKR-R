# DKR-R → Nintendo Switch Port — Project State

Living status ledger for porting the recompiled Diddy Kong Racing runtime to
Nintendo Switch with devkitPro / devkitA64 + libnx.

This file is the at-a-glance state. The authoritative approved plan is:

- `C:\Users\Valencio Hoffman\.plannotator\plans\dkr-r-nintendo-switch-port-dev-2026-10-17-approved.md`

The older execution ledger at
`.superpowers/sdd/dkr-r-nintendo-switch-port-dev-2026-10-17-approved/progress.md`
is superseded by this file. Update this file, not that one.

The milestone plan, per-area work and session boundaries all live in this file
(see [Milestones](#milestones)). One milestone is worked per session; do not
start a milestone before its predecessor has recorded evidence.

## Snapshot

| Field | Value |
|---|---|
| Last verified | 2026-11-20 |
| Repository | `D:\Personal\C++\dkr-n64recomp` |
| Branch | `switch-port` (rebased on `main` after the post-fold `upstream/main` merge, `8c742a0`) |
| Project version | `1.0.15` (`VERSION`) |
| Target | Nintendo Switch homebrew, installable `DKR-R.nro` |
| Toolchain | devkitA64 r30-1 / GCC 16.1.0 / libnx 4.12.0 / switch-tools 1.13.1 |
| Build host | Windows + Ninja; WSL2/Ubuntu for the existing prepare pipeline |
| Current milestone | **M0 — Scaffolding (in progress)** |
| Phase 1 verdict | Not playable; no game `.nro` built yet |

### Post-fold rebase (2026-11-20)

The branch now sits on the completed fold instead of the v1.0.7 beta 2 tree.

- `main` merged `upstream/main` (`53a78c3`, v1.0.15); `switch-port` was rebased
  onto that merge (`8c742a0`). One conflict, in
  `runtime-recomp/CMakeLists.txt`: the fold's `PreparedInputs.cmake` /
  `BuildInputs.cmake` includes and formatting were kept, and the
  `if(DKR_SWITCH) include(cmake/SwitchPlatform.cmake)` branch was re-added.
- `cmake --preset switch-scaffold --fresh` configures green against the folded
  tree (`build/switch-scaffold`, 2026-11-20). The cache still records
  `DKR_SWITCH=ON`, `DKR_SWITCH_HAS_EXCEPTIONS=1`, `DKR_SWITCH_HAS_RTTI=1`, and
  the `DKRSwitchHello` target is generated.
- `DKRSwitchHello` still fails to compile with the same five libnx 4.x API
  errors recorded under M0. The rebase did not change that debt.
- The fold replaced the first-party patch layers with source and left
  `architecture/pattern-guard-baseline.txt` empty. The old per-area issue pack
  was removed with `handover/`; this file is now the only sequencing source.
  RT64, plume and nxvk remain third-party pins; first-party Switch code belongs
  in `switch/` and `runtime-recomp/src/switch/`.

Status legend: `DONE` = exit criteria met and evidence recorded ·
`IN PROGRESS` = work landed, criteria not met · `BLOCKED` = waiting on a
dependency/decision · `NOT STARTED` · `DEFERRED` = out of phase 1.

## Status at a glance

| Milestone | Status | One-line state |
|---|---|---|
| M0 — Scaffolding | **IN PROGRESS** | `switch-scaffold` configures green; hello `.nro` fails to compile; device boot unverified |
| M1 — CPU bring-up (no GPU) | **NOT STARTED** | No generated payloads, no `DKRPortGame` Switch branch, no platform glue |
| M2 — Renderer (RT64 + nxvk) | **NOT STARTED** | nxvk checkout present but not built/installed; no Switch window source |
| M3 — Gameplay qualification | **NOT STARTED** | Depends on M1/M2 |
| M4 — Packaging + docs | **NOT STARTED** | No `docs/SWITCH.md`, no `Package-Switch.ps1` |
| M5 — Rider readiness | **NOT STARTED** | `compile_commands.json` + deploy target exist; Rider profile/docs absent |
| M6 — Stretch (netplay, legacy mods, gyro) | **DEFERRED** | Separate plans after phase 1 |

## Phase 1 scope

### Goals

- New `switch/` CMake wrapper over `runtime-recomp/CMakeLists.txt`, configured
  with the devkitA64 toolchain, producing an installable `DKR-R.nro`.
- Offline single-player first: launcher, both US ROM revisions, rendering,
  audio, controller input, persistent saves.
- Renderer: RT64 Vulkan backend through the **nxvk** portlib (Mesa NVK for
  Tegra X1). RT64 HLSL shaders precompiled on the host and shipped in RomFS.
- All RT64 adjustments go through the project's `dkr_stage_patch` pipeline
  under `patches/switch/`; never hand-edit pinned `extern/` dependencies.

### Non-goals / gated off in phase 1

- Quick Join / WebRTC netplay (`libdatachannel`, `libjuice`, `usrsctp`).
- Legacy mod subprocess worker (homebrew has no subprocess model; iOS precedent).
- Experimental Rollback and the qualification executables.
- Automatic updater (stubbed to a clear "not supported on Switch" error).
- Gyro, Android-style mobile UI.

### Definition of done (phase 1)

- `cmake --preset switch` + build produces
  `build/switch/.../DKR-R.nro` with zero edits to `extern/`.
- Desktop presets and existing platform builds are unaffected (all Switch
  behavior behind `DKR_SWITCH`).
- On device: boots to launcher, imports both US revisions, plays offline with
  audio + controller + persistent saves.
- Netplay/mod/rollback features report unsupported instead of crashing.
- The `switch/` project opens in JetBrains Rider, configures/builds with the
  devkitA64 profile, and can build-and-deploy a `.nro`.

## Verified environment (2026-11-03)

From `dkp-pacman -Q` and tool invocations on this machine:

| Component | Version |
|---|---|
| devkitA64 | r30-1 |
| devkitA64 GCC | 16.1.0-1 |
| devkitA64 newlib | 4.6.0.20260123-4 |
| libnx | 4.12.0-1 |
| switch-tools | 1.13.1-1 |
| switch-cmake | 1.5.2-1 |
| switch-sdl2 | 2.0.14-1 |
| switch-libzstd | 1.5.7-1 |
| switch-mbedtls | 2.28.10-1 |
| switch-zlib | 1.2.11-3 |
| switch-libexpat | 2.2.5-3 |
| CMake | 4.4.3 |
| Ninja | 1.13.2 |
| Docker | Required only for `scripts/Build-NXVK.ps1` |

Environment variables: `DEVKITPRO=C:\devkitPro`, `DEVKITA64=C:\devkitPro\devkitA64`.

Not yet satisfied:

- `C:\devkitPro\portlibs\switch\lib\pkgconfig\nxvk.pc` is **absent** — nxvk has
  not been built/installed by `scripts/Build-NXVK.ps1`.
- `runtime-recomp/RecompiledFuncs` is **absent** — generated CPU/RSP payloads
  have not been produced for this checkout.
- No on-device validation has been performed from this host.

## Dependency triage

| Dependency | Switch plan | Current state |
|---|---|---|
| monocypher, gekkonet, hlslpp | Compile as-is | Present in `extern/` |
| zstd | `switch-libzstd` portlib | Installed |
| mbedtls | portlib or vendored static | Installed (2.28.10) |
| SDL2 | devkitPro portlib, in-process input/audio | Installed (2.0.14) |
| RT64 + plume | Vulkan backend; host-side shader precompile | `extern/rt64` present; not wired for Switch |
| nxvk (new) | Pinned `c3abea1efde44027b7e3e20b48eb55beeecd5ab4`; static portlib | Lock entry added (uncommitted); checkout present; **not built** |
| libdatachannel / libjuice / usrsctp | Gated OFF phase 1 | Present but unused |
| nativefiledialog-extended | Not available; use SD-card path + existing import flow | Android precedent exists |
| dkr-decomp, N64Recomp | Host-side only | Present; generation pipeline unchanged |
| sljit (RSP JIT) | aarch64 supported; keep interpreter fallback | Present; unverified on Switch |

## Architecture

### New Switch-owned files (already scaffolded)

```
switch/
  CMakeLists.txt                 # project(DKRSwitch), hello target, add_subdirectory(../runtime-recomp)
  CMakePresets.json              # switch-base, switch-scaffold, switch
  cmake/SwitchToolchain.cmake    # devkitA64 + switch.specs; exceptions/RTTI preserved
  cmake/deploy-nro.cmake         # FTP push to a console (sys-ftpd :5000)
  cmake/make-nacp.cmake          # NACP from nro/app.nacp.template
  nro/app.nacp.template          # display title/author/version
  src/hello.c                    # toolchain verification artifact
runtime-recomp/
  cmake/SwitchPlatform.cmake     # forced option gates, module path, dxc host shader hook
  cmake/switch/FindSDL2.cmake    # reads portlibs directly (Windows pkg-config wrapper issue)
  cmake/switch/FindNXVK.cmake    # parses nxvk.pc; imported nxvk::nxvk target
  cmake/switch/HostShaders.cmake # host dxc path for HLSL → SPIR-V
  src/switch/switch_main.cpp     # __nx_applet_type=Application; NVK env acknowledgement
  src/switch/switch_update_http.cpp # updater stub (unsupported on Switch)
scripts/Build-NXVK.ps1           # Docker cross-build + portlib install
```

### Still missing (from the approved plan)

```
runtime-recomp/src/switch/switch_platform.cpp/.hpp   # diagnostics, memory trim, build identity
runtime-recomp/src/switch/switch_rt64_window.cpp     # replacement for rt64_application_window.cpp
runtime-recomp/src/switch/switch_compat.c            # newlib gaps
patches/switch/*.patch                               # staged RT64/plume adjustments
Build-Switch.ps1                                     # prepare → configure → build → elf2nro
scripts/Package-Switch.ps1                           # RomFS staging + naming
docs/SWITCH.md                                       # build + device validation guide
```

### Existing-project edits still required

`runtime-recomp/CMakeLists.txt` currently has only two Switch branches:

1. `if(IOS OR DKR_SWITCH)` → force `BUILD_TESTING=OFF` (line 60).
2. `if(DKR_SWITCH)` → include `cmake/SwitchPlatform.cmake` (line 126).

Still needed (mirroring the Android/iOS branches):

- Force `DKR_RUNTIME_BUILD_SDL3_INPUT_HOST=OFF`.
- Gate `DKR_NETPLAY_WEBRTC`, `DKRLegacyModWorker`, `DKR_EXPERIMENTAL_RACE_TEST`,
  and qualification executables OFF on Switch.
- `DKRPortGame` branch: add `src/switch/` sources, link `SDL2::SDL2`, `nxvk`,
  libnx; swap `rt64_application_window.cpp` → `switch_rt64_window.cpp`
  (Android pattern is at lines 405–430).
- `game_main.cpp`: `#elif defined(__SWITCH__)` entry branch.
- `rt64_renderer.cpp`: `__SWITCH__` native-window branch from SDL2 WM info
  (mirror the `__ANDROID__` branch).
- Keep `DKR_RUNTIME_BUILD_RT64=ON` with the Vulkan renderer path.

## Milestones

### Session protocol

One milestone per session. The sessions share one checkout, so run one at a
time. Do not start a milestone until its predecessor is `DONE` with recorded
evidence.

Every session:

- works on `switch-port` and keeps Switch behaviour behind `DKR_SWITCH`;
- never edits `extern/` in place (third-party fixes are `patches/<dep>/` plus a
  `patches/manifest.json` entry; first-party changes go in source);
- records evidence (command, path, log, error), never "works";
- runs `python scripts/check.py --suite guard` before reporting done, and
  `--suite guard,tooling` after touching scripts or CMake;
- ticks a device-only criterion only after an on-device observation.

Reference material, read-only and outside this repository:
`D:\Personal\C++\DK64Recomp-NX` — a shipped Switch port of a Rainchus-lineage
N64 recompilation with a different renderer. Read its `switch/` layer for
platform behaviour, not for game or renderer code. It is GPL-3.0; do not copy
code from it without deciding the licence deliberately.

### M0 — Scaffolding — IN PROGRESS

**Goal:** `switch/` configures under the devkitA64 toolchain; a hello `.nro`
boots on device; the existing host prepare pipeline still runs unchanged.

**Exit criteria:**

- [ ] `switch-scaffold` configure succeeds and both exceptions/RTTI checks pass.
- [ ] `DKRSwitchHello` builds and produces `dkr-switch-hello.nro`.
- [ ] The `.nro` boots on a homebrew-capable Switch and prints the banner.
- [ ] Host prepare produces ELF + N64Recomp payloads for v77/v80 + RSP.
- [ ] Scaffolding is committed on `switch-port` (or intentionally parked).

**Verified evidence:**

- `switch-scaffold` configure is green: `build/switch-scaffold/CMakeCache.txt`
  records `DKR_SWITCH:BOOL=ON`, `DKR_SWITCH_HAS_EXCEPTIONS=1`,
  `DKR_SWITCH_HAS_RTTI=1`.
- `DKRSwitchHello` target exists in `build/switch-scaffold/build.ninja`.
- The hello build **fails** against libnx 4.12.0. Errors in
  `switch/src/hello.c`:
  - `consoleInit(nwindowGetDefault())` — wrong argument type; current API is
    `consoleInit(PrintConsole*)` (`consoleInit(NULL)` for the default console).
  - `pad` is undeclared — needs a `PadState` plus `padInitializeDefault(&pad)`.
  - `PadStateDown` is not a thing — use `padGetButtonsDown(&pad)`.
  - `padGetButtons(&pad, PadStateDown)` — wrong arity; current signature is
    `padGetButtons(const PadState*)`.
  - `PadButton_Plus` / `PadButton_Minus` — current names are
    `HidNpadButton_Plus` / `HidNpadButton_Minus`.
  - `napms` is not declared — use `svcSleepThread(...)` or `nanosleep`.
- No `.nro` exists under `build/switch-scaffold/`.
- On-device boot: **not performed**.
- `runtime-recomp/RecompiledFuncs` is absent, so the host prepare step has not
  produced payloads for this checkout.

**Remaining work (ordered):**

1. Port `switch/src/hello.c` to the libnx 4.12 API and rebuild.
2. Copy the resulting `.nro` to the SD card and boot it from the Homebrew Menu
   in title mode (Album/applet mode lacks the memory budget).
3. Run the host prepare pipeline with the existing workflow for both US
   revisions and the RSP, and record the exact output paths.
4. Decide whether to commit the scaffolding before starting M1.

**Notes / rulings from the prior run:**

- `switch_compat.c` is deferred until the link actually reports missing newlib
  symbols (newlib 4.6 likely already provides `getrandom`, `posix_memalign`,
  `sysconf`).
- `FindSDL2` / `FindNXVK` parse `.pc` files directly because devkitPro's
  `aarch64-none-elf-pkg-config` is a bash wrapper on Windows and cannot be
  executed by CMake.
- Platform sources live under `runtime-recomp/src/switch/` (not `switch/src/`)
  to mirror `src/android/` and keep the `DKRPortGame` source list local.
- nxvk is GPL-2.0-or-later + Mesa licenses; static linking makes the combined
  `.nro` GPL-encumbered for recipients. `docs/SWITCH.md` and `THIRD_PARTY.md`
  must carry the notice (M4).

### M1 — Runtime link without a GPU — NOT STARTED

**Goal:** `DKRPortGame` links for aarch64 and reaches the game with the null
renderer, SDL2 audio/input, and a save file. No Vulkan.

**Platform prerequisites** (from the reference port; expect to need each):

- 64 MB address-space reservation instead of 512 GB / 4 GB in
  `librecomp/include/librecomp/addresses.hpp`; Horizon commits memory eagerly.
- Thread shims: 1 MiB stacks via `-Wl,--wrap=pthread_create`, `pthread_detach`
  no-op, core placement (main + SDL audio on 0, game/VI/timer/RSP on 1,
  graphics on 2), ultramodern priority mapping.
- `mmap`/`munmap`/`mprotect`/`getpagesize` over `aligned_alloc`.
- Save rotation with remove/rename; `std::filesystem::copy_file` ends in
  `fchmod`, which the SD driver rejects.
- `quick_exit` → `_Exit`; reset the mod context before `_exit`.
- `__SWITCH__` in the concurrentqueue semaphore path and `WindowHandle`.
- Decide mods: gate `LiveRecomp` out of the link, or add the libnx `Jit` and
  sljit configuration it needs. The RSP is statically recompiled; sljit is only
  for mods.
- SDL2 built for Switch without OpenGL/EGL (or unused EGL entry points stubbed).
  devkitPro's SDL2 portlib hardcodes `-lEGL -lglapi -ldrm_nouveau` for
  switch-mesa and must not be mixed with nxvk.
- No launcher without RT64: `runtime_ui.cpp` is only in the
  `DKR_RUNTIME_BUILD_RT64` source list and `game_main.cpp` gates
  `run_startup_screen`. Use a fixed ROM path under `sdmc:/switch/DKR-R/`.

**Exit criteria:**

- [ ] `cmake --preset switch` configures with `DKR_RUNTIME_BUILD_RT64=OFF`.
- [ ] `DKRPortGame` links for aarch64 with no Vulkan symbols.
- [ ] `__SWITCH__` entry branch in `game_main.cpp`.
- [ ] Save directory under the app's savedata/SD path, with rotation.
- [ ] Device checklist recorded: ROM load, EEPROM save/reload, audio,
  controller mapping.
- [ ] Guard suite passes.

**Current state:** not started. Evidence:

- `cmake --preset switch` fails immediately at
  `runtime-recomp/CMakeLists.txt` because `DKR_GENERATED_SOURCE_V80` is empty
  (`DKR_GENERATED_SOURCE_V77` defaults to `runtime-recomp/RecompiledFuncs`,
  which does not exist).
- The runtime `DKRPortGame` target has no `DKR_SWITCH` source/link branch yet.
- `switch_platform.cpp`, `switch_compat.c` do not exist.
- No save-path or input adaptation exists.

### M2 — Renderer (RT64 Vulkan over nxvk) — NOT STARTED

**Goal:** RT64 Vulkan presents through nxvk. Shaders are not compiled on
device: host `dxc` embeds SPIR-V at build time and `re-spirv` specialises it on
the CPU at runtime. First rendered menu and race.

**Tasks, in order:**

- Build NXVK (`scripts/Build-NXVK.ps1`) and run its own smoke ladder on device:
  `nvk_tri`, `nvk_scene`, `nvk_multi`, `nvk_textures`, `nvk_cubemap`,
  `nvk_vi_swapchain`, plus `nvk_zcull` and `nvk_desc_flush`.
- Patch plume: `volkInitializeCustom(vk_icdGetInstanceProcAddr)` instead of
  `volkInitialize`; `VK_NN_VI_SURFACE_EXTENSION_NAME`; `RenderWindow` =
  `NWindow*`; surface via `vkCreateViSurfaceNN`; `nwindowGetDimensions`.
- Presentation format `R8G8B8A8_UNORM` for the swapchain and the final VI
  pipeline (the Android RGBA patch is the precedent). Port the generic half of
  `patches/android/vulkan-surface-capabilities.patch`: `maxImageCount == 0` is
  unbounded, alpha fallback, required usage flags.
- Persist a `VkPipelineCache` so NAK compilation does not hitch on every start.
- `switch_rt64_window.cpp` replaces `rt64_application_window.cpp` (Android
  pattern). The native window is `nwindowGetDefault()`; SDL has no Switch WM
  info.
- First frame at 640x480, then 720p. Dock/undock must not crash or leak.

**Exit criteria:**

- [ ] `scripts/Build-NXVK.ps1` installs `nxvk.pc` + archives.
- [ ] NXVK ladder passes on device (list failures, do not hide them).
- [ ] `FindNXVK.cmake` links `nxvk::nxvk`.
- [ ] A DKR menu and a race render on device.
- [ ] Dock/undock is stable.
- [ ] Guard suite passes.

**Current state:** scaffolding only.

- `FindNXVK.cmake` and `HostShaders.cmake` exist.
- `extern/nxvk` is checked out at `c3abea1efde` (VERSION `26.2.2`).
- `nxvk.pc` is not installed, so the full `switch` preset would fail at the
  nxvk lookup after the generated-source gate is fixed.
- No `switch_rt64_window.cpp`, no plume Switch patches.

### M3 — Gameplay qualification — NOT STARTED

**Goal:** Both revisions playable; launcher↔game flow; widescreen/HUD/graphics
presets; Joy-Con/Pro Controller mapping; memory ceilings; cortex-a57 perf pass.

**Exit criteria:**

- [ ] Both US revisions reach gameplay.
- [ ] Launcher and game flow work without host-only helpers.
- [ ] Controller mapping is complete and documented.
- [ ] Texture-cache/memory-pressure trim modeled on Android.
- [ ] Docked/handheld resolution presets documented and tested.
- [ ] Perf pass: applet heap sizing, optional clock boost, track benchmarks.

**Current state:** not started; depends on M1 + M2.

**Tasks:**

- Launcher and import UX. The launcher is SDL_Renderer + ImGui; use the software
  renderer unless measurement says otherwise. `runtime_ui.cpp` is only compiled
  with RT64 today — decouple it or add it explicitly for Switch. ROM import is
  NFD-based; write an NFD backend over `sdmc:` or scan a fixed folder.
- Controller mapping for Joy-Con and Pro Controller; decide SDL2
  gamecontroller vs a libnx `pad` backend.
- Memory: texture-cache ceilings modelled on Android, applet heap, title-mode
  launch.
- Performance: apm performance configuration, core placement, resolution
  presets (handheld 720p, docked 1080p, lower internal for heavy scenes).
- Lifecycle: background/resume, dock/undock, clean exit to the Homebrew Menu.

### M4 — Packaging + docs — NOT STARTED

**Goal:** Reproducible package + documentation + CI host-compile check.

**Exit criteria:**

- [ ] `scripts/Package-Switch.ps1` produces
      `DKR-R-<version>-Switch.nro` with RomFS (shader cache, notices,
      `dkr-release.json`).
- [ ] NACP version derives from `VERSION`.
- [ ] `docs/SWITCH.md` covers build, deploy, device validation, nxvk licensing.
- [ ] Device acceptance checklist appended in the style of
      `RELEASE-VALIDATION.md`.
- [ ] Nightly CI host-compile check follows the existing workflow pattern.

**Licensing:** NXVK's new files are GPL-2.0-or-later; the combined `.nro` is
GPL-3.0 because the runtime already links GPL-3.0 N64ModernRuntime. State the
source-availability obligation in `docs/SWITCH.md` and `THIRD_PARTY.md`.

**Current state:** not started. `build/switch-scaffold/dkr-release.json` exists
as a scaffold artifact only; there is no packaging script or Switch doc.

### M5 — JetBrains Rider readiness — NOT STARTED

**Goal:** Make `switch/` first-class in Rider.

**Exit criteria:**

- [ ] `switch/CMakeLists.txt` + `CMakePresets.json` are discovered by Rider.
- [ ] A Rider toolchain profile points at `switch/cmake/SwitchToolchain.cmake`.
- [ ] `CMAKE_EXPORT_COMPILE_COMMANDS=ON` is set in the preset (already true in
      `switch-base`).
- [ ] `dkr-switch-deploy` custom target pushes the `.nro` over FTP/SMB (target
      exists; untested).
- [ ] Host-only presets are not attempted by the IDE.
- [ ] CMake cache regenerates cleanly after toolchain changes.
- [ ] Rider setup documented in `docs/SWITCH.md`.

**Current state:** partial. `compile_commands.json` is generated for the
scaffold, and `switch/CMakeLists.txt` defines `dkr-switch-deploy`; no Rider
profile or documentation exists.

### M6 — Stretch — DEFERRED

Separate plans after phase 1:

- Netplay feasibility spike (mbedtls + gekkonet local rollback first; Quick
  Join/WebRTC later).
- Legacy mod import without a subprocess.
- Gyro.

## Active blockers and findings

1. **Hello `.nro` does not compile** — `switch/src/hello.c` uses the pre-4.x
   libnx API. This is the only thing between M0 configure and M0 build.
2. **No generated CPU/RSP payloads** — `runtime-recomp/RecompiledFuncs` is
   missing; the full `switch` preset stops at
   `runtime-recomp/CMakeLists.txt:144`. The host prepare pipeline must run
   before M1 can configure.
3. **nxvk is not installed** — the checkout exists but no portlib. Full
   configure will next fail at `FindNXVK.cmake`'s `nxvk.pc` existence check.
4. **Switch game branch is not wired** — only `BUILD_TESTING` and the
   `SwitchPlatform.cmake` include are gated; `DKRPortGame` has no Switch
   sources or links.
5. **Work is uncommitted** — on `switch-port`, modified: `.gitignore`,
   `dependencies.lock.json`, `runtime-recomp/CMakeLists.txt`,
   `runtime-recomp/cmake/Updates.cmake`,
   `runtime-recomp/src/game/updates/update_http.cpp`,
   `runtime-recomp/src/game/updates/update_process.cpp`. Untracked: `switch/`,
   `runtime-recomp/cmake/SwitchPlatform.cmake`, `runtime-recomp/cmake/switch/`,
   `runtime-recomp/src/switch/`, `scripts/Build-NXVK.ps1`, `.opencode/`.
   (`.opencode/` and the `.gitignore` "Opencode" block are local tooling noise,
   not part of the port.)

## Immediate next actions

Ordered so each step produces evidence for the ledger.

1. **Fix the hello build (M0).**
   Rewrite `switch/src/hello.c` for libnx 4.12:
   `consoleInit(NULL)`, a `PadState` + `padInitializeDefault`, `padUpdate`,
   `padGetButtonsDown`, `HidNpadButton_Plus/Minus`, `svcSleepThread`.
   Verify: `cmake --build build/switch-scaffold --target DKRSwitchHello` →
   `build/switch-scaffold/bin/Release/dkr-switch-hello.nro`.
2. **Boot the hello `.nro` on hardware (M0).**
   Copy to `sd:/switch/`, launch, confirm banner + clean exit. Record console
   and firmware in this file.
3. **Run the host prepare pipeline (M0 → M1).**
   Use the existing `Prepare-DKR-Runtime` / `Prepare-Game-Source` workflow in
   WSL for both US revisions and the RSP. Record the generated directories and
   pass them as `DKR_GENERATED_SOURCE_V77` / `DKR_GENERATED_SOURCE_V80`.
4. **Build nxvk (M1/M2 prerequisite).**
   `scripts/Build-NXVK.ps1` (Docker); confirm
   `C:\devkitPro\portlibs\switch\lib\pkgconfig\nxvk.pc` and `libnvk*.a` exist.
5. **Wire the Switch build (M1).**
   Add the `DKR_SWITCH` branches to `runtime-recomp/CMakeLists.txt` for
   `DKRPortGame` sources/links and forced feature gates; add
   `switch_platform.cpp`, the `game_main.cpp` entry branch, and save paths.
6. **Renderer bring-up (M2).**
   Add `switch_rt64_window.cpp`, the `rt64_renderer.cpp` window branch, and the
   staged `patches/switch/` changes; package the host shader cache; run the
   Vulkan probe on device before full RT64.
7. **Qualify and package (M3 → M4).**
   Gameplay checklist, memory/perf pass, packaging script, `docs/SWITCH.md`,
   CI check.
8. **Rider pass (M5).**
   Toolchain profile, deploy run configuration, docs.

## Verification commands

```powershell
# Toolchain / scaffold (from repo root)
cmake --preset switch-scaffold --fresh          # run in switch/
cmake --build build/switch-scaffold --target DKRSwitchHello

# Full product configure (blocked until generated payloads + nxvk exist)
cmake --preset switch --fresh                   # run in switch/

# nxvk portlib
powershell -ExecutionPolicy Bypass -File scripts/Build-NXVK.ps1
Test-Path C:\devkitPro\portlibs\switch\lib\pkgconfig\nxvk.pc

# Deploy (once a .nro exists and sys-ftpd is running)
cmake --build build/switch --target dkr-switch-deploy
```

Note: presets use `binaryDir = ${sourceDir}/../build/${presetName}`, so run
CMake from the `switch/` directory (or pass `--preset` with the right source
dir).

## Risks and mitigations

| Risk | Mitigation |
|---|---|
| RT64 ↔ nxvk feature fit (compute, storage buffers, float formats on GM20B) | Probe target first; M1 before M2; fall back to reduced RT64 features if needed |
| No dxcompiler on aarch64 | Host dxc precompile into RT64 shader cache in RomFS; verify cache hits on device |
| Stock Switch CMake disables exceptions/RTTI | `SwitchToolchain.cmake` preserves them; `SwitchPlatform.cmake` asserts both at configure |
| newlib gaps | Add `switch_compat.c` only for symbols the link actually misses |
| Applet heap ~1.8 GB vs texture/upscaler budgets | Android-style memory-pressure ceilings; document docked/handheld presets |
| JIT executable memory (sljit RSP) | Homebrew allows it; keep interpreted RSP fallback selectable |
| GPL-2.0+ nxvk statically linked | SWITCH.md + THIRD_PARTY.md notices; treat combined `.nro` as GPL-encumbered |
| ROM/asset policy | No ROM or extracted Nintendo/Rare assets in the repo or package |
| Uncommitted scaffolding | Commit M0 on `switch-port` before M1 wiring grows |

## Ledger protocol

When updating this file:

1. Change `Last verified` and the affected milestone's status.
2. Record **evidence** (command, artifact path, error text), not just "done".
3. Keep exit criteria as checkboxes; tick only with evidence.
4. Add a row to the changelog below.
5. Never mark a device-only criterion done without an on-device observation.

## Changelog

| Date | Change |
|---|---|
| 2026-11-03 | Created this ledger. Verified environment, scaffold configure, hello build failure, missing generated payloads, missing nxvk portlib, uncommitted branch state. |
| 2026-11-03 | Added the `handover/` issue pack: 21 per-area issues (SW-001…SW-021) plus index and template. |
| 2026-11-20 | Rebased `switch-port` onto the post-fold `main` (v1.0.15, `8c742a0`). Re-verified scaffold configure, Switch markers and the unchanged hello failure. Recorded that the fold invalidated the old `patches/switch/` staging assumptions. |
| 2026-11-20 | Removed the `handover/` pack. The milestone session protocol and the corrected M1/M2 prerequisites now live only in this file. |
