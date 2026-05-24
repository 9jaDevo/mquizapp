# Skill: php-to-nestjs-migration

Use this skill when migrating a specific PHP/CodeIgniter endpoint from `admin_backend/application/controllers/Api.php` to the NestJS backend at `apps/api/`. Ensures response shape compatibility, auth parity, and safe dual-running.

## Steps

### Step 1 — Read the PHP Endpoint

Locate the PHP method in `admin_backend/application/controllers/Api.php`.

Identify:
- Method name and HTTP verb (all PHP methods are POST in the existing API)
- Input fields read from `$this->input->post()`
- Auth mechanism (`verify_token()` call?)
- DB queries: which tables, joins, conditions
- Response shape: `error`, `message`, `data` fields returned
- Any business logic (coin award, score calculation, fraud check)

### Step 2 — Map to NestJS Structure

| PHP | NestJS |
|---|---|
| `$this->input->post('field')` | DTO field with `@IsString()` / `@IsInt()` |
| `verify_token()` | `@UseGuards(FirebaseAuthGuard)` |
| `$this->db->query(...)` | `this.prisma.model.findMany(...)` |
| `echo json_encode(['error' => 0, 'message' => '...', 'data' => [...]])` | `return data` (TransformInterceptor wraps it) |

Note: The PHP API uses `error: 0` for success, `error: 1` for failure. The NestJS API uses `success: true/false`. The Flutter app must handle both during Phase 3 dual-running. Use the `ApiConfig.resolveBase()` method to route to the correct backend per endpoint.

### Step 3 — Create the NestJS Endpoint

Follow the full steps in the `nestjs-module-generator` skill if the module doesn't exist yet. If the module exists, add the new endpoint to the existing controller and service.

Critical: **Produce an identical data shape for the `data` field** to avoid breaking the Flutter app. If the PHP response returns `user_name`, the NestJS response must also return `user_name` (not `userName`).

### Step 4 — Add to Migration Tracking

Add the endpoint to the migration list in `DEVELOPER_ROADMAP.md` Section 9 (Phase 3 Migration Order table):
- Mark the sprint it belongs to
- Note the risk level (auth-sensitive = High, read-only = Low)

### Step 5 — Update Flutter ApiConfig

Once the endpoint is live and tested, add it to `migratedEndpoints` in `lib/core/config/api_config.dart`:

```dart
static const migratedEndpoints = {
  // previously migrated...
  'new_endpoint_name',  // ← add here
};
```

### Step 6 — Dual-Run Validation

Before decommissioning the PHP endpoint:
- [ ] NestJS endpoint returns identical `data` shape as PHP
- [ ] Auth behavior is identical (same fields required/optional)
- [ ] Coin and score changes produce identical DB results
- [ ] Run the same Postman request against both backends and diff the responses
- [ ] Flutter app tested against NestJS endpoint for this feature

## Validation Checklist

- [ ] PHP endpoint fully read and understood before writing NestJS code
- [ ] Response `data` shape is backward-compatible
- [ ] DTO validates all fields PHP was `$this->input->post()`-ing
- [ ] Auth guard applied if PHP called `verify_token()`
- [ ] Endpoint added to `migratedEndpoints` only after testing
- [ ] No PHP endpoint modified during migration
