# TODO

## Setup 

- [x] Create `firmware/` for version-controlled firmware artifacts.
- [ ] Create `scripts/archive-firmware.sh`.
- [ ] Define the firmware archive directory and naming convention.
- [ ] Have `archive-firmware.sh` copy and rename an already-compiled `.bin` or `.hex` file.
- [ ] Have `archive-firmware.sh` create `info.txt` containing:
	- Build date and time
	- Keyboard and keymap
	- Userspace repository, branch, and commit
	- QMK repository, branch, and commit
	- Firmware filename and size
	- SHA-256 checksum
- [ ] Keep firmware compilation in the existing QMK build workflow; `archive-firmware.sh` must not compile firmware.
- [x] Update `AGENTS.md` validation instructions to require archiving successful builds with `scripts/archive-firmware.sh`.
- [x] Remove the existing requirement to log build provenance in `docs/keyboards.md`.
- [ ] Commit archived firmware binaries and their corresponding `info.txt` files to version control.

## First test

### Older white DZ60 PCBs

- [ ] Update TODO.md with test plan for two older white DZ60-family PCBs.
- [ ] Note: The newer blue PCB is already positively identified as a DZ60 and recognized by VIA; do not include in test procedure.
- [ ] Document hardware specs: ATmega32U4, USB-C, solder PCB, multi-layout support, RGB underglow, conventional backlighting, factory USB ID: FEED:6060 (Manufacturer: dou, Product: DZ60).
- [ ] Clarify: VID:PID 6060 does not uniquely identify a DZ60 revision; focus is on whether vanilla QMK `dz60` target works on these boards.

### Test plan - older white DZ60s

- [ ] Use one white PCB as the test board.
- [ ] Verify that hardware reset reliably enters the ATmega32U4 bootloader.
- [ ] Investigate whether existing flash and EEPROM can be read and saved as backup.
- [ ] Build completely vanilla QMK firmware (`qmk compile -kb dz60 -km default`) without QMK Userspace config, VIA, or optional features.
- [ ] Flash vanilla firmware onto the test PCB.
- [ ] Test switch positions by shorting switch pads with tweezers (representative positions across the matrix, not exhaustively).
- [ ] Verify normal positions produce expected keys.
- [ ] Test representative alternate-layout positions.
- [ ] Separately verify RGB underglow and conventional backlighting.

### Resolution - if vanilla DZ60 works

- [ ] Treat both white PCBs as compatible with current QMK `dz60` target.
- [ ] Do not identify their historical PCB revision.
- [ ] Add `dz60` support to QMK Userspace.
- [ ] Adapt shared universal layout to DZ60 physical layout.
- [ ] Preserve ANSI/Mac mode arrangement.
- [ ] Preserve Caps-held navigation layer.
- [ ] Preserve settings layer.
- [ ] Do not create independent DZ60-specific layout design.

### Resolution - if vanilla DZ60 does not work

- [ ] Reset test PCB to ATmega32U4 bootloader.
- [ ] Investigate historical DZ60 hardware definitions or other plausible QMK targets.
- [ ] Do not manually trace matrix unless firmware-based identification fails.
