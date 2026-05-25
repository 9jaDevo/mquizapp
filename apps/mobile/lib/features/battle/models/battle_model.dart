import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:mquiz/core/utils/parsers.dart';
import 'package:mquiz/features/quiz/models/question_model.dart';

// ── Battle Player ─────────────────────────────────────────────────────────────

class BattlePlayer extends Equatable {
  const BattlePlayer({
    required this.uid,
    required this.userId,
    required this.displayName,
    this.photoUrl,
    this.isReady = false,
    this.correctAnswers = 0,
    this.score = 0,
    this.answersCount = 0,
    this.finishedAt,
  });

  final String uid;

  /// mQuiz backend user ID (int as string).
  final String userId;

  final String displayName;
  final String? photoUrl;
  final bool isReady;
  final int correctAnswers;
  final int score;
  final int answersCount;
  final DateTime? finishedAt;

  bool get hasFinished => finishedAt != null;

  factory BattlePlayer.fromMap(Map<String, dynamic> m) => BattlePlayer(
        uid: parseStringOr(m['uid'], ''),
        userId: parseStringOr(m['userId'], ''),
        displayName: parseStringOr(m['displayName'], 'Player'),
        photoUrl: parseString(m['photoUrl']),
        isReady: parseBool(m['isReady']),
        correctAnswers: parseIntOr(m['correctAnswers'], 0),
        score: parseIntOr(m['score'], 0),
        answersCount: parseIntOr(m['answersCount'], 0),
        finishedAt: (m['finishedAt'] as Timestamp?)?.toDate(),
      );

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'userId': userId,
        'displayName': displayName,
        'photoUrl': photoUrl,
        'isReady': isReady,
        'correctAnswers': correctAnswers,
        'score': score,
        'answersCount': answersCount,
        'finishedAt':
            finishedAt != null ? Timestamp.fromDate(finishedAt!) : null,
      };

  BattlePlayer copyWith({
    bool? isReady,
    int? correctAnswers,
    int? score,
    int? answersCount,
    DateTime? finishedAt,
  }) =>
      BattlePlayer(
        uid: uid,
        userId: userId,
        displayName: displayName,
        photoUrl: photoUrl,
        isReady: isReady ?? this.isReady,
        correctAnswers: correctAnswers ?? this.correctAnswers,
        score: score ?? this.score,
        answersCount: answersCount ?? this.answersCount,
        finishedAt: finishedAt ?? this.finishedAt,
      );

  @override
  List<Object?> get props =>
      [uid, correctAnswers, score, answersCount, isReady, finishedAt];
}

// ── Battle Status ─────────────────────────────────────────────────────────────

enum BattleStatus { waiting, inProgress, completed, cancelled, unknown }

extension BattleStatusX on BattleStatus {
  static BattleStatus fromString(String s) => switch (s) {
        'waiting' => BattleStatus.waiting,
        'inProgress' => BattleStatus.inProgress,
        'completed' => BattleStatus.completed,
        'cancelled' => BattleStatus.cancelled,
        _ => BattleStatus.unknown,
      };

  String get value => switch (this) {
        BattleStatus.waiting => 'waiting',
        BattleStatus.inProgress => 'inProgress',
        BattleStatus.completed => 'completed',
        BattleStatus.cancelled => 'cancelled',
        BattleStatus.unknown => 'unknown',
      };
}

// ── Battle Room ───────────────────────────────────────────────────────────────

class BattleRoom extends Equatable {
  const BattleRoom({
    required this.id,
    required this.categoryId,
    required this.categoryName,
    required this.status,
    required this.user1,
    required this.createdAt,
    required this.entryFee,
    this.user2,
    this.questions = const [],
  });

  final String id;
  final int categoryId;
  final String categoryName;
  final BattleStatus status;
  final BattlePlayer user1;
  final BattlePlayer? user2;

  /// Questions for this battle session (stored in Firestore by room creator).
  final List<QuizQuestion> questions;
  final DateTime createdAt;
  final int entryFee;

  bool get isFull => user2 != null;
  bool get bothFinished =>
      user1.hasFinished && (user2?.hasFinished ?? false);

  factory BattleRoom.fromSnapshot(
          DocumentSnapshot<Map<String, dynamic>> snap) =>
      _fromData(snap.id, snap.data()!);

  factory BattleRoom.fromQueryDocumentSnapshot(
          QueryDocumentSnapshot<Map<String, dynamic>> snap) =>
      _fromData(snap.id, snap.data());

  static BattleRoom _fromData(String id, Map<String, dynamic> m) {
    final rawQ = (m['questions'] as List<dynamic>? ?? []);
    final questions = rawQ
        .whereType<Map>()
        .map((q) => QuizQuestion.fromJson(Map<String, dynamic>.from(q)))
        .toList(growable: false);

    return BattleRoom(
      id: id,
      categoryId: parseIntOr(m['categoryId'], 0),
      categoryName: parseStringOr(m['categoryName'], 'Battle'),
      status: BattleStatusX.fromString(
          parseStringOr(m['status'], 'unknown')),
      user1: BattlePlayer.fromMap(
          Map<String, dynamic>.from(m['user1'] as Map? ?? {})),
      user2: m['user2'] != null
          ? BattlePlayer.fromMap(
              Map<String, dynamic>.from(m['user2'] as Map))
          : null,
      questions: questions,
      createdAt:
          (m['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      entryFee: parseIntOr(m['entryFee'], 0),
    );
  }

  @override
  List<Object?> get props => [id, status, user1, user2];
}

// ── Battle Result ─────────────────────────────────────────────────────────────

class BattleResult extends Equatable {
  const BattleResult({
    required this.roomId,
    required this.myPlayer,
    required this.opponent,
    required this.questions,
    required this.didWin,
  });

  final String roomId;
  final BattlePlayer myPlayer;
  final BattlePlayer opponent;
  final List<QuizQuestion> questions;
  final bool didWin;

  bool get isDraw => myPlayer.correctAnswers == opponent.correctAnswers;

  @override
  List<Object?> get props => [roomId, didWin];
}
