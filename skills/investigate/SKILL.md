---
name: investigate
description: Debugging methodology that prevents speculation and enforces disciplined investigation. Use when tackling bugs, unexpected behavior, or broken features.
disable-model-invocation: true
---

# Investigate

Disciplined debugging methodology. Prevents speculation, enforces evidence-based investigation.

For full bug lifecycle (ticket, fix, test, commit, push), use `/create-bug` instead.

## Step 1: Orient

Before asking anything, read the affected code path:

- Identify the entry point (route, handler, component, command)
- Trace the data flow through the relevant modules
- Note recent changes: `git log --oneline -10 -- <affected files>`

Build a mental model of how the code is *supposed* to work before investigating why it doesn't.

## Step 2: Intake

Ask three structured questions using AskUserQuestion (single call, all three):

1. **Repro status** — "Can you reproduce this reliably?"
   - Options: "Yes, every time" / "Sometimes" / "Saw it once" / "Haven't tried yet"

2. **Starting point** — "Where should we start looking?"
   - Options: provide 2-3 specific locations based on your Step 1 reading, plus "Somewhere else"

3. **Additional context** — "Anything else relevant?"
   - Options: "Error message/stack trace" / "Recent change triggered it" / "Environment-specific" / "Nothing else"

## Step 3: Investigate

Follow these principles strictly:

### Add logging first, never speculate
Before forming any hypothesis, add logging/tracing to observe actual behavior. Read the output. Let the data tell you what's wrong.

### Simplest explanation first
Check the obvious before the exotic:
1. Typo or wrong variable?
2. Stale cache or state?
3. Missing dependency or config?
4. Race condition or timing?
5. Only then consider deeper architectural issues

### Reliable reproduction before fixing
If you can't reproduce it, you can't verify a fix. Invest time in reproduction before investing time in solutions.

### 3-patch rule
If you've tried 3 patches and the bug persists, your mental model is wrong. Stop patching. Step back and re-examine assumptions. Re-engage with the user — describe what you've tried and what you expected vs. observed.

### Trace mutations
When debugging state issues, trace every point where the relevant state is read or written. Don't trust assumptions about data flow — verify each step.

### Check boundaries
Bugs cluster at boundaries: between modules, between sync/async, between client/server, between serialization/deserialization. Check these first.

## Collaboration Principles

### User reality wins
If the user says "it worked yesterday," believe them. Find what changed. `git diff`, env changes, dependency updates.

### Ask what they see
Don't ask "does it work?" Ask "what do you see when you do X?" Specific observations beat yes/no answers.

### Trust pattern recognition
If the user says "this feels like the same bug as last time," investigate that connection. Human pattern recognition catches things grep misses.

### Discuss before fixing
Once you've identified the likely cause, explain your findings and proposed fix before implementing. Two sets of eyes on the diagnosis prevents fixing symptoms instead of causes.

## When to Escalate

- **Can't reproduce after 15 minutes** — ask the user to demonstrate
- **Root cause is in a dependency** — document and surface, don't patch around it
- **Fix requires architectural change** — stop and discuss scope, consider `/create-feature`
- **Multiple interacting bugs** — separate them, create individual tickets
