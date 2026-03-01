# Powers

Structured development workflows for Claude Code using [tk](https://github.com/EnderRealm/ticket/) tickets.

**One ticket = one commit = one push.** Each workflow guides you from idea to shipped code.

## Quick Start

```bash
# Start a new feature
/create-feature

# Fix a bug
/create-bug

# Resume work on an existing ticket
/work-ticket p-1234
```

## Full System Installation

Set up the complete powers workflow on a new machine:

### 1. Prerequisites

Install [tk](https://github.com/EnderRealm/ticket/):
```bash
# Follow tk installation instructions
```

### 2. Clone the Repo

```bash
git clone https://github.com/EnderRealm/powers.git ~/code/powers
cd ~/code/powers
```

### 3. Set Up Global Config (Optional)

Link the global Claude config files to use this repo's versions:

```bash
# Backup existing configs
mv ~/.claude/CLAUDE.md ~/.claude/CLAUDE.md.backup 2>/dev/null
mv ~/.claude/settings.json ~/.claude/settings.json.backup 2>/dev/null

# Create symlinks
ln -s ~/code/powers/CLAUDE.global.md ~/.claude/CLAUDE.md
ln -s ~/code/powers/settings.global.json ~/.claude/settings.json
ln -s ~/code/powers/statusline.sh ~/.claude/statusline.sh
chmod +x ~/.claude/statusline.sh
```

This gives you:
- Development workflow instructions in every session
- Pre-approved permissions for common operations
- Consistent behavior across machines

### 4. Install the Plugin

In Claude Code:
```
/plugin marketplace add EnderRealm/powers
/plugin install powers@powers
```

Restart Claude Code. You should see the workflow commands in `/skills`.

## Workflow Commands

### Development Workflow

| Command | Description |
|---------|-------------|
| `/create-feature` | Full feature workflow: brainstorm → plan → execute → test → commit → push |
| `/create-bug` | Lean bug workflow: investigate → fix → test → commit → push |
| `/work-ticket <id>` | Resume work on existing ticket based on type and state |

### Ticket Management

| Command | Description |
|---------|-------------|
| `/tk-list` | List tickets with optional filters |
| `/tk-ready` | Show tickets ready to work on (no blockers) |
| `/tk-ticket` | Create a single ticket manually |

### Debugging

| Command | Description |
|---------|-------------|
| `/investigate` | Disciplined debugging methodology — structured intake, logging-first, 3-patch rule |

### Design & Planning

| Command | Description |
|---------|-------------|
| `/brainstorm` | Socratic design refinement before implementation |

### Agents

| Agent | Description |
|-------|-------------|
| `plan-reviewer` | Validates implementation plans against the codebase (read-only, returns structured review) |

## Workflow Principles

- **Phases always run**, scaled to task size
- **Ask on decisions, not confirmations** — proceed unless blocked
- **Document decisions** with `**Decision:**` and `(auto)` or `(human)` tags
- **Capture learnings** in `## Learnings` section for later mining
- **Never hack around blockers** — stop and surface issues

## Testing Handoff

Workflows end by setting tickets to `needs_testing` status, not `closed`. This signals that:

1. The agent has completed implementation
2. Code is committed and pushed
3. Human (or agent) testing is required before closure

To close a ticket after verification:
```bash
tk edit <ticket-id> --status closed
```

Use `tk ls --status=needs_testing` to see tickets awaiting verification.

## Learning Extraction

Powers includes hooks that capture session knowledge before it's lost to context compaction or session end.

**PreCompact hook** — Prompts Claude to produce a structured session summary (tickets, decisions, problems, discoveries, incomplete work) while it still has full context.

**SessionEnd hook** — Extracts the summary from the session transcript and pushes it to the [learnings](https://github.com/EnderRealm/learnings) repo.

Summaries are processed nightly by the [Manager](https://github.com/EnderRealm/manager) repo's extraction pipeline:
1. Catch-up: summarize any missed sessions
2. Extract: create tickets from unresolved problems, discoveries, incomplete work
3. Detect patterns: identify recurring themes across sessions and projects
4. Generate rollups: daily, weekly, monthly, annual summaries

### Nightly Pipeline Setup

The nightly job runs from the [Manager](https://github.com/EnderRealm/manager) repo. Requires Bash 5+ (`brew install bash`).

**Run manually:**
```bash
~/code/manager/scripts/nightly-pipeline.sh
```

**Install as launchd job (runs daily at 2am):**
```bash
cp ~/code/manager/scripts/com.smacbeth.learnings-nightly.plist ~/Library/LaunchAgents/
launchctl load ~/Library/LaunchAgents/com.smacbeth.learnings-nightly.plist
```

**Check logs:**
```bash
tail -f ~/code/manager/logs/nightly-pipeline.log
```

**Uninstall:**
```bash
launchctl unload ~/Library/LaunchAgents/com.smacbeth.learnings-nightly.plist
rm ~/Library/LaunchAgents/com.smacbeth.learnings-nightly.plist
```

See `docs/LEARNING-EXTRACTION-DESIGN.md` for the full system design.

## Project Structure

```
agents/
  plan-reviewer.md    # Plan validation agent
skills/
  create-feature/     # /create-feature workflow
  create-bug/         # /create-bug workflow
  work-ticket/        # /work-ticket resume logic
  brainstorming/      # /brainstorm design sessions
  investigate/        # /investigate debugging methodology
  css-architecture/   # CSS token system and semantic styling
  create-tickets/     # Epic/task generation
  using-powers/       # Session start context
  tk-list/            # Ticket listing
  tk-ready/           # Ready tickets
  tk-ticket/          # Single ticket creation
hooks/
  hooks.json          # Hook registration (SessionStart, PreCompact, SessionEnd)
  session-start.sh    # Injects using-powers context
  extract-session-summary.sh  # Extracts summaries to learnings repo
  run-hook.cmd        # Cross-platform hook runner
docs/
  TICKET-CONVENTIONS.md          # Ticket structure patterns
  LEARNING-EXTRACTION-DESIGN.md  # Learning extraction system design
templates/
  PROJECT.md          # Project config template
CLAUDE.global.md      # Global agent instructions
settings.global.json  # Global permissions
```

## Local Development

```bash
/plugin marketplace add powers-dev file://./.claude-plugin/marketplace.json
/plugin install powers-dev@powers
```

## Updating

```
/plugin update powers
```

## License

MIT
