---
id: git-worktree-integration-9f15
stage: triage
status: needs_testing
deps: []
links: []
created: 2026-03-03T22:23:25Z
type: feature
priority: 1
parent: branch-based-worktree-499c
version: 6
---
# Git worktree integration skill

Create a using-git-worktrees skill that creates isolated workspaces per ticket. Branch name derived from ticket ID. Handles: worktree creation, .gitignore verification, project setup (bun install etc), test baseline verification. Maps each worktree to a tk ticket ID.

## Design

New skill: skills/using-git-worktrees/SKILL.md. Uses Claude Code EnterWorktree or direct git worktree commands. Convention: branch name = ticket-id (e.g., p-499c). Verifies tests pass in fresh worktree before work begins. Called by create-feature Phase 2.5 (after ticket creation, before planning).

## Acceptance Criteria

Skill exists. Creates worktree with ticket-derived branch name. Runs project setup. Verifies test baseline. Integrates with create-feature workflow.

## Notes

**2026-03-04T04:49:45Z**

## Brainstorm

**Problem:** Features work on current branch with no isolation. No clean rollback, no PR-based review.

**Solution:** Skill that creates worktree at .claude/worktrees/<ticket-id>/ with branch = ticket ID. Runs project setup and test baseline.

**Decisions:**
- **Decision:** Use git worktree add directly, not EnterWorktree (human) — EnterWorktree has auto-deletion bug on committed work, forces worktree-<name> branch prefix
- **Decision:** Worktrees at .claude/worktrees/<ticket-id>/ (auto) — matches Claude Code convention, .claude/ typically gitignored
- **Decision:** Test baseline warns but does not block (auto) — main could be broken, not our fault

<!-- checkpoint: brainstorm -->

**2026-03-04T04:49:54Z**

## Plan

1. Create skills/using-git-worktrees/SKILL.md with sections: when to use, create, setup, baseline, working, return, cleanup, errors

<!-- checkpoint: planning -->

**2026-03-04T04:50:43Z**

## Execute

**What changed:**
- Created skills/using-git-worktrees/SKILL.md — full worktree lifecycle (create, setup, baseline, resume, cleanup)
- Bumped plugin version to 0.5.0

**Decisions made:**
- **Decision:** Branch name = ticket ID directly, no prefix (auto) — cleaner than worktree-<name>, directly traceable
- **Decision:** Package manager detection table with priority order (auto) — bun first per project conventions
- **Decision:** Dirty working tree blocks worktree creation (auto) — forces clean state before branching

<!-- checkpoint: executing -->

**2026-03-04T04:50:49Z**

## Finalize

**Known limitations:**
- No ExitWorktree equivalent — cd back to main repo is manual
- Cleanup section is reference material for finishing-branch skill, not standalone
- Does not handle nested worktrees or submodules

## Learnings

- EnterWorktree has auto-deletion bug on committed-but-not-merged work — git worktree add directly is safer
- Bash cwd persists across tool calls, so cd into worktree is sufficient for session-wide isolation

<!-- checkpoint: finalized -->
