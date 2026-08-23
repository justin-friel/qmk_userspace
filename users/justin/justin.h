#pragma once

#include "quantum.h"

enum layers {
	_ANSI,
	_MAC,
	_NAV,
	_SETTINGS
};

enum custom_keycodes {
	OS_APP = SAFE_RANGE,
	OS_PS,
	JUSTIN_SAFE_RANGE
};

bool process_record_user_justin(uint16_t keycode, keyrecord_t *record);
