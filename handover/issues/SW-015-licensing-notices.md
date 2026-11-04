# SW-015 — Licensing and third-party notices

| Field | Value |
|---|---|
| Status | Not started |
| Milestone | M4 |
| Area | `area/licensing` |
| Depends on | SW-008 |
| Blocks | SW-014 |
| Owner | unassigned |
| Branch | `switch-port` |

## Goal

Make the Switch package's licensing correct and explicit, especially the
consequences of statically linking nxvk (GPL-2.0-or-later + Mesa licenses).

## Context

DKR-R itself is MIT with public source. nxvk is GPL-2.0-or-later for new files
plus Mesa licenses; static linking makes the combined `.nro` GPL-encumbered for
recipients. The approved plan already flags that `docs/SWITCH.md` and
`THIRD_PARTY.md` must carry the notice. No such notice exists yet.

## Scope

- In scope: dependency license inventory, written notices, source-offer
  wording, package inclusion, and a check that notices ship in RomFS.
- Out of scope: legal advice; this issue records engineering facts.

## Acceptance criteria

- [ ] Every statically linked dependency has an entry in `THIRD_PARTY.md`.
- [ ] nxvk's GPL-2.0-or-later and Mesa notices are included verbatim.
- [ ] `docs/SWITCH.md` states the combined-binary licensing consequence.
- [ ] The package ships the notices in a discoverable location.
- [ ] The source-availability/offer path is documented for recipients.
- [ ] No dependency license is silently omitted.

## Implementation notes

Generate the inventory from `dependencies.lock.json` plus the portlibs actually
linked (SDL2, zstd, mbedtls, expat, zlib, nxvk). Note that `switch/` code itself
remains MIT; the combined binary is the concern.

Do not claim the package is MIT-only. Be precise about which files are which.

## Relevant existing code

- `THIRD_PARTY.md`
- `LICENSE.md`
- `dependencies.lock.json`
- `scripts/Build-NXVK.ps1` — copies nxvk licenses into portlibs.
- `extern/nxvk/licenses/`

## Switch-specific risks

- Portlib licenses may differ from the desktop vendored versions.
- A later nxvk bump can change the license set.
- Removing a notice during packaging is easy to miss.

## Validation

Package inspection: unzip/list RomFS and confirm every notice file is present.

## Open questions

- Will Switch builds be distributed publicly, or only as a private handover?
- Who owns the final licensing review?

## Changelog

| Date | Change |
|---|---|
| 2026-11-03 | Created from the nxvk licensing note in the approved plan. |
