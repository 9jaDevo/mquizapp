import 'package:equatable/equatable.dart';
import 'package:mquiz/core/utils/parsers.dart';

class LeaderboardEntry extends Equatable {
  const LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.name,
    required this.score,
    this.profileImage,
    this.isMe = false,
  });

  factory LeaderboardEntry.fromJson(
    Map<String, dynamic> j, {
    int? currentUserId,
  }) {
    final id = parseIntOr(j['userId'] ?? j['id'], 0);
    return LeaderboardEntry(
      rank: parseIntOr(j['rank'], 0),
      userId: id,
      name: parseStringOr(j['name'], 'Anonymous'),
      score: parseIntOr(j['score'], 0),
      profileImage: parseString(j['profile'] ?? j['profileImage']),
      isMe: currentUserId != null && currentUserId == id,
    );
  }

  final int rank;
  final int userId;
  final String name;
  final int score;
  final String? profileImage;
  final bool isMe;

  @override
  List<Object?> get props => [rank, userId, name, score, isMe];
}
