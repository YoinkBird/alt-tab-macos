**Describe the bug**

Pressing Escape (or hold-modifier+Escape) does not close the AltTab overlay in some configurations. Three closed tickets describe variants of this — #5018, #1835, #44 — but the underlying problem still reproduces on macOS 26 Tahoe when the hold shortcut is Cmd.

The closed tickets converged on "macOS reserves the shortcut, disable Game Overlay or rebind." On a clean machine with Game Overlay disabled and no third-party event-stealers running, the bug still occurs — pointing to a different root cause: AltTab's `cancelShortcut` is `.local` scope (`NSEvent.addLocalMonitorForEvents`), which only fires when `TilesPanel` is the key window. `TilesPanel` is a `.nonactivatingPanel`, and macOS can revoke its key-window status before Escape is pressed, silently dropping the event.

I have a fix in PR #5615 that adds a `CGEventTap` to intercept the event before it's dropped, and would appreciate review.

**Steps to reproduce the bug**

> ⚠️ **Important**: this requires changing the **default hold shortcut from Option (`⌥`) to Command (`⌘`)** — i.e. configuring AltTab to mimic the native macOS Cmd+Tab. This is a very common rebind, but it's likely why the bug has been hard to triage: AltTab's defaults don't trigger it. Reproduction *requires* the user to have changed their hold shortcut to Cmd.

Configuration:
- Hold shortcut: **`Cmd`** (changed from default `Option`)
- `shortcutStyle`: `searchOnRelease` (overlay stays open after release)

1. Press `Cmd`+`Tab` — overlay opens
2. Release `Tab` (keep holding `Cmd`, or release everything — same result)
3. Press `Escape`

Expected: overlay closes.
Actual: nothing happens.

With the default `Option` hold shortcut, `Option`+`Escape` works correctly on the same machine — confirming the bug is specific to the `Cmd`-as-hold configuration and not a generic Escape-handling problem.

**Already tried (recommendations from #5018, #1835)**

- ✅ Disabled Game Overlay (System Settings → Keyboard → Keyboard Shortcuts → Mission Control)
- ✅ Killed `Contexts.app`, `1Password`. (Do not have `Witch`, `Overflow`, `HiDock`)
- ✅ Reproduced on a second machine with no password manager and no Contexts
- ✅ Tried [ShortcutDetective](https://www.irradiatedsoftware.com/labs/) (the diagnostic tool recommended in [#5018](https://github.com/lwouis/alt-tab-macos/issues/5018)) — got a deprecation/compatibility warning on launch. Already uninstalled so no specific output to share. The tool is vendor-classified as "Labs" / proof-of-concept, stuck at v1.0, no updates since the macOS 10.6 era — effectively unsupported on current macOS.
- ✅ Tested all three `shortcutStyle`s (`focusOnRelease` / `doNothingOnRelease` / `searchOnRelease`)
- ✅ Confirmed via debug log: `keys:⌘c` arrives at `handleKeyboardEvent`, `keys:⌘<esc>` never does — the event is dropped before AltTab's local monitor sees it

**Root cause and fix**

Full investigation: [`ai/bug-escape-cancel-shortcut.md`](https://github.com/lwouis/alt-tab-macos/blob/master/ai/bug-escape-cancel-shortcut.md) (added in PR #5615).

Short version:
- `cancelShortcut` is `.local` scope, only fires while `TilesPanel.isKeyWindow`
- `TilesPanel` is a `.nonactivatingPanel`; macOS can revoke its key status silently
- The existing `flagsChanged` `CGEventTap` is `.listenOnly` and modifier-only — can't intercept Escape
- Fix: add a second `CGEventTap` (`.defaultTap`, `keyDown`, `.headInsertEventTap`) that calls `handleKeyboardEvent(..., localOnly: true)` while `App.appIsBeingUsed`, intercepting local-scope shortcuts globally

**PR**

#5615

**Your environment**

* AltTab version: 10.12.0
* macOS version: 26.4.1 Tahoe
* Other relevant info: hold shortcut = `Cmd`; reproduces on multiple machines including a clean second laptop with no Contexts/1Password/Game Overlay
