#!/usr/bin/env bash
# Build AltTabDebug.app (ad-hoc signed, no keychain identity needed) and zip it
# for upload as a CI artifact. Invoked by .github/workflows/debug_build.yml.
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# Derive a proper version from git instead of the unreplaced #VERSION# placeholder.
# e.g. "v10.12.0-27-geac17c17" (27 commits past v10.12.0, at commit eac17c17).
VERSION="$(git -C "$REPO_ROOT" describe --tags --always)"
echo "Version: $VERSION"

# Stamp it into Info.plist for this build, then restore the file so a local run never
# leaves the tracked Info.plist dirty (the release pipeline does the same in CI only).
INFO="$REPO_ROOT/Info.plist"
cp "$INFO" "$INFO.orig"
trap 'mv -f "$INFO.orig" "$INFO"' EXIT
sed -i '' -e "s/#VERSION#/$VERSION/" "$INFO"

ADHOC_SIGN=1 bash "$REPO_ROOT/ai/build.sh"

APP="$REPO_ROOT/DerivedData/Build/Products/Debug/AltTabDebug.app"
[[ -d "$APP" ]] || { echo "ERROR: $APP not found after build" >&2; exit 1; }

# ditto preserves symlinks/permissions inside the bundle (a plain zip corrupts a .app)
ZIP="$REPO_ROOT/AltTabDebug-$VERSION.zip"
rm -f "$ZIP"
ditto -c -k --sequesterRsrc --keepParent "$APP" "$ZIP"
echo "Packaged: $ZIP"
