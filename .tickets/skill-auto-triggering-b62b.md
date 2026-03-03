---
id: skill-auto-triggering-b62b
stage: triage
status: open
deps: []
links: []
created: 2026-03-03T22:24:04Z
type: feature
priority: 1
---
# Skill auto-triggering via enriched descriptions


Enrich skill descriptions with keyword-rich trigger phrases (CSO pattern from superpowers) so the agent can match skills to situations without explicit slash commands. Add a rule to using-powers: before responding to any development task, check if a Powers skill applies. Does not replace slash commands — supplements them for organic discovery.

## Design

Update each SKILL.md description field with longer, keyword-rich descriptions covering trigger scenarios. Add to using-powers: 'Before responding to any development request, scan available skills for a match. If a skill applies, invoke it.' Test by verifying the agent suggests relevant skills in non-slash-command contexts.

## Acceptance Criteria

All skill descriptions enriched with trigger keywords. using-powers includes auto-check rule. Agent suggests relevant skills when user describes work without using slash commands.
