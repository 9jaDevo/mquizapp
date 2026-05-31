import 'package:mquiz/core/network/nestjs_api.dart';
import 'package:mquiz/features/partner_contests/models/partner_contest.dart';
import 'package:mquiz/features/partner_contests/models/partner_leaderboard.dart';
import 'package:mquiz/features/quiz/models/question_model.dart';

class PartnerContestRepository {
  PartnerContestRepository({NestJsApi? api}) : _api = api ?? NestJsApi.instance;
  final NestJsApi _api;

  Future<List<PartnerContest>> listContests() async {
    final list = await _api.listPartnerContests();
    return list.map(PartnerContest.fromJson).toList(growable: false);
  }

  Future<PartnerContest> getContest(int id) async {
    final map = await _api.getPartnerContest(id);
    return PartnerContest.fromJson(map);
  }

  Future<PartnerContest> lookupByCode(String code) async {
    final map = await _api.lookupPartnerContestByCode(code.trim().toUpperCase());
    return PartnerContest.fromJson(map);
  }

  Future<void> joinContest(int id) async {
    await _api.joinPartnerContest(id);
  }

  Future<List<QuizQuestion>> fetchQuestions(int id) async {
    final list = await _api.getPartnerContestQuestions(id);
    return list.map(QuizQuestion.fromJson).toList(growable: false);
  }

  Future<Map<String, dynamic>> submit({
    required int contestId,
    required List<SubmittedAnswer> answers,
    required int durationMs,
  }) async {
    return _api.submitPartnerContest(contestId, {
      'answers': answers.map((a) => a.toJson()).toList(growable: false),
      'durationMs': durationMs,
    });
  }

  Future<List<PartnerLeaderboardEntry>> fetchLeaderboard(
    int id, {
    int? currentUserId,
  }) async {
    final list = await _api.getPartnerContestLeaderboard(id);
    return list
        .map((m) => PartnerLeaderboardEntry.fromJson(m, currentUserId: currentUserId))
        .toList(growable: false);
  }
}
