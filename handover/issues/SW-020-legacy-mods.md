# SW-020 — Legacy mod import without subprocess (deferred)

| Field | Value |
|---|---|
| Status | **Deferred** (phase 2+) |
| Milestone | M6 |
| Area | `area/mods` |
| Depends on | SW-003, SW-004 |
| Blocks | — |
| Owner | unassigned |
| Branch | `switch-port` |

## Goal

Support DKR-R's offline mod content on Switch without the desktop's
`DKRLegacyModWorker` subprocess model.

## Context

Homebrew has no subprocess model, so the legacy mod worker is gated OFF in
phase 1 (same precedent as iOS). Mod import/admission/activation still need an
in-process path if mods are to work on Switch. The project already separates
reviewed native behaviour adapters from arbitrary patched guest code; that
boundary must hold.

## Scope

- In scope: in-process asset/mod decoding, activation, namespace isolation,
  validation, and safe rejection of unsupported mods.
- Out of scope: running arbitrary guest code, online mod sync (SW-019).

## Acceptance criteria

- [ ] A reviewed asset-only mod can be imported and used offline on Switch.
- [ ] The in-process path enforces the same validation as desktop.
- [ ] Unsupported mods fail closed with a clear error.
- [ ] No subprocess is spawned.
- [ ] Memory use for mod assets is bounded and measured.
- [ ] Mods do not affect saves outside their namespace.

## Implementation notes

Study `runtime_legacy_mods` and the iOS gating. Move only the safe,
in-process-safe parts of the worker into the runtime; keep arbitrary guest-code
behaviour out.

`nativefiledialog-extended` is unavailable; import through the SD-card/file
flow from SW-004.

## Relevant existing code

- `runtime-recomp/src/game/runtime_legacy_mods.*`
- `runtime-recomp/src/game/runtime_code_mods.*`
- `runtime-recomp/src/game/runtime_mod_library_ui.inl`
- `runtime-recomp/src/game/custom_tracks.*`
- `docs/MODDING_ARCHITECTURE.md`, `docs/LEGACY-MODS-BETA.md`
- `docs/ASSET_POLICY.md`

## Switch-specific risks

- Memory ceiling for large mod/track packs.
- Long decode times on ARM without a worker process.
- Path/namespace collisions on a case-insensitive SD filesystem.
- Licensing/asset policy for imported content.

## Validation

Device check: import an asset-only custom track or character, use it offline,
relaunch, and confirm no namespace leak.

## Open questions

- Which mod class is phase-2 minimum: texture packs, custom tracks, or
  characters?
- Is a background decode thread acceptable, or must import be synchronous?

## Changelog

| Date | Change |
|---|---|
| 2026-11-03 | Created; deferred by the phase-1 plan. |
