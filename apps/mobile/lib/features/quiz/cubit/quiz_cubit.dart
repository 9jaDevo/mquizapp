import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mquiz/core/constants/app_constants.dart';
import 'package:mquiz/core/utils/error_handler.dart';
import 'package:mquiz/features/quiz/data/quiz_repository.dart';
import 'package:mquiz/features/quiz/models/question_model.dart';

sealed class QuizState extends Equatable {
  const QuizState();
  @override
  List<Object?> get props => const [];
}

class QuizIdle extends QuizState {
  const QuizIdle();
}

class QuizLoading extends QuizState {
  const QuizLoading();
}

class QuizInProgress extends QuizState {
  const QuizInProgress({
    required this.questions,
    required this.index,
    required this.answers,
    required this.secondsLeft,
    required this.elapsedMsPerQuestion,
    required this.startedAt,
  });

  final List<QuizQuestion> questions;
  final int index;

  /// Selected option per question (questionId -> 'a'..'e' or '' if skipped).
  final Map<int, String> answers;

  /// Countdown for the current question.
  final int secondsLeft;

  /// Time taken per question (questionId -> ms).
  final Map<int, int> elapsedMsPerQuestion;

  final DateTime startedAt;

  QuizQuestion get current => questions[index];
  int get total => questions.length;
  bool get isLast => index >= questions.length - 1;
  String? selectedFor(int qId) => answers[qId];

  QuizInProgress copyWith({
    int? index,
    Map<int, String>? answers,
    int? secondsLeft,
    Map<int, int>? elapsedMsPerQuestion,
  }) =>
      QuizInProgress(
        questions: questions,
        index: index ?? this.index,
        answers: answers ?? this.answers,
        secondsLeft: secondsLeft ?? this.secondsLeft,
        elapsedMsPerQuestion:
            elapsedMsPerQuestion ?? this.elapsedMsPerQuestion,
        startedAt: startedAt,
      );

  @override
  List<Object?> get props => [questions, index, answers, secondsLeft];
}

class QuizSubmitting extends QuizState {
  const QuizSubmitting();
}

class QuizCompleted extends QuizState {
  const QuizCompleted(this.result, this.questions);
  final QuizResult result;
  final List<QuizQuestion> questions;
  @override
  List<Object?> get props => [result, questions];
}

class QuizError extends QuizState {
  const QuizError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

class QuizCubit extends Cubit<QuizState> {
  QuizCubit(this._repo) : super(const QuizIdle());

  final QuizRepository _repo;
  Timer? _tick;

  @override
  Future<void> close() {
    _tick?.cancel();
    return super.close();
  }

  Future<void> start({
    required int categoryId,
    int? subcategoryId,
    int? level,
    int? limit,
  }) async {
    emit(const QuizLoading());
    try {
      final questions = await _repo.fetchQuestions(
        categoryId: categoryId,
        subcategoryId: subcategoryId,
        level: level,
        limit: limit ?? AppConstants.defaultQuestionsPerQuiz,
      );
      if (questions.isEmpty) {
        emit(const QuizError('No questions available for this selection.'));
        return;
      }
      emit(QuizInProgress(
        questions: questions,
        index: 0,
        answers: const {},
        secondsLeft: AppConstants.secondsPerQuestion,
        elapsedMsPerQuestion: const {},
        startedAt: DateTime.now(),
      ));
      _startTimer();
    } catch (e) {
      emit(QuizError(describeError(e)));
    }
  }

  void _startTimer() {
    _tick?.cancel();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      final s = state;
      if (s is! QuizInProgress) {
        _tick?.cancel();
        return;
      }
      if (s.secondsLeft <= 1) {
        // auto-skip
        _commitAnswer('', autoAdvance: true);
      } else {
        emit(s.copyWith(secondsLeft: s.secondsLeft - 1));
      }
    });
  }

  void selectOption(String option) {
    final s = state;
    if (s is! QuizInProgress) return;
    final qId = s.current.id;
    final newAnswers = Map<int, String>.from(s.answers)..[qId] = option;
    emit(s.copyWith(answers: newAnswers));
  }

  void nextQuestion() {
    final s = state;
    if (s is! QuizInProgress) return;
    final qId = s.current.id;
    final answer = s.answers[qId] ?? '';
    _commitAnswer(answer, autoAdvance: true);
  }

  void _commitAnswer(String answer, {required bool autoAdvance}) {
    final s = state;
    if (s is! QuizInProgress) return;
    final qId = s.current.id;
    final elapsedMs = (AppConstants.secondsPerQuestion - s.secondsLeft) * 1000;
    final newAnswers = Map<int, String>.from(s.answers);
    newAnswers[qId] = newAnswers[qId] ?? answer;
    final newElapsed = Map<int, int>.from(s.elapsedMsPerQuestion)
      ..[qId] = elapsedMs;

    if (s.isLast) {
      _tick?.cancel();
      _submit(
        questions: s.questions,
        answers: newAnswers,
        elapsedMs: newElapsed,
        startedAt: s.startedAt,
      );
      return;
    }
    if (autoAdvance) {
      emit(s.copyWith(
        index: s.index + 1,
        answers: newAnswers,
        elapsedMsPerQuestion: newElapsed,
        secondsLeft: AppConstants.secondsPerQuestion,
      ));
    }
  }

  Future<void> _submit({
    required List<QuizQuestion> questions,
    required Map<int, String> answers,
    required Map<int, int> elapsedMs,
    required DateTime startedAt,
  }) async {
    emit(const QuizSubmitting());
    try {
      final submitted = questions
          .map((q) => SubmittedAnswer(
                questionId: q.id,
                userAnswer: answers[q.id] ?? '',
                timeTakenMs: elapsedMs[q.id] ?? 0,
                usedBoosters: const [],
              ))
          .toList(growable: false);
      final result = await _repo.submitQuiz(
        categoryId: questions.first.categoryId,
        subcategoryId: questions.first.subcategoryId,
        level: questions.first.level,
        answers: submitted,
        durationMs: DateTime.now().difference(startedAt).inMilliseconds,
      );
      emit(QuizCompleted(result, questions));
    } catch (e) {
      emit(QuizError(describeError(e)));
    }
  }

  void reset() {
    _tick?.cancel();
    emit(const QuizIdle());
  }
}
