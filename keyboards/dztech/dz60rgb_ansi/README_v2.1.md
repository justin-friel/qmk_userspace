# DZTECH DZ60RGB_ANSI v2.1

Note for version v2.1 of the board only.

## Flashing Firmware

QMK has stated that using the QMK Toolbox to flash boards with the lufa-ms bootloader is unstable. In fact, the maintainers make a point of putting this warning in the build output:

```
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
LUFA MASS STORAGE Bootloader selected
DO NOT USE THIS BOOTLOADER IN NEW PROJECTS!
It is extremely prone to bricking, and is only included to support existing boards.
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
```

The most recent version as of the time of this writing is stored in the project in the [dz60rgb_ansi_flash_guide.pdf](./dz60rgb_ansi_flash_guide.pdf). One thing worth noting is that the firmware must be renamed FLASH.bin


