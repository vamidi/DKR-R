# Switch port — milestone session briefs

One milestone per session. Do not start a milestone before its predecessor is
`DONE` with recorded evidence. Do not work two milestones in the same checkout at
the same time.

This file supersedes the older sequencing notes in `handover/README.md` and the
pre-fold instructions in `handover/issues/*` where they disagree. The per-area
issues are still the detailed checklists; this file is the session boundary.

Reference material (read-only, outside this repository):

- `D:\Personal\C++\DK64Recomp-NX` — a shipped Switch port of a Rainchus-lineage
  N64 recompilation with a different renderer. Read its `switch/` layer for
  platform behaviour, not for game or renderer code. It is GPL-3.0; do not copy
  code into this repo without deciding the licence deliberately.

Ground rules for every session:

- Work on `switch-port`. Keep every Switch behaviour behind `DKR_SWITCH`.
- Never edit `extern/` in place. Third-party fixes are `patches/<dep>/*.patch`
  with a `patches/manifest.json` entry; first-party changes go in source.
- No ROM, extracted asset, save, or secret in the repo or a package.
- Record evidence (command, path, log, error), not "works".
- Run `python scripts/check.py --suite guard` before reporting a milestone
  finished. Add `--suite guard,tooling` after touching scripts or CMake.
- Device-only criteria are only checked after an on-device observation.

---

## M0 — Scaffold and toolchain

**Goal:** the hello `.nro` builds and boots, and the host prepare pipeline has
produced the payloads M1 needs.

Tasks:

1. Fix `switch/src/hello.c` for libnx 4.x: `consoleInit(NULL)`, a `PadState`
   with `padInitializeDefault` / `padUpdate` / `padGetButtonsDown`,
   `HidNpadButton_Plus` / `HidNpadButton_Minus`, `svcSleepThread`.
2. Build and boot it on hardware (Homebrew Menu in title mode, not Album).
3. Run the prepare pipeline for v77, v80 and the RSP. Record the exact output
   directories and pass them as `DKR_GENERATED_SOURCE_V77` /
   `DKR_GENERATED_SOURCE_V80`; do not guess a path.
4. Confirm `cmake --preset switch-scaffold --fresh` stays green.

Exit criteria:

- [ ] `DKRSwitchHello` builds and the `.nro` boots on device.
- [ ] Generated payload directories exist and are recorded here.
- [ ] Guard suite passes.

Do not start M1 from this session.

---

## M1 — Runtime link without a GPU

**Goal:** `DKRPortGame` links for aarch64 and reaches the game with the null
renderer, SDL2 audio/input, and a save file. No Vulkan.

Read first: `switch/patches/n64modernruntime.patch` and the shims in
`D:\Personal\C++\DK64Recomp-NX\switch\`. Expect to need equivalents of:

- 64 MB address-space reservation instead of 512 GB / 4 GB (Horizon commits
  memory eagerly). Without this the runtime will not start.
- Thread shims: 1 MiB stacks via `--wrap=pthread_create`, `pthread_detach`
  no-op, core placement (main + SDL audio on 0, game/VI/timer/RSP on 1,
  graphics on 2), ultramodern priority mapping.
- `mmap`/`munmap`/`mprotect`/`getpagesize` over `aligned_alloc`.
- Save rotation with remove/rename: `std::filesystem::copy_file` ends in
  `fchmod`, which the SD driver rejects.
- `quick_exit` → `_Exit`; reset the mod context before `_exit`.
- `__SWITCH__` in the concurrentqueue semaphore path and `WindowHandle`.
- Decide mods now: either gate `LiveRecomp` out of the link, or add the libnx
  `Jit` + sljit configuration it needs.

Build decisions:

- SDL2 must be built for Switch without OpenGL/EGL (or the unused EGL entry
  points stubbed). The devkitPro SDL2 portlib hardcodes `-lEGL -lglapi
  -ldrm_nouveau` for switch-mesa, which must not be mixed with NXVK.
- Entry point: `#elif defined(__SWITCH__)` in `game_main.cpp`; `switch_main.cpp`
  owns applet type and environment.
- ROM and saves come from `sdmc:/switch/DKR-R/`; there is no launcher without
  RT64 (the launcher is only compiled with `DKR_RUNTIME_BUILD_RT64`), so use a
  fixed ROM path and say so in the session report.

Exit criteria:

- [ ] `cmake --preset switch` configures with `DKR_RUNTIME_BUILD_RT64=OFF`.
- [ ] `DKRPortGame` links for aarch64 with no Vulkan symbols.
- [ ] Device boots to the game from an SD ROM path.
- [ ] Audio, controller input, EEPROM save/reload and ROM import verified on
      device.
- [ ] Guard suite passes.

Do not start M2 from this session.

---

## M2 — NXVK and RT64

**Goal:** RT64 renders Diddy Kong Racing on the console through NXVK.

Tasks, in order:

1. Build NXVK (`scripts/Build-NXVK.ps1`), confirm `nxvk.pc` and the archives,
   then run NXVK's own smoke ladder on device: `nvk_tri`, `nvk_scene`,
   `nvk_multi`, `nvk_textures`, `nvk_cubemap`, `nvk_vi_swapchain`, plus
   `nvk_zcull` and `nvk_desc_flush`. Record the tally.
2. Patch plume through the patch pipeline: `volkInitializeCustom(
   vk_icdGetInstanceProcAddr)` instead of `volkInitialize`; add
   `VK_NN_VI_SURFACE_EXTENSION_NAME`; `RenderWindow` = `NWindow*`; surface via
   `vkCreateViSurfaceNN`; `nwindowGetDimensions` for extent.
3. Presentation format `R8G8B8A8_UNORM` for the swapchain and the final VI
   pipeline (the Android RGBA patch is the precedent). Port the generic half of
   `patches/android/vulkan-surface-capabilities.patch`: `maxImageCount == 0`
   means unbounded, alpha fallback, required usage flags.
4. Add a persisted `VkPipelineCache` so NAK shader compilation does not hitch on
   every start.
5. `switch_rt64_window.cpp` replaces `rt64_application_window.cpp` (Android
   pattern). The native window is `nwindowGetDefault()`; SDL has no Switch WM
   info.
6. First frame at 640x480, then 720p. Dock/undock must not crash or leak.

Exit criteria:

- [ ] NXVK ladder passes on device (list any failure, do not hide it).
- [ ] `nxvk::nxvk` links and the RT64 renderer presents.
- [ ] A DKR menu and a race render on device.
- [ ] Guard suite passes.

Do not start M3 from this session.

---

## M3 — Playable build

**Goal:** both US revisions play offline with a usable launcher and stable
performance.

Scope:

- Launcher and import UX. The launcher is SDL_Renderer + ImGui; use the software
  renderer unless measurement says otherwise. `runtime_ui.cpp` is only compiled
  with RT64 today — decouple it or add it explicitly for Switch. ROM import is
  NFD-based; either write an NFD backend over `sdmc:` or scan a fixed folder.
- Controller mapping for Joy-Con and Pro Controller; decide SDL2 gamecontroller
  vs a libnx `pad` backend.
- Memory: texture-cache ceilings modelled on Android; applet heap; verify
  title-mode launch.
- Performance: appm performance configuration, core placement, resolution
  presets (handheld 720p, docked 1080p, lower internal for heavy scenes).
- Lifecycle: background/resume, dock/undock, clean exit back to the Homebrew
  Menu.

Exit criteria:

- [ ] Both revisions playable on device.
- [ ] Launcher, import and saves work without host helpers.
- [ ] Docked and handheld presets documented and tested.
- [ ] Guard suite passes.

---

## M4 — Packaging, docs, licensing, CI

Scope:

- `scripts/Package-Switch.ps1`: RomFS, NACP from `VERSION`, shader/pipeline
  cache if shipped, notices, `dkr-release.json`.
- `docs/SWITCH.md`: build, deploy, device checklist, NXVK usage, clock profiles.
- `THIRD_PARTY.md`: NXVK new files are GPL-2.0-or-later; the combined `.nro` is
  GPL-3.0 (the runtime already links GPL-3.0 N64ModernRuntime). State the source
  availability obligation.
- Nightly CI host-compile check following the existing workflow pattern.

Exit criteria:

- [ ] Reproducible `DKR-R-<version>-Switch.nro` with notices.
- [ ] Docs and device checklist land.
- [ ] CI check is green.

---

## M5 — Rider

Scope: toolchain profile, `compile_commands.json` from the preset, a deploy run
configuration using `dkr-switch-deploy`, and documentation. No product changes.

Exit criteria:

- [ ] Configure, build and deploy the `.nro` from Rider.
- [ ] Host-only presets are not attempted.

---

## M6 — Stretch, deferred

Netplay, legacy mods without a subprocess, gyro. Separate plans after M0-M5 are
signed off. Do not start any of these inside a phase-1 session.
