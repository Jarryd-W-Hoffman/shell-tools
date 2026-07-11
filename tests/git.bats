#!/usr/bin/env bats

load 'test_helper.sh'

setup() {
    # Create a temporary git repo for testing
    export TEST_HOME="$(mktemp -d)"
    export HOME="$TEST_HOME"
    export TEST_REPO="$TEST_HOME/test-repo"
    mkdir -p "$TEST_REPO"
    cd "$TEST_REPO"
    git init
    git config user.email "test@test.com"
    git config user.name "Test User"
    # Create an initial commit so HEAD exists
    echo "initial" > file.txt
    git add file.txt
    git commit -m "initial commit"
    # Set up a bare remote so gitreset/gitfetch have something to fetch
    git init --bare "$TEST_HOME/remote.git"
    git remote add origin "$TEST_HOME/remote.git"
    git push -u origin master 2>/dev/null || git push -u origin main 2>/dev/null || true
    # Source the git helpers
    source "$PROJECT_ROOT/shell/git.sh"
}

teardown() {
    rm -rf "$TEST_HOME"
}

@test "gitfetch: runs without error in a git repo" {
    run gitfetch
    assert_success
}

@test "gitfetch: fails outside a git repo" {
    cd "$TEST_HOME"
    run bash -c "source '$PROJECT_ROOT/shell/git.sh' && gitfetch 2>&1"
    assert_failure
    assert_output --partial "Not in a git repository"
}

@test "gitreset: runs without error in a git repo" {
    run gitreset
    assert_success
}

@test "gitreset: fails outside a git repo" {
    cd "$TEST_HOME"
    run bash -c "source '$PROJECT_ROOT/shell/git.sh' && gitreset 2>&1"
    assert_failure
    assert_output --partial "Not in a git repository"
}

@test "gitlog: runs without error" {
    run gitlog
    assert_success
}

@test "gitlog: fails outside a git repo" {
    cd "$TEST_HOME"
    run bash -c "source '$PROJECT_ROOT/shell/git.sh' && gitlog 2>&1"
    assert_failure
    assert_output --partial "Not in a git repository"
}
