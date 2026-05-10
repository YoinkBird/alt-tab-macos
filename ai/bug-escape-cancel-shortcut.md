# Bug: Escape / Cmd+Escape does not close the AltTab overlay

**Labels**: bug
**Related**: #5018, #1835, #44
**Status**: FIXED (branch `alkjdla`)

---

## Describe the bug

Pressing Escape (or hold-modifier+Escape) while the AltTab overlay is open does nothing.
The overlay stays open.

Verified repro: hold shortcut = Cmd, shortcutStyle = searchOnRelease (overlay stays open after
releasing hold key):
1. Press Cmd+Tab — overlay opens
2. Release Tab — overlay stays open
3. Press Escape — nothing happens

Option+Escape (with Option as hold shortcut) works correctly on the same machine, ruling out
a generic Escape-handling problem.

## Root cause (confirmed via debug log)

`cancelShortcut` is registered as `.local` scope via `NSEvent.addLocalMonitorForEvents`. This
only fires when `TilesPanel` is the key window. The Cmd+Escape event never appeared in the
debug log — it was dropped before `handleKeyboardEvent` was ever called.

`TilesPanel` uses `.nonactivatingPanel`, so `makeKeyAndOrderFront` gives it key focus without
activating the app. macOS (or competing processes) can revoke that key status before Escape is
pressed, silently dropping the event before the local monitor sees it.

**Why AltTab's existing CGEventTap doesn't help**: It is `.listenOnly` and only subscribed to
`flagsChanged` (modifier keys only, not `keyDown`). It cannot intercept Escape.

## Fix (implemented)

Added a second `CGEventTap` (`localShortcutEventTap`) with `.defaultTap` (can absorb) on
`keyDown` events, installed at `.headInsertEventTap` on `.cgSessionEventTap`. While
`App.appIsBeingUsed`, it calls `handleKeyboardEvent(..., localOnly: true)`, which skips
shortcuts with `scope == .global` (nextWindowShortcut, holdShortcut — already handled by
`RegisterEventHotKey` + `KeyRepeatTimer`) and only handles `scope == .local` shortcuts
(cancelShortcut etc.).

The `localOnly` restriction was required to fix a secondary regression: without it, the tap
also fired for Tab/Cmd+Tab, double-triggering `nextWindowShortcut` alongside the Carbon hotkey
handler and `KeyRepeatTimer`, causing infinite window cycling.

Key files:
- `src/logic/events/KeyboardEvents.swift` — `addCgEventTapForLocalShortcuts()`, `cgEventKeyDownHandler`
- `src/logic/events/KeyboardEventsTestable.swift` — `localOnly` parameter on `handleKeyboardEvent` / `triggerMatchingShortcuts`

## Ruled out

### Apps suspected as event-stealers
- **Contexts.app** — killed; bug still reproduces
- **1Password / Secure Input** — killed; reproduces on machines with no password manager
- **Witch, Overflow, HiDock** — none running on test machines
- **GameOverlay (Game Center)** — disabled; Option+Escape works fine on the same machine, ruling out generic Escape blocking
- **Rectangle, other window managers** — not present

### Conditions tested
- **shortcutStyles**: `focusOnRelease`, `doNothingOnRelease`, `searchOnRelease` — last one is most reliable repro (overlay stays open, forcing Escape as the dismiss path)
- **Hold keys**: Option+Escape works → Cmd+Escape fails. Bug is Cmd-specific, not generic Escape blocking
- **Multiple machines**: reproduces on a second laptop with no password manager and no Contexts.app

### Code paths investigated
- `ATShortcut.modifiersMatch` — verified correct for Cmd+Escape; would handle the event if it arrived
- Existing `flagsChanged` `CGEventTap` — confirmed `.listenOnly` and modifier-only, can't help

### Smoking gun
Debug log showed `keys:⌘c` arriving at `handleKeyboardEvent` while the overlay was open, but
`keys:⌘<esc>` never appeared — the event was dropped before AltTab could see it.

### False starts during fix development
- Initial `CGEventTap` (no `localOnly` filter) → infinite Cmd+Tab cycling because the new tap
  double-fired `nextWindowShortcut` alongside the Carbon hotkey handler. Fixed by adding the
  `localOnly` filter to skip global-scope shortcuts.
- Initial hypothesis blamed Contexts.app before the user confirmed it wasn't running.

## Linked tickets — status and prior fixes tried

All three linked tickets are **CLOSED** but the underlying problem still reproduces:

| # | State | Comments | Last activity | Title |
|---|-------|----------|---------------|-------|
| 5018 | CLOSED | 11 | 2026-01-19 | Cancel and hide control not working with Escape |
| 1835 | CLOSED | 17 | 2026-01-06 | Cannot use [esc] key to "cancel and hide" with Hyper modifiers |
| 44   | CLOSED | 3  | 2019-10-25 | Close on Esc (original feature request) |

### Most common fixes / workarounds suggested in those tickets

1. **Disable Game Overlay** (macOS 26 Tahoe) — System Settings → Keyboard → Keyboard Shortcuts → Mission Control → uncheck "Game Overlay". Most-upvoted fix in #5018 / #1835. Tried — doesn't resolve our bug, but confirmed it's the standard suggestion.
2. **Conflicts warning** added in v7.33+ for hard-reserved combos (`⌘⌥⎋`, `⌘⌥⇧⎋`, `⌘⌥⇧⌃⎋`). Doesn't apply to Cmd+Escape (which can be disabled via Game Overlay toggle).
3. **`ShortcutDetective`** — third-party tool to identify which process is grabbing a shortcut. One reporter (@rennsax) used it to identify `universalaccessd` hijacking `⌘⎋`.
4. **Kill `universalaccessd`** — releases `⌘⎋` temporarily; macOS relaunches it.
5. **Reboot** — temporarily releases the shortcut from MPV (which Tahoe detects as a "game" → hijacks `⌘⎋`).
6. **`defaults write com.lwouis.alt-tab-macos.plist`** — bypass the Settings UI to set shortcuts that the conflicts warning blocks.
7. **Roll back to v7.32** — pre-conflicts-warning, lets the user re-enable Cmd+Escape (workaround, not a fix).

### Reserved-by-macOS Escape combos (per @lwouis in #1835)

```swift
// Introduced in macOS 26 (Tahoe). Toggleable in System Settings.
gameOverlay              = ⌘⎋
// Ancient. Hard-set, can't be disabled.
forceQuitApplications    = ⌘⌥⎋
forceQuitActiveApp       = ⌘⌥⇧⎋
reservedForUnknownReason = ⌘⌥⇧⌃⎋
```

### Why our PR adds something new

The existing tickets converged on "macOS hijacks Escape, the user must reconfigure". Our debug log showed the event genuinely never arrives at AltTab's handler — but the cause is `TilesPanel` losing key-window status, not a kernel-level reservation. A `CGEventTap` at `.headInsertEventTap` intercepts the event before whatever drops it, restoring the cancel path without requiring users to disable Game Overlay or remap their shortcut.

## Separate bug (to file later)

When AltTab shows a "conflicting shortcut" warning for GameOverlay (Cmd+Escape), it opens
System Settings → Keyboard → Modifier Keys — the wrong pane. Also a false positive since
Game Center is disabled.

## Your environment

* AltTab version: 10.12.0
* macOS version: 15.x (Sequoia)
* Hold shortcut: Cmd
* Reproduces on: multiple machines, no competing apps needed
