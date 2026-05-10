## Summary

Closes #NNNN. {{Related: #NNN, #NNN (if applicable; note their state if
closed-but-still-reproduces).}}

{{1-2 sentence plain-English description of what the PR does and why.}}

{{Optional: Contributor Journey block (delete if not using):

**Contributor Journey**:
{{1-2 sentence first-person story: noticed X, tried Y, fell back to digging
into Z. Honest, brief, in your voice.}}
}}

{{Optional: agentic-tooling disclosure (delete if not using):

_Investigated and authored with the help of an agentic test harness ({{tool
name}}): {{1-line summary of how the tooling was used}}. All findings verified
manually on real hardware._
}}

## Root cause

{{Plain technical explanation. Cite identifiers (`Class`, `method`) where
helpful. End with a sentence on why it manifests under the bug's repro
conditions.}}

{{Optional: 1-paragraph "why existing handling doesn't cover this" if useful.}}

## Fix

{{Description of the change, including any subtle invariant preservation, e.g.
"the X filter was required to avoid Y from double-firing alongside the Carbon
hotkey handler".}}

## Files

- `path/to/File.swift`: {{what changed}}
- `path/to/OtherFile.swift`: {{what changed}}
- `ai/bug-{{slug}}.md`: full investigation notes
- `ai/{{repro-helper}}.sh`: repro helper (if applicable)

## Test plan

{{Optional intro: "Mapped to the 'Shortcuts' use-case list in
[`docs/contributing.md`](docs/contributing.md)." — when applicable.}}

**Verified working:**
- [x] [{{description / quoted use-case from contributing.md}}]({{deep-link to
  contributing.md L<N> on PR branch}}): {{1-line about what was verified and how}}
- [x] {{plain item if no contributing.md mapping}}: {{1-line}}
- [x] `bash ai/build.sh` succeeds

**Not verified, flagging for maintainer QA:**
- [ ] {{thing not tested}}: {{why / what would need to be done}}
- [ ] {{thing not tested}}
