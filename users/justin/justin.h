#pragma once

#include "quantum.h"

enum layers {
	_ANSI,
	_MAC,
	_NAV,
	_SETTINGS
};

// TODO: Move this enum to keyboards/keychron/q4/ansi/keymaps/justin/justin.hß
/*
The Keychron Q4 will not build without this.
enum layers_keychron {
	MAC_BASE,
	WIN_BASE,
	NAV_FN,
	SET_FN,
	OTHER_FN
};
*/

#ifndef MAC_LAYER
#	define MAC_LAYER _MAC
#endif

enum custom_keycodes {
	OS_APP = SAFE_RANGE,
	OS_PS,
	JUSTIN_SAFE_RANGE
};

bool process_record_user_justin(uint16_t keycode, keyrecord_t *record);
