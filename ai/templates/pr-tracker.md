---
title: {{topic short name}}
pr: https://github.com/{{owner}}/{{repo}}/pull/NNNN
pr_number: NNNN
branch: {{branch-name}}
backup_branch: {{branch-name}}-raw
status: {{open | merged | closed}}
fixes: [{{issue-number, issue-number, ...}}]
companion_issue: {{url or null}}
companion_issue_number: {{N or null}}
companion_issue_title: "{{title or null}}"
description_synced: false
body_file: ai/pr-{{slug}}.body.md
---

# Tracker — {{topic}}

PR body lives in [`pr-{{slug}}.body.md`](pr-{{slug}}.body.md). Edit there, then sync:

```bash
gh pr edit NNNN --repo {{owner}}/{{repo}} \
  --body-file ai/pr-{{slug}}.body.md
# then flip description_synced: true in this file's frontmatter
```

# PR title

`{{conventional-prefix}}: {{title}}`

Update with:
```bash
gh pr edit NNNN --repo {{owner}}/{{repo}} \
  --title "{{conventional-prefix}}: {{title}}"
```

# Companion issue

{{[#NNN](url) — 1-line about why filed; or "n/a"}}. Issue body lives in [`issue-body-{{slug}}.md`](issue-body-{{slug}}.md).

# Commits on branch

Live list:
```bash
git log upstream/master..HEAD --oneline
```

# Contrib-guidelines check

| Guideline | Status |
|-----------|--------|
| Title conveys the change | {{✅/❌}} |
| Mention ticket | {{✅ #NNN, #NNN}} |
| Conventional commits | {{✅/❌}} |
| Manual QA done | {{✅ + caveats / ❌}} |

# Open questions / decisions

- [ ] {{open item}}
- [ ] {{open item}}
