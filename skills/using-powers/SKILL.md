---
name: using-powers
description: Establishes skill usage patterns at session start
---

# Powers Plugin

Structured development workflows using tk tickets.

## Development Workflow

**Start new work:**
- `/create-feature` — Full feature workflow (brainstorm → plan → execute → test → commit → push)
- `/create-feature --subagent` — Same workflow, but dispatches a fresh subagent per plan task with two-stage review (spec compliance + code quality). Use for large features with 4+ tasks.
- `/create-bug` — Lean bug workflow (investigate → fix → test → commit → push)

**Resume existing work:**
- `/work-ticket <id>` — Resume work on a ticket based on its type and state

**One ticket = one commit = one push.** Each workflow ends with a committed, pushed change.

## Ticket Management

- `/tk-list` — List tickets with optional filters
- `/tk-ready` — Show tickets ready to work on (no blockers)
- `/tk-ticket` — Create a single ticket manually

## Design & Planning

- `/brainstorm` — Socratic design refinement before implementation
- `powers:create-tickets` — Convert designs into tk epics and tasks

## When to Use What

| Situation | Action |
|-----------|--------|
| New feature to build | `/create-feature` |
| Large feature, many tasks | `/create-feature --subagent` |
| Bug to fix | `/create-bug` |
| Resuming from yesterday | `/work-ticket <id>` |
| Need to think through approach | `/brainstorm` |
| Have design, need task breakdown | `powers:create-tickets` |
| Quick ticket lookup | `/tk-list` or `/tk-ready` |

## Workflow Principles

- **Phases always run**, scaled to task size
- **Ask on decisions, not confirmations** — proceed unless blocked
- **Document decisions** with `**Decision:**` and `(auto)` or `(human)` tags
- **Capture learnings** in `## Learnings` section
- **Never hack around blockers** — stop and surface issues

## tk Quick Reference

`tk` is a CLI on PATH. Run `tk help` for full details.

```bash
# Viewing
tk ls                            # open tickets
tk ls --status=in_progress       # filter by status
tk ls -t feature                 # filter by type (-t lowercase)
tk ls --parent=<epic-id>         # children of epic
tk ready                         # unblocked tickets
tk show <id>                     # ticket details

# Creating & editing
tk create "Title" -t feature     # create ticket
tk edit <id> --status closed     # update fields
tk add-note <id> "text"          # append note

# Query (JSON output)
tk query                                        # all tickets as JSONL
tk query '.status == "open"'                    # jq filter (auto-wrapped in select)
tk query '.type == "bug" and .priority <= 1'    # compound filter
tk query '.title | test("deploy"; "i")'         # regex search
```

Query notes: output is JSONL (one JSON object per line). The filter
is passed to jq `select()` automatically — do NOT add your own `select()`.
Use single quotes for filters to avoid bash escaping issues.
