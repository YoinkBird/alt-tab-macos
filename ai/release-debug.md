# Debug release: build AltTabDebug on CI and install it elsewhere

One command builds `AltTabDebug.app` on GitHub Actions and downloads it so you can
install it on another machine:

```
$ ai/release-debug.sh --set-default
```

This pushes the current branch, ensures the GitHub default branch points at it,
dispatches the `debug-build` workflow, waits for it, and downloads the artifact
(`AltTabDebug.zip`) into the current directory. Run `ai/release-debug.sh --help`
for flags (`--branch`, `--out`, `--dry-run`).

## The "magic" it encapsulates

- **Why the default branch matters.** The build uses a manual (`workflow_dispatch`)
  trigger. GitHub only exposes that trigger if the workflow file lives on the repo's
  default branch, so the script asserts default branch == build branch (and refuses
  to change it unless you pass `--set-default`).
- **What gets built.** The `Debug` scheme via `ai/build-debug-ci.sh`, which sets
  `ADHOC_SIGN=1` so `ai/build.sh` ad-hoc signs (the local "Local Self-Signed"
  keychain identity from `config/debug.xcconfig` does not exist on CI runners).
- **The download is double-zipped.** GitHub wraps every artifact in its own zip, and
  the app is already a zip, so unzip twice to reach `AltTabDebug.app`.

## Install on another machine

```
$ unzip AltTabDebug.zip               # GitHub wrapper -> AltTabDebug-<version>.zip
$ unzip AltTabDebug-*.zip             # -> AltTabDebug.app
$ mv AltTabDebug.app /Applications/
```

The `<version>` comes from `git describe --tags` (e.g. `v10.12.0-27-geac17c17`):
`ai/build-debug-ci.sh` stamps it into the app's `CFBundleShortVersionString` and the
zip filename, so each build is self-identifying. The GitHub artifact name stays the
stable `AltTabDebug` so `gh run download --name AltTabDebug` keeps working.

First launch is blocked once because the build is ad-hoc signed (not notarized):
open **System Settings > Privacy & Security**, then click **Open Anyway**. Then
grant **Accessibility** and **Screen Recording**. It runs alongside a brew-installed
`alt-tab` (separate `com.lwouis.alt-tab-macos.debug` bundle id).

## Make it nicer later

- **Auto-installing `.pkg`** (no drag, no second unzip): replace the `ditto` zip in
  `ai/build-debug-ci.sh` with `pkgbuild`.
- **Zero-friction installs** (no "Open Anyway"): sign with your own Apple Developer ID
  and notarize, reusing the release pipeline's notarization step.
- **Human-facing version numbers**: tag your own fork releases (`git tag v10.13.0`);
  `git describe` then builds off your tags instead of `v10.12.0-<n>-g<sha>`. Upstream
  has since moved to 11.x; you forked at the end of 10.x.

## Files

- `.github/workflows/debug_build.yml`: the manual workflow
- `ai/build-debug-ci.sh`: build + zip
- `ai/build.sh`: `ADHOC_SIGN=1` support
- `ai/release-debug.sh`: the one-command orchestrator
