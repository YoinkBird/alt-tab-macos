## Summary

Closes #5616. Related: #5018, #1835, #44 (closed but underlying problem still reproduces).

Pressing Escape (or hold-modifier+Escape) does not close the AltTab overlay in some conditions.

**Contributor Journey**:
I noticed that Escape didn't close the AltTab overlay and tried several workarounds and troubleshooting steps as outlined in #5018, #1835, #44.

I love AltTab and I figured I would see if I could help out by using Claude Code.

_Investigated and authored with the help of an agentic test harness (Claude Code): repro scripts, debug log analysis, and the patch itself were iterated through automated tooling. All findings verified manually on real hardware._

## Root cause

`cancelShortcut` is `.local` scope, registered via `NSEvent.addLocalMonitorForEvents`, which only fires when `TilesPanel` is the key window. `TilesPanel` is a `.nonactivatingPanel`; macOS can revoke its key status before Escape is pressed, silently dropping the event. Confirmed via debug log: Cmd+Escape never reached `handleKeyboardEvent`.

The existing `flagsChanged` `CGEventTap` is `.listenOnly` and modifier-only, so it can't intercept Escape.

## Fix

Adds a second `CGEventTap` (`localShortcutEventTap`) at `.headInsertEventTap` on `kCGSessionEventTap`, with `.defaultTap` (can absorb), subscribed to `keyDown`. While `App.appIsBeingUsed`, it calls `handleKeyboardEvent(..., localOnly: true)`, which:

- Skips `scope == .global` shortcuts (already handled by `RegisterEventHotKey` + `KeyRepeatTimer`)
- Only intercepts `scope == .local` shortcuts (cancelShortcut etc.)

The `localOnly` filter was required to avoid a regression: without it, the new tap double-fired `nextWindowShortcut` alongside the Carbon hotkey handler, causing infinite window cycling on Cmd+Tab.

## Files

- `src/logic/events/KeyboardEvents.swift`: new `addCgEventTapForLocalShortcuts()` and `cgEventKeyDownHandler`
- `src/logic/events/KeyboardEventsTestable.swift`: `localOnly` parameter on `handleKeyboardEvent` / `triggerMatchingShortcuts`
- `ai/bug-escape-cancel-shortcut.md`: full investigation notes
- `ai/debug-escape.sh`: repro helper
- `ai/setup-dev.sh`: one-time dev environment setup

## Test plan

Mapped to the "Shortcuts" use-case list in [`docs/contributing.md`](docs/contributing.md).

**Verified working:**
- [x] [**`cancelShortcut` (Escape) closes the overlay reliably**](https://github.com/YoinkBird/alt-tab-macos/blob/fix/cancel-shortcut-key-window/docs/contributing.md#L140): the fix's target; previously failed when `TilesPanel` lost key-window status
- [x] [_"Some shortcuts should only work when AltTab is open"_](https://github.com/YoinkBird/alt-tab-macos/blob/fix/cancel-shortcut-key-window/docs/contributing.md#L138): local-scope shortcuts now active whenever `appIsBeingUsed`, regardless of `TilesPanel.isKeyWindow`
- [x] [_"...active whether the hold shortcut is held or not"_](https://github.com/YoinkBird/alt-tab-macos/blob/fix/cancel-shortcut-key-window/docs/contributing.md#L139): verified for both hold-still-held and hold-released paths
- [x] [_"Shortcuts should have priority over system shortcuts such as `cmd+tab`"_](https://github.com/YoinkBird/alt-tab-macos/blob/fix/cancel-shortcut-key-window/docs/contributing.md#L133): the new tap installs at `.headInsertEventTap`, ahead of most other taps, improving priority for local-scope shortcuts
- [x] [`select next window` containing hold-key modifiers](https://github.com/YoinkBird/alt-tab-macos/blob/fix/cancel-shortcut-key-window/docs/contributing.md#L134): Cmd hold + Cmd+Tab next
- [x] [Shortcuts repeat if kept pressed](https://github.com/YoinkBird/alt-tab-macos/blob/fix/cancel-shortcut-key-window/docs/contributing.md#L142): regression caught and fixed via `localOnly` filter; without it, Cmd+Tab cycled infinitely from double-firing
- [x] `bash ai/build.sh` succeeds

**Not verified, flagging for maintainer QA:**
- [ ] Multi-modifier hold key (e.g. `⌥⇧`); only Cmd was tested
- [ ] Capslock interactions
- [ ] Shortcut sets 1 and 2 isolation
- [ ] `focusOnRelease` / `doNothingOnRelease` modes (only `searchOnRelease` tested)
- [ ] International keyboard layouts
- [ ] **Secure Input**: the existing `flagsChanged` tap has a comment noting it survives Secure Input; the new `keyDown` tap may not. Worth verifying.
