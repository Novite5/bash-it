# shellcheck shell=bats
# shellcheck disable=SC2034 # Variables consumed by externally-loaded powerline functions.

load "${MAIN_BASH_IT_DIR?}/test/test_helper.bash"

function local_setup_file() {
	setup_libs "colors"
	load "${BASH_IT?}/themes/powerline/powerline.base.bash"
}

# Stub a no-op segment so we can run __powerline_prompt_command without
# sourcing every plugin that the default segments depend on.
function __powerline_noop_prompt() { :; }
# _save-and-reload-history is called unconditionally; stub it out.
function _save-and-reload-history() { :; }

# --- __powerline_prompt_command: missing-newline handler (fixes #2372) ---

@test "powerline base: __powerline_prompt_command overflows the line and returns to column 1" {
	COLUMNS=20
	POWERLINE_PROMPT=("noop")
	run __powerline_prompt_command

	local expected
	expected="$(printf '%*s\r' "$((COLUMNS - 1))" '')"
	assert_output --partial "${expected}"
}

@test "powerline base: __powerline_prompt_command missing-newline sequence is first output" {
	COLUMNS=20
	POWERLINE_PROMPT=("noop")
	run __powerline_prompt_command

	# Confirm the padding+carriage-return appears at the very start, meaning it
	# is a direct printf rather than anything embedded in PS1 or segments.
	local prefix
	prefix="$(printf '%*s\r' "$((COLUMNS - 1))" '')"
	[[ "${output}" == "${prefix}"* ]]
}

@test "powerline base: __powerline_prompt_command falls back to 80 columns when COLUMNS is unset" {
	unset COLUMNS
	POWERLINE_PROMPT=("noop")
	run __powerline_prompt_command

	local expected
	expected="$(printf '%*s\r' 79 '')"
	assert_output --partial "${expected}"
}
