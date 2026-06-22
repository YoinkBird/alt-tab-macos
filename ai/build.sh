#!/usr/bin/env bash
# NOTE: First run will prompt for keychain password multiple times: click "Always Allow" each time.
# Set ADHOC_SIGN=1 to build with ad-hoc signing ("-") instead of the local "Local Self-Signed"
# identity from config/debug.xcconfig. Used by CI, where that keychain identity does not exist.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DERIVED_DATA="${DERIVED_DATA:-$REPO_ROOT/DerivedData}"

sign_args=()
if [[ "${ADHOC_SIGN:-0}" == "1" ]]; then
  sign_args=(CODE_SIGN_IDENTITY="-" CODE_SIGN_STYLE=Manual CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=YES)
fi

xcodebuild \
  -workspace "$REPO_ROOT/alt-tab-macos.xcworkspace" \
  -scheme Debug \
  -configuration Debug \
  -derivedDataPath "$DERIVED_DATA" \
  ${sign_args[@]+"${sign_args[@]}"}
