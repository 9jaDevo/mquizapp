# Phase 4 — New Features (Existing Flutter App) Checklist

> **Target:** Weeks 15–22 · Existing app: `lib/`
> **Status key:** ⬜ Not started · 🔄 In progress · ✅ Complete · ❌ Blocked
>
> **Columns:** `API` = backend endpoint done · `UI` = Flutter screen done · `Test` = tests passing · `Prod` = verified in production

---

## 4.1 Lives System

| Task | API | UI | Test | Prod | Notes |
|---|---|---|---|---|---|
| `UserLives` Prisma model + migration | ✅ | — | — | — | Schema defined in roadmap |
| `GET /v2/lives` endpoint | ⬜ | — | ⬜ | ⬜ | |
| `POST /v2/lives/use` endpoint | ⬜ | — | ⬜ | ⬜ | |
| `POST /v2/lives/restore/ad` endpoint | ⬜ | — | ⬜ | ⬜ | |
| `POST /v2/lives/restore/coins` endpoint | ⬜ | — | ⬜ | ⬜ | |
| Lives counter in home screen header (5 hearts) | — | ⬜ | ⬜ | ⬜ | |
| "Out of lives" modal with 3 options | — | ⬜ | ⬜ | ⬜ | Watch ad / use coins / wait |
| Countdown timer to next regen (server time) | — | ⬜ | ⬜ | ⬜ | |
| Lives cubit (`LivesCubit`) | — | ⬜ | ⬜ | ⬜ | |
| Lives deducted on quiz start | ⬜ | ⬜ | ⬜ | ⬜ | |

---

## 4.2 Boosters System

| Task | API | UI | Test | Prod | Notes |
|---|---|---|---|---|---|
| `BoosterType`, `UserBooster` Prisma models | ✅ | — | — | — | |
| `GET /v2/boosters/types` endpoint | ⬜ | — | ⬜ | ⬜ | |
| `GET /v2/boosters/inventory` endpoint | ⬜ | — | ⬜ | ⬜ | |
| `POST /v2/boosters/purchase` endpoint | ⬜ | — | ⬜ | ⬜ | |
| `POST /v2/boosters/use` endpoint | ⬜ | — | ⬜ | ⬜ | |
| Booster icons in quiz screen (bottom row) | — | ⬜ | ⬜ | ⬜ | |
| Fifty-Fifty effect (remove 2 wrong options) | — | ⬜ | ⬜ | ⬜ | Client-side UI only |
| Skip Question effect (advance without penalty) | — | ⬜ | ⬜ | ⬜ | |
| Freeze Timer effect (pause countdown 15s) | — | ⬜ | ⬜ | ⬜ | |
| Double Points effect (2x for next correct) | — | ⬜ | ⬜ | ⬜ | Server validates |
| "Buy booster" bottom sheet (when inventory = 0) | — | ⬜ | ⬜ | ⬜ | |
| Booster Store in profile/store screen | — | ⬜ | ⬜ | ⬜ | |
| Boosters used shown in result screen | — | ⬜ | ⬜ | ⬜ | |
| `ActiveBoosters` model + `BoostersCubit` | — | ⬜ | ⬜ | ⬜ | |

---

## 4.3 Progress Map

| Task | API | UI | Test | Prod | Notes |
|---|---|---|---|---|---|
| `Stage`, `UserProgress` Prisma models | ✅ | — | — | — | |
| `GET /v2/progress` endpoint | ⬜ | — | ⬜ | ⬜ | |
| `GET /v2/progress/stages` endpoint | ⬜ | — | ⬜ | ⬜ | |
| XP awarded on `POST /v2/quiz/submit` | ⬜ | — | ⬜ | ⬜ | |
| Stage unlock logic in quiz submit service | ⬜ | — | ⬜ | ⬜ | |
| Progress Map screen (scrollable node map) | — | ⬜ | ⬜ | ⬜ | |
| Locked/unlocked stage node states | — | ⬜ | ⬜ | ⬜ | |
| Stage detail bottom sheet | — | ⬜ | ⬜ | ⬜ | |
| Stage unlock celebration animation (Lottie) | — | ⬜ | ⬜ | ⬜ | |
| XP progress bar on home/profile screen | — | ⬜ | ⬜ | ⬜ | |
| `ProgressCubit` | — | ⬜ | ⬜ | ⬜ | |

---

## 4.4 Shareable Score Cards

| Task | API | UI | Test | Prod | Notes |
|---|---|---|---|---|---|
| `screenshot` package added to `pubspec.yaml` | — | ⬜ | — | — | |
| `share_plus` package added | — | ⬜ | — | — | |
| `ResultShareCard` widget | — | ⬜ | ⬜ | ⬜ | Score, rank, category, referral |
| Share button in quiz result screen | — | ⬜ | ⬜ | ⬜ | |
| Share image renders correctly on iOS + Android | — | ⬜ | ⬜ | ⬜ | |

---

## 4.5 Phone Number / OTP Login

| Task | API | UI | Test | Prod | Notes |
|---|---|---|---|---|---|
| Firebase Phone Auth configured (no backend changes needed) | — | — | — | — | Firebase handles OTP |
| `PhoneAuthScreen` (number input + OTP input) | — | ⬜ | ⬜ | ⬜ | |
| Phone auth option on login screen | — | ⬜ | ⬜ | ⬜ | |
| Auth flow: Firebase OTP → existing `POST /v2/auth/login` | — | ⬜ | ⬜ | ⬜ | |
| Duplicate account handling (same phone, different Firebase UID) | ⬜ | ⬜ | ⬜ | ⬜ | |

---

## 4.6 WAEC/JAMB/NECO Content Pack UI

| Task | API | UI | Test | Prod | Notes |
|---|---|---|---|---|---|
| Exam Prep categories tagged in DB | ⬜ | — | — | — | Tag existing questions |
| "Exam Prep" section on home screen | — | ⬜ | ⬜ | ⬜ | |
| Exam type cards (WAEC, NECO, JAMB, BECE) | — | ⬜ | ⬜ | ⬜ | |
| Subject → Topic → Practice Quiz flow | — | ⬜ | ⬜ | ⬜ | |
| Timed practice quiz mode | — | ⬜ | ⬜ | ⬜ | |
| "My weak topics" section (AI-identified) | ⬜ | ⬜ | ⬜ | ⬜ | Phase 6 AI dependency |

---

## 4.7 Mystery Box

| Task | API | UI | Test | Prod | Notes |
|---|---|---|---|---|---|
| Mystery box reward logic in quiz submit service | ⬜ | — | ⬜ | ⬜ | Every 3rd completion |
| Reward probability config in `tbl_settings` | ⬜ | — | — | — | Coins/booster/life/badge |
| Lottie mystery box opening animation | — | ⬜ | ⬜ | ⬜ | |
| Reward reveal screen | — | ⬜ | ⬜ | ⬜ | |
| `MysteryBoxCubit` | — | ⬜ | ⬜ | ⬜ | |

---

## Phase 4 Gate

- [ ] All new features tested on both iOS (TestFlight) and Android (internal track)
- [ ] Lives, coins, and booster counts update in real-time without requiring restart
- [ ] No regression in quiz flow (existing quiz types still work)
- [ ] All new API endpoints covered in Postman collection
- [ ] Crash-free rate maintained ≥ 99.5% after release
