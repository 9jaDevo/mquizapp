import 'package:flutterquiz/core/constants/api_body_parameter_labels.dart';

final class LeagueLeaderboardEntry {
  const LeagueLeaderboardEntry({
    this.userId,
    this.score,
    this.userRank,
    this.name,
    this.profile,
  });

  LeagueLeaderboardEntry.fromJson(Map<String, dynamic> json)
      : userId = json['user_id']?.toString(),
        score = json['score']?.toString(),
        userRank = json['user_rank']?.toString(),
        name = json['name'] as String?,
        profile = json[profileKey] as String?;

  final String? userId;
  final String? score;
  final String? userRank;
  final String? name;
  final String? profile;
}

final class LeagueLeaderboardResult {
  const LeagueLeaderboardResult({
    required this.total,
    required this.rows,
    this.myRank,
    this.myScore,
    required this.topThree,
  });

  final int total;
  final List<LeagueLeaderboardEntry> rows;
  final String? myRank;
  final String? myScore;
  final List<LeagueLeaderboardEntry> topThree;
}
