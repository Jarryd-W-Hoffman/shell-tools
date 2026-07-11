#!/usr/bin/env bash

set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

case "${SHELL##*/}" in
    zsh)  RC_FILE="$HOME/.zshrc" ;;
    bash) RC_FILE="$HOME/.bashrc" ;;
    *)
        echo "Warning: Unsupported login shell '${SHELL##*/}'."
        echo "Falling back to ~/.bashrc. If this isn't sourced by your shell,"
        echo "manually add the following line to your shell's rc file:"
        echo "  source \"$REPO_DIR/load.sh\""
        RC_FILE="$HOME/.bashrc"
        ;;
esac

if { [[ -f "$RC_FILE" ]] && [[ ! -w "$RC_FILE" ]]; } ||
   { [[ ! -f "$RC_FILE" ]] && [[ ! -w "$(dirname "$RC_FILE")" ]]; }; then
    echo "Error: Cannot write to $RC_FILE (permission denied)." >&2
    exit 1
fi

LINE="source \"$REPO_DIR/load.sh\""

if grep -qxF "$LINE" "$RC_FILE"; then
    echo "Already installed in $RC_FILE."
else
    {
        echo ""
        echo "# shell-tools"
        echo "$LINE"
    } >> "$RC_FILE"
    echo "Installed!"
fi

echo "Restart your shell or run:"
echo "  source $RC_FILE"
