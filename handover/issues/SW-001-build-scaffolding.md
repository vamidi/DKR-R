# SW-001 — Build scaffolding and toolchain verification

| Field | Value |
|---|---|
| Status | **In progress** |
| Milestone | M0 |
| Area | `area/build` |
| Depends on | — |
| Blocks | SW-002, SW-003, SW-008, SW-017 |
| Owner | unassigned |
| Branch | `switch-port` |

## Goal

Make `switch/` configure, compile, link, and produce an installable hello
`.nro` that boots on a Switch, proving the devkitA64 → `switch.specs` →
`elf2nro` path before any game code is cross-compiled.

## Context

The wrapper project, presets, toolchain file, NACP template, deploy target, and
hello source exist. `switch-scaffold` configures green and the exceptions/RTTI
checks pass, but `switch/src/hello.c` was written against an older libnx API
and does not compile against libnx 4.12.0. No `.nro` has been produced.

## Scope

- In scope: the hello target, the `switch-scaffold` preset, NACP generation,
  and one on-device boot.
- Out of scope: game sources, RT64, generated payloads (SW-002/SW-003).

## Acceptance criteria

- [ ] `switch/src/hello.c` compiles against libnx 4.12.0.
- [ ] `cmake --build build/switch-scaffold --target DKRSwitchHello` produces
      `build/switch-scaffold/bin/Release/dkr-switch-hello.nro`.
- [ ] The `.nro` is copied to the console and boots to the banner.
- [ ] `+`/`-` exits cleanly (or the five-second timeout does).
- [ ] The scaffold changes are committed on `switch-port`.

## Implementation notes

Current libnx API replacements:

- `consoleInit(nwindowGetDefault())` → `consoleInit(NULL)` for the default
  console.
- Add `PadState pad; padInitializeDefault(&pad);` before the loop.
- `PadStateDown` → `padGetButtonsDown(&pad)`.
- `PadButton_Plus` / `PadButton_Minus` → `HidNpadButton_Plus` /
  `HidNpadButton_Minus`.
- `napms(16)` → `svcSleepThread(16'000'000ULL)` (or `nanosleep`).

`__nx_applet_type = AppletType_Application` is correct for the product; keep it
in `switch_main.cpp`, and leave the hello target self-contained for now.

Deploy options: `dkr-switch-deploy` requires `DKR_SWITCH_CONSOLE_IP` and a
console running sys-ftpd on port 5000; alternatively copy the `.nro` to
`sd:/switch/` and launch from the homebrew menu.

## Relevant existing code

- `switch/CMakeLists.txt` — hello target + NRO packaging.
- `switch/CMakePresets.json` — `switch-scaffold` preset.
- `switch/cmake/SwitchToolchain.cmake` — devkitA64 wiring.
- `switch/src/hello.c` — the failing source.
- `runtime-recomp/cmake/SwitchPlatform.cmake` — exceptions/RTTI assertions.

## Switch-specific risks

- libnx API drift between the installed 4.12.0 and examples in
  `.opencode/skills/switch-homebrew/references/`; trust the installed headers.
- NACP generation can fail silently if `VERSION` or the template placeholders
  drift; check `nro/app.nacp.txt`.
- A `.nro` that links is not proof it boots; the applet heap and application
  applet type matter.

## Validation

```powershell
cmake --preset switch-scaffold --fresh
cmake --build build/switch-scaffold --target DKRSwitchHello
Get-ChildItem build/switch-scaffold/bin/Release -Filter *.nro
```

Device check: banner text, build timestamp, clean exit.

## Open questions

- Which console/firmware and homebrew launcher will be used for validation?
- Is sys-ftpd available, or should deploy go through SD-card copying?

## Changelog

| Date | Change |
|---|---|
| 2026-11-03 | Created from the M0 findings in `n64_project_state.md`. |
