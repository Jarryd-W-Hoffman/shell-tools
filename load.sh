# shellcheck shell=bash
# Sourced by ~/.bashrc or ~/.zshrc — must work in both shells.
# BASH_SOURCE doesn't exist in zsh; %x prompt expansion gives the sourced file's path.
if [ -n "${ZSH_VERSION:-}" ]; then
    # shellcheck disable=SC2296
    _shell_tools_dir="$(cd "$(dirname "${(%):-%x}")" && pwd)" || return
else
    _shell_tools_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" || return
fi

_shell_tools_shopt_save=""
if [ -z "${ZSH_VERSION:-}" ]; then
    _shell_tools_shopt_save="$(shopt -p nullglob 2>/dev/null)" || true
    shopt -s nullglob
fi

for _shell_tools_file in "$_shell_tools_dir"/shell/*.sh; do
    # shellcheck disable=SC1090
    if ! source "$_shell_tools_file"; then
        echo "shell-tools: warning: failed to source $_shell_tools_file" >&2
    fi
done

if [ -n "$_shell_tools_shopt_save" ]; then
    eval "$_shell_tools_shopt_save"
fi

unset _shell_tools_dir _shell_tools_file _shell_tools_shopt_save
