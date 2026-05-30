import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mquiz/core/utils/error_handler.dart';
import 'package:mquiz/features/leaderboard/data/leaderboard_repository.dart';
import 'package:mquiz/features/leaderboard/models/leaderboard_entry_model.dart';

sealed class LeaderboardState extends Equatable {
  const LeaderboardState();
  @override
  List<Object?> get props => const [];
}

class LeaderboardInitial extends LeaderboardState {
  const LeaderboardInitial();
}

class LeaderboardLoading extends LeaderboardState {
  const LeaderboardLoading(this.period);
  final LeaderboardPeriod period;
  @override
  List<Object?> get props => [period];
}

class LeaderboardLoaded extends LeaderboardState {
  const LeaderboardLoaded({
    required this.period,
    required this.entries,
    required this.myRank,
  });
  final LeaderboardPeriod period;
  final List<LeaderboardEntry> entries;
  final Map<String, dynamic> myRank;
  @override
  List<Object?> get props => [period, entries, myRank];
}

class CategoryLeaderboardLoading extends LeaderboardState {
  const CategoryLeaderboardLoading(this.categoryId, this.period);
  final int categoryId;
  final LeaderboardPeriod period;
  @override
  List<Object?> get props => [categoryId, period];
}

class CategoryLeaderboardLoaded extends LeaderboardState {
  const CategoryLeaderboardLoaded({
    required this.categoryId,
    required this.period,
    required this.entries,
  });
  final int categoryId;
  final LeaderboardPeriod period;
  final List<LeaderboardEntry> entries;
  @override
  List<Object?> get props => [categoryId, period, entries];
}

class LeaderboardError extends LeaderboardState {
  const LeaderboardError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

class LeaderboardCubit extends Cubit<LeaderboardState> {
  LeaderboardCubit(this._repo) : super(const LeaderboardInitial());
  final LeaderboardRepository _repo;

  LeaderboardPeriod _period = LeaderboardPeriod.weekly;
  LeaderboardPeriod get period => _period;

  Future<void> load(LeaderboardPeriod period, {int? currentUserId}) async {
    _period = period;
    emit(LeaderboardLoading(period));
    try {
      final entries = await _repo.fetchTop(period, currentUserId: currentUserId);
      Map<String, dynamic> myRank = const {};
      try {
        myRank = await _repo.fetchMyRank();
      } catch (_) {
        // optional — not blocking
      }
      emit(LeaderboardLoaded(
        period: period,
        entries: entries,
        myRank: myRank,
      ));
    } catch (e) {
      emit(LeaderboardError(describeError(e)));
    }
  }

  Future<void> loadCategoryTop(
    int categoryId,
    LeaderboardPeriod period, {
    int? currentUserId,
  }) async {
    emit(CategoryLeaderboardLoading(categoryId, period));
    try {
      final entries = await _repo.fetchCategoryTop(
        categoryId,
        period,
        currentUserId: currentUserId,
      );
      emit(CategoryLeaderboardLoaded(
        categoryId: categoryId,
        period: period,
        entries: entries,
      ));
    } catch (e) {
      emit(LeaderboardError(describeError(e)));
    }
  }
}
