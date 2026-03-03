---
name: subagent-execution
description: Execute implementation plans by dispatching a fresh subagent per task with two-stage review. Use when running create-feature with --subagent flag, or when a plan has 4+ independent tasks that would benefit from clean context per task.
---

# Subagent-Driven Execution

Execute a plan by dispatching a fresh subagent per task, with two-stage review after each: spec compliance first, then code quality.

**Core principle:** Fresh context per task + two-stage review = no drift, high quality on long features.

## When to Use

- Plan has 4+ tasks
- Tasks are mostly independent (different files, different subsystems)
- Feature is large enough that single-agent context would degrade
- Invoked by `/create-feature --subagent` or manually

**Do not use when:**
- Tasks are tightly coupled (shared state, sequential dependencies on prior task output)
- Plan has 1-3 small tasks (overhead not worth it)
- Exploratory work where the plan will change mid-execution

## Input

Requires a plan with discrete, numbered tasks. Each task should have:
- Clear description of what to implement
- File paths to create/modify
- Acceptance criteria or verification steps

The plan can come from a tk ticket note (Phase 3 of create-feature) or a standalone plan file.

## The Process

### Step 1: Extract Tasks

Read the plan. For each task, extract:
- **Task number and name**
- **Full task text** (every detail — subagents cannot read the plan)
- **File paths** involved
- **Dependencies** on other tasks (must complete task N before task M?)
- **Verification** steps

Order tasks by dependency. Flag any that could conflict (touching same files).

### Step 2: Execute Each Task

For each task, sequentially:

#### 2a. Dispatch Implementer Subagent

Use the Agent tool:
```
Agent tool:
  subagent_type: "general-purpose"
  description: "Implement Task N: <name>"
  prompt: <fill from ./implementer-prompt.md template>
```

Pass the **full task text** in the prompt. Do not tell the subagent to read a file.

Include in the prompt:
- Complete task description
- Scene-setting context (where this fits in the larger feature)
- Project constraints (tech stack, conventions, tk ticket ID)
- Working directory

**If the implementer asks questions:** Answer them with context from the plan and codebase, then let the subagent continue. Resume the agent using its agent ID.

**If the implementer fails:** Surface the failure to the user with:
- What task was being attempted
- The error or failure description
- The implementer's partial output (if any)
- Ask: "Retry with different approach, skip this task, or abort?"

Do NOT silently fall back to single-agent mode.

#### 2b. Dispatch Spec Compliance Reviewer

After the implementer reports completion:

```
Agent tool:
  subagent_type: "general-purpose"
  description: "Review spec compliance for Task N"
  prompt: <fill from ./spec-reviewer-prompt.md template>
```

Pass: the original task requirements AND the implementer's report.

**If spec reviewer finds issues:**
1. Resume the implementer subagent with the specific issues
2. Implementer fixes
3. Re-dispatch spec reviewer
4. Repeat until approved

#### 2c. Dispatch Code Quality Reviewer

Only after spec compliance passes:

```
Agent tool:
  subagent_type: "general-purpose"
  description: "Review code quality for Task N"
  prompt: <fill from ./code-quality-reviewer-prompt.md template>
```

**If quality reviewer finds issues:**
1. Resume the implementer subagent with the issues
2. Implementer fixes
3. Re-dispatch quality reviewer
4. Repeat until approved

#### 2d. Record Completion

```bash
tk add-note <ticket-id> "Task N: <name> — complete
- Spec: approved
- Quality: approved
- Files: <list>"
```

### Step 3: Final Review

After all tasks complete, dispatch one final code quality review covering the entire implementation:

```
Agent tool:
  subagent_type: "general-purpose"
  description: "Final review: full implementation"
  prompt: |
    Review the complete implementation for <ticket-id>.

    Tasks completed:
    <summary of all tasks and their outcomes>

    Check for:
    - Cross-task consistency (naming, patterns, error handling)
    - Integration issues between tasks
    - Missing glue code
    - Overall architecture coherence

    Report: strengths, issues by severity, overall assessment.
```

### Step 4: Hand Back to Workflow

Return control to the calling workflow (create-feature Phase 5: Test) with:
- Summary of all tasks completed
- Any concerns from reviewers
- Files changed across all tasks

## Red Flags

**Never:**
- Skip reviews (spec OR quality) — both are required for every task
- Dispatch multiple implementer subagents in parallel — file conflicts
- Start code quality review before spec compliance passes
- Accept "close enough" on spec compliance
- Make subagents read plan files — pass full text in prompt
- Silently fall back to single-agent mode on failure
- Proceed to next task with open review issues
- Let implementer self-review replace formal review — both are needed

**If subagent asks questions:**
- Answer clearly and completely
- Provide additional codebase context if needed
- Do not rush into implementation

**If reviewer finds issues:**
- Implementer fixes (same subagent, resumed)
- Reviewer reviews again (new subagent)
- Repeat until approved

## Error Handling

| Error Class | Behavior |
|-------------|----------|
| Subagent fails to complete task | Surface to user with context, ask for direction |
| Reviewer finds spec issues | Implementer fixes, re-review loop |
| Reviewer finds quality issues | Implementer fixes, re-review loop |
| Review loop exceeds 3 rounds | Surface to user — likely a design problem |
| Subagent produces conflicting changes | Stop, surface conflict, ask for resolution |

## Integration

**Called by:**
- `powers:create-feature` Phase 4 (when `--subagent` flag present)

**Hands off to:**
- Calling workflow's next phase (typically Phase 5: Test)

**Prompt templates:**
- `./implementer-prompt.md`
- `./spec-reviewer-prompt.md`
- `./code-quality-reviewer-prompt.md`
