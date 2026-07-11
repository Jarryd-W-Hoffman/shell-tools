# shell-tools

Portable, plugin-based shell utilities for bash and zsh. Drop in a script, get new commands — no configuration required.

## Requirements

- **bash** or **zsh**
- `install.sh` auto-detects your login shell (`$SHELL`) and targets the correct rc file
- Unsupported shells (fish, ksh, etc.) fall back to `~/.bashrc` with a warning

## Install

```sh
git clone git@github.com:Jarryd-W-Hoffman/shell-tools.git
cd shell-tools
./install.sh
```

This appends a `source "<repo>/load.sh"` line (under a `# shell-tools` comment) to your rc file. Running it again is safe — it detects existing installs.

Restart your shell or activate immediately:

```sh
source ~/.zshrc   # or ~/.bashrc
```

## Uninstall

```sh
./uninstall.sh
```

Removes the source line and comment from `~/.bashrc`, `~/.bash_profile`, and `~/.zshrc`. The repository itself is not deleted:

```sh
rm -rf shell-tools
```

## How it works

```
~/.zshrc or ~/.bashrc
  └── sources load.sh
        └── sources all shell/*.sh files
```

`load.sh` is the single entry point. It dynamically discovers and sources every `*.sh` file in the [shell/](shell/) directory. To add a new tool, create a `.sh` file there — no changes to `load.sh` or any other file needed.

## Adding a tool

Create a new file in `shell/`:

```sh
# shell/mytool.sh

mytool() {
    # your logic here
    echo "Hello from mytool"
}
```

Restart your shell. `mytool` is now available as a command.

## Commands

### Git

| Command | Description |
| --- | --- |
| `gitreset [branch]` | Fetch all remotes, then hard-reset to `origin/<branch>`. Defaults to the current branch. |
| `gitfetch` | Fetch all remotes and prune deleted branches. |
| `gitlog [args]` | Compact colored log with graph, dates, and author. Pass extra args to filter. |

## Development

Available make targets:

```sh
make help       # list available targets
make test       # run tests
make lint       # lint shell scripts with shellcheck
make install    # run the installer
make uninstall  # run the uninstaller
```

### Linting

Lint all shell scripts with [shellcheck](https://www.shellcheck.net/):

```sh
sudo apt-get install shellcheck
make lint
```

### Testing

Tests use [bats-core](https://github.com/bats-core/bats-core). Install the required packages:

```sh
sudo apt-get install bats bats-assert bats-support bats-file
```

Then run:

```sh
make test
```

This runs all tests in `tests/` covering install, uninstall, and load behavior. To run a single test file:

```sh
bats tests/install.bats
```

#### Adding tests

Test files follow the naming convention `tests/<name>.bats`. Each file can use the shared helpers:

```bash
load 'test_helper.sh'

setup() {
    setup_test_env   # creates temp $HOME, copies repo
}

teardown() {
    teardown_test_env
}

@test "my test description" {
    run bash "$TEST_REPO_DIR/install.sh"
    assert_success
    assert_file_contains "$HOME/.bashrc" "source.*load.sh"
}
```

### CI

GitHub Actions runs lint and tests on every push to `main` and on pull requests. See [`.github/workflows/test.yml`](.github/workflows/test.yml).

## License

[MIT](LICENSE)
