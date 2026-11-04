# SW-019 — Netplay feasibility (deferred)

| Field | Value |
|---|---|
| Status | **Deferred** (phase 2+) |
| Milestone | M6 |
| Area | `area/netplay` |
| Depends on | SW-003, SW-007, SW-008 |
| Blocks | — |
| Owner | unassigned |
| Branch | `switch-port` |

## Goal

Decide whether DKR-R netplay is feasible on Switch and, if so, implement a
supported subset without destabilizing phase 1.

## Context

All netplay is gated OFF in phase 1. The desktop path uses WebRTC
(`libdatachannel` + `libjuice` + `usrsctp`) for Quick Join, and mbedtls for
TLS/DTLS. None of those have a Switch port. libnx provides BSD-ish sockets, but
the ICE/DTLS stack is the hard part. A local LAN rollback path may be feasible
sooner than Quick Join.

## Scope

- In scope: a feasibility spike, architecture/determinism admission checks,
  local-LAN transport experiment, and a recommendation.
- Out of scope: shipping netplay in phase 1; WebRTC without a proven port.

## Acceptance criteria

- [ ] A spike documents which transport is possible on Switch (LAN sockets,
      PeerJS/WebRTC, or none).
- [ ] A two-console local-LAN test (or an emulator + console pair) runs a match.
- [ ] Admission checks reject arch/FP/determinism mismatches correctly.
- [ ] The experiment does not regress offline play.
- [ ] A go/no-go recommendation is recorded.

## Implementation notes

Start with `gekkonet` + mbedtls on direct IP/LAN, not WebRTC. The existing
determinism hash and admission policy should be reused. Cross-architecture
(ARM64 Switch vs x86_64 desktop) admission must be explicit.

Do not link `libdatachannel` into the Switch build until a port exists.

## Relevant existing code

- `runtime-recomp/src/game/runtime_netplay.*`
- `runtime-recomp/src/game/online_input_policy.hpp`
- `runtime-recomp/src/game/determinism_state_hash.*`
- `runtime-recomp/src/game/determinism_hash_policy.hpp`
- `runtime-recomp/src/game/lobby_privacy_policy.hpp`
- `docs/ONLINE_MULTIPLAYER.md`

## Switch-specific risks

- No libdatachannel/libjuice/usrsctp port.
- NAT traversal without WebRTC is limited.
- Switch sleep/suspend ends sessions ungracefully.
- Cross-architecture floating-point determinism.

## Validation

Two-device LAN match with the same build and mod set, plus a mismatch-rejection
test.

## Open questions

- Is Switch↔desktop netplay a goal, or Switch↔Switch only?
- Is a direct-IP/LAN mode acceptable for phase 2?

## Changelog

| Date | Change |
|---|---|
| 2026-11-03 | Created; deferred by the phase-1 plan. |
