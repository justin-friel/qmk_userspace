# QMK Standardization

## Purpose

This repository standardizes QMK configuration across a large collection of keyboards.

The universal layout is the source of truth. Individual keyboard keymaps adapt the
universal layout to physical layouts and hardware capabilities.

Read these documents before making architectural changes:

* `README.md`
* `docs/keyboards.md`

## Design principles

* Prefer one shared implementation over duplicated keymaps.
* Keep board-specific files thin.
* Support ANSI/Windows/Linux and macOS modes.
* Preserve the Caps-held (MO) navigation layer across boards.
* VIA shall be available for experimentation, but VIA configuration is not authoritative.
* Prefer solving problems with layers and existing QMK features before introducing custom code.
* Avoid unnecessary QMK features.
* Keep ATmega flash and RAM usage in mind.
* Favor maintainability over cleverness.
* Use the repository scripts rather than inventing new build commands when scripts exist.

## Working style

* Review the existing design before changing code.
* Do not implement code changes without consent.
* Challenge assumptions and identify tradeoffs.
* Do not silently redesign the universal layout.
* Present architectural changes for review before broad implementation.
* Make the smallest maintainable change.
* Use tabs for indentation in C, Makefiles, and shell scripts where appropriate.
* Do not treat VIA-generated output as source code.

## Validation

For every affected keyboard:

1. Compile the keymap. 
2. Report firmware size.
3. Report any warnings.
4. Do not flash hardware unless explicitly requested.
5. Save the resulting firmware binary under `firmware/{keyboard-name}/{build-id}/`.
6. Alongside the firmware binary, create `info.txt` containing:
   * Keyboard and keymap.
   * Build date and time.
   * Userspace repository, branch, and commit.
   * QMK firmware repository, branch, and commit.
   * Firmware filename and size.
   * SHA-256 checksum of the firmware binary.

