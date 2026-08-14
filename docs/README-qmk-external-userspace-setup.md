# QMK External Userspace Setup

These instructions configure an existing QMK firmware checkout to use an external QMK Userspace repository.

See the official documentation for [Setting Up Your QMK Environment](https://docs.qmk.fm/newbs_getting_started) and [External QMK Userspace](https://docs.qmk.fm/newbs_external_userspace) for more information.

Path examples use `$HOME` when showing commands or filesystem locations.

When showing example program output, absolute paths use `/home/<user>/...` because QMK prints expanded filesystem paths rather than shell variables.

The expected directory structure is:

```text
$HOME/src/qmk/
├── qmk_distribution/
├── qmk_firmware/
└── qmk_userspace/
```

- `qmk_firmware` is the QMK firmware Git repository.
- `qmk_userspace` contains personal keymaps, layouts, shared configuration, and archived firmware.
- `qmk_distribution` contains the toolchains and supporting environment managed by the QMK environment bootstrap installer.

The repositories remain separate. QMK combines the firmware repository and userspace overlay at build time.

## 1. Verify the QMK CLI

Check which `qmk` executable is being used:

```bash
type -a qmk
```

With the bootstrap installation used here, the executable is:

```text
/home/<user>/.local/bin/qmk
```

Check the installed CLI version:

```bash
qmk --version
```

## 2. Configure the QMK Firmware Repository

Tell the QMK CLI where the existing `qmk_firmware` checkout is located:

```bash
qmk config user.qmk_home="$HOME/src/qmk/qmk_firmware"
```

This is important when using an existing QMK repository rather than allowing `qmk setup` to create a new checkout.

`user.qmk_home` identifies the QMK firmware source tree and allows the CLI to load the commands and build infrastructure supplied by `qmk_firmware`.

## 3. Configure the External Userspace Repository

Tell QMK where the External Userspace repository is located:

```bash
qmk config user.overlay_dir="$HOME/src/qmk/qmk_userspace"
```

`user.overlay_dir` identifies the External Userspace that QMK overlays onto the firmware source tree during builds.

## 4. Verify the Configuration

Display the current QMK CLI configuration:

```bash
qmk config
```

The important settings should point to the intended repositories, for example:

```text
user.qmk_home=/home/<user>/src/qmk/qmk_firmware
user.overlay_dir=/home/<user>/src/qmk/qmk_userspace
```

These settings have different purposes:

```text
user.qmk_home
	QMK firmware source and build system

user.overlay_dir
	Personal External QMK Userspace
```

`qmk.json` does not establish the connection between these repositories. The QMK CLI configuration does.

## 5. Verify External Userspace

Run:

```bash
qmk userspace-doctor
```

A working configuration should produce output similar to:

```text
Ψ QMK home: /home/<user>/src/qmk/qmk_firmware
Ψ Testing userspace candidate: /home/<user>/src/qmk/qmk_userspace -- Valid `qmk.json`
Ψ QMK userspace: /home/<user>/src/qmk/qmk_userspace
Ψ Userspace enabled: True
```

Verify that:

- `QMK home` points to the intended `qmk_firmware` checkout.
- `QMK userspace` points to the intended `qmk_userspace` checkout.
- `qmk.json` is valid.
- `Userspace enabled` is `True`.

### Troubleshooting

#### Only Basic QMK Commands Are Available

If a command such as:

```bash
qmk userspace-doctor
```

fails with an error showing that the only available commands are:

```text
config
clone
console
env
setup
```

check the QMK configuration:

```bash
qmk config
```

If `user.qmk_home` is missing, configure the existing firmware checkout:

```bash
qmk config user.qmk_home="$HOME/src/qmk/qmk_firmware"
```

Then verify that the firmware-integrated commands are available:

```bash
qmk userspace-doctor
```

The standalone QMK CLI provides only a small set of commands itself. Additional commands such as compilation and External Userspace support are loaded from the configured `qmk_firmware` checkout.

#### Wrong QMK Executable

If QMK behaves unexpectedly, determine which executable the shell is finding:

```bash
type -a qmk
```

Then check its version:

```bash
qmk --version
```

This helps identify an older or otherwise unintended QMK CLI earlier in `PATH`.

### Final Verification

A correctly configured system should satisfy all of the following:

```text
qmk_firmware:
	$HOME/src/qmk/qmk_firmware

qmk_userspace:
	$HOME/src/qmk/qmk_userspace

QMK configuration:
	user.qmk_home points to qmk_firmware
	user.overlay_dir points to qmk_userspace

qmk userspace-doctor:
	Valid qmk.json
	Correct userspace path
	Userspace enabled: True
```

Once these checks pass, QMK External Userspace is ready for keymaps, layouts, and shared userspace configuration.

## 6. Understand the Overlay

QMK does not copy userspace source files into `qmk_firmware`.

For example, the firmware repository may contain:

```text
qmk_firmware/
└── keyboards/
	└── dz60/
		├── keyboard.json
		├── dz60.c
		└── keymaps/
			└── default/
				└── keymap.c
```

while the userspace repository may contain:

```text
qmk_userspace/
└── keyboards/
	└── dz60/
		└── keymaps/
			└── justin/
				└── keymap.c
```

QMK can use the keyboard definition from `qmk_firmware` and the personal keymap from `qmk_userspace` in the same build.

The normal QMK build command remains:

```bash
qmk compile -kb dz60 -km justin
```

External Userspace does not introduce a second build system.

## 7. Understand Layouts

QMK separates a keyboard's electrical matrix from its physical key arrangements.

A keyboard definition can expose one or more layout macros in its `keyboard.json`. For example, the DZ60 exposes layouts including:

```text
LAYOUT_60_ansi
LAYOUT_60_ansi_split
LAYOUT_60_ansi_split_bs_rshift
LAYOUT_60_ansi_split_space_rshift
LAYOUT_60_iso
LAYOUT_60_hhkb
LAYOUT_all
```

A keymap selects one of these macros to describe which physical key positions it uses.

For example:

```c
const uint16_t PROGMEM keymaps[][MATRIX_ROWS][MATRIX_COLS] = {
	[0] = LAYOUT_60_ansi(
		/* keycodes */
	)
};
```

The layout macro translates those physical key positions into the keyboard's electrical matrix positions.

### Keyboard Layout Macros vs. Shared Userspace Layouts

There are two related concepts that should not be confused.

The layouts defined by a keyboard's `keyboard.json` describe physical arrangements supported by that particular keyboard:

```text
qmk_firmware/keyboards/<keyboard>/keyboard.json
```

External Userspace can also contain shared layouts:

```text
qmk_userspace/
└── layouts/
```

A shared userspace layout allows one keymap to be reused across multiple keyboards that expose a compatible standard layout.

For example, several TKL keyboards may have completely different:

```text
controllers
PCBs
matrices
row/column wiring
```

while still exposing the same standard physical TKL layout.

Those keyboards can potentially share one keymap under `layouts/`. Each keyboard's own firmware definition remains responsible for translating that common physical layout into its own electrical matrix.

Conceptually:

```text
TKL A matrix ─┐
TKL B matrix ─┼── common physical layout ── shared keymap
TKL C matrix ─┘
```

Therefore, `layouts/` does not define new physical capabilities for a keyboard. The keyboard definition must already provide a compatible layout.

Use:

```text
layouts/
	Shared keymaps for compatible physical layouts.

keyboards/
	Board-specific keymaps.
```

Do not force a keyboard into a shared layout merely to eliminate a small amount of duplication.

### DZ60 Example

The DZ60 PCB supports many physical arrangements.

The desired layout for this userspace is standard ANSI with:

- normal 2u Backspace
- split Right Shift

The current DZ60 definition does not expose a layout macro for exactly this combination.

The closest existing macro is:

```text
LAYOUT_60_ansi_split_bs_rshift
```

This provides both split Backspace and split Right Shift.

The physical DZ60 PCB has been electrically verified to connect the normal 2u Backspace position to the matrix position used by the right-hand key of the split Backspace arrangement.

Therefore, the existing layout can be used by assigning `KC_NO` to the unused split-Backspace position and `KC_BSPC` to the position corresponding to the physical 2u Backspace:

```c
KC_NO, KC_BSPC
```

This allows userspace development to proceed without immediately modifying the DZ60 keyboard definition in `qmk_firmware`.

A dedicated layout such as:

```text
LAYOUT_60_ansi_split_rshift
```

may be added to the DZ60 definition later so that the QMK layout macro accurately describes the physical layout.

This is a useful example of the boundary between the repositories:

```text
qmk_firmware
	Defines the keyboard hardware and supported physical layouts.

qmk_userspace
	Defines what those physical keys should do.
```

Do not modify a keyboard hardware definition merely to share key behavior. Conversely, do not use userspace layouts to compensate for missing or incorrect hardware definitions when a proper keyboard layout definition is warranted.

## 8. Understand the `users/` Folder

The `users/` folder contains configuration and behavior that can be shared by multiple keymaps.

A user directory is associated with keymaps having the same name. For example:

```text
qmk_userspace/
├── keyboards/
│	├── dz60/
│	│	└── keymaps/
│	│		└── justin/
│	│			└── keymap.c
│	└── another_keyboard/
│		└── keymaps/
│			└── justin/
│				└── keymap.c
└── users/
	└── justin/
```

When QMK builds a keymap named `justin`, the corresponding `users/justin/` directory can provide shared configuration and behavior.

For example:

```bash
qmk compile -kb dz60 -km justin
```

can use both:

```text
keyboards/dz60/keymaps/justin/
users/justin/
```

This allows individual keyboard keymaps to remain thin while common behavior is implemented once.

### User Files

A user directory can contain files such as:

```text
users/
└── justin/
	├── config.h
	├── rules.mk
	├── justin.c
	└── justin.h
```

These files serve different purposes:

```text
config.h
	Shared compile-time configuration.

rules.mk
	Shared QMK build configuration and feature selection.

justin.c
	Shared C behavior and implementation.

justin.h
	Shared declarations, custom keycodes, and interfaces.
```

These files should not be created merely because QMK supports them. Add each file only when there is configuration or behavior that genuinely belongs there.

### Shared Configuration

Configuration should only be placed in `users/justin/config.h` when it is genuinely common to the keyboards using that userspace.

Do not use the shared `config.h` as a collection of defaults that individual keyboards routinely override.

Doing so leads to configuration such as:

```c
#ifdef SOME_SETTING
#	undef SOME_SETTING
#endif
#define SOME_SETTING new_value
```

or keyboard-specific conditionals in shared userspace:

```c
#ifdef KEYBOARD_some_keyboard
	/* keyboard-specific configuration */
#endif
```

Frequent exceptions are a sign that the setting is not actually universal and should remain with the individual keyboard or keymap.

The preferred rule is:

```text
users/justin/config.h
	Configuration that is genuinely shared.

keyboard/keymap config.h
	Configuration specific to that keyboard or keymap.
```

Avoid relying on preprocessor include order to resolve conflicting definitions.

### `rules.mk`

A user `rules.mk` can provide shared build configuration or enable QMK features used by all corresponding keymaps.

For example, VIA is intended to be available on all standardized keyboards, so it is enabled once in:

```text
users/justin/rules.mk
```

with:

```make
VIA_ENABLE = yes
```

This makes VIA a shared userspace build feature rather than repeating the setting in every keyboard keymap.

QMK processes the keymap `rules.mk` before the user `rules.mk`. Therefore, ordinary Make variable assignments in the user `rules.mk` can override assignments made earlier by the keymap.

Do not depend heavily on this precedence. Shared `rules.mk` settings should represent genuinely shared build requirements rather than a mechanism for overriding individual keymaps.

### Shared C Code

Files such as `justin.c` and `justin.h` are appropriate for behavior that needs to be reused across keyboards.

Examples may eventually include:

- shared custom keycodes
- common key-processing behavior
- common QMK callbacks
- reusable helper functions

Use C for behavior rather than attempting to force behavioral logic into declarative configuration.

The project convention is:

> Use JSON for static data. Use C for behavior. Don't try to make everything declarative.

### Keep Shared Userspace Small

Do not move code into `users/justin/` merely because more than one keyboard happens to contain similar code.

First determine whether QMK already provides a standard mechanism for sharing the requirement.

In particular:

```text
layouts/
	Share a keymap across compatible physical layouts.

users/justin/
	Share behavior and configuration across keymaps.
```

Promote something into `users/justin/` only when it is genuinely common behavior or configuration.

If shared code accumulates many keyboard-specific conditionals or exceptions, reconsider whether that code actually belongs in shared userspace.

## 9. Understand the `keyboards/` Folder

The `keyboards/` folder works much like traditional in-tree QMK keymaps.

An in-tree keymap such as:

```text
qmk_firmware/keyboards/dz60/keymaps/justin/
```

can instead live in External Userspace:

```text
qmk_userspace/keyboards/dz60/keymaps/justin/
```

QMK uses the keyboard hardware definition from `qmk_firmware` and overlays the personal keymap from `qmk_userspace`.

The normal build command remains unchanged:

```bash
qmk compile -kb dz60 -km justin
```

The userspace `keyboards/` directory should contain the personal keymap and any configuration specific to that keyboard or keymap. It should not contain copies of the keyboard's hardware definitions, matrix configuration, or drivers merely to customize a keymap.

The directory hierarchy follows the actual QMK keyboard target. For example:

```text
keychron/q1/ansi
```

would correspond to:

```text
qmk_userspace/keyboards/keychron/q1/ansi/keymaps/justin/
```

A keymap directory may contain the same familiar files as an in-tree QMK keymap:

```text
keymap.c
config.h
rules.mk
```

Only add `config.h`, `rules.mk`, or other files when the particular keyboard actually requires them.

For an existing QMK user, `keyboards/` requires little change in workflow. The main difference is that personal keymaps live in the external `qmk_userspace` repository instead of inside `qmk_firmware`.

## 10. Add Build Targets

External Userspace can maintain a list of keyboard/keymap combinations that belong to the userspace.

These targets are stored in the root `qmk.json` file:

```json
{
	"userspace_version": "1.0",
	"build_targets": [
		["dz60", "justin"]
	]
}
```

Rather than editing this list manually, add a target with:

```bash
qmk userspace-add -kb dz60 -km justin
```

The target can be verified with:

```bash
qmk userspace-list
```

There are two useful ways to compile an External Userspace keymap.

To compile a specific keyboard and keymap explicitly:

```bash
qmk compile -kb dz60 -km justin
```

This does not depend on the target being present in `build_targets`.

To compile the targets registered in `qmk.json`:

```bash
qmk userspace-compile
```

For example:

```text
Ψ Preparing target list...
Build dz60:justin                                                      [OK]
```

As additional keyboards are standardized, they can be added to `build_targets`.

`qmk.json` therefore describes which keyboard/keymap combinations belong to the External Userspace build set. It does not replace QMK's normal build system.

## 11. Use Shared Build Configuration

Files under:

```text
users/justin/
```

can provide configuration shared by the `justin` keymaps.

VIA is intended to be available on all standardized keyboards. Instead of adding the same setting to every keyboard-specific `rules.mk`, it is enabled once in:

```text
users/justin/rules.mk
```

with:

```make
VIA_ENABLE = yes
```

A verbose DZ60 build confirmed that the shared setting was applied. The compiler configuration included:

```text
-DVIA_ENABLE
-DDYNAMIC_KEYMAP_ENABLE
```

and the VIA implementation was compiled:

```text
Compiling: quantum/via.c
Compiling: quantum/nvm/eeprom/nvm_via.c
```

VIA remains an interface for experimentation and dynamic remapping. The userspace source files remain the authoritative keyboard configuration.

## 12. Configure the QMK Managed Toolchain

The QMK environment bootstrap installer places its managed toolchains in the configured QMK distribution directory.

For this setup:

```text
$HOME/src/qmk/qmk_distribution
```

The location should be made available to QMK through the `QMK_DISTRIB_DIR` environment variable.

For Bash, add this to `~/.bashrc`:

```bash
export QMK_DISTRIB_DIR="$HOME/src/qmk/qmk_distribution"
```

Then reload the shell configuration:

```bash
source ~/.bashrc
```

With `QMK_DISTRIB_DIR` configured, QMK can locate and use the toolchains managed by its distribution.

For example, the DZ60 build uses QMK's managed AVR compiler:

```text
avr-gcc (crosstool-NG ... qmk/qmk_toolchains ...) 15.2.0
```

It is not necessary to add:

```text
$QMK_DISTRIB_DIR/bin
```

to the normal interactive shell `PATH`.

This keeps QMK-specific compilers and utilities out of the general shell environment while still allowing QMK builds to use them.

If the distribution directory is not configured correctly, an AVR build may fail with an error such as:

```text
sh: 1: avr-gcc: not found
gmake: *** [builddefs/common_rules.mk:221: gccversion] Error 127
```

The compiler may still exist at:

```text
$HOME/src/qmk/qmk_distribution/bin/avr-gcc
```

In that situation, configure `QMK_DISTRIB_DIR` rather than installing another AVR toolchain.

### Missing QMK Submodules

A QMK firmware checkout also requires its Git submodules.

For example, an ATmega32U4 build may fail with:

```text
tmk_core/protocol/lufa/lufa.mk:13: lib/lufa/LUFA/makefile: No such file or directory
gmake: *** No rule to make target 'lib/lufa/LUFA/makefile'. Stop.
```

This indicates that the LUFA submodule required by the AVR USB implementation is missing.

From the QMK firmware repository, initialize or update the QMK submodules with:

```bash
cd "$HOME/src/qmk/qmk_firmware" && qmk git-submodule
```

After the submodules and managed toolchain are available, the External Userspace build can be retried normally.

## 13. Maintain Standard and Vendor QMK Branches

A single local `qmk_firmware` repository is used for upstream QMK and vendor forks.

Separate clones are not required.

The configured remotes are:

```text
origin
	Personal GitHub fork of standard QMK

massdrop
	Massdrop QMK fork

keychron
	Keychron QMK fork
```

Inspect them with:

```bash
git remote -v
```

Current remote URLs are:

```text
origin     https://github.com/<github-user>/qmk_firmware.git
massdrop   https://github.com/Massdrop/qmk_firmware.git
keychron   https://github.com/Keychron/qmk_firmware.git
```

Fetch vendor code without changing the currently checked-out branch:

```bash
git fetch massdrop --prune && git fetch keychron --prune
```

Use `fetch`, not `pull`, when retrieving vendor code. `pull` also attempts to merge retrieved code into the currently checked-out branch.

The current local firmware branches are:

```text
master
massdrop-master
keychron-k2-he
keychron-k10-pro
justin-userspace
```

Vendor-derived branches currently originate from:

```text
massdrop-master
	massdrop/master

keychron-k2-he
	keychron/2025q3

keychron-k10-pro
	keychron/wls_2025q1
```

Switching `qmk_firmware` branches changes the QMK implementation and hardware definitions used when External Userspace builds a keymap.

Before switching branches:

```bash
git status
```

Then select the required firmware branch:

```bash
git checkout master
```

or, for example:

```bash
git checkout massdrop-master
```

Vendor-derived local branches should be pushed to the personal `origin` repository, not back to the vendor repository.

For example:

```bash
git push -u origin massdrop-master && git push -u origin keychron-k2-he
```

This allows External Userspace to remain the personal configuration layer while different keyboards use the appropriate upstream or vendor QMK source tree.

## 14. Build and Archive Firmware

Normal QMK compilation remains available:

```bash
qmk compile -kb dz60 -km justin
```

However, firmware intended to be retained or flashed should normally be built with:

```bash
./build-archive.sh -kb dz60 -km justin
```

For verbose QMK output:

```bash
./build-archive.sh -v -kb dz60 -km justin
```

`build-archive.sh` is a thin wrapper around QMK compilation. QMK remains responsible for the actual build.

The wrapper:

- verifies the source repositories before building
- determines `qmk_userspace` from its own Git repository
- determines `qmk_firmware` from `qmk config user.qmk_home`
- records the exact `qmk_userspace` Git branch and commit
- records the exact `qmk_firmware` Git branch and commit
- obtains keyboard information from `qmk info -kb`
- records the exact build start and finish time
- invokes `qmk compile`
- displays QMK output normally during the build
- captures the QMK build output
- strips terminal escape sequences from the stored copy
- identifies the resulting `.hex` or `.bin`
- moves the userspace-root build artifact into the firmware archive
- records the file size and SHA-256 digest
- stores the complete build output in `info.txt`

The archive structure is:

```text
firmware/
└── {keyboard}/
	└── {ISO-like timestamp}/
		├── info.txt
		└── firmware.hex-or-bin
```

For example:

```text
firmware/
└── dz60/
	└── 2026-08-13T23-50-58-0500/
		├── info.txt
		└── dz60_justin.hex
```

The directory timestamp uses a filesystem-safe ISO-8601-like format including seconds and timezone.

The metadata inside `info.txt` uses normal ISO 8601 timestamps.

A typical archive records:

```text
Keyboard: dz60
Keyboard Name: DZ60
Manufacturer: KBDFans
Maintainer: QMK Community
Processor: atmega32u4
Bootloader: atmel-dfu
Keymap: justin

Build started: ...
Build finished: ...

Firmware:
	Filename: dz60_justin.hex
	File size: ...
	SHA-256: ...

qmk_userspace:
	Repository: ...
	Branch: ...
	Commit: ...

qmk_firmware:
	Repository: ...
	Branch: ...
	Commit: ...

Build output:
	...
```

The captured QMK output also preserves QMK's own firmware-size calculation, for example:

```text
The firmware size is fine - 25602/28672 (89%, 3070 bytes free)
```

The archive script intentionally does not reimplement QMK's firmware-size calculation.

### Source Cleanliness

The source used to produce an archived firmware build must be identifiable by Git.

Changes to userspace source files or `qmk_firmware` therefore prevent an archived build until those changes are committed.

Existing firmware archives under:

```text
firmware/
```

do not count as dirty userspace source and do not need to be committed before another build.

This permits firmware archives to remain local if desired while still ensuring that each archived binary refers to identifiable source revisions.

### Generated Root Firmware

QMK normally copies generated firmware to the root of both `qmk_firmware` and `qmk_userspace`.

The root-level userspace artifacts are generated files and are ignored by Git:

```gitignore
/*.hex
/*.bin
```

After a successful archived build, `build-archive.sh` moves the userspace-root artifact into the appropriate `firmware/` archive directory.

The copies inside:

```text
qmk_firmware/
qmk_firmware/.build/
```

are left alone.

## 15. Reading Layout Geometry in `keyboard.json`

A layout entry in `keyboard.json` connects a physical key position with an electrical matrix position.

For example, an extracted layout entry may appear as:

```text
4,10	x=10	y=4	w=1.25
```

This represents two different coordinate systems.

The first pair:

```text
4,10
```

is the electrical matrix coordinate:

```text
row = 4
column = 10
```

QMK sees a switch assigned to this position as matrix location:

```text
[4][10]
```

The remaining values describe physical keyboard geometry:

```text
x=10
y=4
w=1.25
```

They mean:

```text
x
	Horizontal physical position in keyboard units.

y
	Vertical physical position in keyboard units.

w
	Physical key width in keyboard units.
```

Therefore:

```text
4,10	x=10	y=4	w=1.25
```

means:

```text
Electrical position:
	matrix row 4, column 10

Physical position:
	x = 10u
	y = 4u
	width = 1.25u
```

For example, part of the DZ60 ANSI bottom row is:

```text
4,6	x=3.75	y=4	w=6.25
4,10	x=10	y=4	w=1.25
4,11	x=11.25	y=4	w=1.25
4,13	x=12.5	y=4	w=1.25
4,14	x=13.75	y=4	w=1.25
```

This describes a 6.25u Spacebar followed by four 1.25u modifier positions.

Notice that the matrix coordinates are not required to be consecutive:

```text
4,11
4,13
```

Matrix position `[4][12]` is simply not used by this particular layout.

The electrical matrix and physical geometry are separate concepts. Matrix row and column numbers should not be interpreted as physical keyboard coordinates.

### Layouts on Multi-Layout PCBs

A PCB such as the DZ60 contains switch footprints for many possible physical layouts.

A single layout definition does not describe every footprint available on the PCB. Instead, it describes the positions used by that particular supported layout and maps those positions to the keyboard's electrical matrix.

For example:

```text
LAYOUT_60_ansi_split_bs_rshift
```

describes the physical positions used for that particular ANSI configuration.

Other DZ60 layout definitions may expose different switch positions for split Spacebars, different bottom rows, ISO layouts, alternate Shift arrangements, or other supported configurations.

Some alternative physical switch footprints may share the same electrical matrix position. If two footprints are wired to the same matrix row and column, QMK cannot distinguish between them electrically; they are alternate physical placements of the same logical matrix position.

Other alternate footprints may use different matrix positions.

For that reason:

```text
keyboard.json
	Defines the layouts QMK supports and maps their physical positions
	to electrical matrix positions.

PCB construction
	Determines which physical switch footprints actually exist.

Assembled keyboard
	Determines which of those footprints are populated with switches.
```

When necessary, electrical testing of an unsoldered PCB can confirm which matrix position corresponds to a particular physical switch footprint.

### Inspect a Layout

QMK can render the physical shape of a supported layout:

```bash
qmk info -kb dz60 -l
```

The underlying layout data can also be inspected directly from `keyboard.json`.

For example:

```bash
jq -r '.layouts.LAYOUT_60_ansi_split_bs_rshift.layout[] | "\(.matrix | join(","))\tx=\(.x)\ty=\(.y)\tw=\(.w // 1)"' "$HOME/src/qmk/qmk_firmware/keyboards/dz60/keyboard.json"
```

This produces a compact representation showing:

```text
matrix coordinate	physical x	physical y	width
```

while preserving the order of the layout entries.

This is useful when creating or adapting a keymap because it shows both the physical layout and the matrix positions represented by the selected QMK layout macro.

## 16. Working Model

The final separation of responsibilities is:

```text
qmk_firmware
	QMK implementation, keyboard hardware definitions, and vendor branches.

qmk_userspace source
	Authoritative personal keymaps, shared layouts, behavior, and configuration.

VIA
	Experimentation and temporary dynamic remapping.

firmware/
	Archived build artifacts with source provenance and QMK build output.
```

VIA configuration is not the source of truth.

Changes intended to become permanent should be represented in userspace source, compiled with QMK, and archived when a firmware build is worth retaining.