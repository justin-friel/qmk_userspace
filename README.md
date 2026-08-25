# QMK Userspace

This was created from a template repository which allows for an external set of QMK keymaps to be defined and compiled. This is useful for users who want to maintain their own keymaps without having to fork the [main QMK repository](https://github.com/qmk/qmk_firmware). You must still fork the main QMK repository if writing firmware for a *new* keyboard.

For fork-specific instructions see [README-qmk-external-userspace-setup.md](docs/README-qmk-external-userspace-setup.md)

## Goals

* Maintain a large number of keyboards.
* Keep personal keymaps separate from QMK firmware.
* Keep references to specific forks and commits for nonstandard boards (Massdrop, Keychron).
* Standardize on a modern QMK External Userspace workflow.
* Use a universal layout philosophy across boards.
* Prefer one shared source of truth.
* Use shared layouts when multiple keyboards expose a compatible physical layout.
* Support ANSI and Mac modes.
* Keep VIA available for experimentation but not as the source of truth.
* Archive firmware with its QMK source revisions and build information.
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
│Boot │  ▽  │  ▽  │  ▽  │  ▽  │  ▽  │  ▽  │  ▽  │  ▽  │  ▽  │  ▽  │  ▽  │  ▽  │   EE_CLR  │
├─────┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬────────┤
│    ▽   │  ▽  │  ▽  │  ▽  │RTOG │RNXT │RVAL │RHUE │RSAT │RSPD │  ▽  │  ▽  │  ▽  │   ▽    │
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

The userspace source is the authoritative keyboard configuration.

VIA is available for experimentation and temporary remapping, but permanent changes should be incorporated into the userspace source.

Firmware intended to be retained is built and archived with:

```bash
./scripts/build-userspace-archive.sh -kb <keyboard> -km <keymap>
```

Flashing is a separate, manual operation.

# Setup

## Howto configure your build targets

1. Run the normal `qmk setup` procedure if you haven't already done so -- see [QMK Docs](https://docs.qmk.fm/#/newbs) for details.
1. Fork this repository
1. Clone your fork to your local machine
1. Enable userspace in QMK config using `qmk config user.overlay_dir="$(realpath qmk_userspace)"`
1. Add a new keymap for your board using `qmk new-keymap`
    * This will create a new keymap in the `keyboards` directory, in the same location that would normally be used in the main QMK repository. For example, if you wanted to add a keymap for the Planck, it will be created in `keyboards/planck/keymaps/<your keymap name>`
    * You can also create a new keymap using `qmk new-keymap -kb <your_keyboard> -km <your_keymap>`
    * Alternatively, add your keymap manually by placing it in the location specified above.
    * `layouts/<layout name>/<your keymap name>/keymap.*` is also supported if you prefer the layout system
1. Add your keymap(s) to the build by running `qmk userspace-add -kb <your_keyboard> -km <your_keymap>`
    * This will automatically update your `qmk.json` file
    * Corresponding `qmk userspace-remove -kb <your_keyboard> -km <your_keymap>` will delete it
    * Listing the build targets can be done with `qmk userspace-list`
1. Commit your changes

## Howto build with GitHub

1. In the GitHub Actions tab, enable workflows
1. Push your changes above to your forked GitHub repository
1. Look at the GitHub Actions for a new actions run
1. Wait for the actions run to complete
1. Inspect the Releases tab on your repository for the latest firmware build

## Howto build locally

1. Run the normal `qmk setup` procedure if you haven't already done so -- see [QMK Docs](https://docs.qmk.fm/#/newbs) for details.
1. Fork this repository
1. Clone your fork to your local machine
1. `cd` into this repository's clone directory
1. Set global userspace path: `qmk config user.overlay_dir="$(realpath .)"` -- you MUST be located in the cloned userspace location for this to work correctly
    * This will be automatically detected if you've `cd`ed into your userspace repository, but the above makes your userspace available regardless of your shell location.
1. Compile normally: `qmk compile -kb your_keyboard -km your_keymap` or `make your_keyboard:your_keymap`

Alternatively, if you configured your build targets above, you can use `qmk userspace-compile` to build all of your userspace targets at once.

## Extra info

If you wish to point GitHub actions to a different repository, a different branch, or even a different keymap name, you can modify `.github/workflows/build_binaries.yml` to suit your needs.

To override the `build` job, you can change the following parameters to use a different QMK repository or branch:
```
    with:
      qmk_repo: qmk/qmk_firmware
      qmk_ref: master
```

If you wish to manually manage `qmk_firmware` using git within the userspace repository, you can add `qmk_firmware` as a submodule in the userspace directory instead. GitHub Actions will automatically use the submodule at the pinned revision if it exists, otherwise it will use the default latest revision of `qmk_firmware` from the main repository.

This can also be used to control which fork is used, though only upstream `qmk_firmware` will have support for external userspace until other manufacturers update their forks.

1. (First time only) `git submodule add https://github.com/qmk/qmk_firmware.git`
1. (To update) `git submodule update --init --recursive`
1. Commit your changes to your userspace repository
