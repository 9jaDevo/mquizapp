import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mquiz/features/quiz/cubit/quiz_cubit.dart';
import 'package:mquiz/features/quiz/data/quiz_repository.dart';
import 'package:mquiz/features/quiz/models/question_model.dart';

class MockQuizRepository extends Mock implements QuizRepository {}

final _q1 = QuizQuestion(
  id: 1,
  categoryId: 5,
  text: 'What is 2+2?',
  type: 'text',
  options: const {'a': '3', 'b': '4', 'c': '5', 'd': '6'},
  level: 1,
  correctAnswer: 'b',
);

final _q2 = QuizQuestion(
  id: 2,
  categoryId: 5,
  text: 'Capital of Nigeria?',
  type: 'text',
  options: const {'a': 'Lagos', 'b': 'Ibadan', 'c': 'Abuja', 'd': 'Kano'},
  level: 1,
  correctAnswer: 'c',
);

void main() {
  late MockQuizRepository repo;

  setUpAll(() {
    registerFallbackValue(<QuizQuestion>[]);
  });

  setUp(() {
    repo = MockQuizRepository();
  });

  group('QuizCubit —', () {
    test('initial state is QuizIdle', () {
      expect(QuizCubit(repo).state, isA<QuizIdle>());
    });

    blocTest<QuizCubit, QuizState>(
      'start emits Loading then InProgress with first question',
      build: () {
        when(() => repo.fetchQuestions(
              categoryId: any(named: 'categoryId'),
              subcategoryId: any(named: 'subcategoryId'),
              level: any(named: 'level'),
              limit: any(named: 'limit'),
            )).thenAnswer((_) async => [_q1, _q2]);
        return QuizCubit(repo);
      },
      act: (c) => c.start(categoryId: 5),
      expect: () => [isA<QuizLoading>(), isA<QuizInProgress>()],
      verify: (c) {
        final s = c.state as QuizInProgress;
        expect(s.index, 0);
        expect(s.total, 2);
        expect(s.current.id, 1);
      },
    );

    blocTest<QuizCubit, QuizState>(
      'start emits QuizError when no questions available',
      build: () {
        when(() => repo.fetchQuestions(
              categoryId: any(named: 'categoryId'),
              subcategoryId: any(named: 'subcategoryId'),
              level: any(named: 'level'),
              limit: any(named: 'limit'),
            )).thenAnswer((_) async => []);
        return QuizCubit(repo);
      },
      act: (c) => c.start(categoryId: 5),
      expect: () => [isA<QuizLoading>(), isA<QuizError>()],
    );

    blocTest<QuizCubit, QuizState>(
      'selectOption records the answer for the current question',
      build: () {
        when(() => repo.fetchQuestions(
              categoryId: any(named: 'categoryId'),
              subcategoryId: any(named: 'subcategoryId'),
              level: any(named: 'level'),
              limit: any(named: 'limit'),
            )).thenAnswer((_) async => [_q1, _q2]);
        return QuizCubit(repo);
      },
      act: (c) async {
        await c.start(categoryId: 5);
        c.selectOption('b');
      },
      skip: 2,
      expect: () => [isA<QuizInProgress>()],
      verify: (c) {
        final s = c.state as QuizInProgress;
        expect(s.selectedFor(1), 'b');
      },
    );
  });
}
