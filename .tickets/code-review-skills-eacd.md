---
id: code-review-skills-eacd
stage: triage
status: open
deps: []
links: []
created: 2026-03-03T22:24:19Z
type: feature
priority: 2
---
# Code review skills (requesting + receiving)


Port the superpowers requesting/receiving code review pattern. Requesting: dispatch a code-reviewer subagent that checks implementation against the plan, reports issues by severity. Receiving: teach the agent how to handle feedback without being defensive, including when to push back on review comments. Create a code-reviewer agent or extend plan-reviewer.

## Design

Two new skills: skills/requesting-code-review/SKILL.md and skills/receiving-code-review/SKILL.md. New agent: agents/code-reviewer.md (read-only, checks against plan, returns structured findings with severity). Requesting skill dispatches code-reviewer between plan tasks or before branch finishing. Receiving skill provides rules for handling review feedback constructively.

## Acceptance Criteria

Both skills exist. Code-reviewer agent exists. Requesting skill dispatches reviewer and surfaces findings. Receiving skill covers anti-defensiveness rules and push-back criteria.
