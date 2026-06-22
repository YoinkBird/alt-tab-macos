#!/usr/bin/env bash
# Build AltTabDebug.app (ad-hoc signed, no keychain identity needed) and zip it
# for upload as a CI artifact. Invoked by .github/workflows/debug_build.yml.
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

ADHOC_SIGN=1 bash "$REPO_ROOT/ai/build.sh"

APP="$REPO_ROOT/DerivedData/Build/Products/Debug/AltTabDebug.app"
[[ -d "$APP" ]] || { echo "ERROR: $APP not found after build" >&2; exit 1; }

# ditto preserves symlinks/permissions inside the bundle (a plain zip corrupts a .app)
ditto -c -k --sequesterRsrc --keepParent "$APP" "$REPO_ROOT/AltTabDebug.zip"
echo "Packaged: $REPO_ROOT/AltTabDebug.zip"
