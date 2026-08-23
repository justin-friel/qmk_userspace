# QMK Userspace

This repository is an external QMK userspace: a separate set of personal
keymaps, shared code, build targets, and retained firmware archives. It can be
used with a normal QMK environment without depending on another project.

## Goals

* Maintain a large number of keyboards.
* Keep personal keymaps separate from QMK firmware.
* Standardize on a modern QMK External Userspace workflow.
* Use a universal layout philosophy across boards.
* Prefer one shared source of truth.
* Use shared layouts when multiple keyboards expose a compatible physical layout.
* Support ANSI and Mac modes.
* Keep VIA available for experimentation but not as the source of truth.
* Archive retained firmware with its QMK source revisions and build information.
* Primary preference is 60% layouts with Caps-based navigation.

## Base Layout

Layer 0: ANSI / Windows / Linux Base

```text
┌─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬───────────┐
│ Esc │  1  │  2  │  3  │  4  │  5  │  6  │  7  │  8  │  9  │  0  │  -  │  =  │ Backspace │
├─────┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬────────┤
│  Tab   │  Q  │  W  │  E  │  R  │  T  │  Y  │  U  │  I  │  O  │  P  │  [  │  ]  │  |\    │
├────────┴┬────┴┬────┴┬────┴┬────┴┬────┴┬────┴┬────┴┬────┴┬────┴┬────┴┬────┴┬────┴────────┤
│  MO(2)  │  A  │  S  │  D  │  F  │  G  │  H  │  J  │  K  │  L  │  ;  │  '  │    Enter    │
├─────────┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴─────────────┤
│   Shift    │  Z  │  X  │  C  │  V  │  B  │  N  │  M  │  ,  │  .  │  ?  │     Shift      │
├───────┬────┴──┬──┴────┬┴─────┴─────┴─────┴─────┴─────┴──┬──┴────┬┴─────┴┬───────┬───────┤
│  Ctrl │  Win  │  Alt  │              Space              │  Alt  │  Win  │ MO(3) │ Ctrl  │
└───────┴───────┴───────┴─────────────────────────────────┴───────┴───────┴───────┴───────┘
```

Layer 1: Mac

```text
┌─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬───────────┐
│  ▽  │  ▽  │  ▽  │  ▽  │  ▽  │  ▽  │  ▽  │  ▽  │  ▽  │  ▽  │  ▽  │  ▽  │  ▽  │     ▽     │
├─────┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬────────┤
│    ▽   │  ▽  │  ▽  │  ▽  │  ▽  │  ▽  │  ▽  │  ▽  │  ▽  │  ▽  │  ▽  │  ▽  │  ▽  │   ▽    │
├────────┴┬────┴┬────┴┬────┴┬────┴┬────┴┬────┴┬────┴┬────┴┬────┴┬────┴┬────┴┬────┴────────┤
│    ▽    │  ▽  │  ▽  │  ▽  │  ▽  │  ▽  │  ▽  │  ▽  │  ▽  │  ▽  │  ▽  │  ▽  │      ▽      │
├─────────┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴─────────────┤
│     ▽      │  ▽  │  ▽  │  ▽  │  ▽  │  ▽  │  ▽  │  ▽  │  ▽  │  ▽  │  ▽  │       ▽        │
├───────┬────┴──┬──┴────┬┴─────┴─────┴─────┴─────┴─────┴──┬──┴────┬┴─────┴┬───────┬───────┤
│   ▽   │  Alt  │  Cmd  │                ▽                │  Cmd  │  Alt  │   ▽   │ Ctrl  │
└───────┴───────┴───────┴─────────────────────────────────┴───────┴───────┴───────┴───────┘
```

Layer 2: Convenience / Caps held

```text
┌─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬───────────┐
│ `~  │ F1  │ F2  │ F3  │ F4  │ F5  │ F6  │ F7  │ F8  │ F9  │ F10 │ F11 │ F12 │  Delete   │
├─────┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬────────┤
│    ▽   │  ▽  │  ▽  │  ▽  │  ▽  │  ▽  │  ▽  │ PgUp│  ↑  │ PgDn│ PtSc│ Ins │ ScLk│   ▽    │
├────────┴┬────┴┬────┴┬────┴┬────┴┬────┴┬────┴┬────┴┬────┴┬────┴┬────┴┬────┴┬────┴────────┤
│    ▽    │  ▽  │  ▽  │  ▽  │  ▽  │  ▽  │ Home│  ←  │  ↓  │  →  │  ▽  │  ▽  │      ▽      │
├─────────┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴─────────────┤
│     ▽      │  ▽  │  ▽  │  ▽  │  ▽  │  ▽  │ End │  ▽  │  ▽  │  ▽  │  ▽  │       ▽        │
├───────┬────┴──┬──┴────┬┴─────┴─────┴─────┴─────┴─────┴──┬──┴────┬┴─────┴┬───────┬───────┤
│   ▽   │   ▽   │   ▽   │                ▽                │   ▽   │ Menu  │   ▽   │   ▽   │
└───────┴───────┴───────┴─────────────────────────────────┴───────┴───────┴───────┴───────┘
```

Layer 3: Settings

```text
┌─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬───────────┐
│Boot │  ▽  │  ▽  │  ▽  │  ▽  │  ▽  │  ▽  │  ▽  │  ▽  │  ▽  │  ▽  │  ▽  │  ▽  │     ▽     │
├─────┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬────────┤
│    ▽   │  ▽  │  ▽  │  ▽  │  ▽  │  ▽  │  ▽  │  ▽  │  ▽  │  ▽  │  ▽  │  ▽  │  ▽  │   ▽    │
├────────┴┬────┴┬────┴┬────┴┬────┴┬────┴┬────┴┬────┴┬────┴┬────┴┬────┴┬────┴┬────┴────────┤
│  Caps   │Ansi │  ▽  │  ▽  │  ▽  │  ▽  │  ▽  │  ▽  │  ▽  │  ▽  │  ▽  │  ▽  │      ▽      │
├─────────┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴─────────────┤
│     ▽      │  ▽  │  ▽  │  ▽  │  ▽  │  ▽  │ NKRO│ Mac │  ▽  │  ▽  │  ▽  │       ▽        │
├───────┬────┴──┬──┴────┬┴─────┴─────┴─────┴─────┴─────┴──┬──┴────┬┴─────┴┬───────┬───────┤
│   ▽   │   ▽   │   ▽   │                ▽                │   ▽   │   ▽   │   ▽   │   ▽   │
└───────┴───────┴───────┴─────────────────────────────────┴───────┴───────┴───────┴───────┘
```

* fn1 = Caps Lock
* fn2 = Menu/F13/Split Shift/Pause depending on board (ANSI 60% shown)

## Source of Truth

The userspace source is the authoritative keyboard configuration. VIA is
available for experimentation and temporary remapping, but permanent changes
belong in the userspace source.

Retained firmware archives live under `firmware/<keyboard>/<build-time>/` with
their `info.txt` build metadata. Building and flashing are separate operations.

## Setup

1. Set up QMK following the [QMK documentation](https://docs.qmk.fm/newbs_getting_started).
1. Clone this repository.
1. From its root, configure it as the external userspace:

   ```bash
   qmk config user.overlay_dir="$(realpath .)"
   ```

1. Verify the configuration with:

   ```bash
   qmk userspace-doctor
   ```

## Keymaps and Build Targets

Add a board-specific keymap under
`keyboards/<keyboard>/keymaps/<keymap>/`, or use a compatible shared layout
under `layouts/`. Add a target to `qmk.json` with:

```bash
qmk userspace-add -kb <keyboard> -km <keymap>
```

List configured targets with `qmk userspace-list`, then build either one target
or all configured targets:

```bash
qmk compile -kb <keyboard> -km <keymap>
qmk userspace-compile
```

## Shared Userspace Code

The `users/` directory holds code and configuration shared by keymaps with the
same name. Use it for common behavior while keeping board-specific physical
layout and hardware behavior in the corresponding keyboard keymap.
