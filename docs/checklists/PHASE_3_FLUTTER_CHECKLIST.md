# Phase 3 — Flutter App Migration Checklist

> **Target:** Weeks 11–14 · Existing app: `lib/`
> **Goal:** Route existing Flutter app from PHP backend to Node.js backend, sprint by sprint.
> **Status key:** ⬜ Not started · 🔄 In progress · ✅ Complete · ❌ Blocked
>
> **Columns:** `Dio` = repository uses Dio client · `Parse` = new envelope (`success/data`) parsed · `Test` = Flutter unit test passing · `Prod` = verified in production build · `PHP Off` = PHP endpoint decommissioned

---

## ⚠️ Strategic Update — May 2026

**Decision:** The existing `lib/` Flutter app (sourced from CodeCanyon) will NOT be submitted to Apple App Store or used as the long-term Android app. Instead:

- **`lib/` app** stays live on Android Play Store as-is, serving existing Android users until the new app ships. **No further feature investment in `lib/`.**
- **`apps/mobile/`** is the new production Flutter app — same bundle ID `com.togafrica.mquiz` on Android (existing users get a Play Store upgrade), fresh first-submission on iOS App Store (new code, no similarity risk).
- **Phase 3 Flutter wiring** done in `lib/` is now **reference implementation only** — the infrastructure (`NestJsApi`, `ApiMigration` flags, `runNestCall`, `ApiClient`) is directly copy-portable into `apps/mobile/`.
- **Phase 3 NestJS backend** (`apps/api/`) is ✅ fully complete and is the API target for both the old and new app.

**Next line of action → Phase 5 (build `apps/mobile/`). Phase 4 on `lib/` is skipped.**

---

## Implementation Status Snapshot

**Migration infrastructure: COMPLETE.** All Dio plumbing, the `NestJsApi` service exposing every v2 endpoint, the `ApiMigration` feature-flag system, and the `runNestCall` error-translation bridge are in place and compile clean.

**Per-feature wiring: PARTIAL.** The following data sources/cubits now route to NestJS when their feature flag is enabled (flags all default `false` → zero production risk):

| Feature flag | File wired | NestJS endpoint |
|---|---|---|
| `ApiMigration.bookmarks` | `lib/features/bookmark/bookmark_remote_data_source.dart` | `GET/POST/DELETE /v2/bookmarks` (quiz_zone only) |
| `ApiMigration.badges` | `lib/features/badges/badges_remote_data_source.dart` | `GET /v2/users/me/badges` |
| `ApiMigration.config` | `lib/features/system_config/system_config_remote_data_source.dart` | `GET /v2/config/system` |
| `ApiMigration.notifications` | `lib/features/notification/cubit/notification_cubit.dart` | `GET /v2/notifications` |
| `ApiMigration.categories` | `lib/features/quiz/quiz_remote_data_source.dart` (`getCategory`, `getSubCategory`) | `GET /v2/categories`, `GET /v2/categories/:id/subcategories` |
| `ApiMigration.profile` | `lib/features/profile_management/profile_management_remote_data_source.dart` (`getUserDetailsById`) | `GET /v2/users/me` |
| `ApiMigration.stats` | `lib/features/statistic/statistic_remote_data_source.dart` (`getStatistic`) | `GET /v2/users/me/stats` |
| `ApiMigration.streak` | `lib/features/wallet/repos/monetization_remote_data_source.dart` (`checkDailyStreak`) | `POST /v2/streak/check-in` |
| `ApiMigration.coins` | `lib/features/coin_history/repos/coin_history_remote_data_source.dart` | `GET /v2/coins/history` |
| `ApiMigration.ads` | `lib/features/wallet/repos/monetization_remote_data_source.dart` (`getSponsorBanner`, `getSponsorBanners`) | `GET /v2/ads/sponsor-banners` |

**To roll out a feature** (after staging verification): build with `--dart-define=USE_NESTJS_<FEATURE>=true` (e.g. `USE_NESTJS_CATEGORIES=true`).

**Deferred items** (need extra work beyond a flag flip):
- **Auth login / guest** — NestJS uses Firebase ID token from `Authorization` header; PHP returns `data.api_token`. Requires changes in `AuthLocalDataSource` to bypass JWT storage when on NestJS.
- **Leaderboard cubits** — PHP returns `{my_rank, other_users_rank}`; NestJS returns flat array. Needs a cubit adapter that fetches `getMyLeaderboardRank` separately.
- **Quiz submit** — `setQuizCoinScore` payload differs across quiz types; case-by-case mapping required.
- **Profile update / FCM token / avatar upload** — multipart and field-name mapping pending.
- **Lives / boosters / payments** — money-critical; defer until lower-risk features are verified in production first.
- **Specialised quiz fetchers** (audio, latex, comprehension, multi-match, exam, fun-and-learn) — no NestJS equivalents; remain on PHP.

---

## 0. Migration Infrastructure

| Task | Done | Notes |
|---|---|---|
| Add `dio` to `pubspec.yaml` | ✅ | dio: ^5.8.0 added; `flutter pub get` clean |
| Create `lib/core/network/api_client.dart` with Dio + Firebase token interceptor | ✅ | Singleton `ApiClient.instance`, auth interceptor, 401 force-refresh retry, debug LogInterceptor |
| Create `lib/core/network/api_config.dart` with feature-flag set | ✅ | `ApiMigration` class with 20 per-feature bool flags + `globallyEnabled` kill-switch; all default `false`, override via `--dart-define=USE_NESTJS_<FEATURE>=true` |
| Create `lib/core/network/api_response.dart` — envelope model `{ success, data, message }` | ✅ | Generic `ApiResponse<T>` + `ApiClientException` typed errors |
| Write shared `BaseRepository` with error handling for new envelope | ✅ | `runNestCall<T>()` bridges `ApiClientException` → legacy `ApiException` so existing cubits work unchanged |
| Confirm dual-running: both PHP and Node.js endpoints respond correctly | ✅ | Per-feature flag pattern — when flag off, original PHP code path runs; when on, NestJS code runs. No behavior change until explicitly opted in |
| Comprehensive `NestJsApi` service exposing all v2 endpoints | ✅ | `lib/core/network/nestjs_api.dart` — ~50 typed methods across all 8 sprints |

**Strategy used:** Feature-flag gated migration. Each migrated data-source method checks the relevant `ApiMigration.<feature>` flag at the top; if `true`, routes to NestJS via `NestJsApi`; if `false`, falls through to existing PHP code. This means **zero production risk on merge** — all flags default `false`. Production rollout happens by flipping the build-time defines once each feature is verified in staging.

---

## Sprint 1 — Auth & Profile (HIGH RISK — test thoroughly)

| Feature | Dio | Parse | Test | Prod | PHP Off | Notes |
|---|---|---|---|---|---|---|
| `POST /v2/auth/login` — replace PHP login | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | Deferred — different shape (NestJS uses Firebase token from `Authorization` header, no `api_token` response). Requires `AuthLocalDataSource` token-storage changes |
| `GET /v2/users/me` — replace PHP get_profile | ✅ | ✅ | ⬜ | ⬜ | ⬜ | Gated on `ApiMigration.profile` in `profile_management_remote_data_source.dart` |
| `PUT /v2/users/me` — replace PHP update_profile | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | Multipart upload; deferred |
| `PUT /v2/users/me/fcm-token` — replace PHP update_fcm | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | NestJsApi method present (`updateFcmToken`); wiring deferred |
| Auth state cubit updated for new response shape | ⬜ | ⬜ | ⬜ | ⬜ | — | Blocked by auth-response shape difference |
| Profile cubit updated | ✅ | ✅ | ⬜ | ⬜ | — | No cubit change needed; `runNestCall` bridges errors |
| Guest login flow working | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | Deferred with auth |

**Sprint 1 sign-off:**
- [ ] Login with Google account succeeds end-to-end
- [ ] Profile data loads from Node.js backend
- [ ] Response field names match — no null display values in UI
- [ ] 2 weeks in production with zero auth-related crash reports

---

## Sprint 2 — Categories & Questions (MEDIUM RISK)

| Feature | Dio | Parse | Test | Prod | PHP Off | Notes |
|---|---|---|---|---|---|---|
| `GET /v2/categories` — replace PHP get_categories | ✅ | ✅ | ⬜ | ⬜ | ⬜ | Gated on `ApiMigration.categories` in `quiz_remote_data_source.dart` |
| `GET /v2/categories/:id/subcategories` | ✅ | ✅ | ⬜ | ⬜ | ⬜ | Gated on `ApiMigration.categories` |
| `GET /v2/quiz/questions` — replace PHP get_questions | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | Many specialised PHP variants (audio, latex, comprehension, multi-match) have no v2 equivalent — keep on PHP |
| `POST /v2/quiz/submit` — replace PHP submit_quiz | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | `NestJsApi.submitQuiz` ready; wiring deferred — payload shape differs across quiz types |
| Quiz cubit updated | ✅ | ✅ | ⬜ | ⬜ | — | No cubit change needed |
| Categories cubit updated | ✅ | ✅ | ⬜ | ⬜ | — | No cubit change needed |
| Bookmarks working | ✅ | ✅ | ⬜ | ⬜ | ⬜ | Gated on `ApiMigration.bookmarks` and `type == '1'` only (quiz_zone). Audio/guess-the-word bookmarks stay on PHP |

**Sprint 2 sign-off:**
- [ ] All quiz types load correct questions from Node.js
- [ ] Scores are correctly updated in DB after submission
- [ ] Coins awarded match expected values

---

## Sprint 3 — Leaderboard, Badges & Streaks (LOW RISK)

| Feature | Dio | Parse | Test | Prod | PHP Off | Notes |
|---|---|---|---|---|---|---|
| `GET /v2/quiz/leaderboard` — replace PHP get_leaderboard | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | `NestJsApi.getLeaderboard` ready; PHP returns `{my_rank, other_users_rank}` envelope vs flat list. Cubit adapter needed before wiring |
| `GET /v2/users/me/badges` — replace PHP get_badges | ✅ | ✅ | ⬜ | ⬜ | ⬜ | Gated on `ApiMigration.badges` |
| `GET /v2/streak` — replace PHP get_streak | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | Not exposed via NestJS as standalone GET — streak read piggy-backs on `getMyStats` |
| `POST /v2/streak/check-in` — replace PHP daily_checkin | ✅ | ✅ | ⬜ | ⬜ | ⬜ | Gated on `ApiMigration.streak` in `monetization_remote_data_source.dart#checkDailyStreak` |
| `GET /v2/users/me/stats` — replace PHP get_user_stats | ✅ | ✅ | ⬜ | ⬜ | ⬜ | Gated on `ApiMigration.stats` in `statistic_remote_data_source.dart` |
| Leaderboard cubit updated | ⬜ | ⬜ | ⬜ | ⬜ | — | Blocked on response-shape adapter |
| Streak cubit updated | ✅ | ✅ | ⬜ | ⬜ | — | No cubit change needed |

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
| `GET /v2/coins/balance` | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | `NestJsApi.getCoinBalance` ready |
| `GET /v2/coins/history` | ✅ | ✅ | ⬜ | ⬜ | ⬜ | Gated on `ApiMigration.coins` in `coin_history_remote_data_source.dart` |
| `GET /v2/lives` | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | `NestJsApi.getLives` ready |
| `POST /v2/lives/use` | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | |
| `POST /v2/lives/restore/ad` | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | |
| `POST /v2/lives/restore/coins` | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | |
| `GET /v2/boosters/types` | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | |
| `GET /v2/boosters/inventory` | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | |
| `POST /v2/boosters/purchase` | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | |
| `POST /v2/payments/initialize` | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | Money-critical — defer until production verification of stats/coins |
| `POST /v2/payments/verify/:reference` | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | Money-critical |
| Coins cubit updated | ✅ | ✅ | ⬜ | ⬜ | — | History wired; balance pending |
| Lives cubit updated | ⬜ | ⬜ | ⬜ | ⬜ | — | |

**Sprint 6 sign-off:**
- [ ] Coin purchases tested with Paystack test card
- [ ] No double-charge or double-award in test runs
- [ ] Lives regen timer displays correctly

---

## Sprint 7 — Ads & Config (LOW RISK)

| Feature | Dio | Parse | Test | Prod | PHP Off | Notes |
|---|---|---|---|---|---|---|
| `GET /v2/config/system` | ✅ | ✅ | ⬜ | ⬜ | ⬜ | Gated on `ApiMigration.config` in `system_config_remote_data_source.dart` |
| `GET /v2/config/languages` | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | No 1:1 NestJS endpoint; languages stay on PHP |
| `GET /v2/ads/sponsor-banners` | ✅ | ✅ | ⬜ | ⬜ | ⬜ | Gated on `ApiMigration.ads` in `monetization_remote_data_source.dart#getSponsorBanner(s)` |
| `POST /v2/ads/banner-click` | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | `NestJsApi.recordAdImpression` ready |
| AdMob config driven by `system` response | ✅ | ✅ | ⬜ | ⬜ | — | Inherits system config migration |

---

## Sprint 8 — Notifications (LOW RISK)

| Feature | Dio | Parse | Test | Prod | PHP Off | Notes |
|---|---|---|---|---|---|---|
| `GET /v2/notifications` | ✅ | ✅ | ⬜ | ⬜ | ⬜ | Gated on `ApiMigration.notifications` in `notification_cubit.dart` |
| `PUT /v2/notifications/:id/read` | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | `NestJsApi.markNotificationRead` ready |
| `GET /v2/referral/code` | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | `NestJsApi.getReferralCode` ready; no existing data source to wire |
| `POST /v2/referral/apply` | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | `NestJsApi.applyReferralCode` ready |
| Notifications cubit updated | ✅ | ✅ | ⬜ | ⬜ | — | Cubit wired directly to NestJS |

---

## PHP Decommission Gate

Before shutting down PHP backend:

- [ ] All 8 sprint groups migrated and verified in production
- [ ] 2 weeks of zero PHP-related error reports after final sprint
- [ ] `migratedEndpoints` set in `ApiConfig` covers ALL endpoints
- [ ] PHP backend set to maintenance mode for 1 week with monitoring
- [ ] Error logs checked daily during maintenance mode week
- [ ] PHP server shut down after maintenance week with zero issues
