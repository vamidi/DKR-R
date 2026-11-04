# SW-005 — Save persistence and EEPROM

| Field | Value |
|---|---|
| Status | Not started |
| Milestone | M1 |
| Area | `area/saves` |
| Depends on | SW-003, SW-004 |
| Blocks | SW-014, SW-016 |
| Owner | unassigned |
| Branch | `switch-port` |

## Goal

Persist and reload offline progress (EEPROM and the project's save namespaces)
on Switch without corrupting existing saves or leaking speculative online
state.

## Context

DKR-R has a save-routing layer that holds one immutable route until all
producers retire, plus atomic persistence and scoped backups. Switch needs a
storage backend and the same guarantees using its private savedata path.

## Scope

- In scope: offline save directory, atomic write/rename, backup rotation,
  EEPROM codec, save UI paths.
- Out of scope: online save namespaces (SW-019), legacy mod saves (SW-020).

## Acceptance criteria

- [ ] A new save is created in the Switch savedata path.
- [ ] Progress survives app exit and console reboot.
- [ ] Save writes are atomic (no truncated file after a mid-write kill).
- [ ] A corrupt save falls back to the scoped backup with an actionable error.
- [ ] Both ROM revisions can use their compatible EEPROM format.
- [ ] No save is written for speculative/rollback state.

## Implementation notes

Reuse `save_manager`, `runtime_save_routing`, and `dkr_save_codec`; add a Switch
storage backend rather than a parallel format. Use write-temp + fsync + rename
semantics available on the SD/newlib layer.

The virtual Pak path should follow the same route and be tested independently.

## Relevant existing code

- `runtime-recomp/src/game/save_manager.*`
- `runtime-recomp/src/game/save_storage.hpp`
- `runtime-recomp/src/game/runtime_save_routing.*`
- `runtime-recomp/src/game/dkr_save_codec.*`
- `runtime-recomp/src/game/virtual_pak.*`
- `docs/SAVES.md`

## Switch-specific risks

- SD card removal/power loss during write; atomic rename is mandatory.
- Case-insensitive filesystems can collide save namespaces.
- Savedata quotas and applet-user selection can make the path unavailable.
- Restoring a desktop save may need a migration/validation step.

## Validation

Device check: create progress, back out, power-cycle, reload; corrupt a copy and
confirm backup recovery.

## Open questions

- Should desktop saves be importable, and if so through which UI?
- Is the savedata path or `sdmc:` the better long-term home for backups?

## Changelog

| Date | Change |
|---|---|
| 2026-11-03 | Created. |
