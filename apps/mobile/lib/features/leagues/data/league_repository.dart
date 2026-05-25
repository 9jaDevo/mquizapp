import 'package:mquiz/core/network/nestjs_api.dart';
import 'package:mquiz/features/leaderboard/models/leaderboard_entry_model.dart';
import 'package:mquiz/features/leagues/models/league_model.dart';
import 'package:mquiz/features/quiz/models/question_model.dart';

class LeagueRepository {
  LeagueRepository({NestJsApi? api}) : _api = api ?? NestJsApi.instance;
  final NestJsApi _api;

  Future<List<League>> listLeagues() async {
    final list = await _api.listLeagues();
    return list.map(League.fromJson).toList(growable: false);
  }

  Future<League> fetchLeague(int id) async {
    final data = await _api.getLeague(id);
    return League.fromJson(data);
  }

  Future<LeagueMembership?> fetchMyMembership() async {
    final data = await _api.getMyLeague();
    if (data.isEmpty) return null;
    return LeagueMembership.fromJson(data);
  }

  Future<void> joinLeague(int id) async {
    await _api.optInLeague(id);
  }

  Future<List<QuizQuestion>> fetchTodayQuestions(int id) async {
    final data = await _api.getTodayLeagueQuestions(id);
    final raw = data['questions'];
    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((m) =>
              QuizQuestion.fromJson(Map<String, dynamic>.from(m)))
          .toList(growable: false);
    }
    return const [];
  }

  Future<Map<String, dynamic>> submitAnswers({
    required int leagueId,
    required List<SubmittedAnswer> answers,
    required int durationMs,
  }) async {
    final data = await _api.submitLeagueAnswers(leagueId, {
      'answers': answers.map((a) => a.toJson()).toList(growable: false),
      'durationMs': durationMs,
    });
    return data;
  }

  Future<List<LeaderboardEntry>> fetchLeaderboard(
    int id, {
    int? currentUserId,
  }) async {
    final list = await _api.getLeagueLeaderboard(id);
    return list
        .map((m) =>
            LeaderboardEntry.fromJson(m, currentUserId: currentUserId))
        .toList(growable: false);
  }
}
