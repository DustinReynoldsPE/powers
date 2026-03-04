---
id: branch-finishing-workflow-1c6f
stage: triage
status: needs_testing
deps: [git-worktree-integration-9f15]
links: []
created: 2026-03-03T22:23:35Z
type: feature
priority: 1
parent: branch-based-worktree-499c
version: 3
---
# Branch finishing workflow skill

Create a finishing-branch skill that replaces the current always-commit-and-push Phase 7/8. After tests pass, presents options: (1) create PR via gh, (2) merge locally to main, (3) keep branch as-is, (4) discard branch. Handles worktree cleanup after choice. Updates tk ticket status based on outcome.

## Design

New skill: skills/finishing-branch/SKILL.md. Checks: all tests pass, no uncommitted changes, ticket status is needs_testing or later. PR path: git push -u origin, gh pr create with ticket ID in title and description. Merge path: git checkout main, git merge --no-ff branch. Discard path: confirm destructive action, git worktree remove, git branch -D. Always cleans up worktree on merge/PR/discard.

## Acceptance Criteria

Skill exists with 4 finish options. PR creation uses gh CLI. Worktree cleanup on completion. Ticket status updated. Integrated into create-feature Phase 7-8 and create-bug equivalent.

## Notes

**2026-03-04T05:13:15Z**

## Brainstorm

**Decisions:**
- **Decision:** PR is recommended default option (auto) — encourages review-based workflow
- **Decision:** PR path keeps worktree alive (auto) — review may request changes, user cleans up after merge
- **Decision:** Discard requires explicit confirmation (auto) — destructive, irreversible
- **Decision:** gh fallback to manual push + URL (auto) — gh auth may not be configured

## Plan

1. Create skills/finishing-branch/SKILL.md with 4 finish options, pre-flight checks, error handling

## Execute

- Created skills/finishing-branch/SKILL.md — pre-flight checks, 4 options (PR/merge/keep/discard), outcome table, error handling
- Bumped plugin version to 0.6.0

## Finalize

**Known limitations:**
- gh CLI auth detection is best-effort (checks exit code)
- No automatic PR template detection — uses inline template
- Worktree-less branch path (direct checkout) is documented but secondary

<!-- checkpoint: finalized -->
