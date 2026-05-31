import 'package:equatable/equatable.dart';
import 'package:mquiz/core/utils/parsers.dart';

class PartnerLeaderboardEntry extends Equatable {
  const PartnerLeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.displayName,
    required this.score,
    required this.correctAnswers,
    required this.timeTakenMs,
    this.avatarUrl,
    this.isCurrentUser = false,
  });

  final int rank;
  final int userId;
  final String displayName;
  final double score;
  final int correctAnswers;
  final int timeTakenMs;
  final String? avatarUrl;
  final bool isCurrentUser;

  factory PartnerLeaderboardEntry.fromJson(
    Map<String, dynamic> j, {
    int? currentUserId,
  }) =>
      PartnerLeaderboardEntry(
        rank: parseIntOr(j['rank'], 0),
        userId: parseIntOr(j['userId'], 0),
        displayName: parseStringOr(j['displayName'], 'User'),
        score: (j['score'] as num?)?.toDouble() ?? 0.0,
        correctAnswers: parseIntOr(j['correctAnswers'], 0),
        timeTakenMs: parseIntOr(j['timeTakenMs'], 0),
        avatarUrl: parseString(j['avatarUrl']),
        isCurrentUser:
            currentUserId != null && parseIntOr(j['userId'], -1) == currentUserId,
      );

  String get formattedTime {
    final secs = timeTakenMs ~/ 1000;
    if (secs < 60) return '${secs}s';
    return '${secs ~/ 60}m ${secs % 60}s';
  }

  @override
  List<Object?> get props =>
      [rank, userId, displayName, score, correctAnswers, timeTakenMs, avatarUrl, isCurrentUser];
}
