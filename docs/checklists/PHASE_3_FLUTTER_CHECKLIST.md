# Phase 3 — Flutter App Migration Checklist

> **Target:** Weeks 11–14 · Existing app: `lib/`
> **Goal:** Route existing Flutter app from PHP backend to Node.js backend, sprint by sprint.
> **Status key:** ⬜ Not started · 🔄 In progress · ✅ Complete · ❌ Blocked
>
> **Columns:** `Dio` = repository uses Dio client · `Parse` = new envelope (`success/data`) parsed · `Test` = Flutter unit test passing · `Prod` = verified in production build · `PHP Off` = PHP endpoint decommissioned

---

## 0. Migration Infrastructure

| Task | Done | Notes |
|---|---|---|
| Add `dio` to `pubspec.yaml` | ⬜ | Replace `http` package |
| Create `lib/core/network/api_client.dart` with Dio + Firebase token interceptor | ⬜ | |
| Create `lib/core/config/api_config.dart` with `migratedEndpoints` set | ⬜ | |
| Create `lib/core/network/api_response.dart` — envelope model `{ success, data, message }` | ⬜ | |
| Write shared `BaseRepository` with error handling for new envelope | ⬜ | |
| Confirm dual-running: both PHP and Node.js endpoints respond correctly | ⬜ | |

---

## Sprint 1 — Auth & Profile (HIGH RISK — test thoroughly)

| Feature | Dio | Parse | Test | Prod | PHP Off | Notes |
|---|---|---|---|---|---|---|
| `POST /v2/auth/login` — replace PHP login | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | |
| `GET /v2/users/me` — replace PHP get_profile | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | |
| `PUT /v2/users/me` — replace PHP update_profile | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | |
| `PUT /v2/users/me/fcm-token` — replace PHP update_fcm | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | |
| Auth state cubit updated for new response shape | ⬜ | ⬜ | ⬜ | ⬜ | — | |
| Profile cubit updated | ⬜ | ⬜ | ⬜ | ⬜ | — | |
| Guest login flow working | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | |

**Sprint 1 sign-off:**
- [ ] Login with Google account succeeds end-to-end
- [ ] Profile data loads from Node.js backend
- [ ] Response field names match — no null display values in UI
- [ ] 2 weeks in production with zero auth-related crash reports

---

## Sprint 2 — Categories & Questions (MEDIUM RISK)

| Feature | Dio | Parse | Test | Prod | PHP Off | Notes |
|---|---|---|---|---|---|---|
| `GET /v2/categories` — replace PHP get_categories | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | |
| `GET /v2/categories/:id/subcategories` | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | |
| `GET /v2/quiz/questions` — replace PHP get_questions | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | |
| `POST /v2/quiz/submit` — replace PHP submit_quiz | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | CRITICAL |
| Quiz cubit updated | ⬜ | ⬜ | ⬜ | ⬜ | — | |
| Categories cubit updated | ⬜ | ⬜ | ⬜ | ⬜ | — | |
| Bookmarks working (if previously in PHP) | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | |

**Sprint 2 sign-off:**
- [ ] All quiz types load correct questions from Node.js
- [ ] Scores are correctly updated in DB after submission
- [ ] Coins awarded match expected values

---

## Sprint 3 — Leaderboard, Badges & Streaks (LOW RISK)

| Feature | Dio | Parse | Test | Prod | PHP Off | Notes |
|---|---|---|---|---|---|---|
| `GET /v2/quiz/leaderboard` — replace PHP get_leaderboard | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | |
| `GET /v2/users/me/badges` — replace PHP get_badges | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | |
| `GET /v2/streak` — replace PHP get_streak | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | |
| `POST /v2/streak/check-in` — replace PHP daily_checkin | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | |
| `GET /v2/users/me/stats` — replace PHP get_user_stats | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | |
| Leaderboard cubit updated | ⬜ | ⬜ | ⬜ | ⬜ | — | |
| Streak cubit updated | ⬜ | ⬜ | ⬜ | ⬜ | — | |

---

## Sprint 4 — Daily Challenge & Contests (MEDIUM RISK)

| Feature | Dio | Parse | Test | Prod | PHP Off | Notes |
|---|---|---|---|---|---|---|
| `GET /v2/quiz/daily-challenge` | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | |
| `POST /v2/quiz/daily-challenge/submit` | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | |
| `GET /v2/contests/active` | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | |
| `GET /v2/contests/:id` | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | |
| `POST /v2/contests/:id/enter` | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | |
| Contest cubit updated | ⬜ | ⬜ | ⬜ | ⬜ | — | |

---

## Sprint 5 — League (MEDIUM RISK)

| Feature | Dio | Parse | Test | Prod | PHP Off | Notes |
|---|---|---|---|---|---|---|
| `GET /v2/leagues/active` | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | |
| `GET /v2/leagues/:id` | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | |
| `POST /v2/leagues/:id/join` | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | |
| `POST /v2/leagues/:id/submit` | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | |
| `GET /v2/leagues/:id/leaderboard` | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | |
| League cubit updated | ⬜ | ⬜ | ⬜ | ⬜ | — | |

---

## Sprint 6 — Coins, Lives, Boosters (HIGH RISK — money involved)

| Feature | Dio | Parse | Test | Prod | PHP Off | Notes |
|---|---|---|---|---|---|---|
| `GET /v2/coins/balance` | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | |
| `GET /v2/lives` | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | |
| `POST /v2/lives/use` | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | |
| `POST /v2/lives/restore/ad` | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | |
| `POST /v2/lives/restore/coins` | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | |
| `GET /v2/boosters/types` | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | |
| `GET /v2/boosters/inventory` | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | |
| `POST /v2/boosters/purchase` | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | |
| `POST /v2/payments/initialize` | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | |
| `POST /v2/payments/verify/:reference` | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | |
| Coins cubit updated | ⬜ | ⬜ | ⬜ | ⬜ | — | |
| Lives cubit updated | ⬜ | ⬜ | ⬜ | ⬜ | — | |

**Sprint 6 sign-off:**
- [ ] Coin purchases tested with Paystack test card
- [ ] No double-charge or double-award in test runs
- [ ] Lives regen timer displays correctly

---

## Sprint 7 — Ads & Config (LOW RISK)

| Feature | Dio | Parse | Test | Prod | PHP Off | Notes |
|---|---|---|---|---|---|---|
| `GET /v2/config/system` | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | |
| `GET /v2/config/languages` | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | |
| `GET /v2/ads/sponsor-banners` | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | |
| `POST /v2/ads/banner-click` | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | |
| AdMob config driven by `system` response | ⬜ | ⬜ | ⬜ | ⬜ | — | |

---

## Sprint 8 — Notifications (LOW RISK)

| Feature | Dio | Parse | Test | Prod | PHP Off | Notes |
|---|---|---|---|---|---|---|
| `GET /v2/notifications` | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | |
| `PUT /v2/notifications/:id/read` | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | |
| `GET /v2/referral/code` | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | |
| `POST /v2/referral/apply` | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | |
| Notifications cubit updated | ⬜ | ⬜ | ⬜ | ⬜ | — | |

---

## PHP Decommission Gate

Before shutting down PHP backend:

- [ ] All 8 sprint groups migrated and verified in production
- [ ] 2 weeks of zero PHP-related error reports after final sprint
- [ ] `migratedEndpoints` set in `ApiConfig` covers ALL endpoints
- [ ] PHP backend set to maintenance mode for 1 week with monitoring
- [ ] Error logs checked daily during maintenance mode week
- [ ] PHP server shut down after maintenance week with zero issues
