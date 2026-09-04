/* Copyright 2026 Justin Friel @justin-friel

 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */

#pragma once

#include "quantum.h"

enum layers {
	_ANSI,
	_MAC,
	_NAV,
	_SETTINGS
};

#ifndef MAC_LAYER
#	define MAC_LAYER _MAC
#endif

enum custom_keycodes {      // Action           ANSI        MAC
	OS_APP = SAFE_RANGE,    // Menu             KC_APP      Ctrl F2
	OS_PS,                  // Print Screen     KC_PSCR     Shift + 3 (Cmd + OS_PS = Cmd+Shift+4)
	OS_SA,					// Select All       Ctrl+A	    Command+A
	OS_CP,					// Copy             Ctrl+C	    Command+C
	OS_CT,					// Cut              Ctrl+X	    Command+X
	OS_P,					// Paste            Ctrl+V	    Command+V
	OS_UD,					// Undo             Ctrl+Z	    Command+Z
	OS_RD,					// Redo             Ctrl+Y	    Command+Shift+Z
	JUSTIN_SAFE_RANGE
};

#define M_NAV	    MO(_NAV)
#define M_SET	    MO(_SETTINGS)
#define T_ANSI	    TO(_ANSI)
#define T_MAC	    TO(_MAC)

bool process_record_user_justin(uint16_t keycode, keyrecord_t *record);
