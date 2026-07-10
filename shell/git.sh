#!/usr/bin/env bash

#
# Git helpers
#

gitreset() {
    # Use the first argument ($1) if it exists, otherwise get the current branch name.
    local branch_name=${1:-$(git branch --show-current)}

    # Check if a branch name was successfully determined.
    if [ -z "$branch_name" ]; then
        echo "Error: Could not determine branch. Are you in a git repository?"
    else
        # Execute the reset command. Double-quoting prevents issues with special characters.
        git reset --hard "origin/$branch_name"
    fi
}
