# mQuiz Platform — Master Progress Checklist

> **How to use:** Update status emoji as work progresses. Link to the phase-specific checklist for details.
> **Status key:** ⬜ Not started · 🔄 In progress · ✅ Complete · ❌ Blocked

---

## Phase Overview

| Phase | Scope | Status | Checklist | Target |
|---|---|---|---|---|
| Phase 1 | NestJS API Backend | ⬜ | [PHASE_1_API_CHECKLIST.md](PHASE_1_API_CHECKLIST.md) | Weeks 1–6 |
| Phase 2 | Next.js Admin Panel | ⬜ | [PHASE_2_ADMIN_CHECKLIST.md](PHASE_2_ADMIN_CHECKLIST.md) | Weeks 7–10 |
| Phase 3 | Flutter → Node.js Migration | ⬜ | [PHASE_3_FLUTTER_CHECKLIST.md](PHASE_3_FLUTTER_CHECKLIST.md) | Weeks 11–14 |
| Phase 4 | New Features (Existing App) | ⬜ | [PHASE_4_FEATURES_CHECKLIST.md](PHASE_4_FEATURES_CHECKLIST.md) | Weeks 15–22 |
| Phase 5 | New Flutter App (Apple Store) | ⬜ | [PHASE_5_NEW_APP_CHECKLIST.md](PHASE_5_NEW_APP_CHECKLIST.md) | Parallel |
| Phase 6 | Schools, AI, Government | ⬜ | [PHASE_6_SCHOOLS_AI_CHECKLIST.md](PHASE_6_SCHOOLS_AI_CHECKLIST.md) | Months 5–9 |

---

## Phase 1 API — Module Summary

| Module | Endpoints | Impl | Tests | Postman |
|---|---|---|---|---|
| Bootstrap (common infrastructure) | Guards, interceptors, filters | ⬜ | ⬜ | — |
| Auth | 3 | ⬜ | ⬜ | ⬜ |
| Users | 7 | ⬜ | ⬜ | ⬜ |
| Categories | 2 | ⬜ | ⬜ | ⬜ |
| Questions | 1 | ⬜ | ⬜ | ⬜ |
| Quiz | 4 | ⬜ | ⬜ | ⬜ |
| Leaderboard | 1 | ⬜ | ⬜ | ⬜ |
| Coins | 2 | ⬜ | ⬜ | ⬜ |
| Lives | 4 | ⬜ | ⬜ | ⬜ |
| Boosters | 4 | ⬜ | ⬜ | ⬜ |
| Progress | 2 | ⬜ | ⬜ | ⬜ |
| League | 5 | ⬜ | ⬜ | ⬜ |
| Contest | 3 | ⬜ | ⬜ | ⬜ |
| Referral | 2 | ⬜ | ⬜ | ⬜ |
| Streak | 2 | ⬜ | ⬜ | ⬜ |
| Notifications | 2 | ⬜ | ⬜ | ⬜ |
| Config | 3 | ⬜ | ⬜ | ⬜ |
| Ads | 2 | ⬜ | ⬜ | ⬜ |
| Payments | 4 | ⬜ | ⬜ | ⬜ |
| Admin (API) | 12+ | ⬜ | ⬜ | ⬜ |

---

## Phase 2 Admin — Page Summary

| Page | Features | Status | Tests |
|---|---|---|---|
| Auth (login) | Firebase sign-in, role check | ⬜ | ⬜ |
| Dashboard | KPIs, charts, fraud feed | ⬜ | ⬜ |
| Users | Table, search, detail, actions | ⬜ | ⬜ |
| Questions | Table, filters, create/edit, CSV, AI queue | ⬜ | ⬜ |
| Categories | List, drag-drop, subcategories | ⬜ | ⬜ |
| Contests | List, create/edit, leaderboard | ⬜ | ⬜ |
| Leagues | List, daily quiz assign, leaderboard | ⬜ | ⬜ |
| AI Questions | Generate form, review queue, history | ⬜ | ⬜ |
| Sponsor Banners | List, preview, create/edit, analytics | ⬜ | ⬜ |
| Analytics | All charts and retention curves | ⬜ | ⬜ |
| Notifications | Compose, schedule, delivery report | ⬜ | ⬜ |
| Settings | System config editor, feature flags | ⬜ | ⬜ |
| Schools | List, detail, subscriptions | ⬜ | ⬜ |

---

## Phase 3 Flutter Migration — Sprint Summary

| Sprint | Endpoint Group | Status | PHP Decommissioned |
|---|---|---|---|
| 1 | Auth, Profile | ⬜ | ⬜ |
| 2 | Categories, Questions | ⬜ | ⬜ |
| 3 | Leaderboard, Badges, Streaks | ⬜ | ⬜ |
| 4 | Daily Challenge, Contest | ⬜ | ⬜ |
| 5 | League | ⬜ | ⬜ |
| 6 | Coins, Lives, Boosters | ⬜ | ⬜ |
| 7 | Ads config, System config | ⬜ | ⬜ |
| 8 | Notifications | ⬜ | ⬜ |

---

## Definition of Done (All Phases)

A feature is **Done** only when ALL of the following are true:

- [ ] Code implemented and reviewed
- [ ] Unit tests written and passing (minimum: service layer)
- [ ] Integration/E2E tests passing for the endpoint
- [ ] Postman collection updated with the new request(s)
- [ ] API response shape verified against `{ success, data, message }` envelope
- [ ] Security audit checklist passed (auth guard, validation, ownership check)
- [ ] No high/critical `npm audit` vulnerabilities introduced
- [ ] Phase checklist row marked ✅

> Manual verification via Postman is a **secondary confirmation step** — automated tests are the gate.

---

## Postman Collection

Location: [`postman/mQuiz_API.postman_collection.json`](../../postman/mQuiz_API.postman_collection.json)

Import into Postman along with the environment file:
[`postman/mQuiz_Dev.postman_environment.json`](../../postman/mQuiz_Dev.postman_environment.json)

**Update the collection every time an endpoint is completed.** Postman is the manual verification and client integration reference.
