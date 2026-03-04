---
name: tk-ready
description: Show tickets ready to work on (no unresolved dependencies)
---

Run `tk ready` and display the results.

Ready tickets are tickets whose dependencies are all resolved and whose parent is at `implement` stage or later. These are the tickets you can work on right now.

## Usage

```bash
tk ready                # Show all ready tickets
tk ready --open         # Skip parent hierarchy checks
tk ready -a steve       # Ready tickets assigned to steve
```

Note: `ready` supports `-a` (assignee) and `-T` (tag) filters only.
To filter ready tickets by type, use `tk query '.stage != "done" and .type == "feature"'` or pipe: `tk ready | grep feature`.
