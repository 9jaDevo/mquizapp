import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mquiz/core/utils/error_handler.dart';
import 'package:mquiz/features/contests/data/contest_repository.dart';
import 'package:mquiz/features/contests/models/contest_model.dart';
import 'package:mquiz/features/leaderboard/models/leaderboard_entry_model.dart';

// ── List ────────────────────────────────────────────────────────────────────
sealed class ContestsListState extends Equatable {
  const ContestsListState();
  @override
  List<Object?> get props => const [];
}

final class ContestsListInitial extends ContestsListState {
  const ContestsListInitial();
}

final class ContestsListLoading extends ContestsListState {
  const ContestsListLoading();
}

final class ContestsListLoaded extends ContestsListState {
  const ContestsListLoaded(this.contests);
  final List<Contest> contests;
  @override
  List<Object?> get props => [contests];
}

final class ContestsListError extends ContestsListState {
  const ContestsListError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

class ContestsListCubit extends Cubit<ContestsListState> {
  ContestsListCubit(this._repo) : super(const ContestsListInitial());
  final ContestRepository _repo;

  Future<void> load() async {
    emit(const ContestsListLoading());
    try {
      emit(ContestsListLoaded(await _repo.listContests()));
    } catch (e) {
      emit(ContestsListError(describeError(e)));
    }
  }
}

// ── Detail ──────────────────────────────────────────────────────────────────
sealed class ContestDetailState extends Equatable {
  const ContestDetailState();
  @override
  List<Object?> get props => const [];
}

final class ContestDetailInitial extends ContestDetailState {
  const ContestDetailInitial();
}

final class ContestDetailLoading extends ContestDetailState {
  const ContestDetailLoading();
}

final class ContestDetailLoaded extends ContestDetailState {
  const ContestDetailLoaded({
    required this.contest,
    required this.leaderboard,
  });
  final Contest contest;
  final List<LeaderboardEntry> leaderboard;
  @override
  List<Object?> get props => [contest, leaderboard];
}

final class ContestDetailError extends ContestDetailState {
  const ContestDetailError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

class ContestDetailCubit extends Cubit<ContestDetailState> {
  ContestDetailCubit(this._repo) : super(const ContestDetailInitial());
  final ContestRepository _repo;

  Future<void> load(Contest contest, {int? currentUserId}) async {
    emit(const ContestDetailLoading());
    try {
      final lb = await _repo.fetchLeaderboard(contest.id,
          currentUserId: currentUserId);
      emit(ContestDetailLoaded(contest: contest, leaderboard: lb));
    } catch (e) {
      emit(ContestDetailError(describeError(e)));
    }
  }

  /// Deep-link entry point: loads a contest by ID without a pre-fetched object.
  /// Fetches the contest list and picks the matching one, or creates a stub if
  /// not found so the leaderboard can still be displayed.
  Future<void> loadById(int id, {int? currentUserId}) async {
    emit(const ContestDetailLoading());
    try {
      final all = await _repo.listContests();
      final contest = all.firstWhere(
        (c) => c.id == id,
        orElse: () => Contest(id: id, name: 'Contest #$id'),
      );
      final lb = await _repo.fetchLeaderboard(id, currentUserId: currentUserId);
      emit(ContestDetailLoaded(contest: contest, leaderboard: lb));
    } catch (e) {
      emit(ContestDetailError(describeError(e)));
    }
  }
}
