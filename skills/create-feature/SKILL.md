---
name: create-feature
description: Start a new feature with structured workflow. Brainstorm → plan → execute → test → commit → push.
---

# Feature Workflow

**Identity:** Full lifecycle for a new feature. Creates ticket, worktree, implements, tests, finishes branch. Use `work-ticket` to resume an existing feature.

**Modes:** `--auto` (skip STOP gates), `--subagent` (fresh subagent per task, 4+ task plans)

## Protocol

**Phase 1 — Brainstorm**
Gather context: relevant files, recent commits, open tickets. Ask one question at a time to understand problem, solution, constraints, success criteria. Invoke `powers:brainstorming` for complex design.

**Phase 2 — Create ticket**
```bash
tk create "<title>" --type feature --priority <1-3> -d "<description>"
```

**Phase 3 — Worktree**
Invoke `powers:using-git-worktrees` with the ticket ID.

**Phase 4 — Plan**
Write a numbered task list with acceptance criteria per task. Validate: does the plan cover the full ticket scope? If `--subagent`, invoke `powers:subagent-execution`.

**Phase 5 — Execute**
Implement tasks in order. Write checkpoint to ticket after each task.

**Phase 6 — Test**
Run the project's test/lint commands. Fix failures before proceeding.

**Phase 7 — Finish**
Invoke `powers:finishing-branch`.

## Quality Gates
- All tests pass
- Ticket has checkpoint block written
- No untracked changes left behind

## Exit Protocol
Write checkpoint block to ticket file before any pause.
