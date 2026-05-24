---
description: "Scaffold a complete Flutter feature with cubit, state, model, repository, and screen following mQuiz Cubit conventions."
---

Scaffold a complete Flutter feature for the mQuiz app.

Feature name: **${input:featureName}**
API endpoint it calls: **${input:apiEndpoint}**  
Brief description: **${input:description}**

## Target Location

- Existing app: `lib/features/${input:featureName}/`
- New app: `apps/mobile/lib/features/${input:featureName}/`

## What to Generate

1. **`models/${input:featureName}_model.dart`**
   - A Dart model class with `fromJson` factory constructor
   - Fields appropriate to the description
   - Use null-safety throughout (`?` for nullable, `??` defaults)

2. **`cubit/${input:featureName}_state.dart`**
   - States: `${input:featureName}Initial`, `${input:featureName}Loading`, `${input:featureName}Loaded`, `${input:featureName}Error`
   - `Loaded` state carries the model or list
   - `Error` state carries a `String message`

3. **`cubit/${input:featureName}_cubit.dart`**
   - Extends `Cubit<${input:featureName}State>`
   - Takes a repository in constructor
   - A primary `load()` method that emits Loading → Loaded or Error
   - Uses `try/catch` around repository calls

4. **`repository/${input:featureName}_repository.dart`**
   - Takes `Dio` in constructor
   - Calls `${input:apiEndpoint}` using the shared Dio client
   - Parses the `{ success, data }` envelope and returns the model

5. **`screens/${input:featureName}_screen.dart`**
   - Stateless widget
   - Uses `BlocBuilder<${input:featureName}Cubit, ${input:featureName}State>`
   - Handles all 4 states with appropriate UI (loading spinner, error text, content)
   - Has a `BlocProvider` wrapper example in the docstring

## Conventions to Follow

- No `http` package — Dio only.
- Never call Firebase directly in repositories — the Dio client handles token attachment.
- State classes are `abstract` base + concrete subclasses (not sealed, for Flutter 3.x compatibility).
- Do not put business logic in the screen widget.

## After Generating

Remind me to:
1. Register the repository and cubit in the dependency injection setup.
2. Add a route for the screen in GoRouter (new app) or Navigator (existing app).
3. Verify the API endpoint is listed in `DEVELOPER_ROADMAP.md` → Full API Reference.
