#!/usr/bin/env bash
# Survey comments across a list of GitHub issues, with local JSON cache.
# Run from repo root. Add `ai/.cache/` to `.gitignore`.
#
# Usage:
#   bash ai/templates/gh-comment-survey.sh <repo> <issue> [<issue> ...]
# Example:
#   bash ai/templates/gh-comment-survey.sh lwouis/alt-tab-macos 5018 1835 44
#
# Pipe to grep / less to find specific authors or topics. Refresh with:
#   rm -rf ai/.cache/gh-issues

set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "usage: $0 <owner/repo> <issue-number> [<issue-number> ...]" >&2
  exit 2
fi

REPO="$1"; shift
CACHE_DIR="ai/.cache/gh-issues"
mkdir -p "$CACHE_DIR"

for n in "$@"; do
  cache="$CACHE_DIR/$n.json"
  [[ -f "$cache" ]] || gh issue view "$n" \
    --repo "$REPO" --comments --json comments > "$cache"

  echo "=== #$n ==="
  jq -r '.comments[] | "\(.author.login) | \(.url) | \(.body | gsub("\n"; " ") | .[0:120])"' "$cache"
done
