#!/usr/bin/env bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_LINE="source \"$SCRIPT_DIR/load.sh\""

remove_from_rc() {
    local rc_file="$1"

    if [[ ! -f "$rc_file" ]]; then
        return
    fi

    if grep -Fq "$SOURCE_LINE" "$rc_file"; then
        # Create a backup
        cp "$rc_file" "$rc_file.bak"

        # Remove the source line
        grep -Fv "$SOURCE_LINE" "$rc_file.bak" > "$rc_file"
        rm "$rc_file.bak"

        echo "✓ Removed from $rc_file"
    else
        echo "- No entry found in $rc_file"
    fi
}

remove_from_rc "$HOME/.bashrc"
remove_from_rc "$HOME/.bash_profile"
remove_from_rc "$HOME/.zshrc"

echo
echo "shell-tools has been uninstalled."
echo "Restart your terminal or run:"
echo "  source ~/.bashrc"
echo "or"
echo "  source ~/.zshrc"
echo
echo "The repository itself was not deleted."
echo "You can remove it manually if you no longer need it:"
echo "  rm -rf \"$SCRIPT_DIR\""
