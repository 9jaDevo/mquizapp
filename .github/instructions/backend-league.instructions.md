---
applyTo: "**/admin_backend/application/controllers/*.php"
---

Backend generation rules for league work:

- Follow existing `Api.php` conventions.
- Use `{endpoint}_post()` naming.
- Validate auth via `verify_token()` where required.
- Keep response shape stable: `error`, `message`, `data`.
- Reuse timezone handling pattern used by contest endpoints.
- Wrap multi-write flows in transactions.
- Avoid changing non-league endpoints unless needed for integration.
