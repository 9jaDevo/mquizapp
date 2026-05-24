# Phase 2 — Next.js Admin Panel Checklist

> **Target:** Weeks 7–10 · Location: `apps/admin/src/`
> **Status key:** ⬜ Not started · 🔄 In progress · ✅ Complete · ❌ Blocked
>
> **Columns:** `Impl` = page/component merged · `Test` = component/integration tests passing · `Auth` = role guard verified · `Resp` = responsive layout verified

---

## 0. Bootstrap & Shared Infrastructure

| Task | Impl | Test | Notes |
|---|---|---|---|
| Next.js 15 project init (`apps/admin/`) | ⬜ | — | App Router |
| Tailwind CSS + shadcn/ui configured | ⬜ | — | |
| TanStack Table v8 installed | ⬜ | — | |
| React Hook Form + Zod installed | ⬜ | — | |
| Axios client with auth interceptor | ⬜ | ⬜ | Attaches Firebase token |
| NextAuth.js with Firebase provider | ⬜ | ⬜ | |
| Admin role check middleware | ⬜ | ⬜ | Block non-admin on all pages |
| Shared `DataTable` component | ⬜ | ⬜ | Reused across all list pages |
| Shared `PageHeader` + breadcrumb component | ⬜ | — | |
| Sidebar nav with role-based item visibility | ⬜ | ⬜ | |
| Dark/light mode support | ⬜ | — | |
| `loading.tsx` + `error.tsx` skeleton pattern | ⬜ | — | On all pages |

---

## 1. Auth Pages (`app/(auth)/`)

| Page/Component | Impl | Test | Auth | Resp | Notes |
|---|---|---|---|---|---|
| `/login` — Firebase Google sign-in | ⬜ | ⬜ | — | ⬜ | |
| Role verification on sign-in (redirect non-admins) | ⬜ | ⬜ | ⬜ | — | |
| `/unauthorized` — blocked role page | ⬜ | — | — | ⬜ | |

---

## 2. Dashboard (`app/dashboard/`)

| Feature | Impl | Test | Auth | Resp | Notes |
|---|---|---|---|---|---|
| Total users KPI card | ⬜ | ⬜ | ⬜ | ⬜ | `GET /v2/admin/analytics/dashboard` |
| DAU / MAU KPI cards | ⬜ | ⬜ | ⬜ | ⬜ | |
| Revenue today/week/month KPI cards | ⬜ | ⬜ | ⬜ | ⬜ | |
| Active contests count | ⬜ | ⬜ | ⬜ | ⬜ | |
| Active leagues count | ⬜ | ⬜ | ⬜ | ⬜ | |
| Recent fraud flags feed (last 10) | ⬜ | ⬜ | ⬜ | ⬜ | |
| User growth line chart (Recharts) | ⬜ | ⬜ | ⬜ | ⬜ | |
| Quiz completions per day bar chart | ⬜ | ⬜ | ⬜ | ⬜ | |
| Top 5 categories pie chart | ⬜ | ⬜ | ⬜ | ⬜ | |

---

## 3. Users (`app/users/`)

| Feature | Impl | Test | Auth | Resp | Notes |
|---|---|---|---|---|---|
| Users list page with paginated table | ⬜ | ⬜ | ⬜ | ⬜ | `GET /v2/admin/users` |
| Search by name / email / firebase_id | ⬜ | ⬜ | ⬜ | ⬜ | |
| Filter by status (active/suspended) | ⬜ | ⬜ | ⬜ | ⬜ | |
| User detail page (`/users/[id]`) | ⬜ | ⬜ | ⬜ | ⬜ | |
| — Full profile section | ⬜ | ⬜ | ⬜ | ⬜ | |
| — Coin history tab | ⬜ | ⬜ | ⬜ | ⬜ | |
| — Badges tab | ⬜ | ⬜ | ⬜ | ⬜ | |
| — Fraud flags tab | ⬜ | ⬜ | ⬜ | ⬜ | |
| Action: Suspend user (with confirmation dialog) | ⬜ | ⬜ | ⬜ | ⬜ | `PATCH /v2/admin/users/:id/suspend` |
| Action: Unsuspend user | ⬜ | ⬜ | ⬜ | ⬜ | |
| Action: Adjust coins (with reason field) | ⬜ | ⬜ | ⬜ | ⬜ | `PATCH /v2/admin/users/:id/coins` |

---

## 4. Questions (`app/questions/`)

| Feature | Impl | Test | Auth | Resp | Notes |
|---|---|---|---|---|---|
| Questions list with paginated table | ⬜ | ⬜ | ⬜ | ⬜ | `GET /v2/admin/questions` |
| Filter: category, type, language, level | ⬜ | ⬜ | ⬜ | ⬜ | |
| Filter: AI-generated flag | ⬜ | ⬜ | ⬜ | ⬜ | |
| Filter: AI approval status | ⬜ | ⬜ | ⬜ | ⬜ | |
| Create question form (`/questions/new`) | ⬜ | ⬜ | ⬜ | ⬜ | `POST /v2/admin/questions` |
| — Rich text question input | ⬜ | ⬜ | ⬜ | ⬜ | |
| — 4 answer options with correct answer selector | ⬜ | ⬜ | ⬜ | ⬜ | |
| — Explanation / note answer field | ⬜ | ⬜ | ⬜ | ⬜ | |
| — Image upload (category/question image) | ⬜ | ⬜ | ⬜ | ⬜ | |
| — Audio upload for audio questions | ⬜ | ⬜ | ⬜ | ⬜ | |
| Edit question form (`/questions/[id]/edit`) | ⬜ | ⬜ | ⬜ | ⬜ | `PUT /v2/admin/questions/:id` |
| Soft delete question | ⬜ | ⬜ | ⬜ | ⬜ | Confirmation dialog required |
| Bulk CSV import page | ⬜ | ⬜ | ⬜ | ⬜ | `POST /v2/admin/questions/import` |
| AI Question Review Queue | ⬜ | ⬜ | ⬜ | ⬜ | `GET /v2/admin/ai-questions/pending` |
| — Approve individual AI question | ⬜ | ⬜ | ⬜ | ⬜ | |
| — Reject AI question with reason | ⬜ | ⬜ | ⬜ | ⬜ | |

---

## 5. Categories (`app/categories/`)

| Feature | Impl | Test | Auth | Resp | Notes |
|---|---|---|---|---|---|
| Categories list with drag-drop reorder | ⬜ | ⬜ | ⬜ | ⬜ | |
| Create category form | ⬜ | ⬜ | ⬜ | ⬜ | |
| Edit category form | ⬜ | ⬜ | ⬜ | ⬜ | |
| Toggle category status (active/inactive) | ⬜ | ⬜ | ⬜ | ⬜ | |
| Toggle premium flag | ⬜ | ⬜ | ⬜ | ⬜ | |
| Subcategory management section | ⬜ | ⬜ | ⬜ | ⬜ | |

---

## 6. Contests (`app/contests/`)

| Feature | Impl | Test | Auth | Resp | Notes |
|---|---|---|---|---|---|
| Contests list table | ⬜ | ⬜ | ⬜ | ⬜ | |
| Create contest form | ⬜ | ⬜ | ⬜ | ⬜ | Dates, coins, prizes |
| Edit contest | ⬜ | ⬜ | ⬜ | ⬜ | |
| Contest leaderboard view + prize distribution action | ⬜ | ⬜ | ⬜ | ⬜ | Confirmation required |

---

## 7. Leagues (`app/leagues/`)

| Feature | Impl | Test | Auth | Resp | Notes |
|---|---|---|---|---|---|
| Leagues list table | ⬜ | ⬜ | ⬜ | ⬜ | |
| Create league form | ⬜ | ⬜ | ⬜ | ⬜ | |
| Edit league | ⬜ | ⬜ | ⬜ | ⬜ | |
| Assign daily quiz questions to league days | ⬜ | ⬜ | ⬜ | ⬜ | |
| League leaderboard + prize distribution | ⬜ | ⬜ | ⬜ | ⬜ | |

---

## 8. AI Questions (`app/ai-questions/`)

| Feature | Impl | Test | Auth | Resp | Notes |
|---|---|---|---|---|---|
| Generate form: subject, topic, class level, difficulty, count | ⬜ | ⬜ | ⬜ | ⬜ | |
| Call AI endpoint and display results in editable table | ⬜ | ⬜ | ⬜ | ⬜ | |
| Approve/reject per question before bulk save | ⬜ | ⬜ | ⬜ | ⬜ | |
| Generation history log (token usage, timestamp) | ⬜ | ⬜ | ⬜ | ⬜ | |

---

## 9. Sponsor Banners (`app/sponsors/`)

| Feature | Impl | Test | Auth | Resp | Notes |
|---|---|---|---|---|---|
| Banners list with image preview | ⬜ | ⬜ | ⬜ | ⬜ | |
| Create banner form (title, image, URL, dates, priority) | ⬜ | ⬜ | ⬜ | ⬜ | |
| Edit banner | ⬜ | ⬜ | ⬜ | ⬜ | |
| Impression count display per banner | ⬜ | ⬜ | ⬜ | ⬜ | |

---

## 10. Analytics (`app/analytics/`)

| Feature | Impl | Test | Auth | Resp | Notes |
|---|---|---|---|---|---|
| User acquisition chart (per day, source) | ⬜ | ⬜ | ⬜ | ⬜ | |
| Retention curve (Day 1, 7, 30) | ⬜ | ⬜ | ⬜ | ⬜ | |
| Revenue breakdown chart | ⬜ | ⬜ | ⬜ | ⬜ | |
| Top 10 categories by plays | ⬜ | ⬜ | ⬜ | ⬜ | |
| Quiz completion rate by mode | ⬜ | ⬜ | ⬜ | ⬜ | |
| Country map: users by country | ⬜ | ⬜ | ⬜ | ⬜ | |

---

## 11. Notifications (`app/notifications/`)

| Feature | Impl | Test | Auth | Resp | Notes |
|---|---|---|---|---|---|
| Compose form: title, body, target segment | ⬜ | ⬜ | ⬜ | ⬜ | |
| Schedule or send immediately | ⬜ | ⬜ | ⬜ | ⬜ | |
| Sent notifications history | ⬜ | ⬜ | ⬜ | ⬜ | |

---

## 12. Settings (`app/settings/`)

| Feature | Impl | Test | Auth | Resp | Notes |
|---|---|---|---|---|---|
| System config key-value editor | ⬜ | ⬜ | ⬜ | ⬜ | `tbl_settings` |
| Feature flags toggle (ads, leagues, schools) | ⬜ | ⬜ | ⬜ | ⬜ | |
| Ad network config (AdMob IDs, etc.) | ⬜ | ⬜ | ⬜ | ⬜ | |

---

## 13. Schools (`app/schools/`)

> Phase 6 dependency — implement shell now, content in Phase 6

| Feature | Impl | Test | Auth | Resp | Notes |
|---|---|---|---|---|---|
| Schools list table | ⬜ | ⬜ | ⬜ | ⬜ | |
| School detail page (teachers, classes, students) | ⬜ | ⬜ | ⬜ | ⬜ | |
| Subscription management per school | ⬜ | ⬜ | ⬜ | ⬜ | |

---

## Phase 2 Gate — Must Pass Before Phase 3

- [ ] All pages accessible only to authenticated admin users
- [ ] Non-admin Firebase users redirected to `/unauthorized`
- [ ] All forms have client-side Zod validation
- [ ] All server components use `fetch` with proper cache tags
- [ ] All destructive actions (suspend, delete, prize distribution) have confirmation dialogs
- [ ] Responsive layout verified on mobile viewport (1024px min for admin is acceptable)
- [ ] `npm audit` — zero high/critical vulnerabilities
- [ ] All API calls use the Axios interceptor (no hardcoded tokens)
