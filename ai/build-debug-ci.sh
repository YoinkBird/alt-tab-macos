#!/usr/bin/env bash
# Build AltTabDebug.app (ad-hoc signed, no keychain identity needed) and package it
# for upload as CI artifacts: a .zip (raw .app) and a double-click .pkg installer.
# Invoked by .github/workflows/debug_build.yml.
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

WORK="$(mktemp -d)"
trap 'mv -f "$INFO.orig" "$INFO"; rm -rf "$WORK"' EXIT

# --- .zip (raw .app); ditto preserves symlinks/permissions inside the bundle ---
ZIP="$REPO_ROOT/AltTabDebug-$VERSION.zip"
rm -f "$ZIP"
ditto -c -k --sequesterRsrc --keepParent "$APP" "$ZIP"
echo "Packaged: $ZIP"

# --- .pkg (double-click installer that copies the app to /Applications) ---
STAGE="$WORK/root"; mkdir -p "$STAGE"
ditto "$APP" "$STAGE/AltTabDebug.app"
# BundleIsRelocatable=NO forces install to /Applications rather than over an existing copy elsewhere
pkgbuild --analyze --root "$STAGE" "$WORK/component.plist"
plutil -replace 0.BundleIsRelocatable -bool NO "$WORK/component.plist"
PKG="$REPO_ROOT/AltTabDebug-$VERSION.pkg"
rm -f "$PKG"
pkgbuild \
  --root "$STAGE" \
  --component-plist "$WORK/component.plist" \
  --install-location /Applications \
  --identifier com.lwouis.alt-tab-macos.debug \
  --version "$VERSION" \
  "$PKG"
echo "Packaged: $PKG"
