#!/usr/bin/env bash

# Shared firmware archival functions.
#
# This file is a library intended to be sourced by the build scripts.
# It does not build firmware and does not provide a standalone command-line
# interface.
#
# The calling build script supplies:
#	- build metadata
#	- source repository
#	- explicit paths to the artifacts produced by the build
#
# This library copies those artifacts into the common
# qmk_userspace/firmware archive.

archive_fail() {
	printf 'Error: %s\n' "$*" >&2
	return 1
}

# Return the configured origin URL for a Git repository.
archive_repo_origin_url() {
	local repo_path="$1"

	git -C "$repo_path" remote get-url origin 2>/dev/null || printf 'N/A'
}

# Return the currently checked-out branch.
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

# Verify that every supplied artifact exists and has a supported extension.
archive_validate_artifacts() {
	local artifact_path

	if (( $# == 0 )); then
		archive_fail "No firmware artifacts supplied"
		return 1
	fi

	for artifact_path in "$@"; do
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

# Archive the artifacts from one completed firmware build.
#
# Arguments:
#	$1	qmk_userspace repository root
#	$2	keyboard target
#	$3	keymap
#	$4	source repository used to build the firmware
#	$5	build start time
#	$6	build finish time
#	$7	build output file, or an empty string
#	$8...	explicit firmware artifact paths
#
# The archive is created at:
#
#	firmware/<keyboard>/<build-start-time>/
#
# Artifacts are copied rather than moved so the original build outputs remain
# available after archival.
archive_firmware() {
	local userspace_root="$1"
	local keyboard="$2"
	local keymap="$3"
	local source_repo="$4"
	local build_started="$5"
	local build_finished="$6"
	local build_output_file="$7"
	shift 7

	local -a artifact_paths=("$@")

	local build_start_dir
	local archive_dir
	local info_path
	local artifact_path
	local artifact_filename
	local archived_path
	local firmware_sha
	local firmware_size

	archive_require_git_repo "$userspace_root"
	archive_require_git_repo "$source_repo"
	archive_validate_artifacts "${artifact_paths[@]}"

	# Use the build start time for the archive directory so the archive
	# identifies when the firmware was actually built.
	build_start_dir="$(date -d "$build_started" +"%Y-%m-%dT%H-%M-%S%z")"
	archive_dir="${userspace_root}/firmware/${keyboard}/${build_start_dir}"
	info_path="${archive_dir}/info.txt"

	# Never overwrite an existing firmware archive.
	if [[ -e "$archive_dir" ]]; then
		archive_fail "Archive directory already exists: $archive_dir"
		return 1
	fi

	mkdir -p "$archive_dir"

	# Write metadata that applies to the entire build.
	{
		printf 'Keyboard: %s\n' "$keyboard"
		printf 'Keymap: %s\n\n' "$keymap"

		printf 'Build started: %s\n' "$build_started"
		printf 'Build finished: %s\n\n' "$build_finished"

		printf 'Source repository:\n'
		printf '\tRepository: %s\n' "$(archive_repo_origin_url "$source_repo")"
		printf '\tBranch: %s\n' "$(archive_repo_branch "$source_repo")"
		printf '\tCommit: %s\n\n' "$(archive_repo_commit "$source_repo")"

		printf 'Firmware artifacts:\n'
	} > "$info_path"

	# Copy each artifact and record enough information to verify it later.
	for artifact_path in "${artifact_paths[@]}"; do
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

	# Preserve the compiler/build log when the caller captured one.
	if [[ -n "$build_output_file" && -f "$build_output_file" ]]; then
		{
			printf 'Build output:\n'
			printf '%s\n' '--------------------------------------------------------------------------------'
			cat "$build_output_file"
			printf '%s\n' '--------------------------------------------------------------------------------'
		} >> "$info_path"
	fi

	printf 'Archive directory: %s\n' "$archive_dir"
}
