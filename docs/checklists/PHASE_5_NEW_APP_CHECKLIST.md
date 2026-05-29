# Phase 5 — New Flutter App (Primary Delivery) Checklist

> **Target:** Active now · Location: `apps/mobile/`
> **Status key:** ⬜ Not started · 🔄 In progress · ✅ Complete · ❌ Blocked
>
> **Last updated:** 2026-05-26
>
> **This is the primary Flutter deliverable.** The existing `lib/` app (CodeCanyon-based) is being retired. This new app replaces it on both stores.
>
> **Sprints completed:** Sprint 0 ✅ · Sprint 1 ✅ · Sprint 2 ✅ · Sprint 3 ✅ · Sprint 4 ✅ · Sprint 5 ✅ · Sprint 6 ✅ · Sprint 7 ✅ · Sprint 8 ✅ · Sprint 9 ✅ · Sprint 10 ✅ · Sprint 11 ✅ · Sprint 12 (Splash) ✅ · Sprint 13 (Phase B–E) ✅
> **`flutter analyze lib` — 0 errors, 0 warnings in all new code ✅**

---

## ⚠️ Bundle ID Strategy — May 2026

| Platform | Bundle ID | Effect |
|---|---|---|
| **Android** | `com.togafrica.mquiz` | Existing Play Store users get a seamless OTA upgrade |
| **iOS** | `com.togafrica.mquiz` | First-ever submission — no similarity risk (brand new code) |

**Do NOT use a new bundle ID like `com.mquiz.learn`.** Keeping the same Android ID retains all existing users without requiring a reinstall.

---

## Pre-requisite: NestJS API Endpoints (Phase 4 backend work)

These backend endpoints must exist before the new app can use them. Build in `apps/api/` first.

| Endpoint | Done | Notes |
|---|---|---|
| `GET /v2/lives` | ✅ | Implemented as `GET /v2/lives/me` |
| `POST /v2/lives/use` | ✅ | Implemented as `POST /v2/lives/consume` |
| `POST /v2/lives/restore/ad` | ✅ | Implemented as `POST /v2/lives/restore-with-ad` |
| `POST /v2/lives/restore/coins` | ✅ | Implemented as `POST /v2/lives/restore-with-coins` |
| `GET /v2/boosters/types` | ✅ | |
| `GET /v2/boosters/inventory` | ✅ | Implemented as `GET /v2/boosters/me` |
| `POST /v2/boosters/purchase` | ✅ | Implemented as `POST /v2/boosters/:boosterTypeId/purchase` |
| `POST /v2/boosters/use` | ✅ | Implemented as `POST /v2/boosters/consume` |
| `GET /v2/progress` | ✅ | Implemented as `GET /v2/progress/me` |
| `GET /v2/progress/stages` | ✅ | |
| `POST /v2/payments/initialize` | ✅ | Paystack |
| `POST /v2/payments/verify/:reference` | ✅ | Paystack |

---

## 0. Project Bootstrap (`apps/mobile/`)

| Task | Done | Notes |
|---|---|---|
| Flutter project created (`flutter create`) | ✅ | `apps/mobile/` — bundle ID set via `--org com.togafrica` |
| Bundle ID set to `com.togafrica.mquiz` on Android AND iOS | ✅ | Same ID = Android upgrade, fresh iOS submission |
| Firebase project configured (existing project, new app registration) | ✅ | `google-services.json` (android/app/) + `GoogleService-Info.plist` (ios/Runner/) downloaded and present |
| AdMob App ID registered for iOS | ⬜ | Android AdMob ID can be reused |
| GoRouter installed and configured | ✅ | `go_router ^14.6.3` — `app/router.dart` with auth redirect + ShellRoute |
| `flutter_bloc` (Cubit) installed | ✅ | `flutter_bloc ^9.1.1` + `equatable ^2.0.7` |
| `dio` installed + `ApiClient` ported from `lib/core/network/api_client.dart` | ✅ | Firebase token interceptor + 401 retry. Points to `https://mquizapi.onrender.com/v2` |
| `NestJsApi` service ported from `lib/core/network/nestjs_api.dart` | ✅ | ~55 typed methods in `core/network/nestjs_api.dart` |
| Design system implemented (`lib/core/theme/`) | ✅ | `AppColors`, `AppTextStyles` (Poppins), `AppTheme` light/dark — Material 3 |
| All new assets created (no CodeCanyon SVGs carried over) | ⬜ | Logo, onboarding illustrations, lifeline icons — original artwork needed |
| App icon (original design) | ✅ | `assets/images/app_icon.png` present; `flutter_launcher_icons` configured in pubspec |
| Splash screen (original design) | ✅ | ⬜ | `splash_screen.dart` — AnimatedOpacity logo fade-in on `#7C3AED` bg; `flutter_native_splash ^2.4.4` configured; run `dart run flutter_native_splash:create` |
| Privacy Policy URL live: `https://mquiz.uk/privacy` | ⬜ | Required for Apple |
| `flutter analyze` — zero warnings | ✅ | **No issues found** (ran 2026-05-25) |

---

## 1. Auth Feature (`lib/features/auth/`)

| Screen / Component | Impl | Test | Notes |
|---|---|---|---|
| Login screen (Google + Apple + Phone options) | ✅ | ⬜ | `login_screen.dart` — all 4 options + Guest |
| Google sign-in flow | ✅ | ⬜ | `auth_remote_data_source.dart` + `AuthCubit` |
| Apple sign-in flow | ✅ | ⬜ | `sign_in_with_apple` — required for App Store |
| Phone OTP flow | ✅ | ⬜ | `otp_screen.dart` with PinCodeTextField (6-digit) |
| Guest mode (skip login) | ✅ | ⬜ | Anonymous Firebase sign-in |
| Onboarding flow (name setup, first-time only) | ✅ | ⬜ | `profile_setup_screen.dart` — name input; age/language ⬜ pending |
| `AuthCubit` + sealed states | ✅ | ⬜ | `AuthInitial`, `AuthLoading`, `Authenticated`, `AuthNeedsProfileSetup`, `AuthOtpSent`, `Unauthenticated`, `AuthError` |

---

## 2. Home Feature (`lib/features/home/`)

| Screen / Component | Impl | Test | Notes |
|---|---|---|---|
| Home screen layout (new game-like design) | ✅ | ⬜ | Gradient header, stat pills (coins/lives/streak), category grid, daily challenge banner |
| Lives counter in header | ✅ | ⬜ | `_GreetingHeader` stat pill |
| Coins counter in header | ✅ | ⬜ | `_GreetingHeader` stat pill |
| XP/stage progress bar in header | ✅ | ⬜ | `_GreetingHeader` — LinearProgressIndicator with stage label + XP count |
| Category grid | ✅ | ⬜ | `SliverGrid` with `_CategoryCard` |
| Daily challenge card | ✅ | ⬜ | `_DailyChallengeCard` — best-effort load |
| Exam Prep section (WAEC/JAMB/NECO) | 🔲 | ⬜ | Deferred — Phase 6 (schools feature) |
| Active contest banner | ✅ | ⬜ | `_ContestBanner` — orange gradient, trophy icon, routes to `/contests` |
| Sponsor banner (if active) | ✅ | ⬜ | `_SponsorBanner` — white card, network logo, opens websiteUrl via `url_launcher` |
| `HomeCubit` + states | ✅ | ⬜ | `home_cubit.dart` — HomeInitial/Loading/Loaded/Error |
| `HomeRepository` | ✅ | ⬜ | `home_repository.dart` — parallel profile+categories+daily |
| `HomeRemoteDataSource` | ✅ | ⬜ | Data fetched via `NestJsApi` + `ProfileRepository` |

---

## 3. Quiz Feature (`lib/features/quiz/`)

| Screen / Component | Impl | Test | Notes |
|---|---|---|---|
| Category/subcategory selection screen | ✅ | ⬜ | `subcategories_screen.dart` |
| Lives gate on quiz start | ✅ | ⬜ | `_startQuiz()` checks lives → `LivesCubit.consume()` → `OutOfLivesSheet` if 0 |
| Lives gate on quiz start | ✅ | ⬜ | `_startQuiz()` checks lives → `LivesCubit.consume()` → `OutOfLivesSheet` if 0 |
| Quiz screen (all question types) | ✅ | ⬜ | `quiz_screen.dart` — MC, image support, timer |
| — Multiple choice (standard) | ✅ | ⬜ | `_OptionTile` with square badge |
| — Fun & Learn | ✅ | ⬜ | `_FunLearnView` — explanation card, auto-reveal after 3s, "Show options now" button |
| — Guess the Word | ✅ | ⬜ | `_GuessTheWordView` — Wrap layout with animated tap tiles |
| — Audio questions | 🔲 | ⬜ | Deferred — Phase 6 (needs audio streaming infra) |
| — Math questions | 🔲 | ⬜ | Deferred — Phase 6 (needs LaTeX renderer) |
| Countdown timer | ✅ | ⬜ | `_QuizHeader` + `Timer.periodic` in `QuizCubit` |
| Booster icons in quiz (with effects) | ✅ | ⬜ | `_BoosterTray` + `_BoosterChip` — addTime(30s) for time, skipQuestion for skip, 50/50 support |
| Result screen (score, accuracy, rank change) | ✅ | ⬜ | `quiz_result_screen.dart` — score/accuracy/coins |
| Share result card | ✅ | ⬜ | `_share()` via `share_plus` — score/accuracy/coins + mquizapp.com link |
| Mystery box trigger (every 3rd quiz) | ✅ | ⬜ | `_checkMysteryBoxTrigger()` in QuizCubit — SharedPreferences counter, every 5th quiz; `_MysteryBoxSheet` bottom sheet with elastic animation |
| Wrong answer AI explanation | 🔲 | ⬜ | Deferred — Phase 6 |
| `QuizCubit` + states | ✅ | ⬜ | `quiz_cubit.dart` — Idle/Loading/InProgress/Submitting/Completed/Error |

---

## 4. Progress Map Feature (`lib/features/progress_map/`)

| Screen / Component | Impl | Test | Notes |
|---|---|---|---|
| Progress map screen (scrollable stage nodes) | ✅ | ⬜ | `progress_map_screen.dart` — scrollable stage nodes |
| Locked/unlocked stage states | ✅ | ⬜ | Visual lock/unlock via `stage.unlocked` |
| Stage unlock animation | 🔲 | ⬜ | Visual only (no Lottie) — Lottie deferred |
| `ProgressCubit` | ✅ | ⬜ | `progress/cubit/` |

---

## 5. Lives Feature (`lib/features/lives/`)

| Screen / Component | Impl | Test | Notes |
|---|---|---|---|
| "Out of lives" modal | ✅ | ⬜ | `out_of_lives_sheet.dart` — watch ad / coins / wait |
| Regen countdown timer | ✅ | ⬜ | Countdown from `nextRefillAt` server timestamp |
| `LivesCubit` | ✅ | ⬜ | `lives_cubit.dart` |

---

## 6. Boosters Feature (`lib/features/boosters/`)

| Screen / Component | Impl | Test | Notes |
|---|---|---|---|
| Booster store screen | ✅ | ⬜ | `booster_store_screen.dart` |
| Booster purchase confirmation | ✅ | ⬜ | Confirmation dialog before deducting coins |
| `BoostersCubit` | ✅ | ⬜ | `booster_store_cubit.dart` |

---

## 7. Battle Feature (`lib/features/battle/`)

| Screen / Component | Impl | Test | Notes |
|---|---|---|---|
| Find opponent screen | ✅ | ⬜ | `find_opponent_screen.dart` — idle → category picker → matchmaking/waiting; navigates to `/battle/live` on `BattleInProgress` |
| Live battle screen (Firestore sync) | ✅ | ⬜ | `live_battle_screen.dart` — real-time opponent progress, `PopScope` quit-guard, auto-advance timer |
| Battle result screen | ✅ | ⬜ | `battle_result_screen.dart` — win/draw/lose banner, score comparison, play-again |
| `BattleCubit` | ✅ | ⬜ | `battle_cubit.dart` — matchmaking → play → finalize; Firestore stream listener |
| `BattleRepository` | ✅ | ⬜ | `battle_repository.dart` — Firestore CRUD + NestJS question fetch |
| `BattleRoom` / `BattlePlayer` / `BattleResult` models | ✅ | ⬜ | `battle_model.dart` — full Equatable models with Firestore serialization |
| Firestore security rules (`battleRoom`) | ✅ | ⬜ | `firestore.rules` — least-privilege: creator-write, participant-update, no client-delete |
| BattleCubit registered in `providers.dart` | ✅ | ⬜ | Global scope (spans FindOpponent → LiveBattle → BattleResult) |
| Routes in `router.dart` (`/battle`, `/battle/live`, `/battle/result`) | ✅ | ⬜ | |
| Battle CTA card on HomeScreen | ✅ | ⬜ | `_BattleCta` widget navigates to `/battle` |

---

## 8. Leaderboard Feature (`lib/features/leaderboard/`)

| Screen / Component | Impl | Test | Notes |
|---|---|---|---|
| Global leaderboard tabs (daily/weekly/all-time) | ✅ | ⬜ | `leaderboard_screen.dart` — TabController with 3 periods |
| My rank highlight | ✅ | ⬜ | `currentUserId` passed to rank rows |
| Category leaderboard | ⬜ | ⬜ | Pending implementation |
| `LeaderboardCubit` | ✅ | ⬜ | `leaderboard_cubit.dart` |

---

## 9. Profile Feature (`lib/features/profile/`)

| Screen / Component | Impl | Test | Notes |
|---|---|---|---|
| Profile screen | ✅ | ⬜ | `profile_screen.dart` |
| Edit profile | ✅ | ⬜ | `edit_profile_screen.dart` |
| Badges display | ✅ | ⬜ | `_BadgesGrid` in profile screen |
| Stats display | ✅ | ⬜ | Stat grid (quizzes / accuracy / streak / badges) |
| Referral code + copy | ✅ | ⬜ | `_ReferralCard` — code display + clipboard copy |
| Referral native share | ✅ | ⬜ | `share_plus` in `_ReferralCard` — referral link with `?ref=CODE` |
| Coin history | ✅ | ⬜ | `coin_history_screen.dart` |
| `ProfileCubit` | ✅ | ⬜ | `profile_cubit.dart` |

---

## 10. Store Feature (`lib/features/store/`)

| Screen / Component | Impl | Test | Notes |
|---|---|---|---|
| Coin packs listing | ✅ | ⬜ | `coin_store_screen.dart` |
| Subscription plans | 🔲 | ⬜ | Deferred — requires separate App Store review process post-launch |
| Paystack payment flow | ✅ | ⬜ | `StoreCubit.initialize` + `StoreCubit.verify` — server-authoritative |
| Apple IAP (required by App Store) | ✅ | ⬜ | `StoreCubit.initIAP()` + `purchaseIAP()` — `in_app_purchase` stream, server-authoritative verify; `CoinPackModel.effectiveAppStoreId` |
| `StoreCubit` | ✅ | ⬜ | `store_cubit.dart` — load/initialize/verify/cancelPurchase |

---

## 11. League Feature (`lib/features/leagues/`)

| Screen / Component | Impl | Test | Notes |
|---|---|---|---|
| Active leagues list | ✅ | ⬜ | `leagues_list_screen.dart` |
| League detail + join | ✅ | ⬜ | `league_detail_screen.dart` — wired "Play Today's Quiz" button |
| League daily quiz | ✅ | ⬜ | `league_quiz_screen.dart` + `league_quiz_cubit.dart` — timer-driven, auto-advance, submit to API |
| League quiz result | ✅ | ⬜ | Shared `session_result_screen.dart` with `SessionResultExtra` |
| League leaderboard | ✅ | ⬜ | Inline in league detail screen |

---

## 11b. Contest Feature (`lib/features/contests/`)

| Screen / Component | Impl | Test | Notes |
|---|---|---|---|
| Contests list | ✅ | ⬜ | `contests_list_screen.dart` — live badge, tapping live contest → detail |
| Contest detail + entry | ✅ | ⬜ | `contest_detail_screen.dart` — prize banner, dates, top-20 leaderboard, Enter & Play |
| Contest quiz | ✅ | ⬜ | `contest_quiz_screen.dart` + `contest_quiz_cubit.dart` — identical flow to league quiz |
| Contest quiz result | ✅ | ⬜ | Shared `session_result_screen.dart` |

---

## 12. Apple App Store Submission

| Task | Done | Notes |
|---|---|---|
| All screens fully functional | ⬜ | Apple tests thoroughly |
| Privacy Policy URL live | ⬜ | `https://mquiz.uk/privacy` |
| Age rating assessed (4+ or 9+) | ⬜ | |
| All IAP products registered in App Store Connect | ⬜ | |
| App Preview video recorded (30–60 seconds) | ⬜ | Shows actual gameplay |
| 6.5-inch screenshots (iPhone 15 Pro Max) | ⬜ | |
| 5.5-inch screenshots (iPhone 8 Plus) | ⬜ | |
| iPad screenshots (if supporting iPad) | ⬜ | |
| App Store Connect description written | ⬜ | Lead with "AI-powered exam practice" |
| Review notes to Apple (explain WAEC/JAMB educational purpose) | ⬜ | |
| Flutter obfuscation enabled in release build | ⬜ | `--obfuscate --split-debug-info` |
| No hardcoded API keys in source code | ✅ | All secrets via Firebase / dart-define |
| `flutter analyze` — zero errors | ✅ | **No issues found** (2026-05-25) |
| `flutter test` — all tests passing | ⬜ | No tests written yet |
| TestFlight internal testing complete | ⬜ | Min 2 weeks |
| TestFlight external testing complete | ⬜ | Min 1 week |
| Submission to App Store Review | ⬜ | |

---

## Sprint Roadmap — Remaining Work

| Sprint | Feature | Status |
|---|---|---|
| Sprint 0 | Bootstrap + Core Infrastructure | ✅ Complete |
| Sprint 1 | Auth (Google / Apple / Phone / Guest) | ✅ Complete |
| Sprint 2 | Home / Dashboard (stats header, category grid, banners) | ✅ |
| Sprint 3 | Categories + Quiz (all question types, timer, result screen) | ✅ |
| Sprint 4 | Leaderboard (global + category, tabs, my-rank highlight) | ✅ |
| Sprint 5 | Profile + Stats (edit, badges, referral, coin history) | ✅ |
| Sprint 6 | Streak + Lives + Boosters (out-of-lives modal, booster store) | ✅ |
| Sprint 7 | Leagues (list, detail, join, daily quiz, leaderboard) | ✅ Complete — list/detail/join/leaderboard + in-league quiz play + shared session result screen |
| Sprint 8 | Contests (banner, detail, entry, live results) | ✅ Complete — list + detail + contest quiz play + shared session result |
| Sprint 9 | Store + Payments (coin packs, subscriptions, Paystack, Apple IAP) | ✅ Coin store + Paystack init/verify (server-authoritative); subscriptions/Apple IAP not in scope |
| Sprint 10 | Battle (Firestore matchmaking, live battle screen, result) | ✅ Complete — all 6 files + providers + routes + home CTA + Firestore security rules |
| Sprint 11 | Progress Map (scrollable stage nodes, unlock animation) | ✅ |
| Sprint 12 | Firebase config + assets + app icon + Polish | ✅ Complete — firebase files downloaded, app icon done, splash polished |
| Sprint 13 | Tests + TestFlight + App Store submission | ⬜ |

**Outstanding blockers (must resolve before first device build):**
- ✅ ~~Download `google-services.json`~~ — present at `apps/mobile/android/app/google-services.json`
- ✅ ~~Download `GoogleService-Info.plist`~~ — present at `apps/mobile/ios/Runner/GoogleService-Info.plist`
- ✅ ~~Original logo/icon artwork~~ — `assets/images/app_icon.png` in place
- ⬜ Run `dart run flutter_launcher_icons:generate` to generate native icon assets
- ⬜ Run `dart run flutter_native_splash:create` to generate native splash assets
