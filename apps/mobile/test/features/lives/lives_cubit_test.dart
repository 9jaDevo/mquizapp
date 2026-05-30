import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mquiz/features/lives/cubit/lives_cubit.dart';
import 'package:mquiz/features/lives/data/lives_repository.dart';
import 'package:mquiz/features/lives/models/lives_models.dart';

class MockLivesRepository extends Mock implements LivesRepository {}

final _fullLives = LivesState(
  current: 5,
  max: 5,
  lastRefillAt: DateTime(2026, 5, 29),
  nextRefillAt: null,
  intervalMs: 1800000,
);

final _oneLive = LivesState(
  current: 1,
  max: 5,
  lastRefillAt: DateTime(2026, 5, 29),
  nextRefillAt: DateTime(2026, 5, 29, 0, 30),
  intervalMs: 1800000,
);

void main() {
  late MockLivesRepository repo;

  setUp(() {
    repo = MockLivesRepository();
  });

  group('LivesCubit —', () {
    test('initial state is LivesInitial', () {
      expect(LivesCubit(repo).state, isA<LivesInitial>());
    });

    blocTest<LivesCubit, LivesUiState>(
      'load emits Loading then Loaded on success',
      build: () {
        when(() => repo.fetchLives()).thenAnswer((_) async => _fullLives);
        return LivesCubit(repo);
      },
      act: (c) => c.load(),
      expect: () => [
        isA<LivesLoading>(),
        isA<LivesLoaded>(),
      ],
      verify: (c) {
        final s = c.state as LivesLoaded;
        expect(s.lives.current, 5);
      },
    );

    blocTest<LivesCubit, LivesUiState>(
      'load emits Loading then Error on failure',
      build: () {
        when(() => repo.fetchLives()).thenThrow(Exception('network error'));
        return LivesCubit(repo);
      },
      act: (c) => c.load(),
      expect: () => [isA<LivesLoading>(), isA<LivesError>()],
    );

    blocTest<LivesCubit, LivesUiState>(
      'restoreWithCoins updates balance on success',
      build: () {
        when(() => repo.fetchLives()).thenAnswer((_) async => _oneLive);
        when(() => repo.restoreWithCoins()).thenAnswer((_) async => _fullLives);
        return LivesCubit(repo)..load();
      },
      act: (c) async {
        await Future<void>.delayed(Duration.zero); // let load complete
        await c.restoreWithCoins();
      },
      skip: 2,
      expect: () => [
        isA<LivesLoaded>(),
        isA<LivesLoaded>(),
      ],
    );

    blocTest<LivesCubit, LivesUiState>(
      'consume returns false when load not called',
      build: () => LivesCubit(repo),
      act: (c) async {
        final result = await c.consume();
        expect(result, isFalse);
      },
      expect: () => [],
    );
  });
}
