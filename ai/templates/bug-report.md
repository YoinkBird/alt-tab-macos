# Bug: {{short summary, e.g. "Escape does not close the AltTab overlay"}}

**Labels**: bug
**Related**: {{[#NNN](https://github.com/lwouis/alt-tab-macos/issues/NNN), [#NNN](https://...), ...}}
**Status**: {{open | INVESTIGATING | FIXED on branch `<branch-name>`}}

---

## Describe the bug

{{1-2 paragraph plain-English description of what happens and what should happen.}}

Verified repro: {{conditions, e.g. hold shortcut = Cmd, shortcutStyle = searchOnRelease}}:
1. {{step}}
2. {{step}}
3. {{step}}

{{Optional: contrast with a working configuration that rules out generic causes,
e.g. "Option+Escape works on the same machine, ruling out a generic Escape problem."}}

## Root cause (confirmed via {{evidence type, e.g. debug log, lldb, instrumentation}})

{{Plain explanation of the underlying cause. Cite specific identifiers
(`ClassName`, `methodName`, file paths) where relevant. End with a sentence
about *why* the bug manifests under the repro conditions.}}

**Why {{existing mitigation, if any}} doesn't help**: {{explanation of what was
already in place and why it falls short for this case}}.

## Fix ({{implemented | proposed}})

{{Description of the change at the level of: what new mechanism, where it
lives, what it intercepts/handles, and any subtle invariant it preserves.
Include any regression-avoidance reasoning (e.g. "X filter required to avoid
double-firing of Y").}}

Key files:
- `path/to/File.swift`: {{what changed}}
- `path/to/OtherFile.swift`: {{what changed}}

## Ruled out

### {{Category, e.g. "Apps suspected as event-stealers"}}
- **{{thing}}**: {{outcome, e.g. "killed; bug still reproduces"}}
- **{{thing}}**: {{outcome}}

### Conditions tested
- **{{condition variable}}**: {{values tested, which reproduce/don't}}
- **{{condition variable}}**: {{values tested}}

### Code paths investigated
- `{{symbol/path}}`: {{conclusion, e.g. "verified correct; would handle the event if it arrived"}}

### Smoking gun
{{The single observation that pinned the root cause. Often a log line, a
breakpoint hit, or a missing event.}}

### False starts during fix development
- {{first wrong hypothesis or fix attempt}}: {{why it was wrong}}
- {{second wrong hypothesis}}: {{why it was wrong}}

## Linked tickets — status and prior fixes tried

{{Use the gh-comment-survey snippet (ai/templates/gh-comment-survey.sh) to enumerate.}}

| # | State | Comments | Last activity | Title |
|---|-------|----------|---------------|-------|
| [#NNN](url) | OPEN/CLOSED | N | YYYY-MM-DD | {{title}} |
| [#NNN](url) | OPEN/CLOSED | N | YYYY-MM-DD | {{title}} |

### Most common fixes / workarounds suggested in those tickets

1. **{{fix name}}**: {{summary; cite a comment-level deep link}}. {{Did it
   resolve our bug? Why not?}}
2. **{{fix name}}**: ...

### Why our PR adds something new

{{One paragraph: what the existing tickets converged on, why the underlying
problem still reproduces, and what your PR addresses that the prior
discussion missed.}}

## Your environment

* AltTab version: {{e.g. 10.12.0}}
* macOS version: {{e.g. 26.4.1 Tahoe}}
* Hold shortcut: {{e.g. Cmd; or "default (Option)"}}
* Reproduces on: {{e.g. "multiple machines, no competing apps needed"}}
