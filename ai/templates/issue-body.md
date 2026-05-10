**Describe the bug**

{{1-paragraph plain-English summary of what happens. Mention any closed/related
tickets and explain why this is distinct (or why those didn't resolve it for
you), e.g.: "Three closed tickets describe variants of this — #X, #Y, #Z — but
the underlying problem still reproduces on macOS NN.N when ..."}}

{{Optional: 1-paragraph summary of root cause, kept high-level for the issue.
Detailed investigation goes in the linked bug-report doc / PR.}}

I have a {{proposed fix | fix}} in PR #NNNN that {{1-line of what the PR does}},
and would appreciate review.

**Steps to reproduce the bug**

> ⚠️ **Important**: {{any non-default config required to reproduce — e.g.
> changing the default hold shortcut, enabling/disabling a feature. Be explicit
> if defaults don't trigger the bug, since that explains why the bug evades
> triage.}}

Configuration:
- {{config item}}: {{value}} ({{e.g. "changed from default X"}})
- {{config item}}: {{value}}

1. {{step 1}}
2. {{step 2}}
3. {{step 3}}

Expected: {{outcome}}.
Actual: {{outcome}}.

{{Optional: contrast with a working configuration, e.g. "With default hold
shortcut, X works correctly on the same machine — confirming the bug is
specific to ..."}}

**Already tried (recommendations from {{related tickets}})**

Related bug reports / comments reviewed:
- [#NNN — @author: 1-line summary](comment-deep-link)
- [#NNN — @author: 1-line summary](comment-deep-link)
- ...

What I tested:
- ✅ {{thing tried}} {{outcome}}
- ✅ {{thing tried}} {{outcome}}
- ✅ Confirmed via {{evidence}}: {{observation}}

**Root cause and {{proposed fix | fix}}**

Full investigation: [`ai/bug-{{slug}}.md`](https://github.com/{{owner}}/{{repo}}/pull/NNNN/files) (added in PR #NNNN; link points to all changed files; scroll to that doc).

Short version:
- {{1-line root cause statement}}
- {{1-line about why existing handling/mitigation doesn't cover it}}
- Fix: {{1-2 lines on the change}}

**PR**

#NNNN

**Your environment**

* AltTab version: {{x.y.z}}
* macOS version: {{N.N.N (codename)}}
* Other relevant info: {{config that matters; reproduces on multiple machines? etc.}}
