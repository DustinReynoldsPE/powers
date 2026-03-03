---
id: verification-completion-standalone-c0b2
stage: triage
status: open
deps: []
links: []
created: 2026-03-03T22:24:11Z
type: feature
priority: 1
---
# Verification-before-completion standalone skill


Extract inline STOP-gate verification logic into a reusable standalone skill. Hard rule: no completion claims without fresh verification evidence. Includes rationalization prevention (agent cannot claim tests passed without running them). Invocable from any workflow and enforceable as a pre-commit check.

## Design

New skill: skills/verify/SKILL.md. Checklist: tests pass (with evidence), no uncommitted changes, ticket acceptance criteria met, no regressions introduced. Includes rationalization prevention section: common shortcuts the agent might try and why they are forbidden. Referenced by create-feature Phase 6, create-bug equivalent, and finishing-branch pre-checks.

## Acceptance Criteria

Skill exists. Enforces fresh verification evidence. Includes rationalization prevention. Integrated into workflow finalize phases. Can be invoked standalone via /verify.
