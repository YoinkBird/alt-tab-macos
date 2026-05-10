---
title: AltTab conflict warning opens wrong System Settings pane
status: noted, not yet filed
discovered_during: cancelShortcut investigation (PR #5615)
priority: low
---

# Bug: conflict warning for `⌘⎋` opens wrong System Settings pane

## What we observed

When AltTab shows a "conflicting shortcut" warning for `⌘⎋` (GameOverlay), clicking the
warning's link opens **System Settings → Keyboard → Modifier Keys** — the wrong pane. The
correct pane is **System Settings → Keyboard → Keyboard Shortcuts → Mission Control** (where
Game Overlay is actually toggleable).

Additional issue: it's also a **false positive** in some setups — the warning fires even
when Game Center / Game Overlay is already disabled.

## Where it likely lives in the code

Search candidates:
- Wherever `Modifier Keys` or related deep-link is constructed (likely `x-apple.systempreferences:`
  URL with the wrong anchor)
- The conflict-warning logic added in v7.33+ for hard-reserved combos

## When to file

Lower priority than the cancelShortcut fix. File when:
- The cancelShortcut PR (#5615) lands, OR
- You hit it again while doing something else

## Draft issue title

`Conflict warning for ⌘⎋ opens wrong System Settings pane (Modifier Keys instead of Mission Control); also false-positives when Game Overlay is disabled`
