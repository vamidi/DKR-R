# SW-016 — Docs and device validation

| Field | Value |
|---|---|
| Status | Not started |
| Milestone | M4 |
| Area | `area/docs` |
| Depends on | SW-014 |
| Blocks | — |
| Owner | unassigned |
| Branch | `switch-port` |

## Goal

Give a new developer everything needed to build, deploy, validate, and
troubleshoot the Switch port, and record a reproducible device acceptance run.

## Context

The approved plan calls for `docs/SWITCH.md` plus a device checklist appended in
the style of `RELEASE-VALIDATION.md`. Neither exists. `n64_project_state.md`
tracks status but is not a build guide.

## Scope

- In scope: build prerequisites, preset commands, nxvk setup, ROM import,
  deploy (SD/FTP), controls, known limitations, troubleshooting, and a signed
  device checklist.
- Out of scope: desktop/Android/iOS doc changes.

## Acceptance criteria

- [ ] `docs/SWITCH.md` covers prerequisites and exact commands.
- [ ] nxvk build/install and licensing notes are included.
- [ ] ROM import and save locations are documented.
- [ ] Controller mapping and supported modes are documented.
- [ ] A device acceptance checklist covers both ROM revisions, audio, input,
      saves, suspend/resume, dock/undock, and launcher↔game.
- [ ] Checklist results include console/firmware and artifact checksum.
- [ ] Known phase-1 limitations (netplay, mods, updates) are explicit.

## Implementation notes

Follow the tone and structure of `docs/BUILDING.md`, `docs/PLATFORMS.md`, and
`RELEASE-VALIDATION.md`. Keep commands copy-pasteable for PowerShell.

The checklist should distinguish automated evidence from hardware observation,
as the release validation doc already does.

## Relevant existing code

- `docs/BUILDING.md`, `docs/PLATFORMS.md`, `docs/TROUBLESHOOTING.md`
- `RELEASE-VALIDATION.md`
- `n64_project_state.md`
- `handover/README.md`

## Switch-specific risks

- Commands differ between a Windows host and a WSL/Ubuntu host.
- devkitPro package names/versions drift.
- A checklist that only says "works" is not reproducible.

## Validation

A fresh developer follows the doc on a clean machine and produces a `.nro`
without asking questions.

## Open questions

- Which host OS is the reference for the guide: Windows, WSL, or both?
- Where should device logs be stored so they can be attached to a report?

## Changelog

| Date | Change |
|---|---|
| 2026-11-03 | Created. |
