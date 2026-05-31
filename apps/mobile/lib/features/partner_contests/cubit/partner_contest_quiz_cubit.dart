import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mquiz/core/constants/app_constants.dart';
import 'package:mquiz/core/utils/error_handler.dart';
import 'package:mquiz/features/partner_contests/data/partner_contest_repository.dart';
import 'package:mquiz/features/quiz/models/question_model.dart';

// ── States ───────────────────────────────────────────────────────────────────

sealed class PartnerContestQuizState extends Equatable {
  const PartnerContestQuizState();
  @override
  List<Object?> get props => const [];
}

final class PartnerContestQuizIdle extends PartnerContestQuizState {
  const PartnerContestQuizIdle();
}

final class PartnerContestQuizLoading extends PartnerContestQuizState {
  const PartnerContestQuizLoading();
}

final class PartnerContestQuizInProgress extends PartnerContestQuizState {
  const PartnerContestQuizInProgress({
    required this.questions,
    required this.index,
    required this.answers,
    required this.secondsLeft,
    required this.elapsedMsPerQuestion,
    required this.startedAt,
    required this.timeLimitSeconds,
  });

  final List<QuizQuestion> questions;
  final int index;
  final Map<int, String> answers;
  final int secondsLeft;
  final Map<int, int> elapsedMsPerQuestion;
  final DateTime startedAt;
  final int timeLimitSeconds;

  QuizQuestion get current => questions[index];
  int get total => questions.length;
  bool get isLast => index >= questions.length - 1;
  String? selectedFor(int qId) => answers[qId];

  PartnerContestQuizInProgress copyWith({
    int? index,
    Map<int, String>? answers,
    int? secondsLeft,
    Map<int, int>? elapsedMsPerQuestion,
  }) =>
      PartnerContestQuizInProgress(
        questions: questions,
        index: index ?? this.index,
        answers: answers ?? this.answers,
        secondsLeft: secondsLeft ?? this.secondsLeft,
        elapsedMsPerQuestion: elapsedMsPerQuestion ?? this.elapsedMsPerQuestion,
        startedAt: startedAt,
        timeLimitSeconds: timeLimitSeconds,
      );

  @override
  List<Object?> get props => [questions, index, answers, secondsLeft];
}

final class PartnerContestQuizSubmitting extends PartnerContestQuizState {
  const PartnerContestQuizSubmitting();
}

final class PartnerContestQuizCompleted extends PartnerContestQuizState {
  const PartnerContestQuizCompleted(this.result, this.questions);
  final QuizResult result;
  final List<QuizQuestion> questions;
  @override
  List<Object?> get props => [result, questions];
}

final class PartnerContestQuizError extends PartnerContestQuizState {
  const PartnerContestQuizError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

// ── Cubit ─────────────────────────────────────────────────────────────────────

class PartnerContestQuizCubit extends Cubit<PartnerContestQuizState> {
  PartnerContestQuizCubit(this._repo, this._contestId,
      {int? timeLimitSeconds})
      : _timeLimitSeconds =
            timeLimitSeconds ?? AppConstants.secondsPerQuestion,
        super(const PartnerContestQuizIdle());

  final PartnerContestRepository _repo;
  final int _contestId;
  final int _timeLimitSeconds;
  Timer? _tick;

  @override
  Future<void> close() {
    _tick?.cancel();
    return super.close();
  }

  Future<void> start() async {
    emit(const PartnerContestQuizLoading());
    try {
      final questions = await _repo.fetchQuestions(_contestId);
      if (questions.isEmpty) {
        emit(const PartnerContestQuizError('No questions available for this contest.'));
        return;
      }
      emit(PartnerContestQuizInProgress(
        questions: questions,
        index: 0,
        answers: const {},
        secondsLeft: _timeLimitSeconds,
        elapsedMsPerQuestion: const {},
        startedAt: DateTime.now(),
        timeLimitSeconds: _timeLimitSeconds,
      ));
      _startTimer();
    } catch (e) {
      emit(PartnerContestQuizError(describeError(e)));
    }
  }

  void _startTimer() {
    _tick?.cancel();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      final s = state;
      if (s is! PartnerContestQuizInProgress) {
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
    if (s is! PartnerContestQuizInProgress) return;
    final qId = s.current.id;
    emit(s.copyWith(answers: Map<int, String>.from(s.answers)..[qId] = option));
  }

  void nextQuestion() {
    final s = state;
    if (s is! PartnerContestQuizInProgress) return;
    _commitAnswer(s.answers[s.current.id] ?? '', autoAdvance: true);
  }

  void _commitAnswer(String answer, {required bool autoAdvance}) {
    final s = state;
    if (s is! PartnerContestQuizInProgress) return;
    final qId = s.current.id;
    final elapsedMs =
        ((_timeLimitSeconds - s.secondsLeft) * 1000).clamp(0, _timeLimitSeconds * 1000);
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
        secondsLeft: _timeLimitSeconds,
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
    emit(const PartnerContestQuizSubmitting());
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
      emit(PartnerContestQuizCompleted(QuizResult.fromJson(data), questions));
    } catch (e) {
      emit(PartnerContestQuizError(describeError(e)));
    }
  }

  void reset() {
    _tick?.cancel();
    emit(const PartnerContestQuizIdle());
  }
}
