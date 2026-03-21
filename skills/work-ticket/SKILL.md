---
name: work-ticket
description: Resume work on an existing ticket based on its type and current state.
argument-hint: <ticket-id> [--auto]
---

# Resume Ticket Work

**Identity:** Resume or continue work on any ticket. Reads checkpoint markers to find where to pick up. Do not use to create tickets from scratch — use `create-feature` or `create-bug`.

## Orientation

```bash
tk show <ticket-id>
```

Read the ticket. Look for:
- `<!-- checkpoint: <phase> -->` — where the last session stopped
- `<!-- exit-state: ... -->` — what to do next
- `<!-- key-files: ... -->` — load-bearing paths to read first

## Protocol

**1. Find current state**

| Checkpoint | Resume at |
|---|---|
| none / `brainstorm` | Understand goal, plan approach |
| `planning` | Plan exists — begin implementation |
| `executing` | Mid-implementation — read exit-state, continue |
| `testing` | Implementation done — run tests |
| `finalized` | Done — call `powers:finishing-branch` |

If no checkpoint, infer from ticket stage and content.

**2. Do the work**

- Feature/task: implement → test → `powers:finishing-branch`
- Bug: investigate → fix → test → `powers:finishing-branch`
- Chore with no code: complete → `tk advance <id>`

**3. Before each natural pause, write exit block to the ticket file:**

```
<!-- checkpoint: <triage|spec|design|implement|test|verify|finalized> -->
<!-- exit-state: <one sentence: what was done, immediate next step> -->
<!-- key-files: <comma-separated load-bearing paths> -->
<!-- open-questions: <unresolved items or 'none'> -->
```

## Quality Gates

- Acceptance criteria in the ticket are met
- Tests pass (run the project's test command)
- Exit block written to ticket file

## Auto Mode

`--auto`: skip confirmation prompts, tag decisions with `(auto)`, proceed through all phases.
