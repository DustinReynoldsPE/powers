---
name: finishing-branch
description: Complete work on a development branch. Closes worktree if one exists. Use after tests pass.
---

# Finishing a Branch

**Identity:** Completes a feature or bug branch. Handles worktree cleanup. Always called as the last step of `create-feature`, `create-bug`, or `work-ticket`.

## Pre-Flight

Before choosing an option, verify:
1. All changes committed (`git status` is clean)
2. Tests pass
3. Ticket advanced to correct stage (`tk advance <id>` if not done)

## Options

**Option 1 — Pull Request (default for features)**
```bash
git push -u origin <branch>
gh pr create --title "<title>" --body "<summary>"
```
Then clean up worktree (see below).

**Option 2 — Merge locally (for chores, small tasks)**
```bash
cd <repo-root>
git merge --no-ff <branch> -m "Merge <branch>"
```
Then clean up worktree (see below).

**Option 3 — Keep branch (work in progress)**
Write checkpoint block to ticket. Stop here.

**Option 4 — Discard**
```bash
cd <repo-root>
git worktree remove .claude/worktrees/<ticket-id> --force
git branch -D <ticket-id>
```
Update ticket: `tk add-note <id> "Discarded: <reason>"`

## Worktree Cleanup (Options 1 & 2)

After merge or PR is open:
```bash
cd <repo-root>
git worktree remove .claude/worktrees/<ticket-id>
git branch -d <ticket-id>
```

If no worktree was used, skip cleanup.

## Quality Gates
- Branch merged or PR open
- Worktree removed (if one existed)
- Ticket at correct stage

## Exit Protocol
Write `<!-- checkpoint: finalized -->` to ticket file.
