import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/engagement_repository.dart';

/// States for weekly engagement leaderboard
abstract class EngagementWeeklyState {}

class EngagementWeeklyInitial extends EngagementWeeklyState {}

class EngagementWeeklyProgress extends EngagementWeeklyState {}

class EngagementWeeklySuccess extends EngagementWeeklyState {
  final List<Map<String, dynamic>> leaderboardData;
  final List<Map<String, dynamic>> topThree;
  final Map<String, dynamic>? myRank;
  final int total;
  final bool hasMore;

  EngagementWeeklySuccess({
    required this.leaderboardData,
    required this.topThree,
    required this.myRank,
    required this.total,
    required this.hasMore,
  });
}

class EngagementWeeklyFailure extends EngagementWeeklyState {
  final String errorMessage;

  EngagementWeeklyFailure(this.errorMessage);
}

/// Cubit for managing weekly engagement leaderboard
class EngagementWeeklyCubit extends Cubit<EngagementWeeklyState> {
  final EngagementRepository _engagementRepository;

  EngagementWeeklyCubit(this._engagementRepository)
    : super(EngagementWeeklyInitial());

  /// Fetch weekly engagement leaderboard
  Future<void> fetchEngagementLeaderboard({
    required String scope,
    String? filterValue,
    String limit = '20',
  }) async {
    emit(EngagementWeeklyProgress());
    try {
      final result = await _engagementRepository.getWeeklyEngagementLeaderboard(
        offset: '0',
        limit: limit,
        scope: scope,
        filterValue: filterValue,
      );

      if (result['error'] == false) {
        final data = result['data'] as Map<String, dynamic>;
        final otherUsersRank =
            (data['other_users_rank'] ?? <dynamic>[]) as List<dynamic>;
        final total = int.tryParse(result['total']?.toString() ?? '0') ?? 0;

        final leaderboardData =
            otherUsersRank.map((e) => e as Map<String, dynamic>).toList();
        final topThree = (data['top_three_ranks'] as List?)
                ?.map((e) => e as Map<String, dynamic>)
                .toList() ??
            <Map<String, dynamic>>[];
        final myRank = data['my_rank'] is Map<String, dynamic>
            ? data['my_rank'] as Map<String, dynamic>
            : null;

        emit(
          EngagementWeeklySuccess(
            leaderboardData: leaderboardData,
            topThree: topThree,
            myRank: myRank,
            total: total,
            hasMore: otherUsersRank.length >= int.parse(limit),
          ),
        );
      } else {
        emit(
          EngagementWeeklyFailure(
            (result['message'] ?? 'Failed to fetch leaderboard').toString(),
          ),
        );
      }
    } catch (e) {
      emit(EngagementWeeklyFailure(e.toString()));
    }
  }

  /// Fetch more leaderboard data (pagination)
  Future<void> fetchMoreData({
    required String scope,
    String? filterValue,
    required String offset,
    String limit = '20',
  }) async {
    if (state is EngagementWeeklySuccess) {
      try {
        final currentState = state as EngagementWeeklySuccess;

        final result = await _engagementRepository
            .getWeeklyEngagementLeaderboard(
              offset: offset,
              limit: limit,
              scope: scope,
              filterValue: filterValue,
            );

        if (result['error'] == false) {
          final data = result['data'] as Map<String, dynamic>;
          final otherUsersRank =
              (data['other_users_rank'] ?? <dynamic>[]) as List<dynamic>;

          final updatedData = [
            ...currentState.leaderboardData,
            ...otherUsersRank.map((e) => e as Map<String, dynamic>),
          ];

          emit(
            EngagementWeeklySuccess(
              leaderboardData: updatedData,
              topThree: currentState.topThree,
              myRank: currentState.myRank,
              total: currentState.total,
              hasMore: otherUsersRank.length >= int.parse(limit),
            ),
          );
        }
      } catch (e) {
        // Keep current state, just log error
        print('Error fetching more data: $e');
      }
    }
  }
}
