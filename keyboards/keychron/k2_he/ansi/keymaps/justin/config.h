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

#ifdef MAC_LAYER
#	undef MAC_LAYER
#endif

#define MAC_LAYER 0

#ifdef DYNAMIC_KEYMAP_LAYER_COUNT
#	undef DYNAMIC_KEYMAP_LAYER_COUNT
#endif

#define DYNAMIC_KEYMAP_LAYER_COUNT 5
