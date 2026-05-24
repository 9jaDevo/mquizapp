---
description: "Use when creating or modifying NestJS backend code: controllers, services, modules, guards, DTOs, interceptors, or any file in apps/api/src/. Covers module structure, Prisma usage, auth, validation, response format, and error handling."
applyTo: "**/apps/api/src/**/*.ts"
---

# NestJS Backend Rules

## Module Structure

Every feature module must have exactly these files:

```
src/modules/feature/
├── feature.module.ts       ← imports PrismaModule, registers controller + service
├── feature.controller.ts   ← route handlers only, no business logic
├── feature.service.ts      ← all business logic and Prisma queries
└── dto/
    ├── create-feature.dto.ts
    └── update-feature.dto.ts
```

## Controller Rules

- Controllers only: extract params, call service, return result.
- Always annotate with `@UseGuards(FirebaseAuthGuard)` unless the endpoint is explicitly public.
- Use `@CurrentUser() user: DecodedIdToken` — never read user identity from request body.
- Decorate public endpoints with `@Public()` and `@Throttle({ default: { limit: 30, ttl: 60000 } })`.

```typescript
@Controller('v2/feature')
@UseGuards(FirebaseAuthGuard)
export class FeatureController {
  constructor(private readonly featureService: FeatureService) {}

  @Get()
  async getAll(@CurrentUser() user: DecodedIdToken) {
    return this.featureService.findAll(user.uid);
  }

  @Post()
  async create(
    @CurrentUser() user: DecodedIdToken,
    @Body() dto: CreateFeatureDto,
  ) {
    return this.featureService.create(user.uid, dto);
  }
}
```

## DTO Rules

- Use `class-validator` decorators on every field — no unvalidated properties.
- Use `@IsOptional()` for optional fields; don't make everything required.
- Never use `any` type in DTOs.

```typescript
import { IsString, IsInt, IsOptional, MinLength, Max, Min } from 'class-validator';

export class CreateQuizSubmitDto {
  @IsInt()
  @Min(1)
  questionId: number;

  @IsString()
  @MinLength(1)
  answer: string;

  @IsOptional()
  @IsInt()
  @Min(0)
  timeTaken?: number;
}
```

## Service Rules

- All Prisma calls are in services, never controllers.
- Wrap multi-step writes in `prisma.$transaction([...])`.
- Use `prisma.model.findUniqueOrThrow()` when the record must exist — let Prisma throw, catch it in the filter.
- Never expose raw Prisma errors to the client — let `HttpExceptionFilter` handle them.
- Log unexpected errors with NestJS `Logger`, not `console.log`.

```typescript
@Injectable()
export class FeatureService {
  private readonly logger = new Logger(FeatureService.name);

  constructor(private readonly prisma: PrismaService) {}

  async findAll(firebaseUid: string) {
    const user = await this.prisma.user.findUniqueOrThrow({
      where: { firebaseId: firebaseUid },
    });
    return this.prisma.feature.findMany({
      where: { userId: user.id, status: 1 },
      orderBy: { createdAt: 'desc' },
    });
  }
}
```

## Prisma Usage

- Use `select` to return only needed fields — never return password-equivalent fields.
- Use `include` for relations only when the caller actually needs the related data.
- Add `skip` + `take` to any list query that could return unbounded rows.
- Always filter by `status: 1` for user-facing content unless fetching admin data.

## Error Handling

- Throw `NotFoundException`, `BadRequestException`, `ForbiddenException`, `UnauthorizedException` from `@nestjs/common`.
- Never throw `Error` directly — use the NestJS HTTP exceptions.
- The global `HttpExceptionFilter` wraps all errors in `{ success: false, error: "CODE", message: "..." }`.

## Security Checklist for Every New Endpoint

- [ ] Protected by `FirebaseAuthGuard` or explicitly marked `@Public()`
- [ ] Input validated by a DTO with `class-validator`
- [ ] Rate limiting applied (especially for auth, AI, payment endpoints)
- [ ] User identity derived from verified token, not request body
- [ ] No raw SQL strings anywhere
- [ ] Sensitive fields excluded from response (`select` on Prisma queries)
- [ ] Paystack/payment webhooks verify HMAC signature before any logic runs

## Definition of Done — Every Endpoint

An endpoint is **not complete** until ALL of the following are checked off:

1. **Unit test** written in `*.service.spec.ts` — at minimum: happy path + 1 error case
2. **E2E/integration test** in `test/` using supertest — verifies HTTP status and response shape
3. **Postman collection updated** — add or update the request in `postman/mQuiz_API.postman_collection.json`
   - Include example request body
   - Include a test script that verifies `success: true` and key `data` fields
4. **Phase checklist updated** — mark `Impl ✅`, `Unit ✅`, `E2E ✅`, `PM ✅` in `docs/checklists/PHASE_1_API_CHECKLIST.md`
5. Manual Postman run passes (secondary confirmation only — NOT a substitute for automated tests)

> Never mark a row ✅ in the checklist if automated tests do not exist. Manual testing is a verification step, not the gate.
