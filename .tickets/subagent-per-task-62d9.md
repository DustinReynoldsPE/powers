---
id: subagent-per-task-62d9
stage: triage
status: needs_testing
deps: []
links: []
created: 2026-03-03T22:23:54Z
type: feature
priority: 1
---
# Subagent-per-task execution mode

Add an alternative execution mode to create-feature Phase 4 that dispatches a fresh subagent for each task in the plan. Each subagent gets clean context with only the task description, relevant file paths, and project constraints. Two-stage review after each task: (1) spec compliance, (2) code quality. Prevents context pollution and enables longer autonomous runs.

## Design

Add --subagent flag to create-feature. When enabled, Phase 4 iterates plan steps and for each: launches Agent tool with subagent_type general-purpose, passes task description + file paths + constraints, collects result, runs two-stage review (can be plan-reviewer agent or a new code-reviewer agent). Falls back to single-agent mode if subagent fails. Independent tasks can run in parallel per dispatching-parallel-agents pattern.

## Acceptance Criteria

create-feature supports --subagent flag. Each plan task dispatched to fresh subagent. Two-stage review runs after each task. Results aggregated. Fallback to single-agent on failure.

## Notes

**2026-03-03T22:48:29Z**

## Brainstorm

**Problem:** Single-agent execution causes context pollution on long features. Subagent-per-task gives each plan step a fresh context.

**Solution:** Standalone subagent-execution skill with 3 prompt templates. create-feature Phase 4 invokes it when --subagent flag present.

**Decisions:**
- **Decision:** Sequential execution, not parallel (auto) — parallel implementation subagents cause file conflicts
- **Decision:** Three separate prompt template files (auto) — matches superpowers pattern, keeps SKILL.md clean
- **Decision:** Spec review before code quality review, strict ordering (auto) — right thing before right way
- **Decision:** Review loops not one-shots (auto) — reviewer finds issues -> implementer fixes -> re-review
- **Decision:** Surface subagent failures, don't silently fall back (human) — silent fallback masks problems, let human decide

<!-- checkpoint: brainstorm -->

**2026-03-03T23:11:31Z**

## Plan

**Decision:** No new agent definitions in agents/ (auto) — reviewers are subagents via prompt templates
**Decision:** Adapt templates to our conventions (auto) — tk references, decision tagging, error classification

1. Create skills/subagent-execution/SKILL.md — orchestration loop
2. Create skills/subagent-execution/implementer-prompt.md — implementer template
3. Create skills/subagent-execution/spec-reviewer-prompt.md — spec compliance template
4. Create skills/subagent-execution/code-quality-reviewer-prompt.md — quality template
5. Modify skills/create-feature/SKILL.md — add --subagent flag path in Phase 4
6. Modify skills/using-powers/SKILL.md — document new skill and flag

<!-- checkpoint: planning -->

**2026-03-03T23:14:03Z**

## Execute

**What changed:**
- Created skills/subagent-execution/SKILL.md — orchestration loop with sequential task dispatch, two-stage review, error surfacing
- Created skills/subagent-execution/implementer-prompt.md — template with Q&A upfront, self-review, structured report
- Created skills/subagent-execution/spec-reviewer-prompt.md — template with trust-nothing verification, actionable output
- Created skills/subagent-execution/code-quality-reviewer-prompt.md — template covering correctness, clarity, consistency, simplicity, testing
- Modified skills/create-feature/SKILL.md — added --subagent flag, alternative Phase 4 path
- Modified skills/using-powers/SKILL.md — documented --subagent option and when-to-use table entry
- Bumped plugin version to 0.4.0 (minor: new skill)

**Decisions made:**
- **Decision:** Prompt templates use slot-filling pattern with bracketed placeholders (auto) — orchestrator fills in context, cleaner than embedding in SKILL.md
- **Decision:** Review loop cap at 3 rounds before surfacing to user (auto) — prevents infinite loops on design-level problems

<!-- checkpoint: executing -->

**2026-03-03T23:15:13Z**

## Finalize

**Known limitations:**
- Subagent execution is sequential only — no parallel implementer dispatch (by design, to avoid file conflicts)
- Review loop cap (3 rounds) is documented but not mechanically enforced — relies on orchestrator following the skill
- No plan persistence yet — orchestrator must pass full task text in prompts (plan-persistence-standalone-f4e9 addresses this)

**TODOs filed:** None — existing tickets cover follow-on work (code-review-skills-eacd for dedicated reviewer agent, plan-persistence-standalone-f4e9 for plan files)

## Learnings

- Superpowers' three-template pattern (implementer, spec-reviewer, quality-reviewer) maps cleanly to Claude Code's Agent tool with subagent_type general-purpose
- The trust-nothing instruction in spec-reviewer is critical — without it, reviewers tend to accept implementer claims at face value
- Slot-filling prompt templates are more maintainable than embedded prompts in SKILL.md

<!-- checkpoint: finalized -->
