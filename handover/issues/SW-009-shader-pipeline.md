# SW-009 — Shader precompile and RomFS cache

| Field | Value |
|---|---|
| Status | Not started |
| Milestone | M2 |
| Area | `area/graphics` |
| Depends on | SW-008 |
| Blocks | SW-014 |
| Owner | unassigned |
| Branch | `switch-port` |

## Goal

Precompile RT64's HLSL shaders on the host into RT64's shader-cache format and
ship them in the `.nro` RomFS so the console never needs `dxcompiler`.

## Context

There is no dxcompiler for aarch64. The Android port already proves the
host-tool pattern in `cmake/android/HostShaders.cmake`; the Switch equivalent
is `cmake/switch/HostShaders.cmake`. RT64 can consume a cache, but the exact
cache layout and lookup behavior must be verified.

## Scope

- In scope: host dxc invocation, cache format, deterministic output, RomFS
  packaging, cache-hit verification, fallback error when a shader is missing.
- Out of scope: runtime shader editing, custom user shaders.

## Acceptance criteria

- [ ] The host build emits the complete RT64 shader cache for the Switch build.
- [ ] The cache is stored in RomFS at the path RT64 expects.
- [ ] On device, RT64 loads every shader from cache with no dxc call.
- [ ] A deliberate cache miss produces a clear error, not a hang.
- [ ] Cache generation is reproducible (same input → same output).
- [ ] Package size impact is recorded.

## Implementation notes

Start from the Android `HostShaders.cmake` and adapt the tool path and output
directory. Make the cache a build output, not a committed binary blob.

Verify RT64's cache naming/versioning against the pinned RT64 commit; a cache
from a different RT64 version may be silently rejected.

## Relevant existing code

- `runtime-recomp/cmake/switch/HostShaders.cmake`
- `runtime-recomp/cmake/android/HostShaders.cmake`
- `extern/rt64` shader sources (read-only; patch via `patches/switch/`)
- `runtime-recomp/src/game/rt64_renderer.*`

## Switch-specific risks

- dxc output can be host-specific; pin the dxc version.
- RomFS is read-only at runtime; any RT64 write-back cache needs a savedata
  path instead.
- Large caches inflate the `.nro` and load time.

## Validation

Device check: boot with no network/dxc, reach a rendered scene, inspect logs
for cache hits.

## Open questions

- Does RT64 write new cache entries at runtime, and if so where?
- Should the cache be compressed in RomFS?

## Changelog

| Date | Change |
|---|---|
| 2026-11-03 | Created. |
