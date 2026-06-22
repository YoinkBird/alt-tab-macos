#!/usr/bin/env bash
# release-debug.sh: build an installable AltTabDebug via GitHub Actions and fetch it.
#
# Lightweight scripted "release": asserts the repo is in the state the manual
# (workflow_dispatch) trigger needs, pushes, dispatches debug-build, waits, downloads.
#
# Usage: ai/release-debug.sh [--branch <name>] [--out <dir>] [--set-default] [--dry-run]
#   --branch       branch to build (default: current branch)
#   --out          existing dir to download the artifact into (default: .)
#   --set-default  set the GitHub default branch to <branch> if it isn't (default: refuse)
#   --dry-run      print the plan; change nothing
#
# Fails loud if: gh missing/unauthenticated, dirty tree, branch missing, default
# branch != <branch> (unless --set-default), or the CI build fails.
set -euo pipefail
WORKFLOW="debug_build.yml"; ARTIFACT="AltTabDebug"

branch=""; out="."; set_default=0; dry=0
while [[ $# -gt 0 ]]; do case "$1" in
  --branch) branch="$2"; shift 2 ;;
  --out) out="$2"; shift 2 ;;
  --set-default) set_default=1; shift ;;
  --dry-run) dry=1; shift ;;
  -h|--help) sed -n '2,15p' "$0"; exit 0 ;;
  *) echo "ERROR: unknown arg: $1" >&2; exit 2 ;;
esac; done
run() { echo "+ $*"; [[ "$dry" == 1 ]] || "$@"; }

# --- preconditions (fail loud) ---
command -v gh >/dev/null || { echo "ERROR: gh not installed (brew install gh)" >&2; exit 1; }
gh auth status >/dev/null 2>&1 || { echo "ERROR: gh not authenticated (gh auth login)" >&2; exit 1; }
[[ -d "$out" ]] || { echo "ERROR: --out dir does not exist: $out" >&2; exit 1; }
git diff --quiet && git diff --cached --quiet || { echo "ERROR: dirty tree; commit/stash first" >&2; exit 1; }
[[ -n "$branch" ]] || branch="$(git symbolic-ref --short HEAD)"
git show-ref --verify --quiet "refs/heads/$branch" || { echo "ERROR: no such branch: $branch" >&2; exit 1; }
repo="$(gh repo view --json nameWithOwner -q .nameWithOwner)"
echo "Repo: $repo   Branch: $branch   Artifact -> $out"

# --- 1. push (you invoke this script; this is your push) ---
run git push origin "$branch"

# --- 2. assert default branch (workflow_dispatch needs the file there) ---
current="$(gh repo view --json defaultBranchRef -q .defaultBranchRef.name)"
if [[ "$current" != "$branch" ]]; then
  [[ "$set_default" == 1 ]] || { echo "ERROR: default branch is '$current', not '$branch'." >&2
    echo "       re-run with --set-default, or: gh repo edit $repo --default-branch $branch" >&2; exit 1; }
  run gh repo edit "$repo" --default-branch "$branch"
fi

# --- 3. dispatch + wait ---
run gh workflow run "$WORKFLOW" --ref "$branch"
[[ "$dry" == 1 ]] && { echo "(dry-run) would wait + download '$ARTIFACT'"; exit 0; }
echo "Waiting for run to register..."; sleep 5
run_id="$(gh run list --workflow="$WORKFLOW" --branch "$branch" --limit 1 --json databaseId -q '.[0].databaseId')"
gh run watch "$run_id" --exit-status

# --- 4. download ---
gh run download "$run_id" --name "$ARTIFACT" --dir "$out"
echo "Done. $ARTIFACT.zip in $out/  (unzip twice -> AltTabDebug.app -> /Applications -> 'Open Anyway')"
