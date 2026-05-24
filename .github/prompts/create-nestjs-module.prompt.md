---
description: "Scaffold a complete NestJS feature module with controller, service, DTOs, and module file following mQuiz conventions."
---

Scaffold a complete NestJS feature module for the mQuiz API at `apps/api/src/modules/${input:moduleName}`.

The module name is: **${input:moduleName}**
Brief description of what this module does: **${input:description}**

## What to Generate

Create these files:

1. **`${input:moduleName}.module.ts`** — imports `PrismaModule`, registers the service and controller.

2. **`${input:moduleName}.controller.ts`** — route prefix `v2/${input:moduleName}`. Include:
   - `@UseGuards(FirebaseAuthGuard)` at class level
   - A `GET /` list endpoint
   - A `GET /:id` detail endpoint
   - A `POST /` create endpoint using the create DTO

3. **`${input:moduleName}.service.ts`** — depends on `PrismaService`. Include:
   - `private readonly logger = new Logger(${input:moduleName}Service.name)`
   - Stub implementations for findAll, findOne, and create methods

4. **`dto/create-${input:moduleName}.dto.ts`** — at least 2 example fields with `class-validator` decorators appropriate to the description.

5. **`dto/update-${input:moduleName}.dto.ts`** — extends `PartialType(Create${input:moduleName}Dto)`.

## Conventions to Follow

- All responses go through `TransformInterceptor` — return plain objects from service, not wrapped envelopes.
- Throw `NotFoundException` from service when a record is not found.
- All Prisma queries go in the service, never the controller.
- Use `@CurrentUser() user: DecodedIdToken` for authenticated user identity.
- The Prisma model name will be inferred from the module name (PascalCase).

## After Generating Files

Remind me to:
1. Add `${input:moduleName}Module` to the imports array in `app.module.ts`.
2. Run `npx prisma generate` if a new Prisma model was added.
3. Write at least one test for the service.
