# PR tracking: cancelShortcut key-window fix

**PR**: https://github.com/lwouis/alt-tab-macos/pull/5615
**Branch**: `fix/cancel-shortcut-key-window`
**Backup branch (full history, untrimmed)**: `fix/cancel-shorcut-key-window-raw`
**Status**: open, awaiting maintainer review

---

## Current PR title

`fix: Escape closes overlay reliably (cancelShortcut key-window bug)`

## Proposed PR description (preview — not yet applied)

```markdown
> [USER STORY — fill in your voice]
> I noticed that Escape didn't close the AltTab overlay and saw in #5018, #1835, #44 that others have hit this for years. I tried several workarounds (different shortcutStyle, killing competing apps) but none worked, so I dug into the event pipeline.

_Investigated and authored with the help of an agentic test harness (Claude Code) — repro scripts, debug log analysis, and the patch itself were iterated through automated tooling. All findings verified manually on real hardware._

## Summary

Fixes #5018, #1835, #44 — pressing Escape (or hold-modifier+Escape) does not close the AltTab overlay in some conditions.

## Root cause

`cancelShortcut` is `.local` scope, registered via `NSEvent.addLocalMonitorForEvents`, which only fires when `TilesPanel` is the key window. `TilesPanel` is a `.nonactivatingPanel` — macOS can revoke its key status before Escape is pressed, silently dropping the event. Confirmed via debug log: Cmd+Escape never reached `handleKeyboardEvent`.

The existing `flagsChanged` `CGEventTap` is `.listenOnly` and modifier-only, so it can't intercept Escape.

## Fix

Adds a second `CGEventTap` (`localShortcutEventTap`) at `.headInsertEventTap` on `kCGSessionEventTap`, with `.defaultTap` (can absorb), subscribed to `keyDown`. While `App.appIsBeingUsed`, it calls `handleKeyboardEvent(..., localOnly: true)`, which:

- Skips `scope == .global` shortcuts (already handled by `RegisterEventHotKey` + `KeyRepeatTimer`)
- Only intercepts `scope == .local` shortcuts (cancelShortcut etc.)

The `localOnly` filter was required to avoid a regression: without it, the new tap double-fired `nextWindowShortcut` alongside the Carbon hotkey handler, causing infinite window cycling on Cmd+Tab.

## Files

- `src/logic/events/KeyboardEvents.swift` — new `addCgEventTapForLocalShortcuts()` and `cgEventKeyDownHandler`
- `src/logic/events/KeyboardEventsTestable.swift` — `localOnly` parameter on `handleKeyboardEvent` / `triggerMatchingShortcuts`
- `ai/bug-escape-cancel-shortcut.md` — full investigation notes
- `ai/debug-escape.sh` — repro helper
- `ai/setup-dev.sh` — one-time dev environment setup

## Test plan

- [x] Cmd+Tab → release Tab → Escape closes overlay
- [x] Cmd+Tab cycling no longer loops infinitely
- [x] `bash ai/build.sh` succeeds
- [ ] Maintainer to verify on additional macOS versions / shortcut configs
```

## Pending: post as follow-up PR comment

```markdown
## Edge-case audit against contributing.md

Reviewed against the "Shortcuts" use-case list in docs/contributing.md:

**Verified working:**
- Local shortcuts active when overlay is open, with or without hold key held (the fix's target)
- `select next window` containing hold-key modifiers (Cmd hold + Cmd+Tab next)
- Repeat behavior on Cmd+Tab cycling (regression caught and fixed via `localOnly` filter)

**Not verified — flagging for maintainer QA:**
- Multi-modifier hold key (e.g. `⌥⇧`) — only Cmd was tested
- Capslock interactions
- Shortcut sets 1 and 2 isolation
- `focusOnRelease` / `doNothingOnRelease` modes (only `searchOnRelease` tested)
- International keyboard layouts
- **Secure Input** — the existing `flagsChanged` tap has a comment noting it survives Secure Input; the new `keyDown` tap may not. Worth verifying.
```

## Commits on branch

```
72fe5198 ci: add setup-dev.sh for one-time dev environment setup
3fe28db8 fix: intercept local shortcuts via CGEventTap when TilesPanel loses key focus
5ab3043f docs: add cancelShortcut bug report and investigation findings
8fb70144 ci: add debug-escape.sh for cancelShortcut repro
```

## Contrib-guidelines check

| Guideline | Status |
|-----------|--------|
| Title conveys the change | ✅ |
| Mention ticket | ✅ #5018, #1835, #44 |
| Conventional commits | ✅ |
| Manual QA done | ✅ (with caveats disclosed in follow-up comment) |

## Open questions / decisions

- [ ] User to write the one-line story in their own voice
- [ ] Apply description edit + post follow-up comment
- [ ] Consider testing the "Not verified" edge cases before maintainer review
