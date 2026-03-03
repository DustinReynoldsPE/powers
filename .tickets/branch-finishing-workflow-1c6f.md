---
id: branch-finishing-workflow-1c6f
stage: triage
status: open
deps: [git-worktree-integration-9f15]
links: []
created: 2026-03-03T22:23:35Z
type: feature
priority: 1
parent: branch-based-worktree-499c
---
# Branch finishing workflow skill

Create a finishing-branch skill that replaces the current always-commit-and-push Phase 7/8. After tests pass, presents options: (1) create PR via gh, (2) merge locally to main, (3) keep branch as-is, (4) discard branch. Handles worktree cleanup after choice. Updates tk ticket status based on outcome.

## Design

New skill: skills/finishing-branch/SKILL.md. Checks: all tests pass, no uncommitted changes, ticket status is needs_testing or later. PR path: git push -u origin, gh pr create with ticket ID in title and description. Merge path: git checkout main, git merge --no-ff branch. Discard path: confirm destructive action, git worktree remove, git branch -D. Always cleans up worktree on merge/PR/discard.

## Acceptance Criteria

Skill exists with 4 finish options. PR creation uses gh CLI. Worktree cleanup on completion. Ticket status updated. Integrated into create-feature Phase 7-8 and create-bug equivalent.
