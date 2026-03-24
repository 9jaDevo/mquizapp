import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/commons/commons.dart';
import 'package:flutterquiz/core/core.dart';
import 'package:flutterquiz/features/ads/blocs/interstitial_ad_cubit.dart';
import 'package:flutterquiz/features/ads/blocs/rewarded_ad_cubit.dart';
import 'package:flutterquiz/features/ads/utils/ad_analytics_collector.dart';
import 'package:flutterquiz/features/profile_management/cubits/update_score_and_coins_cubit.dart';
import 'package:flutterquiz/features/profile_management/cubits/user_details_cubit.dart';
import 'package:flutterquiz/features/profile_management/profile_management_repository.dart';
import 'package:flutterquiz/features/quiz/cubits/contest_cubit.dart';
import 'package:flutterquiz/features/quiz/models/contest.dart';
import 'package:flutterquiz/features/quiz/models/quiz_type.dart';
import 'package:flutterquiz/features/quiz/quiz_repository.dart';
import 'package:flutterquiz/features/system_config/cubits/system_config_cubit.dart';
import 'package:flutterquiz/ui/widgets/already_logged_in_dialog.dart';
import 'package:flutterquiz/ui/widgets/circular_progress_container.dart';
import 'package:flutterquiz/ui/widgets/custom_back_button.dart';
import 'package:flutterquiz/ui/widgets/error_container.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';

/// Contest Type
const int _past = 0;
const int _live = 1;
const int _upcoming = 2;

class ContestScreen extends StatefulWidget {
  const ContestScreen({super.key});

  @override
  State<ContestScreen> createState() => _ContestScreen();

  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider<ContestCubit>(
            create: (_) => ContestCubit(QuizRepository()),
          ),
          BlocProvider<UpdateCoinsCubit>(
            create: (_) => UpdateCoinsCubit(ProfileManagementRepository()),
          ),
        ],
        child: const ContestScreen(),
      ),
    );
  }
}

class _ContestScreen extends State<ContestScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    context.read<ContestCubit>().getContest(
      languageId: UiUtils.getCurrentQuizLanguageId(context),
    );
    Future.delayed(Duration.zero, () {
      if (mounted) {
        context.read<InterstitialAdCubit>().createInterstitialAd(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: 1,
      child: Builder(
        builder: (BuildContext context) {
          return Scaffold(
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              title: Text(
                context.tr('contestLbl')!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.onTertiary,
                ),
              ),
              leading: const CustomBackButton(),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.info_outline),
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      Routes.contestRules,
                    );
                  },
                  tooltip: 'Contest Rules',
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(50),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: Theme.of(
                      context,
                    ).colorScheme.onTertiary.withValues(alpha: 0.08),
                  ),
                  child: TabBar(
                    tabAlignment: TabAlignment.fill,
                    tabs: [
                      Tab(text: context.tr('pastLbl')),
                      Tab(text: context.tr('liveLbl')),
                      Tab(text: context.tr('upcomingLbl')),
                    ],
                  ),
                ),
              ),
            ),
            body: BlocConsumer<ContestCubit, ContestState>(
              bloc: context.read<ContestCubit>(),
              listener: (context, state) {
                if (state is ContestFailure) {
                  if (state.errorMessage == errorCodeUnauthorizedAccess) {
                    showAlreadyLoggedInDialog(context);
                  }
                }
              },
              builder: (context, state) {
                if (state is ContestProgress || state is ContestInitial) {
                  return const Center(child: CircularProgressContainer());
                }
                if (state is ContestFailure) {
                  return ErrorContainer(
                    errorMessage: convertErrorCodeToLanguageKey(
                      state.errorMessage,
                    ),
                    onTapRetry: () {
                      context.read<ContestCubit>().getContest(
                        languageId: UiUtils.getCurrentQuizLanguageId(context),
                      );
                    },
                    showErrorImage: true,
                  );
                }
                final contestList = (state as ContestSuccess).contestList;
                return TabBarView(
                  children: [
                    past(contestList.past),
                    live(contestList.live),
                    future(contestList.upcoming),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget past(Contest data) {
    return data.errorMessage.isNotEmpty
        ? contestErrorContainer(data)
        : ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: data.contestDetails.length,
            itemBuilder: (_, i) => _ContestCard(
              contestDetails: data.contestDetails[i],
              contestType: _past,
            ),
          );
  }

  Widget live(Contest data) {
    return data.errorMessage.isNotEmpty
        ? contestErrorContainer(data)
        : ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: data.contestDetails.length,
            itemBuilder: (_, i) => _ContestCard(
              contestDetails: data.contestDetails[i],
              contestType: _live,
            ),
          );
  }

  Widget future(Contest data) {
    return data.errorMessage.isNotEmpty
        ? contestErrorContainer(data)
        : ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: data.contestDetails.length,
            itemBuilder: (_, i) => _ContestCard(
              contestDetails: data.contestDetails[i],
              contestType: _upcoming,
            ),
          );
  }

  ErrorContainer contestErrorContainer(Contest data) {
    return ErrorContainer(
      showBackButton: false,
      errorMessage: convertErrorCodeToLanguageKey(data.errorMessage),
      onTapRetry: () => context.read<ContestCubit>().getContest(
        languageId: UiUtils.getCurrentQuizLanguageId(context),
      ),
      showErrorImage: true,
    );
  }
}

class _ContestCard extends StatefulWidget {
  const _ContestCard({required this.contestDetails, required this.contestType});

  final ContestDetails contestDetails;
  final int contestType;

  @override
  State<_ContestCard> createState() => _ContestCardState();
}

class _ContestCardState extends State<_ContestCard> {
  bool _isProcessingEntry = false;

  Future<void> _handleOnTap() async {
    if (widget.contestType == _past) {
      Navigator.of(context).pushNamed(
        Routes.contestLeaderboard,
        arguments: {'contestId': widget.contestDetails.id},
      );
    }
    if (widget.contestType == _live) {
      if (_isProcessingEntry) return; // Prevent duplicate taps
      
      _isProcessingEntry = true;
      
      try {
        final userCoins = int.parse(context.read<UserDetailsCubit>().getCoins()!);
        final entryFee = int.parse(widget.contestDetails.entry!);
        
        // Record contest entry attempt (Phase 3)
        await AdAnalyticsCollector.recordComplianceEvent(
          eventName: 'contest_entry_attempted',
          payload: {
            'contest_id': widget.contestDetails.id,
            'entry_fee': entryFee,
            'user_coins': userCoins,
          },
        );

        if (userCoins >= entryFee) {
          // Offer rewarded ad before entry (Phase 3)
          if (context.mounted) {
            await _showContestEntryRewardedAdOption();
          }

          // Deduct entry fee
          if (context.mounted) {
            context.read<UpdateCoinsCubit>().updateCoins(
              coins: entryFee,
              addCoin: false,
              title: playedContestKey,
            );

            context.read<UserDetailsCubit>().updateCoins(
              addCoin: false,
              coins: entryFee,
            );
            
            // Record successful entry
            await AdAnalyticsCollector.recordComplianceEvent(
              eventName: 'contest_entry_completed',
              payload: {
                'contest_id': widget.contestDetails.id,
                'entry_fee': entryFee,
              },
            );

            if (context.mounted) {
              Navigator.of(context).pushReplacementNamed(
                Routes.quiz,
                arguments: {
                  'quizType': QuizTypes.contest,
                  'contestId': widget.contestDetails.id,
                },
              );
            }
          }
        } else {
          if (context.mounted) {
            showNotEnoughCoinsDialog(context);
          }
        }
      } finally {
        if (mounted) {
          _isProcessingEntry = false;
        }
      }
    }
  }

  /// Show optional rewarded ad before contest entry (Phase 3)
  Future<void> _showContestEntryRewardedAdOption() async {
    try {
      final rewardedAdCubit = context.read<RewardedAdCubit>();
      final sysConfigCubit = context.read<SystemConfigCubit>();
      
      if (!sysConfigCubit.isAdsEnable) return;

      // Check if rewarded ad is available
      final canShowRewarded = await RewardedFrequencyManager.canShowRewarded();
      if (!canShowRewarded) return;

      bool rewardEarned = false;

      // Show rewarded ad
      await AdAnalyticsCollector.recordComplianceEvent(
        eventName: 'contest_entry_ad_offered',
        payload: {
          'contest_id': widget.contestDetails.id,
        },
      );

      await rewardedAdCubit.showAd(
        context: context,
        onAdDismissedCallback: () {},
        onUserEarnedReward: () {
          rewardEarned = true;
        },
        rewardAmount: 10,
        rewardCurrencyLabel: 'coins',
      );

      if (rewardEarned && context.mounted) {
        // Grant coins if ad was completed
        context.read<UpdateCoinsCubit>().updateCoins(
          coins: 10,
          addCoin: true,
          title: 'contest_entry_ad_reward',
        );

        context.read<UserDetailsCubit>().updateCoins(
          addCoin: true,
          coins: 10,
        );

        await AdAnalyticsCollector.recordComplianceEvent(
          eventName: 'contest_entry_ad_completed',
          payload: {
            'contest_id': widget.contestDetails.id,
            'reward_coins': 10,
          },
        );
      }
    } catch (e) {
      // Silently fail - entry can proceed without ad
      log('Error showing contest entry rewarded ad: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final boldTextStyle = TextStyle(
      fontSize: 14,
      color: context.primaryTextColor,
      fontWeight: FontWeight.bold,
    );
    final normalTextStyle = TextStyle(
      fontSize: 14,
      fontWeight: FontWeights.regular,
      color: context.primaryTextColor.withValues(alpha: 0.6),
    );
    final width = context.width;

    final verticalDivider = SizedBox(
      width: 1,
      height: 30,
      child: ColoredBox(color: context.scaffoldBackgroundColor),
    );

    return Container(
      margin: const EdgeInsets.all(15),
      width: width * .9,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(5, 5),
          ),
        ],
        borderRadius: BorderRadius.circular(10),
      ),
      child: GestureDetector(
        onTap: _handleOnTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CachedNetworkImage(
                imageUrl: widget.contestDetails.image!,
                placeholder: (_, i) =>
                    const Center(child: CircularProgressContainer()),
                imageBuilder: (_, img) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(image: img, fit: BoxFit.cover),
                    ),
                    height: 171,
                    width: width,
                  );
                },
                errorWidget: (_, i, e) => Center(
                  child: Icon(Icons.error, color: context.primaryColor),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: width * .78),
                    child: Text(
                      widget.contestDetails.name!,
                      style: boldTextStyle,
                    ),
                  ),
                  if (widget.contestDetails.description!.length > 50)
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: context.scaffoldBackgroundColor,
                        ),
                      ),
                      alignment: Alignment.center,
                      height: 30,
                      width: 30,
                      padding: EdgeInsets.zero,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            widget.contestDetails.showDescription =
                                !widget.contestDetails.showDescription!;
                          });
                        },
                        child: Icon(
                          widget.contestDetails.showDescription!
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          color: context.primaryTextColor,
                          size: 30,
                        ),
                      ),
                    )
                  else
                    const SizedBox(),
                ],
              ),
              SizedBox(
                width: !widget.contestDetails.showDescription!
                    ? width * .75
                    : width,
                child: Text(
                  widget.contestDetails.description!,
                  style: TextStyle(
                    color: context.primaryTextColor.withValues(alpha: 0.3),
                  ),
                  maxLines: !widget.contestDetails.showDescription! ? 1 : 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 10),
              Divider(color: context.scaffoldBackgroundColor, height: 0),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(context.tr('entryFeesLbl')!, style: normalTextStyle),
                      Text(
                        '${widget.contestDetails.entry!} ${context.tr('coinsLbl')!}',
                        style: boldTextStyle,
                      ),
                    ],
                  ),

                  ///
                  verticalDivider,
                  if (widget.contestType == _upcoming)
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          context.tr('startsOnLbl')!,
                          style: normalTextStyle,
                        ),
                        Text(
                          widget.contestDetails.startDate!,
                          style: boldTextStyle,
                        ),
                      ],
                    )
                  else
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(context.tr('playersLbl')!, style: normalTextStyle),
                        Text(
                          widget.contestDetails.participants!,
                          style: boldTextStyle,
                        ),
                      ],
                    ),

                  ///
                  verticalDivider,
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(context.tr('endsOnLbl')!, style: normalTextStyle),
                      Text(
                        widget.contestDetails.endDate!,
                        style: boldTextStyle,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
