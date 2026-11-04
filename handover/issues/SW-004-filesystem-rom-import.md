# SW-004 — Filesystem, ROM import, and asset paths

| Field | Value |
|---|---|
| Status | Not started |
| Milestone | M1 |
| Area | `area/filesystem` |
| Depends on | SW-003 |
| Blocks | SW-005, SW-020 |
| Owner | unassigned |
| Branch | `switch-port` |

## Goal

Make ROM selection/import and all runtime asset paths work on Switch using SD
card and application savedata paths, with no native file dialog.

## Context

Desktop uses nativefiledialog-extended; Android uses a file/ZIP import flow.
Switch homebrew has no desktop dialog and no subprocess, so the port follows
the Android path: choose a ROM already on the SD card, validate the canonical
hash, and build the private byte-swapped cache.

## Scope

- In scope: path roots, ROM discovery/import, ZIP handling, private cache,
  logs, mod/texture-pack roots, and error messages.
- Out of scope: save persistence (SW-005), custom track/mod authoring.

## Acceptance criteria

- [ ] A ROM placed on the SD card is discoverable and importable from the
      launcher.
- [ ] Both US v1.0/v77 and Rev A/v1.1/v80 hashes are recognized.
- [ ] The private cache is created without modifying the original ROM.
- [ ] Logs, config, saves, and asset roots resolve to valid Switch paths.
- [ ] Missing/invalid ROM errors are actionable on the console.
- [ ] No dependency on nativefiledialog-extended remains in the Switch build.

## Implementation notes

Use libnx filesystem APIs through the SDL2/newlib layer where possible. Prefer
`sdmc:/switch/dkr-r/` for user-visible content and the application savedata
path for private state. Keep ZIP import in-process.

Enumerate hardcoded desktop paths and route them through a small
`switch_platform` path helper rather than scattering `#ifdef`s.

## Relevant existing code

- `runtime-recomp/src/game/rom_revision.*` — revision detection.
- `runtime-recomp/src/game/game_payload.*` — payload selection.
- `runtime-recomp/src/game/runtime_platform.*` — platform paths.
- `runtime-recomp/src/android/` — mobile import precedent.
- `docs/ROM_SETUP.md`, `docs/ASSET_POLICY.md`.

## Switch-specific risks

- FAT32/exFAT case sensitivity and long paths differ from Windows.
- `sdmc:` may be unavailable until the SD card is mounted; handle mount errors.
- Writing large caches under the applet heap/SD can be slow; show progress.
- The repo/package must never contain ROMs or extracted assets.

## Validation

Device check: import both revisions from SD, relaunch, confirm cache reuse.

## Open questions

- Is there an existing file-picker UI that can be reused for SD browsing, or is
  a simple path list enough for phase 1?
- Where should user-visible logs live so they can be retrieved without a PC?

## Changelog

| Date | Change |
|---|---|
| 2026-11-03 | Created. |
