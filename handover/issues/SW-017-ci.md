# SW-017 — CI nightly host-compile check

| Field | Value |
|---|---|
| Status | Not started |
| Milestone | M4 |
| Area | `area/ci` |
| Depends on | SW-001, SW-003 |
| Blocks | — |
| Owner | unassigned |
| Branch | `switch-port` |

## Goal

Catch Switch cross-compile regressions automatically without requiring a
console or a ROM in CI.

## Context

The repo already has `nightly-host-checks.yml`, platform build workflows, and a
workflow linter. The Switch port needs a configure/build (and ideally a
package) check that runs on a hosted runner with devkitPro installed, using the
scaffold preset until generated payloads can be produced in CI.

## Scope

- In scope: a workflow that installs devkitPro, configures `switch-scaffold`,
  builds the hello target (and later the full runtime), and uploads the `.nro`.
- Out of scope: on-device tests, ROM-dependent generated payloads unless a
  licensed fixture is available in a private runner.

## Acceptance criteria

- [ ] A workflow configures `switch-scaffold` on a clean runner.
- [ ] It builds `DKRSwitchHello` and uploads the `.nro`.
- [ ] It fails on a broken cross-compile.
- [ ] It does not require ROMs or private assets.
- [ ] A later stage can build `DKRPortGame` with cached/generated payloads.
- [ ] Workflow lint passes.

## Implementation notes

Model on `build-android.yml` / `build-ios.yml` and the dependency-cache pattern
from `nightly-host-checks.yml`. Pin devkitPro package versions or record the
resolved set in the log.

The full `switch` preset needs generated payloads; keep that job separate and
optional until a licensed generation fixture exists.

## Relevant existing code

- `.github/workflows/nightly-host-checks.yml`
- `.github/workflows/build-android.yml`
- `.github/workflows/build-ios.yml`
- `.github/workflows/workflow-lint.yml`
- `docs/NIGHTLY-CHECKS.md`

## Switch-specific risks

- devkitPro install time and package drift on runners.
- Docker-in-CI for nxvk may be too slow/heavy; skip it in the compile check.
- Hosted runners lack a GPU, so only compile-time checks are possible.

## Validation

Open a PR with a deliberate compile break and confirm the workflow fails; then
fix it and confirm green.

## Open questions

- GitHub-hosted runner or a self-hosted Windows/WSL runner?
- Should the nxvk portlib be cached as an artifact?

## Changelog

| Date | Change |
|---|---|
| 2026-11-03 | Created. |
