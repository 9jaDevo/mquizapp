# mQuizApp Copilot Instructions

## Mandatory Generation Order

1. Run existing-code audit first.
2. Generate/update Copilot scaffolding files second.
3. Generate feature code only after checklist gates are passed.

Do not skip this order.

## Existing-Code Audit Rule (Hard Gate)

Before creating any new feature files:

- Inspect related backend and Flutter modules.
- Reuse established patterns from contest flow where possible.
- Produce a delta list with four buckets:
  - Reuse as-is
  - Modify existing
  - Create new
  - Do not touch

If audit is incomplete, stop code generation.

## League Feature Conventions

### Backend (CodeIgniter / Api.php)

- Endpoint style: `{name}_post()`.
- Always call `verify_token()` for authenticated endpoints.
- Return stable payload shape:
  - `error`: bool
  - `message`: string/error code
  - `data`: object/list
- Use timezone-aware logic (`timezone`, `gmt_format`) consistent with contest APIs.
- Wrap write operations in DB transactions.

### Flutter

- Use existing quiz architecture:
  - models in `lib/features/quiz/models/`
  - cubits in `lib/features/quiz/cubits/`
  - screens in `lib/ui/screens/quiz/`
- Keep naming consistent with contest implementations.
- Handle loading/success/failure states explicitly.

### Database

- New league schema must live in `admin_backend/database/migrations/`.
- Keep compatibility with existing contest tables and scoring formula.
- Avoid destructive migration steps unless explicitly approved.

## Security and Safety

- Never hardcode secrets, API keys, or tokens.
- Validate all required request fields.
- Avoid destructive commands and broad refactors in unrelated modules.

## Phase Checklist Gate

Before moving to the next phase, mark all items complete in:

- `docs/LEAGUE_IMPLEMENTATION_CHECKLIST.md`

If the phase is not fully checked, do not start the next one.
