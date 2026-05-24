---
description: "Use when creating or modifying Prisma schema files, database models, or running migrations. Covers model naming, tbl_ prefix mapping, relation definitions, index strategy, and the MySQL-to-PostgreSQL migration path."
applyTo: "**/prisma/schema.prisma"
---

# Prisma Schema Rules

## Naming Conventions

| Prisma | MySQL | Rule |
|---|---|---|
| Model name | table name | PascalCase model → `@@map("tbl_snake_case")` |
| Field name | column name | camelCase field → `@map("snake_case")` |
| Relation field | (no column) | camelCase, no `@map` needed |

```prisma
model LeagueUser {
  id        Int    @id @default(autoincrement())
  leagueId  Int    @map("league_id")       // ← always map snake_case columns
  userId    Int    @map("user_id")

  league    League @relation(fields: [leagueId], references: [id])
  user      User   @relation(fields: [userId], references: [id])

  @@unique([leagueId, userId])
  @@map("tbl_league_user")               // ← always use tbl_ prefix
}
```

## Required for Every Model

- `@id @default(autoincrement())` on the primary key (all existing tables use int PK).
- `@@map("tbl_<name>")` — every model must map to the `tbl_` prefixed table.
- `@map("column_name")` — every field whose Prisma name differs from the MySQL column name.
- Timestamps: use `@default(now())` for `createdAt` and `@updatedAt` for `updatedAt`.

## Status Fields

Existing tables use `Int` status fields (0 = inactive/suspended, 1 = active). Mirror this:

```prisma
status  Int  @default(1)   // 0=inactive, 1=active
```

New tables may use `String` status for richer states:

```prisma
status  String  @default("active") @db.VarChar(20)  // active, suspended, pending
```

## Index Strategy

Add indexes for:
- Foreign key columns used in `WHERE` clauses (Prisma does NOT auto-add FK indexes in MySQL).
- Leaderboard queries: `@@index([leagueId, cumulativeBestScore])`.
- Time-based lookups: `@@index([userId, createdAt])`.
- Soft-delete lookups: `@@index([status])` on large tables.

```prisma
@@index([userId])
@@index([leagueId, userId])
@@index([createdAt])
```

## Json Fields

Use `Json` type for flexible data (answers map, metadata, daily scores). Always document what the JSON contains in a comment:

```prisma
answers         Json?   // { "a": "...", "b": "...", "c": "...", "d": "..." }
dailyBestScores Json?   @map("daily_best_scores") // { "1": 95.5, "2": 88.0, ... }
```

## Datasource Block — Do Not Change Provider

The datasource is MySQL. To migrate to PostgreSQL in the future, only change the `provider` line — all model code stays identical:

```prisma
datasource db {
  provider = "mysql"   // change to "postgresql" only when migrating
  url      = env("DATABASE_URL")
}
```

## Migration Safety

- Never remove a column in Prisma that is still used by the PHP backend (dual-running period).
- Additive changes only during Phase 1–3: add models, add fields, add indexes.
- Column renames require a two-step migration: add new column → backfill → remove old.
- All new tables must include rollback notes in the migration SQL comment header.
