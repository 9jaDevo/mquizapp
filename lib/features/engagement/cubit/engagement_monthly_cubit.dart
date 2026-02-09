import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/engagement_repository.dart';

/// States for monthly engagement leaderboard
abstract class EngagementMonthlyState {}

class EngagementMonthlyInitial extends EngagementMonthlyState {}

class EngagementMonthlyProgress extends EngagementMonthlyState {}

class EngagementMonthlySuccess extends EngagementMonthlyState {
  final List<Map<String, dynamic>> leaderboardData;
  final List<Map<String, dynamic>> topThree;
  final Map<String, dynamic>? myRank;
  final int total;
  final bool hasMore;

  EngagementMonthlySuccess({
    required this.leaderboardData,
    required this.topThree,
    required this.myRank,
    required this.total,
    required this.hasMore,
  });
}

class EngagementMonthlyFailure extends EngagementMonthlyState {
  final String errorMessage;

  EngagementMonthlyFailure(this.errorMessage);
}

/// Cubit for managing monthly engagement leaderboard
class EngagementMonthlyCubit extends Cubit<EngagementMonthlyState> {
  final EngagementRepository _engagementRepository;

  EngagementMonthlyCubit(this._engagementRepository)
    : super(EngagementMonthlyInitial());

  /// Fetch monthly engagement leaderboard
  Future<void> fetchEngagementLeaderboard({
    required String scope,
    String? filterValue,
    String limit = '20',
  }) async {
    emit(EngagementMonthlyProgress());
    try {
      final result = await _engagementRepository
          .getMonthlyEngagementLeaderboard(
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
          EngagementMonthlySuccess(
            leaderboardData: leaderboardData,
            topThree: topThree,
            myRank: myRank,
            total: total,
            hasMore: otherUsersRank.length >= int.parse(limit),
          ),
        );
      } else {
        emit(
          EngagementMonthlyFailure(
            (result['message'] ?? 'Failed to fetch leaderboard').toString(),
          ),
        );
      }
    } catch (e) {
      emit(EngagementMonthlyFailure(e.toString()));
    }
  }

  /// Fetch more leaderboard data (pagination)
  Future<void> fetchMoreData({
    required String scope,
    String? filterValue,
    required String offset,
    String limit = '20',
  }) async {
    if (state is EngagementMonthlySuccess) {
      try {
        final currentState = state as EngagementMonthlySuccess;

        final result = await _engagementRepository
            .getMonthlyEngagementLeaderboard(
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
            EngagementMonthlySuccess(
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
