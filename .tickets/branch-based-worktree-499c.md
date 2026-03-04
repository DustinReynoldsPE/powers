---
id: branch-based-worktree-499c
stage: triage
status: needs_testing
deps: []
links: []
created: 2026-03-03T22:23:16Z
type: epic
priority: 1
version: 1
---
# Branch-based worktree workflow

Adopt branch-per-feature workflow: each feature gets a branch, works in a git worktree, and finishes with a PR. Replaces the current always-commit-and-push-to-current-branch approach. Based on gaps identified in powers-vs-superpowers comparison.

## Design

Epic covering: worktree integration, branch finishing workflow, and updates to create-feature/create-bug to use the new flow. Superpowers model: worktree creation -> isolated work -> 4-option finish (merge/PR/keep/discard). Our adaptation: tk ticket maps to branch/worktree, finish phase offers merge-local or create-PR.

## Acceptance Criteria

create-feature and create-bug workflows use branch+worktree by default. Branch finishing skill exists with merge/PR options. Worktree cleanup on completion.
