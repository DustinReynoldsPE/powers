---
name: using-git-worktrees
description: Create isolated git worktrees for ticket-based development. Use when starting work on a feature or bug ticket that needs branch isolation, parallel development, or PR-based review. Maps each worktree to a tk ticket ID.
---

# Using Git Worktrees

Create an isolated workspace for a ticket. Each worktree gets its own branch named after the ticket ID, enabling parallel work and PR-based review.

## When to Use

- Starting a feature or bug that should be reviewed via PR
- Working on multiple tickets in parallel (each gets its own worktree)
- Any work that benefits from branch isolation

**Called by:** `create-feature` Phase 2.5 (after ticket creation, before planning)

**Do not use when:**
- Quick fix on the current branch is sufficient
- Ticket is a chore or task that doesn't need review

## Step 1: Create Worktree

```bash
# Ensure we're on the main branch and up to date
git checkout main
git pull --ff-only

# Create worktree with ticket ID as branch name
git worktree add .claude/worktrees/<ticket-id> -b <ticket-id>
```

**Branch convention:** Branch name = ticket ID (e.g., `p-1234`, `git-worktree-integration-9f15`). This makes branches traceable to tickets.

**Worktree location:** `.claude/worktrees/<ticket-id>/` — inside the `.claude/` directory, which is typically gitignored.

### Verify .gitignore

Check that `.claude/worktrees/` is covered by `.gitignore`:

```bash
# Check if .claude/ or .claude/worktrees/ is gitignored
git check-ignore -q .claude/worktrees/test 2>/dev/null
```

If not ignored, add it:

```bash
echo ".claude/worktrees/" >> .gitignore
git add .gitignore
git commit -m "Add .claude/worktrees/ to .gitignore"
```

## Step 2: Enter Worktree

```bash
cd .claude/worktrees/<ticket-id>
```

The Bash working directory persists across tool calls. All subsequent file operations, git commands, and tool calls will operate in the worktree.

Confirm you're in the right place:

```bash
git branch --show-current  # Should show <ticket-id>
pwd                        # Should show .claude/worktrees/<ticket-id>
```

## Step 3: Project Setup

Detect the package manager and run install. Check in order:

| File | Command |
|------|---------|
| `bun.lockb` or `bun.lock` | `bun install` |
| `package-lock.json` | `npm install` |
| `yarn.lock` | `yarn install` |
| `pnpm-lock.yaml` | `pnpm install` |
| `requirements.txt` | `pip install -r requirements.txt` |
| `Pipfile` | `pipenv install` |
| `pyproject.toml` | `pip install -e .` |
| `Gemfile` | `bundle install` |
| `go.mod` | `go mod download` |

If none found, skip setup — project may not need it.

If setup fails, warn but continue. The worktree is still usable.

## Step 4: Test Baseline

Run the test suite to establish a clean baseline before making changes.

Detect the test runner:

| File/Config | Command |
|-------------|---------|
| `bun.lockb` + `package.json` has test script | `bun test` |
| `package.json` has test script | `npm test` |
| `pytest.ini` or `pyproject.toml` with pytest | `pytest` |
| `Makefile` with test target | `make test` |

**If tests pass:** Baseline verified. Any future failures are from our changes.

**If tests fail:** Log the failures but do not block.

```bash
tk add-note <ticket-id> "## Worktree Setup

Branch: <ticket-id>
Path: .claude/worktrees/<ticket-id>
Baseline: <N tests passed, M failed | no test suite found>

<!-- checkpoint: worktree-created -->"
```

**If no test suite:** Note it and continue. Not all projects have tests.

## Resuming an Existing Worktree

If the worktree already exists (e.g., resuming from a previous session):

```bash
# Check if worktree exists
git worktree list | grep <ticket-id>
```

If found:
1. `cd` into it
2. Verify the branch: `git branch --show-current`
3. Skip setup if `node_modules`/equivalent already exists
4. Skip baseline (already established)

## Returning to Main Repository

When done working (called by finishing-branch skill):

```bash
cd <original-repo-path>
```

Do not remove the worktree here — that's the finishing-branch skill's job.

## Cleanup

Called by the finishing-branch skill after merge/PR/discard:

```bash
# From the main repository (not from inside the worktree)
git worktree remove .claude/worktrees/<ticket-id>

# If branch was merged or discarded, delete it
git branch -d <ticket-id>  # -d for merged, -D for unmerged (discard case)
```

If `git worktree remove` fails because of uncommitted changes:

```bash
# Force removal only if user chose to discard
git worktree remove --force .claude/worktrees/<ticket-id>
```

## Error Handling

| Situation | Behavior |
|-----------|----------|
| Worktree already exists | Resume — cd into it, skip creation |
| Branch already exists (no worktree) | Ask — branch may be from prior work. Reuse or rename? |
| Project setup fails | Warn and continue — worktree is still usable |
| Test baseline fails | Log failures, continue — main may be broken |
| Not in a git repository | Stop — worktrees require git |
| Dirty working tree on main | Stop — commit or stash before creating worktree |

## Integration

**Called by:**
- `powers:create-feature` Phase 2.5
- `powers:create-bug` (equivalent phase)

**Hands off to:**
- Calling workflow's next phase (typically planning)

**Referenced by:**
- `powers:finishing-branch` for cleanup steps
