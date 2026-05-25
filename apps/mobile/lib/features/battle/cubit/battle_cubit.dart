import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mquiz/core/constants/app_constants.dart';
import 'package:mquiz/core/utils/error_handler.dart';
import 'package:mquiz/features/auth/models/auth_model.dart';
import 'package:mquiz/features/battle/data/battle_repository.dart';
import 'package:mquiz/features/battle/models/battle_model.dart';
import 'package:mquiz/features/quiz/data/quiz_repository.dart';
import 'package:mquiz/features/quiz/models/category_model.dart';
import 'package:mquiz/features/quiz/models/question_model.dart';

// ── States ────────────────────────────────────────────────────────────────────

sealed class BattleState extends Equatable {
  const BattleState();
  @override
  List<Object?> get props => const [];
}

final class BattleIdle extends BattleState {
  const BattleIdle();
}

final class BattleLoadingCategories extends BattleState {
  const BattleLoadingCategories();
}

final class BattleCategoryPicker extends BattleState {
  const BattleCategoryPicker(this.categories);
  final List<Category> categories;
  @override
  List<Object?> get props => [categories];
}

final class BattleMatchmaking extends BattleState {
  const BattleMatchmaking({required this.categoryId, required this.categoryName});
  final int categoryId;
  final String categoryName;
  @override
  List<Object?> get props => [categoryId, categoryName];
}

final class BattleWaiting extends BattleState {
  const BattleWaiting({
    required this.roomId,
    required this.categoryName,
  });
  final String roomId;
  final String categoryName;
  @override
  List<Object?> get props => [roomId, categoryName];
}

final class BattleInProgress extends BattleState {
  const BattleInProgress({
    required this.roomId,
    required this.questions,
    required this.index,
    required this.answers,
    required this.secondsLeft,
    required this.elapsedMsPerQuestion,
    required this.startedAt,
    required this.isUser1,
    required this.opponentAnswersCount,
    required this.opponentCorrect,
    required this.opponentFinished,
  });

  final String roomId;
  final List<QuizQuestion> questions;
  final int index;
  final Map<int, String> answers;
  final int secondsLeft;
  final Map<int, int> elapsedMsPerQuestion;
  final DateTime startedAt;
  final bool isUser1;
  final int opponentAnswersCount;
  final int opponentCorrect;
  final bool opponentFinished;

  QuizQuestion get current => questions[index];
  int get total => questions.length;
  bool get isLast => index >= questions.length - 1;
  String? selectedFor(int qId) => answers[qId];

  BattleInProgress copyWith({
    int? index,
    Map<int, String>? answers,
    int? secondsLeft,
    Map<int, int>? elapsedMsPerQuestion,
    int? opponentAnswersCount,
    int? opponentCorrect,
    bool? opponentFinished,
  }) =>
      BattleInProgress(
        roomId: roomId,
        questions: questions,
        index: index ?? this.index,
        answers: answers ?? this.answers,
        secondsLeft: secondsLeft ?? this.secondsLeft,
        elapsedMsPerQuestion:
            elapsedMsPerQuestion ?? this.elapsedMsPerQuestion,
        startedAt: startedAt,
        isUser1: isUser1,
        opponentAnswersCount:
            opponentAnswersCount ?? this.opponentAnswersCount,
        opponentCorrect: opponentCorrect ?? this.opponentCorrect,
        opponentFinished: opponentFinished ?? this.opponentFinished,
      );

  @override
  List<Object?> get props => [
        roomId, index, answers, secondsLeft,
        opponentAnswersCount, opponentCorrect, opponentFinished,
      ];
}

final class BattleSubmitting extends BattleState {
  const BattleSubmitting();
}

final class BattleCompleted extends BattleState {
  const BattleCompleted(this.result);
  final BattleResult result;
  @override
  List<Object?> get props => [result];
}

final class BattleError extends BattleState {
  const BattleError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

// ── Cubit ─────────────────────────────────────────────────────────────────────

class BattleCubit extends Cubit<BattleState> {
  BattleCubit({
    required BattleRepository battleRepo,
    required QuizRepository quizRepo,
  })  : _battleRepo = battleRepo,
        _quizRepo = quizRepo,
        super(const BattleIdle());

  final BattleRepository _battleRepo;
  final QuizRepository _quizRepo;

  Timer? _tick;
  StreamSubscription<BattleRoom>? _roomSub;
  String? _currentRoomId;
  bool? _isUser1;

  @override
  Future<void> close() async {
    _tick?.cancel();
    await _roomSub?.cancel();
    super.close();
  }

  // ── Phase 1: Category Selection ────────────────────────────────────────────

  Future<void> loadCategories() async {
    emit(const BattleLoadingCategories());
    try {
      final categories = await _quizRepo.fetchCategories();
      if (categories.isEmpty) {
        emit(const BattleError('No categories available.'));
        return;
      }
      emit(BattleCategoryPicker(categories));
    } catch (e) {
      emit(BattleError(describeError(e)));
    }
  }

  // ── Phase 2: Matchmaking ───────────────────────────────────────────────────

  Future<void> startMatchmaking({
    required Category category,
    required AuthModel user,
  }) async {
    emit(BattleMatchmaking(
      categoryId: category.id,
      categoryName: category.name,
    ));
    try {
      // Fetch questions first (needed whether creating or joining)
      final questions =
          await _battleRepo.fetchBattleQuestions(category.id);
      if (questions.isEmpty) {
        emit(const BattleError('No questions available for this category.'));
        return;
      }

      final me = _buildPlayer(user);
      final existingRoom = await _battleRepo.findWaitingRoom(category.id);

      if (existingRoom != null &&
          existingRoom.user1.uid != user.firebaseUid) {
        // Join the existing room
        await _battleRepo.joinRoom(
            roomId: existingRoom.id, user2: me);
        _isUser1 = false;
        _currentRoomId = existingRoom.id;
        _listenToRoom(
          existingRoom.id,
          // user2 uses the questions from the existing room
          questionsOverride: existingRoom.questions.isNotEmpty
              ? existingRoom.questions
              : questions,
          isUser1: false,
          user: user,
        );
      } else {
        // Create a new room
        final roomId = await _battleRepo.createRoom(
          categoryId: category.id,
          categoryName: category.name,
          user1: me,
          questions: questions,
        );
        _isUser1 = true;
        _currentRoomId = roomId;
        emit(BattleWaiting(
          roomId: roomId,
          categoryName: category.name,
        ));
        _listenToRoom(roomId,
            questionsOverride: questions, isUser1: true, user: user);
      }
    } catch (e) {
      emit(BattleError(describeError(e)));
    }
  }

  void _listenToRoom(
    String roomId, {
    required List<QuizQuestion> questionsOverride,
    required bool isUser1,
    required AuthModel user,
  }) {
    _roomSub?.cancel();
    _roomSub = _battleRepo.watchRoom(roomId).listen(
      (room) => _onRoomUpdate(room,
          questions: questionsOverride, isUser1: isUser1, user: user),
      onError: (e) => emit(BattleError(describeError(e))),
    );
  }

  void _onRoomUpdate(
    BattleRoom room, {
    required List<QuizQuestion> questions,
    required bool isUser1,
    required AuthModel user,
  }) {
    if (isClosed) return;
    switch (room.status) {
      case BattleStatus.cancelled:
        _cleanup();
        emit(const BattleError('The battle was cancelled.'));
        return;
      case BattleStatus.inProgress:
        final s = state;
        if (s is BattleWaiting || s is BattleMatchmaking) {
          // Transition from waiting → in progress
          _startBattle(room, questions: questions, isUser1: isUser1);
          return;
        }
        if (s is BattleInProgress) {
          // Update opponent progress
          final opponent = isUser1 ? room.user2 : room.user1;
          if (opponent != null) {
            emit(s.copyWith(
              opponentAnswersCount: opponent.answersCount,
              opponentCorrect: opponent.correctAnswers,
              opponentFinished: opponent.hasFinished,
            ));
          }
          // If both finished, finalize
          if (room.bothFinished) {
            _finalizeBattle(room, isUser1: isUser1, user: user);
          }
        }
        return;
      case BattleStatus.completed:
        if (state is BattleInProgress || state is BattleSubmitting) {
          _finalizeBattle(room, isUser1: isUser1, user: user);
        }
        return;
      case BattleStatus.waiting:
      case BattleStatus.unknown:
        break;
    }
  }

  void _startBattle(
    BattleRoom room, {
    required List<QuizQuestion> questions,
    required bool isUser1,
  }) {
    _tick?.cancel();
    emit(BattleInProgress(
      roomId: room.id,
      questions: questions,
      index: 0,
      answers: const {},
      secondsLeft: AppConstants.secondsPerQuestion,
      elapsedMsPerQuestion: const {},
      startedAt: DateTime.now(),
      isUser1: isUser1,
      opponentAnswersCount: 0,
      opponentCorrect: 0,
      opponentFinished: false,
    ));
    _startTimer();
  }

  // ── Phase 3: Quiz Play ─────────────────────────────────────────────────────

  void _startTimer() {
    _tick?.cancel();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      final s = state;
      if (s is! BattleInProgress) {
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
    if (s is! BattleInProgress) return;
    final qId = s.current.id;
    emit(s.copyWith(answers: {...s.answers, qId: option}));
  }

  void nextQuestion() {
    final s = state;
    if (s is! BattleInProgress) return;
    _commitAnswer(s.answers[s.current.id] ?? '', autoAdvance: true);
  }

  void _commitAnswer(String answer, {required bool autoAdvance}) {
    final s = state;
    if (s is! BattleInProgress) return;
    final qId = s.current.id;
    final elapsedMs =
        (AppConstants.secondsPerQuestion - s.secondsLeft) * 1000;
    final newAnswers = Map<int, String>.from(s.answers);
    newAnswers[qId] = newAnswers[qId] ?? answer;
    final newElapsed = Map<int, int>.from(s.elapsedMsPerQuestion)
      ..[qId] = elapsedMs;

    // Calculate correct count for progress update
    int correctSoFar = 0;
    for (final entry in newAnswers.entries) {
      final q = s.questions.firstWhere((q) => q.id == entry.key,
          orElse: () => s.questions.first);
      if (q.correctAnswer != null &&
          q.correctAnswer!.isNotEmpty &&
          entry.value == q.correctAnswer) {
        correctSoFar++;
      }
    }

    if (s.isLast) {
      _tick?.cancel();
      _submitBattle(s, newAnswers, newElapsed, correctSoFar);
      return;
    }

    if (autoAdvance) {
      final next = s.copyWith(
        index: s.index + 1,
        answers: newAnswers,
        elapsedMsPerQuestion: newElapsed,
        secondsLeft: AppConstants.secondsPerQuestion,
      );
      emit(next);
      _startTimer();

      // Fire-and-forget Firestore progress update
      _battleRepo.updateProgress(
        roomId: s.roomId,
        isUser1: s.isUser1,
        correctAnswers: correctSoFar,
        answersCount: newAnswers.length,
      );
    }
  }

  Future<void> _submitBattle(
    BattleInProgress s,
    Map<int, String> answers,
    Map<int, int> elapsedMs,
    int correctAnswers,
  ) async {
    emit(const BattleSubmitting());
    try {
      final score = correctAnswers * 10; // 10 pts per correct answer
      await _battleRepo.finishBattle(
        roomId: s.roomId,
        isUser1: s.isUser1,
        correctAnswers: correctAnswers,
        score: score,
        answersCount: answers.length,
      );
      // Mark room completed if both finished (best-effort)
      await _battleRepo.markCompleted(s.roomId);
    } catch (_) {
      // Ignore write errors — result will come via stream
    }
  }

  // ── Phase 4: Result ────────────────────────────────────────────────────────

  void _finalizeBattle(
    BattleRoom room, {
    required bool isUser1,
    required AuthModel user,
  }) {
    _cleanup();
    final myPlayer = isUser1 ? room.user1 : (room.user2 ?? room.user1);
    final opponent = isUser1 ? (room.user2 ?? room.user1) : room.user1;

    emit(BattleCompleted(BattleResult(
      roomId: room.id,
      myPlayer: myPlayer,
      opponent: opponent,
      questions: room.questions,
      didWin: myPlayer.correctAnswers > opponent.correctAnswers,
    )));
  }

  // ── Cancel / Reset ─────────────────────────────────────────────────────────

  Future<void> cancel() async {
    final roomId = _currentRoomId;
    _cleanup();
    if (roomId != null && _isUser1 == true) {
      try {
        await _battleRepo.cancelRoom(roomId);
      } catch (_) {}
    }
    emit(const BattleIdle());
  }

  void reset() {
    _cleanup();
    emit(const BattleIdle());
  }

  void _cleanup() {
    _tick?.cancel();
    _tick = null;
    _roomSub?.cancel();
    _roomSub = null;
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  static BattlePlayer _buildPlayer(AuthModel user) => BattlePlayer(
        uid: user.firebaseUid,
        userId: user.userId,
        displayName: user.name ?? 'Player',
        photoUrl: user.photoUrl,
      );
}
