---
description: "Use when creating or modifying Flutter Dart code in the existing app (lib/) or new app (apps/mobile/lib/). Covers Cubit state management, API integration with Dio, Firebase auth token attachment, model parsing, and screen structure."
applyTo: ["**/lib/**/*.dart", "**/apps/mobile/lib/**/*.dart"]
---

# Flutter Development Rules

## State Management — Cubit Pattern

Use `Cubit<State>` from `flutter_bloc`. Do NOT use full BLoC with events for new features.

```dart
// feature_state.dart
abstract class FeatureState {}
class FeatureInitial extends FeatureState {}
class FeatureLoading extends FeatureState {}
class FeatureLoaded extends FeatureState { final FeatureModel data; FeatureLoaded(this.data); }
class FeatureError extends FeatureState { final String message; FeatureError(this.message); }

// feature_cubit.dart
class FeatureCubit extends Cubit<FeatureState> {
  final FeatureRepository _repo;
  FeatureCubit(this._repo) : super(FeatureInitial());

  Future<void> load() async {
    emit(FeatureLoading());
    try {
      final data = await _repo.fetchFeature();
      emit(FeatureLoaded(data));
    } catch (e) {
      emit(FeatureError(e.toString()));
    }
  }
}
```

## File Naming

| File type | Convention | Example |
|---|---|---|
| Screen | `feature_screen.dart` | `league_screen.dart` |
| Cubit | `feature_cubit.dart` | `league_cubit.dart` |
| State | `feature_state.dart` | `league_state.dart` |
| Model | `feature_model.dart` | `league_model.dart` |
| Repository | `feature_repository.dart` | `league_repository.dart` |
| Widget | `feature_widget.dart` | `league_card_widget.dart` |

## API Calls — Dio Client

Use the shared `ApiClient` (Dio) — never the `http` package. The client automatically attaches the Firebase ID token.

```dart
// In a repository
class LeagueRepository {
  final Dio _dio;
  LeagueRepository(this._dio);

  Future<List<LeagueModel>> getActiveLeagues() async {
    final response = await _dio.get('/v2/leagues/active');
    final data = response.data['data'] as List;
    return data.map((e) => LeagueModel.fromJson(e)).toList();
  }
}
```

## Model Parsing

- Every model must have `fromJson(Map<String, dynamic> json)` factory constructor.
- Use null-safety: handle nullable fields with `??` defaults.
- Never assume field types from JSON — cast explicitly.

```dart
class LeagueModel {
  final int id;
  final String name;
  final int entryCoins;
  final DateTime startDate;

  LeagueModel({
    required this.id,
    required this.name,
    required this.entryCoins,
    required this.startDate,
  });

  factory LeagueModel.fromJson(Map<String, dynamic> json) {
    return LeagueModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      entryCoins: json['entry_coins'] as int? ?? 0,
      startDate: DateTime.parse(json['start_date'] as String),
    );
  }
}
```

## Screen Structure

Screens are stateless; state comes from BlocBuilder or BlocConsumer.

```dart
class LeagueScreen extends StatelessWidget {
  const LeagueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LeagueCubit, LeagueState>(
      builder: (context, state) {
        if (state is LeagueLoading) return const CircularProgressIndicator();
        if (state is LeagueError) return Text(state.message);
        if (state is LeagueLoaded) return _buildList(state.leagues);
        return const SizedBox.shrink();
      },
    );
  }
}
```

## Firebase Auth

- The Dio client in `lib/core/network/api_client.dart` automatically fetches and attaches the Firebase ID token to every request. Do not manually attach tokens in repositories or cubits.
- For Firebase Firestore (battle rooms), use the `cloud_firestore` package directly in the battle feature — do not route battle state through the REST API.

## Ads Integration

- Ad type is driven by the `adsType` setting from the system config API (field: `ads_type`).
- `AdType.admob('1')` means AdMob with mediation configured in the AdMob dashboard — no Flutter code changes needed to enable mediation.
- Never hardcode ad unit IDs in Dart code — fetch them from the system config response.

## Existing App Compatibility (lib/)

- Maintain existing cubit and repository patterns already in `lib/`.
- During Phase 3 migration, new Node.js endpoints replace PHP ones by updating the base URL in `ApiConfig` — do not restructure cubits just to switch endpoints.
- Feature-flag new UI behind a condition from system config before fully releasing.
