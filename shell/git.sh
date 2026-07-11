#!/usr/bin/env bash
#
# git.sh - Git helper functions
#

# _git_require_repo - Validate we're inside a git repository.
#
# Private helper used by other functions that need a repo context.
#
# Returns:
#   0 if in a git repository, 1 otherwise
_git_require_repo() {
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        echo "Error: Not in a git repository." >&2
        return 1
    fi
}

# _git_require_branch - Get the current branch name, or use an argument.
#
# Private helper that combines repo validation with branch detection.
# Falls back to $1 if no current branch can be determined.
#
# Arguments:
#   $1 - Branch name (optional, defaults to current branch)
#
# Stdout:
#   The resolved branch name
#
# Returns:
#   0 on success, 1 if not in a repo or branch can't be determined
_git_require_branch() {
    _git_require_repo || return 1
    local branch_name=${1:-$(git branch --show-current)}
    if [ -z "$branch_name" ]; then
        echo "Error: Could not determine branch." >&2
        return 1
    fi
    echo "$branch_name"
}

# _git_fetch - Fetch all remotes and prune deleted branches.
#
# Private helper used by gitfetch and gitreset.
#
# Arguments:
#   Any valid git fetch arguments (e.g. --dry-run, --quiet)
#
# Returns:
#   0 on success, 1 if not in a git repository
_git_fetch() {
    _git_require_repo || return 1
    git fetch --all -p "$@"
}

# gitfetch - Fetch all remotes and prune deleted branches.
#
# Public wrapper around _git_fetch. Passes extra arguments through.
#
# Arguments:
#   Any valid git fetch arguments (e.g. --dry-run, --quiet)
#
# Examples:
#   gitfetch
#   gitfetch --dry-run
#
# Returns:
#   0 on success, 1 if not in a git repository
gitfetch() {
    _git_fetch "$@"
}

# gitreset - Fetch all remotes, then hard-reset to origin/<branch>.
#
# Combines git fetch --all -p with git reset --hard.
# Defaults to the current branch if no argument is given.
#
# Arguments:
#   $1 - Branch name (optional, defaults to current branch)
#
# Examples:
#   gitreset          # reset to origin/current-branch
#   gitreset develop  # reset to origin/develop
#
# Returns:
#   0 on success, 1 if not in a git repo or branch can't be determined
gitreset() {
    local branch_name
    branch_name=$(_git_require_branch "$1") || return 1
    _git_fetch || return 1
    git reset --hard "origin/$branch_name"
}

# gitlog - Compact colored log with graph, dates, and author.
#
# Displays a visual branch/merge history with relative dates,
# branch/tag decorations, commit subject, and author name.
#
# Arguments:
#   Any valid git log arguments (e.g. -5, --since="2 weeks ago")
#
# Examples:
#   gitlog
#   gitlog -10            # last 10 commits
#   gitlog --since="yesterday"
#
# Returns:
#   0 on success, 1 if not in a git repository
gitlog() {
    _git_require_repo || return 1
    git log \
        --graph \
        --decorate \
        --oneline \
        --all \
        --date=relative \
        --pretty=format:'%C(auto)%h %C(cyan)%ad%C(reset) %C(yellow)%d%C(reset) %s %C(green)(%an)%C(reset)' \
        "$@"
}
