# Agent Registry

## Key Reference Documents

Before any agent begins work, it must be aware of:
- **Architecture & phases**: `DEVELOPER_ROADMAP.md` — single source of truth for all technical decisions.
- **Product vision**: `New_RoadMap.md` — full feature set, target audience, monetization.
- **DB schema (live)**: `admin_backend/database/migrations/mquiz_d5bueportal (5).sql`
- **Project-wide conventions**: `.github/copilot-instructions.md`

---

## Planning Agent

Purpose:
- Convert product goals into implementable phases.
- Define sequencing, dependencies, and acceptance criteria.

Responsibilities:
- Maintain phase plan and checklist integrity in `DEVELOPER_ROADMAP.md`.
- Enforce mandatory gates (security audit, scaffolding, phase completion checklist).
- Reference `New_RoadMap.md` for feature scope — do not invent features not in the roadmap.
- Classify work by migration phase (Phase 1 = Node.js backend, Phase 2 = admin, Phase 3 = Flutter connect, etc.).

---

## Explore Agent

Purpose:
- Perform read-only analysis before implementation.

Responsibilities:
- Inspect existing PHP backend in `admin_backend/` to understand existing behavior before migrating.
- Inspect existing Flutter code in `lib/` to identify reusable cubits, models, and patterns.
- Produce delta map: reuse, modify, create, do-not-touch.
- Identify which tables in `tbl_*` schema are relevant to the work.
- **Never modify files** — read and report only.

---

## Implementation Agent

Purpose:
- Implement scoped changes phase-by-phase.

Responsibilities:
- Follow conventions from `.github/copilot-instructions.md` at all times.
- Use the appropriate `.github/instructions/*.instructions.md` file for the layer being worked on (NestJS, Flutter, Prisma, Next.js, migrations).
- For NestJS modules: use the `nestjs-module-generator` skill.
- For PHP→NestJS migration: use the `php-to-nestjs-migration` skill.
- For Flutter API reconnection: use the `flutter-feature-migration` skill.
- Make minimal, targeted edits — do not refactor unrelated code.
- Do not proceed to the next phase without all checklist items ticked in `DEVELOPER_ROADMAP.md`.
- **Never modify `admin_backend/`** unless explicitly asked.

---

## Security Agent

Purpose:
- Enforce security compliance before merging any feature.

Responsibilities:
- Run the `/security-audit` prompt against every new controller and service.
- Verify OWASP Top 10 mitigations per `.github/instructions/security-compliance.instructions.md`.
- Flag: missing auth guards, unvalidated inputs, Paystack webhook without signature check, raw SQL, hardcoded secrets.
- Block merge if Critical or High severity issues are unresolved.
- Check fraud detection coverage for gamification features (coin award, lives restore, quiz submit).

---

## Review Agent

Purpose:
- Validate quality, regressions, and completion.

Responsibilities:
- Verify acceptance criteria and test coverage for each phase (see Definition of Done in `DEVELOPER_ROADMAP.md` Section 18).
- Confirm no unrelated regressions introduced.
- Verify response shape backward compatibility during Phase 3 (NestJS must match PHP response `data` field structure).
- Run `npm audit` and report any high/critical vulnerabilities.

---

## Handoff Rules

- Planning → Explore: include target phase, scope of feature, and paths to relevant existing code.
- Explore → Implementation: include delta map (reuse/modify/create), risks, and relevant table names.
- Implementation → Security Agent: include all changed files and any new endpoints or DB writes.
- Security Agent → Review: include audit results with severity ratings.
- Implementation → Review: include changed files, test results, and API response diff (if migrating from PHP).

---

## Tool Boundaries

- Prefer read-only discovery before edits.
- Do not use destructive repository commands (`DROP TABLE`, `git reset --hard`, `rm -rf`).
- Avoid editing unrelated files — one concern per PR.
- Do not modify `.github/copilot-instructions.md` or `DEVELOPER_ROADMAP.md` unless explicitly asked.
- The `admin_backend/` directory is production code — treat as read-only unless explicitly tasked.

---

## Available Skills (`.github/skills/`)

| Skill | When to Use |
|---|---|
| `nestjs-module-generator` | Creating a new NestJS feature module from scratch |
| `php-to-nestjs-migration` | Migrating a specific PHP endpoint to NestJS |
| `flutter-feature-migration` | Connecting an existing Flutter feature to the Node.js API |
| `league-api-implementation` | Implementing league-specific backend endpoints |
| `league-feature-planning` | Planning league feature phases and dependencies |
| `league-flutter-ui` | Building Flutter UI for league features |
| `league-notifications-ads` | League notification and ad integration |

## Available Prompts (`.github/prompts/`)

| Prompt | When to Use |
|---|---|
| `create-nestjs-module` | Scaffold a complete NestJS module interactively |
| `create-flutter-feature` | Scaffold a complete Flutter feature with cubit/model/screen |
| `create-admin-page` | Scaffold a Next.js admin page with table and auth |
| `security-audit` | Audit any file for OWASP Top 10 issues |
