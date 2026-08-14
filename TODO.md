# TODO

## Setup 

- [x] Create `firmware/` for version-controlled firmware artifacts.
- [x] Create `build-archive.sh`.
- [x] Define the firmware archive directory and naming convention.
- [x] Have `archive-firmware.sh` move an already-compiled `.bin` or `.hex` file to firmware/<board>/<date> folder.
- [x] Have `archive-firmware.sh` create `info.txt` containing:
	- Build date and time
	- Keyboard and keymap
	- Userspace repository, branch, and commit
	- QMK repository, branch, and commit
	- Firmware filename and size
	- SHA-256 checksum
- [x] Update `AGENTS.md` validation instructions to require archiving successful builds with `build-archive.sh`.
- [x] Remove the existing requirement to log build provenance in `docs/keyboards.md`.
- [x] Commit archived firmware binaries and their corresponding `info.txt` files to version control.
- [ ] Containerize build environment

## First test

### Older white DZ60 PCBs

- [x] Update TODO.md with test plan for two older white DZ60-family PCBs.
- [x] Note: The newer blue PCB is already positively identified as a DZ60 and recognized by VIA; do not include in test procedure.
- [x] Document hardware specs: ATmega32U4, USB-C, solder PCB, multi-layout support, RGB underglow, conventional backlighting, factory USB ID: FEED:6060 (Manufacturer: dou, Product: DZ60).
- [x] Clarify: VID:PID 6060 does not uniquely identify a DZ60 revision; focus is on whether vanilla QMK `dz60` target works on these boards.

### Test plan - older white DZ60s

- [x] Use one white PCB as the test board.
- [x] Verify that hardware reset reliably enters the ATmega32U4 bootloader.
- [x] Build completely vanilla QMK firmware (`qmk compile -kb dz60 -km default`) without QMK Userspace config, VIA, or optional features.
- [x] Flash vanilla firmware onto the test PCB.
- [x] Test switch positions by shorting switch pads with tweezers (representative positions across the matrix, not exhaustively).
- [x] Verify normal positions produce expected keys.
- [x] Test representative alternate-layout positions.
- [ ] Separately verify RGB underglow and conventional backlighting.

### Resolution - if vanilla DZ60 works

- [ ] Treat both white PCBs as compatible with current QMK `dz60` target.
- [x] Do not identify their historical PCB revision.
- [x] Add `dz60` support to QMK Userspace.
- [x] Adapt shared universal layout to DZ60 physical layout.
- [x] Preserve ANSI/Mac mode arrangement.
- [x] Preserve Caps-held navigation layer.
- [x] Preserve settings layer.
- [x] Do not create independent DZ60-specific layout design.
