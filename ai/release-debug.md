# Debug release: build AltTabDebug on CI and install it elsewhere

One command builds `AltTabDebug.app` on GitHub Actions and downloads it so you can
install it on another machine:

```
$ ai/release-debug.sh --set-default
```

This pushes the current branch, ensures the GitHub default branch points at it,
dispatches the `debug-build` workflow, waits for it, and downloads the artifact
into the current directory. Run `ai/release-debug.sh --help` for flags
(`--branch`, `--out`, `--dry-run`).

The artifact contains two files for the same build: a `.pkg` double-click installer
(the easy path) and a `.zip` of the raw `.app` (for scripting or manual placement).

## The "magic" it encapsulates

- **Why the default branch matters.** The build uses a manual (`workflow_dispatch`)
  trigger. GitHub only exposes that trigger if the workflow file lives on the repo's
  default branch, so the script asserts default branch == build branch (and refuses
  to change it unless you pass `--set-default`).
- **What gets built.** The `Debug` scheme via `ai/build-debug-ci.sh`, which sets
  `ADHOC_SIGN=1` so `ai/build.sh` ad-hoc signs (the local "Local Self-Signed"
  keychain identity from `config/debug.xcconfig` does not exist on CI runners).
- **GitHub wraps artifacts in a zip.** So the download is `AltTabDebug.zip`; unzip it
  once to get the `.pkg` and `.zip` for the build.
- **Versioning.** `<version>` comes from `git describe --tags` (e.g.
  `v10.12.0-28-ge8c733f4`): `ai/build-debug-ci.sh` stamps it into the app's
  `CFBundleShortVersionString` and the file names, so each build is self-identifying.
  The GitHub artifact name stays the stable `AltTabDebug` so
  `gh run download --name AltTabDebug` keeps working.

## Install on another machine

Easy path (the `.pkg` installs to `/Applications` for you, no drag):

```
$ unzip AltTabDebug.zip            # GitHub wrapper -> AltTabDebug-<version>.pkg (+ .zip)
$ open AltTabDebug-*.pkg           # runs the installer wizard
```

First time, the unsigned `.pkg` is blocked once: open **System Settings > Privacy &
Security**, click **Open Anyway**, then re-open the pkg. The wizard asks for your admin
password and installs to `/Applications`. The installed app is not quarantined, so it
launches without a second prompt. Then grant **Accessibility** and **Screen Recording**.

Raw path (if you want the `.app` directly): `unzip AltTabDebug-*.zip` and move
`AltTabDebug.app` to `/Applications` yourself (that copy *is* quarantined, so you
clear it via **Open Anyway** on the app instead).

It runs alongside a brew-installed `alt-tab` (separate `com.lwouis.alt-tab-macos.debug`
bundle id).

## Make it nicer later

- **Zero-friction installs** (no "Open Anyway"): sign the pkg with your own Apple
  Developer ID *Installer* cert and notarize, reusing the release pipeline's
  notarization step.
- **Human-facing version numbers**: tag your own fork releases (`git tag v10.13.0`);
  `git describe` then builds off your tags instead of `v10.12.0-<n>-g<sha>`. Upstream
  has since moved to 11.x; you forked at the end of 10.x.

## Files

- `.github/workflows/debug_build.yml`: the manual workflow
- `ai/build-debug-ci.sh`: build + package (`.pkg` installer and `.zip`)
- `ai/build.sh`: `ADHOC_SIGN=1` support
- `ai/release-debug.sh`: the one-command orchestrator
