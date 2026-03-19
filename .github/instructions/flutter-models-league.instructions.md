---
applyTo: "**/lib/features/quiz/models/*.dart"
---

Flutter model generation rules for league work:

- Match style used in existing quiz/contest models.
- Keep constructors and `fromJson` robust to nullable/partial payloads.
- Preserve field naming compatibility with backend payload.
- Do not alter existing contest model contracts.
