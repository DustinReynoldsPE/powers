# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Powers is a Claude Code plugin providing skills for ticket-based workflows using [tk](https://github.com/DustinReynoldsPE/ticket/).

## Architecture

```
.claude-plugin/
  plugin.json           # Plugin metadata (bump version on every change)
  marketplace.json      # Local dev marketplace config
agents/
  plan-reviewer.md      # Plan validation agent
skills/
  brainstorming/        # /brainstorm - Socratic design refinement
  create-feature/       # /create-feature - Feature workflow
  create-bug/           # /create-bug - Bug workflow
  work-ticket/          # /work-ticket - Resume based on ticket type
  investigate/          # /investigate - Debugging methodology
  css-architecture/     # CSS token system and semantic styling
  create-tickets/       # Convert designs to tk epics/tasks
  using-powers/         # Meta-skill injected at session start
  tk-list/              # /tk-list - List tickets with filters
  tk-ready/             # /tk-ready - Show ready tickets
  tk-ticket/            # /tk-ticket - Create single ticket
docs/
  TICKET-CONVENTIONS.md # Ticket structure patterns
templates/
  PROJECT.md            # Project configuration template
hooks/
  hooks.json            # Hook registration
  session-start.sh      # Injects using-powers into session context
  run-hook.cmd          # Cross-platform hook runner
```

**Skills are slash commands.** Each `skills/<name>/SKILL.md` creates a `/name` command. The `name` field in frontmatter becomes the command name.

**Agents** live in `agents/<name>.md` with YAML frontmatter (`name`, `description`, `tools`, `model`, `memory`).

**Skill loading:** SessionStart hook reads `using-powers/SKILL.md` and injects as context.

**Skill structure:** Each skill has `SKILL.md` with YAML frontmatter (`name`, `description`) and markdown content.

## Versioning

**Always bump the version in `.claude-plugin/plugin.json` when making changes.** Use semver:
- Patch (0.x.Y): bug fixes, wording tweaks
- Minor (0.X.0): new skills, agents, or workflow changes
- Major (X.0.0): breaking changes to skill interfaces or plugin structure

## Local Development

```bash
# Register local marketplace
/plugin marketplace add powers-dev file://./.claude-plugin/marketplace.json

# Install from local marketplace
/plugin install powers-dev@powers
```

## Dependency

Requires [tk](https://github.com/DustinReynoldsPE/ticket/) CLI. Skills verify `tk` is available before proceeding.
