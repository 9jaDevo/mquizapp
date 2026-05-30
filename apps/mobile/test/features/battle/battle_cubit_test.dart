import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mquiz/features/battle/cubit/battle_cubit.dart';
import 'package:mquiz/features/battle/data/battle_repository.dart';
import 'package:mquiz/features/quiz/data/quiz_repository.dart';
import 'package:mquiz/features/quiz/models/category_model.dart';
import 'package:mquiz/features/quiz/models/question_model.dart';

class MockBattleRepository extends Mock implements BattleRepository {}

class MockQuizRepository extends Mock implements QuizRepository {}

final _cat = Category(
  id: 1,
  name: 'Science',
  slug: 'science',
  isPremium: false,
  coins: 0,
  rowOrder: 1,
  image: null,
  type: null,
);

BattleCubit _build(
    MockBattleRepository battle, MockQuizRepository quiz) =>
    BattleCubit(battleRepo: battle, quizRepo: quiz);

void main() {
  late MockBattleRepository battleRepo;
  late MockQuizRepository quizRepo;

  setUpAll(() {
    registerFallbackValue(<Category>[]);
    registerFallbackValue(<QuizQuestion>[]);
  });

  setUp(() {
    battleRepo = MockBattleRepository();
    quizRepo = MockQuizRepository();
  });

  group('BattleCubit —', () {
    test('initial state is BattleIdle', () {
      expect(_build(battleRepo, quizRepo).state, isA<BattleIdle>());
    });

    blocTest<BattleCubit, BattleState>(
      'loadCategories emits LoadingCategories then CategoryPicker',
      build: () {
        when(() => quizRepo.fetchCategories(type: any(named: 'type')))
            .thenAnswer((_) async => [_cat]);
        return _build(battleRepo, quizRepo);
      },
      act: (c) => c.loadCategories(),
      expect: () => [
        isA<BattleLoadingCategories>(),
        isA<BattleCategoryPicker>(),
      ],
      verify: (c) {
        final s = c.state as BattleCategoryPicker;
        expect(s.categories.length, 1);
        expect(s.categories.first.name, 'Science');
      },
    );

    blocTest<BattleCubit, BattleState>(
      'loadCategories emits BattleError when no categories',
      build: () {
        when(() => quizRepo.fetchCategories(type: any(named: 'type')))
            .thenAnswer((_) async => []);
        return _build(battleRepo, quizRepo);
      },
      act: (c) => c.loadCategories(),
      expect: () => [
        isA<BattleLoadingCategories>(),
        isA<BattleError>(),
      ],
    );

    blocTest<BattleCubit, BattleState>(
      'loadCategories emits BattleError on exception',
      build: () {
        when(() => quizRepo.fetchCategories(type: any(named: 'type')))
            .thenThrow(Exception('network'));
        return _build(battleRepo, quizRepo);
      },
      act: (c) => c.loadCategories(),
      expect: () => [
        isA<BattleLoadingCategories>(),
        isA<BattleError>(),
      ],
    );
  });
}
