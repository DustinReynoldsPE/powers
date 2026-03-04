---
id: git-worktree-integration-9f15
stage: triage
status: in_progress
deps: []
links: []
created: 2026-03-03T22:23:25Z
type: feature
priority: 1
parent: branch-based-worktree-499c
version: 1
---
# Git worktree integration skill

Create a using-git-worktrees skill that creates isolated workspaces per ticket. Branch name derived from ticket ID. Handles: worktree creation, .gitignore verification, project setup (bun install etc), test baseline verification. Maps each worktree to a tk ticket ID.

## Design

New skill: skills/using-git-worktrees/SKILL.md. Uses Claude Code EnterWorktree or direct git worktree commands. Convention: branch name = ticket-id (e.g., p-499c). Verifies tests pass in fresh worktree before work begins. Called by create-feature Phase 2.5 (after ticket creation, before planning).

## Acceptance Criteria

Skill exists. Creates worktree with ticket-derived branch name. Runs project setup. Verifies test baseline. Integrates with create-feature workflow.
