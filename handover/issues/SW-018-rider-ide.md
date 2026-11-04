# SW-018 — JetBrains Rider readiness

| Field | Value |
|---|---|
| Status | Not started |
| Milestone | M5 |
| Area | `area/ide` |
| Depends on | SW-001, SW-014 |
| Blocks | — |
| Owner | unassigned |
| Branch | `switch-port` |

## Goal

Make `switch/` first-class in JetBrains Rider: presets discoverable, code
navigation working through the compile database, and build-and-deploy from a
Run Configuration.

## Context

`switch/CMakePresets.json` already sets `CMAKE_EXPORT_COMPILE_COMMANDS=ON`, and
`switch/CMakeLists.txt` defines a `dkr-switch-deploy` target. There is no Rider
toolchain profile or documentation, and the host-only presets must not be
attempted for the Switch target.

## Scope

- In scope: Rider CMake profile, toolchain binding, preset visibility,
  compile-database navigation, deploy run configuration, cache regeneration,
  and `docs/SWITCH.md` instructions.
- Out of scope: CLion/VS Code support.

## Acceptance criteria

- [ ] Rider lists the `switch-scaffold` and `switch` presets.
- [ ] Configure and build work from the IDE with the devkitA64 profile.
- [ ] Code navigation/completion works over Switch sources.
- [ ] `dkr-switch-deploy` can be run as a build-and-deploy configuration.
- [ ] Host-only presets are not attempted for the Switch profile.
- [ ] The CMake cache regenerates cleanly after a toolchain change.
- [ ] Setup steps are documented.

## Implementation notes

The toolchain file requires `DEVKITPRO` and resolves host tools (ninja, git,
python) before switching to target-only search. Make sure Rider's environment
inherits `DEVKITPRO`/`DEVKITA64`.

If Rider's CMake integration cannot run the devkitPro pkg-config wrapper, the
Find modules already avoid it; confirm no preset forces pkg-config execution.

## Relevant existing code

- `switch/CMakePresets.json`
- `switch/cmake/SwitchToolchain.cmake`
- `switch/CMakeLists.txt` (`dkr-switch-deploy`)
- `switch/cmake/deploy-nro.cmake`

## Switch-specific risks

- Rider may not support a custom `CMAKE_SYSTEM_NAME NintendoSwitch`.
- Compile commands can point at a staging directory Rider cannot index.
- Deploy needs a reachable console IP and sys-ftpd.

## Validation

Open the repo in Rider on a clean machine, configure/build/deploy the scaffold
from the IDE, and navigate into `runtime-recomp/src/game`.

## Open questions

- Is Rider the primary IDE for this port, or a secondary option?
- Should deploy use FTP (current target) or nxlink?

## Changelog

| Date | Change |
|---|---|
| 2026-11-03 | Created. |
