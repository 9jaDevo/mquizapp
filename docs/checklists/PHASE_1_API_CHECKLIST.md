# Phase 1 — NestJS API Backend Checklist

> **Target:** Weeks 1–6 · Location: `apps/api/src/`
> **Status key:** ⬜ Not started · 🔄 In progress · ✅ Complete · ❌ Blocked
>
> **Columns:** `Impl` = code merged · `Unit` = unit tests passing · `E2E` = integration test passing · `PM` = Postman request added/updated

---

## 0. Bootstrap & Common Infrastructure

| Task | Impl | Unit | E2E | PM | Notes |
|---|---|---|---|---|---|
| NestJS project init (`apps/api/`) | ✅ | — | — | — | NestJS 11, TS 5.7 |
| Prisma init + MySQL datasource | ✅ | — | — | — | Prisma 6, MariaDB on XAMPP |
| `prisma/schema.prisma` — all models mapped | ✅ | — | — | — | Singular `tbl_*` names; new tables pending migrate |
| `FirebaseAuthGuard` (`common/guards/`) | ✅ | ✅ | — | — | 5 tests pass |
| `RolesGuard` + `@Roles()` decorator | ✅ | ✅ | — | — | 5 tests pass |
| `@CurrentUser()` decorator | ✅ | — | — | — | Supports key extraction |
| `TransformInterceptor` — response envelope | ✅ | ✅ | — | — | 4 tests pass; pass-through honored |
| `HttpExceptionFilter` — error envelope | ✅ | ✅ | — | — | 4 tests pass; STATUS_TO_CODE map |
| Global `ValidationPipe` (whitelist, forbid) | ✅ | — | — | — | In main.ts |
| Swagger (`@nestjs/swagger`) configured | ✅ | — | — | — | `/docs` non-prod only |
| Redis connection (`ioredis`) | ✅ | — | — | — | @Global RedisModule |
| Rate limiting (`@nestjs/throttler`) global | ✅ | — | — | — | 60/min default via APP_GUARD |
| `PrismaService` singleton | ✅ | — | — | — | @Global PrismaModule |
| Environment validation (`@nestjs/config`) | ✅ | — | — | — | Joi schema, abortEarly:false |
| CORS whitelist config | ✅ | — | — | — | Dev=all / Prod=ADMIN_URL |

---

## 1. Auth Module (`src/modules/auth/`)

| Endpoint | Description | Impl | Unit | E2E | PM | Notes |
|---|---|---|---|---|---|---|
| `POST /v2/auth/login` | Verify Firebase token, upsert user record, return profile | ⬜ | ⬜ | ⬜ | ⬜ | |
| `POST /v2/auth/guest` | Create anonymous guest session | ⬜ | ⬜ | ⬜ | ⬜ | |
| `POST /v2/auth/refresh-token` | Validate token is still live | ⬜ | ⬜ | ⬜ | ⬜ | |

**Auth module checklist:**
- [ ] Returns user profile + `onboarding_complete` flag on login
- [ ] Creates `UserLives`, `UserProgress`, `DailyStreak` rows on first login
- [ ] Rate limited: max 10 requests/minute per IP
- [ ] Guest user gets `type = 'guest'` and no coin awards

---

## 2. Users Module (`src/modules/users/`)

| Endpoint | Description | Impl | Unit | E2E | PM | Notes |
|---|---|---|---|---|---|---|
| `GET /v2/users/me` | Get own full profile | ⬜ | ⬜ | ⬜ | ⬜ | |
| `PUT /v2/users/me` | Update name, avatar, language, age group | ⬜ | ⬜ | ⬜ | ⬜ | |
| `GET /v2/users/:id` | Public profile (name, score, rank, badges) | ⬜ | ⬜ | ⬜ | ⬜ | |
| `GET /v2/users/me/stats` | Quiz count, accuracy %, best category, streaks | ⬜ | ⬜ | ⬜ | ⬜ | |
| `GET /v2/users/me/badges` | My earned badges with details | ⬜ | ⬜ | ⬜ | ⬜ | |
| `GET /v2/users/me/coin-history` | Paginated coin transaction history | ⬜ | ⬜ | ⬜ | ⬜ | |
| `PUT /v2/users/me/fcm-token` | Update FCM push token | ⬜ | ⬜ | ⬜ | ⬜ | |

**Users module checklist:**
- [ ] `PUT /v2/users/me` does NOT allow updating `coins`, `allTimeScore`, `status` via body
- [ ] `GET /v2/users/:id` only exposes public fields — no email, firebase_id, FCM token
- [ ] Coin history is scoped to the authenticated user only

---

## 3. Categories Module (`src/modules/categories/`)

| Endpoint | Description | Impl | Unit | E2E | PM | Notes |
|---|---|---|---|---|---|---|
| `GET /v2/categories` | All active categories (with language filter) | ⬜ | ⬜ | ⬜ | ⬜ | |
| `GET /v2/categories/:id/subcategories` | Subcategories of a category | ⬜ | ⬜ | ⬜ | ⬜ | |

---

## 4. Questions Module (`src/modules/questions/`)

| Endpoint | Description | Impl | Unit | E2E | PM | Notes |
|---|---|---|---|---|---|---|
| `GET /v2/questions` | Paginated questions (admin use) | ⬜ | ⬜ | ⬜ | ⬜ | Requires admin role |

---

## 5. Quiz Module (`src/modules/quiz/`)

| Endpoint | Description | Impl | Unit | E2E | PM | Notes |
|---|---|---|---|---|---|---|
| `GET /v2/quiz/questions` | Questions for a quiz session (type, category, level, limit) | ⬜ | ⬜ | ⬜ | ⬜ | |
| `POST /v2/quiz/submit` | Submit answers: update score, coins, XP, streak | ⬜ | ⬜ | ⬜ | ⬜ | Critical path |
| `GET /v2/quiz/daily-challenge` | Today's daily challenge questions | ⬜ | ⬜ | ⬜ | ⬜ | |
| `POST /v2/quiz/daily-challenge/submit` | Submit daily challenge answers | ⬜ | ⬜ | ⬜ | ⬜ | |

**Quiz module checklist:**
- [ ] `POST /v2/quiz/submit` validates all submitted answers server-side — never trust client score
- [ ] Coin award calculated server-side from correct answer count
- [ ] XP award updates `UserProgress` in the same transaction
- [ ] Duplicate submission for same session is idempotent (no double coins)
- [ ] Fraud check triggered: too-fast completion time logged to `tbl_fraud_detection`

---

## 6. Leaderboard Module (`src/modules/leaderboard/`)

| Endpoint | Description | Impl | Unit | E2E | PM | Notes |
|---|---|---|---|---|---|---|
| `GET /v2/quiz/leaderboard` | Global leaderboard (daily/weekly/monthly/alltime, country filter) | ⬜ | ⬜ | ⬜ | ⬜ | Cached in Redis |

**Leaderboard checklist:**
- [ ] Redis `ZREVRANGE` for O(log N) leaderboard queries
- [ ] Cache TTL: 5 minutes for global, 30 seconds for realtime battles
- [ ] Country filter uses `country_code` on `tbl_users`

---

## 7. Coins Module (`src/modules/coins/`)

| Endpoint | Description | Impl | Unit | E2E | PM | Notes |
|---|---|---|---|---|---|---|
| `GET /v2/coins/balance` | Current coin balance + recent history summary | ⬜ | ⬜ | ⬜ | ⬜ | |
| `POST /v2/coins/award` | Internal: award coins (called by quiz, streak, etc.) | ⬜ | ⬜ | — | ⬜ | Internal service only |

---

## 8. Lives Module (`src/modules/lives/`)

| Endpoint | Description | Impl | Unit | E2E | PM | Notes |
|---|---|---|---|---|---|---|
| `GET /v2/lives` | Current life count + next regen timestamp | ⬜ | ⬜ | ⬜ | ⬜ | |
| `POST /v2/lives/use` | Deduct one life before starting a quiz | ⬜ | ⬜ | ⬜ | ⬜ | |
| `POST /v2/lives/restore/ad` | Restore 1 life after rewarded ad (server verifies ad token) | ⬜ | ⬜ | ⬜ | ⬜ | |
| `POST /v2/lives/restore/coins` | Restore 1 life using coins (verify balance first) | ⬜ | ⬜ | ⬜ | ⬜ | |

**Lives module checklist:**
- [ ] Cannot deduct life below 0
- [ ] Regen timer calculated server-side — never trust client timestamps
- [ ] Coin deduction for restore is atomic with life increment (same transaction)
- [ ] `POST /v2/lives/restore/ad` requires valid, unused ad completion token

---

## 9. Boosters Module (`src/modules/boosters/`)

| Endpoint | Description | Impl | Unit | E2E | PM | Notes |
|---|---|---|---|---|---|---|
| `GET /v2/boosters/types` | All available booster types with coin price | ⬜ | ⬜ | ⬜ | ⬜ | |
| `GET /v2/boosters/inventory` | My current booster counts | ⬜ | ⬜ | ⬜ | ⬜ | |
| `POST /v2/boosters/purchase` | Buy a booster with coins (deduct coins + increment inventory) | ⬜ | ⬜ | ⬜ | ⬜ | |
| `POST /v2/boosters/use` | Use a booster in-game (decrement inventory) | ⬜ | ⬜ | ⬜ | ⬜ | |

**Boosters checklist:**
- [ ] Purchase is atomic: coin deduct + inventory increment in single transaction
- [ ] Cannot use a booster with quantity 0
- [ ] Purchase validates user has sufficient coins before deducting

---

## 10. Progress Module (`src/modules/progress/`)

| Endpoint | Description | Impl | Unit | E2E | PM | Notes |
|---|---|---|---|---|---|---|
| `GET /v2/progress` | My current stage + total XP + stage history | ⬜ | ⬜ | ⬜ | ⬜ | |
| `GET /v2/progress/stages` | All stages for progress map UI | ⬜ | ⬜ | ⬜ | ⬜ | Cacheable |

---

## 11. League Module (`src/modules/league/`)

| Endpoint | Description | Impl | Unit | E2E | PM | Notes |
|---|---|---|---|---|---|---|
| `GET /v2/leagues/active` | Active leagues user can join | ⬜ | ⬜ | ⬜ | ⬜ | |
| `GET /v2/leagues/:id` | League detail + user's join status | ⬜ | ⬜ | ⬜ | ⬜ | |
| `POST /v2/leagues/:id/join` | Opt-in to league (deduct entry coins) | ⬜ | ⬜ | ⬜ | ⬜ | |
| `POST /v2/leagues/:id/submit` | Submit daily quiz score | ⬜ | ⬜ | ⬜ | ⬜ | |
| `GET /v2/leagues/:id/leaderboard` | League leaderboard | ⬜ | ⬜ | ⬜ | ⬜ | |

---

## 12. Contest Module (`src/modules/contest/`)

| Endpoint | Description | Impl | Unit | E2E | PM | Notes |
|---|---|---|---|---|---|---|
| `GET /v2/contests/active` | Active contests | ⬜ | ⬜ | ⬜ | ⬜ | |
| `GET /v2/contests/:id` | Contest detail + prizes | ⬜ | ⬜ | ⬜ | ⬜ | |
| `POST /v2/contests/:id/enter` | Enter a contest (deduct entry coins) | ⬜ | ⬜ | ⬜ | ⬜ | |

---

## 13. Referral Module (`src/modules/referral/`)

| Endpoint | Description | Impl | Unit | E2E | PM | Notes |
|---|---|---|---|---|---|---|
| `GET /v2/referral/code` | My referral code + referral stats | ⬜ | ⬜ | ⬜ | ⬜ | |
| `POST /v2/referral/apply` | Apply a referral code (one-time per user) | ⬜ | ⬜ | ⬜ | ⬜ | |

**Referral checklist:**
- [ ] One referral per user enforced (DB unique constraint on `referee_id`)
- [ ] IP + device fingerprint logged for fraud detection
- [ ] Self-referral rejected
- [ ] Reward granted only after referring user completes first quiz

---

## 14. Streak Module (`src/modules/streak/`)

| Endpoint | Description | Impl | Unit | E2E | PM | Notes |
|---|---|---|---|---|---|---|
| `GET /v2/streak` | My streak info (count, max, last check-in) | ⬜ | ⬜ | ⬜ | ⬜ | |
| `POST /v2/streak/check-in` | Daily check-in (called on app open) | ⬜ | ⬜ | ⬜ | ⬜ | |

---

## 15. Notifications Module (`src/modules/notifications/`)

| Endpoint | Description | Impl | Unit | E2E | PM | Notes |
|---|---|---|---|---|---|---|
| `GET /v2/notifications` | My notifications (paginated, unread count) | ⬜ | ⬜ | ⬜ | ⬜ | |
| `PUT /v2/notifications/:id/read` | Mark notification as read | ⬜ | ⬜ | ⬜ | ⬜ | |

---

## 16. Config Module (`src/modules/settings/`)

| Endpoint | Description | Impl | Unit | E2E | PM | Notes |
|---|---|---|---|---|---|---|
| `GET /v2/config/system` | App config (ad type, feature flags, coin rates) | ⬜ | ⬜ | ⬜ | ⬜ | Cached |
| `GET /v2/config/languages` | Supported app languages | ⬜ | ⬜ | ⬜ | ⬜ | Cached |
| `GET /v2/config/quiz-languages` | Supported quiz content languages | ⬜ | ⬜ | ⬜ | ⬜ | Cached |

---

## 17. Ads Module (`src/modules/ads/`)

| Endpoint | Description | Impl | Unit | E2E | PM | Notes |
|---|---|---|---|---|---|---|
| `GET /v2/ads/sponsor-banners` | Active sponsor banners for home screen | ⬜ | ⬜ | ⬜ | ⬜ | |
| `POST /v2/ads/banner-click` | Record a sponsor banner click | ⬜ | ⬜ | ⬜ | ⬜ | |

---

## 18. Payments Module (`src/modules/payments/`)

| Endpoint | Description | Impl | Unit | E2E | PM | Notes |
|---|---|---|---|---|---|---|
| `POST /v2/payments/initialize` | Initialize Paystack payment for coin pack or subscription | ⬜ | ⬜ | ⬜ | ⬜ | |
| `POST /v2/payments/verify/:reference` | Verify payment and fulfill order | ⬜ | ⬜ | ⬜ | ⬜ | |
| `POST /v2/payments/webhook/paystack` | Paystack webhook (HMAC-SHA512 verified) | ⬜ | ⬜ | ⬜ | ⬜ | |
| `GET /v2/payments/history` | My payment history | ⬜ | ⬜ | ⬜ | ⬜ | |

**Payments checklist:**
- [ ] Webhook verifies `x-paystack-signature` HMAC-SHA512 before processing
- [ ] Payment verification calls Paystack API server-side before awarding coins/subscription
- [ ] Duplicate webhook events are idempotent (check reference already processed)
- [ ] Payment amounts validated against server-defined price list (not client-supplied)

---

## 19. Admin API Endpoints (`src/modules/admin/`)

> These endpoints require `@UseGuards(FirebaseAuthGuard, RolesGuard)` + `@Roles('admin')`

| Endpoint | Description | Impl | Unit | E2E | PM | Notes |
|---|---|---|---|---|---|---|
| `GET /v2/admin/users` | Paginated users table with search/filter | ⬜ | ⬜ | ⬜ | ⬜ | |
| `PATCH /v2/admin/users/:id/suspend` | Suspend user | ⬜ | ⬜ | ⬜ | ⬜ | |
| `PATCH /v2/admin/users/:id/coins` | Adjust user coins | ⬜ | ⬜ | ⬜ | ⬜ | |
| `GET /v2/admin/questions` | Paginated questions with full filters | ⬜ | ⬜ | ⬜ | ⬜ | |
| `POST /v2/admin/questions` | Create question | ⬜ | ⬜ | ⬜ | ⬜ | |
| `PUT /v2/admin/questions/:id` | Edit question | ⬜ | ⬜ | ⬜ | ⬜ | |
| `DELETE /v2/admin/questions/:id` | Soft delete question (set status=0) | ⬜ | ⬜ | ⬜ | ⬜ | |
| `POST /v2/admin/questions/import` | Bulk CSV import | ⬜ | ⬜ | ⬜ | ⬜ | |
| `GET /v2/admin/ai-questions/pending` | AI questions pending review | ⬜ | ⬜ | ⬜ | ⬜ | |
| `POST /v2/admin/ai-questions/:id/approve` | Approve AI question | ⬜ | ⬜ | ⬜ | ⬜ | |
| `POST /v2/admin/ai-questions/:id/reject` | Reject AI question | ⬜ | ⬜ | ⬜ | ⬜ | |
| `GET /v2/admin/analytics/dashboard` | KPI metrics for dashboard | ⬜ | ⬜ | ⬜ | ⬜ | |
| `GET /v2/admin/fraud-flags` | Unresolved fraud detection records | ⬜ | ⬜ | ⬜ | ⬜ | |
| `POST /v2/admin/notifications/send` | Send push notification to segment | ⬜ | ⬜ | ⬜ | ⬜ | |
| `GET /v2/admin/settings` | All system settings | ⬜ | ⬜ | ⬜ | ⬜ | |
| `PUT /v2/admin/settings` | Update system settings | ⬜ | ⬜ | ⬜ | ⬜ | |

---

## Phase 1 Gate — Must Pass Before Phase 2

- [ ] All modules registered in `AppModule`
- [ ] `npx prisma generate` succeeds with zero errors
- [ ] `npm run test` passes (all unit tests)
- [ ] `npm run test:e2e` passes (all integration tests)
- [ ] `npm audit` — zero high/critical vulnerabilities
- [ ] Swagger UI accessible at `/api/docs`
- [ ] All endpoints in Postman collection and returning correct envelope
- [ ] `FirebaseAuthGuard` tested: rejected with expired/forged token
- [ ] Rate limiting tested: 429 returned after threshold
- [ ] `DEVELOPER_ROADMAP.md` Phase 1 checklist marked complete
