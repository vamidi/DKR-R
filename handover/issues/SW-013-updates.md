# SW-013 — Update service on Switch

| Field | Value |
|---|---|
| Status | **Partial** (stub landed) |
| Milestone | M4 |
| Area | `area/runtime` |
| Depends on | — |
| Blocks | SW-016 |
| Owner | unassigned |
| Branch | `switch-port` |

## Goal

Define and implement the Switch behavior for DKR-R's built-in updater: either a
working update path or a clean, documented "updates are not supported" flow
that never crashes or offers an uninstallable package.

## Context

Desktop updates are HTTPS + signed metadata + a child-process installer. Switch
homebrew has no child-process model, and this build currently links a stub
(`switch_update_http.cpp`) that throws a clear error. The UI must catch it and
report the check as failed rather than hanging.

## Scope

- In scope: feature gate, UI copy, error handling, and a decision on whether to
  implement HTTPS/install later.
- Out of scope: a full self-updater in phase 1.

## Acceptance criteria

- [ ] The updater is compiled out or stubbed on Switch behind `DKR_SWITCH`.
- [ ] "Check for updates" reports unsupported/failed without crashing.
- [ ] No HTTP request is attempted.
- [ ] Update UI copy explains how Switch builds are distributed.
- [ ] The decision is recorded in `docs/SWITCH.md`.

## Implementation notes

The stub exists at `runtime-recomp/src/switch/switch_update_http.cpp`. Verify
`Updates.cmake` selects it on Switch and that `update_process.cpp` cannot try
to spawn a helper.

If a future phase implements updates, libnx's SSL/socket stack or a
download-to-SD flow is required; do not reuse the desktop installer.

## Relevant existing code

- `runtime-recomp/src/switch/switch_update_http.cpp`
- `runtime-recomp/src/game/updates/update_service.*`
- `runtime-recomp/src/game/updates/update_process.*`
- `runtime-recomp/src/game/runtime_updates_ui.inl`
- `runtime-recomp/cmake/Updates.cmake`
- `docs/UPDATES.md`

## Switch-specific risks

- Signed metadata verification assumes desktop paths and a helper binary.
- A partially downloaded file could be treated as installable.
- Error text may be truncated in the console UI.

## Validation

Device check: open the update UI, run Check for updates, confirm a clean error
and no network activity.

## Open questions

- Phase 1: hide the update UI entirely, or show it with an explanation?
- Is an SD-card-based manual update flow desirable?

## Changelog

| Date | Change |
|---|---|
| 2026-11-03 | Created; stub already present. |
