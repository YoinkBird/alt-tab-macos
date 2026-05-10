---
title: cancelShortcut key-window fix
pr: https://github.com/lwouis/alt-tab-macos/pull/5615
pr_number: 5615
branch: fix/cancel-shortcut-key-window
backup_branch: fix/cancel-shorcut-key-window-raw
status: open
fixes: [5018, 1835, 44]
companion_issue: https://github.com/lwouis/alt-tab-macos/issues/5616
companion_issue_number: 5616
companion_issue_title: "Escape doesn't close overlay when hold shortcut is Cmd (different root cause than #5018/#1835; proposed fix in #5615)"
description_synced: false
body_file: ai/pr-cancel-shortcut-key-window.body.md
---

# Tracker — cancelShortcut key-window fix

PR body is in [`pr-cancel-shortcut-key-window.body.md`](pr-cancel-shortcut-key-window.body.md). Edit there, then sync:

```bash
gh pr edit 5615 --repo lwouis/alt-tab-macos \
  --body-file ai/pr-cancel-shortcut-key-window.body.md
# then flip description_synced: true in this file's frontmatter
```

# PR title

`fix: Escape closes overlay reliably (cancelShortcut key-window bug)`

Update with:
```bash
gh pr edit 5615 --repo lwouis/alt-tab-macos \
  --title "fix: Escape closes overlay reliably (cancelShortcut key-window bug)"
```

# Companion issue

[#5616](https://github.com/lwouis/alt-tab-macos/issues/5616) — filed manually so the maintainer has a current open ticket pointing to this PR (#5018, #1835, #44 are all closed). Issue body lives in [`issue-body-cancel-shortcut.md`](issue-body-cancel-shortcut.md).

# Commits on branch

Live list:
```bash
git log upstream/master..HEAD --oneline
```

Last snapshot (run command above for current state):
```
72fe5198 ci: add setup-dev.sh for one-time dev environment setup
3fe28db8 fix: intercept local shortcuts via CGEventTap when TilesPanel loses key focus
5ab3043f docs: add cancelShortcut bug report and investigation findings
8fb70144 ci: add debug-escape.sh for cancelShortcut repro
```

`local:` commits (not for upstream — strip before push):
```bash
git log upstream/master..HEAD --oneline | grep '^[a-f0-9]* local:'
```

# Contrib-guidelines check

| Guideline | Status |
|-----------|--------|
| Title conveys the change | ✅ |
| Mention ticket | ✅ #5018, #1835, #44, #5616 |
| Conventional commits | ✅ |
| Manual QA done | ✅ (caveats in PR body Test plan) |

# Open questions / decisions

- [x] User to write the one-line story (line 28-31 of body file)
- [x] Companion issue filed (#5616)
- [ ] Sync PR body — `gh pr edit ...` then flip `description_synced: true`
- [ ] Decide whether to test "Not verified" edge cases ourselves before maintainer review
- [ ] Strip `local:` commits before any push of branch to upstream
