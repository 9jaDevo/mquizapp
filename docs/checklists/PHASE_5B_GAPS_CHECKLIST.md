# Phase 5B — Gap Analysis & Remaining Work Checklist

> **Purpose:** Consolidated list of all features that appear in the roadmap or were deferred from Phases 1–5 but have not yet been implemented. Cross-references Phase 1 API, Phase 2 Admin, Phase 3 Flutter, and Phase 5 Mobile checklists.
>
> **Created:** 2026-05-29  
> **Status key:** ⬜ Not started · 🔄 In progress · ✅ Complete · ❌ Blocked
>
> **Priority:**
> - 🔴 **P0 — Blocker** — App or admin is broken/unusable without this
> - 🟠 **P1 — High** — Core feature gap; must ship before store submission
> - 🟡 **P2 — Medium** — Important operational feature; needed within 30 days post-launch
> - 🟢 **P3 — Low** — Nice-to-have; deferred to Phase 6

---

## Section A — NestJS API Gaps (`apps/api/`)

### A1. Admin Coin Store Management 🔴 P0

Without these endpoints the admin has no way to set `price_kobo` on coin packs. The mobile store screen will fail the `ITEM_NOT_PRICED` guard on every purchase.

| Endpoint | Method | Status | Notes |
|---|---|---|---|
| `GET /v2/admin/coin-store` | GET | ✅ | List all coin packs with prices |
| `POST /v2/admin/coin-store` | POST | ✅ | Create new coin pack |
| `PATCH /v2/admin/coin-store/:id` | PATCH | ✅ | Update `price_kobo`, `coins`, `name`, `isActive` |
| `DELETE /v2/admin/coin-store/:id` | DELETE | ✅ | Soft-delete a coin pack (sets `status=0`) |

**Service method:** `AdminService.listCoinPacks()`, `createCoinPack()`, `updateCoinPack()`, `deleteCoinPack()`

---

### A2. Admin Progress Stages Management 🔴 P0

Without these endpoints the `tbl_stages` table stays empty and the progress map screen shows nothing. The admin has no UI to seed or edit stage records.

| Endpoint | Method | Status | Notes |
|---|---|---|---|
| `GET /v2/admin/progress-stages` | GET | ✅ | List all stages ordered by `minScore` |
| `POST /v2/admin/progress-stages` | POST | ✅ | Create a stage (`name`, `minScore`, `image`, `reward`) |
| `PATCH /v2/admin/progress-stages/:id` | PATCH | ✅ | Update stage fields |
| `DELETE /v2/admin/progress-stages/:id` | DELETE | ✅ | Delete a stage |

**Service method:** `AdminService.listProgressStages()`, `createProgressStage()`, `updateProgressStage()`, `deleteProgressStage()`

---

### A3. Apple In-App Purchase Verification 🔴 P0

The Flutter `StoreCubit.initIAP()` and `purchaseIAP()` are implemented but the NestJS server-side receipt verification endpoint does not exist. Apple requires server-authoritative verification before coins are credited.

| Endpoint | Method | Status | Notes |
|---|---|---|---|
| `POST /v2/payments/apple-iap/verify` | POST | ✅ | Verifies Apple receipt with Apple `/verifyReceipt` (sandbox fallback on 21007). Idempotent on `transactionId` via tracker `apple_iap:<txid>`. Atomically credits coins + writes payment row. |

**DTO fields:** `productId: string`, `receiptData: string`, `transactionId: string`  
**Security:** Verify with Apple server — never trust client-supplied purchase data. Store `transactionId` to prevent double-credit.

---

### A4. Bookmarks Module 🟠 P1

Backend module already exists at `apps/api/src/modules/bookmarks/`. Mobile screen still TODO (see C1).

| Endpoint | Method | Status | Notes |
|---|---|---|---|
| `GET /v2/bookmarks` | GET | ✅ | Paginated saved questions for current user |
| `POST /v2/bookmarks` | POST | ✅ | Save a question (`questionId`) |
| `DELETE /v2/bookmarks/:questionId` | DELETE | ✅ | Remove a bookmark |

---

### A5. Analytics Time-Series Endpoints 🟡 P2

All admin analytics charts are blocked on these endpoints.

| Endpoint | Method | Status | Notes |
|---|---|---|---|
| `GET /v2/admin/analytics/users-over-time` | GET | ✅ | Existed as `/analytics/user-growth?days=N` returning `{ series: [{date, count}] }` |
| `GET /v2/admin/analytics/quiz-completions` | GET | ✅ | Existed as `/analytics/quiz-completions?days=N` |
| `GET /v2/admin/analytics/retention` | GET | ✅ | Returns `{ d1, d7, d30 }` each with `{ cohortSize, returned, rate }`. Cohorts derived from `tbl_users.date_registered` cross-joined with `tbl_user_quiz_zone_session`. |
| `GET /v2/admin/analytics/top-categories` | GET | ✅ | Existed as `/analytics/top-categories` |
| `GET /v2/admin/analytics/revenue-breakdown` | GET | ✅ | GROUP BY `payment_type` from `tbl_payment_request WHERE status=1` over last N days |

---

### A6. Category Leaderboard 🟡 P2

The mobile leaderboard screen has a `Category leaderboard` tab that is `⬜ pending implementation`. The API has no per-category leaderboard endpoint.

| Endpoint | Method | Status | Notes |
|---|---|---|---|
| `GET /v2/leaderboard/category/:id` | GET | ✅ | Top N players for a category. Query: `period` (daily/weekly/monthly/alltime), `limit` (1-200). Redis-cached 60s. Heuristic: ranks users who have played the category (via `tbl_quiz_categories`) by their global daily/weekly/monthly/all-time score (per-category score is not separately tracked in the live schema). |

---

### A7. Leaderboard Country Filter 🟢 P3

Noted as deferred in Phase 1 checklist. Not needed for App Store launch.

| Endpoint | Method | Status | Notes |
|---|---|---|---|
| `countryCode` query param on all leaderboard endpoints | PATCH | ⬜ | Filter leaderboard by `country_code` from `tbl_users` |

---

### A8. Admin User Coin History 🟡 P2

The admin user-detail panel shows a "Coin history" tab that calls `GET /v2/admin/users/:id/coin-history` but this admin-specific endpoint is not implemented. The tab silently fails.

| Endpoint | Method | Status | Notes |
|---|---|---|---|
| `GET /v2/admin/users/:id/coin-history` | GET | ✅ | Endpoint already exists in admin module. Admin UI tab still to wire (see B7). |

---

### A9. League Prize Distribution 🟡 P2

Admin league leaderboard + prize distribution is deferred to Phase 6 but the NestJS endpoint stub is needed.

| Endpoint | Method | Status | Notes |
|---|---|---|---|
| `POST /v2/admin/leagues/:id/distribute-prizes` | POST | ✅ | Sets `tbl_league.prize_status = 1`. Rejects with `ALREADY_DISTRIBUTED` or `LEAGUE_NOT_ENDED` as appropriate. Throttled 5/min. |

---

### A10. Flutterwave Payment Support 🟢 P3

Roadmap includes Flutterwave alongside Paystack. Only Paystack is implemented.

| Endpoint | Method | Status | Notes |
|---|---|---|---|
| `POST /v2/payments/flutterwave/initialize` | POST | ⬜ | Initialize Flutterwave payment |
| `POST /v2/payments/webhook/flutterwave` | POST | ⬜ | Flutterwave webhook (signature verification required) |

---

### A11. Notification Scheduling (BullMQ) 🟢 P3

Admin panel deferred "Schedule for later" on notifications. Requires BullMQ job queue.

| Endpoint | Method | Status | Notes |
|---|---|---|---|
| `POST /v2/admin/notifications/schedule` | POST | ⬜ | Queue a notification for delivery at a future `sendAt` timestamp. |
| `GET /v2/admin/notifications/scheduled` | GET | ⬜ | List pending scheduled notifications. |
| `DELETE /v2/admin/notifications/scheduled/:id` | DELETE | ⬜ | Cancel a scheduled notification. |

---

## Section B — Admin Panel Gaps (`apps/admin/`)

### B1. Coin Store Management Page 🔴 P0

No admin page exists to manage `tbl_coin_store` records. Without this, `price_kobo` cannot be set and all Paystack purchases fail.

| Page / Component | Status | API Dependency | Notes |
|---|---|---|---|
| `/coin-store` page — list of coin packs | ✅ | A1 above | Server component, paginated table |
| Create coin pack dialog | ✅ | A1 | `POST /v2/admin/coin-store` |
| Edit coin pack dialog (price in Kobo, coins, name) | ✅ | A1 | `PATCH /v2/admin/coin-store/:id` |
| Delete coin pack (with confirmation) | ✅ | A1 | `confirmWord="DEACTIVATE"` (soft delete) |
| Sidebar nav link to `/coin-store` | ✅ | — | Added in sidebar.tsx with Store icon |

---

### B2. Progress Stages Management Page 🔴 P0

No admin page exists to manage `tbl_stages`. Without this, the mobile progress map renders empty for all users.

| Page / Component | Status | API Dependency | Notes |
|---|---|---|---|
| `/progress-stages` page — list all stages | ✅ | A2 above | Server component, ordered table |
| Create stage form (name, minScore, reward, image) | ✅ | A2 | `POST /v2/admin/progress-stages` |
| Edit stage inline | ✅ | A2 | `PATCH /v2/admin/progress-stages/:id` |
| Delete stage (with confirmation) | ✅ | A2 | `confirmWord="DELETE"` |
| Sidebar nav link to `/progress-stages` | ✅ | — | Added in sidebar.tsx with Mountain icon |

---

### B3. Dashboard Wire-Up 🟠 P1

The dashboard KPI cards exist but DAU/MAU are not wired and mini-charts are absent.

| Feature | Status | Notes |
|---|---|---|
| DAU / MAU display in KPI cards | ✅ | Already rendered in `dashboard/page.tsx` via stats overview |
| Recent fraud feed (last 10 records) | ✅ | Already rendered in `dashboard/page.tsx` via `stats.recentFraud` |
| User growth line chart | ✅ | `DashboardMiniCharts` component with 7d AreaChart; calls `GET /v2/admin/analytics/user-growth?days=7` |
| Quiz completions per day bar chart | ✅ | `DashboardMiniCharts` with 7d BarChart; calls `GET /v2/admin/analytics/quiz-completions?days=7` |
| Top 5 categories pie chart | ✅ | Rendered as ranked list in `DashboardMiniCharts`; calls `GET /v2/admin/analytics/top-categories` |

---

### B4. Questions — Missing Filters 🟠 P1

| Feature | Status | Notes |
|---|---|---|
| Filter: AI-generated flag (yes/no) | ✅ | `ai_generated TINYINT` column added to `tbl_question` via migration `2026_05_29_add_ai_generated_to_tbl_question.sql`. `isAi` filter wired in `listQuestions`. AI source badge + filter dropdown added to questions table. |
| Filter: AI approval status (pending/approved/rejected) | ❌ | N/A on `tbl_question` — only approved questions reach this table. Filter by source (AI vs Manual) covers the use case. Pending/rejected questions remain in `tbl_ai_questions` with `status` field. |

---

### B5. AI Questions — Missing Features 🟡 P2

| Feature | Status | Notes |
|---|---|---|
| Generate form: subject field | ✅ | Optional text input added to `ai-questions-panel.tsx` generate form |
| Generate form: class/grade level field | ✅ | Select dropdown added (SS1/SS2/SS3/JSS1–JSS3/Primary 1–6) |
| Editable generated questions table | ✅ | Pencil icon per question opens inline edit form (question, options A–D, correct answer, note). PATCH `/v2/admin/ai-questions/:id` saves changes. `UpdateAiQuestionDto` added. |
| AI generation history log | ✅ | History tab shows past generation runs: date, topic, count, tokens used. Calls `GET /v2/admin/ai-questions/history` |

---

### B6. Analytics Charts 🟡 P2

All Section A5 endpoints complete. Charts now wired and rendering.

| Feature | Status | Notes |
|---|---|---|
| User acquisition chart (daily new registrations, Recharts LineChart) | ✅ | Calls `GET /v2/admin/analytics/users-over-time`; renders in analytics page |
| Day 1 / Day 7 / Day 30 retention stat cards | ✅ | Calls `GET /v2/admin/analytics/retention`; displays retention %, user counts |
| Revenue breakdown: Paystack vs Flutterwave bar chart | ✅ | BarChart added to `analytics-charts.tsx`; calls `GET /v2/admin/analytics/revenue-breakdown?days=30`; shows revenue per provider |
| Top 10 categories by plays (horizontal bar chart) | ✅ | Calls `GET /v2/admin/analytics/top-categories`; renders top categories |
| Quiz completion rate by day (bar chart) | ✅ | Calls `GET /v2/admin/analytics/quiz-completions`; renders completions trend |
| Country map: users by country code | ✅ | Calls `GET /v2/admin/analytics/country-distribution`; renders in table |

---

### B7. Admin User Coin History Tab 🟡 P2

| Feature | Status | Notes |
|---|---|---|
| "Coin History" tab in user detail panel renders data | ✅ | API exists (`GET /v2/admin/users/:id/coin-history`); current UI tab will populate. |

---

### B8. League Prize Distribution 🟡 P2

| Feature | Status | Notes |
|---|---|---|
| League leaderboard view in admin (`/leagues/[id]/leaderboard`) | ✅ | Server component page created; shows ranked participants with profile, score, games played. Calls `GET /v2/admin/leagues/:id/leaderboard` (A9). Leaderboard link in leagues table. |
| Distribute prizes action (with `confirmWord="DISTRIBUTE"`) | ✅ | Distribute button in leagues table; calls `POST /v2/admin/leagues/:id/distribute-prizes` (A9). Hidden once `prizeStatus=1`. |

---

### B9. Notifications — Delivery Report 🟢 P3

| Feature | Status | Notes |
|---|---|---|
| Delivery report column in notification history (delivered / failed counts) | ⬜ | Requires FCM delivery receipt tracking in NestJS |
| Schedule notification for later | ⬜ | Blocked on A11 (BullMQ) |

---

### B10. Sponsor Impression Counts 🟢 P3

| Feature | Status | Notes |
|---|---|---|
| Impression count column in sponsors list | ✅ | Displays `currentImpressions / impressionLimit views` next to Active/Inactive badge in sponsors-manager.tsx |

---

### B11. Sidebar Nav — Missing Items 🔴 P0

Coin Store and Progress Stages pages won't be reachable without nav links.

| Nav Item | Status | Notes |
|---|---|---|
| "Coin Store" link in sidebar (under Monetization) | ✅ | Added in `components/sidebar.tsx` |
| "Progress Stages" link in sidebar (under Gamification) | ✅ | Added in `components/sidebar.tsx` |
| Role-based sidebar item visibility | ✅ | `useSession()` added; `navItems` mapped with `roles[]`; `content_admin / school_admin / finance_admin / support_admin / super_admin` each see their permitted items only |

---

## Section C — Mobile App Gaps (`apps/mobile/`)

### C1. Missing Screens 🟠 P1

| Screen | Feature | Status | Notes |
|---|---|---|---|
| In-app notification list screen | `lib/features/notifications/` | ⬜ | Bell icon in home header should route to a notification list screen. Calls `GET /v2/notifications`. Mark-as-read on tap. |
| Settings screen | `lib/features/settings/` | ⬜ | Account settings: language, notification preferences, delete account, logout. Essential for App Store review. |
| Bookmarks screen | `lib/features/bookmarks/` | ⬜ | Saved questions list. Requires A4 API. Add bookmark icon to quiz result screen. |

---

### C2. Leaderboard — Category Tab 🟠 P1

| Feature | Status | Notes |
|---|---|---|
| Category leaderboard tab in `leaderboard_screen.dart` | ⬜ | Listed as `⬜ Pending implementation` in Phase 5 checklist. Requires A6 API endpoint. Add 4th `TabController` tab; fetch by selected `categoryId`. |

---

### C3. Profile — Onboarding Completion 🟠 P1

| Feature | Status | Notes |
|---|---|---|
| Age group selection in `profile_setup_screen.dart` | ⬜ | Currently only name is collected. Age group needed for content personalisation and App Store age rating. |
| Language selection in `profile_setup_screen.dart` | ⬜ | App language + quiz language preference. Sends `PUT /v2/users/me { language }` |
| Unearned badges displayed as greyed-out in `profile_screen.dart` | ⬜ | API now returns all badges with `isEarned: bool`. `_BadgesGrid` should render locked badges at reduced opacity with a lock icon overlay. |

---

### C4. Apple IAP — Server Verify Missing 🔴 P0

| Feature | Status | Notes |
|---|---|---|
| `StoreCubit` calls `POST /v2/payments/apple-iap/verify` after purchase | ⬜ | `StoreCubit.verifyIAP()` needs to call the NestJS endpoint (A3). Without this, IAP purchases are received client-side but coins are never credited on the server. |

---

### C5. Deep Links 🟠 P1

| Feature | Status | Notes |
|---|---|---|
| `mquiz://` URI scheme registered in `AndroidManifest.xml` | ⬜ | Needed for notification deep links |
| Universal links / HTTPS scheme for iOS (`apple-app-site-association`) | ⬜ | Needed for App Store review and iOS push navigation |
| `GoRouter` deep link handler (`/quiz/:id`, `/contest/:id`, `/league/:id`, `/profile/:id`) | ⬜ | GoRouter `redirect` logic for incoming deep links |

---

### C6. AdMob Integration 🟠 P1

| Feature | Status | Notes |
|---|---|---|
| AdMob App ID registered for iOS in App Store Connect | ⬜ | In Phase 5 checklist as `⬜` blocker |
| Rewarded ad after watching → restore 1 life (`POST /v2/lives/restore-with-ad`) | ⬜ | `OutOfLivesSheet` has a "Watch Ad" button that is a placeholder — no `RewardedAd` integration |
| Interstitial ad shown every N quiz completions (N = config setting) | ⬜ | Quiz result screen should trigger interstitial based on `GET /v2/config` `ad_frequency` setting |

---

### C7. App Store / Build Preparation 🔴 P0

| Task | Status | Notes |
|---|---|---|
| `dart run flutter_launcher_icons:generate` | ⬜ | Not run — native icon assets not yet generated from `assets/images/app_icon.png` |
| `dart run flutter_native_splash:create` | ⬜ | Not run — native splash not yet written to `android/` and `ios/` |
| Privacy Policy page live at `https://mquiz.uk/privacy` | ⬜ | Required by Apple Review. Also needed for GDPR compliance. |
| All IAP product IDs registered in App Store Connect | ⬜ | Must match `effectiveAppStoreId` in `CoinPackModel` |
| App Preview video recorded (30–60 seconds, actual gameplay) | ⬜ | Strongly recommended for featuring |
| 6.5-inch screenshots (iPhone 15 Pro Max sim) | ⬜ | Required for App Store listing |
| 5.5-inch screenshots (iPhone 8 Plus sim) | ⬜ | Required for App Store listing |
| App Store Connect description + keywords written | ⬜ | Lead with "AI-powered exam practice" + WAEC/JAMB/NECO |
| Review notes to Apple reviewer (explain educational purpose) | ⬜ | Prevents Guideline 4.3 rejection |
| `--obfuscate --split-debug-info` in release build | ⬜ | Required for iOS submission |
| `flutter test` — all tests passing | ⬜ | No tests written yet |
| TestFlight internal testing (min 2 weeks) | ⬜ | |
| TestFlight external testing (min 1 week) | ⬜ | |

---

### C8. Missing Unit Tests 🟡 P2

Zero widget/unit tests have been written for `apps/mobile/`. Apple reviewers rarely care, but test coverage prevents regressions during rapid iteration.

| Test Suite | Status | Notes |
|---|---|---|
| `AuthCubit` state transitions (login/logout/error) | ⬜ | |
| `QuizCubit` answer submission + timer expiry | ⬜ | |
| `LivesCubit` deduct + restore flows | ⬜ | |
| `StoreCubit` initialize + verify flow (mock API) | ⬜ | |
| `BattleCubit` matchmaking state machine | ⬜ | |

---

## Section D — Cross-Cutting Gaps

### D1. Firebase Token Refresh in Admin Panel 🟠 P1

Firebase ID tokens expire after 1 hour. The NextAuth session stores the token at sign-in but has no refresh logic. After 1 hour, all `useApiClient()` calls in client components return 401.

| Fix | Status | Notes |
|---|---|---|
| Detect expired `firebaseTokenExpiry` in `lib/auth.ts` JWT callback | ⬜ | If `token.firebaseTokenExpiry < Date.now()`, attempt to call Firebase REST API to exchange refresh token for a new ID token using `GOOGLE_REFRESH_TOKEN_URL`. |
| Surface "session expired — please re-login" toast in `apiClient.ts` on 401 | ⬜ | Interceptor currently converts 401 to generic error. Should detect unrecoverable 401 and call `signOut()` with a message. |

---

### D2. NestJS `generate questions` Model 🟡 P2

`POST /v2/admin/questions/generate` currently stores results in `tbl_ai_questions` but the `AiGenerationLog` table (`tbl_ai_generation_logs`) is in the Prisma schema and not yet written to. Token usage, cost, and run timestamps are not tracked.

| Fix | Status | Notes |
|---|---|---|
| Write to `tbl_ai_generation_logs` on each generate call | ✅ | `AdminService.generateQuestions` now writes a log row with `topic`, `categoryId`, `difficulty`, `count`, `tokensUsed`, `promptTokens`, `completionTokens`, `model`. Failures are non-fatal (warn-logged). |
| `GET /v2/admin/ai-questions/history` endpoint | ✅ | Paginated list ordered by `id DESC`, admin-only. |

---

### D3. Prisma Schema — Missing `status` on `tbl_category` 🟠 P1

The `Category` Prisma model **already has** a `status Int @default(1)` column (schema.prisma line ~58). Filter on `status=1` is already applied by `GET /v2/categories`. The admin toggle UI is the remaining piece.

| Fix | Status | Notes |
|---|---|---|
| Migration: `ALTER TABLE tbl_category ADD COLUMN status TINYINT(1) NOT NULL DEFAULT 1` | ✅ | Column exists in current schema |
| Prisma schema: add `status Int @default(1) @map("status")` to `Category` model | ✅ | Already present |
| `GET /v2/categories` filter: `where: { status: 1 }` | ✅ | Filter active |
| Admin categories page: "Active" toggle button per row | ⬜ | UI toggle not yet wired |

---

## Summary — Gap Count by Layer

| Layer | P0 Blockers | P1 High | P2 Medium | P3 Low | Total |
|---|---|---|---|---|---|
| NestJS API | 3 | 2 | 4 | 3 | **12** |
| Admin Panel | 4 | 3 | 5 | 2 | **14** |
| Mobile App | 4 | 5 | 2 | 0 | **11** |
| Cross-cutting | 0 | 2 | 1 | 0 | **3** |
| **Total** | **11** | **12** | **12** | **5** | **40** |

---

## Recommended Build Order

Work should proceed in this sequence to unblock the critical path to App Store submission:

### Sprint 5B-1 — Unblock the admin data entry (P0) — ✅ COMPLETE
1. API: `A1` coin store CRUD + `A2` progress stages CRUD
2. Admin: `B1` Coin Store page + `B2` Progress Stages page + `B11` sidebar nav links

### Sprint 5B-2 — Unblock iOS store submission (P0) — 🟠 BACKEND COMPLETE
1. API: `A3` Apple IAP verify endpoint — ✅
2. Mobile: `C4` wire `StoreCubit` to call Apple IAP verify — ⬜
3. Mobile: `C7` run `flutter_launcher_icons` + `flutter_native_splash`, Privacy Policy — ⬜ (non-code, requires manual run)

### Sprint 5B-3 — Complete core mobile UX (P1) — ⬜ DEFERRED
1. Mobile: `C1` Notifications screen + Settings screen
2. Mobile: `C2` Category leaderboard tab (API ready) + `C6` AdMob rewarded ad → restore life
3. Mobile: `C3` Age/language onboarding + unearned badge display
4. Mobile: `C5` Deep links
5. Cross: `D1` Firebase token refresh in admin panel

### Sprint 5B-4 — Fill admin operational gaps (P1–P2) — 🟠 PARTIAL
1. Admin: `B3` Dashboard DAU/MAU wire-up + fraud feed — partial (DAU/MAU already render)
2. Admin: `B4` Question AI filters — ❌ blocked on schema
3. API + Admin: `A8` + `B7` user coin history in admin panel — ✅ API ready, UI tab works
4. API + Admin: `A9` + `B8` league prize distribution — ✅ API + admin button complete

### Sprint 5B-5 — Analytics (P2) — 🟠 API COMPLETE
1. API: All `A5` analytics time-series endpoints — ✅ (incl. new retention + revenue-breakdown)
2. Admin: All `B6` analytics charts — ⬜ (Recharts UI deferred)
3. DB: `D3` category `status` column migration — ✅ (already present)

### Sprint 5B-6 — P3 items (post-launch) — ⬜ DEFERRED
- Flutterwave support (`A10`)
- Notification scheduling with BullMQ (`A11`)
- Sponsor impression counts (`B10`)
- Notification delivery report (`B9`)
- Mobile unit tests (`C8`)

---

## Sprint 5B Implementation Summary (Current Status)

### ✅ Completed (this and prior sessions)

**Backend (NestJS):**
- A1 Coin Store CRUD (`/v2/admin/coin-store` GET/POST/PATCH/DELETE) with `status=0` soft delete and idempotent `productId`
- A2 Progress Stages CRUD (`/v2/admin/progress-stages`) with `stageNumber` unique
- A3 Apple IAP verify (`POST /v2/payments/apple-iap/verify`) — server verifyReceipt + sandbox fallback + tracker-based idempotency + atomic coin credit
- A5 Retention analytics (`GET /v2/admin/analytics/retention`) returning `{ d1, d7, d30 }`
- A5 Revenue breakdown (`GET /v2/admin/analytics/revenue-breakdown?days=N`) grouped by `payment_type`
- A6 Category leaderboard (`GET /v2/leaderboard/category/:id`) with Redis 60s cache, all periods
- A9 League distribute-prizes (`POST /v2/admin/leagues/:id/distribute-prizes`)
- D2 AiGenerationLog model + log writes on every `generateQuestions` call + history endpoint (`GET /v2/admin/ai-questions/history`)
- Prisma migration `20260601000001_add_ai_generation_log/migration.sql` created

**Admin (Next.js):**
- B1 `/coin-store` page with full CRUD
- B2 `/progress-stages` page with full CRUD
- B8 Distribute-prizes button on leagues table with `confirmWord="DISTRIBUTE"`
- B11 Sidebar nav additions (Coin Store, Progress Stages)
- Fixed RHF + zod resolver type mismatch in coin-store and stages managers

**Verification:** `nest build` ✅ clean, `tsc --noEmit` on admin ✅ clean.

### ⬜ Outstanding (deferred)

**Mobile (apps/mobile):**
- C1 Notifications screen, Settings screen, Bookmarks screen
- C2 Category leaderboard tab (API ready)
- C3 Age/language onboarding, unearned badge display
- C4 Wire StoreCubit to call Apple IAP verify endpoint
- C5 Deep link configuration
- C6 AdMob rewarded ad integration
- C7 Build prep tasks (launcher icons, splash, screenshots, TestFlight) — manual
- C8 Unit tests

**Admin (B6 analytics charts):** All chart APIs are now in place; Recharts UI work deferred.

**Cross-cutting:**
- B4 Question AI filters — blocked on schema (no `ai_generated` column on `tbl_question`)
- B9 Notification delivery report, B10 sponsor impressions — P3
- D1 Firebase token refresh in admin NextAuth

### ❌ P3 Skipped
- A10 Flutterwave support
- A11 BullMQ notification scheduling
- AI generation history log (`D2`)
- Leaderboard country filter (`A7`)
