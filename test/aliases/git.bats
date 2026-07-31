# shellcheck shell=bats

load "${MAIN_BASH_IT_DIR?}/test/test_helper.bash"

function local_setup_file() {
	setup_libs ""
}

function local_setup() {
	TEST_REPO="${BATS_FILE_TMPDIR}/test-repo-${BATS_TEST_NUMBER}"
	mkdir -p "${TEST_REPO}"
	cd "${TEST_REPO}" || false
	git init . 2>&1 | grep -v "Reinitialized" || true

	source "${BASH_IT?}/aliases/available/git.aliases.bash"
}

@test "get_default_branch: returns main when origin points to main" {
	# Set up a local remote-like structure
	git remote add origin "https://github.com/test/repo.git"
	git symbolic-ref refs/remotes/origin/HEAD refs/remotes/origin/main

	run get_default_branch
	assert_success
	assert_output "main"
}

@test "get_default_branch: returns master when origin points to master" {
	git remote add origin "https://github.com/test/repo.git"
	git symbolic-ref refs/remotes/origin/HEAD refs/remotes/origin/master

	run get_default_branch
	assert_success
	assert_output "master"
}

@test "get_default_branch: falls back to first remote when origin doesn't exist" {
	git remote add upstream "https://github.com/upstream/repo.git"
	git symbolic-ref refs/remotes/upstream/HEAD refs/remotes/upstream/main

	run get_default_branch
	assert_success
	assert_output "main"
}

@test "get_default_branch: returns empty when no remotes exist" {
	run get_default_branch
	assert_success
	assert_output ""
}

@test "get_default_branch: returns empty when remote has no HEAD ref" {
	git remote add origin "https://github.com/test/repo.git"
	# Don't set a HEAD ref, so the git symbolic-ref command will fail

	run get_default_branch
	assert_success
	assert_output ""
}

@test "get_default_branch: properly strips remote prefix from branch name" {
	git remote add origin "https://github.com/test/repo.git"
	git symbolic-ref refs/remotes/origin/HEAD refs/remotes/origin/develop

	run get_default_branch
	assert_success
	assert_output "develop"
}

@test "get_default_branch: uses origin when both origin and another remote exist" {
	git remote add upstream "https://github.com/upstream/repo.git"
	git remote add origin "https://github.com/test/repo.git"
	git symbolic-ref refs/remotes/upstream/HEAD refs/remotes/upstream/main
	git symbolic-ref refs/remotes/origin/HEAD refs/remotes/origin/master

	run get_default_branch
	assert_success
	assert_output "master"
}
