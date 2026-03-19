# League Existing Code Audit

This audit is the mandatory pre-generation gate for league implementation.

## Scope Reviewed

- Backend controller patterns in admin backend API controller
- Flutter quiz repository and remote data source patterns
- Contest screens, models, and cubits
- Existing migration style and SQL conventions

## Reuse As-Is

1. Contest tab architecture and UX baseline from contest screen.
2. Contest model shape for active/upcoming/past grouping and parse style.
3. Cubit state pattern: initial, progress/loading, success, failure.
4. Repository -> remote data source layering for API calls.
5. Leaderboard pagination strategy (limit + offset + hasMore).
6. Contest backend timezone approach using timezone and gmt parameters.

## Modify Existing

1. Quiz repository: add league methods in same style as contest methods.
2. Quiz remote data source: add league endpoints and payload mapping.
3. Route/navigation registration: add league entry points near contest flow.
4. API controller: add league endpoints with same auth/response style.

## Create New

1. League models in quiz models folder.
2. League cubits in quiz cubits folder.
3. League screens in quiz screens folder.
4. League database migration file with league tables and indexes.
5. Optional admin model/controller support for league management.

## Do Not Touch

1. Existing contest endpoint behavior and payload contracts.
2. Existing contest leaderboard ranking logic used by current clients.
3. Existing monetization migration history files.
4. Unrelated game modes and non-quiz modules.

## Risk Log and Mitigation

1. Risk: Breaking contest payload assumptions while adding league payloads.
   - Mitigation: keep league endpoints separate; do not alter contest response keys.
2. Risk: Timezone drift across daily quiz and notification behavior.
   - Mitigation: apply existing timezone and gmt handling pattern everywhere.
3. Risk: Leaderboard performance degradation with large leagues.
   - Mitigation: use indexed queries and denormalized league leaderboard table.
4. Risk: Overlapping navigation routes causing runtime errors.
   - Mitigation: add unique route keys and integration tests for navigation.

## Gate Decision

Audit complete and approved for code generation.
