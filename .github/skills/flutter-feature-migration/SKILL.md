# Skill: flutter-feature-migration

Use this skill when connecting an existing Flutter feature to the new Node.js backend, replacing its PHP API calls without breaking current user experience.

## Steps

### Step 1 — Identify the Feature's API Layer

Find all files in `lib/` that make HTTP calls for this feature:
- Repository files (`*_repository.dart` or `*_datasource.dart`)
- Any cubit that directly calls `http` or `dio`
- Network response model files that parse the PHP response shape

Note the current base URL, endpoint path, request fields, and response fields used.

### Step 2 — Verify the NestJS Endpoint Exists

Check `DEVELOPER_ROADMAP.md` → Section 13 (Full API Reference) for the Node.js equivalent endpoint.

If it doesn't exist yet, pause and implement it using the `nestjs-module-generator` skill first.

Verify response shape compatibility:
- The Node.js API returns `{ success: true, data: {...} }`.
- The Flutter code currently parses `{ error: 0, message: "...", data: {...} }`.
- Update the response parsing in the repository to handle the new envelope.

### Step 3 — Update the Repository

Change the repository to use the shared `ApiClient` (Dio) and parse the new response envelope:

```dart
// Before (PHP endpoint)
final response = await http.post(Uri.parse('$baseUrl/api/get_leagues'));
final json = jsonDecode(response.body);
if (json['error'] == 0) { ... }

// After (Node.js endpoint)
final response = await _dio.get('/v2/leagues/active');
if (response.data['success'] == true) {
  return (response.data['data'] as List)
      .map((e) => LeagueModel.fromJson(e))
      .toList();
}
```

### Step 4 — Update Model Parsing if Needed

If the Node.js endpoint returns different field names (e.g., `start_date` instead of `startdate`), update the `fromJson` factory — but first confirm the NestJS service is returning the correct field names.

Do NOT change model field names used in the UI — only update `fromJson` parsing.

### Step 5 — Feature-Flag the Migration

Wrap the endpoint switch in `ApiConfig.resolveBase()`:

```dart
// lib/core/config/api_config.dart
static const migratedEndpoints = {
  'get_leagues',   // ← add when ready
};
```

This allows the PHP endpoint to stay as fallback during testing.

### Step 6 — Test

- [ ] Hot reload Flutter app — existing screens still load
- [ ] Data from Node.js matches what PHP was returning
- [ ] Error states (network failure, 401) handled correctly
- [ ] Coins, scores, streaks update correctly if this feature writes data

### Step 7 — Mark as Complete

- [ ] Add endpoint to `migratedEndpoints` in `ApiConfig`
- [ ] Update the Phase 3 migration order table in `DEVELOPER_ROADMAP.md`
- [ ] If all endpoints for a module are migrated, mark that sprint complete

## Validation Checklist

- [ ] No direct `http` package usage in the migrated repository
- [ ] Firebase token attached via Dio client (not manually)
- [ ] New envelope `{ success, data }` parsed correctly
- [ ] Existing model field names unchanged (only `fromJson` updated)
- [ ] PHP endpoint still running as fallback until fully verified
