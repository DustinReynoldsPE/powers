---
name: finishing-branch
description: Complete work on a development branch. Use after tests pass to merge locally, create a PR, keep the branch, or discard it. Handles worktree cleanup and ticket stage updates.
---

# Finishing a Development Branch

Complete work on a ticket branch. Verifies readiness, presents finish options, cleans up worktree and branch.

**Called by:** `create-feature` Phase 7-8, `create-bug` equivalent phase, or invoked manually.

## Pre-Flight Checks

Before presenting options, verify:

### 1. All changes committed

```bash
git status --porcelain
```

If uncommitted changes exist, stop:
> Uncommitted changes detected. Commit or stash before finishing.

### 2. Tests pass

```bash
# Detect and run test suite (same detection as using-git-worktrees Step 4)
```

If tests fail, stop:
> Tests are failing. Fix before finishing, or use `--force` to override.

### 3. Ticket stage

```bash
tk show <ticket-id>
```

Ticket should be at `test` or later. If still at `implement` or earlier, warn:
> Ticket is still at `<stage>`. Advance to `test` before finishing, or proceed anyway?

## Finish Options

Present these four options to the user:

### Option 1: Create Pull Request (recommended)

Push branch and create a PR for review.

```bash
# Push branch to remote
git push -u origin <ticket-id>

# Create PR with ticket context
gh pr create \
  --title "[<ticket-id>] <ticket title>" \
  --body "$(cat <<'EOF'
## Summary
<1-3 bullet points describing the change>

## Ticket
`<ticket-id>`: <ticket title>

## Test plan
<verification steps>
EOF
)"
```

**If `gh` is not authenticated:**
> `gh` CLI is not authenticated. Push the branch manually and create PR at:
> `https://github.com/<owner>/<repo>/pull/new/<ticket-id>`

```bash
git push -u origin <ticket-id>
```

**After PR created:**
```bash
tk advance <ticket-id> --to test
tk add-note <ticket-id> "PR created: <pr-url>"
```

Worktree is **kept** — work may continue if PR review requests changes. The user can clean up later with Option 4 after merge.

### Option 2: Merge Locally

Merge the branch into main without a PR.

```bash
# Return to main repo
cd <original-repo-path>

# Update main
git checkout main
git pull --ff-only

# Merge with merge commit for history
git merge --no-ff <ticket-id> -m "[<ticket-id>] <ticket title>"

# Push
git push
```

**After merge:**
```bash
tk advance <ticket-id> --to test

# Clean up worktree and branch
git worktree remove .claude/worktrees/<ticket-id>
git branch -d <ticket-id>
```

### Option 3: Keep As-Is

Leave the branch and worktree in place. No cleanup, no stage change.

Use when:
- Work is not done but you want to pause
- Waiting on external dependency
- Want to review before deciding

```bash
tk add-note <ticket-id> "Branch <ticket-id> kept as-is. Resume with /work-ticket <ticket-id>."
```

### Option 4: Discard

Delete the branch and all work on it. **This is destructive and irreversible.**

Confirm before proceeding:
> This will delete branch `<ticket-id>` and all commits on it. Are you sure?

Only proceed with explicit confirmation.

```bash
# Return to main repo
cd <original-repo-path>
git checkout main

# Remove worktree (force — may have changes)
git worktree remove --force .claude/worktrees/<ticket-id>

# Delete branch
git branch -D <ticket-id>

# Delete remote branch if pushed
git push origin --delete <ticket-id> 2>/dev/null || true
```

**After discard:**
```bash
tk advance <ticket-id> --to triage
tk add-note <ticket-id> "Branch discarded. Work was deleted."
```

## Working Without a Worktree

If the branch was created without a worktree (direct `git checkout -b`), the same options apply but skip worktree cleanup steps. Detect by checking:

```bash
git worktree list | grep <ticket-id>
```

If no worktree found, skip `git worktree remove` in all paths.

## Summary of Outcomes

| Option | Branch | Worktree | Remote | Ticket Stage |
|--------|--------|----------|--------|--------------|
| Create PR | kept | kept | pushed | `test` |
| Merge locally | deleted | deleted | pushed (via main) | `test` |
| Keep as-is | kept | kept | no change | no change |
| Discard | deleted | deleted | deleted (if pushed) | `triage` |

## Error Handling

| Situation | Behavior |
|-----------|----------|
| `gh` not authenticated | Fall back to manual push + URL |
| Merge conflicts on local merge | Stop, surface conflict, ask user to resolve |
| Remote push fails | Surface error, suggest `git pull --rebase` |
| Worktree removal fails | Retry with `--force` if user chose discard |
| Branch already merged | Skip merge, proceed to cleanup |

## Integration

**Called by:**
- `powers:create-feature` Phase 7-8
- `powers:create-bug` equivalent phase

**References:**
- `powers:using-git-worktrees` for cleanup procedures
