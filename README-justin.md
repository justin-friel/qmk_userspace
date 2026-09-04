# QMK Userspace Conventions

## Goals

* Keep personal keymaps separate from QMK firmware source.
* Keep references to specific forks and commits for nonstandard boards (Massdrop, Keychron).
* Standardize on a modern QMK External Userspace workflow.
* Use a universal layout and layers across boards.
* Archive firmware with its QMK source revisions and build information.

## Base Layout

Layer 0: ANSI / Windows / Linux Base

```text
┌─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬───────────┐
│ Esc │  1  │  2  │  3  │  4  │  5  │  6  │  7  │  8  │  9  │  0  │  -  │  =  │ Backspace │
├─────┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬────────┤
│  Tab   │  Q  │  W  │  E  │  R  │  T  │  Y  │  U  │  I  │  O  │  P  │  [  │  ]  │  |\    │
├────────┴┬────┴┬────┴┬────┴┬────┴┬────┴┬────┴┬────┴┬────┴┬────┴┬────┴┬────┴┬────┴────────┤
│  M_NAV  │  A  │  S  │  D  │  F  │  G  │  H  │  J  │  K  │  L  │  ;  │  '  │    Enter    │
├─────────┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴─────────────┤
│   Shift    │  Z  │  X  │  C  │  V  │  B  │  N  │  M  │  ,  │  .  │  ?  │     Shift      │
├───────┬────┴──┬──┴────┬┴─────┴─────┴─────┴─────┴─────┴──┬──┴────┬┴─────┴┬───────┬───────┤
│  Ctrl │  Win  │  Alt  │              Space              │  Alt  │  Win  │ M_SET │ Ctrl  │
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
│    ▽   │  ▽  │  ▽  │  ▽  │  ▽  │  ▽  │OS_RD│ PgUp│  ↑  │OS_PS│ PtSc│ Ins │ ScLk│   ▽    │
├────────┴┬────┴┬────┴┬────┴┬────┴┬────┴┬────┴┬────┴┬────┴┬────┴┬────┴┬────┴┬────┴────────┤
│    ▽    │OS_SA│  ▽  │  ▽  │  ▽  │  ▽  │ Home│  ←  │  ↓  │  →  │  ▽  │  ▽  │      ▽      │
├─────────┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴─────────────┤
│     ▽      │OS_UD│OS_CT│OS_CP│OS_P │  ▽  │ End │  ▽  │  ▽  │  ▽  │  ▽  │       ▽        │
├───────┬────┴──┬──┴────┬┴─────┴─────┴─────┴─────┴─────┴──┬──┴────┬┴─────┴┬───────┬───────┤
│   ▽   │   ▽   │   ▽   │                ▽                │   ▽   │ Menu  │   ▽   │   ▽   │
└───────┴───────┴───────┴─────────────────────────────────┴───────┴───────┴───────┴───────┘
```
Layer 3: Settings
```text
┌─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬───────────┐
│Boot │  ▽  │  ▽  │  ▽  │  ▽  │  ▽  │  ▽  │  ▽  │  ▽  │  ▽  │  ▽  │  ▽  │  ▽  │   EE_CLR  │
├─────┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬────────┤
│    ▽   │  ▽  │  ▽  │  ▽  │RTOG │RNXT │RHUEU│RSATU│RVALU│RSPDU│  ▽  │  ▽  │  ▽  │   ▽    │
├────────┴┬────┴┬────┴┬────┴┬────┴┬────┴┬────┴┬────┴┬────┴┬────┴┬────┴┬────┴┬────┴────────┤
│  Caps   │ANSI │  ▽  │  ▽  │  ▽  │RPRV │RHUED│RSATD│RVALD│RSPDD│  ▽  │  ▽  │      ▽      │
├─────────┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴─────────────┤
│     ▽      │ BL- │ BL+ │BLTG │  ▽  │  ▽  │ NKRO│ Mac │  ▽  │  ▽  │  ▽  │       ▽        │
├───────┬────┴──┬──┴────┬┴─────┴─────┴─────┴─────┴─────┴──┬──┴────┬┴─────┴┬───────┬───────┤
│   ▽   │   ▽   │   ▽   │                ▽                │   ▽   │   ▽   │   ▽   │   ▽   │
└───────┴───────┴───────┴─────────────────────────────────┴───────┴───────┴───────┴───────┘
```

* fn1 = Caps Lock
* fn2 = Menu/F13/Split Shift/Pause depending on board (ANSI 60% shown)

## Common Features

The base keymap is based on a 60% layout. All keyboards, regardless of size, should implement the following layers and features for convenience and muscle memory.

### Layers

The standard keymap contains four layers:

1. A standard ANSI layer.
2. A Mac-compatible layer.
3. A layer used for navigation shortcuts and keys missing from a TKL keyboard.
4. A layer dedicated mostly to hardware controls.

```c
enum layers {
	_ANSI,
	_MAC,
	_NAV,
	_SETTINGS
};
```

### Base layer

The default layer contains the standard alphanumeric keys and function keys for activating the different layers.

- `MO(_NAV)` is in the Caps Lock position.
- `MO(_SETTINGS)` is in the position of the Menu key, when available. It may be mapped to a different key depending on the layout.

### ANSI and Mac Modes

Keyboards use a dedicated ANSI layer as the default layer and a mostly transparent Mac layer with the GUI and Alt/Option keys in the appropriate positions for Apple layouts.

Mac mode is toggleable on the settings layer, but not stored in EEPROM.

#### Cross-Platform keycodes

Custom keycodes are implemented to avoid dead keys when in Mac mode and standardize common shortcuts between ANSI and Mac keyboards.

| Keycode  | Function        | ANSI       | MAC
|:---      |:---             |:---        |:---
| OS_PS,   | Print Screen    | KC_PSCR     | Shift + 3 (Cmd + OS_PS = Cmd+Shift+4)
| OS_SA,   | Select All      | Ctrl+A      | Command+A
| OS_CP,   | Copy            | Ctrl+C	   | Command+C
| OS_CT,   | Cut             | Ctrl+X	   | Command+X
| OS_P,    | Paste           | Ctrl+V	   | Command+V
| OS_UD,   | Undo            | Ctrl+Z	   | Command+Z
| OS_RD,   | Redo            | Ctrl+Y	   | Command+Shift+Z

### Navigation Layer

The navigation layer contains keys that are in the navigation section of a TKL keyboard. Notably:

- Arrow keys (`KC_UP`, `KC_LEFT`, `KC_DOWN` and `KC_RGHT`) are at the `I`, `J`, `K`, `L` positions.
- Page Up and Page Down (`KC_PGUP` and `KC_PGDN`) are located at `U` and `O` positions.
- Home and End (`KC_HOME` and `KC_END`) are located at the `H` and `N` positions.
- The Print Screen key is located at the `P` position.
- Insert and Scroll Lock (`KC_INS` and `KC_SCRL`) are located at the `[` and `]` positions.
- Delete (`KC_DEL`) is located at the `Backspace` position.
- Pause/Break is not implemented, as I have never found a use for that key.

### Settings Layer

The settings layer contains keyboard hardware functions, the ANSI and Mac mode toggles, and a couple of keys that do not fit conveniently into the Navigation Layer.

- Bootloader mode and EEPROM reset are located at `ESC` and `Backspace`.
- ANSI and Mac mode toggles are at `A` and `M`.
- NKRO, if available, is located at the `N` position.
- Caps Lock is available at its standard location.

#### RGB Key Locations

The established layout for RGB keys should be the same across boards, regardless of whether the board uses RGB Matrix or underglow as its implementation.

|Key	    |Function		    |Matrix		|Underglow	|Legacy Massdrop
|:---	    |:---			    |:---		|:---		|:---
|`R`	    |TOGGLE			    |RM_TOGG	|UG_TOGG	|RGB_TOG
|`T`	    |MODE_NEXT		    |RM_NEXT	|UG_NEXT	|RGB_MOD
|`Y`	    |HUE_UP			    |RM_HUEU	|UG_HUEU	|RGB_HUI
|`U`	    |SATURATION_UP	    |RM_SATU	|UG_SATU	|RGB_SAI
|`I`	    |VALUE_UP		    |RM_VALU	|UG_VALU	|RGB_VAI
|`O`	    |SPEED_UP		    |RM_SPDU	|UG_SPDU	|RGB_SPI
|`G`	    |MODE_PREV		    |RM_PREV	|UG_PREV	|RGB_RMOD
|`H`	    |HUE_DOWN		    |RM_HUED	|UG_HUED	|RGB_HUD
|`J`	    |SATURATION_DOWN	|RM_SATD	|UG_SATD	|RGB_SAD
|`K`	    |VALUE_DOWN		    |RM_VALD	|UG_VALD	|RGB_VAD
|`L`	    |SPEED_DOWN		    |RM_SPDD	|UG_SPDD	|RGB_SPD

There is no defined mapping for the following RGB matrix keycodes yet.

```
RM_FLGN = QK_RGB_MATRIX_FLAG_NEXT
RM_FLGP = QK_RGB_MATRIX_FLAG_PREVIOUS
```

### VIA Compatibility

VIA compatibility is enabled by default. VIA may be used for experimentation
and temporary remapping, but permanent keymap and configuration changes belong
in this userspace source.

## Firmware Archives

Retained firmware is stored under
`firmware/<keyboard>/<build-time>/`. Each archive includes build artifacts and
an `info.txt` file recording build metadata, including the QMK
userspace and QMK firmware revisions.

Building, flashing, and archiving may be automated with a separate project; that automation is not required to use or
maintain this userspace.
