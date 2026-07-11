#!/usr/bin/env bats

load 'test_helper.sh'

setup() {
    # Create a minimal repo structure for load.sh testing
    export TEST_HOME="$(mktemp -d)"
    export HOME="$TEST_HOME"
    export TEST_REPO="$TEST_HOME/shell-tools"
    mkdir -p "$TEST_REPO/shell"
    cp "$PROJECT_ROOT/load.sh" "$TEST_REPO/load.sh"
}

teardown() {
    rm -rf "$TEST_HOME"
}

@test "load: sources all .sh files in shell/ directory" {
    echo 'loaded_marker() { echo "MARKER"; }' > "$TEST_REPO/shell/test.sh"

    run bash -c "source '$TEST_REPO/load.sh' && loaded_marker"
    assert_success
    assert_output "MARKER"
}

@test "load: sources multiple .sh files" {
    echo 'func_a() { echo "A"; }' > "$TEST_REPO/shell/a.sh"
    echo 'func_b() { echo "B"; }' > "$TEST_REPO/shell/b.sh"

    run bash -c "source '$TEST_REPO/load.sh' && func_a && func_b"
    assert_success
    assert_output "A
B"
}

@test "load: handles empty shell/ directory without errors" {
    # shell/ exists but has no .sh files
    run bash -c "source '$TEST_REPO/load.sh' && echo OK"
    assert_success
    assert_output "OK"
}

@test "load: handles missing shell/ directory without errors" {
    rm -rf "$TEST_REPO/shell"

    run bash -c "source '$TEST_REPO/load.sh' && echo OK"
    assert_success
    assert_output "OK"
}

@test "load: only sources .sh files" {
    echo 'echo "SHOULD_NOT_LOAD"' > "$TEST_REPO/shell/readme.txt"
    echo 'loaded_marker() { echo "SH"; }' > "$TEST_REPO/shell/ok.sh"

    run bash -c "source '$TEST_REPO/load.sh' && loaded_marker"
    assert_success
    assert_output "SH"
}

@test "load: cleans up internal variables after sourcing" {
    echo 'some_func() { echo "done"; }' > "$TEST_REPO/shell/tool.sh"

    run bash -c "source '$TEST_REPO/load.sh' && some_func && [ -z \"\${_shell_tools_dir:-}\" ] && [ -z \"\${_shell_tools_file:-}\" ] && [ -z \"\${_shell_tools_shopt_save:-}\" ] && echo CLEAN"
    assert_success
    assert_output --partial "CLEAN"
}

@test "load: restores nullglob state after sourcing" {
    echo 'noop() { :; }' > "$TEST_REPO/shell/tool.sh"

    run bash -c "
        source '$TEST_REPO/load.sh'
        shopt -p nullglob || true
    "
    assert_output "shopt -u nullglob"
}

@test "load: warns on source errors but continues loading" {
    echo 'this is not valid bash (((' > "$TEST_REPO/shell/bad.sh"
    echo 'good_func() { echo "GOOD"; }' > "$TEST_REPO/shell/good.sh"

    run bash -c "source '$TEST_REPO/load.sh' && good_func"
    assert_success
    assert_output --partial "GOOD"
    assert_output --partial "shell-tools: warning: failed to source"
    assert_output --partial "bad.sh"
}
