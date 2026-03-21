---
name: using-git-worktrees
description: Create an isolated git worktree for ticket-based development. Use when starting work on a feature or bug that needs branch isolation or PR-based review.
---

# Git Worktrees

**Identity:** Creates a worktree per ticket. Branch name = ticket ID. Cleanup is handled by `powers:finishing-branch` — do not delete worktrees here.

**Do not use for:** chores, docs-only tasks, or quick fixes where a PR isn't needed.

## Create

```bash
# From the repo root
git checkout main && git pull --ff-only
git worktree add .claude/worktrees/<ticket-id> -b <ticket-id>
cd .claude/worktrees/<ticket-id>
```

Ensure `.claude/worktrees/` is in `.gitignore`.

## Enter Existing Worktree

```bash
cd <repo-root>/.claude/worktrees/<ticket-id>
```

## Project Setup

Run any project-specific setup needed in the worktree (install deps, build, etc.) — same as you would in a fresh checkout.

## Cleanup

Done by `powers:finishing-branch`. Do not remove the worktree manually unless discarding.

## Error Handling

- `already exists`: worktree was created previously — just `cd` into it
- `branch already exists`: `git worktree add ... <ticket-id>` with existing branch — add `--checkout` flag
