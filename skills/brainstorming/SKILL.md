---
name: brainstorming
description: Socratic design refinement before implementation. Use before building features, adding functionality, or modifying behavior.
---

# Brainstorming Ideas Into Designs

Collaborative dialogue to turn ideas into fully formed designs.

## Prerequisites

Verify `tk` is installed. If unavailable, stop and tell the user to install it.

## Process

**Understanding the idea:**
- Review current project state (files, docs, recent commits)
- Check active tickets: `tk ls` for open tasks, `tk ls -T epic` for epics
- Ask questions one at a time to refine the idea
- Prefer multiple choice when possible
- Focus on: purpose, constraints, success criteria

**Exploring approaches:**
- Propose 2-3 approaches with trade-offs
- Lead with your recommendation and reasoning

**Presenting the design:**
- Break into sections of 200-300 words
- Ask after each section whether it looks right
- Cover: architecture, components, data flow, error handling, testing
- Go back and clarify if something doesn't make sense

## After the Design

**Implementation (if continuing):**
- Ask: "Ready to set up for implementation?"
- Use `/create-feature` to set up for implementation with the design

## Principles

- One question at a time
- Multiple choice preferred
- YAGNI ruthlessly
- Explore alternatives before settling
- Incremental validation
