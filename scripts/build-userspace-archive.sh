#!/usr/bin/env bash

set -Eeuo pipefail


usage() {
	printf 'Usage: %s -kb <keyboard> -km <keymap>\n' "$0" >&2
	printf '       %s -v -kb <keyboard> -km <keymap>\n' "$0" >&2
	exit 1
}


fail() {
	printf 'Error: %s\n' "$*" >&2
	exit 1
}


# Remove leading and trailing whitespace from a string.
trim() {
	local value="$1"

	value="${value#"${value%%[![:space:]]*}"}"
	value="${value%"${value##*[![:space:]]}"}"
	printf '%s' "$value"
}


# Verify that a path points to a Git working tree.
require_git_repo() {
	local repo_path="$1"
	local label="$2"

	if ! git -C "$repo_path" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
		fail "$label is not a Git repository: $repo_path"
	fi
}


# Require qmk_firmware to be completely clean before building.
require_clean_repo() {
	local repo_path="$1"
	local label="$2"
	local status

	status="$(git -C "$repo_path" status --porcelain --untracked-files=normal)"

	if [[ -n "$status" ]]; then
		printf '%s\n' "$status" >&2
		fail "$label has tracked or untracked changes: $repo_path"
	fi
}


# Require qmk_userspace source to be clean.
#
# Existing firmware archives are intentionally ignored because creating
# archives is normal operation for this repository.
require_clean_userspace_repo() {
	local repo_path="$1"
	local status

	status="$(git -C "$repo_path" status --porcelain --untracked-files=normal -- . ':(exclude)firmware/**')"

	if [[ -n "$status" ]]; then
		printf '%s\n' "$status" >&2
		fail "qmk_userspace has tracked or untracked source changes: $repo_path"
	fi
}


# Determine qmk_firmware from the QMK configuration rather than assuming
# a particular filesystem layout.
qmk_firmware_root() {
	local raw
	local path

	raw="$(qmk config user.qmk_home)"
	if [[ "$raw" != user.qmk_home=* ]]; then
		return 1
	fi

	path="${raw#user.qmk_home=}"
	path="${path% (config)}"
	path="$(trim "$path")"

	if [[ -z "$path" || "$path" == "None" ]]; then
		return 1
	fi

	printf '%s\n' "$path"
}


# Read one field from the human-readable output of `qmk info`.
qmk_info_value() {
	local info_output="$1"
	local field="$2"

	awk -v field="$field" '
		index($0, field ":") == 1 {
			sub("^[^:]*:[[:space:]]*", "", $0)
			print
			exit
		}
	' <<< "$info_output"
}


# Look for firmware filenames explicitly reported by QMK during the build.
#
# Modern userspace builds normally place the final .hex or .bin in the
# qmk_userspace repository root.
artifact_candidates_from_output() {
	local output_path="$1"
	local line
	local match
	local candidate

	while IFS= read -r line; do
		while [[ "$line" =~ ([^[:space:]\'\"]+\.(hex|bin)) ]]; do
			match="${BASH_REMATCH[1]}"
			line="${line#*"$match"}"

			if [[ "$match" == */* ]]; then
				candidate="$match"
			else
				candidate="${QMK_USERSPACE_ROOT}/${match##*/}"
			fi

			if [[ -f "$candidate" ]]; then
				printf '%s\n' "$(realpath "$candidate")"
			fi
		done
	done < "$output_path"
}


# Locate the firmware artifact produced by this build.
#
# Prefer a filename explicitly reported in the QMK output. If QMK does not
# report one, fall back to finding a newly-created .hex or .bin in the
# qmk_userspace root.
#
# Never guess if more than one candidate exists.
detect_firmware_path() {
	local output_path="$1"
	local marker_path="$2"
	local candidate
	local -a matches=()

	while IFS= read -r candidate; do
		matches+=("$candidate")
	done < <(artifact_candidates_from_output "$output_path" | sort -u)

	if (( ${#matches[@]} == 1 )); then
		printf '%s\n' "${matches[0]}"
		return 0
	fi

	if (( ${#matches[@]} > 1 )); then
		printf '%s\n' "${matches[@]}" >&2
		fail "Multiple firmware artifacts were referenced in QMK output; refusing to guess"
	fi

	while IFS= read -r candidate; do
		matches+=("$candidate")
	done < <(
		find "$QMK_USERSPACE_ROOT" \
			-maxdepth 1 \
			-type f \
			\( -name '*.hex' -o -name '*.bin' \) \
			-newer "$marker_path" \
			-print |
			sort
	)

	if (( ${#matches[@]} == 1 )); then
		printf '%s\n' "${matches[0]}"
		return 0
	fi

	if (( ${#matches[@]} > 1 )); then
		printf '%s\n' "${matches[@]}" >&2
		fail "Multiple firmware artifacts found in qmk_userspace root; refusing to guess"
	fi

	return 1
}


# Parse the keyboard, keymap, and optional verbose-build flag.
parse_arguments() {
	while [[ $# -gt 0 ]]; do
		case "$1" in
			-v)
				verbose=1
				shift
				;;
			-kb)
				[[ $# -ge 2 ]] || usage
				keyboard="$2"
				shift 2
				;;
			-km)
				[[ $# -ge 2 ]] || usage
				keymap="$2"
				shift 2
				;;
			*)
				printf 'Unknown argument: %s\n' "$1" >&2
				usage
				;;
		esac
	done

	if [[ -z "$keyboard" || -z "$keymap" ]]; then
		usage
	fi
}


# Locate qmk_userspace from this script and qmk_firmware from QMK's
# configured user.qmk_home.
find_repository_roots() {
	local script_dir

	script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

	QMK_USERSPACE_ROOT="$(git -C "$script_dir" rev-parse --show-toplevel 2>/dev/null || true)"
	if [[ -z "$QMK_USERSPACE_ROOT" ]]; then
		fail "Unable to determine qmk_userspace repository root from script location"
	fi

	QMK_FIRMWARE_ROOT="$(qmk_firmware_root || true)"
	if [[ -z "$QMK_FIRMWARE_ROOT" ]]; then
		fail "Unable to determine qmk_firmware location from qmk config user.qmk_home"
	fi
}


# Verify the repositories and build environment before compiling anything.
validate_environment() {
	if ! command -v qmk >/dev/null 2>&1; then
		fail "qmk is not installed or not on PATH"
	fi

	require_git_repo "$QMK_USERSPACE_ROOT" "qmk_userspace"
	require_git_repo "$QMK_FIRMWARE_ROOT" "qmk_firmware"

	require_clean_userspace_repo "$QMK_USERSPACE_ROOT"
	require_clean_repo "$QMK_FIRMWARE_ROOT" "qmk_firmware"
}


# Collect keyboard metadata from modern QMK.
#
# Unlike the historical Massdrop tree, current QMK exposes this metadata
# directly through `qmk info`.
read_keyboard_metadata() {
	QMK_INFO_OUTPUT="$(qmk --no-color info -kb "$keyboard" 2>&1)" || {
		printf '%s\n' "$QMK_INFO_OUTPUT" >&2
		fail "Unable to read QMK keyboard info for '$keyboard'"
	}

	KEYBOARD_NAME="$(qmk_info_value "$QMK_INFO_OUTPUT" "Keyboard Name")"
	KEYBOARD_MANUFACTURER="$(qmk_info_value "$QMK_INFO_OUTPUT" "Manufacturer")"
	KEYBOARD_MAINTAINER="$(qmk_info_value "$QMK_INFO_OUTPUT" "Maintainer")"
	KEYBOARD_PROCESSOR="$(qmk_info_value "$QMK_INFO_OUTPUT" "Processor")"
	KEYBOARD_BOOTLOADER="$(qmk_info_value "$QMK_INFO_OUTPUT" "Bootloader")"

	# Modern QMK should provide all of these fields. Refuse to create an
	# incomplete archive if required keyboard metadata is unexpectedly absent.
	if [[ -z "$KEYBOARD_NAME" ||
		  -z "$KEYBOARD_MANUFACTURER" ||
		  -z "$KEYBOARD_MAINTAINER" ||
		  -z "$KEYBOARD_PROCESSOR" ||
		  -z "$KEYBOARD_BOOTLOADER" ]]; then
		fail "QMK keyboard info for '$keyboard' is missing required metadata"
	fi
}


# Compile the requested userspace keymap and capture the complete build log.
#
# --no-color keeps the captured log suitable for plain-text info.txt without
# requiring a later ANSI escape-sequence cleanup step.
build_firmware() {
	BUILD_STARTED_EPOCH="$(date +%s)"
	BUILD_STARTED_ISO="$(date -d "@$BUILD_STARTED_EPOCH" +"%Y-%m-%dT%H:%M:%S%:z")"

	BUILD_OUTPUT_FILE="$(mktemp)"
	BUILD_MARKER_FILE="$(mktemp)"
	touch -d "@$BUILD_STARTED_EPOCH" "$BUILD_MARKER_FILE"

	if [[ "$verbose" -eq 1 ]]; then
		qmk_cmd=(qmk --no-color -v compile -kb "$keyboard" -km "$keymap")
	else
		qmk_cmd=(qmk --no-color compile -kb "$keyboard" -km "$keymap")
	fi

	if ! "${qmk_cmd[@]}" 2>&1 | tee "$BUILD_OUTPUT_FILE"; then
		fail "QMK compile failed for keyboard '$keyboard' keymap '$keymap'"
	fi

	BUILD_FINISHED_ISO="$(date +"%Y-%m-%dT%H:%M:%S%:z")"
}


# Identify the firmware file produced by the completed userspace build.
find_build_artifacts() {
	ARTIFACT_PATH="$(detect_firmware_path "$BUILD_OUTPUT_FILE" "$BUILD_MARKER_FILE" || true)"

	if [[ -z "$ARTIFACT_PATH" ]]; then
		fail "No firmware artifact found at qmk_userspace root after successful build"
	fi

	ARTIFACT_PATHS=(
		"$ARTIFACT_PATH"
	)
}


# Populate the shared archive-library inputs and archive this build.
archive_build() {
	ARCHIVE_USERSPACE_ROOT="$QMK_USERSPACE_ROOT"

	ARCHIVE_KEYBOARD="$keyboard"
	ARCHIVE_KEYMAP="$keymap"

	ARCHIVE_KEYBOARD_NAME="$KEYBOARD_NAME"
	ARCHIVE_MANUFACTURER="$KEYBOARD_MANUFACTURER"
	ARCHIVE_MAINTAINER="$KEYBOARD_MAINTAINER"
	ARCHIVE_PROCESSOR="$KEYBOARD_PROCESSOR"
	ARCHIVE_BOOTLOADER="$KEYBOARD_BOOTLOADER"

	ARCHIVE_BUILD_STARTED="$BUILD_STARTED_ISO"
	ARCHIVE_BUILD_FINISHED="$BUILD_FINISHED_ISO"
	ARCHIVE_BUILD_OUTPUT_FILE="$BUILD_OUTPUT_FILE"

	# Modern external-userspace builds depend on both repositories.
	ARCHIVE_USERSPACE_REPO="$QMK_USERSPACE_ROOT"
	ARCHIVE_FIRMWARE_REPO="$QMK_FIRMWARE_ROOT"

	ARCHIVE_ARTIFACT_PATHS=(
		"${ARTIFACT_PATHS[@]}"
	)

	archive_firmware
}


# Modern QMK places a convenience copy of the final firmware artifact in the
# qmk_userspace root. Once archival succeeds, remove that temporary build output
# so the root returns to its pre-build state.
cleanup_build_artifacts() {
	local artifact_path

	for artifact_path in "${ARTIFACT_PATHS[@]}"; do
		case "$artifact_path" in
			"$QMK_USERSPACE_ROOT"/*.hex|"$QMK_USERSPACE_ROOT"/*.bin)
				rm -f -- "$artifact_path"
				;;
		esac
	done
}


# Remove temporary build-log and timestamp-marker files.
cleanup() {
	if [[ -n "${BUILD_OUTPUT_FILE:-}" ]]; then
		rm -f "$BUILD_OUTPUT_FILE"
	fi

	if [[ -n "${BUILD_MARKER_FILE:-}" ]]; then
		rm -f "$BUILD_MARKER_FILE"
	fi
}


main() {
	keyboard=""
	keymap=""
	verbose=0

	QMK_USERSPACE_ROOT=""
	QMK_FIRMWARE_ROOT=""

	QMK_INFO_OUTPUT=""
	KEYBOARD_NAME=""
	KEYBOARD_MANUFACTURER=""
	KEYBOARD_MAINTAINER=""
	KEYBOARD_PROCESSOR=""
	KEYBOARD_BOOTLOADER=""

	BUILD_STARTED_EPOCH=""
	BUILD_STARTED_ISO=""
	BUILD_FINISHED_ISO=""
	BUILD_OUTPUT_FILE=""
	BUILD_MARKER_FILE=""

	ARTIFACT_PATH=""
	ARTIFACT_PATHS=()
	qmk_cmd=()

	parse_arguments "$@"
	find_repository_roots

	# Load the shared archive implementation only after locating qmk_userspace.
	source "$QMK_USERSPACE_ROOT/scripts/lib/archive-firmware.sh"

	trap cleanup EXIT

	validate_environment
	read_keyboard_metadata
	build_firmware
	find_build_artifacts
	archive_build
	cleanup_build_artifacts
}

main "$@"
