---
applyTo: "**/lib/features/quiz/cubits/*.dart"
---

Cubit generation rules for league work:

- Follow existing loading/success/failure state pattern.
- Keep repository calls centralized in cubits/repositories.
- Surface backend errors cleanly in failure states.
- Avoid introducing side effects in state classes.
