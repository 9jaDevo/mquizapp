# Phase 5 — New Flutter App (Apple Store) Checklist

> **Target:** Parallel with Phase 4 · Location: `apps/mobile/`
> **Status key:** ⬜ Not started · 🔄 In progress · ✅ Complete · ❌ Blocked

---

## 0. Project Bootstrap (`apps/mobile/`)

| Task | Done | Notes |
|---|---|---|
| Flutter project created (`flutter create`) | ⬜ | |
| New Bundle ID registered: `com.mquiz.learn` | ⬜ | Not the old ID |
| New Firebase project configured | ⬜ | New `GoogleService-Info.plist` + `google-services.json` |
| New AdMob App ID registered | ⬜ | |
| GoRouter installed and configured | ⬜ | |
| `flutter_bloc` (Cubit) installed | ⬜ | |
| `dio` installed + `ApiClient` created | ⬜ | Points to Node.js backend |
| Design system implemented (`lib/core/theme/`) | ⬜ | New color palette + Nunito font |
| Privacy Policy URL live: `https://mquiz.uk/privacy` | ⬜ | Required for Apple |
| App icon (new design, not CodeCanyon template) | ⬜ | |
| Splash screen (new design) | ⬜ | |

---

## 1. Auth Feature (`lib/features/auth/`)

| Screen / Component | Impl | Test | Notes |
|---|---|---|---|
| Login screen (Google + Apple + Phone options) | ⬜ | ⬜ | |
| Google sign-in flow | ⬜ | ⬜ | |
| Apple sign-in flow | ⬜ | ⬜ | Required for App Store |
| Phone OTP flow | ⬜ | ⬜ | |
| Guest mode (skip login) | ⬜ | ⬜ | |
| Onboarding flow (name, age group, language) | ⬜ | ⬜ | Post-login, first-time only |
| `AuthCubit` + states | ⬜ | ⬜ | |

---

## 2. Home Feature (`lib/features/home/`)

| Screen / Component | Impl | Test | Notes |
|---|---|---|---|
| Home screen layout (new game-like design) | ⬜ | ⬜ | |
| Lives counter in header | ⬜ | ⬜ | |
| Coins counter in header | ⬜ | ⬜ | |
| XP/progress bar in header | ⬜ | ⬜ | |
| Category grid | ⬜ | ⬜ | |
| Daily challenge card | ⬜ | ⬜ | |
| Exam Prep section (WAEC/JAMB/NECO) | ⬜ | ⬜ | |
| Active contest banner | ⬜ | ⬜ | |
| Sponsor banner (if active) | ⬜ | ⬜ | |
| `HomeCubit` + states | ⬜ | ⬜ | |

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
| No hardcoded API keys in source code | ⬜ | Security check |
| `flutter analyze` — zero errors | ⬜ | |
| `flutter test` — all tests passing | ⬜ | |
| TestFlight internal testing complete | ⬜ | Min 2 weeks |
| TestFlight external testing complete | ⬜ | Min 1 week |
| Submission to App Store Review | ⬜ | |
