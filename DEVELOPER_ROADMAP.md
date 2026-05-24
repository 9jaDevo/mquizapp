# mQuiz Platform v2.0 — Comprehensive Developer Roadmap

> **Document Purpose:** Single source of truth for all developers. Every decision, every phase, every API, every schema.
> **Last Updated:** May 2026
> **Status:** Active — Hybrid Migration Strategy

---

## Table of Contents

1. [Strategic Overview](#1-strategic-overview)
2. [Architecture Decision](#2-architecture-decision)
3. [Technology Stack](#3-technology-stack)
4. [Repository Structure](#4-repository-structure)
5. [Database Strategy: MySQL + Prisma](#5-database-strategy-mysql--prisma)
6. [Prisma Schema (Full)](#6-prisma-schema-full)
7. [Phase 1 — Node.js Backend (Weeks 1–6)](#7-phase-1--nodejs-backend-weeks-16)
8. [Phase 2 — Admin Panel (Weeks 7–10)](#8-phase-2--admin-panel-weeks-710)
9. [Phase 3 — Flutter App Integration (Weeks 11–14)](#9-phase-3--flutter-app-integration-weeks-1114)
10. [Phase 4 — New Features on Existing Flutter App (Weeks 15–22)](#10-phase-4--new-features-on-existing-flutter-app-weeks-1522)
11. [Phase 5 — New Flutter App for Apple Store (Parallel Build)](#11-phase-5--new-flutter-app-for-apple-store-parallel-build)
12. [Phase 6 — School, AI, and Government Features (Months 5–9)](#12-phase-6--school-ai-and-government-features-months-59)
13. [Full API Reference](#13-full-api-reference)
14. [Environment Variables](#14-environment-variables)
15. [Deployment Strategy](#15-deployment-strategy)
16. [PostgreSQL Migration Path](#16-postgresql-migration-path)
17. [Team Roles and Responsibilities](#17-team-roles-and-responsibilities)
18. [Definition of Done Per Phase](#18-definition-of-done-per-phase)

---

## 1. Strategic Overview

### The Problem to Solve

The existing mQuiz app was built on a purchased CodeCanyon script (PHP/CodeIgniter). It has been heavily extended but:
- Apple App Store has rejected it under Guideline 4.3 (binary similarity to template)
- PHP backend is not suitable for AI integration, WebSocket battles, school multi-tenancy, or high-scale analytics
- The platform vision has grown beyond what a template-based app can cleanly support

### The Solution: Hybrid Migration

Rather than discarding 1.5+ years of working features (quiz engine, battle rooms, ads, referrals, leaderboard, leagues), we migrate in layered phases:

```
PHASE 1 → Rebuild backend in Node.js/NestJS (same MySQL DB, Prisma ORM)
PHASE 2 → Build new admin panel in Next.js
PHASE 3 → Point existing Flutter app at new Node.js APIs
PHASE 4 → Add new features to existing Flutter app
PHASE 5 → Build new Flutter app from scratch (Apple Store ready, parallel)
PHASE 6 → Add school, AI, government features to new Flutter app
```

### Why MySQL + Prisma (Not PostgreSQL Yet)

- The existing database is MySQL — keeping it means zero data migration risk during backend transition
- Prisma ORM abstracts the database engine — when ready to move to PostgreSQL, only the `datasource` block in `schema.prisma` changes, and all query code stays identical
- PostgreSQL migration becomes a one-day operation when the time comes (not a multi-month project)
- Trigger the PostgreSQL migration when: DAU > 50,000, analytics queries become slow, or you need full-text search at scale

### Why Keep Firebase

Firebase is NOT replaced. It handles:
- **Firestore**: Real-time battle rooms (bi-directional sync, too costly to rebuild with WebSocket)
- **FCM**: Push notifications (the best push infrastructure available)
- **Firebase Auth**: Token issuance (NestJS will verify these tokens using firebase-admin SDK)

The Node.js backend becomes the REST API layer. Firebase stays the real-time and notification layer.

---

## 2. Architecture Decision

```
┌─────────────────────────────────────────────────────────────┐
│                    CLIENTS                                    │
│  Flutter App (existing)  │  Flutter App v2 (new, Apple)      │
│  Admin Panel (Next.js)   │  School Web Portal (Next.js)      │
└──────────┬───────────────────────────────┬───────────────────┘
           │ REST API calls                │
           │                              │
┌──────────▼───────────────────────────────▼───────────────────┐
│                  Node.js / NestJS API                         │
│                  (Primary backend)                            │
│                                                               │
│  Auth Module    Quiz Module     School Module   AI Module     │
│  User Module    League Module   Payment Module  Admin Module  │
│  Ads Module     Leaderboard     Notification    Analytics     │
└──────────┬───────────────────────────────┬───────────────────┘
           │ Prisma ORM                    │ firebase-admin SDK
           │                              │
┌──────────▼──────────┐   ┌───────────────▼───────────────────┐
│   MySQL Database    │   │         Firebase                   │
│   (Prisma managed)  │   │  Firestore (battles)               │
│                     │   │  FCM (push notifications)          │
│  All existing +     │   │  Auth (token verification)         │
│  new tables         │   └───────────────────────────────────┘
└─────────────────────┘
           │
           │ (Future: change datasource to PostgreSQL)
           ▼
┌─────────────────────┐
│  PostgreSQL (future)│
│  Zero code changes  │
└─────────────────────┘
```

### Transition Bridge: Dual Backend Period (Weeks 1–14)

During migration, the Flutter app uses a config flag to route per-endpoint:

```dart
// lib/core/config/api_config.dart
class ApiConfig {
  // Toggle per endpoint as Node.js APIs become ready
  static const String phpBase = 'https://api.mquiz.uk/php';
  static const String nodeBase = 'https://api.mquiz.uk/v2';

  // Endpoints that have been migrated to Node.js
  static const migratedEndpoints = {
    'login', 'get_profile', 'get_leaderboard', 'get_categories',
    // Add here as Node.js endpoints pass testing
  };

  static String resolveBase(String endpoint) {
    return migratedEndpoints.contains(endpoint) ? nodeBase : phpBase;
  }
}
```

PHP backend stays running and untouched during migration. It is decommissioned after Node.js passes full feature parity testing in Phase 3.

---

## 3. Technology Stack

### Backend
| Layer | Technology | Reason |
|---|---|---|
| Runtime | Node.js 22 LTS | Long-term support, performance |
| Framework | NestJS 11 | Modular, decorator-based, built-in DI, ideal for large apps |
| ORM | Prisma 6 | Type-safe, supports MySQL → PostgreSQL migration with zero code changes |
| Database | MySQL 8 (existing) | Keep existing data, no migration risk |
| Cache | Redis 7 | Leaderboard sorted sets, session cache, rate limiting |
| Real-time | Firebase Firestore | Battle rooms (keep existing Flutter integration) |
| Auth | Firebase Admin SDK | Verify Firebase JWT tokens in NestJS guard |
| Push | Firebase Cloud Messaging | Via firebase-admin in NestJS |
| AI | OpenAI API (GPT-4o) | Question generation, explanations, reports |
| File Storage | Cloudinary or AWS S3 | Question images, avatars, sponsor banners |
| Validation | class-validator + class-transformer | DTOs with automatic validation |
| Documentation | Swagger (@nestjs/swagger) | Auto-generated API docs |

### Frontend — Admin Panel
| Layer | Technology |
|---|---|
| Framework | Next.js 15 (App Router) |
| Styling | Tailwind CSS + shadcn/ui |
| State | Zustand |
| Charts | Recharts |
| Tables | TanStack Table v8 |
| Forms | React Hook Form + Zod |
| HTTP | Axios with interceptors |
| Auth | NextAuth.js with Firebase provider |

### Frontend — Flutter App (Both Existing and New)
| Layer | Technology |
|---|---|
| Framework | Flutter 3.x (Dart 3.x) |
| State | flutter_bloc (Cubit pattern — keep existing) |
| Local Storage | Hive |
| HTTP | Dio (replace http package for better interceptors) |
| Real-time | Firebase Firestore (battles — unchanged) |
| Push | Firebase Messaging (unchanged) |
| Navigation | GoRouter (new app) / existing Navigator (current app) |
| Ads | Google Mobile Ads SDK (AdMob Mediation) |
| Payments | Paystack Flutter SDK |
| Animations | Lottie + Rive |
| Image Capture | screenshot package (share cards) |

### Infrastructure
| Service | Tool |
|---|---|
| Hosting (initial) | Render (low cost, auto-deploy from Git) |
| Hosting (scale) | AWS ECS or DigitalOcean App Platform |
| CI/CD | GitHub Actions |
| Redis | Upstash Redis (serverless, free tier available) |
| Domain | Cloudflare (DNS + CDN + DDoS) |
| Monitoring | Sentry (errors) + Datadog or Grafana (metrics) |
| Secrets | Render env vars → AWS Secrets Manager at scale |

---

## 4. Repository Structure

```
mquiz-platform/
├── apps/
│   ├── api/                        ← NestJS backend
│   │   ├── src/
│   │   │   ├── modules/
│   │   │   │   ├── auth/
│   │   │   │   ├── users/
│   │   │   │   ├── quiz/
│   │   │   │   ├── categories/
│   │   │   │   ├── leaderboard/
│   │   │   │   ├── coins/
│   │   │   │   ├── badges/
│   │   │   │   ├── battle/
│   │   │   │   ├── contest/
│   │   │   │   ├── league/
│   │   │   │   ├── notifications/
│   │   │   │   ├── ads/
│   │   │   │   ├── settings/
│   │   │   │   ├── lives/           ← NEW
│   │   │   │   ├── boosters/        ← NEW
│   │   │   │   ├── progress/        ← NEW
│   │   │   │   ├── ai/              ← NEW
│   │   │   │   ├── schools/         ← NEW
│   │   │   │   ├── payments/        ← NEW
│   │   │   │   └── admin/
│   │   │   ├── common/
│   │   │   │   ├── guards/          ← FirebaseAuthGuard, RolesGuard
│   │   │   │   ├── decorators/      ← @CurrentUser, @Roles
│   │   │   │   ├── filters/         ← Global exception filter
│   │   │   │   ├── interceptors/    ← Response transform, logging
│   │   │   │   └── pipes/           ← Validation pipe
│   │   │   ├── prisma/
│   │   │   │   └── prisma.service.ts
│   │   │   └── main.ts
│   │   ├── prisma/
│   │   │   ├── schema.prisma        ← Single source of truth for DB
│   │   │   └── migrations/         ← Auto-generated by Prisma
│   │   ├── test/
│   │   └── package.json
│   │
│   ├── admin/                       ← Next.js admin panel
│   │   ├── src/
│   │   │   ├── app/                 ← App Router pages
│   │   │   │   ├── (auth)/
│   │   │   │   ├── dashboard/
│   │   │   │   ├── users/
│   │   │   │   ├── questions/
│   │   │   │   ├── categories/
│   │   │   │   ├── quiz/
│   │   │   │   ├── contests/
│   │   │   │   ├── leagues/
│   │   │   │   ├── schools/
│   │   │   │   ├── ai-questions/
│   │   │   │   ├── analytics/
│   │   │   │   ├── sponsors/
│   │   │   │   ├── notifications/
│   │   │   │   └── settings/
│   │   │   ├── components/
│   │   │   ├── lib/
│   │   │   └── hooks/
│   │   └── package.json
│   │
│   └── mobile/                      ← New Flutter app (Apple Store version)
│       ├── lib/
│       └── pubspec.yaml
│
├── packages/
│   └── shared-types/                ← Shared TypeScript types (API contracts)
│
├── .github/
│   └── workflows/
│       ├── api-deploy.yml
│       └── admin-deploy.yml
│
└── package.json                     ← Turbo monorepo root
```

**Use Turborepo** to manage the monorepo:
```bash
npm install turbo --save-dev
```

---

## 5. Database Strategy: MySQL + Prisma

### Initial Setup

```bash
# In apps/api/
npm install prisma @prisma/client
npx prisma init --datasource-provider mysql
```

```prisma
// prisma/schema.prisma
datasource db {
  provider = "mysql"
  url      = env("DATABASE_URL")
}

// DATABASE_URL="mysql://user:password@localhost:3306/mquiz_db"
```

### The Migration Path to PostgreSQL (When Needed)

When DAU exceeds 50,000 or analytics queries slow down:

**Step 1:** Export MySQL data to PostgreSQL using pgloader
```bash
pgloader mysql://user:pass@localhost/mquiz_db postgresql://user:pass@localhost/mquiz_db
```

**Step 2:** Change one line in schema.prisma:
```prisma
datasource db {
  provider = "postgresql"   // ← Only change needed
  url      = env("DATABASE_URL")
}
```

**Step 3:** Run `npx prisma migrate deploy`

**Zero application code changes required.** This is the entire migration.

### Naming Convention

All tables keep the `tbl_` prefix from the existing database to ensure the Node.js backend can run against the same database as PHP during the transition period, with zero conflicts.

---

## 6. Prisma Schema (Full)

This schema covers all existing tables plus all new tables required by the roadmap. It is the single source of truth for the database.

```prisma
// apps/api/prisma/schema.prisma

generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "mysql"
  url      = env("DATABASE_URL")
}

// ============================================================
// EXISTING CORE TABLES (mapped to existing MySQL structure)
// ============================================================

model User {
  id                Int               @id @default(autoincrement())
  firebaseId        String            @unique @map("firebase_id") @db.VarChar(255)
  name              String?           @db.VarChar(255)
  email             String?           @unique @db.VarChar(255)
  mobile            String?           @db.VarChar(20)
  type              String?           @db.VarChar(50) // google, apple, phone, guest
  profile           String?           @db.VarChar(500)
  fcmId             String?           @map("fcm_id") @db.VarChar(500)
  coins             Int               @default(0)
  allTimeScore      Int               @default(0) @map("all_time_score")
  allTimeRank       Int               @default(0) @map("all_time_rank")
  status            Int               @default(1) // 0=suspended, 1=active
  friendsCode       String?           @unique @map("friends_code") @db.VarChar(20)
  appLanguage       String?           @default("english") @map("app_language")
  dateRegistered    DateTime          @default(now()) @map("date_registered")
  lastLoginDate     DateTime?         @map("last_login_date")
  ageGroup          String?           @map("age_group") @db.VarChar(20) // kids, teens, adults, seniors
  classLevel        String?           @map("class_level") @db.VarChar(50)
  countryCode       String?           @map("country_code") @db.VarChar(5)

  // Relations
  badges            UserBadge[]
  bookmarks         Bookmark[]
  dailyStreak       DailyStreak?
  deviceMapping     DeviceMapping[]
  coinHistory       CoinHistory[]
  lives             UserLives?
  boosters          UserBooster[]
  progress          UserProgress?
  leagueUsers       LeagueUser[]
  leagueSubmissions LeagueSubmission[]
  schoolStudent     SchoolStudent?
  teacherProfile    Teacher?
  referrals         Referral[]        @relation("ReferrerRelation")
  referredBy        Referral?         @relation("RefereeRelation")
  fraudDetections   FraudDetection[]
  subscriptions     Subscription[]
  notifications     UserNotification[]

  @@map("tbl_users")
}

model Category {
  id            Int           @id @default(autoincrement())
  categoryName  String        @map("category_name") @db.VarChar(255)
  image         String?       @db.VarChar(500)
  languageId    Int           @default(0) @map("language_id")
  status        Int           @default(1)
  isPremium     Int           @default(0) @map("is_premium")
  maxWinCoins   Int           @default(0) @map("max_win_coins")
  rowOrder      Int           @default(0) @map("row_order")
  dateCreated   DateTime      @default(now()) @map("date_created")

  subcategories Subcategory[]
  questions     Question[]

  @@map("tbl_category")
}

model Subcategory {
  id              Int       @id @default(autoincrement())
  categoryId      Int       @map("category_id")
  subcategoryName String    @map("subcategory_name") @db.VarChar(255)
  image           String?   @db.VarChar(500)
  languageId      Int       @default(0) @map("language_id")
  status          Int       @default(1)
  isPremium       Int       @default(0) @map("is_premium")
  maxWinCoins     Int       @default(0) @map("max_win_coins")
  rowOrder        Int       @default(0) @map("row_order")
  dateCreated     DateTime  @default(now()) @map("date_created")

  category  Category   @relation(fields: [categoryId], references: [id])
  questions Question[]

  @@map("tbl_subcategory")
}

model Question {
  id              Int      @id @default(autoincrement())
  type            Int      @default(1) // 1=quiz_zone, 2=fun_learn, 3=guess_word, 4=audio, 5=math, 6=multimatch
  subtype         Int      @default(0) @map("sub_type")
  categoryId      Int      @default(0) @map("category_id")
  subcategoryId   Int      @default(0) @map("subcategory_id")
  languageId      Int      @default(0) @map("language_id")
  question        String   @db.Text
  answers         String   @db.LongText // JSON: {"a":"...", "b":"...", "c":"...", "d":"..."}
  correctAnswer   String   @map("correct_answer") @db.VarChar(10)
  noteAnswer      String?  @map("note_answer") @db.Text
  audioFile       String?  @map("audio_file") @db.VarChar(500)
  imageFile       String?  @map("image_file") @db.VarChar(500)
  level           Int      @default(1) // 1=easy, 2=medium, 3=hard
  status          Int      @default(1)
  aiGenerated     Int      @default(0) @map("ai_generated")
  aiApproved      Int      @default(0) @map("ai_approved") // 0=pending, 1=approved, 2=rejected
  approvedBy      Int?     @map("approved_by")
  dateCreated     DateTime @default(now()) @map("date_created")

  category    Category?    @relation(fields: [categoryId], references: [id])
  subcategory Subcategory? @relation(fields: [subcategoryId], references: [id])

  @@map("tbl_questions")
}

model Badge {
  id          Int         @id @default(autoincrement())
  name        String      @db.VarChar(255)
  image       String?     @db.VarChar(500)
  type        String      @db.VarChar(50) // streak, score, category, referral, etc.
  condition   Int         @default(0)     // threshold value to earn badge
  status      Int         @default(1)

  userBadges  UserBadge[]

  @@map("tbl_badges")
}

model UserBadge {
  id        Int      @id @default(autoincrement())
  userId    Int      @map("user_id")
  badgeId   Int      @map("badge_id")
  earnedAt  DateTime @default(now()) @map("earned_at")

  user  User  @relation(fields: [userId], references: [id])
  badge Badge @relation(fields: [badgeId], references: [id])

  @@unique([userId, badgeId])
  @@map("tbl_user_badges")
}

model Bookmark {
  id         Int      @id @default(autoincrement())
  userId     Int      @map("user_id")
  questionId Int      @map("question_id")
  createdAt  DateTime @default(now()) @map("created_at")

  user User @relation(fields: [userId], references: [id])

  @@unique([userId, questionId])
  @@map("tbl_bookmark")
}

model DailyStreak {
  id              Int       @id @default(autoincrement())
  userId          Int       @unique @map("user_id")
  lastLoginDate   DateTime? @map("last_login_date") @db.Date
  streakCount     Int       @default(0) @map("streak_count")
  maxStreak       Int       @default(0) @map("max_streak")
  coinEarnedToday Int       @default(0) @map("coin_earned_today")
  createdAt       DateTime  @default(now()) @map("created_at")
  updatedAt       DateTime  @updatedAt @map("updated_at")

  user User @relation(fields: [userId], references: [id])

  @@map("tbl_daily_streak")
}

model CoinHistory {
  id          Int      @id @default(autoincrement())
  userId      Int      @map("user_id")
  coins       Int
  type        String   @db.VarChar(50) // earned, spent, purchased, rewarded, deducted
  source      String   @db.VarChar(100) // quiz_win, daily_streak, referral, booster_purchase, etc.
  description String?  @db.VarChar(255)
  createdAt   DateTime @default(now()) @map("created_at")

  user User @relation(fields: [userId], references: [id])

  @@index([userId])
  @@map("tbl_coin_history")
}

model DeviceMapping {
  id                Int      @id @default(autoincrement())
  userId            Int      @map("user_id")
  deviceId          String   @unique @map("device_id") @db.VarChar(255)
  deviceType        String?  @map("device_type") @db.VarChar(20)
  deviceName        String?  @map("device_name") @db.VarChar(255)
  firstLogin        DateTime @default(now()) @map("first_login")
  lastLogin         DateTime? @map("last_login")
  status            String   @default("active") @db.VarChar(20)
  suspensionReason  String?  @map("suspension_reason") @db.VarChar(255)

  user User @relation(fields: [userId], references: [id])

  @@map("tbl_device_mapping")
}

model FraudDetection {
  id              Int      @id @default(autoincrement())
  userId          Int      @map("user_id")
  detectionType   String   @map("detection_type") @db.VarChar(50)
  reason          String   @db.VarChar(255)
  severity        String   @default("low") @db.VarChar(20)
  actionTaken     String   @default("none") @map("action_taken") @db.VarChar(20)
  metadata        Json?
  resolved        Int      @default(0)
  resolvedAt      DateTime? @map("resolved_at")
  resolutionNotes String?  @map("resolution_notes") @db.VarChar(500)
  createdAt       DateTime @default(now()) @map("created_at")

  user User @relation(fields: [userId], references: [id])

  @@map("tbl_fraud_detection")
}

model Referral {
  id           Int      @id @default(autoincrement())
  referrerId   Int      @map("referrer_id")
  refereeId    Int      @unique @map("referee_id")
  referralCode String   @map("referral_code") @db.VarChar(20)
  rewardGiven  Int      @default(0) @map("reward_given")
  rewardAmount Int      @default(0) @map("reward_amount")
  ipAddress    String?  @map("ip_address") @db.VarChar(50)
  deviceId     String?  @map("device_id") @db.VarChar(255)
  createdAt    DateTime @default(now()) @map("created_at")

  referrer User @relation("ReferrerRelation", fields: [referrerId], references: [id])
  referee  User @relation("RefereeRelation", fields: [refereeId], references: [id])

  @@map("tbl_referrals")
}

model Contest {
  id              Int      @id @default(autoincrement())
  languageId      Int      @default(0) @map("language_id")
  name            String   @db.VarChar(255)
  description     String?  @db.Text
  image           String?  @db.VarChar(500)
  entryCoins      Int      @default(0) @map("entry_coins")
  startDate       DateTime @map("start_date")
  endDate         DateTime @map("end_date")
  status          Int      @default(1)
  prizeStatus     Int      @default(0) @map("prize_status")
  dateCreated     DateTime @default(now()) @map("date_created")

  prizes      ContestPrize[]

  @@map("tbl_contest")
}

model ContestPrize {
  id        Int    @id @default(autoincrement())
  contestId Int    @map("contest_id")
  rank      Int
  prize     Int    @default(0) // coins
  extraPrize String? @map("extra_prize") @db.VarChar(255)

  contest Contest @relation(fields: [contestId], references: [id])

  @@map("tbl_contest_prize")
}

model League {
  id          Int      @id @default(autoincrement())
  languageId  Int      @default(0) @map("language_id")
  name        String   @db.Text
  description String?  @db.Text
  image       String?  @db.VarChar(255)
  startDate   DateTime @map("start_date")
  endDate     DateTime @map("end_date")
  entry       Int      @default(0)
  createdBy   Int      @default(0) @map("created_by")
  prizeStatus Int      @default(0) @map("prize_status")
  status      Int      @default(1)
  dateCreated DateTime @default(now()) @map("date_created")

  leagueUsers       LeagueUser[]
  dailyQuizzes      LeagueDailyQuiz[]
  submissions       LeagueSubmission[]
  leaderboard       LeagueLeaderboard[]

  @@map("tbl_league")
}

model LeagueUser {
  id                   Int       @id @default(autoincrement())
  leagueId             Int       @map("league_id")
  userId               Int       @map("user_id")
  status               String    @default("opt-in") @db.VarChar(20)
  optedInAt            DateTime? @map("opted_in_at")
  coinsPaid            Int       @default(0) @map("coins_paid")
  notificationsEnabled Int       @default(1) @map("notifications_enabled")
  dateCreated          DateTime  @default(now()) @map("date_created")

  league League @relation(fields: [leagueId], references: [id])
  user   User   @relation(fields: [userId], references: [id])

  @@unique([leagueId, userId])
  @@map("tbl_league_user")
}

model LeagueDailyQuiz {
  id            Int      @id @default(autoincrement())
  leagueId      Int      @map("league_id")
  quizDay       Int      @map("quiz_day")
  quizDate      DateTime @map("quiz_date") @db.Date
  questionCount Int      @default(20) @map("question_count")
  dateAssigned  DateTime @default(now()) @map("date_assigned")

  league      League             @relation(fields: [leagueId], references: [id])
  submissions LeagueSubmission[]

  @@unique([leagueId, quizDay])
  @@map("tbl_league_daily_quiz")
}

model LeagueSubmission {
  id              Int      @id @default(autoincrement())
  leagueId        Int      @map("league_id")
  userId          Int      @map("user_id")
  dailyQuizId     Int      @map("daily_quiz_id")
  quizDay         Int      @map("quiz_day")
  score           Float    @default(0)
  correctAnswers  Int      @default(0) @map("correct_answers")
  wrongAnswers    Int      @default(0) @map("wrong_answers")
  totalQuestions  Int      @default(0) @map("total_questions")
  submittedAt     DateTime @default(now()) @map("submitted_at")

  league     League          @relation(fields: [leagueId], references: [id])
  user       User            @relation(fields: [userId], references: [id])
  dailyQuiz  LeagueDailyQuiz @relation(fields: [dailyQuizId], references: [id])

  @@map("tbl_league_submission")
}

model LeagueLeaderboard {
  id                 Int      @id @default(autoincrement())
  leagueId           Int      @map("league_id")
  userId             Int      @map("user_id")
  cumulativeBestScore Float   @default(0) @map("cumulative_best_score")
  dailyBestScores    Json?    @map("daily_best_scores")
  gamesPlayed        Int      @default(0) @map("games_played")
  rank               Int?
  lastUpdated        DateTime @updatedAt @map("last_updated")

  league League @relation(fields: [leagueId], references: [id])

  @@unique([leagueId, userId])
  @@map("tbl_league_leaderboard")
}

model SponsorBanner {
  id                  Int       @id @default(autoincrement())
  sponsorName         String    @map("sponsor_name") @db.VarChar(255)
  title               String?   @db.VarChar(255)
  imageUrl            String?   @map("image_url") @db.VarChar(500)
  redirectUrl         String?   @map("redirect_url") @db.VarChar(500)
  impressionLimit     Int       @default(0) @map("impression_limit")
  currentImpressions  Int       @default(0) @map("current_impressions")
  startDate           DateTime  @map("start_date")
  endDate             DateTime  @map("end_date")
  isActive            Int       @default(1) @map("is_active")
  priority            Int       @default(0)
  createdAt           DateTime  @default(now()) @map("created_at")

  @@map("tbl_sponsor_banners")
}

model SystemSetting {
  id    Int    @id @default(autoincrement())
  title String @unique @db.VarChar(255)
  value String @db.Text

  @@map("tbl_settings")
}

model UserNotification {
  id        Int      @id @default(autoincrement())
  userId    Int      @map("user_id")
  title     String   @db.VarChar(255)
  message   String   @db.Text
  type      String   @db.VarChar(50) // badge, streak, tournament, friend_challenge, score_beaten
  isRead    Int      @default(0) @map("is_read")
  data      Json?
  createdAt DateTime @default(now()) @map("created_at")

  user User @relation(fields: [userId], references: [id])

  @@index([userId, isRead])
  @@map("tbl_notifications")
}

// ============================================================
// NEW TABLES — Lives System
// ============================================================

model UserLives {
  id              Int       @id @default(autoincrement())
  userId          Int       @unique @map("user_id")
  livesCount      Int       @default(5) @map("lives_count")
  maxLives        Int       @default(5) @map("max_lives")
  lastRegenAt     DateTime? @map("last_regen_at")
  nextRegenAt     DateTime? @map("next_regen_at")  // next time a life regenerates
  regenIntervalMin Int      @default(30) @map("regen_interval_min") // minutes per life
  updatedAt       DateTime  @updatedAt @map("updated_at")

  user User @relation(fields: [userId], references: [id])

  @@map("tbl_user_lives")
}

// ============================================================
// NEW TABLES — Boosters System
// ============================================================

model BoosterType {
  id          Int     @id @default(autoincrement())
  name        String  @db.VarChar(100)        // "Fifty-Fifty", "Skip Question", "Freeze Timer"
  code        String  @unique @db.VarChar(50) // "fifty_fifty", "skip", "freeze_timer"
  description String? @db.VarChar(255)
  image       String? @db.VarChar(500)
  coinCost    Int     @default(50) @map("coin_cost")
  status      Int     @default(1)

  userBoosters UserBooster[]

  @@map("tbl_booster_types")
}

model UserBooster {
  id          Int      @id @default(autoincrement())
  userId      Int      @map("user_id")
  boosterId   Int      @map("booster_id")
  quantity    Int      @default(0)
  expiresAt   DateTime? @map("expires_at")
  updatedAt   DateTime  @updatedAt @map("updated_at")

  user    User        @relation(fields: [userId], references: [id])
  booster BoosterType @relation(fields: [boosterId], references: [id])

  @@unique([userId, boosterId])
  @@map("tbl_user_boosters")
}

// ============================================================
// NEW TABLES — Progress Map (Levels & Stages)
// ============================================================

model Stage {
  id          Int     @id @default(autoincrement())
  name        String  @db.VarChar(100) // "Beginner", "Rising Star", etc.
  levelNumber Int     @map("level_number")
  xpRequired  Int     @map("xp_required")   // XP needed to unlock this stage
  image       String? @db.VarChar(500)
  rewardCoins Int     @default(0) @map("reward_coins")
  rewardBadgeId Int?  @map("reward_badge_id")
  status      Int     @default(1)

  userProgress UserProgress[]

  @@map("tbl_stages")
}

model UserProgress {
  id            Int      @id @default(autoincrement())
  userId        Int      @unique @map("user_id")
  currentStageId Int     @map("current_stage_id")
  totalXp       Int      @default(0) @map("total_xp")
  weeklyXp      Int      @default(0) @map("weekly_xp")
  monthlyXp     Int      @default(0) @map("monthly_xp")
  updatedAt     DateTime @updatedAt @map("updated_at")

  user         User  @relation(fields: [userId], references: [id])
  currentStage Stage @relation(fields: [currentStageId], references: [id])

  @@map("tbl_user_progress")
}

// ============================================================
// NEW TABLES — AI Features
// ============================================================

model AiGenerationLog {
  id             Int      @id @default(autoincrement())
  generatedBy    Int      @map("generated_by")    // user_id of teacher or admin
  subject        String?  @db.VarChar(100)
  topic          String?  @db.VarChar(255)
  classLevel     String?  @map("class_level") @db.VarChar(50)
  difficulty     String?  @db.VarChar(20)
  questionsCount Int      @map("questions_count")
  prompt         String?  @db.Text
  outputJson     Json?    @map("output_json")
  tokensUsed     Int?     @map("tokens_used")
  status         String   @default("generated") @db.VarChar(20) // generated, reviewed, approved, rejected
  reviewedBy     Int?     @map("reviewed_by")
  reviewedAt     DateTime? @map("reviewed_at")
  createdAt      DateTime @default(now()) @map("created_at")

  @@map("tbl_ai_generation_logs")
}

// ============================================================
// NEW TABLES — Schools System
// ============================================================

model School {
  id           Int      @id @default(autoincrement())
  name         String   @db.VarChar(255)
  email        String   @unique @db.VarChar(255)
  phone        String?  @db.VarChar(20)
  address      String?  @db.VarChar(500)
  state        String?  @db.VarChar(100)
  country      String?  @default("NG") @db.VarChar(5)
  logo         String?  @db.VarChar(500)
  status       String   @default("active") @db.VarChar(20)
  planType     String   @default("free") @map("plan_type") @db.VarChar(20) // free, basic, premium
  planExpiry   DateTime? @map("plan_expiry")
  createdAt    DateTime @default(now()) @map("created_at")

  teachers     Teacher[]
  classes      SchoolClass[]
  students     SchoolStudent[]
  subscriptions Subscription[]

  @@map("tbl_schools")
}

model Teacher {
  id          Int      @id @default(autoincrement())
  userId      Int      @unique @map("user_id")
  schoolId    Int      @map("school_id")
  subjects    String?  @db.VarChar(500) // comma-separated or JSON array
  role        String   @default("teacher") @db.VarChar(30) // teacher, head_teacher, school_admin
  status      String   @default("active") @db.VarChar(20)
  joinedAt    DateTime @default(now()) @map("joined_at")

  user        User          @relation(fields: [userId], references: [id])
  school      School        @relation(fields: [schoolId], references: [id])
  classes     SchoolClass[]
  assignments Assignment[]

  @@map("tbl_teachers")
}

model SchoolClass {
  id          Int      @id @default(autoincrement())
  schoolId    Int      @map("school_id")
  teacherId   Int      @map("teacher_id")
  name        String   @db.VarChar(100) // "SS2 Science A"
  subject     String?  @db.VarChar(100)
  classCode   String   @unique @map("class_code") @db.VarChar(10) // join code e.g. "MQ-XY23"
  status      String   @default("active") @db.VarChar(20)
  createdAt   DateTime @default(now()) @map("created_at")

  school      School          @relation(fields: [schoolId], references: [id])
  teacher     Teacher         @relation(fields: [teacherId], references: [id])
  students    SchoolStudent[]
  assignments Assignment[]

  @@map("tbl_school_classes")
}

model SchoolStudent {
  id        Int      @id @default(autoincrement())
  userId    Int      @unique @map("user_id")
  schoolId  Int      @map("school_id")
  classId   Int?     @map("class_id")
  studentId String?  @map("student_id") @db.VarChar(50) // school-assigned ID
  joinedAt  DateTime @default(now()) @map("joined_at")

  user    User         @relation(fields: [userId], references: [id])
  school  School       @relation(fields: [schoolId], references: [id])
  class   SchoolClass? @relation(fields: [classId], references: [id])
  assignmentResults AssignmentResult[]

  @@map("tbl_school_students")
}

model Assignment {
  id              Int       @id @default(autoincrement())
  teacherId       Int       @map("teacher_id")
  classId         Int       @map("class_id")
  title           String    @db.VarChar(255)
  categoryId      Int?      @map("category_id")
  questionIds     Json      @map("question_ids") // array of question IDs
  totalQuestions  Int       @map("total_questions")
  timeLimit       Int?      @map("time_limit") // seconds
  dueDate         DateTime? @map("due_date")
  status          String    @default("active") @db.VarChar(20)
  createdAt       DateTime  @default(now()) @map("created_at")

  teacher Teacher    @relation(fields: [teacherId], references: [id])
  class   SchoolClass @relation(fields: [classId], references: [id])
  results AssignmentResult[]

  @@map("tbl_assignments")
}

model AssignmentResult {
  id              Int      @id @default(autoincrement())
  assignmentId    Int      @map("assignment_id")
  studentId       Int      @map("student_id") // SchoolStudent.id
  userId          Int      @map("user_id")
  score           Float    @default(0)
  correctAnswers  Int      @default(0) @map("correct_answers")
  wrongAnswers    Int      @default(0) @map("wrong_answers")
  timeTaken       Int?     @map("time_taken") // seconds
  answers         Json?    // { questionId: chosenAnswer }
  submittedAt     DateTime @default(now()) @map("submitted_at")

  assignment Assignment    @relation(fields: [assignmentId], references: [id])
  student    SchoolStudent @relation(fields: [studentId], references: [id])

  @@unique([assignmentId, userId])
  @@map("tbl_assignment_results")
}

// ============================================================
// NEW TABLES — Subscriptions & Payments
// ============================================================

model Subscription {
  id          Int      @id @default(autoincrement())
  userId      Int?     @map("user_id")
  schoolId    Int?     @map("school_id")
  planId      String   @map("plan_id") @db.VarChar(50) // weekly, monthly, termly, annual, school_basic, school_premium
  status      String   @default("active") @db.VarChar(20)
  startDate   DateTime @map("start_date")
  endDate     DateTime @map("end_date")
  paymentRef  String?  @map("payment_ref") @db.VarChar(255) // Paystack reference
  amountPaid  Float    @map("amount_paid")
  currency    String   @default("NGN") @db.VarChar(5)
  gateway     String   @default("paystack") @db.VarChar(30) // paystack, flutterwave, apple_iap, google_iap
  createdAt   DateTime @default(now()) @map("created_at")

  user   User?   @relation(fields: [userId], references: [id])
  school School? @relation(fields: [schoolId], references: [id])

  @@map("tbl_subscriptions")
}

model PaymentTransaction {
  id          Int      @id @default(autoincrement())
  userId      Int      @map("user_id")
  type        String   @db.VarChar(50) // coin_purchase, subscription, tournament_entry
  amount      Float
  currency    String   @default("NGN") @db.VarChar(5)
  gateway     String   @db.VarChar(30)
  reference   String   @unique @db.VarChar(255)
  status      String   @default("pending") @db.VarChar(20) // pending, success, failed
  metadata    Json?
  createdAt   DateTime @default(now()) @map("created_at")
  updatedAt   DateTime @updatedAt @map("updated_at")

  @@map("tbl_payment_transactions")
}
```

---

## 7. Phase 1 — Node.js Backend ✅ COMPLETE (2026-05-24)

### Week 1 — Project Bootstrap

```bash
# Create NestJS project
npm i -g @nestjs/cli
nest new mquiz-api
cd mquiz-api

# Core dependencies
npm install @prisma/client prisma
npm install @nestjs/config @nestjs/jwt @nestjs/swagger
npm install firebase-admin
npm install class-validator class-transformer
npm install ioredis
npm install bcrypt
npm install openai

# Dev dependencies
npm install -D @types/bcrypt prisma

# Init Prisma
npx prisma init --datasource-provider mysql
```

**Folder structure for src/:**
```
src/
├── main.ts                    ← Bootstrap, global pipes, Swagger
├── app.module.ts              ← Root module
├── prisma/
│   └── prisma.service.ts      ← PrismaClient singleton
├── common/
│   ├── guards/
│   │   ├── firebase-auth.guard.ts
│   │   └── roles.guard.ts
│   ├── decorators/
│   │   ├── current-user.decorator.ts
│   │   └── roles.decorator.ts
│   ├── filters/
│   │   └── http-exception.filter.ts
│   ├── interceptors/
│   │   └── transform.interceptor.ts   ← Wraps all responses in { success, data, message }
│   └── pipes/
│       └── parse-firebase-token.pipe.ts
└── modules/
    └── [feature]/
        ├── [feature].module.ts
        ├── [feature].controller.ts
        ├── [feature].service.ts
        └── dto/
```

### Standard Response Format

All API responses use this envelope (enforced by TransformInterceptor):

```typescript
// Success
{ "success": true, "data": { ... }, "message": "OK" }

// Error
{ "success": false, "error": "ERROR_CODE", "message": "Human readable message" }
```

### Firebase Auth Guard

Every protected route uses this guard. It verifies the Firebase ID token sent in the `Authorization: Bearer <token>` header.

```typescript
// common/guards/firebase-auth.guard.ts
import { Injectable, CanActivate, ExecutionContext, UnauthorizedException } from '@nestjs/common';
import * as admin from 'firebase-admin';

@Injectable()
export class FirebaseAuthGuard implements CanActivate {
  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest();
    const authHeader = request.headers.authorization;

    if (!authHeader?.startsWith('Bearer ')) {
      throw new UnauthorizedException('Missing or invalid token');
    }

    const token = authHeader.split('Bearer ')[1];

    try {
      const decoded = await admin.auth().verifyIdToken(token);
      request.user = decoded; // { uid, email, name, ... }
      return true;
    } catch {
      throw new UnauthorizedException('Invalid Firebase token');
    }
  }
}
```

### Week 2–3 — Auth and User Module

**Auth endpoints:**
```
POST /v2/auth/login          ← Register or login via Firebase token
POST /v2/auth/guest          ← Create guest session
POST /v2/auth/refresh-token  ← Firebase handles token refresh; this just validates
```

**Login flow:**
1. Flutter sends Firebase ID token
2. NestJS verifies with firebase-admin
3. NestJS looks up user by `firebase_id` in DB
4. If not found → create new user record
5. Return user profile + any missing onboarding flags

**User endpoints:**
```
GET  /v2/users/me                    ← Get own profile
PUT  /v2/users/me                    ← Update profile
GET  /v2/users/:id                   ← Get public profile
GET  /v2/users/me/stats              ← Detailed stats (quizzes, accuracy, best category)
GET  /v2/users/me/badges             ← My badges
GET  /v2/users/me/coin-history       ← Coin transaction history
PUT  /v2/users/me/fcm-token          ← Update FCM token
```

### Week 3–4 — Quiz, Categories, Questions

```
GET  /v2/categories                          ← All active categories
GET  /v2/categories/:id/subcategories        ← Subcategories of a category
GET  /v2/questions                           ← Paginated questions (admin)
GET  /v2/quiz/questions                      ← Get questions for a quiz session
     Query params: type, category_id, subcategory_id, language_id, level, limit
POST /v2/quiz/submit                         ← Submit quiz answers + update score/coins/XP
GET  /v2/quiz/daily-challenge                ← Today's daily challenge questions
POST /v2/quiz/daily-challenge/submit         ← Submit daily challenge
GET  /v2/quiz/leaderboard                    ← Global leaderboard
     Query params: period (daily|weekly|monthly|alltime), category_id, country_code
```

### Week 4–5 — Gamification: Coins, Badges, Lives, Boosters, Progress

```
GET  /v2/coins/balance                       ← Current coin balance
POST /v2/coins/award                         ← Internal: award coins (called by quiz submit)
GET  /v2/lives                               ← Current lives + next regen time
POST /v2/lives/use                           ← Deduct one life
POST /v2/lives/restore/ad                    ← Restore life after watching rewarded ad
POST /v2/lives/restore/coins                 ← Restore life using coins
GET  /v2/boosters/types                      ← All available booster types
GET  /v2/boosters/inventory                  ← My booster counts
POST /v2/boosters/purchase                   ← Buy booster with coins
POST /v2/boosters/use                        ← Use a booster in-game
GET  /v2/progress                            ← My current stage + XP + all stages
GET  /v2/progress/stages                     ← All stages (for progress map UI)
```

### Week 5–6 — League, Contest, Referral, Streaks, Notifications

```
GET  /v2/leagues/active                      ← Active leagues
GET  /v2/leagues/:id                         ← League detail
POST /v2/leagues/:id/join                    ← Join/opt-in to league
POST /v2/leagues/:id/submit                  ← Submit daily quiz score
GET  /v2/leagues/:id/leaderboard             ← League leaderboard

GET  /v2/contests/active                     ← Active contests
GET  /v2/contests/:id                        ← Contest detail
POST /v2/contests/:id/enter                  ← Enter contest

GET  /v2/referral/code                       ← My referral code + stats
POST /v2/referral/apply                      ← Apply someone's referral code

GET  /v2/streak                              ← My streak info
POST /v2/streak/check-in                     ← Daily check-in (called at app open)

GET  /v2/notifications                       ← My notifications
PUT  /v2/notifications/:id/read              ← Mark as read
```

### Week 6 — System Config and Ads

```
GET  /v2/config/system                       ← App config (ads type, feature flags, etc.)
GET  /v2/config/languages                    ← Supported app languages
GET  /v2/config/quiz-languages               ← Supported quiz content languages
GET  /v2/ads/sponsor-banners                 ← Active sponsor banners for home screen
POST /v2/ads/banner-click                    ← Record sponsor banner click
```

---

## 8. Phase 2 — Admin Panel (Weeks 7–10)

### Setup

```bash
npx create-next-app@latest mquiz-admin --typescript --tailwind --app
cd mquiz-admin
npx shadcn@latest init
npm install @tanstack/react-table recharts zustand react-hook-form zod axios
```

### Pages and Features

**Dashboard** (`/dashboard`)
- Total users, DAU, MAU
- Revenue today/week/month (coins purchased + subscriptions)
- Active contests, active leagues
- Recent fraud flags
- Charts: user growth, quiz completions per day, top categories

**Users** (`/users`)
- Paginated user table: name, email, coins, score, rank, status, registration date
- Search by name/email/firebase_id
- User detail page: full profile, coin history, badges, quiz history, fraud flags
- Actions: suspend, unsuspend, adjust coins, force badge award

**Questions** (`/questions`)
- Paginated questions table: type, category, level, status
- Filters: category, type, language, level, ai_generated, ai_approval_status
- Create/edit question form: rich text, answer options, correct answer, explanation, image upload
- Bulk CSV import
- AI Question Queue: list of AI-generated questions pending review — approve or reject each one

**Categories** (`/categories`)
- Category list with drag-drop reorder
- Create/edit category: name, image, language, premium flag, max win coins
- Subcategory management within each category

**Contests** (`/contests`)
- Contest list: name, dates, entries, status
- Create/edit contest: name, description, image, entry coins, start/end dates, prizes
- Contest leaderboard with prize distribution action

**Leagues** (`/leagues`)
- League list and management
- Assign daily questions to league days
- League leaderboard with prize distribution

**Schools** (`/schools`)
- School list: name, plan, teacher count, student count
- School detail: teachers, classes, students
- Subscription management per school

**AI Questions** (`/ai-questions`)
- Input form: subject, topic, class level, difficulty, question count
- Send to OpenAI and display generated questions in editable table
- Approve/reject each question before adding to question bank
- Generation history log with token usage

**Sponsor Banners** (`/sponsors`)
- Banner list with preview
- Create/edit banner: title, image upload, redirect URL, date range, priority
- Impression analytics per banner

**Analytics** (`/analytics`)
- User acquisition chart (per day, source: organic/referral/paid)
- Retention curves (Day 1, Day 7, Day 30)
- Revenue breakdown (coins, subscriptions, school plans)
- Top 10 categories by plays
- Quiz completion rates per mode
- Country map: users by country

**Notifications** (`/notifications`)
- Compose push notification: title, body, target (all, segment, specific users)
- Schedule or send immediately
- Delivery status report

**Settings** (`/settings`)
- System config key-value editor (same as `tbl_settings`)
- Feature flags (ads enabled, league enabled, school enabled, etc.)
- Ad network config (AdMob IDs, Unity IDs, etc.)

### Admin Auth

Admin panel uses Firebase Auth with role-based access. Admin users are stored in a separate `tbl_admin_users` table with role field: `super_admin | content_admin | school_admin | finance_admin | support_admin`.

---

## 9. Phase 3 — Flutter App Integration (Weeks 11–14)

### Goal

Point the existing Flutter app at the new Node.js backend, endpoint by endpoint. PHP backend stays running until all endpoints are migrated and tested.

### Step 1: Add Dio and base API service

Replace the current `http` package with `Dio` for better interceptors:

```dart
// lib/core/network/api_client.dart
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ApiClient {
  static const String _nodeBase = 'https://api.mquiz.uk/v2';
  late final Dio _dio;

  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: _nodeBase,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
    ));

    // Attach Firebase token to every request
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final token = await user.getIdToken();
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        // Handle 401 → redirect to login
        if (error.response?.statusCode == 401) {
          // navigate to login
        }
        handler.next(error);
      },
    ));
  }

  Dio get client => _dio;
}
```

### Step 2: Migration Order

Migrate these endpoint groups in this order (each group is a PR, tested before merging):

| Sprint | Endpoints | Risk |
|---|---|---|
| 1 | Auth (login, profile) | High — test thoroughly |
| 2 | Categories, Questions | Medium |
| 3 | Leaderboard, Badges, Streaks | Low |
| 4 | Daily Challenge, Contest | Medium |
| 5 | League | Medium |
| 6 | Coins, Lives, Boosters | High — money involved |
| 7 | Ads config, System config | Low |
| 8 | Notifications | Low |

### Step 3: Decommission PHP

After all endpoints are live on Node.js and tested in production for 2 weeks with zero reported issues:
1. Set PHP backend to maintenance mode
2. Monitor error logs for 1 week
3. Shut down PHP server

---

## 10. Phase 4 — New Features on Existing Flutter App (Weeks 15–22)

### 10.1 Lives System

**UI changes:**
- Add lives counter to home screen header (5 heart icons)
- When life is depleted in quiz: show "You're out of lives" modal with options:
  - Watch ad → restore 1 life (calls `POST /v2/lives/restore/ad`)
  - Use coins → restore 1 life (calls `POST /v2/lives/restore/coins`)
  - Wait → show countdown timer to next regen
- Lives gradually fill up as timer counts down (1 life per 30 minutes)

**Backend integration:** New `UserLives` table, managed by `/v2/lives` endpoints.

### 10.2 Boosters System

**UI changes:**
- Add booster icons to in-quiz screen (bottom row of 4 icons)
- Tapping a booster icon: if inventory > 0, apply effect immediately; if 0, show "buy" sheet
- Booster Store in profile/store screen: list all booster types with coin price
- In result screen: show which boosters were used

**Booster effects in Flutter quiz engine:**
```dart
// lib/features/quiz/models/active_boosters.dart
class ActiveBoosters {
  bool fiftyFiftyUsed = false;
  bool skipUsed = false;
  bool freezeTimerActive = false;
  bool doublePointsActive = false;
  int extraTimeAdded = 0;

  void apply(String boosterCode, QuizState state) {
    switch (boosterCode) {
      case 'fifty_fifty':
        // Remove 2 wrong options from current question UI
        fiftyFiftyUsed = true;
      case 'skip':
        // Auto-advance to next question without penalty
        skipUsed = true;
      case 'freeze_timer':
        // Pause the countdown timer for 15 seconds
        freezeTimerActive = true;
      case 'double_points':
        // Next correct answer worth 2x
        doublePointsActive = true;
    }
  }
}
```

### 10.3 Progress Map

**UI: New "Progress" tab or screen**
- Visual journey: horizontal or vertical scrollable map with stage nodes
- Each node: icon (locked/unlocked), stage name, XP required
- Tap unlocked stage: show stage details, reward already claimed
- Tap locked stage: show XP needed to unlock
- Animated unlock celebration when a new stage is reached

```dart
// lib/features/progress/screens/progress_map_screen.dart
// Uses GET /v2/progress/stages to fetch all stages
// Uses GET /v2/progress to fetch user's current stage + XP
```

### 10.4 Shareable Score Cards

After every quiz result:

```dart
// lib/features/quiz/widgets/result_share_card.dart
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

class ResultShareCard extends StatelessWidget {
  final int score, totalQuestions, rank;
  final String category, referralCode;

  Future<void> shareResult(BuildContext context) async {
    final controller = ScreenshotController();
    final image = await controller.captureFromWidget(
      _buildShareCard(),
    );
    final xFile = XFile.fromData(image, mimeType: 'image/png');
    await Share.shareXFiles(
      [xFile],
      text: 'I scored $score/$totalQuestions in $category on mQuiz! '
            'Can you beat me? Download: https://mquiz.uk/ref/$referralCode',
    );
  }

  Widget _buildShareCard() {
    // Beautiful card with:
    // - mQuiz logo + brand colors
    // - Category name
    // - Score prominently displayed
    // - "Rank #$rank" badge
    // - Referral link at bottom
    // - "Can you beat me?" CTA
  }
}
```

### 10.5 Phone Number / OTP Login

Add phone auth alongside existing Google/Apple login:

```dart
// lib/features/auth/screens/phone_auth_screen.dart
// Uses Firebase Phone Auth (Firebase handles OTP SMS)
// No backend changes needed - Firebase token works the same way
```

### 10.6 WAEC/JAMB Content Pack UI

- Add "Exam Prep" section to home screen
- Within Exam Prep: cards for WAEC, NECO, JAMB, BECE
- Each card leads to subject selection, then topic selection, then timed practice quiz
- "My weak topics" section: AI-identified topics the user keeps getting wrong
- Questions already exist in DB — just needs category/tagging and a dedicated UI flow

### 10.7 Mystery Box

After every 3rd quiz completion, show mystery box animation:

```dart
// Random reward selection:
// 40% chance: coins (random 10-50)
// 25% chance: booster
// 20% chance: extra life
// 10% chance: rare badge
// 5%  chance: tournament ticket
// Uses Lottie animation for box opening
```

---

## 11. Phase 5 — New Flutter App for Apple Store (Parallel Build)

**This runs in parallel with Phase 4. Assign a dedicated sub-team.**

### Why Build Now

- Existing app binary is flagged by Apple (CodeCanyon origin)
- New app = clean binary Apple has never seen
- New app can ship with all Phase 4 features built-in from day one
- New app = opportunity to redesign the full UI to match the roadmap vision

### New App Architecture

```
apps/mobile/
├── lib/
│   ├── main.dart
│   ├── app.dart                    ← MaterialApp + BLoC providers
│   ├── core/
│   │   ├── theme/                  ← New design system (game-like, colorful)
│   │   ├── router/                 ← GoRouter
│   │   ├── network/                ← Dio client → Node.js backend
│   │   ├── constants/
│   │   └── utils/
│   ├── features/
│   │   ├── auth/
│   │   ├── home/
│   │   ├── quiz/
│   │   ├── progress_map/
│   │   ├── lives/
│   │   ├── boosters/
│   │   ├── battle/
│   │   ├── leaderboard/
│   │   ├── profile/
│   │   ├── store/
│   │   ├── achievements/
│   │   ├── schools/               ← Phase 6
│   │   └── ai_tutor/              ← Phase 6
│   └── shared/
│       ├── widgets/
│       └── cubits/
└── pubspec.yaml
```

### New Design System

The new app visually differentiates from the CodeCanyon template. Key design principles:

```dart
// lib/core/theme/app_theme.dart
class MQuizTheme {
  // Primary: Rich Blue-Purple gradient (game-like)
  static const Color primary = Color(0xFF4F46E5);
  static const Color primaryDark = Color(0xFF3730A3);
  static const Color secondary = Color(0xFFF59E0B); // Amber for coins/rewards
  static const Color success = Color(0xFF10B981);   // Green for correct
  static const Color error = Color(0xFFEF4444);     // Red for wrong
  static const Color background = Color(0xFF0F0F1A); // Dark game background

  // Fonts: Nunito (rounded, friendly, readable for all ages)
  static const String fontFamily = 'Nunito';

  // Each category has its own color identity
  static const categoryColors = {
    'football': Color(0xFF10B981),
    'bible': Color(0xFFF59E0B),
    'mathematics': Color(0xFF6366F1),
    'jamb': Color(0xFFEC4899),
    // ...
  };
}
```

### Apple App Store Submission Checklist

Before submitting:
- [ ] New Bundle ID registered: `com.mquiz.learn` (or similar — not the old one)
- [ ] New Firebase project with new `GoogleService-Info.plist`
- [ ] New AdMob App ID registered
- [ ] All screens fully functional (Apple tests comprehensively)
- [ ] Privacy Policy URL live at `https://mquiz.uk/privacy`
- [ ] Age rating: 4+ (if no user-generated content) or 9+ (with leaderboards)
- [ ] All in-app purchase products registered in App Store Connect
- [ ] App Preview video recorded (30–60 seconds, shows actual gameplay)
- [ ] 6.5-inch and 5.5-inch screenshots prepared (show new game-like UI)
- [ ] App Store Connect description: lead with "AI-powered exam practice" (EdTech positioning)
- [ ] Review notes to Apple: explain WAEC/JAMB functionality and educational purpose

---

## 12. Phase 6 — School, AI, and Government Features (Months 5–9)

### 12.1 AI Question Generator

```typescript
// apps/api/src/modules/ai/ai.service.ts
async generateQuestions(dto: GenerateQuestionsDto): Promise<GeneratedQuestion[]> {
  const prompt = `
    Generate ${dto.count} multiple-choice quiz questions for:
    - Subject: ${dto.subject}
    - Topic: ${dto.topic}
    - Class Level: ${dto.classLevel} (Nigerian curriculum)
    - Difficulty: ${dto.difficulty} (easy/medium/hard)
    - Language: Simple, clear English suitable for Nigerian students

    For each question, return:
    {
      "question": "...",
      "options": { "a": "...", "b": "...", "c": "...", "d": "..." },
      "correct_answer": "a" | "b" | "c" | "d",
      "explanation": "Short, encouraging explanation of why the answer is correct",
      "difficulty": "easy" | "medium" | "hard",
      "topic_tag": "..."
    }

    Return a JSON array only. No extra text.
  `;

  const response = await this.openai.chat.completions.create({
    model: 'gpt-4o',
    messages: [{ role: 'user', content: prompt }],
    response_format: { type: 'json_object' },
    max_tokens: 4000,
  });

  const parsed = JSON.parse(response.choices[0].message.content);

  // Log generation for admin review queue
  await this.prisma.aiGenerationLog.create({
    data: {
      generatedBy: dto.requestingUserId,
      subject: dto.subject,
      topic: dto.topic,
      classLevel: dto.classLevel,
      questionsCount: dto.count,
      outputJson: parsed,
      tokensUsed: response.usage.total_tokens,
    },
  });

  return parsed.questions;
}
```

### 12.2 AI Personal Tutor (Wrong Answer Explanation)

After a user answers a question incorrectly:

```typescript
async explainAnswer(questionId: number, wrongAnswer: string, userId: number) {
  const question = await this.prisma.question.findUnique({
    where: { id: questionId },
  });

  const user = await this.prisma.user.findUnique({
    where: { id: userId },
    select: { ageGroup: true, classLevel: true },
  });

  const prompt = `
    A student answered a quiz question incorrectly.

    Question: ${question.question}
    Their answer: ${wrongAnswer}
    Correct answer: ${question.correctAnswer}
    Existing explanation: ${question.noteAnswer}

    The student is: ${user.ageGroup || 'general'} (${user.classLevel || ''})

    Give a SHORT (2-3 sentences max), encouraging, age-appropriate explanation.
    Start with acknowledging it's a common mistake, then explain why the correct answer is right.
    Use simple, friendly language. No bullet points.
  `;

  const response = await this.openai.chat.completions.create({
    model: 'gpt-4o-mini', // cheaper for per-question explanations
    messages: [{ role: 'user', content: prompt }],
    max_tokens: 200,
  });

  return response.choices[0].message.content;
}
```

### 12.3 School Dashboard in Flutter App

New section in the app for users who are teachers or school admins:

```dart
// lib/features/schools/screens/teacher_dashboard_screen.dart
// Shows:
// - My classes (list)
// - Per class: student count, average score, weak topics
// - Assignments: active/past
// - Quick action: "Create Assignment" button
// - Class leaderboard

// lib/features/schools/screens/create_assignment_screen.dart
// Teacher selects: class, category/subject, question count, time limit, due date
// Can use AI to generate questions or pick from question bank
```

### 12.4 Adaptive Learning Engine

After each quiz session, analyze performance and generate recommendations:

```typescript
// apps/api/src/modules/quiz/quiz.service.ts (in submit quiz handler)
async analyzeAndRecommend(userId: number, sessionAnswers: AnswerDto[]) {
  // 1. Identify wrong answers
  const wrongQuestions = sessionAnswers.filter(a => !a.isCorrect);

  // 2. Get topic tags for wrong questions
  const weakTopics = await this.prisma.question.findMany({
    where: { id: { in: wrongQuestions.map(q => q.questionId) } },
    select: { categoryId: true, subcategoryId: true, level: true },
  });

  // 3. Find more questions on those weak topics
  const recommendations = await this.prisma.question.findMany({
    where: {
      categoryId: { in: weakTopics.map(t => t.categoryId) },
      status: 1,
    },
    take: 10,
    orderBy: { level: 'asc' }, // start easier for weak topics
  });

  // 4. Store as "recommended questions" for the user's next session
  return recommendations;
}
```

### 12.5 Paystack Integration

```typescript
// apps/api/src/modules/payments/paystack.service.ts
async initializeTransaction(userId: number, amount: number, type: string) {
  const reference = `MQ_${userId}_${Date.now()}`;

  const response = await axios.post(
    'https://api.paystack.co/transaction/initialize',
    {
      email: user.email,
      amount: amount * 100, // Paystack uses kobo
      reference,
      metadata: { userId, type, platform: 'mobile' },
    },
    { headers: { Authorization: `Bearer ${process.env.PAYSTACK_SECRET_KEY}` } },
  );

  // Save pending transaction
  await this.prisma.paymentTransaction.create({
    data: { userId, type, amount, currency: 'NGN', gateway: 'paystack', reference, status: 'pending' },
  });

  return { authorizationUrl: response.data.data.authorization_url, reference };
}

// Webhook handler (Paystack posts here on payment success)
async handleWebhook(event: PaystackEvent) {
  if (event.event === 'charge.success') {
    const { reference, metadata } = event.data;

    // Verify with Paystack (never trust webhook alone)
    const verified = await this.verifyTransaction(reference);

    if (verified) {
      // Mark transaction as success
      await this.prisma.paymentTransaction.update({
        where: { reference },
        data: { status: 'success' },
      });

      // Fulfill: award coins or activate subscription
      if (metadata.type === 'coin_purchase') {
        await this.coinsService.awardCoins(metadata.userId, metadata.coinsAmount);
      } else if (metadata.type === 'subscription') {
        await this.subscriptionService.activate(metadata.userId, metadata.planId);
      }
    }
  }
}
```

---

## 13. Full API Reference

All endpoints require `Authorization: Bearer <firebase_id_token>` unless marked `[PUBLIC]`.

### Authentication
| Method | Endpoint | Description |
|---|---|---|
| POST | /v2/auth/login | Register or login |
| POST | /v2/auth/guest | Create guest session |

### Users
| Method | Endpoint | Description |
|---|---|---|
| GET | /v2/users/me | Own profile |
| PUT | /v2/users/me | Update profile |
| GET | /v2/users/:id | Public profile |
| GET | /v2/users/me/stats | Detailed statistics |
| GET | /v2/users/me/badges | My badges |
| GET | /v2/users/me/coin-history | Coin transactions |
| PUT | /v2/users/me/fcm-token | Update push token |

### Categories & Questions
| Method | Endpoint | Description |
|---|---|---|
| GET | /v2/categories | [PUBLIC] All categories |
| GET | /v2/categories/:id/subcategories | [PUBLIC] Subcategories |
| GET | /v2/quiz/questions | Get quiz questions |
| POST | /v2/quiz/submit | Submit answers |
| GET | /v2/quiz/daily-challenge | Today's challenge |
| POST | /v2/quiz/daily-challenge/submit | Submit challenge |

### Gamification
| Method | Endpoint | Description |
|---|---|---|
| GET | /v2/coins/balance | Current balance |
| GET | /v2/lives | Lives + regen timer |
| POST | /v2/lives/use | Deduct 1 life |
| POST | /v2/lives/restore/ad | Restore after ad |
| POST | /v2/lives/restore/coins | Restore with coins |
| GET | /v2/boosters/types | All booster types |
| GET | /v2/boosters/inventory | My booster counts |
| POST | /v2/boosters/purchase | Buy booster |
| POST | /v2/boosters/use | Use booster |
| GET | /v2/progress | My stage + XP |
| GET | /v2/progress/stages | All stages map |

### Social & Competition
| Method | Endpoint | Description |
|---|---|---|
| GET | /v2/leaderboard | Global leaderboard |
| GET | /v2/leagues/active | Active leagues |
| GET | /v2/leagues/:id | League detail |
| POST | /v2/leagues/:id/join | Join league |
| POST | /v2/leagues/:id/submit | Submit score |
| GET | /v2/leagues/:id/leaderboard | League ranking |
| GET | /v2/contests/active | Active contests |
| POST | /v2/contests/:id/enter | Enter contest |
| GET | /v2/referral/code | My referral code |
| POST | /v2/referral/apply | Apply referral code |
| GET | /v2/streak | My streak |
| POST | /v2/streak/check-in | Daily check-in |

### Notifications
| Method | Endpoint | Description |
|---|---|---|
| GET | /v2/notifications | My notifications |
| PUT | /v2/notifications/:id/read | Mark read |
| PUT | /v2/notifications/read-all | Mark all read |

### System
| Method | Endpoint | Description |
|---|---|---|
| GET | /v2/config/system | [PUBLIC] App config |
| GET | /v2/config/languages | [PUBLIC] App languages |
| GET | /v2/config/quiz-languages | [PUBLIC] Quiz languages |
| GET | /v2/ads/sponsor-banners | Active banners |
| POST | /v2/ads/banner-click | Record click |

### AI Features
| Method | Endpoint | Description |
|---|---|---|
| POST | /v2/ai/generate-questions | Generate questions (teacher/admin) |
| POST | /v2/ai/explain-answer | Get explanation for wrong answer |
| GET | /v2/ai/recommendations | Personalized quiz recommendations |

### Schools
| Method | Endpoint | Description |
|---|---|---|
| POST | /v2/schools/register | Register school |
| GET | /v2/schools/me | My school info |
| GET | /v2/schools/classes | My classes (teacher) |
| POST | /v2/schools/classes | Create class |
| POST | /v2/schools/classes/:id/join | Join class (student, by code) |
| GET | /v2/schools/classes/:id/students | Class students |
| GET | /v2/schools/classes/:id/stats | Class performance stats |
| POST | /v2/schools/assignments | Create assignment |
| GET | /v2/schools/assignments | My assignments |
| POST | /v2/schools/assignments/:id/submit | Submit assignment |
| GET | /v2/schools/assignments/:id/results | Assignment results (teacher) |

### Payments
| Method | Endpoint | Description |
|---|---|---|
| POST | /v2/payments/initialize | Start payment (Paystack) |
| POST | /v2/payments/verify/:reference | Verify payment |
| POST | /v2/payments/webhook | Paystack webhook [PUBLIC, validated by signature] |
| GET | /v2/payments/history | My payment history |
| GET | /v2/subscriptions/me | My active subscription |

### Admin (role-protected)
| Method | Endpoint | Description |
|---|---|---|
| GET | /v2/admin/users | All users |
| PUT | /v2/admin/users/:id/suspend | Suspend user |
| PUT | /v2/admin/users/:id/coins | Adjust user coins |
| GET | /v2/admin/questions | All questions |
| POST | /v2/admin/questions | Create question |
| PUT | /v2/admin/questions/:id | Update question |
| GET | /v2/admin/ai-queue | AI questions pending review |
| PUT | /v2/admin/ai-queue/:id/approve | Approve AI question |
| PUT | /v2/admin/ai-queue/:id/reject | Reject AI question |
| GET | /v2/admin/analytics/overview | Dashboard stats |
| POST | /v2/admin/notifications/broadcast | Send push to all/segment |

---

## 14. Environment Variables

```env
# apps/api/.env

# Database (MySQL initially, change to PostgreSQL URL when migrating)
DATABASE_URL="mysql://mquiz_user:strongpassword@localhost:3306/mquiz_db"

# Firebase
FIREBASE_PROJECT_ID="your-project-id"
FIREBASE_CLIENT_EMAIL="firebase-adminsdk-xxxxx@your-project.iam.gserviceaccount.com"
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"

# Redis
REDIS_URL="redis://localhost:6379"
# For Upstash: REDIS_URL="rediss://default:token@endpoint.upstash.io:6380"

# OpenAI
OPENAI_API_KEY="sk-..."
OPENAI_MODEL="gpt-4o"
OPENAI_MINI_MODEL="gpt-4o-mini"

# Paystack
PAYSTACK_SECRET_KEY="sk_live_..."
PAYSTACK_PUBLIC_KEY="pk_live_..."
PAYSTACK_WEBHOOK_SECRET="whsec_..."

# Cloudinary (file uploads)
CLOUDINARY_CLOUD_NAME="mquiz"
CLOUDINARY_API_KEY="..."
CLOUDINARY_API_SECRET="..."

# App
PORT=3000
NODE_ENV="production"
APP_URL="https://api.mquiz.uk"
JWT_SECRET="use-a-long-random-string-here"

# Admin panel URL (for CORS)
ADMIN_URL="https://admin.mquiz.uk"
MOBILE_APP_BUNDLE="com.mquiz.learn"
```

---

## 15. Deployment Strategy

### Initial Deployment (Low Cost, Fast Setup)

**Backend:** Render.app
- Connect GitHub repo, Render auto-deploys on push to `main`
- Add MySQL addon (existing vps server managed MySQL)
- Set environment variables in Render dashboard
- Custom domain: `api.mquiz.uk` → Render app URL
- Cost: ~$7/month to start

**Admin Panel:** Vercel
- Connect GitHub repo, Vercel auto-deploys Next.js
- Custom domain: `admin.mquiz.uk`
- Cost: Free tier covers early stage

**File Storage:** Cloudinary
- Free tier: 25GB storage, 25GB bandwidth/month
- Upgrade as needed

### Production CI/CD (GitHub Actions)

```yaml
# .github/workflows/api-deploy.yml
name: Deploy API

on:
  push:
    branches: [main]
    paths: ['apps/api/**']

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '22'
      - run: cd apps/api && npm ci
      - run: cd apps/api && npm run build
      - run: cd apps/api && npx prisma migrate deploy
        env:
          DATABASE_URL: ${{ secrets.DATABASE_URL }}
      - name: Deploy to Railway
        run: railway up
        env:
          RAILWAY_TOKEN: ${{ secrets.RAILWAY_TOKEN }}
```

### Scale-Up Path (When DAU > 10,000)

1. Move from Render to AWS ECS (containerized NestJS)
2. Move MySQL to AWS RDS Multi-AZ
3. Move Redis to AWS ElastiCache
4. Add CloudFront CDN for API caching
5. This is the same point to evaluate PostgreSQL migration

---

## 16. PostgreSQL Migration Path

When to migrate:
- DAU consistently > 50,000
- Analytics queries taking > 2 seconds
- Need advanced full-text search
- Need JSON operations at scale (JSONB)

**The migration takes approximately 4–8 hours of downtime (or zero downtime with careful planning).**

### Migration Steps

**Step 1:** Provision PostgreSQL (AWS RDS, Supabase, or Neon)

**Step 2:** Export data using pgloader
```bash
# Install pgloader
sudo apt-get install pgloader

# Create migration config
cat > migrate.load << EOF
LOAD DATABASE
  FROM mysql://user:pass@mysql-host/mquiz_db
  INTO postgresql://user:pass@pg-host/mquiz_db

WITH include drop, create tables, create indexes, reset sequences

ALTER SCHEMA 'mquiz_db' RENAME TO 'public';
EOF

pgloader migrate.load
```

**Step 3:** Change one line in schema.prisma
```prisma
datasource db {
  provider = "postgresql"  // ← Only change
  url      = env("DATABASE_URL")
}
```

**Step 4:** Update DATABASE_URL in env:
```
DATABASE_URL="postgresql://user:pass@pg-host:5432/mquiz_db"
```

**Step 5:** Run `npx prisma migrate deploy`

**Step 6:** Run test suite. Deploy.

**Zero application code changes.** All Prisma queries work identically.

---

## 17. Team Roles and Responsibilities

| Role | Responsibilities | Phase Focus |
|---|---|---|
| **Backend Lead** | NestJS API, Prisma schema, business logic, security | Phase 1, 6 |
| **Backend Dev** | Module implementation, API endpoints, tests | Phase 1, 3 |
| **Frontend Lead (Flutter)** | Architecture, state management, API integration | Phase 3, 4 |
| **Flutter Dev** | Feature screens, UI components | Phase 4, 5 |
| **Flutter Dev (Apple)** | New Flutter app, iOS-specific features | Phase 5 |
| **Frontend Lead (Web)** | Next.js admin panel architecture | Phase 2 |
| **Web Dev** | Admin panel pages, components | Phase 2, 6 |
| **AI/ML Dev** | OpenAI integration, prompt engineering, adaptive logic | Phase 6 |
| **DevOps** | CI/CD, Railway/AWS setup, monitoring | All phases |
| **QA** | Test plans, API testing (Postman), Flutter widget tests | All phases |
| **Product Owner** | Requirements, sprint planning, UAT | All phases |

### Recommended Team Size Per Phase

- **Phase 1–2 (Backend + Admin):** 3–4 developers (2 backend, 1–2 web)
- **Phase 3–4 (Flutter integration + new features):** 4–5 developers (2 backend, 2–3 Flutter)
- **Phase 5 (New Flutter app):** 2–3 dedicated Flutter developers (parallel)
- **Phase 6 (AI + Schools):** 5–6 developers (1 AI specialist, 2 backend, 2 Flutter, 1 web)

---

## 18. Definition of Done Per Phase

### Phase 1 — Done When: ✅ COMPLETE (2026-05-24)
- [x] All NestJS modules created with full test coverage (61/61 unit tests + 2/2 E2E tests)
- [x] Prisma schema matches existing MySQL structure with no data loss
- [x] Firebase auth guard working for all protected endpoints
- [x] Swagger documentation auto-generated and accessible at `/api/docs`
- [x] All endpoints returning standard response envelope
- [x] Redis caching implemented for leaderboard queries
- [x] Rate limiting applied to auth and AI endpoints
- [ ] Deployed to Railway with SSL
- [x] Postman collection exported with all endpoints (83 requests)

### Phase 2 — Done When:
- [ ] All admin panel pages functional
- [ ] Admin auth with role-based page access
- [ ] AI question approval workflow complete
- [ ] Sponsor banner management complete
- [ ] Analytics dashboard showing real data
- [ ] Deployed to Vercel with SSL

### Phase 3 — Done When:
- [ ] All PHP endpoints have Node.js equivalents passing identical responses
- [ ] Flutter app feature-flagged to use Node.js endpoints
- [ ] 2 weeks of parallel running with zero regression reported
- [ ] PHP backend decommissioned
- [ ] All Flutter cubits/repositories pointing to Node.js API

### Phase 4 — Done When:
- [ ] Lives system live in existing app
- [ ] Boosters purchasable and usable in quiz
- [ ] Progress map screen live
- [ ] Share cards generating and shareable
- [ ] Phone/OTP login functional
- [ ] WAEC/JAMB content pack accessible
- [ ] Mystery box triggering after every 3rd quiz

### Phase 5 — Done When:
- [ ] New Flutter app compiles clean with no references to old codebase
- [ ] New bundle ID registered, new Firebase project configured
- [ ] All Phase 4 features included in new app from day one
- [ ] Apple App Store submission passes review
- [ ] Google Play submission passes review

### Phase 6 — Done When:
- [ ] AI question generation live in admin panel and teacher dashboard
- [ ] AI answer explanation shown to user after wrong answer
- [ ] School registration and teacher onboarding flow live
- [ ] Student class-join-by-code working
- [ ] Assignment creation and submission working
- [ ] Paystack coin purchase and subscription working
- [ ] Pilot with 5 schools completed and feedback collected

---

*This document is the single source of truth. All PRs, sprints, and architecture decisions reference this document. Update this document when major decisions change.*
