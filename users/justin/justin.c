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

#include "justin.h"

static bool is_mac_mode(void);

bool process_record_user_justin(uint16_t keycode, keyrecord_t *record) {
	switch (keycode) {
		case OS_APP: {
			/*
			Alter Application/Menu key behavior.
				ANSI Windows/Linux:
					Application/Menu -> Normal Application/Menu key behavior.
				Mac:
					Application/Menu -> Control + F2 (move focus to the menu bar).
			*/
			static bool app_registered = false;

			if (record->event.pressed) {
				if (is_mac_mode()) {
					tap_code16(LCTL(KC_F2));
				} else {
					// Preserve normal key-down/key-up behavior outside macOS.
					register_code(KC_APP);
					app_registered = true;
				}
			} else if (app_registered) {
				unregister_code(KC_APP);
				app_registered = false;
			}
			return false;
		}
		case OS_PS: {
			/*
			Alter Print Screen key behavior.
				ANSI Windows/Linux:
					Print Screen -> Normal Print Screen behavior.
				Mac:
					Print Screen -> Command + Shift + 3 (capture entire screen).
					Command + Print Screen -> Command + Shift + 4 (select area to capture).
			*/
			static bool pscr_registered = false;

			if (record->event.pressed) {
				if (is_mac_mode()) {
					// Shortcut modifiers are weak modifiers, so a physically held
					// Command key remains held after tap_code16() completes.
					if (get_mods() & MOD_MASK_GUI) {
						tap_code16(LGUI(LSFT(KC_4)));
					} else {
						tap_code16(LGUI(LSFT(KC_3)));
					}
				} else {
					// Preserve normal key-down/key-up behavior outside macOS.
					register_code(KC_PSCR);
					pscr_registered = true;
				}
			} else if (pscr_registered) {
				unregister_code(KC_PSCR);
				pscr_registered = false;
			}
			return false;
		}
        case OS_SA:
            if (record->event.pressed) {
                tap_code16(is_mac_mode() ? LGUI(KC_A) : LCTL(KC_A));
            }
            return false;

        case OS_CP:
            if (record->event.pressed) {
                tap_code16(is_mac_mode() ? LGUI(KC_C) : LCTL(KC_C));
            }
            return false;

        case OS_CT:
            if (record->event.pressed) {
                tap_code16(is_mac_mode() ? LGUI(KC_X) : LCTL(KC_X));
            }
            return false;

        case OS_P:
            if (record->event.pressed) {
                tap_code16(is_mac_mode() ? LGUI(KC_V) : LCTL(KC_V));
            }
            return false;

        case OS_UD:
            if (record->event.pressed) {
                tap_code16(is_mac_mode() ? LGUI(KC_Z) : LCTL(KC_Z));
            }
            return false;

        case OS_RD:
            if (record->event.pressed) {
                tap_code16(is_mac_mode() ? LGUI(LSFT(KC_Z)) : LCTL(KC_Y));
            }
            return false;
		default:
			return true;
	}
}

/*
	Return true when the keyboard is operating in macOS mode.

	Different keyboards select the macOS layer in different ways:

		Using TO(_MAC):
	        _MAC is enabled through the normal QMK layer state.

	    Keychron:
	        The physical Win/Mac switch selects _MAC as the default layer,
	        so it appears in default_layer_state instead.

	Combine both QMK layer-state bitmasks so shared OS-aware keycodes work
	regardless of how the keyboard selected _MAC.
*/
static bool is_mac_mode(void) {
	/*
		1UL is an unsigned long with value 1. Shifting it by MAC_LAYER creates
		the bitmask for the layer configured as macOS mode.
	*/
	return ((layer_state | default_layer_state) & (1UL << MAC_LAYER)) != 0;
}
