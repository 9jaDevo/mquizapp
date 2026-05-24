# Phase 6 — Schools, AI & Government Features Checklist

> **Target:** Months 5–9 · Requires Phase 1–3 complete
> **Status key:** ⬜ Not started · 🔄 In progress · ✅ Complete · ❌ Blocked

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
