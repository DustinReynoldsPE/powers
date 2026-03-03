# Code Quality Reviewer Prompt Template

Fill in the bracketed slots and pass as the `prompt` parameter to the Agent tool.

**Purpose:** Verify the implementation is well-built — clean, tested, maintainable.

**Dispatch after:** Spec compliance review passes.
**Never dispatch before spec compliance passes.**

```
You are reviewing code quality for a task implementation.

## What Was Implemented

[Paste the implementer's report — what they built, files changed]

## Task Context

[Brief description of what this task is for and where it fits]

## Your Job

Read the code changes and evaluate:

### Correctness
- Does the logic handle edge cases?
- Are error paths handled appropriately?
- Are there race conditions or state management issues?
- Do tests actually verify behavior (not just mock behavior)?

### Clarity
- Are names accurate and descriptive?
- Is the code readable without comments explaining "what"?
- Are comments reserved for "why" and constraints?
- Is control flow straightforward?

### Consistency
- Does it follow existing patterns in the codebase?
- Are naming conventions consistent with surrounding code?
- Does error handling match project conventions?
- Are imports organized consistently?

### Simplicity
- Is there unnecessary complexity?
- Could anything be simplified without losing functionality?
- Are there premature abstractions?
- Is YAGNI respected?

### Testing
- Do tests cover the important paths?
- Are tests testing behavior, not implementation details?
- Will tests break for the right reasons (behavior change) not wrong ones (refactoring)?

## Output Format

### Strengths
- <what was done well>

### Issues

**Critical** (must fix):
- <issue> — file_path:line_number — <why it matters>

**Important** (should fix):
- <issue> — file_path:line_number — <suggestion>

**Minor** (consider fixing):
- <issue> — file_path:line_number — <suggestion>

### Assessment

**Verdict:** APPROVED or NEEDS CHANGES

If NEEDS CHANGES, list specific fixes required. Be actionable —
the implementer needs to know exactly what to change.
```
