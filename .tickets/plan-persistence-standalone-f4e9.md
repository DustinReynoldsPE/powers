---
id: plan-persistence-standalone-f4e9
stage: triage
status: open
deps: []
links: []
created: 2026-03-03T22:24:35Z
type: feature
priority: 2
---
# Plan persistence to standalone files


Save implementation plans as standalone markdown files instead of only inline in ticket notes. Enables cross-session reference and separate execution sessions. Plans survive context compaction and can be re-read by work-ticket for resumption.

## Design

Save plans to .tickets/<ticket-id>/plan.md or a plans/ directory. create-feature Phase 3 writes plan to file after approval. work-ticket reads plan file when resuming at execute phase. Plan file includes: ticket reference, ordered steps with file paths, decisions, and checkpoint markers. Plan-reviewer agent reads the file directly.

## Acceptance Criteria

Plans saved as standalone markdown files. work-ticket can read and resume from plan files. plan-reviewer reads plan files. Plans survive context compaction.
