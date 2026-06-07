# mQuiz Platform

mQuiz is a hybrid migration workspace for a gamified quiz platform. The repository contains the legacy PHP backend, the new NestJS API, the Next.js admin panel, Flutter apps, and the public website that support the ongoing rebuild.

## What is in this repo

- `apps/api/` - New NestJS backend API
- `apps/admin/` - Next.js admin panel
- `apps/mobile/` - New Flutter app in progress
- `lib/` - Existing Flutter app codebase
- `admin_backend/` - Legacy CodeIgniter backend, kept as a production reference during migration
- `website/` - Public marketing / blog website

## Stack

- Backend: Node.js 22, NestJS 11, Prisma 6, MySQL 8
- Admin: Next.js 15, React 19, Tailwind CSS, shadcn/ui
- Mobile: Flutter 3.x, Cubit / BLoC, Firebase, Dio
- Infra and services: Firebase Auth, Firestore, FCM, Redis, OpenAI, Paystack, Cloudinary

## Getting started

This repository is a monorepo-style workspace, so each app has its own install and run commands.

### NestJS API

```bash
cd apps/api
npm install
npm run start:dev
```

### Next.js admin panel

```bash
cd apps/admin
npm install
npm run dev
```

### Public website

```bash
cd website
npm install
npm run dev
```

### Flutter apps

```bash
flutter pub get
flutter run
```

Use the app folder you are actively working in before running the Flutter command if you are targeting `apps/mobile/` or the root Flutter app.

## Environment files

- Do not commit `.env` files or production secrets.
- The API production env file is ignored by git and should stay local.
- Keep shared examples as `.env.example` files when you need to document required variables.

## Key docs

- [Developer roadmap](DEVELOPER_ROADMAP.md)
- [Quick start](QUICK_START.md)
- [Implementation index](IMPLEMENTATION_INDEX.md)
- [API quick reference](API_QUICK_REFERENCE.md)

## Notes

- The legacy backend under `admin_backend/` is treated as read-only unless a task explicitly asks for a change there.
- This repo is mid-migration, so not every feature lives in one stack yet.
