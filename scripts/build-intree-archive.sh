#!/usr/bin/env bash

set -Eeuo pipefail

usage() {
	printf 'Usage: %s -kb <keyboard> -km <keymap>\n' "$0" >&2
	exit 1
}

fail() {
	printf 'Error: %s\n' "$*" >&2
	exit 1
}

require_git_repo() {
	local repo_path="$1"
	local label="$2"

	if ! git -C "$repo_path" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
		fail "$label is not a Git repository: $repo_path"
	fi
}

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

require_clean_userspace_repo() {
	local repo_path="$1"
	local status

	# Firmware archives are expected to create changes under firmware/.
	status="$(git -C "$repo_path" status --porcelain --untracked-files=normal -- . ':(exclude)firmware/**')"

	if [[ -n "$status" ]]; then
		printf '%s\n' "$status" >&2
		fail "qmk_userspace has tracked or untracked source changes: $repo_path"
	fi
}

parse_arguments() {
	while [[ $# -gt 0 ]]; do
		case "$1" in
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

find_repository_roots() {
	local script_dir

	script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

	QMK_USERSPACE_ROOT="$(git -C "$script_dir" rev-parse --show-toplevel 2>/dev/null || true)"
	if [[ -z "$QMK_USERSPACE_ROOT" ]]; then
		fail "Unable to determine qmk_userspace repository root from script location"
	fi

	QMK_ROOT="$(dirname "$QMK_USERSPACE_ROOT")"
	QMK_FIRMWARE_ROOT="${QMK_ROOT}/qmk_firmware"
	QMK_INFRA_ROOT="${QMK_ROOT}/qmk_git_infrastructure"

	RUN_CONTAINER="${QMK_INFRA_ROOT}/scripts/run-qmk-container.sh"
}

validate_environment() {
	require_git_repo "$QMK_USERSPACE_ROOT" "qmk_userspace"
	require_git_repo "$QMK_FIRMWARE_ROOT" "qmk_firmware"

	require_clean_userspace_repo "$QMK_USERSPACE_ROOT"

	# The Massdrop tree can contain known untracked residue from switching
	# between modern QMK and the historical vendor branch. Do not require a
	# completely clean qmk_firmware working tree here.
	#
	# Tracked source changes should still prevent archival.
	local tracked_status
	tracked_status="$(git -C "$QMK_FIRMWARE_ROOT" status --porcelain --untracked-files=no)"

	if [[ -n "$tracked_status" ]]; then
		printf '%s\n' "$tracked_status" >&2
		fail "qmk_firmware has tracked changes: $QMK_FIRMWARE_ROOT"
	fi

	if [[ ! -x "$RUN_CONTAINER" ]]; then
		fail "Container wrapper is missing or not executable: $RUN_CONTAINER"
	fi
}

artifact_prefix() {
	local keyboard_name="$1"
	local keymap_name="$2"
	local prefix

	prefix="${keyboard_name//\//_}_${keymap_name}"
	printf '%s' "$prefix"
}

build_firmware() {
	local target="${keyboard}:${keymap}"

	BUILD_STARTED_EPOCH="$(date +%s)"
	BUILD_STARTED_ISO="$(date -d "@$BUILD_STARTED_EPOCH" +"%Y-%m-%dT%H:%M:%S%:z")"

	BUILD_OUTPUT_FILE="$(mktemp)"

	# Massdrop v1 predates the modern qmk compile workflow.
	#
	# The QMK-managed ARM toolchain must be added to PATH explicitly because
	# direct make does not receive the PATH setup normally performed by qmk.
	#
	# -fcommon is required when compiling this historical source with the
	# current GCC toolchain.
	if ! "$RUN_CONTAINER" sh -lc \
		"PATH=/home/qmk/.local/share/qmk/bin:\$PATH make -C /home/qmk/src/qmk/qmk_firmware '$target' EXTRAFLAGS=-fcommon" \
		2>&1 | tee "$BUILD_OUTPUT_FILE"; then
		fail "In-tree QMK build failed for keyboard '$keyboard' keymap '$keymap'"
	fi

	BUILD_FINISHED_ISO="$(date +"%Y-%m-%dT%H:%M:%S%:z")"
}

find_build_artifacts() {
	local prefix

	prefix="$(artifact_prefix "$keyboard" "$keymap")"

	ARTIFACT_PATHS=(
		"$QMK_FIRMWARE_ROOT/.build/${prefix}.bin"
		"$QMK_FIRMWARE_ROOT/.build/${prefix}.hex"
		"$QMK_FIRMWARE_ROOT/.build/${prefix}.elf"
		"$QMK_FIRMWARE_ROOT/.build/${prefix}.map"
	)

	local artifact_path

	for artifact_path in "${ARTIFACT_PATHS[@]}"; do
		if [[ ! -f "$artifact_path" ]]; then
			fail "Expected build artifact was not produced: $artifact_path"
		fi
	done
}

archive_build() {
	archive_firmware \
		"$QMK_USERSPACE_ROOT" \
		"$keyboard" \
		"$keymap" \
		"$QMK_FIRMWARE_ROOT" \
		"$BUILD_STARTED_ISO" \
		"$BUILD_FINISHED_ISO" \
		"$BUILD_OUTPUT_FILE" \
		"${ARTIFACT_PATHS[@]}"
}

cleanup() {
	if [[ -n "${BUILD_OUTPUT_FILE:-}" ]]; then
		rm -f "$BUILD_OUTPUT_FILE"
	fi
}

main() {
	keyboard=""
	keymap=""

	QMK_USERSPACE_ROOT=""
	QMK_FIRMWARE_ROOT=""
	QMK_INFRA_ROOT=""
	QMK_ROOT=""
	RUN_CONTAINER=""

	BUILD_STARTED_EPOCH=""
	BUILD_STARTED_ISO=""
	BUILD_FINISHED_ISO=""
	BUILD_OUTPUT_FILE=""

	ARTIFACT_PATHS=()

	parse_arguments "$@"
	find_repository_roots

	# Load the shared archival implementation only after locating qmk_userspace.
	source "$QMK_USERSPACE_ROOT/scripts/lib/archive-firmware.sh"

	trap cleanup EXIT

	validate_environment
	build_firmware
	find_build_artifacts
	archive_build
}

main "$@"
