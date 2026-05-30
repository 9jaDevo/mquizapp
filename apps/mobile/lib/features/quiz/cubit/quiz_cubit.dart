import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    this.hiddenOptions = const {},
    this.appliedBoosterCodes = const {},
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

  /// Option keys hidden by the 50/50 booster for the current question.
  final Set<String> hiddenOptions;

  /// Booster codes already applied to the current question (prevents re-use).
  final Set<String> appliedBoosterCodes;

  QuizQuestion get current => questions[index];
  int get total => questions.length;
  bool get isLast => index >= questions.length - 1;
  String? selectedFor(int qId) => answers[qId];

  QuizInProgress copyWith({
    int? index,
    Map<int, String>? answers,
    int? secondsLeft,
    Map<int, int>? elapsedMsPerQuestion,
    Set<String>? hiddenOptions,
    Set<String>? appliedBoosterCodes,
  }) =>
      QuizInProgress(
        questions: questions,
        index: index ?? this.index,
        answers: answers ?? this.answers,
        secondsLeft: secondsLeft ?? this.secondsLeft,
        elapsedMsPerQuestion:
            elapsedMsPerQuestion ?? this.elapsedMsPerQuestion,
        startedAt: startedAt,
        hiddenOptions: hiddenOptions ?? this.hiddenOptions,
        appliedBoosterCodes: appliedBoosterCodes ?? this.appliedBoosterCodes,
      );

  @override
  List<Object?> get props => [questions, index, answers, secondsLeft, hiddenOptions, appliedBoosterCodes];
}

class QuizSubmitting extends QuizState {
  const QuizSubmitting();
}

class QuizCompleted extends QuizState {
  const QuizCompleted(this.result, this.questions,
      {this.triggerMysteryBox = false});
  final QuizResult result;
  final List<QuizQuestion> questions;
  /// Whether to show the mystery-box sheet on the result screen.
  final bool triggerMysteryBox;
  @override
  List<Object?> get props => [result, questions, triggerMysteryBox];
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
    final elapsedMs = ((AppConstants.secondsPerQuestion - s.secondsLeft) * 1000).clamp(0, AppConstants.secondsPerQuestion * 1000);
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
        hiddenOptions: const {},
        appliedBoosterCodes: const {},
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
      final triggerBox = await _checkMysteryBoxTrigger();
      emit(QuizCompleted(result, questions, triggerMysteryBox: triggerBox));
    } catch (e) {
      emit(QuizError(describeError(e)));
    }
  }

  /// Returns true every 5 completed quizzes to trigger the mystery-box sheet.
  Future<bool> _checkMysteryBoxTrigger() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final count = (prefs.getInt('quiz_completed_count') ?? 0) + 1;
      await prefs.setInt('quiz_completed_count', count);
      return count % 5 == 0;
    } catch (_) {
      return false;
    }
  }

  /// Adds extra seconds to the current question's countdown (booster: Add Time).
  void addTime(int secs) {
    final s = state;
    if (s is! QuizInProgress) return;
    emit(s.copyWith(secondsLeft: s.secondsLeft + secs));
  }

  /// Skips the current question (commits empty answer and advances).
  void skipQuestion() {
    final s = state;
    if (s is! QuizInProgress) return;
    _commitAnswer('', autoAdvance: true);
  }

  /// Applies a booster for the current question.
  /// Enforces single-use per question via [appliedBoosterCodes].
  Future<void> applyBooster({
    required String code,
    required int boosterTypeId,
  }) async {
    final s = state;
    if (s is! QuizInProgress) return;
    if (s.appliedBoosterCodes.contains(code)) return;

    final newCodes = Set<String>.from(s.appliedBoosterCodes)..add(code);

    if (code == '50_50' || code == 'fifty_fifty') {
      try {
        final removed = await _repo.fiftyFifty(
          questionId: s.current.id,
          boosterTypeId: boosterTypeId,
        );
        final newHidden = Set<String>.from(s.hiddenOptions)..addAll(removed);
        emit(s.copyWith(hiddenOptions: newHidden, appliedBoosterCodes: newCodes));
      } catch (_) {
        // Booster API failed — do not mark as used so user can retry
      }
    } else if (code == 'time_freeze' || code == 'add_time') {
      try {
        await _repo.consumeBooster(boosterTypeId);
        emit(s.copyWith(
          secondsLeft: s.secondsLeft + 30,
          appliedBoosterCodes: newCodes,
        ));
      } catch (_) {}
    } else if (code == 'skip') {
      try {
        await _repo.consumeBooster(boosterTypeId);
        emit(s.copyWith(appliedBoosterCodes: newCodes));
        _commitAnswer('', autoAdvance: true);
      } catch (_) {}
    } else {
      try {
        await _repo.consumeBooster(boosterTypeId);
        emit(s.copyWith(appliedBoosterCodes: newCodes));
      } catch (_) {}
    }
  }

  void reset() {
    _tick?.cancel();
    emit(const QuizIdle());
  }
}
