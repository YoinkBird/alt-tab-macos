## Pattern 4: dev built ON TOP of release

```
master       ●─────●─────●────────●  (upstream)
              \
pr/<topic>     ●─●─●            (clean, public, push to origin, this is the PR)
                    \
dev/<topic>          ●─●─●─●    (= pr/<topic> + scratch commits stacked)
```

**Invariant:** `dev/<topic>` always has `pr/<topic>` as its ancestor. dev = pr + your local stuff.

### How edits flow

- **Publishable change** (fix code, docs for upstream): commit on `pr/<topic>` first → push. Then `git checkout dev/<topic>; git merge pr/<topic>` (fast-forward, no merge commit needed).
- **Scratch / tracker / `local:` commit**: commit on `dev/<topic>` only.
- **Reviewer asks for change**: edit on `pr/<topic>`, push (force or new commit). dev fast-forwards.

No cherry-picks. No history-borking. Real merges (or fast-forwards). Each commit exists in one place with one hash.

### Re: your file-separation idea

Yes; pair this with putting scratch in a known dir (`ai/.scratch/`, or `.local/`), and add a pre-push hook that rejects any push containing files in that path. Belt + suspenders against accidentally pushing local stuff via the wrong branch.

### "Cut a release / merge back"

Maps cleanly: each push to `pr/<topic>` is a "release". `dev` "merges back" via fast-forward; no work. If a scratch commit on dev later turns out to belong upstream, cherry-pick that ONE commit to `pr/<topic>` (rare, contained, explicit).

### Applying to current state

Your existing branch `fix/cancel-shortcut-key-window` has both publishable (`docs:`, `fix:`, `ci:`) and scratch (`local:`) commits interleaved. To convert to the new pattern:

1. Create `pr/cancel-shortcut-key-window` = current branch with `local:` commits dropped (one rebase)
2. Make `dev/cancel-shortcut-key-window` = current branch as-is, just renamed (or kept)
3. Going forward, follow the rule: publishable → pr branch first, then dev fast-forwards

For your two upcoming PRs (gameoverlay + contributing-tests), start fresh with the pattern from day one.
