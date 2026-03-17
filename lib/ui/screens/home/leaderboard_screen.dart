import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/core/core.dart';
import 'package:flutterquiz/features/ads/blocs/interstitial_ad_cubit.dart';
import 'package:flutterquiz/features/ads/utils/ad_feature_flags.dart';
import 'package:flutterquiz/features/engagement/cubit/engagement_alltime_cubit.dart';
import 'package:flutterquiz/features/engagement/cubit/engagement_monthly_cubit.dart';
import 'package:flutterquiz/features/engagement/cubit/engagement_weekly_cubit.dart';
import 'package:flutterquiz/features/leaderboard/cubit/leaderboard_all_time_cubit.dart';
import 'package:flutterquiz/features/leaderboard/cubit/leaderboard_monthly_cubit.dart';
import 'package:flutterquiz/features/profile_management/cubits/user_details_cubit.dart';
import 'package:flutterquiz/ui/widgets/already_logged_in_dialog.dart';
import 'package:flutterquiz/ui/widgets/circular_progress_container.dart';
import 'package:flutterquiz/ui/widgets/custom_appbar.dart';
import 'package:flutterquiz/ui/widgets/error_container.dart';
import 'package:flutterquiz/ui/widgets/leaderboard/leaderboard_card_widget.dart';
import 'package:flutterquiz/ui/widgets/leaderboard/metric_toggle_widget.dart';
import 'package:flutterquiz/ui/widgets/leaderboard/scope_selector_widget.dart';
import 'package:flutterquiz/ui/widgets/leaderboard/time_filter_widget.dart';
import 'package:flutterquiz/ui/widgets/leaderboard/top_three_podium_widget.dart';
import 'package:flutterquiz/ui/widgets/leaderboard/user_position_card_widget.dart';

class LeaderBoardScreen extends StatefulWidget {
  const LeaderBoardScreen({super.key});

  @override
  State<LeaderBoardScreen> createState() => LeaderBoardScreenState();
}

enum LeaderboardScope { world, country, region }

enum LeaderboardMetric { score, engagement }

enum LeaderboardTimePeriod { week, month, allTime }

class LeaderBoardScreenState extends State<LeaderBoardScreen>
    with AutomaticKeepAliveClientMixin {
  static bool _shownInterstitialThisLaunch = false;
  // Filter states
  LeaderboardScope _selectedScope = LeaderboardScope.world;
  LeaderboardMetric _selectedMetric = LeaderboardMetric.score;
  LeaderboardTimePeriod _selectedTimePeriod = LeaderboardTimePeriod.allTime;

  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    // Initial data fetch
    Future.delayed(Duration.zero, () {
      _fetchLeaderboardData();
      _maybeShowInterstitialOncePerSession();
    });
  }

  Future<void> _maybeShowInterstitialOncePerSession() async {
    if (!AdFeatureFlags.isEnabled(AdFeatureFlags.utilityInterstitials) ||
        _shownInterstitialThisLaunch ||
        !mounted) {
      return;
    }

    _shownInterstitialThisLaunch = true;
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    await context.read<InterstitialAdCubit>().showAd(context);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.maxScrollExtent ==
        _scrollController.offset) {
      _fetchMoreData();
    }
  }

  String _getScopeFilterValue() {
    if (_selectedScope == LeaderboardScope.world) {
      return 'world';
    }

    // Get user's country code or continent from profile
    final userProfile = context.read<UserDetailsCubit>().getUserProfile();

    if (_selectedScope == LeaderboardScope.country) {
      // Return user's country code (will be added to UserProfile model)
      return userProfile.userId ??
          ''; // Placeholder until country_code is added
    } else {
      // Return user's continent (will be added to UserProfile model)
      return userProfile.userId ?? ''; // Placeholder until continent is added
    }
  }

  void _fetchLeaderboardData() {
    final scope = _selectedScope == LeaderboardScope.world
        ? 'world'
        : _getScopeFilterValue();

    if (_selectedMetric == LeaderboardMetric.engagement) {
      // Fetch engagement leaderboard
      if (_selectedTimePeriod == LeaderboardTimePeriod.week) {
        context.read<EngagementWeeklyCubit>().fetchEngagementLeaderboard(
          scope: _selectedScope == LeaderboardScope.world
              ? 'world'
              : _selectedScope == LeaderboardScope.country
              ? 'country'
              : 'region',
          filterValue: scope,
          limit: '20',
        );
      } else if (_selectedTimePeriod == LeaderboardTimePeriod.month) {
        context.read<EngagementMonthlyCubit>().fetchEngagementLeaderboard(
          scope: _selectedScope == LeaderboardScope.world
              ? 'world'
              : _selectedScope == LeaderboardScope.country
              ? 'country'
              : 'region',
          filterValue: scope,
          limit: '20',
        );
      } else {
        context.read<EngagementAllTimeCubit>().fetchEngagementLeaderboard(
          scope: _selectedScope == LeaderboardScope.world
              ? 'world'
              : _selectedScope == LeaderboardScope.country
              ? 'country'
              : 'region',
          filterValue: scope,
          limit: '20',
        );
      }
    } else {
      // Fetch score leaderboard
      if (_selectedTimePeriod == LeaderboardTimePeriod.month) {
        context.read<LeaderBoardMonthlyCubit>().fetchLeaderBoard('20');
      } else {
        context.read<LeaderBoardAllTimeCubit>().fetchLeaderBoard('20');
      }
      // Note: Weekly score leaderboard needs to be implemented in backend
    }
  }

  void _fetchMoreData() {
    final scope = _selectedScope == LeaderboardScope.world
        ? 'world'
        : _selectedScope == LeaderboardScope.country
        ? 'country'
        : 'region';
    final filterValue = _getScopeFilterValue();

    if (_selectedMetric == LeaderboardMetric.engagement) {
      if (_selectedTimePeriod == LeaderboardTimePeriod.week) {
        final cubit = context.read<EngagementWeeklyCubit>();
        final state = cubit.state;
        if (state is EngagementWeeklySuccess && state.hasMore) {
          cubit.fetchMoreData(
            scope: scope,
            filterValue: scope == 'world' ? null : filterValue,
            offset: state.leaderboardData.length.toString(),
          );
        }
      } else if (_selectedTimePeriod == LeaderboardTimePeriod.month) {
        final cubit = context.read<EngagementMonthlyCubit>();
        final state = cubit.state;
        if (state is EngagementMonthlySuccess && state.hasMore) {
          cubit.fetchMoreData(
            scope: scope,
            filterValue: scope == 'world' ? null : filterValue,
            offset: state.leaderboardData.length.toString(),
          );
        }
      } else {
        final cubit = context.read<EngagementAllTimeCubit>();
        final state = cubit.state;
        if (state is EngagementAllTimeSuccess && state.hasMore) {
          cubit.fetchMoreData(
            scope: scope,
            filterValue: scope == 'world' ? null : filterValue,
            offset: state.leaderboardData.length.toString(),
          );
        }
      }
    } else {
      if (_selectedTimePeriod == LeaderboardTimePeriod.month) {
        final cubit = context.read<LeaderBoardMonthlyCubit>();
        if (cubit.hasMoreData()) {
          cubit.fetchMoreLeaderBoardData('20');
        }
      } else {
        final cubit = context.read<LeaderBoardAllTimeCubit>();
        if (cubit.hasMoreData()) {
          cubit.fetchMoreLeaderBoardData('20');
        }
      }
    }
  }

  void _onScopeChanged(LeaderboardScope scope) {
    if (_selectedScope != scope) {
      setState(() {
        _selectedScope = scope;
      });
      _fetchLeaderboardData();
    }
  }

  void _onMetricChanged(LeaderboardMetric metric) {
    if (_selectedMetric != metric) {
      setState(() {
        _selectedMetric = metric;
      });
      _fetchLeaderboardData();
    }
  }

  void _onTimePeriodChanged(LeaderboardTimePeriod period) {
    if (_selectedTimePeriod != period) {
      setState(() {
        _selectedTimePeriod = period;
      });
      _fetchLeaderboardData();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: QAppBar(
        elevation: 0,
        noBottomRadius: true,
        title: Text(context.tr('leaderboardLbl')!),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Compact Filter Section with Liquid Glass Effect
          Container(
            margin: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.15),
                  Colors.white.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Scope Selector (World/Country/Region)
                ScopeSelectorWidget(
                  selectedScope: _selectedScope == LeaderboardScope.world
                      ? 'world'
                      : _selectedScope == LeaderboardScope.country
                      ? 'country'
                      : 'region',
                  onScopeChanged: (scope) {
                    _onScopeChanged(
                      scope == 'world'
                          ? LeaderboardScope.world
                          : scope == 'country'
                          ? LeaderboardScope.country
                          : LeaderboardScope.region,
                    );
                  },
                ),
                const SizedBox(height: 10),

                // Metric Toggle (Score/Engagement)
                MetricToggleWidget(
                  selectedMetricIndex:
                      _selectedMetric == LeaderboardMetric.score ? 0 : 1,
                  onMetricChanged: (index) {
                    _onMetricChanged(
                      index == 0
                          ? LeaderboardMetric.score
                          : LeaderboardMetric.engagement,
                    );
                  },
                ),
                const SizedBox(height: 10),

                // Time Filter (Week/Month/All Time)
                TimeFilterWidget(
                  selectedPeriod:
                      _selectedTimePeriod == LeaderboardTimePeriod.week
                      ? 'week'
                      : _selectedTimePeriod == LeaderboardTimePeriod.month
                      ? 'month'
                      : 'alltime',
                  onPeriodChanged: (period) {
                    _onTimePeriodChanged(
                      period == 'week'
                          ? LeaderboardTimePeriod.week
                          : period == 'month'
                          ? LeaderboardTimePeriod.month
                          : LeaderboardTimePeriod.allTime,
                    );
                  },
                ),
              ],
            ),
          ),

          // Leaderboard Content
          Expanded(
            child: _buildLeaderboardContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardContent() {
    if (_selectedMetric == LeaderboardMetric.engagement) {
      return _buildEngagementLeaderboard();
    } else {
      return _buildScoreLeaderboard();
    }
  }

  Widget _buildEngagementLeaderboard() {
    if (_selectedTimePeriod == LeaderboardTimePeriod.week) {
      return _buildEngagementWeekly();
    } else if (_selectedTimePeriod == LeaderboardTimePeriod.month) {
      return _buildEngagementMonthly();
    } else {
      return _buildEngagementAllTime();
    }
  }

  Widget _buildScoreLeaderboard() {
    if (_selectedTimePeriod == LeaderboardTimePeriod.month) {
      return _buildScoreMonthly();
    } else {
      return _buildScoreAllTime();
    }
    // Note: Weekly score leaderboard not yet implemented
  }

  Widget _buildEngagementWeekly() {
    return BlocConsumer<EngagementWeeklyCubit, EngagementWeeklyState>(
      listener: (context, state) {
        if (state is EngagementWeeklyFailure) {
          if (state.errorMessage == errorCodeUnauthorizedAccess) {
            showAlreadyLoggedInDialog(context);
          }
        }
      },
      builder: (context, state) {
        if (state is EngagementWeeklyFailure) {
          return ErrorContainer(
            showBackButton: false,
            errorMessage: convertErrorCodeToLanguageKey(state.errorMessage),
            onTapRetry: _fetchLeaderboardData,
            showErrorImage: true,
            errorMessageColor: const Color(0xFF1E90FF),
          );
        }

        if (state is EngagementWeeklySuccess) {
          if (state.leaderboardData.isEmpty && state.topThree.isEmpty) {
            return _noLeaderboard();
          }

          return _buildLeaderboardUI(
            entries: state.leaderboardData,
            topThree: state.topThree,
            myRank: state.myRank,
            hasMore: state.hasMore,
            isEngagement: true,
          );
        }

        return const Center(child: CircularProgressContainer());
      },
    );
  }

  Widget _buildEngagementMonthly() {
    return BlocConsumer<EngagementMonthlyCubit, EngagementMonthlyState>(
      listener: (context, state) {
        if (state is EngagementMonthlyFailure) {
          if (state.errorMessage == errorCodeUnauthorizedAccess) {
            showAlreadyLoggedInDialog(context);
          }
        }
      },
      builder: (context, state) {
        if (state is EngagementMonthlyFailure) {
          return ErrorContainer(
            showBackButton: false,
            errorMessage: convertErrorCodeToLanguageKey(state.errorMessage),
            onTapRetry: _fetchLeaderboardData,
            showErrorImage: true,
            errorMessageColor: const Color(0xFF1E90FF),
          );
        }

        if (state is EngagementMonthlySuccess) {
          if (state.leaderboardData.isEmpty && state.topThree.isEmpty) {
            return _noLeaderboard();
          }

          return _buildLeaderboardUI(
            entries: state.leaderboardData,
            topThree: state.topThree,
            myRank: state.myRank,
            hasMore: state.hasMore,
            isEngagement: true,
          );
        }

        return const Center(child: CircularProgressContainer());
      },
    );
  }

  Widget _buildEngagementAllTime() {
    return BlocConsumer<EngagementAllTimeCubit, EngagementAllTimeState>(
      listener: (context, state) {
        if (state is EngagementAllTimeFailure) {
          if (state.errorMessage == errorCodeUnauthorizedAccess) {
            showAlreadyLoggedInDialog(context);
          }
        }
      },
      builder: (context, state) {
        if (state is EngagementAllTimeFailure) {
          return ErrorContainer(
            showBackButton: false,
            errorMessage: convertErrorCodeToLanguageKey(state.errorMessage),
            onTapRetry: _fetchLeaderboardData,
            showErrorImage: true,
            errorMessageColor: const Color(0xFF1E90FF),
          );
        }

        if (state is EngagementAllTimeSuccess) {
          if (state.leaderboardData.isEmpty && state.topThree.isEmpty) {
            return _noLeaderboard();
          }

          return _buildLeaderboardUI(
            entries: state.leaderboardData,
            topThree: state.topThree,
            myRank: state.myRank,
            hasMore: state.hasMore,
            isEngagement: true,
          );
        }

        return const Center(child: CircularProgressContainer());
      },
    );
  }

  Widget _buildScoreMonthly() {
    return BlocConsumer<LeaderBoardMonthlyCubit, LeaderBoardMonthlyState>(
      listener: (context, state) {
        if (state is LeaderBoardMonthlyFailure) {
          if (state.errorMessage == errorCodeUnauthorizedAccess) {
            showAlreadyLoggedInDialog(context);
          }
        }
      },
      builder: (context, state) {
        if (state is LeaderBoardMonthlyFailure) {
          return ErrorContainer(
            showBackButton: false,
            errorMessage: convertErrorCodeToLanguageKey(state.errorMessage),
            onTapRetry: _fetchLeaderboardData,
            showErrorImage: true,
            errorMessageColor: const Color(0xFF1E90FF),
          );
        }

        if (state is LeaderBoardMonthlySuccess) {
          if (state.leaderBoardDetails.isEmpty) {
            return _noLeaderboard();
          }

          return _buildScoreLeaderboardUI(
            leaderboardList: state.leaderBoardDetails,
            hasMore: state.hasMore,
            rank: LeaderBoardMonthlyCubit.rankM,
            profile: LeaderBoardMonthlyCubit.profileM,
            score: LeaderBoardMonthlyCubit.scoreM,
          );
        }

        return const Center(child: CircularProgressContainer());
      },
    );
  }

  Widget _buildScoreAllTime() {
    return BlocConsumer<LeaderBoardAllTimeCubit, LeaderBoardAllTimeState>(
      listener: (context, state) {
        if (state is LeaderBoardAllTimeFailure) {
          if (state.errorMessage == errorCodeUnauthorizedAccess) {
            showAlreadyLoggedInDialog(context);
          }
        }
      },
      builder: (context, state) {
        if (state is LeaderBoardAllTimeFailure) {
          return ErrorContainer(
            showBackButton: false,
            errorMessage: convertErrorCodeToLanguageKey(state.errorMessage),
            onTapRetry: _fetchLeaderboardData,
            showErrorImage: true,
            errorMessageColor: const Color(0xFF1E90FF),
          );
        }

        if (state is LeaderBoardAllTimeSuccess) {
          if (state.leaderBoardDetails.isEmpty) {
            return _noLeaderboard();
          }

          return _buildScoreLeaderboardUI(
            leaderboardList: state.leaderBoardDetails,
            hasMore: state.hasMore,
            rank: LeaderBoardAllTimeCubit.rankA,
            profile: LeaderBoardAllTimeCubit.profileA,
            score: LeaderBoardAllTimeCubit.scoreA,
          );
        }

        return const Center(child: CircularProgressContainer());
      },
    );
  }

  Widget _noLeaderboard() => Center(
    child: ErrorContainer(
      topMargin: 0,
      errorMessage: 'noLeaderboardLbl',
      onTapRetry: _fetchLeaderboardData,
      showErrorImage: false,
    ),
  );

  Widget _buildLeaderboardUI({
    required List<Map<String, dynamic>> entries,
    required List<Map<String, dynamic>> topThree,
    required Map<String, dynamic>? myRank,
    required bool hasMore,
    required bool isEngagement,
  }) {
    if (entries.isEmpty && topThree.isEmpty) {
      return _noLeaderboard();
    }

    final currentUserId = context
        .read<UserDetailsCubit>()
        .getUserProfile()
        .userId;
    final sanitizedTopThree = topThree
        .where(
          (item) =>
              item['user_id'] != null && item['user_id'].toString().isNotEmpty,
        )
        .toList();
    final useFallbackTopThree = sanitizedTopThree.isEmpty;
    final resolvedTopThree = useFallbackTopThree
        ? entries.take(3).toList()
        : sanitizedTopThree;
    final topThreeIds = resolvedTopThree
        .map((e) => e['user_id']?.toString())
        .where((id) => id != null && id.isNotEmpty)
        .toSet();
    final remainingEntries = useFallbackTopThree
        ? (entries.length > 3 ? entries.sublist(3) : <Map<String, dynamic>>[])
        : entries
              .where(
                (item) => !topThreeIds.contains(item['user_id']?.toString()),
              )
              .toList();
    final myRankInt = myRank != null
        ? int.tryParse(myRank['user_rank']?.toString() ?? '0') ?? 0
        : 0;
    final showMyRank = myRank != null && myRankInt > 3;

    return RefreshIndicator(
      color: const Color(0xFF1E90FF),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      onRefresh: () async {
        await Future<void>.delayed(const Duration(milliseconds: 500));
        _fetchLeaderboardData();
      },
      child: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // Top 3 Podium
                if (topThree.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      child: TopThreePodiumWidget(
                        topThree: resolvedTopThree,
                        isEngagement: isEngagement,
                      ),
                    ),
                  ),

                // Remaining entries
                if (remainingEntries.isNotEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (hasMore && index == remainingEntries.length - 1) {
                            return const Padding(
                              padding: EdgeInsets.all(20),
                              child: Center(child: CircularProgressContainer()),
                            );
                          }

                          if (index >= remainingEntries.length) {
                            return null;
                          }

                          final entry = remainingEntries[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: LeaderboardCardWidget(
                              rank: entry['user_rank']?.toString() ?? '0',
                              name: entry['name']?.toString() ?? '',
                              profile: entry['profile']?.toString() ?? '',
                              value: _formatEngagementMinutes(
                                entry['total_minutes']?.toString() ?? '0',
                              ),
                              isCurrentUser: entry['user_id'] == currentUserId,
                              isEngagement: isEngagement,
                              countryCode: entry['country_code']?.toString(),
                            ),
                          );
                        },
                        childCount: remainingEntries.length,
                      ),
                    ),
                  ),

                // Bottom padding for user position card
                if (showMyRank)
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),

          // User Position Card (sticky at bottom)
          if (showMyRank)
            UserPositionCardWidget(
              rank: myRank['user_rank']?.toString() ?? '0',
              name: myRank['name']?.toString() ?? '',
              profile: myRank['profile']?.toString() ?? '',
              value: _formatEngagementMinutes(
                myRank['total_minutes']?.toString() ?? '0',
              ),
              isEngagement: isEngagement,
              countryCode: myRank['country_code']?.toString(),
            ),
        ],
      ),
    );
  }

  Widget _buildScoreLeaderboardUI({
    required List<Map<String, dynamic>> leaderboardList,
    required bool hasMore,
    required String rank,
    required String profile,
    required String score,
  }) {
    final currentUserId = context
        .read<UserDetailsCubit>()
        .getUserProfile()
        .userId;
    final topThree = leaderboardList.take(3).toList();
    final remainingEntries = leaderboardList.length > 3
        ? leaderboardList.sublist(3)
        : <Map<String, dynamic>>[];
    final showMyRank =
        score != '0' && int.tryParse(rank) != null && int.parse(rank) > 3;

    return RefreshIndicator(
      color: const Color(0xFF1E90FF),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      onRefresh: () async {
        await Future<void>.delayed(const Duration(milliseconds: 500));
        _fetchLeaderboardData();
      },
      child: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // Top 3 Podium
                if (topThree.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      child: TopThreePodiumWidget(
                        topThree: topThree,
                        isEngagement: false,
                      ),
                    ),
                  ),

                // Remaining entries
                if (remainingEntries.isNotEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (hasMore && index == remainingEntries.length - 1) {
                            return const Padding(
                              padding: EdgeInsets.all(20),
                              child: Center(child: CircularProgressContainer()),
                            );
                          }

                          if (index >= remainingEntries.length) {
                            return null;
                          }

                          final entry = remainingEntries[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: LeaderboardCardWidget(
                              rank: entry['user_rank']?.toString() ?? '0',
                              name: entry['name']?.toString() ?? '...',
                              profile: entry['profile']?.toString() ?? '',
                              value: entry['score']?.toString() ?? '0',
                              isCurrentUser: entry['user_id'] == currentUserId,
                              isEngagement: false,
                              countryCode:
                                  '', // Not available in current score API
                            ),
                          );
                        },
                        childCount: remainingEntries.length,
                      ),
                    ),
                  ),

                // Bottom padding for user position card
                if (showMyRank)
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),

          // User Position Card (sticky at bottom)
          if (showMyRank)
            UserPositionCardWidget(
              rank: rank,
              name:
                  context.read<UserDetailsCubit>().getUserProfile().name ??
                  'You',
              profile: profile,
              value: score,
              isEngagement: false,
              countryCode: '', // Not available in current score API
            ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  String _formatEngagementMinutes(String minutes) {
    final totalMinutes = double.tryParse(minutes) ?? 0.0;
    final hours = (totalMinutes / 60).floor();
    final mins = (totalMinutes % 60).round();

    if (hours > 0) {
      return '${hours}h ${mins}m';
    }
    return '${mins}m';
  }
}
