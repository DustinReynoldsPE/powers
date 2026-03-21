---
name: create-bug
description: Start a bug fix with lean workflow. Investigate → fix → test → commit → push.
---

# Bug Workflow

**Identity:** Lean fix cycle for a known bug. Creates ticket, investigates root cause, fixes, tests, finishes branch. For bugs that turn out to be features, escalate to `create-feature`.

## Protocol

**Phase 1 — Create ticket**
```bash
tk create "<bug description>" --type bug --priority <1-3>
```

**Phase 2 — Worktree (optional)**
For bugs needing branch isolation: invoke `powers:using-git-worktrees` with the ticket ID.

**Phase 3 — Investigate**
Invoke `powers:investigate`. Do not write fixes during investigation.

**Phase 4 — Fix**
Implement the minimal fix. One concern only — no refactoring alongside the fix.

**Phase 5 — Test**
Run the project's test command. Confirm the bug is gone and no regressions.

**Phase 6 — Document root cause**
```bash
tk add-note <id> "Root cause: <what was wrong>. Fix: <what changed>."
```

**Phase 7 — Finish**
Invoke `powers:finishing-branch`.

## Quality Gates
- Bug is confirmed fixed (not just tests passing)
- Root cause documented in ticket
- No unrelated changes in the diff

## Exit Protocol
Write checkpoint block to ticket file before any pause.
