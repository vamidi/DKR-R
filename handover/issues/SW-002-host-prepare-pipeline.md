# SW-002 — Host prepare pipeline (ELF, v77/v80 CPU, RSP)

| Field | Value |
|---|---|
| Status | Not started |
| Milestone | M0 |
| Area | `area/build` |
| Depends on | SW-001 |
| Blocks | SW-003 |
| Owner | unassigned |
| Branch | `switch-port` |

## Goal

Produce, on the host, every generated input the Switch build needs: the
matching ELF, both CPU payloads (US v1.0/v77 and Rev A/v1.1/v80), and the
recompiled RSP, then point the CMake cache at those directories.

## Context

`runtime-recomp/RecompiledFuncs` is absent, so `cmake --preset switch` stops at
`runtime-recomp/CMakeLists.txt:144` with an empty `DKR_GENERATED_SOURCE_V80`.
Generation stays host-side; the Switch build only consumes the generated C.

## Scope

- In scope: running the existing prepare workflow for this checkout and
  documenting the output paths and hashes.
- Out of scope: changing the generation pipeline or committing generated
  output.

## Acceptance criteria

- [ ] A clean US v1.0 ROM produces a v77 CPU payload directory.
- [ ] A clean US Rev A/v1.1 ROM produces a v80 CPU payload directory.
- [ ] The v77 and v80 directories are different (the CMake guard enforces it).
- [ ] The RSP payload is generated.
- [ ] The exact paths are recorded here and used for
      `DKR_GENERATED_SOURCE_V77` / `DKR_GENERATED_SOURCE_V80`.
- [ ] `cmake --preset switch` advances past the generated-source gate.

## Implementation notes

Use the existing `Prepare-DKR-Runtime.cmd` / `Prepare-DKR-Runtime.ps1` and
`Prepare-Game-Source.cmd` / `Generate-DKR-RSP.cmd` workflow under WSL. The
approved plan says N64Recomp generation stays host-side and its output is
portable C.

Do not commit `RecompiledFuncs`, ROMs, or extracted assets. Keep generated
directories outside git (or under the existing ignore rules) and record their
paths in the local CMake cache/preset.

## Relevant existing code

- `Prepare-DKR-Runtime.cmd`, `Prepare-Game-Source.cmd`, `Generate-DKR-RSP.cmd`
- `scripts/Prepare-DKR-Runtime.ps1`, `scripts/Prepare-Game-Source.ps1`,
  `scripts/Generate-DKR-RSP.ps1`
- `runtime-recomp/CMakeLists.txt:142-159` — generated-source gates.
- `docs/ROM_SETUP.md`, `docs/BUILDING.md`, `docs/DEVELOPMENT.md`

## Switch-specific risks

- The generation step may assume host compiler paths; keep it host-only.
- Line endings/encoding can change generated identities; use the repository's
  existing `.gitattributes` and workflow.
- ROM revision mismatch fails later with confusing errors; verify hashes first.

## Validation

```powershell
# After generation, in switch/
cmake --preset switch --fresh -DDKR_GENERATED_SOURCE_V77=<v77-dir> -DDKR_GENERATED_SOURCE_V80=<v80-dir>
```

Record the two directories and the ROM hashes used (not the ROMs).

## Open questions

- Should the generated directories live under `build/` or a per-developer path
  outside the repo?
- Does the RSP output need a Switch-specific path, or is the existing one
  architecture-neutral?

## Changelog

| Date | Change |
|---|---|
| 2026-11-03 | Created from the M0/M1 findings. |
