import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mquiz/core/utils/error_handler.dart';
import 'package:mquiz/features/partner_contests/data/partner_contest_repository.dart';
import 'package:mquiz/features/partner_contests/models/partner_contest.dart';
import 'package:mquiz/features/partner_contests/models/partner_leaderboard.dart';

// ── List ────────────────────────────────────────────────────────────────────
sealed class PartnerContestListState extends Equatable {
  const PartnerContestListState();
  @override
  List<Object?> get props => const [];
}

final class PartnerContestListInitial extends PartnerContestListState {
  const PartnerContestListInitial();
}

final class PartnerContestListLoading extends PartnerContestListState {
  const PartnerContestListLoading();
}

final class PartnerContestListLoaded extends PartnerContestListState {
  const PartnerContestListLoaded(this.contests);
  final List<PartnerContest> contests;
  @override
  List<Object?> get props => [contests];
}

final class PartnerContestListError extends PartnerContestListState {
  const PartnerContestListError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

class PartnerContestListCubit extends Cubit<PartnerContestListState> {
  PartnerContestListCubit(this._repo) : super(const PartnerContestListInitial());
  final PartnerContestRepository _repo;

  Future<void> load() async {
    emit(const PartnerContestListLoading());
    try {
      emit(PartnerContestListLoaded(await _repo.listContests()));
    } catch (e) {
      emit(PartnerContestListError(describeError(e)));
    }
  }
}

// ── Detail ──────────────────────────────────────────────────────────────────
sealed class PartnerContestDetailState extends Equatable {
  const PartnerContestDetailState();
  @override
  List<Object?> get props => const [];
}

final class PartnerContestDetailInitial extends PartnerContestDetailState {
  const PartnerContestDetailInitial();
}

final class PartnerContestDetailLoading extends PartnerContestDetailState {
  const PartnerContestDetailLoading();
}

final class PartnerContestDetailLoaded extends PartnerContestDetailState {
  const PartnerContestDetailLoaded({
    required this.contest,
    required this.leaderboard,
  });
  final PartnerContest contest;
  final List<PartnerLeaderboardEntry> leaderboard;
  @override
  List<Object?> get props => [contest, leaderboard];
}

final class PartnerContestDetailError extends PartnerContestDetailState {
  const PartnerContestDetailError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

// Joined event emitted so screens can navigate to quiz
final class PartnerContestJoined extends PartnerContestDetailState {
  const PartnerContestJoined(this.contest);
  final PartnerContest contest;
  @override
  List<Object?> get props => [contest];
}

class PartnerContestDetailCubit extends Cubit<PartnerContestDetailState> {
  PartnerContestDetailCubit(this._repo) : super(const PartnerContestDetailInitial());
  final PartnerContestRepository _repo;

  Future<void> load(int id, {int? currentUserId}) async {
    emit(const PartnerContestDetailLoading());
    try {
      final results = await Future.wait([
        _repo.getContest(id),
        _repo.fetchLeaderboard(id, currentUserId: currentUserId),
      ]);
      emit(PartnerContestDetailLoaded(
        contest: results[0] as PartnerContest,
        leaderboard: results[1] as List<PartnerLeaderboardEntry>,
      ));
    } catch (e) {
      emit(PartnerContestDetailError(describeError(e)));
    }
  }

  Future<void> join(int id) async {
    try {
      await _repo.joinContest(id);
      final contest = await _repo.getContest(id);
      emit(PartnerContestJoined(contest));
    } catch (e) {
      emit(PartnerContestDetailError(describeError(e)));
    }
  }
}

// ── Join by Code ─────────────────────────────────────────────────────────────
sealed class PartnerJoinCodeState extends Equatable {
  const PartnerJoinCodeState();
  @override
  List<Object?> get props => const [];
}

final class PartnerJoinCodeIdle extends PartnerJoinCodeState {
  const PartnerJoinCodeIdle();
}

final class PartnerJoinCodeLoading extends PartnerJoinCodeState {
  const PartnerJoinCodeLoading();
}

final class PartnerJoinCodeFound extends PartnerJoinCodeState {
  const PartnerJoinCodeFound(this.contest);
  final PartnerContest contest;
  @override
  List<Object?> get props => [contest];
}

final class PartnerJoinCodeError extends PartnerJoinCodeState {
  const PartnerJoinCodeError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

class PartnerJoinCodeCubit extends Cubit<PartnerJoinCodeState> {
  PartnerJoinCodeCubit(this._repo) : super(const PartnerJoinCodeIdle());
  final PartnerContestRepository _repo;

  Future<void> lookup(String code) async {
    if (code.trim().isEmpty) return;
    emit(const PartnerJoinCodeLoading());
    try {
      emit(PartnerJoinCodeFound(await _repo.lookupByCode(code)));
    } catch (e) {
      emit(PartnerJoinCodeError(describeError(e)));
    }
  }

  void reset() => emit(const PartnerJoinCodeIdle());
}
