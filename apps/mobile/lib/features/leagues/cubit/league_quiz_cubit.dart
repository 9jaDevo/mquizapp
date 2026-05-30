import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mquiz/core/constants/app_constants.dart';
import 'package:mquiz/core/utils/error_handler.dart';
import 'package:mquiz/features/leagues/data/league_repository.dart';
import 'package:mquiz/features/quiz/models/question_model.dart';

// ── States ───────────────────────────────────────────────────────────────────

sealed class LeagueQuizState extends Equatable {
  const LeagueQuizState();
  @override
  List<Object?> get props => const [];
}

final class LeagueQuizIdle extends LeagueQuizState {
  const LeagueQuizIdle();
}

final class LeagueQuizLoading extends LeagueQuizState {
  const LeagueQuizLoading();
}

final class LeagueQuizInProgress extends LeagueQuizState {
  const LeagueQuizInProgress({
    required this.questions,
    required this.index,
    required this.answers,
    required this.secondsLeft,
    required this.elapsedMsPerQuestion,
    required this.startedAt,
  });

  final List<QuizQuestion> questions;
  final int index;

  /// Selected option per question (questionId → 'a'..'e' or '' if skipped).
  final Map<int, String> answers;

  /// Countdown for the current question.
  final int secondsLeft;

  /// Time taken per question (questionId → ms).
  final Map<int, int> elapsedMsPerQuestion;

  final DateTime startedAt;

  QuizQuestion get current => questions[index];
  int get total => questions.length;
  bool get isLast => index >= questions.length - 1;
  String? selectedFor(int qId) => answers[qId];

  LeagueQuizInProgress copyWith({
    int? index,
    Map<int, String>? answers,
    int? secondsLeft,
    Map<int, int>? elapsedMsPerQuestion,
  }) =>
      LeagueQuizInProgress(
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

final class LeagueQuizSubmitting extends LeagueQuizState {
  const LeagueQuizSubmitting();
}

final class LeagueQuizCompleted extends LeagueQuizState {
  const LeagueQuizCompleted(this.result, this.questions);
  final QuizResult result;
  final List<QuizQuestion> questions;
  @override
  List<Object?> get props => [result, questions];
}

final class LeagueQuizError extends LeagueQuizState {
  const LeagueQuizError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

// ── Cubit ─────────────────────────────────────────────────────────────────────

class LeagueQuizCubit extends Cubit<LeagueQuizState> {
  LeagueQuizCubit(this._repo, this._leagueId) : super(const LeagueQuizIdle());

  final LeagueRepository _repo;
  final int _leagueId;
  Timer? _tick;

  @override
  Future<void> close() {
    _tick?.cancel();
    return super.close();
  }

  Future<void> start() async {
    emit(const LeagueQuizLoading());
    try {
      final questions = await _repo.fetchTodayQuestions(_leagueId);
      if (questions.isEmpty) {
        emit(const LeagueQuizError(
            "You've already completed today's quiz, or no questions are available."));
        return;
      }
      emit(LeagueQuizInProgress(
        questions: questions,
        index: 0,
        answers: const {},
        secondsLeft: AppConstants.secondsPerQuestion,
        elapsedMsPerQuestion: const {},
        startedAt: DateTime.now(),
      ));
      _startTimer();
    } catch (e) {
      emit(LeagueQuizError(describeError(e)));
    }
  }

  void _startTimer() {
    _tick?.cancel();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      final s = state;
      if (s is! LeagueQuizInProgress) {
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
    if (s is! LeagueQuizInProgress) return;
    final qId = s.current.id;
    final newAnswers = Map<int, String>.from(s.answers)..[qId] = option;
    emit(s.copyWith(answers: newAnswers));
  }

  void nextQuestion() {
    final s = state;
    if (s is! LeagueQuizInProgress) return;
    _commitAnswer(s.answers[s.current.id] ?? '', autoAdvance: true);
  }

  void _commitAnswer(String answer, {required bool autoAdvance}) {
    final s = state;
    if (s is! LeagueQuizInProgress) return;
    final qId = s.current.id;
    final elapsedMs =
        ((AppConstants.secondsPerQuestion - s.secondsLeft) * 1000).clamp(0, AppConstants.secondsPerQuestion * 1000);
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
    emit(const LeagueQuizSubmitting());
    try {
      final submitted = questions
          .map((q) => SubmittedAnswer(
                questionId: q.id,
                userAnswer: answers[q.id] ?? '',
                timeTakenMs: elapsedMs[q.id] ?? 0,
                usedBoosters: const [],
              ))
          .toList(growable: false);
      final data = await _repo.submitAnswers(
        leagueId: _leagueId,
        answers: submitted,
        durationMs: DateTime.now().difference(startedAt).inMilliseconds,
      );
      emit(LeagueQuizCompleted(QuizResult.fromJson(data), questions));
    } catch (e) {
      emit(LeagueQuizError(describeError(e)));
    }
  }

  void reset() {
    _tick?.cancel();
    emit(const LeagueQuizIdle());
  }
}
