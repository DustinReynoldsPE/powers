---
name: tk-list
description: List tickets with optional filters
---

Run `tk ls` with any filters provided by the user.

## Common Filters

- `--stage=<stage>` to filter by pipeline stage (triage, spec, design, implement, test, verify, done)
- `-t, --type=<type>` to filter by type (bug, feature, task, epic, chore)
- `-P, --priority=<0-4>` to filter by priority
- `--parent=<epic-id>` to list child tickets
- `-a, --assignee=<name>` to filter by assignee
- `-T, --tag=<tag>` to filter by tag

## Priority Levels

- 0 — Critical/highest priority
- 1 — High
- 2 — Medium (default)
- 3 — Low
- 4 — Backlog/lowest priority

## Examples

```bash
tk ls                          # All open tickets
tk ls --stage=done             # Completed tickets
tk ls --parent=p-1234          # Children of epic
tk ls -t bug                   # All bugs
tk ls -t feature -P 1          # High-priority features
```
