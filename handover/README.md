# DKR-R Switch Port — Handover Issue Board

This folder is the handover pack for the Nintendo Switch port. Each file in
`issues/` is a self-contained work item that can be picked up by a developer,
pasted into GitHub Issues, or assigned in a tracker.

Authoritative context:

- `../n64_project_state.md` — current status, environment, and evidence.
- `C:\Users\Valencio Hoffman\.plannotator\plans\dkr-r-nintendo-switch-port-dev-2026-10-17-approved.md` — approved M0–M6 plan.

## How to use this pack

1. Read `../n64_project_state.md` for the current milestone and blockers.
2. Pick an issue whose dependencies are `DONE` (or explicitly waived).
3. Copy `TEMPLATE.md` if a new issue is needed.
4. Keep the issue's status table, acceptance checkboxes, and changelog current.
5. Update `../n64_project_state.md` when an issue closes a milestone criterion.

## Status board

| ID | Issue | Milestone | Status | Depends on |
|---|---|---|---|---|
| SW-001 | Build scaffolding and toolchain verification | M0 | **In progress** | — |
| SW-002 | Host prepare pipeline (ELF, v77/v80 CPU, RSP) | M0 | Not started | SW-001 |
| SW-003 | Core runtime CPU bring-up (no GPU) | M1 | Not started | SW-001, SW-002 |
| SW-004 | Filesystem, ROM import, and asset paths | M1 | Not started | SW-003 |
| SW-005 | Save persistence and EEPROM | M1 | Not started | SW-003, SW-004 |
| SW-006 | Audio output and mixing | M1 / M3 | Not started | SW-003 |
| SW-007 | Input and controller mapping | M1 / M3 | Not started | SW-003 |
| SW-008 | Graphics: RT64 over nxvk | M2 | Not started | SW-003, SW-001 |
| SW-009 | Shader precompile and RomFS cache | M2 | Not started | SW-008 |
| SW-010 | Launcher and in-game UI | M3 | Not started | SW-008 |
| SW-011 | Memory ceilings and performance | M3 | Not started | SW-003, SW-008 |
| SW-012 | Applet lifecycle, background, and resume | M3 | Not started | SW-003 |
| SW-013 | Update service on Switch | M4 | **Partial** (stub) | — |
| SW-014 | Packaging and distribution | M4 | Not started | SW-003, SW-008, SW-009 |
| SW-015 | Licensing and third-party notices | M4 | Not started | SW-008 |
| SW-016 | Docs and device validation | M4 | Not started | SW-014 |
| SW-017 | CI nightly host-compile check | M4 | Not started | SW-001, SW-003 |
| SW-018 | JetBrains Rider readiness | M5 | Not started | SW-001, SW-014 |
| SW-019 | Netplay feasibility | M6 | **Deferred** | SW-003, SW-007, SW-008 |
| SW-020 | Legacy mod import without subprocess | M6 | **Deferred** | SW-003, SW-004 |
| SW-021 | Gyro and motion steering | M6 | **Deferred** | SW-007 |

## Suggested execution waves

**Wave 0 — make the toolchain real (M0)**
`SW-001` → `SW-002`. Nothing else should start until a hello `.nro` boots and
the generated payloads exist.

**Wave 1 — get the game running without a GPU (M1)**
`SW-003` in parallel with `SW-004`, `SW-005`, `SW-006`, `SW-007`. Use the null
renderer and the debug console. This proves CPU, memory, filesystem, audio,
input, and saves independently of RT64.

**Wave 2 — bring up rendering (M2)**
`SW-008` first (nxvk portlib + Vulkan probe), then `SW-009` (shader cache),
then the first rendered frame. Do not start `SW-010` before a frame presents.

**Wave 3 — make it playable (M3)**
`SW-010`, `SW-011`, `SW-012` together. This is the milestone that produces a
playable offline build.

**Wave 4 — ship it (M4 / M5)**
`SW-013` → `SW-014` → `SW-015` → `SW-016` → `SW-017` → `SW-018`.

**Wave 5 — stretch (M6)**
`SW-019`, `SW-020`, `SW-021` only after phase 1 is signed off.

## Issue lifecycle

| Status | Meaning |
|---|---|
| Not started | No code or design work landed. |
| In progress | Work landed on a branch; acceptance criteria not all met. |
| Blocked | Waiting on a dependency, decision, or hardware. |
| Partial | Some sub-scope landed (for example an update stub). |
| Done | Every acceptance checkbox is checked with recorded evidence. |
| Deferred | Explicitly out of phase 1. |

## Global ground rules

- Never hand-edit pinned dependencies under `extern/`; use the staged patch
  pipeline under `patches/switch/`.
- Keep every Switch behavior behind `DKR_SWITCH` so desktop/platform builds are
  unaffected.
- No ROM, extracted Nintendo/Rare asset, save file, or secret in the repo or a
  release package.
- Device-only criteria are only checked after an on-device observation.
- Record evidence (command, path, log, error) in the issue, not just "works".

## GitHub labels to mirror

`platform/switch`, `milestone/M0` … `milestone/M6`, plus one area label:
`area/build`, `area/runtime`, `area/graphics`, `area/audio`, `area/input`,
`area/saves`, `area/filesystem`, `area/ui`, `area/performance`, `area/netplay`,
`area/mods`, `area/packaging`, `area/docs`, `area/ci`, `area/ide`,
`area/licensing`.
