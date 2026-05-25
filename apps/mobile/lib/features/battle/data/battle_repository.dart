import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mquiz/features/battle/models/battle_model.dart';
import 'package:mquiz/features/quiz/data/quiz_repository.dart';
import 'package:mquiz/features/quiz/models/question_model.dart';

const int _kBattleQuestionCount = 10;

/// Handles all Firestore battle room interactions and question loading.
/// Never exposes raw Firestore types to the cubit layer.
class BattleRepository {
  BattleRepository({
    FirebaseFirestore? firestore,
    QuizRepository? quizRepo,
  })  : _db = firestore ?? FirebaseFirestore.instance,
        _quizRepo = quizRepo ?? QuizRepository();

  final FirebaseFirestore _db;
  final QuizRepository _quizRepo;

  CollectionReference<Map<String, dynamic>> get _rooms =>
      _db.collection('battleRoom');

  // ── Question Loading ───────────────────────────────────────────────────────

  Future<List<QuizQuestion>> fetchBattleQuestions(int categoryId) =>
      _quizRepo.fetchQuestions(
        categoryId: categoryId,
        limit: _kBattleQuestionCount,
      );

  // ── Room Lifecycle ─────────────────────────────────────────────────────────

  /// Find a waiting room for the given [categoryId]. Returns null if none.
  Future<BattleRoom?> findWaitingRoom(int categoryId) async {
    final snap = await _rooms
        .where('categoryId', isEqualTo: categoryId)
        .where('status', isEqualTo: 'waiting')
        .orderBy('createdAt', descending: false)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return BattleRoom.fromQueryDocumentSnapshot(snap.docs.first);
  }

  /// Creates a new battle room with user1 as creator. Returns the room ID.
  Future<String> createRoom({
    required int categoryId,
    required String categoryName,
    required BattlePlayer user1,
    required List<QuizQuestion> questions,
    int entryFee = 0,
  }) async {
    final roomRef = _rooms.doc();
    await roomRef.set({
      'categoryId': categoryId,
      'categoryName': categoryName,
      'status': BattleStatus.waiting.value,
      'user1': user1.toMap(),
      'user2': null,
      'questions': questions.map((q) => q.toJson()).toList(),
      'entryFee': entryFee,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return roomRef.id;
  }

  /// User2 joins an existing waiting room → status becomes inProgress.
  Future<void> joinRoom({
    required String roomId,
    required BattlePlayer user2,
  }) async {
    await _rooms.doc(roomId).update({
      'user2': user2.toMap(),
      'status': BattleStatus.inProgress.value,
    });
  }

  /// Cancels a room (called when creator leaves before anyone joins).
  Future<void> cancelRoom(String roomId) =>
      _rooms.doc(roomId).update({'status': BattleStatus.cancelled.value});

  // ── Real-time Stream ───────────────────────────────────────────────────────

  Stream<BattleRoom> watchRoom(String roomId) => _rooms
      .doc(roomId)
      .snapshots()
      .where((snap) => snap.exists && snap.data() != null)
      .map(BattleRoom.fromSnapshot);

  // ── Progress Updates ───────────────────────────────────────────────────────

  /// Updates the player's progress after each answered question.
  Future<void> updateProgress({
    required String roomId,
    required bool isUser1,
    required int correctAnswers,
    required int answersCount,
  }) async {
    final slot = isUser1 ? 'user1' : 'user2';
    await _rooms.doc(roomId).update({
      '$slot.correctAnswers': correctAnswers,
      '$slot.answersCount': answersCount,
    });
  }

  /// Marks the player as finished with final score.
  Future<void> finishBattle({
    required String roomId,
    required bool isUser1,
    required int correctAnswers,
    required int score,
    required int answersCount,
  }) async {
    final slot = isUser1 ? 'user1' : 'user2';
    await _rooms.doc(roomId).update({
      '$slot.correctAnswers': correctAnswers,
      '$slot.score': score,
      '$slot.answersCount': answersCount,
      '$slot.finishedAt': FieldValue.serverTimestamp(),
      // Mark completed only when both finished; the listener handles this
    });
  }

  /// Marks the battle room status as completed.
  Future<void> markCompleted(String roomId) =>
      _rooms.doc(roomId).update({'status': BattleStatus.completed.value});
}
