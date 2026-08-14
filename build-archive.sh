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

trim() {
	local value="$1"

	value="${value#"${value%%[![:space:]]*}"}"
	value="${value%"${value##*[![:space:]]}"}"
	printf '%s' "$value"
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

repo_origin_url() {
	local repo_path="$1"

	git -C "$repo_path" remote get-url origin 2>/dev/null || printf 'N/A'
}

repo_branch() {
	local repo_path="$1"
	local branch

	branch="$(git -C "$repo_path" branch --show-current 2>/dev/null || true)"
	if [[ -n "$branch" ]]; then
		printf '%s' "$branch"
		return
	fi

	git -C "$repo_path" symbolic-ref --short -q HEAD 2>/dev/null || printf 'DETACHED'
}

repo_commit() {
	local repo_path="$1"

	git -C "$repo_path" rev-parse HEAD
}

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

strip_ansi() {
	local input_path="$1"

	perl -pe '
		s/\e\][^\a]*(?:\a|\e\\)//g;
		s/\e\[[0-9;?]*[ -\/]*[@-~]//g;
		s/\e[@-_]//g;
	' "$input_path"
}

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
	done < <(find "$QMK_USERSPACE_ROOT" -maxdepth 1 -type f \( -name '*.hex' -o -name '*.bin' \) -newer "$marker_path" -print | sort)

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

keyboard=""
keymap=""
verbose=0

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

if ! command -v qmk >/dev/null 2>&1; then
	fail "qmk is not installed or not on PATH"
fi

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
QMK_USERSPACE_ROOT="$(git -C "$script_dir" rev-parse --show-toplevel 2>/dev/null || true)"
if [[ -z "$QMK_USERSPACE_ROOT" ]]; then
	fail "Unable to determine qmk_userspace repository root from script location"
fi

QMK_FIRMWARE_ROOT="$(qmk_firmware_root || true)"
if [[ -z "$QMK_FIRMWARE_ROOT" ]]; then
	fail "Unable to determine qmk_firmware location from qmk config user.qmk_home"
fi

require_git_repo "$QMK_USERSPACE_ROOT" "qmk_userspace"
require_git_repo "$QMK_FIRMWARE_ROOT" "qmk_firmware"
require_clean_repo "$QMK_USERSPACE_ROOT" "qmk_userspace"
require_clean_repo "$QMK_FIRMWARE_ROOT" "qmk_firmware"

QMK_USERSPACE_ORIGIN="$(repo_origin_url "$QMK_USERSPACE_ROOT")"
QMK_USERSPACE_BRANCH="$(repo_branch "$QMK_USERSPACE_ROOT")"
QMK_USERSPACE_COMMIT="$(repo_commit "$QMK_USERSPACE_ROOT")"

QMK_FIRMWARE_ORIGIN="$(repo_origin_url "$QMK_FIRMWARE_ROOT")"
QMK_FIRMWARE_BRANCH="$(repo_branch "$QMK_FIRMWARE_ROOT")"
QMK_FIRMWARE_COMMIT="$(repo_commit "$QMK_FIRMWARE_ROOT")"

BUILD_STARTED_EPOCH="$(date +%s)"
BUILD_STARTED_ISO="$(date -d "@$BUILD_STARTED_EPOCH" +"%Y-%m-%dT%H:%M:%S%:z")"
BUILD_START_DIR="$(date -d "@$BUILD_STARTED_EPOCH" +"%Y-%m-%dT%H-%M-%S%z")"

BUILD_OUTPUT_FILE="$(mktemp)"
BUILD_MARKER_FILE="$(mktemp)"
touch -d "@$BUILD_STARTED_EPOCH" "$BUILD_MARKER_FILE"
cleanup() {
	rm -f "$BUILD_OUTPUT_FILE" "$BUILD_MARKER_FILE"
}
trap cleanup EXIT

if [[ "$verbose" -eq 1 ]]; then
	qmk_cmd=(qmk -v compile -kb "$keyboard" -km "$keymap")
else
	qmk_cmd=(qmk compile -kb "$keyboard" -km "$keymap")
fi

if ! "${qmk_cmd[@]}" 2>&1 | tee "$BUILD_OUTPUT_FILE"; then
	fail "QMK compile failed for keyboard '$keyboard' keymap '$keymap'"
fi

BUILD_FINISHED_ISO="$(date +"%Y-%m-%dT%H:%M:%S%:z")"

ARTIFACT_PATH="$(detect_firmware_path "$BUILD_OUTPUT_FILE" "$BUILD_MARKER_FILE" || true)"
if [[ -z "$ARTIFACT_PATH" ]]; then
	fail "No firmware artifact found at qmk_userspace root after successful build"
fi

ARTIFACT_FILENAME="$(basename "$ARTIFACT_PATH")"
ARCHIVE_DIR="${QMK_USERSPACE_ROOT}/firmware/${keyboard}/${BUILD_START_DIR}"
ARCHIVED_PATH="${ARCHIVE_DIR}/${ARTIFACT_FILENAME}"

if [[ -e "$ARCHIVE_DIR" ]]; then
	fail "Archive directory already exists: $ARCHIVE_DIR"
fi

mkdir -p "$ARCHIVE_DIR"
cp -- "$ARTIFACT_PATH" "$ARCHIVED_PATH"

FIRMWARE_SHA="$(sha256sum "$ARCHIVED_PATH" | awk '{print $1}')"
FIRMWARE_SIZE="$(stat -c '%s' "$ARCHIVED_PATH")"
INFO_PATH="${ARCHIVE_DIR}/info.txt"

{
	printf 'Keyboard: %s\n' "$keyboard"
	printf 'Keymap: %s\n\n' "$keymap"
	printf 'Build started: %s\n' "$BUILD_STARTED_ISO"
	printf 'Build finished: %s\n\n' "$BUILD_FINISHED_ISO"
	printf 'Firmware:\n'
	printf '\tFilename: %s\n' "$ARTIFACT_FILENAME"
	printf '\tSize: %s\n' "$FIRMWARE_SIZE"
	printf '\tSHA-256: %s\n\n' "$FIRMWARE_SHA"
	printf 'qmk_userspace:\n'
	printf '\tRepository: %s\n' "$QMK_USERSPACE_ORIGIN"
	printf '\tBranch: %s\n' "$QMK_USERSPACE_BRANCH"
	printf '\tCommit: %s\n\n' "$QMK_USERSPACE_COMMIT"
	printf 'qmk_firmware:\n'
	printf '\tRepository: %s\n' "$QMK_FIRMWARE_ORIGIN"
	printf '\tBranch: %s\n' "$QMK_FIRMWARE_BRANCH"
	printf '\tCommit: %s\n\n' "$QMK_FIRMWARE_COMMIT"
	printf 'Build output:\n'
	printf '%s\n' '--------------------------------------------------------------------------------'
	strip_ansi "$BUILD_OUTPUT_FILE"
	printf '%s\n' '--------------------------------------------------------------------------------'
} > "$INFO_PATH"

printf 'Archive directory: %s\n' "$ARCHIVE_DIR"
printf 'Archived firmware: %s\n' "$ARCHIVED_PATH"
printf 'SHA-256: %s\n' "$FIRMWARE_SHA"
