import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mquiz/core/utils/error_handler.dart';
import 'package:mquiz/features/leaderboard/models/leaderboard_entry_model.dart';
import 'package:mquiz/features/leagues/data/league_repository.dart';
import 'package:mquiz/features/leagues/models/league_model.dart';

// ── List ────────────────────────────────────────────────────────────────────
sealed class LeaguesListState extends Equatable {
  const LeaguesListState();
  @override
  List<Object?> get props => const [];
}

final class LeaguesListInitial extends LeaguesListState {
  const LeaguesListInitial();
}

final class LeaguesListLoading extends LeaguesListState {
  const LeaguesListLoading();
}

final class LeaguesListLoaded extends LeaguesListState {
  const LeaguesListLoaded({required this.leagues, this.membership});
  final List<League> leagues;
  final LeagueMembership? membership;
  @override
  List<Object?> get props => [leagues, membership];
}

final class LeaguesListError extends LeaguesListState {
  const LeaguesListError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

class LeaguesListCubit extends Cubit<LeaguesListState> {
  LeaguesListCubit(this._repo) : super(const LeaguesListInitial());
  final LeagueRepository _repo;

  Future<void> load() async {
    emit(const LeaguesListLoading());
    try {
      final leagues = await _repo.listLeagues();
      LeagueMembership? membership;
      try {
        membership = await _repo.fetchMyMembership();
      } catch (_) {
        membership = null;
      }
      emit(LeaguesListLoaded(leagues: leagues, membership: membership));
    } catch (e) {
      emit(LeaguesListError(describeError(e)));
    }
  }
}

// ── Detail ──────────────────────────────────────────────────────────────────
sealed class LeagueDetailState extends Equatable {
  const LeagueDetailState();
  @override
  List<Object?> get props => const [];
}

final class LeagueDetailInitial extends LeagueDetailState {
  const LeagueDetailInitial();
}

final class LeagueDetailLoading extends LeagueDetailState {
  const LeagueDetailLoading();
}

final class LeagueDetailLoaded extends LeagueDetailState {
  const LeagueDetailLoaded({
    required this.league,
    required this.entries,
    this.joining = false,
  });
  final League league;
  final List<LeaderboardEntry> entries;
  final bool joining;

  LeagueDetailLoaded copyWith({
    League? league,
    List<LeaderboardEntry>? entries,
    bool? joining,
  }) =>
      LeagueDetailLoaded(
        league: league ?? this.league,
        entries: entries ?? this.entries,
        joining: joining ?? this.joining,
      );

  @override
  List<Object?> get props => [league, entries, joining];
}

final class LeagueDetailError extends LeagueDetailState {
  const LeagueDetailError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

class LeagueDetailCubit extends Cubit<LeagueDetailState> {
  LeagueDetailCubit(this._repo) : super(const LeagueDetailInitial());
  final LeagueRepository _repo;

  Future<void> load(int id, {int? currentUserId}) async {
    emit(const LeagueDetailLoading());
    try {
      final results = await Future.wait([
        _repo.fetchLeague(id),
        _repo.fetchLeaderboard(id, currentUserId: currentUserId),
      ]);
      emit(LeagueDetailLoaded(
        league: results[0] as League,
        entries: results[1] as List<LeaderboardEntry>,
      ));
    } catch (e) {
      emit(LeagueDetailError(describeError(e)));
    }
  }

  Future<bool> join() async {
    final current = state;
    if (current is! LeagueDetailLoaded || current.joining) return false;
    emit(current.copyWith(joining: true));
    try {
      await _repo.joinLeague(current.league.id);
      final league = await _repo.fetchLeague(current.league.id);
      emit(LeagueDetailLoaded(league: league, entries: current.entries));
      return true;
    } catch (e) {
      emit(LeagueDetailError(describeError(e)));
      return false;
    }
  }
}
