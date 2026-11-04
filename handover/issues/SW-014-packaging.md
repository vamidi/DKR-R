# SW-014 — Packaging and distribution

| Field | Value |
|---|---|
| Status | Not started |
| Milestone | M4 |
| Area | `area/packaging` |
| Depends on | SW-003, SW-008, SW-009 |
| Blocks | SW-016, SW-018 |
| Owner | unassigned |
| Branch | `switch-port` |

## Goal

Produce a reproducible, correctly named `.nro` package with RomFS content,
version metadata, and notices, suitable for handover or release.

## Context

`switch/CMakeLists.txt` already builds a NACP from `nro/app.nacp.template` and
an NRO via devkitPro's `nx_create_nro`. What is missing is the release pipeline:
RomFS staging (shader cache, notices, `dkr-release.json`), version derivation,
artifact naming, and checksums.

## Scope

- In scope: `scripts/Package-Switch.ps1`, RomFS layout, NACP fields, artifact
  name/version, checksums, and a clean build from a fresh configure.
- Out of scope: store submission, title keys, NSP/XCI packaging.

## Acceptance criteria

- [ ] A clean `cmake --preset switch` + build produces `DKR-R.nro`.
- [ ] `scripts/Package-Switch.ps1` emits
      `DKR-R-<version>-Switch.nro` with the correct RomFS contents.
- [ ] The NACP title, author, and version come from `VERSION`/template.
- [ ] The shader cache from SW-009 is inside RomFS at the expected path.
- [ ] Third-party notices and `dkr-release.json` are included.
- [ ] The package contains no ROM or extracted game asset.
- [ ] A SHA-256 checksum is recorded.

## Implementation notes

Follow the existing `Package-Android-Preview.ps1` / `Package-Windows.ps1`
structure. Use CMake install/copy steps rather than hand-assembled folders.

Keep version parsing in one place. `VERSION` is `1.0.7+beta.2`; the NACP version
and artifact name must agree.

## Relevant existing code

- `switch/CMakeLists.txt` — NACP + `nx_create_nro`.
- `switch/nro/app.nacp.template`
- `switch/cmake/make-nacp.cmake`
- `switch/cmake/deploy-nro.cmake`
- `scripts/Package-Android-Preview.ps1`, `scripts/Package-Windows.ps1`
- `VERSION`, `dependencies.lock.json`

## Switch-specific risks

- `nx_create_nro` argument/ordering differences across switch-tools versions.
- RomFS path case sensitivity on the console.
- NRO size limits and load time with a large shader cache.
- Accidentally shipping host-only helpers or generated payload sources.

## Validation

```powershell
cmake --preset switch --fresh
cmake --build build/switch
powershell -ExecutionPolicy Bypass -File scripts/Package-Switch.ps1
Get-FileHash dist/DKR-R-*-Switch.nro -Algorithm SHA256
```

Device check: install the packaged `.nro` (not the build-tree copy) and play.

## Open questions

- Distribution target: GitHub release, homebrew app store, or private handover?
- Should the package be a zip with a readme, or a bare `.nro`?

## Changelog

| Date | Change |
|---|---|
| 2026-11-03 | Created. |
