#!/usr/bin/env bats

load 'test_helper.sh'

setup() {
    setup_test_env
}

teardown() {
    teardown_test_env
}

@test "uninstall: removes source line from .bashrc" {
    create_mock_rc ".bashrc" "# existing
# shell-tools
source \"$TEST_REPO_DIR/load.sh\"
# end"

    run bash "$TEST_REPO_DIR/uninstall.sh"
    assert_success
    assert_output --partial "Removed source line from $HOME/.bashrc"
    assert_file_not_contains "$HOME/.bashrc" "source.*load.sh"
}

@test "uninstall: removes # shell-tools comment" {
    create_mock_rc ".bashrc" "# existing
# shell-tools
source \"$TEST_REPO_DIR/load.sh\"
# end"

    run bash "$TEST_REPO_DIR/uninstall.sh"
    assert_success
    assert_output --partial "Removed comment from $HOME/.bashrc"
    refute grep -qF "# shell-tools" "$HOME/.bashrc"
}

@test "uninstall: preserves other content in rc file" {
    create_mock_rc ".bashrc" "# my aliases
alias ll='ls -la'

# shell-tools
source \"$TEST_REPO_DIR/load.sh\"

# prompt
PS1='> '"

    run bash "$TEST_REPO_DIR/uninstall.sh"
    assert_success
    assert_file_contains "$HOME/.bashrc" "# my aliases"
    assert_file_contains "$HOME/.bashrc" "alias ll"
    assert_file_contains "$HOME/.bashrc" "PS1="
    assert_file_not_contains "$HOME/.bashrc" "source.*load.sh"
    assert_file_not_contains "$HOME/.bashrc" "# shell-tools"
}

@test "uninstall: prints 'No entry found' when source line is absent" {
    create_mock_rc ".bashrc" "# just some content"

    run bash "$TEST_REPO_DIR/uninstall.sh"
    assert_success
    assert_output --partial "No entry found in $HOME/.bashrc"
}

@test "uninstall: handles non-existent rc files gracefully" {
    rm -f "$HOME/.bashrc" "$HOME/.bash_profile" "$HOME/.zshrc"

    run bash "$TEST_REPO_DIR/uninstall.sh"
    assert_success
}

@test "uninstall: cleans up orphaned .bak files" {
    create_mock_rc ".bashrc" "# content"
    touch "$HOME/.bashrc.bak"

    run bash "$TEST_REPO_DIR/uninstall.sh"
    assert_success
    assert_file_not_exists "$HOME/.bashrc.bak"
}

@test "uninstall: is idempotent — running twice does not error" {
    create_mock_rc ".bashrc" "# shell-tools
source \"$TEST_REPO_DIR/load.sh\""

    run bash "$TEST_REPO_DIR/uninstall.sh"
    assert_success

    run bash "$TEST_REPO_DIR/uninstall.sh"
    assert_success
}

@test "uninstall: full round-trip with install" {
    export SHELL="/bin/bash"
    create_mock_rc ".bashrc" "# my stuff"

    # Install
    run bash "$TEST_REPO_DIR/install.sh"
    assert_success
    assert_file_contains "$HOME/.bashrc" "source.*load.sh"
    assert_file_contains "$HOME/.bashrc" "# shell-tools"

    # Uninstall
    run bash "$TEST_REPO_DIR/uninstall.sh"
    assert_success
    assert_file_not_contains "$HOME/.bashrc" "source.*load.sh"
    assert_file_not_contains "$HOME/.bashrc" "# shell-tools"

    # Original content preserved
    assert_file_contains "$HOME/.bashrc" "# my stuff"
}
