# Ticket Structure Conventions

Standard patterns for ticket content throughout the development workflow.

## Checkpoint Comments

Track workflow progress with HTML comments (invisible in rendered markdown):

```markdown
## Plan

1. Add validation to utils/validate.ts
2. Wire to form component

<!-- checkpoint: planning -->
```

**Valid checkpoints:**
- `<!-- checkpoint: brainstorm -->` — Feature flow only
- `<!-- checkpoint: planning -->` — Feature flow only
- `<!-- checkpoint: executing -->` — Both flows
- `<!-- checkpoint: testing -->` — Both flows
- `<!-- checkpoint: finalized -->` — Feature flow only
- `<!-- checkpoint: investigating -->` — Bug flow only

## Learnings Section

Capture insights for later mining:

```markdown
## Learnings

- Session library doesn't auto-refresh tokens; need manual refresh logic
- Zod validation errors include path info useful for form field highlighting
```

**Mining learnings:**
```bash
rg "^## Learnings" -A 10 .tickets/
```

## Decision Documentation

Document decisions inline where they occur, tagged by source:

```markdown
## Plan

**Decision:** Use Zod for validation (auto) — TypeScript-first, better errors than Joi

1. Add Zod schema to utils/validate.ts
2. Wire to form component
```

Multiple decisions in a section:

```markdown
## Execute

Added validation schema and wired to form.

**Decisions made:**
- Skip React Hook Form (human) — Steve: "Overkill for single field"
- Add debounce to search (auto) — Prevents API spam

**What changed:**
- Created utils/validate.ts with Zod schema
- Added debounce hook to SearchInput
```

**Tags:**
- `(auto)` — Claude made this decision autonomously
- `(human)` — Human override or explicit direction

**Mining decisions:**
```bash
rg "\*\*Decision" .tickets/           # All decisions
rg "\(human\)" .tickets/              # Human overrides
```

## Test Results

Document test execution with timestamp and counts:

```markdown
## Test Results

**2026-01-25 14:32:** 47 tests, 47 passed

Verified manually:
- Form validation shows errors on invalid input
- Success message appears after submit
- User appears in list after creation
```

Failed tests (fix before proceeding):

```markdown
## Test Results

**2026-01-25 14:32:** 47 tests, 45 passed, 2 failed
- FAIL: UserForm.test.ts - validation error message
- FAIL: UserList.test.ts - missing user after create

Fixed validation message format, re-ran:
**2026-01-25 14:38:** 47 tests, 47 passed
```

## Bug Tickets: Root Cause

Bug tickets must document root cause and fix:

```markdown
## Root Cause

Session token expiration check used `<` instead of `<=`, causing
tokens to be considered valid for 1 second after actual expiration.

## Fix

Changed comparison in `src/auth/session.ts:47` from `<` to `<=`.

## Verified

Reproduced with token expiring at T, confirmed redirect at T.
After fix, redirect occurs correctly at T.
```

## Phase-Specific Updates

### Execute Phase (Features)

```markdown
## Execute

**What changed:**
- Created src/utils/validate.ts with Zod schema for user form
- Added useDebounce hook to src/hooks/useDebounce.ts
- Wired validation to UserForm component

**Decisions made:**
- Use native form validation API (auto) — Simpler than custom error state

<!-- checkpoint: executing -->
```

### Finalize Phase (Features)

```markdown
## Finalize

**Known limitations:**
- Validation messages not yet localized

**TODOs filed:**
- p-1234: Add i18n support for validation messages

<!-- checkpoint: finalized -->
```

## Auto Mode: Questions Considered

When running with `--auto`, document questions that would have been asked:

```markdown
## Questions Considered (auto mode)

- Q: Use optimistic updates? → Yes, improves perceived performance
- Q: Add retry logic for failed submissions? → No, YAGNI for MVP
- Q: Include loading skeleton? → No, spinner sufficient
```

## Complete Feature Ticket Example

```markdown
---
id: p-1234
type: feature
stage: triage
---
# Add user form validation

## Problem

Users can submit invalid data, causing server errors.

## Solution

Client-side validation with Zod, error display on form fields.

## Success Criteria

- Invalid submissions blocked before API call
- Error messages appear next to relevant fields
- Valid submissions proceed normally

## Constraints

- Must work without JavaScript (progressive enhancement)

<!-- checkpoint: brainstorm -->

## Plan

**Decision:** Use Zod for validation (auto) — TypeScript-first, good error messages

1. Create Zod schema in utils/validate.ts
2. Add validation hook to UserForm
3. Display field-level errors
4. Test with Puppeteer

<!-- checkpoint: planning -->

## Execute

**What changed:**
- Created src/utils/validate.ts
- Added validation to UserForm.tsx
- Styled error messages in UserForm.module.css

**Decisions made:**
- Use native constraint validation API (human) — Steve: "Keep it simple"

<!-- checkpoint: executing -->

## Test Results

**2026-01-25 15:42:** 52 tests, 52 passed

Verified via Puppeteer:
- Empty form shows required errors
- Invalid email shows format error
- Valid form submits successfully

<!-- checkpoint: testing -->

## Finalize

**Known limitations:**
- Error messages English only

<!-- checkpoint: finalized -->

## Learnings

- Zod's `.safeParse()` returns typed errors with field paths
- Native constraint validation fires on blur, not on change
```

## Complete Bug Ticket Example

```markdown
---
id: p-5678
type: bug
stage: triage
---
# Login fails silently when session expired

## Symptoms

User clicks login, nothing happens. No error message. Console shows 401.

<!-- checkpoint: investigating -->

## Root Cause

Session refresh endpoint returns 401 when token fully expired (vs 403 for
refresh-needed). Client only handles 403, ignores 401.

## Fix

Added 401 handling in src/auth/client.ts:89 to redirect to login page.

**Decision:** Redirect vs show error (auto) — Redirect cleaner UX for expired session

<!-- checkpoint: executing -->

## Verified

1. Set token expiry to past
2. Attempted action requiring auth
3. Before: silent failure. After: redirect to /login

**2026-01-25 16:10:** 48 tests, 48 passed

<!-- checkpoint: testing -->

## Learnings

- Auth API uses 401 for "definitely expired", 403 for "refresh might work"
- Should document these status code semantics in API docs
```
