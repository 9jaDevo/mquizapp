import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mquiz/core/constants/app_constants.dart';
import 'package:mquiz/core/utils/error_handler.dart';
import 'package:mquiz/features/contests/data/contest_repository.dart';
import 'package:mquiz/features/quiz/models/question_model.dart';

// ── States ───────────────────────────────────────────────────────────────────

sealed class ContestQuizState extends Equatable {
  const ContestQuizState();
  @override
  List<Object?> get props => const [];
}

final class ContestQuizIdle extends ContestQuizState {
  const ContestQuizIdle();
}

final class ContestQuizLoading extends ContestQuizState {
  const ContestQuizLoading();
}

final class ContestQuizInProgress extends ContestQuizState {
  const ContestQuizInProgress({
    required this.questions,
    required this.index,
    required this.answers,
    required this.secondsLeft,
    required this.elapsedMsPerQuestion,
    required this.startedAt,
  });

  final List<QuizQuestion> questions;
  final int index;
  final Map<int, String> answers;
  final int secondsLeft;
  final Map<int, int> elapsedMsPerQuestion;
  final DateTime startedAt;

  QuizQuestion get current => questions[index];
  int get total => questions.length;
  bool get isLast => index >= questions.length - 1;
  String? selectedFor(int qId) => answers[qId];

  ContestQuizInProgress copyWith({
    int? index,
    Map<int, String>? answers,
    int? secondsLeft,
    Map<int, int>? elapsedMsPerQuestion,
  }) =>
      ContestQuizInProgress(
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

final class ContestQuizSubmitting extends ContestQuizState {
  const ContestQuizSubmitting();
}

final class ContestQuizCompleted extends ContestQuizState {
  const ContestQuizCompleted(this.result, this.questions);
  final QuizResult result;
  final List<QuizQuestion> questions;
  @override
  List<Object?> get props => [result, questions];
}

final class ContestQuizError extends ContestQuizState {
  const ContestQuizError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

// ── Cubit ─────────────────────────────────────────────────────────────────────

class ContestQuizCubit extends Cubit<ContestQuizState> {
  ContestQuizCubit(this._repo, this._contestId)
      : super(const ContestQuizIdle());

  final ContestRepository _repo;
  final int _contestId;
  Timer? _tick;

  @override
  Future<void> close() {
    _tick?.cancel();
    return super.close();
  }

  Future<void> start() async {
    emit(const ContestQuizLoading());
    try {
      final questions = await _repo.fetchQuestions(_contestId);
      if (questions.isEmpty) {
        emit(const ContestQuizError('No questions available for this contest.'));
        return;
      }
      emit(ContestQuizInProgress(
        questions: questions,
        index: 0,
        answers: const {},
        secondsLeft: AppConstants.secondsPerQuestion,
        elapsedMsPerQuestion: const {},
        startedAt: DateTime.now(),
      ));
      _startTimer();
    } catch (e) {
      emit(ContestQuizError(describeError(e)));
    }
  }

  void _startTimer() {
    _tick?.cancel();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      final s = state;
      if (s is! ContestQuizInProgress) {
        _tick?.cancel();
        return;
      }
      if (s.secondsLeft <= 1) {
        _commitAnswer('', autoAdvance: true);
      } else {
        emit(s.copyWith(secondsLeft: s.secondsLeft - 1));
      }
    });
  }

  void selectOption(String option) {
    final s = state;
    if (s is! ContestQuizInProgress) return;
    final qId = s.current.id;
    final newAnswers = Map<int, String>.from(s.answers)..[qId] = option;
    emit(s.copyWith(answers: newAnswers));
  }

  void nextQuestion() {
    final s = state;
    if (s is! ContestQuizInProgress) return;
    _commitAnswer(s.answers[s.current.id] ?? '', autoAdvance: true);
  }

  void _commitAnswer(String answer, {required bool autoAdvance}) {
    final s = state;
    if (s is! ContestQuizInProgress) return;
    final qId = s.current.id;
    final elapsedMs =
        (AppConstants.secondsPerQuestion - s.secondsLeft) * 1000;
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
      _startTimer();
    }
  }

  Future<void> _submit({
    required List<QuizQuestion> questions,
    required Map<int, String> answers,
    required Map<int, int> elapsedMs,
    required DateTime startedAt,
  }) async {
    emit(const ContestQuizSubmitting());
    try {
      final submitted = questions
          .map((q) => SubmittedAnswer(
                questionId: q.id,
                userAnswer: answers[q.id] ?? '',
                timeTakenMs: elapsedMs[q.id] ?? 0,
                usedBoosters: const [],
              ))
          .toList(growable: false);
      final data = await _repo.submit(
        contestId: _contestId,
        answers: submitted,
        durationMs: DateTime.now().difference(startedAt).inMilliseconds,
      );
      emit(ContestQuizCompleted(QuizResult.fromJson(data), questions));
    } catch (e) {
      emit(ContestQuizError(describeError(e)));
    }
  }

  void reset() {
    _tick?.cancel();
    emit(const ContestQuizIdle());
  }
}
