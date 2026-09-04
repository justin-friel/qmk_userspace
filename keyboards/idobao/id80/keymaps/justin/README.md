# Identifying ID80 versions

`lsusb` _should_ be able to distinguish v1 and v2 from v3

## v1 and v2
ID80 v1 and v2 ANSI share the VID:PID `6964:0080`. ID80 v2 ISO has the VID:PID `6964:0081`.  

Both share the same build target: `idobao/id80/v2`. 

The difference between the v1 and v2 is the v1 does not have backlit keys like the v2. USB identity alone will not separate them.
 
### v1
The ID80 v1 must be compiled with `make idobao/id80/v2/ansi:default BACKLIGHT_ENABLE=no` or `qmk compile -kb idobao/id80/v2 -km default -e BACKLIGHT_ENABLE=no` if you are using the modern `qmk` script.

That setting can also be put in `keyboards/idobao/id80/<version>/keymaps/<user>/rules.mk`
```
BACKLIGHT_ENABLE = no
```
### v2
The v2 does not need any special arguments.

## V3
ID80 v3's USB PID is `6964:0380`
V3 uses rgb_matrix.

*personal note: I have the v2 version of this keyboard.*
