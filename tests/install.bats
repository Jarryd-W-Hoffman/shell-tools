#!/usr/bin/env bats

load 'test_helper.sh'

setup() {
    setup_test_env
}

teardown() {
    teardown_test_env
}

@test "install: appends source line to .bashrc for bash shell" {
    create_mock_rc ".bashrc" "# existing content"
    export SHELL="/bin/bash"

    run bash "$TEST_REPO_DIR/install.sh"
    assert_success
    assert_output --partial "Installed!"
    assert_file_contains "$HOME/.bashrc" "source.*load.sh"
}

@test "install: appends source line to .zshrc for zsh shell" {
    create_mock_rc ".zshrc" "# existing content"
    export SHELL="/bin/zsh"

    run bash "$TEST_REPO_DIR/install.sh"
    assert_success
    assert_output --partial "Installed!"
    assert_file_contains "$HOME/.zshrc" "source.*load.sh"
}

@test "install: prints warning and falls back to .bashrc for unsupported shell" {
    create_mock_rc ".bashrc" ""
    export SHELL="/bin/fish"

    run bash "$TEST_REPO_DIR/install.sh"
    assert_success
    assert_output --partial "Unsupported login shell 'fish'"
    assert_file_contains "$HOME/.bashrc" "source.*load.sh"
}

@test "install: includes the # shell-tools comment" {
    create_mock_rc ".bashrc" ""
    export SHELL="/bin/bash"

    run bash "$TEST_REPO_DIR/install.sh"
    assert_success
    assert_file_contains "$HOME/.bashrc" "# shell-tools"
}

@test "install: is idempotent — second run reports already installed" {
    create_mock_rc ".bashrc" ""
    export SHELL="/bin/bash"

    run bash "$TEST_REPO_DIR/install.sh"
    assert_success
    assert_output --partial "Installed!"

    run bash "$TEST_REPO_DIR/install.sh"
    assert_success
    assert_output --partial "Already installed in"
}

@test "install: does not duplicate lines on repeated runs" {
    create_mock_rc ".bashrc" ""
    export SHELL="/bin/bash"

    run bash "$TEST_REPO_DIR/install.sh"
    run bash "$TEST_REPO_DIR/install.sh"

    # Count how many times the source line appears — should be exactly 1
    run grep -cF "source \"$TEST_REPO_DIR/load.sh\"" "$HOME/.bashrc"
    assert_output "1"
}

@test "install: prints restart instructions" {
    create_mock_rc ".bashrc" ""
    export SHELL="/bin/bash"

    run bash "$TEST_REPO_DIR/install.sh"
    assert_success
    assert_output --partial "Restart your shell or run:"
}

@test "install: creates rc file if it does not exist" {
    export SHELL="/bin/bash"
    rm -f "$HOME/.bashrc"

    run bash "$TEST_REPO_DIR/install.sh"
    assert_success
    assert_file_exists "$HOME/.bashrc"
    assert_file_contains "$HOME/.bashrc" "source.*load.sh"
}

@test "install: fails when rc file is not writable" {
    create_mock_rc ".bashrc" ""
    chmod 444 "$HOME/.bashrc"
    export SHELL="/bin/bash"

    run bash "$TEST_REPO_DIR/install.sh"
    assert_failure
    assert_output --partial "Cannot write to"
}
