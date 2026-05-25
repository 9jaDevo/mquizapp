import 'package:mquiz/core/network/nestjs_api.dart';
import 'package:mquiz/features/leaderboard/models/leaderboard_entry_model.dart';

enum LeaderboardPeriod { daily, weekly, monthly }

extension LeaderboardPeriodX on LeaderboardPeriod {
  String get path => switch (this) {
        LeaderboardPeriod.daily => 'daily',
        LeaderboardPeriod.weekly => 'weekly',
        LeaderboardPeriod.monthly => 'monthly',
      };

  String get label => switch (this) {
        LeaderboardPeriod.daily => 'Daily',
        LeaderboardPeriod.weekly => 'Weekly',
        LeaderboardPeriod.monthly => 'Monthly',
      };
}

class LeaderboardRepository {
  LeaderboardRepository({NestJsApi? api}) : _api = api ?? NestJsApi.instance;
  final NestJsApi _api;

  Future<List<LeaderboardEntry>> fetchTop(
    LeaderboardPeriod period, {
    int limit = 50,
    int? currentUserId,
  }) async {
    final raw = await _api.getLeaderboard(period.path, limit: limit);
    return raw
        .map((j) => LeaderboardEntry.fromJson(j, currentUserId: currentUserId))
        .toList(growable: false);
  }

  Future<Map<String, dynamic>> fetchMyRank() => _api.getMyLeaderboardRank();
}
