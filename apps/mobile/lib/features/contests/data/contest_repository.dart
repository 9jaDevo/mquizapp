import 'package:mquiz/core/network/nestjs_api.dart';
import 'package:mquiz/features/contests/models/contest_model.dart';
import 'package:mquiz/features/leaderboard/models/leaderboard_entry_model.dart';
import 'package:mquiz/features/quiz/models/question_model.dart';

class ContestRepository {
  ContestRepository({NestJsApi? api}) : _api = api ?? NestJsApi.instance;
  final NestJsApi _api;

  Future<List<Contest>> listContests() async {
    final list = await _api.listContests();
    return list.map(Contest.fromJson).toList(growable: false);
  }

  Future<List<QuizQuestion>> fetchQuestions(int id) async {
    final list = await _api.getContestQuestions(id);
    return list.map(QuizQuestion.fromJson).toList(growable: false);
  }

  Future<Map<String, dynamic>> submit({
    required int contestId,
    required List<SubmittedAnswer> answers,
    required int durationMs,
  }) async {
    return _api.submitContest(contestId, {
      'answers': answers.map((a) => a.toJson()).toList(growable: false),
      'durationMs': durationMs,
    });
  }

  Future<List<LeaderboardEntry>> fetchLeaderboard(
    int id, {
    int? currentUserId,
  }) async {
    final list = await _api.getContestLeaderboard(id);
    return list
        .map((m) =>
            LeaderboardEntry.fromJson(m, currentUserId: currentUserId))
        .toList(growable: false);
  }
}
