# Phase 6 — Schools, AI & Government Features Checklist

> **Target:** Months 5–9 · Requires Phase 5 (`apps/mobile/`) shipped to both stores first
> **Status key:** ⬜ Not started · 🔄 In progress · ✅ Complete · ❌ Blocked
>
> **Blocker:** Do not start Phase 6 until the new `apps/mobile/` app has been live on both Play Store and App Store for at least 2 weeks with stable crash-free rate.

---

## 6.1 AI Question Generator

| Task | API | Admin UI | Test | Prod | Notes |
|---|---|---|---|---|---|
| `AiGenerationLog` Prisma model + migration | ✅ | — | — | — | |
| OpenAI SDK integrated (`openai` package) | ⬜ | — | — | — | |
| `POST /v2/admin/ai/generate-questions` endpoint | ⬜ | — | ⬜ | ⬜ | |
| Generation prompt tuned for Nigerian curriculum | ⬜ | — | ⬜ | ⬜ | |
| JSON-only response from GPT-4o enforced | ⬜ | — | ⬜ | ⬜ | |
| Token usage logged per generation | ⬜ | — | — | — | |
| Admin: Generate form (subject/topic/level/difficulty/count) | — | ⬜ | ⬜ | ⬜ | |
| Admin: Editable results table pre-save | — | ⬜ | ⬜ | ⬜ | |
| Admin: Approve/reject individual questions | — | ⬜ | ⬜ | ⬜ | |
| Admin: Generation history log with token costs | — | ⬜ | ⬜ | ⬜ | |
| Rate limit: max 5 generation requests/hour per admin | ⬜ | — | ⬜ | — | |
| AI-generated questions default to `status=0` (draft) | ⬜ | — | ⬜ | — | Security |

---

## 6.2 AI Personal Tutor (Wrong Answer Explanation)

| Task | API | Flutter UI | Test | Prod | Notes |
|---|---|---|---|---|---|
| `GET /v2/quiz/explain/:questionId` endpoint | ⬜ | — | ⬜ | ⬜ | GPT-4o-mini |
| Age-appropriate prompt based on user `ageGroup` + `classLevel` | ⬜ | — | ⬜ | ⬜ | |
| Response cached per question + age group | ⬜ | — | ⬜ | ⬜ | Avoid repeat API calls |
| Explanation shown after wrong answer in quiz | — | ⬜ | ⬜ | ⬜ | |
| "AI Tutor explains..." expandable card | — | ⬜ | ⬜ | ⬜ | |
| Explanation only shown for wrong answers | — | ⬜ | ⬜ | ⬜ | |

---

## 6.3 Schools System — Backend

| Task | API | Test | Prod | Notes |
|---|---|---|---|---|
| `School`, `Teacher`, `SchoolClass`, `SchoolStudent`, `Assignment`, `AssignmentResult` Prisma models | ✅ | — | — | Schema in roadmap |
| `POST /v2/schools/register` — school registration | ⬜ | ⬜ | ⬜ | |
| `POST /v2/schools/teachers/invite` — invite teacher | ⬜ | ⬜ | ⬜ | |
| `POST /v2/schools/classes` — create class | ⬜ | ⬜ | ⬜ | |
| `POST /v2/schools/classes/:code/join` — student joins via code | ⬜ | ⬜ | ⬜ | |
| `POST /v2/schools/assignments` — teacher creates assignment | ⬜ | ⬜ | ⬜ | |
| `POST /v2/schools/assignments/:id/submit` — student submits | ⬜ | ⬜ | ⬜ | |
| `GET /v2/schools/assignments/:id/results` — teacher views results | ⬜ | ⬜ | ⬜ | |
| `GET /v2/schools/classes/:id/leaderboard` — class leaderboard | ⬜ | ⬜ | ⬜ | |
| `GET /v2/schools/classes/:id/analytics` — weak topics per student | ⬜ | ⬜ | ⬜ | |
| Multi-tenancy enforced: teachers only see their school's data | ⬜ | ⬜ | — | |

---

## 6.4 Schools System — Admin Panel

| Page | Impl | Test | Notes |
|---|---|---|---|
| Schools list with plan/status | ⬜ | ⬜ | |
| School detail (teachers, classes, students, usage) | ⬜ | ⬜ | |
| School subscription management | ⬜ | ⬜ | |
| Approve school registration | ⬜ | ⬜ | |

---

## 6.5 Schools System — Flutter App

| Screen | Impl | Test | Notes |
|---|---|---|---|
| Teacher dashboard screen | ⬜ | ⬜ | |
| Class list + student count | ⬜ | ⬜ | |
| Create assignment screen | ⬜ | ⬜ | |
| Assignment results view | ⬜ | ⬜ | |
| Class leaderboard | ⬜ | ⬜ | |
| Student: My assignments list | ⬜ | ⬜ | |
| Student: Take assignment quiz | ⬜ | ⬜ | |
| `SchoolCubit` | ⬜ | ⬜ | |

---

## 6.6 Adaptive Learning Engine

| Task | API | Flutter UI | Test | Prod | Notes |
|---|---|---|---|---|---|
| Wrong answer pattern analysis in quiz submit | ⬜ | — | ⬜ | ⬜ | |
| `POST /v2/quiz/recommendations` — weak topic suggestions | ⬜ | — | ⬜ | ⬜ | |
| "My weak topics" section on profile/home | — | ⬜ | ⬜ | ⬜ | |
| Recommended quiz mode based on weak topics | — | ⬜ | ⬜ | ⬜ | |

---

## 6.7 School Subscriptions & Payments

| Task | API | Admin UI | Test | Prod | Notes |
|---|---|---|---|---|---|
| School subscription plans defined in DB | ⬜ | — | — | — | free/basic/premium |
| `POST /v2/payments/school/initialize` | ⬜ | — | ⬜ | ⬜ | |
| Paystack webhook handles school plan activation | ⬜ | — | ⬜ | ⬜ | |
| Plan expiry enforcement on school endpoints | ⬜ | — | ⬜ | ⬜ | |
| Admin: upgrade/downgrade school plan | — | ⬜ | ⬜ | ⬜ | |

---

## Phase 6 Gate

- [ ] AI generation rate limiting tested (cannot exceed quota)
- [ ] AI questions cannot go live without admin approval (`ai_approved = 1`)
- [ ] School multi-tenancy tested: Teacher A cannot see School B's data
- [ ] Assignment submission is idempotent (no duplicate grades)
- [ ] All new endpoints added to Postman collection
- [ ] `npm audit` — zero high/critical vulnerabilities

---

## 6.8 Admin Dashboard & Analytics Enhancements
> *Deferred from Phase 2*

### Backend API additions needed

| Endpoint | Description | API | Admin UI | Notes |
|---|---|---|---|---|
| `GET /v2/admin/analytics/user-growth?days=30` | Daily new-user counts time-series | ⬜ | ⬜ | For user acquisition chart |
| `GET /v2/admin/analytics/retention` | Day 1 / Day 7 / Day 30 cohort retention | ⬜ | ⬜ | |
| `GET /v2/admin/analytics/revenue?days=30` | Daily revenue with provider split (Paystack/Flutterwave) | ⬜ | ⬜ | |
| `GET /v2/admin/analytics/top-categories?limit=10` | Top categories by quiz plays | ⬜ | ⬜ | |
| `GET /v2/admin/analytics/completions?days=30` | Quiz completions per day by mode | ⬜ | ⬜ | |
| `GET /v2/admin/fraud-flags?limit=10&resolved=false` | Latest 10 unresolved fraud flags | ⬜ | ⬜ | Already implemented — just needs `limit` param |
| `GET /v2/leaderboard?country=NG` | Country-filtered leaderboard | ⬜ | — | Deferred from Phase 1 |

### Admin Panel UI additions needed

| Feature | Page | Notes |
|---|---|---|
| DAU / MAU cards wired to stats endpoint | `dashboard/page.tsx` | API returns them; page just needs to display |
| Active contests count card | `dashboard/page.tsx` | API returns `activeContests`; wire display |
| Recent fraud feed (last 10) | `dashboard/page.tsx` | Shows `GET /v2/admin/fraud-flags?limit=10` feed |
| User growth line chart | `analytics/page.tsx` | Recharts LineChart from `user-growth` endpoint |
| Retention curve chart | `analytics/page.tsx` | Bar chart — Day 1 / 7 / 30 columns |
| Revenue breakdown chart | `analytics/page.tsx` | Stacked bar: Paystack vs Flutterwave |
| Top 10 categories pie chart | `analytics/page.tsx` | |
| Quiz completion rate by mode | `analytics/page.tsx` | |
| Country map: users by country | `analytics/page.tsx` | react-simple-maps or Recharts GeoMap |

---

## 6.9 Admin Operations Enhancements
> *Deferred from Phase 2*

| Feature | Page | Backend | Priority | Notes |
|---|---|---|---|---|
| Scheduled notifications (BullMQ) | `notifications/` | `POST /v2/admin/notifications/schedule` | Medium | Requires BullMQ + cron; `scheduledAt` field |
| League prize distribution UI | `leagues/[id]/` | `POST /v2/admin/leagues/:id/distribute` | High | Trigger prize payout to top N finishers |
| Sponsor impression count display | `sponsors/` | Already tracked in `tbl_ad_impressions` | Low | Count per sponsor |
| AI generation history log | `ai-questions/` | `GET /v2/admin/ai-questions/history` | Medium | Token usage, timestamp, category, count |
| AI questions editable table before saving | `ai-questions/` | Existing review flow | Low | In-place editing before approve |
| Questions: Filter by AI-generated flag | `questions/` | Add `?isAiGenerated=true` to endpoint | Low | Filter param |
| Questions: Filter by AI approval status | `questions/` | Add `?aiStatus=pending|approved|rejected` | Low | |
| Questions: Rich text editor (TipTap/Quill) | `questions/new`, `edit` | No backend change | Low | Replace `<Textarea>` |
| Questions: Audio file upload | `questions/new`, `edit` | Requires CDN (S3/Firebase Storage) | Phase 6 gate | Upload + `audio_url` field |
| Categories: Active/inactive toggle | `categories/` | Add `status` column to `tbl_category` (migration) | Medium | |
| Settings: AdMob unit ID config | `settings/` | Already in `tbl_settings` K/V | Low | UI fields for each ad unit ID |
| Sidebar: Role-based item visibility | Layout | No backend change | Low | Hide schools/Phase 6 nav items behind feature flag |
| Dark/light mode | Layout | No backend change | Low | Tailwind `dark:` classes + ThemeProvider |

---

## 6.10 Flutter App v2 Enhancements
> *Deferred from Phase 5 (`apps/mobile/`)*

| Feature | Module | Backend Ready | Priority | Notes |
|---|---|---|---|---|
| Category leaderboard tab | `leaderboard/` | `GET /v2/leaderboard/daily?categoryId=X` (add param) | Medium | Currently only global leaderboard implemented |
| Audio questions | `quiz/` | PHP only — needs NestJS equivalent | High | `type == 'audio'` — `just_audio` already in pubspec |
| Math / LaTeX questions | `quiz/` | PHP only | Medium | `flutter_math_fork` or `flutter_tex` |
| Wrong-answer AI explanation | `quiz/` | `GET /v2/quiz/explain/:questionId` (Phase 6.2) | High | GPT-4o-mini; expandable card after wrong answer |
| Exam Prep section (WAEC/JAMB/NECO) | `home/` | Schools module (Phase 6.3) | High | `_ExamPrepSection` SliverToBoxAdapter on home |
| Student: Take assignment quiz | `quiz/` | Phase 6.3 schools endpoints | High | Reuse quiz engine with assignment context |
| Teacher / student school screens | `schools/` | Phase 6.3 schools endpoints | High | Full `SchoolCubit` + screens |
| `GET /v2/quiz/daily-challenge` → apps/mobile | `home/` | ✅ Endpoint exists | Medium | Wire `DailyChallengeCard` to real daily quiz |
| Adaptive quiz recommendations | `home/profile` | Phase 6.6 | Low | "My weak topics" section |
| In-app notification inbox | `notifications/` | ✅ `GET /v2/notifications` exists | Medium | Bell icon with unread badge |
| Contest detail — entry fee gate | `contests/` | ✅ `POST /v2/contests/:id/submit` exists | Medium | Wire coin deduction before contest entry |

---

## 6.11 PHP Decommission
> *Deferred from Phase 3 (`lib/` app migration)*

> **Context:** `lib/` app continues serving Android users on Play Store. `apps/mobile/` replaces it when live on both stores.

| Task | Status | Dependency |
|---|---|---|
| Flip all `ApiMigration.*` flags to `true` in `lib/` for tested features | ⬜ | Phase 5 stability (2-week live requirement) |
| Auth migration — resolve Firebase token vs `api_token` shape difference | ⬜ | Core blocker for full cutover |
| Leaderboard cubit adapter (PHP `{my_rank, other_users_rank}` → flat NestJS array) | ⬜ | |
| Quiz submit — align payload shape across all quiz types in `lib/` | ⬜ | |
| Lives / boosters / payments wiring in `lib/` | ⬜ | Money-critical — verify coins/payments in production first |
| Specialised quiz fetchers (audio, latex, comprehension, multi-match) | ⬜ | Needs NestJS equivalents (Phase 6.10 audio/math) |
| Remove `lib/` from Play Store after `apps/mobile/` has 2-week stable release | ⬜ | |
| Shut down PHP backend (set maintenance mode, monitor 1 week, then stop) | ⬜ | All features verified production-stable on NestJS |

---

## 6.12 Infrastructure & Security Hardening
> *Deferred from Phases 1–3*

| Task | Priority | Notes |
|---|---|---|
| Referral: IP + device fingerprint logged for fraud detection | High | `POST /v2/referral/apply` — log IP + user-agent |
| Referral: Reward granted only after referee completes first quiz | High | Currently rewards on apply; should gate on first quiz completion |
| `npm audit` — zero high/critical in `apps/api/` + `apps/admin/` | High | Run before Phase 6 deploy |
| PostgreSQL migration (when DAU > 50 k) | When needed | Change `datasource` in `schema.prisma` only |
| Redis cluster / sentinel for production HA | When needed | Currently single Redis instance |
| CDN for question images + audio (S3 or Firebase Storage) | High | Required for audio questions and image upload |
| BullMQ job queue setup (`@nestjs/bull`) | Medium | Required for scheduled notifications |
| `GET /v2/coins/award` HTTP route | Low | Currently internal service method only; expose if partner integration needed |
