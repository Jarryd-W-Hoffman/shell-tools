#!/usr/bin/env bash

# Load bats extension libraries (installed via apt: bats-assert, bats-support, bats-file)
load '/usr/lib/bats/bats-support/load'
load '/usr/lib/bats/bats-assert/load'
load '/usr/lib/bats/bats-file/load'

# Project root (one level up from tests/)
PROJECT_ROOT="$(cd "$(dirname "${BATS_TEST_FILENAME}")/.." && pwd)"

# Create a temporary home directory and copy the project into it.
# Sets HOME, TEST_REPO_DIR, and populates mock rc files.
setup_test_env() {
    TEST_HOME="$(mktemp -d)"
    export TEST_HOME
    export HOME="$TEST_HOME"
    export SHELL="/bin/bash"

    # Copy the project into the temp dir so install/uninstall have a real repo
    TEST_REPO_DIR="$TEST_HOME/shell-tools"
    cp -r "$PROJECT_ROOT" "$TEST_REPO_DIR"
    chmod +x "$TEST_REPO_DIR/install.sh"
    chmod +x "$TEST_REPO_DIR/uninstall.sh"
}

# Remove the temporary home directory.
teardown_test_env() {
    rm -rf "$TEST_HOME"
}

# Create a mock rc file with optional initial content.
# Usage: create_mock_rc .bashrc "# existing content"
create_mock_rc() {
    local rc_name="$1"
    local content="${2:-}"
    printf '%s\n' "$content" > "$HOME/$rc_name"
}
