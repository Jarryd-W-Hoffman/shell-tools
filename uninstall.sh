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
        # Use a temp file to avoid orphaned backups on interruption
        local tmp_file
        tmp_file="$(mktemp "${rc_file}.XXXXXX")"
        grep -Fv "$SOURCE_LINE" "$rc_file" > "$tmp_file" && mv "$tmp_file" "$rc_file"

        echo "✓ Removed source line from $rc_file"
    else
        echo "- No entry found in $rc_file"
    fi

    # Clean up any orphaned .bak files from previous uninstalls
    rm -f "$rc_file.bak"
}

remove_from_rc_comment() {
    local rc_file="$1"

    if [[ ! -f "$rc_file" ]]; then
        return
    fi

    if grep -Fq "# shell-tools" "$rc_file"; then
        local tmp_file
        tmp_file="$(mktemp "${rc_file}.XXXXXX")"
        grep -Fv "# shell-tools" "$rc_file" > "$tmp_file" && mv "$tmp_file" "$rc_file"

        echo "✓ Removed comment from $rc_file"
    fi
}

for _rc_file in "$HOME/.bashrc" "$HOME/.bash_profile" "$HOME/.zshrc"; do
    remove_from_rc "$_rc_file"
    remove_from_rc_comment "$_rc_file"
done
unset _rc_file

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
