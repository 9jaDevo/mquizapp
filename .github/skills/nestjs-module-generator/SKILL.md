# Skill: nestjs-module-generator

Use this skill when implementing a complete, production-ready NestJS feature module for the mQuiz API. Covers the full lifecycle: Prisma model → DTO validation → service → controller → module registration → tests.

## Steps

### Step 1 — Verify Prisma Model Exists

Check `apps/api/prisma/schema.prisma` for the relevant model. If it doesn't exist:
- Add the model following the rules in `.github/instructions/prisma-schema.instructions.md`
- Run `npx prisma generate` after schema change
- Create a migration SQL file following `.github/instructions/database-migrations.instructions.md`

### Step 2 — Create DTOs

In `src/modules/<feature>/dto/`:
- `create-<feature>.dto.ts` — all required fields with `class-validator` decorators
- `update-<feature>.dto.ts` — `PartialType(Create<feature>Dto)`
- For query params: `filter-<feature>.dto.ts` with `@IsOptional()` on all fields

### Step 3 — Create Service

In `src/modules/<feature>/<feature>.service.ts`:
- Inject `PrismaService` only — no direct DB calls elsewhere
- `findAll(userId, filters?)` — paginated, filtered list
- `findOne(id, userId?)` — single record with ownership check where required
- `create(userId, dto)` — validate, create, return created record
- `update(id, userId, dto)` — ownership check, partial update
- Use `prisma.$transaction` for multi-table writes
- Log errors with `Logger`

### Step 4 — Create Controller

In `src/modules/<feature>/<feature>.controller.ts`:
- `@Controller('v2/<feature>')` with `@UseGuards(FirebaseAuthGuard)` at class level
- Routes delegate immediately to service — no logic in controller
- Use `@CurrentUser()` for user identity
- Add `@ApiTags('<feature>')` and `@ApiBearerAuth()` for Swagger

### Step 5 — Create Module

In `src/modules/<feature>/<feature>.module.ts`:
- Import `PrismaModule`
- Provide the service
- Register the controller

### Step 6 — Register in AppModule

Add `<Feature>Module` to the `imports` array in `src/app.module.ts`.

### Step 7 — Write Service Tests

In `src/modules/<feature>/<feature>.service.spec.ts`:
- Mock `PrismaService` using `jest.mock`
- Test: `findAll` returns filtered list
- Test: `findOne` throws `NotFoundException` for missing ID
- Test: `create` calls Prisma with correct payload
- Test: ownership check rejects wrong user

## Validation Checklist

- [ ] Prisma model has `@@map("tbl_<name>")` and all fields have `@map()`
- [ ] All DTO fields have `class-validator` decorators
- [ ] Controller has `FirebaseAuthGuard`
- [ ] Service does not expose Prisma errors directly
- [ ] Module is registered in `app.module.ts`
- [ ] At least 3 service unit tests pass
- [ ] Swagger decorators are present on controller
