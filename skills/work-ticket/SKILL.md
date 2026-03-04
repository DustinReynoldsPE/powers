---
name: work-ticket
description: Resume work on an existing ticket based on its type and current state.
argument-hint: <ticket-id> [--auto]
---

# Resume Ticket Work

Resume work on an existing ticket, picking up where you left off.

**Input:** `$ARGUMENTS` should contain ticket ID and optional `--auto` flag.

## Step 1: Read the Ticket

```bash
tk show <ticket-id>
```

Extract:
- **Type:** feature, bug, task, epic, chore
- **Stage:** triage, spec, design, implement, test, verify, done
- **Content:** Look for checkpoint comments and existing sections

## Step 2: Find Current State

Look for checkpoint comments in the ticket content:

```
<!-- checkpoint: brainstorm -->
<!-- checkpoint: planning -->
<!-- checkpoint: executing -->
<!-- checkpoint: testing -->
<!-- checkpoint: finalized -->
<!-- checkpoint: investigating -->
```

**If no checkpoint:** Infer from content:
- Has `## Plan` but no `## Execute` → resume at execute
- Has `## Execute` but no `## Test Results` → resume at test
- Has `## Root Cause` but no `## Verified` → resume at test (bug)

## Step 3: Reason About Next Step

Before blindly resuming, evaluate the ticket state:

**Check for issues:**
- Does the plan still make sense given what you know now?
- Are there blockers or concerns noted?
- Has context changed since last session?

**If something's wrong:**
- Propose adjustment: "Plan says X, but that won't work because Y. Revise plan?"
- Can loop back to earlier phases if needed
- Document the deviation

**If everything looks good:**
- Proceed to next phase

## Step 4: Resume Flow

### For Features (type: feature)

| Last Checkpoint | Next Action |
|-----------------|-------------|
| (none) | Start at Phase 1: Brainstorm |
| `brainstorm` | Phase 2: Create ticket (if not created) or Phase 3: Plan |
| `planning` | Phase 4: Execute |
| `executing` | Phase 5: Test |
| `testing` | Phase 6: Finalize |
| `finalized` | Phase 7-8: Commit and Push |

Follow instructions in `/create-feature` for each phase.

### For Bugs (type: bug)

| Last Checkpoint | Next Action |
|-----------------|-------------|
| (none) | Phase 2: Investigate |
| `investigating` | Phase 3: Fix |
| (after fix, no test) | Phase 4: Test |
| `testing` | Phase 5: Document Root Cause |
| `finalized` | Phase 6-7: Commit and Push |

Follow instructions in `/create-bug` for each phase.

### For Other Types (task, chore)

Use feature flow phases as guidance, but adapt as needed:
- Tasks may not need brainstorming
- Chores may not need testing
- Use judgment, document decisions

## Step 5: Validate Before Presenting Results

Before marking any phase as complete or presenting work to the user:

1. **Run tests** if a test suite exists (`bun test`, `npm test`, `pytest`, etc.)
2. **Run type checks** if TypeScript (`bun tsc --noEmit`)
3. **Run linter** if configured (`bun lint`, `npm run lint`, etc.)

If any check fails, fix the issues before proceeding. Do not present work as done until validation passes. If a check cannot be fixed after reasonable effort, document the failure and surface it.

## Step 6: Continue Through Remaining Phases

After resuming, continue through all remaining phases until complete:
- Execute remaining phases in order
- Update ticket at each checkpoint
- Validate at each phase boundary
- Commit and push when done

---

## Auto Mode

When `--auto` is passed:
- Pass `--auto` to subsequent phase execution
- Proceed without confirmation prompts
- Document all decisions with `(auto)` tag
- Still stop on environmental blockers or ambiguous state

## Examples

**Resume a feature at execute phase:**
```
/work-ticket p-1234
```
Reads ticket, finds `<!-- checkpoint: planning -->`, continues with execute phase.

**Resume a bug after investigation:**
```
/work-ticket p-5678 --auto
```
Reads ticket, finds `<!-- checkpoint: investigating -->`, proceeds to fix autonomously.

## Error Handling

**Ticket not found:**
```
Ticket <id> not found. Check the ID and try again.
```

**Ticket already done:**
```
Ticket <id> is at stage done. Move back with `tk advance <id> --to triage` to continue.
```

**Ambiguous state:**
- Multiple or conflicting checkpoints → ask which phase to resume
- Missing expected sections → ask for clarification

**Never:**
- Guess which phase to resume if unclear
- Skip phases without explicit instruction
- Close ticket without completing remaining phases
