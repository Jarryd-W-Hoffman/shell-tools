# shell-tools

Portable shell functions, aliases, and utilities for faster development workflows.

**Version:** 0.0.1

## Requirements

Works in **bash** and **zsh**. `install.sh` detects your login shell (via `$SHELL`) and targets `~/.zshrc` or `~/.bashrc` accordingly.

## Install

```sh
git clone git@github.com:Jarryd-W-Hoffman/shell-tools.git
cd shell-tools
./install.sh
```

This appends a `source "<repo>/load.sh"` line (under a `# shell-tools` comment) to your `~/.zshrc` or `~/.bashrc`, depending on your login shell. Running it again is safe — the line is only added once.

Then restart your shell, or activate immediately with:

```sh
source ~/.zshrc   # or ~/.bashrc
```

## How it works

`load.sh` sources every `*.sh` file in the [shell/](shell/) directory, so dropping a new file in there makes its functions available automatically — no install step needed.

## Uninstall

```sh
./uninstall.sh
```

This removes the `source` line from `~/.bashrc`, `~/.bash_profile`, and `~/.zshrc` (whichever contain it). The repository itself is not deleted — remove the directory manually if you no longer need it:

```sh
rm -rf shell-tools
```

## Commands

### Git

| Command | Description |
| --- | --- |
| `gitreset [branch]` | Hard-reset to `origin/<branch>`. Defaults to the current branch; prints an error if you're not in a git repository. |
