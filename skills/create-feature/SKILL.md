---
name: create-feature
description: Start a new feature with structured workflow. Brainstorm → plan → execute → test → commit → push.
---

# Feature Workflow

Complete workflow for implementing a feature: brainstorm, plan, execute, test, finalize, commit, push.

**Mode:** `$ARGUMENTS` may include:
- `--auto` — autonomous execution (skip STOP gates, document all decisions with `(auto)` tag)
- `--subagent` — dispatch a fresh subagent per plan task with two-stage review (see Phase 4)

## Phase 1: Brainstorm

Understand the feature before creating a ticket.

**Gather context:**
- Review relevant files, docs, recent commits
- Check active tickets: `tk ls` for open tasks, `tk ls -T epic` for epics

**Ask questions (one at a time, prefer multiple choice):**
- What problem does this solve?
- How will it be solved?
- What does success look like?
- What constraints exist?

**Detect scope:**
- If >2 hours of work, propose: "This is epic-sized. Break into child tickets?"
- If yes, use `powers:create-tickets` to generate epic + children, then stop
- If no, continue with single feature
- If the work involves CSS, styling, theming, or web UX, invoke `powers:css-architecture` for conventions

**Output:** Clear understanding of problem, solution, success criteria, constraints.

### STOP — Confirm Understanding

**Do not proceed to Phase 2 unless the user explicitly says to continue.**

Present a summary:
1. **Problem** — what we're solving
2. **Proposed solution** — high-level approach
3. **Scope** — estimated size (small/medium/large)

Wait for confirmation or course correction before creating the ticket.

## Phase 2: Create Ticket

```bash
tk create "<feature title>" \
  --type feature \
  -d "<problem and solution summary>" \
  --design "<approach and key decisions>" \
  --acceptance "<success criteria>"
```

Record the ticket ID for later phases.

## Phase 3: Plan

Define implementation steps with key decisions.

**Produce:**
- Ordered list of implementation steps
- Files to create/modify
- Key decisions with rationale

**Document in ticket:**
```bash
tk add-note <ticket-id> "## Plan

**Decision:** <choice> (auto) — <rationale>

1. <step one>
2. <step two>
3. <step three>

<!-- checkpoint: planning -->"
```

**Interactive mode:** Ask "Does this plan look right?" before proceeding.
**Auto mode:** Document plan and continue.

## Phase 3.5: Validate Plan

Delegate to the `plan-reviewer` agent to verify the plan against the actual codebase.

**Invoke:** Use the Task tool with `subagent_type: "plan-reviewer"`. Pass the plan from Phase 3 as the prompt.

**Handle verdict:**
- **READY** — proceed to Phase 4
- **NEEDS REVISION** — revise plan based on review findings, then re-validate
- **BLOCKED** — stop and surface to user with the reviewer's findings

**Record review in ticket:**
```bash
tk add-note <ticket-id> "## Plan Review

**Verdict:** <READY|NEEDS REVISION|BLOCKED>

<summary of findings>

<!-- checkpoint: plan-validated -->"
```

## Phase 4: Execute

**If `--subagent` flag is present:** Invoke `powers:subagent-execution` with the plan from Phase 3. Pass the ticket ID and full plan text. The subagent-execution skill handles dispatching, review loops, and task-level progress. When it completes, proceed to Phase 5 with its summary.

**Otherwise:** Implement the feature following the plan inline.

**As you work:**
- Track deviations from plan
- Note surprises and learnings
- Document decisions with `**Decision:** <choice> (auto|human) — <rationale>`

**After implementation, update ticket:**
```bash
tk add-note <ticket-id> "## Execute

**What changed:**
- <file created/modified>
- <component added>

**Decisions made:**
- <decision> (auto) — <rationale>

<!-- checkpoint: executing -->"
```

**If blocked:**
- Self-inflicted errors (syntax, typos): Retry until solved
- Environmental blockers (server down): Stop and surface
- Approach issues: Document and ask

### STOP — Implementation Complete

**Do not proceed to Phase 5 unless the user explicitly says to continue.**

Present a summary:
1. **What was built** — files created/modified, components added
2. **Deviations from plan** — anything that changed during implementation
3. **Ready for testing** — what to verify

Wait for the user to review before proceeding to test.

## Phase 5: Test

Verify the feature works.

**Run existing test suite:**
```bash
# Project-specific command, check package.json or PROJECT.md
npm test  # or bun test, pytest, etc.
```

**Manual verification:**
- Use Puppeteer for UX testing (headless=false interactive, headless=true auto)
- Use CLI execution for non-UI features
- Use running dev servers — don't spin up test instances

**Update ticket with results:**
```bash
tk add-note <ticket-id> "## Test Results

**<timestamp>:** <count> tests, <passed> passed

Verified manually:
- <what was tested>
- <what was tested>

<!-- checkpoint: testing -->"
```

**If tests fail:** Fix issues, re-run, document the fix.

## Phase 6: Finalize

Wrap up the feature.

**Check for:**
- TODOs that should become tickets
- Known limitations to document
- Cleanup needed

**Update ticket:**
```bash
tk add-note <ticket-id> "## Finalize

**Known limitations:**
- <limitation if any>

**TODOs filed:**
- <ticket-id>: <description>

## Learnings

- <insight worth remembering>

<!-- checkpoint: finalized -->"
```

**File new tickets for TODOs:**
```bash
tk create "<TODO title>" --type task -d "<description>"
```

## Phase 7: Commit

Stage and commit with ticket-first format.

```bash
git add <files>
git commit -m "[<ticket-id>] <imperative description>"
```

**Example:** `[p-1234] Add user form validation`

**Include:**
- All files changed for this feature
- Updated ticket file from `.tickets/`

## Phase 8: Push

```bash
tk edit <ticket-id> --status needs_testing
git add .tickets/<ticket-id>.md
git commit --amend --no-edit
git push
```

---

## Auto Mode

When `--auto` is passed:
- Skip all STOP points — proceed through phases without confirmation prompts
- Document all decisions with `(auto)` tag
- Add "Questions Considered" section:

```markdown
## Questions Considered (auto mode)

- Q: <question that would have been asked> → <decision made>
- Q: <question> → <decision>
```

- Still stop on environmental blockers or ambiguous requirements

## Error Handling

| Error Class | Behavior |
|-------------|----------|
| Self-inflicted (syntax, typo, wrong API) | Retry until solved |
| Environmental (server down, port unavailable) | Stop and surface |
| Approach/design (plan doesn't work) | Document and ask |

**Never:**
- Write hacky workarounds
- Skip testing
- Silently degrade quality
