# Phase 5C — Partner-Hosted Quiz Competition System

## Status Legend
- ✅ Done
- 🔄 In Progress
- ⬜ Pending
- ❌ Blocked

---

## Layer 1: Database

| # | Task | File | Status |
|---|------|------|--------|
| 1.1 | SQL migration — 6 partner tables | `apps/api/prisma/migrations/20260530_create_partner_system.sql` | ✅ Done |
| 1.2 | Prisma schema — 6 models | `apps/api/prisma/schema.prisma` (appended) | ✅ Done |
| 1.3 | `prisma generate` | — | ✅ Done |

---

## Layer 2: NestJS Backend

| # | Task | File | Status |
|---|------|------|--------|
| 2.1 | `PartnerAuthGuard` | `apps/api/src/common/guards/partner-auth.guard.ts` | ✅ Done |
| 2.2 | `@CurrentPartner()` decorator | `apps/api/src/common/decorators/current-partner.decorator.ts` | ✅ Done |
| 2.3 | `RegisterPartnerDto` | `apps/api/src/modules/partner/dto/register-partner.dto.ts` | ✅ Done |
| 2.4 | `CreatePartnerContestDto` | `apps/api/src/modules/partner/dto/create-partner-contest.dto.ts` | ✅ Done |
| 2.5 | Question DTOs (add, from-bank, reorder) | `apps/api/src/modules/partner/dto/add-partner-question.dto.ts` | ✅ Done |
| 2.6 | `SubmitPartnerContestDto`, `JoinWithCodeDto` | `apps/api/src/modules/partner/dto/submit-partner-contest.dto.ts` | ✅ Done |
| 2.7 | `PartnerService` (full business logic) | `apps/api/src/modules/partner/partner.service.ts` | ✅ Done |
| 2.8 | `PartnerAuthController` | `apps/api/src/modules/partner/partner-auth.controller.ts` | ✅ Done |
| 2.9 | `PartnerController` (dashboard routes) | `apps/api/src/modules/partner/partner.controller.ts` | ✅ Done |
| 2.10 | `PartnerPublicController` (mobile) | `apps/api/src/modules/partner/partner-public.controller.ts` | ✅ Done |
| 2.11 | `PartnerModule` | `apps/api/src/modules/partner/partner.module.ts` | ✅ Done |
| 2.12 | Register `PartnerModule` in `AppModule` | `apps/api/src/app.module.ts` | ✅ Done |
| 2.13 | Admin oversight endpoints (controller) | `apps/api/src/modules/admin/admin.controller.ts` | ✅ Done |
| 2.14 | Admin oversight methods (service delegation) | `apps/api/src/modules/admin/admin.service.ts` | ✅ Done |
| 2.15 | `AdminModule` imports `PartnerModule` | `apps/api/src/modules/admin/admin.module.ts` | ✅ Done |
| 2.16 | TypeScript compile — zero errors | — | ✅ Done |

---

## Layer 3: Next.js Admin Partner Portal

| # | Task | File | Status |
|---|------|------|--------|
| 3.1 | Partner auth pages (login, register) | `apps/admin/app/partner/auth/` | ✅ Done |
| 3.2 | Partner dashboard layout | `apps/admin/app/partner/(dashboard)/layout.tsx` | ✅ Done |
| 3.3 | Partner dashboard home | `apps/admin/app/partner/(dashboard)/page.tsx` | ✅ Done |
| 3.4 | Contests list page | `apps/admin/app/partner/(dashboard)/contests/page.tsx` | ✅ Done |
| 3.5 | Contest detail/edit page | `apps/admin/app/partner/(dashboard)/contests/[id]/page.tsx` | ✅ Done |
| 3.6 | Questions editor page | `apps/admin/app/partner/(dashboard)/contests/[id]/questions/page.tsx` | ✅ Done |
| 3.7 | Participants page | `apps/admin/app/partner/(dashboard)/contests/[id]/participants/page.tsx` | ✅ Done |
| 3.8 | Leaderboard page | `apps/admin/app/partner/(dashboard)/contests/[id]/leaderboard/page.tsx` | ✅ Done |
| 3.9 | Analytics page | `apps/admin/app/partner/(dashboard)/analytics/page.tsx` | ✅ Done |
| 3.10 | Team management page | `apps/admin/app/partner/(dashboard)/team/page.tsx` | ✅ Done |
| 3.11 | Settings/profile page | `apps/admin/app/partner/(dashboard)/settings/page.tsx` | ✅ Done |
| 3.12 | Partner auth config | `apps/admin/lib/partner-auth.ts` | ✅ Done |
| 3.13 | Partner API client | `apps/admin/lib/partner-api-client.ts` | ✅ Done |
| 3.14 | Admin oversight — partner list | `apps/admin/app/(dashboard)/partners/page.tsx` | ✅ Done |
| 3.15 | Admin oversight — partner detail | `apps/admin/app/(dashboard)/partners/[id]/page.tsx` | ✅ Done |

---

## Layer 4: Flutter Mobile

| # | Task | File | Status |
|---|------|------|--------|
| 4.1 | `PartnerContest` model | `apps/mobile/lib/features/partner_contests/models/partner_contest.dart` | ✅ Done |
| 4.2 | `PartnerLeaderboard` model | `apps/mobile/lib/features/partner_contests/models/partner_leaderboard.dart` | ✅ Done |
| 4.3 | `PartnerContestRepository` | `apps/mobile/lib/features/partner_contests/data/partner_contest_repository.dart` | ✅ Done |
| 4.4 | `PartnerContestListCubit` | `apps/mobile/lib/features/partner_contests/cubit/partner_contest_list_cubit.dart` | ✅ Done |
| 4.5 | `PartnerContestQuizCubit` | `apps/mobile/lib/features/partner_contests/cubit/partner_contest_quiz_cubit.dart` | ✅ Done |
| 4.6 | Contest list screen | `apps/mobile/lib/features/partner_contests/screens/partner_contest_list_screen.dart` | ✅ Done |
| 4.7 | Join-with-code screen | `apps/mobile/lib/features/partner_contests/screens/partner_join_code_screen.dart` | ✅ Done |
| 4.8 | Contest detail screen | `apps/mobile/lib/features/partner_contests/screens/partner_contest_detail_screen.dart` | ✅ Done |
| 4.9 | Quiz screen | `apps/mobile/lib/features/partner_contests/screens/partner_contest_quiz_screen.dart` | ✅ Done |
| 4.10 | Result screen | reuses `SessionResultScreen` via `SessionResultExtra` | ✅ Done |
| 4.11 | Leaderboard screen | `apps/mobile/lib/features/partner_contests/screens/partner_contest_leaderboard_screen.dart` | ✅ Done |
| 4.12 | NestJS API methods (7 partner endpoints) | `apps/mobile/lib/core/network/nestjs_api.dart` | ✅ Done |
| 4.13 | GoRouter partner contest routes | `apps/mobile/lib/app/router.dart` | ✅ Done |

---

## API Endpoint Reference

### Auth (public + standard firebase)
| Method | Path | Description |
|--------|------|-------------|
| `POST` | `/v2/partner/auth/register` | Register new partner org |
| `POST` | `/v2/partner/auth/login` | Login (returns custom token with partner claims) |
| `GET` | `/v2/partner/auth/me` | Current partner identity |

### Partner Dashboard (PartnerAuthGuard)
| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/v2/partner/profile` | Profile + plan usage |
| `PUT` | `/v2/partner/profile` | Update profile |
| `GET` | `/v2/partner/plan` | Plan limits |
| `GET` | `/v2/partner/team` | Team members |
| `POST` | `/v2/partner/team/invite` | Invite team member |
| `DELETE` | `/v2/partner/team/:memberId` | Remove team member (owner only) |
| `GET` | `/v2/partner/contests` | List contests |
| `POST` | `/v2/partner/contests` | Create contest |
| `GET/PUT` | `/v2/partner/contests/:id` | Get/update contest |
| `DELETE` | `/v2/partner/contests/:id` | Delete draft contest |
| `POST` | `/v2/partner/contests/:id/publish` | Publish contest |
| `POST` | `/v2/partner/contests/:id/end` | End contest |
| `POST` | `/v2/partner/contests/:id/regenerate-code` | New invite code |
| `GET/POST` | `/v2/partner/contests/:id/questions` | List/add questions |
| `PUT/DELETE` | `/v2/partner/contests/:id/questions/:qid` | Update/delete question |
| `POST` | `/v2/partner/contests/:id/questions/from-bank` | Add from bank (Starter+) |
| `PUT` | `/v2/partner/contests/:id/questions/reorder` | Reorder questions |
| `GET` | `/v2/partner/contests/:id/participants` | Participants list |
| `GET` | `/v2/partner/contests/:id/leaderboard` | Live leaderboard |
| `POST` | `/v2/partner/contests/:id/prizes/distribute` | Mark prizes distributed |
| `GET` | `/v2/partner/analytics` | Overview analytics |
| `GET` | `/v2/partner/analytics/contests/:id` | Contest analytics |

### Public Mobile (FirebaseAuthGuard)
| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/v2/contests/partner` | List public contests |
| `GET` | `/v2/contests/partner/:id` | Contest detail |
| `POST` | `/v2/contests/partner/join-code` | Look up by invite code |
| `POST` | `/v2/contests/partner/:id/join` | Join contest |
| `GET` | `/v2/contests/partner/:id/questions` | Get questions |
| `POST` | `/v2/contests/partner/:id/submit` | Submit answers |
| `GET` | `/v2/contests/partner/:id/leaderboard` | Public leaderboard |

### Admin Oversight (AdminGuard)
| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/v2/admin/partners` | List all partners |
| `GET` | `/v2/admin/partners/:id` | Partner detail |
| `POST` | `/v2/admin/partners/:id/approve` | Approve pending partner |
| `POST` | `/v2/admin/partners/:id/suspend` | Suspend partner |
| `PUT` | `/v2/admin/partners/:id/plan` | Override plan |
| `GET` | `/v2/admin/partners/:id/contests` | Partner's contests |

---

## Plan Limits

| Plan | Active Contests | Max Participants | Questions/Contest | Bank Access |
|------|----------------|-----------------|-------------------|-------------|
| free | 1 | 50 | 30 | ❌ |
| starter | 3 | 500 | 200 | ✅ |
| pro | 10 | 5,000 | unlimited | ✅ |
| enterprise | unlimited | unlimited | unlimited | ✅ |

---

## Definition of Done — Phase 5C

- [ ] All NestJS partner endpoints return correct `{ success, data, message }` envelope
- [ ] `PartnerAuthGuard` rejects requests without partner claims
- [ ] Suspended partner tokens are revoked via Firebase Admin SDK
- [ ] Score calculation is server-side only (answer key never sent to client)
- [ ] Plan limits enforced server-side with clear error messages
- [ ] Admin can approve, suspend, and override plans
- [ ] Partner can create, publish, and end contests
- [ ] Invite codes are unique 8-char hex, case-insensitive lookup
- [ ] Leaderboard ranks recomputed on every submission
- [ ] TypeScript compiles with zero errors
- [ ] Next.js partner portal implemented
- [ ] Flutter mobile partner contests feature implemented
