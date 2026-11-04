# SW-006 — Audio output and mixing

| Field | Value |
|---|---|
| Status | Not started |
| Milestone | M1 (bring-up), M3 (qualification) |
| Area | `area/audio` |
| Depends on | SW-003 |
| Blocks | SW-011, SW-014, SW-016 |
| Owner | unassigned |
| Branch | `switch-port` |

## Goal

Play the recompiled Rare audio RSP output on Switch through SDL2's audio
backend with correct volume categories, mixing, and no dropouts.

## Context

The runtime uses an SDL2 audio device and a project-owned mix/equalizer layer.
Switch homebrew exposes audio through libnx (`audout`/`audren`); devkitPro's
SDL2 portlib supplies the bridge. The audio clock must not be tied to render
interpolation.

## Scope

- In scope: device open/close, buffer size/latency, resampling if required,
  master/music/SFX/vehicle/nature categories, EQ presets, suspend/resume.
- Out of scope: custom music decoding (already portable), netplay audio state
  (SW-019).

## Acceptance criteria

- [ ] Audio device opens at the project's expected rate/format on Switch.
- [ ] Menu music and race SFX play without clicks or underruns.
- [ ] Volume categories and EQ match desktop behavior.
- [ ] Audio survives pause/resume and applet focus changes.
- [ ] No audio thread stalls the main loop on a slow SD card.
- [ ] Sustained play (one full race) has no dropouts.

## Implementation notes

Start from the SDL2 audio path used by the in-process backend, not the SDL3
host worker. Check the devkitPro SDL2 build's supported sample rates and
whether it uses `audout` or `audren`.

Keep the audio clock independent from presentation; the existing mix/equalizer
code is portable and should not be rewritten.

## Relevant existing code

- `runtime-recomp/src/game/runtime_audio_controls.*`
- `runtime-recomp/src/game/audio_equalizer.*`
- `runtime-recomp/src/game/audio_event_queue.*`
- `runtime-recomp/src/game/runtime_sound_ui.inl`
- `docs/SOUND.md`

## Switch-specific risks

- Small audio buffers can underrun on the Switch's scheduler; tune latency.
- `audout` vs `audren` availability differs by firmware/applet mode.
- Docked/handheld output routing changes on the fly.
- A blocked audio callback can stall shutdown; make teardown non-blocking.

## Validation

Device check: menu, one full race, pause/resume, volume changes, dock/undock.

## Open questions

- Target buffer size/latency for handheld vs docked?
- Should the game request background audio, or stop cleanly on suspend?

## Changelog

| Date | Change |
|---|---|
| 2026-11-03 | Created. |
