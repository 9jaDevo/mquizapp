# Phase 5 — New Flutter App (Primary Delivery) Checklist

> **Target:** Active now · Location: `apps/mobile/`
> **Status key:** ⬜ Not started · 🔄 In progress · ✅ Complete · ❌ Blocked
>
> **Last updated:** 2026-05-25
>
> **This is the primary Flutter deliverable.** The existing `lib/` app (CodeCanyon-based) is being retired. This new app replaces it on both stores.
>
> **Sprints completed:** Sprint 0 (Bootstrap) ✅ · Sprint 1 (Auth) ✅
> **`flutter analyze lib` — No issues found ✅**

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
| `GET /v2/lives` | ⬜ | |
| `POST /v2/lives/use` | ⬜ | |
| `POST /v2/lives/restore/ad` | ⬜ | |
| `POST /v2/lives/restore/coins` | ⬜ | |
| `GET /v2/boosters/types` | ⬜ | |
| `GET /v2/boosters/inventory` | ⬜ | |
| `POST /v2/boosters/purchase` | ⬜ | |
| `POST /v2/boosters/use` | ⬜ | |
| `GET /v2/progress` | ⬜ | |
| `GET /v2/progress/stages` | ⬜ | |
| `POST /v2/payments/initialize` | ⬜ | Paystack |
| `POST /v2/payments/verify/:reference` | ⬜ | Paystack |

---

## 0. Project Bootstrap (`apps/mobile/`)

| Task | Done | Notes |
|---|---|---|
| Flutter project created (`flutter create`) | ✅ | `apps/mobile/` — bundle ID set via `--org com.togafrica` |
| Bundle ID set to `com.togafrica.mquiz` on Android AND iOS | ✅ | Same ID = Android upgrade, fresh iOS submission |
| Firebase project configured (existing project, new app registration) | ⬜ | Need `google-services.json` + `GoogleService-Info.plist` from Firebase Console |
| AdMob App ID registered for iOS | ⬜ | Android AdMob ID can be reused |
| GoRouter installed and configured | ✅ | `go_router ^14.6.3` — `app/router.dart` with auth redirect + ShellRoute |
| `flutter_bloc` (Cubit) installed | ✅ | `flutter_bloc ^9.1.1` + `equatable ^2.0.7` |
| `dio` installed + `ApiClient` ported from `lib/core/network/api_client.dart` | ✅ | Firebase token interceptor + 401 retry. Points to `https://mquizapi.onrender.com/v2` |
| `NestJsApi` service ported from `lib/core/network/nestjs_api.dart` | ✅ | ~55 typed methods in `core/network/nestjs_api.dart` |
| Design system implemented (`lib/core/theme/`) | ✅ | `AppColors`, `AppTextStyles` (Poppins), `AppTheme` light/dark — Material 3 |
| All new assets created (no CodeCanyon SVGs carried over) | ⬜ | Logo, onboarding illustrations, lifeline icons — original artwork needed |
| App icon (original design) | ⬜ | `flutter_launcher_icons` ready in pubspec; artwork needed |
| Splash screen (original design) | ⬜ | Programmatic splash in `splash_screen.dart`; original logo asset needed |
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
| Lives counter in header | ⬜ | ⬜ | |
| Coins counter in header | ⬜ | ⬜ | |
| XP/progress bar in header | ⬜ | ⬜ | |
| Category grid | ⬜ | ⬜ | |
| Daily challenge card | ⬜ | ⬜ | |
| Exam Prep section (WAEC/JAMB/NECO) | ⬜ | ⬜ | |
| Active contest banner | ⬜ | ⬜ | |
| Sponsor banner (if active) | ⬜ | ⬜ | |
| `HomeCubit` + states | ⬜ | ⬜ | |
| `HomeRepository` | ⬜ | ⬜ | |
| `HomeRemoteDataSource` | ⬜ | ⬜ | |

---

## 3. Quiz Feature (`lib/features/quiz/`)

| Screen / Component | Impl | Test | Notes |
|---|---|---|---|
| Category/subcategory selection screen | ⬜ | ⬜ | |
| Quiz screen (all question types) | ⬜ | ⬜ | |
| — Multiple choice (standard) | ⬜ | ⬜ | |
| — Fun & Learn | ⬜ | ⬜ | |
| — Guess the Word | ⬜ | ⬜ | |
| — Audio questions | ⬜ | ⬜ | |
| — Math questions | ⬜ | ⬜ | |
| Countdown timer | ⬜ | ⬜ | |
| Booster icons in quiz (with effects) | ⬜ | ⬜ | |
| Result screen (score, accuracy, rank change) | ⬜ | ⬜ | |
| Share result card | ⬜ | ⬜ | |
| Mystery box trigger (every 3rd quiz) | ⬜ | ⬜ | |
| Wrong answer AI explanation | ⬜ | ⬜ | Phase 6 |
| `QuizCubit` + states | ⬜ | ⬜ | |

---

## 4. Progress Map Feature (`lib/features/progress_map/`)

| Screen / Component | Impl | Test | Notes |
|---|---|---|---|
| Progress map screen (scrollable stage nodes) | ⬜ | ⬜ | |
| Locked/unlocked stage states | ⬜ | ⬜ | |
| Stage unlock animation | ⬜ | ⬜ | Lottie |
| `ProgressCubit` | ⬜ | ⬜ | |

---

## 5. Lives Feature (`lib/features/lives/`)

| Screen / Component | Impl | Test | Notes |
|---|---|---|---|
| "Out of lives" modal | ⬜ | ⬜ | Watch ad / coins / wait |
| Regen countdown timer | ⬜ | ⬜ | Server time |
| `LivesCubit` | ⬜ | ⬜ | |

---

## 6. Boosters Feature (`lib/features/boosters/`)

| Screen / Component | Impl | Test | Notes |
|---|---|---|---|
| Booster store screen | ⬜ | ⬜ | |
| Booster purchase confirmation | ⬜ | ⬜ | |
| `BoostersCubit` | ⬜ | ⬜ | |

---

## 7. Battle Feature (`lib/features/battle/`)

| Screen / Component | Impl | Test | Notes |
|---|---|---|---|
| Find opponent screen | ⬜ | ⬜ | Firestore matchmaking |
| Live battle screen (Firestore sync) | ⬜ | ⬜ | |
| Battle result screen | ⬜ | ⬜ | |
| `BattleCubit` | ⬜ | ⬜ | |

---

## 8. Leaderboard Feature (`lib/features/leaderboard/`)

| Screen / Component | Impl | Test | Notes |
|---|---|---|---|
| Global leaderboard tabs (daily/weekly/all-time) | ⬜ | ⬜ | |
| My rank highlight | ⬜ | ⬜ | |
| Category leaderboard | ⬜ | ⬜ | |
| `LeaderboardCubit` | ⬜ | ⬜ | |

---

## 9. Profile Feature (`lib/features/profile/`)

| Screen / Component | Impl | Test | Notes |
|---|---|---|---|
| Profile screen | ⬜ | ⬜ | |
| Edit profile | ⬜ | ⬜ | |
| Badges display | ⬜ | ⬜ | |
| Stats display | ⬜ | ⬜ | |
| Referral code + share | ⬜ | ⬜ | |
| Coin history | ⬜ | ⬜ | |
| `ProfileCubit` | ⬜ | ⬜ | |

---

## 10. Store Feature (`lib/features/store/`)

| Screen / Component | Impl | Test | Notes |
|---|---|---|---|
| Coin packs listing | ⬜ | ⬜ | |
| Subscription plans | ⬜ | ⬜ | |
| Paystack payment flow | ⬜ | ⬜ | |
| Apple IAP (required by App Store) | ⬜ | ⬜ | |
| `StoreCubit` | ⬜ | ⬜ | |

---

## 11. League Feature (`lib/features/league/` — reuse from existing app)

| Screen / Component | Impl | Test | Notes |
|---|---|---|---|
| Active leagues list | ⬜ | ⬜ | |
| League detail + join | ⬜ | ⬜ | |
| League daily quiz | ⬜ | ⬜ | |
| League leaderboard | ⬜ | ⬜ | |

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
| Sprint 7 | Leagues (list, detail, join, daily quiz, leaderboard) | ⚠️ Partial — list/detail/join/leaderboard done; in-league quiz play deferred |
| Sprint 8 | Contests (banner, detail, entry, live results) | ⚠️ Partial — list done; detail + play deferred |
| Sprint 9 | Store + Payments (coin packs, subscriptions, Paystack, Apple IAP) | ✅ Coin store + Paystack init/verify (server-authoritative); subscriptions/Apple IAP not in scope |
| Sprint 10 | Battle (Firestore matchmaking, live battle screen, result) | ⬜ Deferred — Firestore room/matchmaking needs dedicated sprint with security rules |
| Sprint 11 | Progress Map (scrollable stage nodes, unlock animation) | ✅ |
| Sprint 12 | Firebase config + assets + app icon + Polish | ⚠️ Partial — launcher icons generated from mQuiz Logo.png (Android mipmaps + iOS AppIcon); splash + fonts polish deferred |
| Sprint 13 | Tests + TestFlight + App Store submission | ⬜ |

**Outstanding blockers (must resolve before first device build):**
- ⬜ Download `google-services.json` from Firebase Console → `apps/mobile/android/app/`
- ⬜ Download `GoogleService-Info.plist` from Firebase Console → `apps/mobile/ios/Runner/`
- ⬜ Original logo/icon artwork (no CodeCanyon assets)
