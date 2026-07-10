# Sourced by ~/.bashrc or ~/.zshrc — must work in both shells.
# BASH_SOURCE doesn't exist in zsh; %x prompt expansion gives the sourced file's path.
if [ -n "${ZSH_VERSION:-}" ]; then
    _shell_tools_dir="$(cd "$(dirname "${(%):-%x}")" && pwd)"
else
    _shell_tools_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi

for _shell_tools_file in "$_shell_tools_dir"/shell/*.sh; do
    source "$_shell_tools_file"
done

unset _shell_tools_dir _shell_tools_file
