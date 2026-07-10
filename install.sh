#!/usr/bin/env bash

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# This script always runs under bash (see shebang), so detect the user's
# login shell rather than the interpreter running the script.
case "${SHELL##*/}" in
    zsh) RC_FILE="$HOME/.zshrc" ;;
    *)   RC_FILE="$HOME/.bashrc" ;;
esac

LINE="source \"$REPO_DIR/load.sh\""

grep -qxF "$LINE" "$RC_FILE" || {
    echo "" >> "$RC_FILE"
    echo "# shell-tools" >> "$RC_FILE"
    echo "$LINE" >> "$RC_FILE"
}

echo "Installed!"
echo "Restart your shell or run:"
echo "source $RC_FILE"
