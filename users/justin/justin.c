#include "justin.h"

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
				if (layer_state & (1UL << _MAC)) {
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
				if (layer_state & (1UL << _MAC)) {
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

		default:
			return true;
	}
}
