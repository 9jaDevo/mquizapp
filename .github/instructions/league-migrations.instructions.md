---
applyTo: "**/admin_backend/database/migrations/*.sql"
---

Migration generation rules for league work:

- Use non-destructive migration strategy.
- Preserve backward compatibility with contest and user tables.
- Add indexes for leaderboard and daily submission lookups.
- Include rollback notes when introducing critical tables.
