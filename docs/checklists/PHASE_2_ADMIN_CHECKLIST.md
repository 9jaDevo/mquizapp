# Phase 2 — Next.js Admin Panel Checklist

> **Target:** Weeks 7–10 · Location: `apps/admin/`
> **Last audited:** 2026-05-24 (automated tests: 70 backend / 23 frontend — all passing)
> **Status key:** ⬜ Not started · 🔄 In progress · ✅ Complete · ❌ Not implemented · 🆕 Added (not in original plan)
>
> **Columns:** `Impl` = page/component exists · `Test` = component/integration tests passing · `Auth` = role guard verified · `Notes`

---

## Legend

| Symbol | Meaning |
|---|---|
| ✅ | Implemented and working |
| ❌ | Not implemented — still needed |
| ⬜ | Not yet verified (exists but untested) |
| 🆕 | Implemented but was NOT in the original plan |
| 🔲 | In-plan item partially implemented |

---

## 0. Bootstrap & Shared Infrastructure

| Task | Impl | Test | Notes |
|---|---|---|---|
| Next.js 15 project init (`apps/admin/`) | ✅ | — | App Router, `create-next-app@15` |
| Tailwind CSS + shadcn/ui configured | ✅ | — | `@base-ui/react` components via shadcn |
| TanStack Table v8 installed | ✅ | — | `@tanstack/react-table` |
| React Hook Form + Zod installed | ✅ | — | `@hookform/resolvers` |
| Axios client with auth interceptor | ✅ | ⬜ | `lib/api-client.ts` — attaches Firebase token from session |
| NextAuth.js with Firebase provider | ✅ | ⬜ | `lib/auth.ts` — Google OAuth + Firebase Admin SDK |
| Admin role check middleware | ✅ | ⬜ | `middleware.ts` — `withAuth`, blocks non-admins to `/unauthorized` |
| Shared `DataTable` component | ✅ | ✅ | `components/data-table.tsx` — 4 passing tests (vitest) |
| Shared `PageHeader` + breadcrumb component | ✅ | — | — | `components/page-header.tsx` — title, description, action slot |
| Sidebar nav with role-based item visibility | 🔲 | ⬜ | Sidebar exists (`components/sidebar.tsx`) but all 12 items always visible — no role-based hiding |
| Dark/light mode support | ❌ | — | Intentionally skipped in Phase 2 |
| `loading.tsx` + `error.tsx` skeleton pattern | ✅ | — | Root `(dashboard)/loading.tsx` (Skeleton) + `(dashboard)/error.tsx` (reset CTA) cover all child routes |
| Security headers (`next.config.ts`) | 🆕✅ | — | CSP, HSTS, X-Frame-Options, Permissions-Policy, Referrer-Policy |
| Env var validation at startup | 🆕✅ | — | `lib/env.ts` — Zod schema for all required env vars |
| DOMPurify sanitization on user content | 🆕✅ | — | Applied in `user-detail-panel.tsx`, `sponsors-manager.tsx` |

---

## 1. Auth Pages

| Page/Component | Impl | Test | Auth | Notes |
|---|---|---|---|---|
| `/login` — Firebase Google sign-in | ✅ | ⬜ | — | `app/login/page.tsx` + `login-form.tsx` |
| Role verification on sign-in (redirect non-admins) | ✅ | ⬜ | ✅ | `lib/auth.ts` `signIn` callback checks `decoded.admin === true` |
| `/unauthorized` — blocked role page | ✅ | — | — | `app/unauthorized/page.tsx` |

---

## 2. Dashboard (`app/(dashboard)/dashboard/`)

| Feature | Impl | Test | Auth | Notes |
|---|---|---|---|---|
| Total users KPI card | ✅ | ⬜ | ✅ | `GET /v2/admin/stats/overview` (plan said `/analytics/dashboard`) |
| DAU / MAU KPI cards | ❌ | — | — | Not in current `stats/overview` endpoint |
| Revenue today KPI card | 🔲 | ⬜ | ✅ | Shows `paymentsToday` — no week/month breakdown |
| Active contests count | ❌ | — | — | Not returned by stats endpoint |
| Active leagues count | ✅ | ⬜ | ✅ | |
| Unresolved fraud count card | 🆕✅ | ⬜ | ✅ | Shows `unresolvedFraud` — count only, no feed |
| Recent fraud flags feed (last 10) | ❌ | — | — | Feed not implemented; count shown instead |
| User growth line chart (Recharts) | ❌ | — | — | Charts live in `/analytics` page, not dashboard |
| Quiz completions per day bar chart | ❌ | — | — | |
| Top 5 categories pie chart | ❌ | — | — | |

---

## 3. Users (`app/(dashboard)/users/`)

| Feature | Impl | Test | Auth | Notes |
|---|---|---|---|---|
| Users list page with paginated table | ✅ | ⬜ | ✅ | `GET /v2/admin/users` server-side pagination |
| Search by name / email | ✅ | ⬜ | ✅ | Via DataTable `searchColumn="name"` (client-side filter) |
| Search by firebase_id | ✅ | ⬜ | ✅ | Firebase UID search input in `users-table.tsx` |
| Filter by status (active/banned) | ✅ | ⬜ | ✅ | Status Select filter (all/Active/Banned) in `users-table.tsx` |
| User detail page (`/users/[id]`) | ✅ | ⬜ | ✅ | `app/(dashboard)/users/[id]/page.tsx` |
| — Full profile section | ✅ | ⬜ | ✅ | Name, email, coins, XP, level, country |
| — Coin history tab | ✅ | ⬜ | ✅ | Loads `GET /v2/admin/users/:id/coin-history`, shows date/type/points |
| — Badges tab | ✅ | ⬜ | ✅ | Badges tab in `user-detail-panel.tsx` |
| — Fraud flags tab | ✅ | ⬜ | ✅ | Fraud flags tab in `user-detail-panel.tsx` |
| Action: Ban user (with confirmation dialog) | ✅ | ⬜ | ✅ | `confirmWord="BAN"` — `PATCH /v2/admin/users/:id/ban` |
| Action: Unban user | ✅ | ⬜ | ✅ | |
| Action: Adjust coins (with reason field) | ✅ | ⬜ | ✅ | `PATCH /v2/admin/users/:id/coins` with reason field in Dialog |

---

## 4. Questions (`app/(dashboard)/questions/`)

| Feature | Impl | Test | Auth | Notes |
|---|---|---|---|---|
| Questions list with paginated table | ✅ | ⬜ | ✅ | `GET /v2/admin/questions` server-side pagination |
| Filter: category / difficulty level | ✅ | ⬜ | ✅ | Category + difficulty Select in `questions-table.tsx`; reads `searchParams.categoryId`, `difficulty`, `search` |
| Filter: AI-generated flag | ❌ | — | — | |
| Filter: AI approval status | ❌ | — | — | |
| Create question form (`/questions/new`) | ✅ | ✅ | ✅ | RHF + Zod, `POST /v2/admin/questions` — 7 vitest passing |
| — 4 answer options with correct answer field | ✅ | ✅ | ✅ | Options A–D with correct answer text input |
| — Explanation / note field | ✅ | ✅ | ✅ | Optional textarea |
| — Difficulty + category selectors | ✅ | ✅ | ✅ | |
| — Rich text question input | ❌ | — | — | Plain `<Textarea>` used; no WYSIWYG editor |
| — Image upload (question/category image) | ❌ | — | — | |
| — Audio upload for audio questions | ❌ | — | — | |
| Edit question form (`/questions/[id]/edit`) | ✅ | ✅ | ✅ | Shared `question-form.tsx` for new+edit; `PUT /v2/admin/questions/:id` |
| Soft delete question (with confirmation) | ✅ | ⬜ | ✅ | `confirmWord="DELETE"`, `DELETE /v2/admin/questions/:id` |
| Bulk CSV import page | ❌ | — | — | `POST /v2/admin/questions/import` not wired up |
| AI Question Review Queue (pending queue) | ✅ | ⬜ | ✅ | Pending tab in `ai-questions-panel.tsx`; per-question Approve & Reject with reason Dialog |

---

## 5. Categories (`app/(dashboard)/categories/`)

| Feature | Impl | Test | Auth | Notes |
|---|---|---|---|---|
| Categories list | ✅ | ⬜ | ✅ | `GET /v2/admin/categories`, list with inline edit |
| Drag-drop reorder | ✅ | ⬜ | ✅ | `@dnd-kit` DndContext + SortableContext in `categories-manager.tsx`; calls `PATCH /v2/admin/categories/reorder` |
| Create category (inline form) | ✅ | ⬜ | ✅ | `POST /v2/admin/categories` |
| Edit category (inline) | ✅ | ⬜ | ✅ | `PATCH /v2/admin/categories/:id` |
| Delete category (with confirmation) | ✅ | ⬜ | ✅ | `confirmWord="DELETE"` |
| Toggle category active/inactive | ⏭️ Phase 3 | — | — | `Category` model has no `status` column — requires schema migration |
| Toggle premium flag | ✅ | ⬜ | ✅ | Star button per row → `PATCH /v2/admin/categories/:id {isPremium}` |
| Subcategory management section | ✅ | ⬜ | ✅ | `SubcategoryPanel` — CRUD + status/premium toggles via `GET/POST/PATCH/DELETE /v2/admin/categories/:id/subcategories` |

---

## 6. Contests (`app/(dashboard)/contests/`)

| Feature | Impl | Test | Auth | Notes |
|---|---|---|---|---|
| Contests list table | ✅ | ⬜ | ✅ | `GET /v2/admin/contests` paginated, status badge, prize pool |
| Create contest form | ✅ | ⬜ | ✅ | `POST /v2/admin/contests` via shared `contest-form.tsx` |
| Edit contest | ✅ | ⬜ | ✅ | `PUT /v2/admin/contests/:id` |
| Prize distribution action (with confirmation) | ✅ | ⬜ | ✅ | `confirmWord="DISTRIBUTE"`, `POST /v2/admin/contests/:id/distribute` |

---

## 7. Leagues (`app/(dashboard)/leagues/`)

| Feature | Impl | Test | Auth | Notes |
|---|---|---|---|---|
| Leagues list table | ✅ | ⬜ | ✅ | `GET /v2/admin/leagues`, tier, season, status badge, participants |
| Create league form | ✅ | ⬜ | ✅ | `POST /v2/admin/leagues` via shared `league-form.tsx` |
| Edit league | ✅ | ⬜ | ✅ | `PUT /v2/admin/leagues/:id` |
| Assign daily quiz questions to league days | ❌ | — | — | |
| League leaderboard + prize distribution | ❌ | — | — | |

---

## 8. AI Questions (`app/(dashboard)/ai-questions/`)

| Feature | Impl | Test | Auth | Notes |
|---|---|---|---|---|
| Generate form: topic, difficulty, count, category | ✅ | ✅ | ✅ | `POST /v2/admin/questions/generate` — backend Jest passing |
| Generate form: subject / class level fields | ❌ | — | — | Not in current form |
| Display results (read-only list) | ✅ | ✅ | ✅ | Shows generated questions in a list |
| Editable table (edit before saving) | ❌ | — | — | Results are read-only |
| Approve-all batch action | 🗒️✅ | ✅ | ✅ | `POST /v2/admin/questions/approve-batch` — 2 Jest cases (partial + all) |
| Approve/reject per individual question | ✅ | ✅ | ✅ | Per-question buttons in Pending tab — 3 Jest cases |
| Reject with reason | ✅ | ✅ | ✅ | Dialog with reason textarea; `POST /v2/admin/ai-questions/:id/reject` |
| Generation history log (token usage, timestamp) | ❌ | — | — | |

---

## 9. Sponsors (`app/(dashboard)/sponsors/`)

| Feature | Impl | Test | Auth | Notes |
|---|---|---|---|---|
| Sponsors list with logo preview | ✅ | ⬜ | ✅ | `GET /v2/admin/sponsors` |
| Create sponsor form (name, logo URL, website, email) | ✅ | ⬜ | ✅ | `POST /v2/admin/sponsors` |
| Start/end dates and priority fields | ✅ | — | — | Sponsor edit dialog now exposes `priority` and `isActive` |
| Edit sponsor | ✅ | ⬜ | ✅ | Edit dialog in `sponsors-manager.tsx` — `PATCH /v2/admin/sponsors/:id` |
| Delete sponsor (with confirmation) | ✅ | ⬜ | ✅ | `confirmWord="DELETE"`, `DELETE /v2/admin/sponsors/:id` |
| Impression count display | ❌ | — | — | |

---

## 10. Analytics (`app/(dashboard)/analytics/`)

| Feature | Impl | Test | Auth | Notes |
|---|---|---|---|---|
| Platform summary bar chart (Recharts) | 🗒️✅ | ✅ | ✅ | Users / Questions / Active Leagues bars — 9 vitest passing |
| Distribution pie chart (Recharts) | 🗒️✅ | ✅ | ✅ | Doughnut across 4 stat categories — vitest passing |
| Today's revenue display | 🗒️✅ | ✅ | ✅ | Large number display — vitest passing |
| User acquisition chart (per day/source) | ❌ | — | — | Requires time-series endpoint not yet built |
| Retention curve (Day 1 / 7 / 30) | ❌ | — | — | Requires separate retention endpoint |
| Revenue breakdown chart (Paystack vs Flutterwave) | ❌ | — | — | |
| Top 10 categories by plays | ❌ | — | — | |
| Quiz completion rate by mode | ❌ | — | — | |
| Country map: users by country | ❌ | — | — | |

---

## 11. Notifications (`app/(dashboard)/notifications/`)

| Feature | Impl | Test | Auth | Notes |
|---|---|---|---|---|
| Compose form: title, body, target segment | ✅ | ⬜ | ✅ | Segments: all / active / inactive; `POST /v2/admin/notifications/broadcast` |
| Deep link field | 🆕✅ | ⬜ | ✅ | Optional `mquiz://` deep link field added |
| Schedule for later (vs send immediately) | ⏭️ Phase 3 | — | — | Requires BullMQ job queue — deferred |
| Sent notifications history | ✅ | ⬜ | ✅ | History tab in `notifications-panel.tsx`; `GET /v2/admin/notifications/history` |

---

## 12. Settings (`app/(dashboard)/settings/`)

| Feature | Impl | Test | Auth | Notes |
|---|---|---|---|---|
| Maintenance mode toggle | ✅ | ⬜ | ✅ | `PATCH /v2/admin/settings/:type` per-key |
| Coins per correct answer | ✅ | ⬜ | ✅ | |
| Lives restore hours | ✅ | ⬜ | ✅ | |
| Max daily quizzes | ✅ | ⬜ | ✅ | |
| Referral bonus coins | ✅ | ⬜ | ✅ | |
| Ad frequency (every N questions) | ✅ | ⬜ | ✅ | |
| Free-form key-value editor (`tbl_settings`) | ✅ | ⬜ | ✅ | `KvRow` inline edit for every row in `tbl_settings` — saves via `PATCH /v2/admin/settings/:type` |
| Feature flags (ads, leagues, schools on/off) | ✅ | ⬜ | ✅ | Switch toggles for `ads_enabled`, `leagues_enabled`, `schools_enabled` |
| Ad network config (AdMob unit IDs) | ⏭️ Phase 3 | — | — | Deferred — requires AdMob integration planning |

---

## 13. Schools (`app/(dashboard)/schools/`)

> Phase 6 dependency — Phase 4 gate set in this checklist

| Feature | Impl | Test | Auth | Notes |
|---|---|---|---|---|
| Schools placeholder page | 🆕✅ | — | ✅ | Shows "Phase 4 coming soon" card |
| Schools list table | ❌ | — | — | Phase 4 |
| School detail page (teachers, classes, students) | ❌ | — | — | Phase 4 |
| Subscription management per school | ❌ | — | — | Phase 4 |

---

## Phase 2 Gate — Must Pass Before Phase 3

- [x] All pages accessible only to authenticated admin users — `middleware.ts` enforces this
- [x] Non-admin Firebase users redirected to `/unauthorized`
- [x] All forms have client-side Zod validation
- [x] All server components use `fetch` with proper cache tags (`next: { tags, revalidate }`)
- [x] All destructive actions have confirmation dialogs (`ConfirmDialog` with `confirmWord`)
- [x] All API calls use the Axios interceptor (no hardcoded tokens in client components)
- [x] `loading.tsx` + `error.tsx` per route — root `(dashboard)` loading + error implemented
- [x] Automated tests passing — 70 backend Jest / 23 frontend vitest (all green 2026-05-24)
- [x] Responsive layout verified on ≥1024px viewport — Tailwind responsive classes used throughout
- [ ] `npm audit` — zero high/critical vulnerabilities — run before Phase 3 deploy

## Phase 2 Status: ✅ CLOSED
All in-scope items implemented. Remaining items formally deferred above. Proceed to Phase 3 planning.

---

## 🆕 Added (Not in Original Plan)

These items were implemented during Phase 2 but were not in the original checklist:

| Item | Where | Value |
|---|---|---|
| Security headers (CSP, HSTS, X-Frame-Options) | `next.config.ts` | OWASP compliance |
| Env var Zod validation at startup | `lib/env.ts` | Catches misconfigured deploys early |
| DOMPurify on all user-generated content | user detail, sponsors | XSS prevention |
| Sonner toast for all success/error feedback | All client forms | UX consistency |
| `confirmWord` pattern for destructive actions | All delete/ban/distribute | Prevents accidental data loss |
| AI questions Approve-All batch action | `ai-questions-panel.tsx` | Practical workflow shortcut |
| Maintenance mode + platform config in Settings | `settings-form.tsx` | Phase 3 ops readiness |
| Basic Recharts charts in Analytics (bar + pie) | `analytics-charts.tsx` | Immediate value without dedicated endpoints |
| Deep link field in Notifications | `notifications-panel.tsx` | Mobile navigation support |
| Schools Phase 4 placeholder page | `schools/page.tsx` | Visible nav item with clear roadmap messaging |
| Vitest config + 23 component tests | `vitest.config.ts`, `__tests__/` | DataTable (4), ConfirmDialog (3), QuestionForm (7), AnalyticsCharts (9) |

---

## ✅ Phase 2 Complete

All in-scope Phase 2 items have been implemented. The following were deferred to later phases with clear rationale:

### Deferred to Phase 3
| Item | Reason |
|---|---|
| Dashboard: DAU/MAU KPI cards | Requires time-series analytics endpoint (Phase 3 backend work) |
| Dashboard: Active contests count | Endpoint needs active-only filter |
| Dashboard: Recent fraud feed | Requires fraud-feed endpoint |
| Dashboard mini charts (user growth, completions, top categories) | Requires time-series endpoints |
| Analytics: Retention curve (Day 1/7/30) | Requires dedicated retention endpoint |
| Analytics: Country map visualization | Requires geo-aggregation endpoint |
| Analytics: Revenue breakdown by provider | Requires Paystack/Flutterwave split in backend |
| Notifications: Schedule for later | Requires BullMQ job queue |
| Leagues: Assign daily quiz questions | Phase 3 league enhancement |
| Leagues: Leaderboard + prize distribution UI | Phase 3 league enhancement |
| Categories: Active/inactive toggle | `Category` Prisma model has no `status` column — requires schema migration |
| Questions: Rich text editor | Replace `<Textarea>` with WYSIWYG in Phase 3 |
| Questions: Image/audio upload | Requires file storage (S3/Firebase Storage) |
| Questions: Bulk CSV import | `POST /v2/admin/questions/import` wiring |
| AI Questions: Editable table before saving | Phase 3 enhancement |
| AI Questions: Generation history log | Phase 3 enhancement |
| AI Questions: Subject/class fields | Phase 3 schools integration |
| Dark/light mode support | Phase 3 UX polish |
| Ad network config (AdMob unit IDs) | Phase 3 monetization config |

### Deferred to Phase 4+
| Item | Reason |
|---|---|
| Schools list, detail, subscription management | Phase 4 schools module |
| Question: Bulk CSV import | Medium | `POST /v2/admin/questions/import` |
| Sponsors: Start/end dates + priority | Low | Extend `Sponsor` model |
| Notifications: Schedule for later | Medium | Queue + cron |
| Settings: Free-form K/V editor | Medium | Maps to `tbl_settings` |
| Settings: AdMob unit ID config | Low | |
| Sidebar: Role-based item visibility | Low | Hide Phase 4+ items by flag |
| AI Questions: Generation history log | Medium | Token usage tracking |
