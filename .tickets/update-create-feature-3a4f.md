---
id: update-create-feature-3a4f
stage: triage
status: needs_testing
deps: [git-worktree-integration-9f15, branch-finishing-workflow-1c6f]
links: []
created: 2026-03-03T22:23:40Z
type: task
priority: 1
parent: branch-based-worktree-499c
version: 3
---
# Update create-feature and create-bug to use branch workflow

Modify create-feature to: add Phase 2.5 (create worktree after ticket), replace Phase 7-8 with finishing-branch skill invocation. Same for create-bug. Update using-powers documentation to reflect new flow.

## Acceptance Criteria

create-feature and create-bug SKILL.md files updated. Workflows branch/worktree by default. using-powers reflects the new flow.

## Notes

**2026-03-04T05:18:15Z**

## Execute

**What changed:**
- create-feature: Added Phase 2.5 (worktree creation), replaced Phase 8 with finishing-branch invocation
- create-bug: Added Phase 1.5 (optional worktree), replaced Phase 7 with finishing-branch invocation
- using-powers: Updated workflow descriptions to reflect branch-based flow
- Bumped plugin version to 0.7.0

**Decisions:**
- **Decision:** Bug worktree is optional, feature worktree is default (auto) — bugs are often quick fixes that don't need isolation
- **Decision:** Both skills fall back to direct push when not using worktree (auto) — backwards compatible

<!-- checkpoint: finalized -->
