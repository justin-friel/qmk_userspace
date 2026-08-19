#!/usr/bin/env bash

# Shared firmware archive library.
#
# Build scripts populate the ARCHIVE_* variables below and call archive_firmware().
# This library does not build or flash firmware. It validates and copies completed
# build artifacts into the common qmk_userspace/firmware archive and creates the
# corresponding info.txt metadata file.


# Archive destination and build identity.
ARCHIVE_USERSPACE_ROOT=""

ARCHIVE_KEYBOARD=""
ARCHIVE_KEYMAP=""

# Optional keyboard metadata. Build scripts populate whatever information is
# available from their particular QMK tree.
ARCHIVE_KEYBOARD_NAME=""
ARCHIVE_MANUFACTURER=""
ARCHIVE_MAINTAINER=""
ARCHIVE_PROCESSOR=""
ARCHIVE_BOOTLOADER=""

# Build information supplied by the build script.
ARCHIVE_BUILD_STARTED=""
ARCHIVE_BUILD_FINISHED=""
ARCHIVE_BUILD_OUTPUT_FILE=""

# Repositories involved in producing the firmware.
#
# Modern QMK builds use both qmk_userspace and qmk_firmware.
# Massdrop v1 builds use only qmk_firmware, so ARCHIVE_USERSPACE_REPO is empty.
ARCHIVE_USERSPACE_REPO=""
ARCHIVE_FIRMWARE_REPO=""

# Explicit list of build artifacts to archive.
ARCHIVE_ARTIFACT_PATHS=()


# Print an archive error and return failure to the calling build script.
archive_fail() {
	printf 'Error: %s\n' "$*" >&2
	return 1
}

# Return the full configured origin URL for console output.
archive_repo_origin_full() {
	local repo_path="$1"

	git -C "$repo_path" remote get-url origin 2>/dev/null || printf 'N/A'
}

# Return the repository name from the configured origin URL.
# Strip the server/path prefix and optional .git suffix so internal
# Git infrastructure is never written to the firmware archive.
archive_repo_origin_url() {
	local repo_path="$1"

	git -C "$repo_path" remote get-url origin 2>/dev/null |
		sed -E 's#^.*/##; s#^.*:##; s#\.git$##'
}


# Return the currently checked-out branch.
# If HEAD is detached, record that explicitly rather than returning an empty value.
archive_repo_branch() {
	local repo_path="$1"
	local branch

	branch="$(git -C "$repo_path" branch --show-current 2>/dev/null || true)"
	if [[ -n "$branch" ]]; then
		printf '%s' "$branch"
		return
	fi

	git -C "$repo_path" symbolic-ref --short -q HEAD 2>/dev/null || printf 'DETACHED'
}


# Return the full commit hash currently checked out in a repository.
archive_repo_commit() {
	local repo_path="$1"

	git -C "$repo_path" rev-parse HEAD
}


# Verify that a path points to a Git working tree.
archive_require_git_repo() {
	local repo_path="$1"

	if ! git -C "$repo_path" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
		archive_fail "Not a Git repository: $repo_path"
		return 1
	fi
}


# Validate everything supplied by the calling build script before creating
# the archive. This prevents incomplete or incorrectly identified archives.
archive_validate_inputs() {
	local artifact_path

	if [[ -z "$ARCHIVE_USERSPACE_ROOT" ]]; then
		archive_fail "ARCHIVE_USERSPACE_ROOT is not set"
		return 1
	fi

	if [[ -z "$ARCHIVE_KEYBOARD" ]]; then
		archive_fail "ARCHIVE_KEYBOARD is not set"
		return 1
	fi

	if [[ -z "$ARCHIVE_KEYMAP" ]]; then
		archive_fail "ARCHIVE_KEYMAP is not set"
		return 1
	fi

	if [[ -z "$ARCHIVE_BUILD_STARTED" || -z "$ARCHIVE_BUILD_FINISHED" ]]; then
		archive_fail "Build timestamps are not set"
		return 1
	fi

	# The archive always lives in qmk_userspace, so it must be a valid Git repo.
	archive_require_git_repo "$ARCHIVE_USERSPACE_ROOT"

	# Only validate source repositories that participated in this build.
	if [[ -n "$ARCHIVE_USERSPACE_REPO" ]]; then
		archive_require_git_repo "$ARCHIVE_USERSPACE_REPO"
	fi

	if [[ -n "$ARCHIVE_FIRMWARE_REPO" ]]; then
		archive_require_git_repo "$ARCHIVE_FIRMWARE_REPO"
	fi

	if (( ${#ARCHIVE_ARTIFACT_PATHS[@]} == 0 )); then
		archive_fail "No firmware artifacts supplied"
		return 1
	fi

	# Build scripts explicitly identify their artifacts. The archive library
	# verifies that every file exists and is a type we intentionally preserve.
	for artifact_path in "${ARCHIVE_ARTIFACT_PATHS[@]}"; do
		if [[ ! -f "$artifact_path" ]]; then
			archive_fail "Firmware artifact does not exist: $artifact_path"
			return 1
		fi

		case "$artifact_path" in
			*.hex|*.bin|*.elf|*.map)
				;;
			*)
				archive_fail "Unsupported firmware artifact: $artifact_path"
				return 1
				;;
		esac
	done
}


# Archive one completed firmware build.
#
# The calling build script has already built the firmware and populated all
# applicable ARCHIVE_* variables. This function:
#	1. Creates firmware/<keyboard>/<build-time>/.
#	2. Copies the supplied artifacts without modifying the originals.
#	3. Calculates size and SHA-256 for every archived artifact.
#	4. Records build and Git provenance in info.txt.
#	5. Preserves the captured build log when one is supplied.
archive_firmware() {
	local build_start_dir
	local archive_dir
	local info_path
	local artifact_path
	local artifact_filename
	local archived_path
	local firmware_sha
	local firmware_size

	# Validate everything before creating any files.
	archive_validate_inputs

	# Name the archive using the build start time, not the later archive time.
	build_start_dir="$(date -d "$ARCHIVE_BUILD_STARTED" +"%Y-%m-%dT%H-%M-%S%z")"
	archive_dir="${ARCHIVE_USERSPACE_ROOT}/firmware/${ARCHIVE_KEYBOARD}/${build_start_dir}"
	info_path="${archive_dir}/info.txt"

	# Never silently replace a previous firmware archive.
	if [[ -e "$archive_dir" ]]; then
		archive_fail "Archive directory already exists: $archive_dir"
		return 1
	fi

	mkdir -p "$archive_dir"

	# Start info.txt with the keyboard and build metadata common to all artifacts.
	{
		printf 'Keyboard: %s\n' "$ARCHIVE_KEYBOARD"

        # Write all keyboard metadata fields so info.txt has a consistent format.
        # Fields remain blank when the build script cannot determine their value.
        printf 'Keyboard Name: %s\n' "$ARCHIVE_KEYBOARD_NAME"
        printf 'Manufacturer: %s\n' "$ARCHIVE_MANUFACTURER"
        printf 'Maintainer: %s\n' "$ARCHIVE_MAINTAINER"
        printf 'Processor: %s\n' "$ARCHIVE_PROCESSOR"
        printf 'Bootloader: %s\n' "$ARCHIVE_BOOTLOADER"
		printf 'Keymap: %s\n\n' "$ARCHIVE_KEYMAP"
		printf 'Build started: %s\n' "$ARCHIVE_BUILD_STARTED"
		printf 'Build finished: %s\n\n' "$ARCHIVE_BUILD_FINISHED"
		printf 'Firmware artifacts:\n'
	} > "$info_path"

	# Copy every artifact and record information that can later verify the
	# archived copy is byte-for-byte identical to the build output.
	for artifact_path in "${ARCHIVE_ARTIFACT_PATHS[@]}"; do
		artifact_filename="$(basename "$artifact_path")"
		archived_path="${archive_dir}/${artifact_filename}"

		cp -- "$artifact_path" "$archived_path"

		firmware_sha="$(sha256sum "$archived_path" | awk '{print $1}')"
		firmware_size="$(stat -c '%s' "$archived_path")"

		{
			printf '\tFilename: %s\n' "$artifact_filename"
			printf '\tSize: %s\n' "$firmware_size"
			printf '\tSHA-256: %s\n\n' "$firmware_sha"
		} >> "$info_path"
	done

	# Always write the qmk_userspace provenance section so info.txt keeps
	# a consistent schema. Leave the fields blank when userspace did not
	# participate in the build.
	printf 'qmk_userspace:\n' >> "$info_path"

	if [[ -n "$ARCHIVE_USERSPACE_REPO" ]]; then
		{
			printf '\tRepository: %s\n' "$(archive_repo_origin_url "$ARCHIVE_USERSPACE_REPO")"
			printf '\tBranch: %s\n' "$(archive_repo_branch "$ARCHIVE_USERSPACE_REPO")"
			printf '\tCommit: %s\n\n' "$(archive_repo_commit "$ARCHIVE_USERSPACE_REPO")"
		} >> "$info_path"
	else
		{
			printf '\tRepository: \n'
			printf '\tBranch: \n'
			printf '\tCommit: \n\n'
		} >> "$info_path"
	fi

	# Always write the qmk_firmware provenance section so info.txt keeps
	# a consistent schema. Leave the fields blank if firmware source
	# provenance is unavailable.
	printf 'qmk_firmware:\n' >> "$info_path"

	if [[ -n "$ARCHIVE_FIRMWARE_REPO" ]]; then
		{
			printf '\tRepository: %s\n' "$(archive_repo_origin_url "$ARCHIVE_FIRMWARE_REPO")"
			printf '\tBranch: %s\n' "$(archive_repo_branch "$ARCHIVE_FIRMWARE_REPO")"
			printf '\tCommit: %s\n\n' "$(archive_repo_commit "$ARCHIVE_FIRMWARE_REPO")"
		} >> "$info_path"
	else
		{
			printf '\tRepository: \n'
			printf '\tBranch: \n'
			printf '\tCommit: \n\n'
		} >> "$info_path"
	fi

	# Preserve the build log when the build wrapper captured one.
	# The build wrapper is responsible for ensuring the captured output is
	# suitable for plain text (for example, disabling terminal color codes).
	if [[ -n "$ARCHIVE_BUILD_OUTPUT_FILE" && -f "$ARCHIVE_BUILD_OUTPUT_FILE" ]]; then
		{
			printf 'Build output:\n'
			printf '%s\n' '--------------------------------------------------------------------------------'
			cat "$ARCHIVE_BUILD_OUTPUT_FILE"
			printf '%s\n' '--------------------------------------------------------------------------------'
		} >> "$info_path"
	fi

    # Print the full configured Git origins for console visibility.
	# These full paths/URLs are not written to info.txt.
	if [[ -n "$ARCHIVE_USERSPACE_REPO" ]]; then
		printf 'qmk_userspace: %s\n' "$(archive_repo_origin_full "$ARCHIVE_USERSPACE_REPO")"
	else
		printf 'qmk_userspace: \n'
	fi

	if [[ -n "$ARCHIVE_FIRMWARE_REPO" ]]; then
		printf 'qmk_firmware: %s\n' "$(archive_repo_origin_full "$ARCHIVE_FIRMWARE_REPO")"
	else
		printf 'qmk_firmware: \n'
	fi

	printf 'Archive directory: %s\n' "$archive_dir"
}
