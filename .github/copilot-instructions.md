# mQuiz Platform — Project-Wide Copilot Instructions

## Project Identity

**mQuiz** is an AI-powered gamified learning and trivia platform. The codebase is in a **hybrid migration**: the existing PHP/CodeIgniter backend is being replaced by a Node.js/NestJS backend while the Flutter mobile app continues serving users. A new Flutter app is being built in parallel for Apple Store submission.

See `DEVELOPER_ROADMAP.md` at the repo root for the full technical plan, phase definitions, and decision rationale.

---

## Repository Layout

```
admin_backend/          ← Legacy PHP/CodeIgniter backend (READ ONLY during migration)
lib/                    ← Existing Flutter app (Dart)
apps/api/               ← New NestJS backend (active development)
apps/admin/             ← New Next.js admin panel (active development)
apps/mobile/            ← New Flutter app for Apple Store (active development)
admin_backend/database/migrations/   ← MySQL migration history (source of truth for schema)
```

Do not modify `admin_backend/` unless explicitly asked. It runs in production and must stay stable until Node.js achieves full feature parity.

---

## Active Technology Stack

| Layer | Technology |
|---|---|
| Backend | Node.js 22 + NestJS 11 |
| ORM | Prisma 6 (MySQL initially, PostgreSQL-ready) |
| Database | MySQL 8 (`tbl_` prefix on all tables) |
| Admin Panel | Next.js 15 (App Router) + Tailwind CSS + shadcn/ui |
| Mobile (existing) | Flutter 3.x + Cubit pattern |
| Mobile (new) | Flutter 3.x + GoRouter + Cubit pattern |
| Auth | Firebase Auth (tokens verified by firebase-admin in NestJS) |
| Real-time | Firebase Firestore (battle rooms — do not replace) |
| Push | Firebase Cloud Messaging via firebase-admin |
| Payments | Paystack + Flutterwave |
| AI | OpenAI GPT-4o (generation), GPT-4o-mini (per-answer explanations) |
| Cache | Redis (leaderboard, rate limiting, sessions) |

---

## Universal Conventions

### API Response Envelope (NestJS)

Every API response — success or error — must use this shape:

```json
{ "success": true,  "data": { ... },   "message": "OK" }
{ "success": false, "error": "ERROR_CODE", "message": "Human-readable message" }
```

This is enforced by `TransformInterceptor` and `HttpExceptionFilter` in `apps/api/src/common/`. Never return raw objects or raw error messages.

### Database Access

- **Always use Prisma** for all DB reads and writes in the NestJS backend. Never write raw SQL in application code.
- All table names use the `tbl_` prefix. Map them in Prisma with `@@map("tbl_tablename")`.
- Column names in MySQL are `snake_case`. Map them with `@map("column_name")` in Prisma models.
- All Prisma queries live in the service layer (`*.service.ts`), never in controllers or DTOs.

### Authentication

- Protected routes use `@UseGuards(FirebaseAuthGuard)`.
- Get the current user in a controller with `@CurrentUser() user: DecodedIdToken`.
- Never trust the request body or query params for the user's identity — always derive from the verified Firebase token.
- Admin-only routes additionally use `@UseGuards(FirebaseAuthGuard, RolesGuard)` with `@Roles('admin')`.

### Security — Non-Negotiable Rules

- Validate ALL input using `class-validator` DTOs with `ValidationPipe` (global, with `whitelist: true, forbidNonWhitelisted: true`).
- Never expose stack traces or internal error details in production API responses.
- Paystack webhook endpoint must verify the `x-paystack-signature` HMAC-SHA512 header before processing.
- Firebase token verification is the only accepted auth mechanism — never implement a custom JWT or session.
- Apply `@Throttle()` to all public endpoints and auth endpoints.
- Sanitize any content that may be stored and later rendered (question text, user names).

### Naming Conventions

| Context | Convention |
|---|---|
| NestJS files | `feature.controller.ts`, `feature.service.ts`, `feature.module.ts` |
| NestJS DTOs | `create-feature.dto.ts`, `update-feature.dto.ts` |
| Prisma model | PascalCase (`LeagueUser`), mapped to `tbl_snake_case` |
| Flutter files | `feature_cubit.dart`, `feature_screen.dart`, `feature_model.dart` |
| Flutter cubits | `FeatureCubit` extending `Cubit<FeatureState>` |
| Next.js pages | `app/feature/page.tsx`, `app/feature/[id]/page.tsx` |

---

## Phase Awareness

When writing code, be aware of the current migration phase:

- **Phases 1–2** (active now): Building NestJS backend + Next.js admin. PHP backend is read-only reference.
- **Phase 3**: Flutter app will be pointed at Node.js APIs — maintain backwards-compatible response shapes.
- **Phases 4–6**: New features, new Flutter app, schools/AI — gated behind feature flags.

Do not add Phase 4+ features to Phase 1 modules unless explicitly requested.

---

## Key Reference Files

- Architecture & phases: `DEVELOPER_ROADMAP.md`
- Full product vision: `New_RoadMap.md`
- Existing DB schema: `admin_backend/database/migrations/mquiz_d5bueportal (5).sql`
- League schema: `admin_backend/database/migrations/2026_03_19_create_league_system.sql`
- Monetization schema: `admin_backend/database/migrations/2026_01_16_add_monetization_tables.sql`
