import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/quiz/models/league_leaderboard.dart';
import 'package:flutterquiz/features/quiz/quiz_repository.dart';

sealed class LeagueLeaderboardState {
  const LeagueLeaderboardState();
}

final class LeagueLeaderboardInitial extends LeagueLeaderboardState {
  const LeagueLeaderboardInitial();
}

final class LeagueLeaderboardProgress extends LeagueLeaderboardState {
  const LeagueLeaderboardProgress();
}

final class LeagueLeaderboardSuccess extends LeagueLeaderboardState {
  const LeagueLeaderboardSuccess(
    this.rows, {
    required this.total,
    required this.topThree,
    required this.hasMore,
    required this.myRank,
    required this.myScore,
  });

  final List<LeagueLeaderboardEntry> rows;
  final List<LeagueLeaderboardEntry> topThree;
  final int total;
  final bool hasMore;
  final String? myRank;
  final String? myScore;
}

final class LeagueLeaderboardFailure extends LeagueLeaderboardState {
  const LeagueLeaderboardFailure(this.errorMessage);

  final String errorMessage;
}

final class LeagueLeaderboardCubit extends Cubit<LeagueLeaderboardState> {
  LeagueLeaderboardCubit(this._quizRepository)
      : super(const LeagueLeaderboardInitial());

  final QuizRepository _quizRepository;

  Future<void> getLeaderboard(String leagueId) async {
    emit(const LeagueLeaderboardProgress());

    await _quizRepository
        .getLeagueLeaderboard(leagueId: leagueId, limit: 15)
        .then((result) {
      emit(
        LeagueLeaderboardSuccess(
          result.rows,
          topThree: result.topThree,
          total: result.total,
          hasMore: result.total > result.rows.length,
          myRank: result.myRank,
          myScore: result.myScore,
        ),
      );
    }).catchError((Object e) {
      emit(LeagueLeaderboardFailure(e.toString()));
    });
  }

  Future<void> getMore(String leagueId) async {
    if (state is! LeagueLeaderboardSuccess) return;
    final current = state as LeagueLeaderboardSuccess;
    if (!current.hasMore) return;

    await _quizRepository
        .getLeagueLeaderboard(
          leagueId: leagueId,
          limit: 15,
          offset: current.rows.length,
        )
        .then((result) {
      final updated = <LeagueLeaderboardEntry>[...current.rows, ...result.rows];
      emit(
        LeagueLeaderboardSuccess(
          updated,
          topThree: current.topThree,
          total: current.total,
          hasMore: current.total > updated.length,
          myRank: result.myRank,
          myScore: result.myScore,
        ),
      );
    }).catchError((Object e) {
      emit(LeagueLeaderboardFailure(e.toString()));
    });
  }
}
