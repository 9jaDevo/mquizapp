import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutterquiz/commons/commons.dart';
import 'package:flutterquiz/core/core.dart';
import 'package:flutterquiz/features/ads/blocs/interstitial_ad_cubit.dart';
import 'package:flutterquiz/features/ads/blocs/rewarded_ad_cubit.dart';
import 'package:flutterquiz/features/ads/blocs/rewarded_interstitial_ad_cubit.dart';
import 'package:flutterquiz/features/battle_room/cubits/battle_room_cubit.dart';
import 'package:flutterquiz/features/battle_room/models/battle_room.dart';
import 'package:flutterquiz/features/exam/models/exam.dart';
import 'package:flutterquiz/features/profile_management/cubits/update_score_and_coins_cubit.dart';
import 'package:flutterquiz/features/profile_management/cubits/update_user_details_cubit.dart';
import 'package:flutterquiz/features/profile_management/cubits/user_details_cubit.dart';
import 'package:flutterquiz/features/profile_management/models/user_profile.dart';
import 'package:flutterquiz/features/profile_management/profile_management_repository.dart';
import 'package:flutterquiz/features/quiz/cubits/comprehension_cubit.dart';
import 'package:flutterquiz/features/quiz/cubits/contest_cubit.dart';
import 'package:flutterquiz/features/quiz/cubits/quiz_category_cubit.dart';
import 'package:flutterquiz/features/quiz/cubits/set_coin_score_cubit.dart';
import 'package:flutterquiz/features/quiz/cubits/subcategory_cubit.dart';
import 'package:flutterquiz/features/quiz/cubits/unlocked_level_cubit.dart';
import 'package:flutterquiz/features/quiz/models/comprehension.dart';
import 'package:flutterquiz/features/quiz/models/guess_the_word_question.dart';
import 'package:flutterquiz/features/quiz/models/question.dart';
import 'package:flutterquiz/features/quiz/models/quiz_type.dart';
import 'package:flutterquiz/features/quiz/models/user_battle_room_details.dart';
import 'package:flutterquiz/features/skill_tier/models/skill_tier.dart';
import 'package:flutterquiz/features/skill_tier/skill_tier_service.dart';
import 'package:flutterquiz/features/system_config/cubits/system_config_cubit.dart';
import 'package:flutterquiz/features/wallet/cubit/monetization_cubit.dart';
import 'package:flutterquiz/features/wallet/widgets/monetization_widgets.dart';
import 'package:flutterquiz/ui/screens/quiz/guess_the_word_quiz_screen.dart';
import 'package:flutterquiz/ui/screens/quiz/review_answers_screen.dart';
import 'package:flutterquiz/ui/screens/quiz/widgets/radial_result_container.dart';
import 'package:flutterquiz/ui/widgets/already_logged_in_dialog.dart';
import 'package:flutterquiz/ui/widgets/circular_progress_container.dart';
import 'package:flutterquiz/ui/widgets/custom_appbar.dart';
import 'package:flutterquiz/ui/widgets/error_container.dart';
import 'package:flutterquiz/utils/answer_encryption.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({
    required this.isPlayed,
    required this.comprehension,
    required this.isPremiumCategory,
    super.key,
    this.exam,
    this.playWithBot,
    this.correctExamAnswers,
    this.incorrectExamAnswers,
    this.obtainedMarks,
    this.timeTakenToCompleteQuiz,
    this.battleRoom,
    this.questions,
    this.unlockedLevel,
    this.quizType,
    this.subcategoryMaxLevel,
    this.guessTheWordQuestions,
    this.entryFee,
    this.categoryId,
    this.subcategoryId,
    this.lifelines = const [],
    this.totalHintUsed,
    this.matchId,
  });

  final QuizTypes? quizType;
  final List<Question>? questions;
  final BattleRoom? battleRoom;
  final bool? playWithBot;
  final Comprehension comprehension;
  final List<GuessTheWordQuestion>? guessTheWordQuestions;
  final int? entryFee;
  final String? subcategoryMaxLevel;
  final int? unlockedLevel;
  final double? timeTakenToCompleteQuiz;
  final Exam? exam;
  final int? obtainedMarks;
  final int? correctExamAnswers;
  final int? incorrectExamAnswers;
  final String? categoryId;
  final String? subcategoryId;
  final bool isPlayed;
  final bool isPremiumCategory;
  final List<String> lifelines;
  final int? totalHintUsed;
  final String? matchId;

  static Route<dynamic> route(RouteSettings routeSettings) {
    final args = routeSettings.arguments! as Map;
    return CupertinoPageRoute(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => SetCoinScoreCubit()),
          BlocProvider<UpdateCoinsCubit>(
            create: (_) => UpdateCoinsCubit(ProfileManagementRepository()),
          ),
          BlocProvider<UpdateUserDetailCubit>(
            create: (_) => UpdateUserDetailCubit(ProfileManagementRepository()),
          ),
        ],
        child: ResultScreen(
          battleRoom: args['battleRoom'] as BattleRoom?,
          categoryId: args['categoryId'] as String? ?? '',
          comprehension:
              args['comprehension'] as Comprehension? ?? Comprehension.empty,
          correctExamAnswers: args['correctExamAnswers'] as int?,
          entryFee: args['entryFee'] as int?,
          exam: args['exam'] as Exam?,
          guessTheWordQuestions:
              args['guessTheWordQuestions'] as List<GuessTheWordQuestion>?,
          incorrectExamAnswers: args['incorrectExamAnswers'] as int?,
          isPlayed: args['isPlayed'] as bool? ?? true,
          obtainedMarks: args['obtainedMarks'] as int?,
          playWithBot: args['play_with_bot'] as bool?,
          questions: args['questions'] as List<Question>?,
          quizType: args['quizType'] as QuizTypes?,
          subcategoryId: args['subcategoryId'] as String? ?? '',
          subcategoryMaxLevel: args['subcategoryMaxLevel'] as String?,
          timeTakenToCompleteQuiz: args['timeTakenToCompleteQuiz'] as double?,
          unlockedLevel: args['unlockedLevel'] as int?,
          isPremiumCategory: args['isPremiumCategory'] as bool? ?? false,
          lifelines: args['lifelines'] as List<String>? ?? const [],
          totalHintUsed: args['totalHintUsed'] as int?,
          matchId: args['matchId'] as String?,
        ),
      ),
    );
  }

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultViewData {
  const _ResultViewData({
    required this.percentage,
    required this.correct,
    required this.total,
    required this.score,
    required this.coins,
    required this.rankLabel,
    required this.timeLabel,
  });

  final int percentage;
  final int correct;
  final int total;
  final int score;
  final int coins;
  final String rankLabel;
  final String timeLabel;

  int get wrong => total - correct;
}

class _ResultScreenState extends State<ResultScreen> {
  final ScreenshotController screenshotController = ScreenshotController();
  bool _isWinner = false;
  bool _isShareInProgress = false;
  bool _isReviewInProgress = false;
  bool _hasShownBoostDialog = false;
  String _skillTierLabel = '--';

  bool _displayedAlreadyLoggedInDialog = false;

  // Track quiz completions for rewarded interstitial
  static int _quizCompletionCount = 0;

  late final UserProfile userProfile = context
      .read<UserDetailsCubit>()
      .getUserProfile();
  late final String userProfileUrl = userProfile.profileUrl ?? '';
  late final String userName = userProfile.name ?? '';

  /// THIS is only for Self Challenge and Exam
  /// we need to calculate things locally,
  // as we don't give out any coins, score, nor update the statistics.
  late final String _userFirebaseId = context
      .read<UserDetailsCubit>()
      .getUserFirebaseId();

  int get totalQuestions => widget.quizType == QuizTypes.exam
      ? widget.correctExamAnswers! + widget.incorrectExamAnswers!
      : widget.questions?.length ?? 0;

  int get correctAnswers {
    if (widget.quizType == QuizTypes.exam) return widget.correctExamAnswers!;

    if (widget.questions == null) return 0;

    return widget.questions!.where((question) {
      final ans = AnswerEncryption.decryptCorrectAnswer(
        rawKey: _userFirebaseId,
        correctAnswer: question.correctAnswer!,
      );

      return question.submittedAnswerId == ans;
    }).length;
  }

  int get wrongAnswers => widget.quizType == QuizTypes.exam
      ? widget.incorrectExamAnswers!
      : totalQuestions - correctAnswers;

  double get winPercentage => widget.quizType == QuizTypes.exam
      ? (widget.obtainedMarks! * 100) / int.parse(widget.exam!.totalMarks)
      : (correctAnswers * 100) / totalQuestions;

  /// --- End

  @override
  void initState() {
    super.initState();
    _loadSkillTierLabel();

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      // Increment quiz completion counter
      _quizCompletionCount++;

      if (!widget.isPremiumCategory) {
        // Show rewarded interstitial every 2 quizzes (giving 3 coins)
        if (_quizCompletionCount % 2 == 0 &&
            context.read<SystemConfigCubit>().isAdsEnable &&
            !context.read<UserDetailsCubit>().removeAds()) {
          final rewardCoins = context.read<SystemConfigCubit>().rewardAdsCoins;

          await context.read<RewardedInterstitialAdCubit>().showAd(
            context: context,
            rewardAmount: rewardCoins,
            rewardCurrencyLabel: 'coins',
            onAdDismissedCallback: () {
              // Continue with regular flow
            },
          );
        } else {
          // Show regular interstitial ad
          context.read<InterstitialAdCubit>().showAd(context);
        }
      }

      if (widget.quizType == QuizTypes.selfChallenge) {
        setState(() {
          _isWinner =
              winPercentage >
              context.read<SystemConfigCubit>().quizWinningPercentage;
        });
      }

      await _updateResult();

      await fetchUpdateUserDetails();

      _maybeShowBoostEarningsPopup();
    });
  }

  Future<void> _loadSkillTierLabel() async {
    final tier = await SkillTierService.computeTier();
    if (!mounted) return;
    final label = tier != null ? '${SkillTier.label(tier.type)} League' : '--';
    setState(() {
      _skillTierLabel = label;
    });
  }

  void _maybeShowBoostEarningsPopup() {
    if (_hasShownBoostDialog) return;
    if (widget.quizType == QuizTypes.selfChallenge ||
        widget.quizType == QuizTypes.exam) {
      return;
    }

    _hasShownBoostDialog = true;
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        _showBoostEarningsPopup();
      }
    });
  }

  void _showBoostEarningsPopup() {
    try {
      final adsEnabled = context.read<SystemConfigCubit>().isAdsEnable;
      final adsRemoved = context.read<UserDetailsCubit>().removeAds();
      if (!adsEnabled || adsRemoved) return;

      final coinScoreState = context.read<SetCoinScoreCubit>().state;
      if (coinScoreState is! SetCoinScoreSuccess) return;

      final baseCoins = coinScoreState.earnCoin;
      if (baseCoins <= 0) return;

      context.read<MonetizationCubit>().offerBoostEarnings(
        coinsEarned: baseCoins.toString(),
      );

      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) =>
            BlocBuilder<MonetizationCubit, MonetizationState>(
              builder: (context, state) {
                if (state.isLoadingBoost || state.boostEarnings == null) {
                  return const Center(child: CircularProgressIndicator());
                }

                final boost = state.boostEarnings!;

                return BoostEarningsDialog(
                  boost: boost,
                  onClaimPressed: () async {
                    final rewardedCubit = context.read<RewardedAdCubit>();

                    if (rewardedCubit.state is! RewardedAdLoaded) {
                      await rewardedCubit.createRewardedAd(context);
                      if (!mounted) return;
                      context.showSnack(context.tr('watchAdToEarnCoins')!);
                      return;
                    }

                    await rewardedCubit.showAd(
                      context: context,
                      rewardAmount: boost.coinDifference,
                      rewardCurrencyLabel: 'coins',
                      onAdDismissedCallback: () {},
                      onUserEarnedReward: () async {
                        await context
                            .read<MonetizationCubit>()
                            .applyBoostEarnings(
                              coinsEarned: boost.boostedCoins.toString(),
                            );
                        await fetchUpdateUserDetails();
                        if (!mounted) return;
                        Navigator.of(dialogContext).pop();
                      },
                    );
                  },
                  onSkipPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                );
              },
            ),
      );
    } catch (e) {
      // Silently fail boost earnings
    }
  }

  Future<void> _updateResult() async {
    // We are calculating and showing result locally for exam and self challenge
    // so no need to call api for updating result.
    if (widget.quizType case QuizTypes.selfChallenge || QuizTypes.exam) return;

    final type = switch (widget.quizType) {
      QuizTypes.dailyQuiz => '1.1',
      QuizTypes.trueAndFalse => '1.2',
      QuizTypes.randomBattle => '1.3',
      QuizTypes.oneVsOneBattle => '1.4',
      QuizTypes.contest => 'contest',
      _ => widget.quizType!.typeValue!,
    };

    final playedQuestion = switch (widget.quizType) {
      QuizTypes.oneVsOneBattle || QuizTypes.randomBattle => {
        'user1_id': widget.battleRoom!.user1!.uid,
        'user2_id': widget.battleRoom!.user2!.uid,
        'user1_data': widget.battleRoom!.user1!.answers,
        'user2_data': widget.battleRoom!.user2!.answers,
      },
      QuizTypes.guessTheWord =>
        widget.guessTheWordQuestions!
            .map(
              (q) => <String, String>{
                'id': q.id,
                'answer': q.submittedAnswer.join(),
              },
            )
            .toList(),
      _ =>
        widget.questions!
            .map(
              (q) => <String, String>{
                'id': q.id!,
                'answer': q.submittedAnswerId,
              },
            )
            .toList(),
    };

    final categoryId = switch (widget.quizType) {
      QuizTypes.guessTheWord => widget.guessTheWordQuestions?.first.category,
      QuizTypes.dailyQuiz || QuizTypes.trueAndFalse => '',
      _ => widget.questions?.first.categoryId,
    };

    await context.read<SetCoinScoreCubit>().setCoinScore(
      categoryId: categoryId,
      quizType: type,
      playedQuestions: playedQuestion,
      lifelines: widget.lifelines,
      subcategoryId: widget.subcategoryId,
      playWithBot: widget.playWithBot,
      noOfHintUsed: widget.totalHintUsed,
      matchId: widget.matchId,
    );
  }

  Future<void> fetchUpdateUserDetails() async {
    await context.read<UserDetailsCubit>().fetchUserDetails();
  }

  void onPageBackCalls() {
    if (widget.quizType == QuizTypes.funAndLearn &&
        _isWinner &&
        !widget.comprehension.isPlayed) {
      context.read<ComprehensionCubit>().getComprehension(
        languageId: UiUtils.getCurrentQuizLanguageId(context),
        type: widget.questions!.first.subcategoryId! == '0'
            ? 'category'
            : 'subcategory',
        typeId: widget.questions!.first.subcategoryId! == '0'
            ? widget.questions!.first.categoryId!
            : widget.questions!.first.subcategoryId!,
      );
    } else if (widget.quizType == QuizTypes.audioQuestions &&
        _isWinner &&
        !widget.isPlayed) {
      //
      if (widget.questions!.first.subcategoryId == '0') {
        //update category
        context.read<QuizCategoryCubit>().getQuizCategoryWithUserId(
          languageId: UiUtils.getCurrentQuizLanguageId(context),
          type: UiUtils.getCategoryTypeNumberFromQuizType(
            QuizTypes.audioQuestions,
          ),
        );
      } else {
        //update subcategory
        context.read<SubCategoryCubit>().fetchSubCategory(
          widget.questions!.first.categoryId!,
        );
      }
    } else if (widget.quizType == QuizTypes.guessTheWord &&
        _isWinner &&
        !widget.isPlayed) {
      if (widget.guessTheWordQuestions!.first.subcategory == '0') {
        //update category
        context.read<QuizCategoryCubit>().getQuizCategoryWithUserId(
          languageId: UiUtils.getCurrentQuizLanguageId(context),
          type: UiUtils.getCategoryTypeNumberFromQuizType(
            QuizTypes.guessTheWord,
          ),
        );
      } else {
        //update subcategory
        context.read<SubCategoryCubit>().fetchSubCategory(
          widget.guessTheWordQuestions!.first.category,
        );
      }
    } else if (widget.quizType == QuizTypes.mathMania &&
        _isWinner &&
        !widget.isPlayed) {
      if (widget.questions!.first.subcategoryId == '0') {
        //update category
        context.read<QuizCategoryCubit>().getQuizCategoryWithUserId(
          languageId: UiUtils.getCurrentQuizLanguageId(context),
          type: UiUtils.getCategoryTypeNumberFromQuizType(QuizTypes.mathMania),
        );
      } else {
        //update subcategory
        context.read<SubCategoryCubit>().fetchSubCategory(
          widget.questions!.first.categoryId!,
        );
      }
    } else if (widget.quizType == QuizTypes.quizZone) {
      if (widget.subcategoryId == '') {
        context.read<UnlockedLevelCubit>().fetchUnlockLevel(
          widget.categoryId!,
          '0',
          quizType: QuizTypes.quizZone,
        );
      } else {
        context.read<SubCategoryCubit>().fetchSubCategory(widget.categoryId!);
      }
    } else if (widget.quizType == QuizTypes.contest) {
      context.read<ContestCubit>().getContest(
        languageId: UiUtils.getCurrentQuizLanguageId(context),
      );
    }
  }

  bool get _isBattleResult =>
      widget.quizType == QuizTypes.oneVsOneBattle ||
      widget.quizType == QuizTypes.randomBattle;

  String _resolveFirstName() {
    final trimmed = userName.trim();
    if (trimmed.isEmpty) return 'Player';
    return trimmed.split(' ').first;
  }

  String _formatTime(int? totalSeconds) {
    final total = totalSeconds ?? 0;
    if (total <= 0) return '--';
    final minutes = total ~/ 60;
    final seconds = total % 60;
    final minutesText = minutes < 10 ? '0$minutes' : '$minutes';
    final secondsText = seconds < 10 ? '0$seconds' : '$seconds';
    return '$minutesText:$secondsText';
  }

  _ResultViewData _buildResultViewDataFromState(SetCoinScoreSuccess state) {
    final seconds = widget.timeTakenToCompleteQuiz?.round();
    return _ResultViewData(
      percentage: state.percentage,
      correct: state.correctAnswer,
      total: state.totalQuestions,
      score: state.earnScore,
      coins: state.earnCoin,
      rankLabel: _skillTierLabel,
      timeLabel: _formatTime(seconds),
    );
  }

  _ResultViewData _buildResultViewDataFromLocal() {
    final seconds = widget.timeTakenToCompleteQuiz?.round();
    final score = widget.quizType == QuizTypes.exam
        ? (widget.obtainedMarks ?? 0)
        : 0;
    return _ResultViewData(
      percentage: winPercentage.round(),
      correct: correctAnswers,
      total: totalQuestions,
      score: score,
      coins: 0,
      rankLabel: _skillTierLabel,
      timeLabel: _formatTime(seconds),
    );
  }

  Widget _buildGreetingMessage({
    int? scorePct,
    String? userName,
    bool? isWinner,
    bool? isDraw,
  }) {
    final String title;
    final String message;

    if (widget.quizType == QuizTypes.oneVsOneBattle ||
        widget.quizType == QuizTypes.randomBattle) {
      (title, message) = switch ((isWinner, isDraw)) {
        // Win
        (true, false) => ('victoryLbl', 'congratulationsLbl'),
        // Lose
        (false, false) => ('defeatLbl', 'betterNextLbl'),
        // Draw
        (false, true) => ('matchDrawLbl', ''),
        _ => throw Exception('Match cannot be drawn and won'),
      };
    } else if (widget.quizType == QuizTypes.exam) {
      title = widget.exam!.title;
      message = examResultKey;
    } else {
      (title, message) = switch (scorePct!) {
        <= 30 => (goodEffort, keepLearning),
        <= 50 => (wellDone, makingProgress),
        <= 70 => (greatJob, closerToMastery),
        <= 90 => (excellentWork, keepGoing),
        _ => (fantasticJob, achievedMastery),
      };
    }

    final titleStyle = TextStyle(
      fontSize: 26,
      color: context.primaryTextColor,
      fontWeight: FontWeights.bold,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 30),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  widget.quizType == QuizTypes.exam
                      ? title
                      : context.tr(title)!,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: titleStyle,
                ),
              ),
              if (widget.quizType != QuizTypes.exam &&
                  widget.quizType != QuizTypes.oneVsOneBattle &&
                  widget.quizType != QuizTypes.randomBattle) ...[
                Flexible(
                  child: Text(
                    " ${userName!.split(' ').first}",
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: titleStyle,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 5),
        Container(
          alignment: Alignment.center,
          width: context.shortestSide * .85,
          child: Text(
            context.tr(message)!,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 19, color: context.primaryTextColor),
          ),
        ),
      ],
    );
  }

  Widget _buildConfettiDots() {
    return IgnorePointer(
      child: Stack(
        children: const [
          Positioned(
            top: 40,
            left: 30,
            child: _ConfettiDot(size: 8, color: Color(0xFFB9E3FF)),
          ),
          Positioned(
            top: 120,
            right: 40,
            child: _ConfettiDot(size: 6, color: Color(0xFFCCEAD6)),
          ),
          Positioned(
            top: 210,
            left: 60,
            child: _ConfettiDot(size: 10, color: Color(0xFFFFE1B8)),
          ),
          Positioned(
            top: 280,
            right: 80,
            child: _ConfettiDot(size: 7, color: Color(0xFFFAD4E8)),
          ),
          Positioned(
            bottom: 180,
            left: 40,
            child: _ConfettiDot(size: 9, color: Color(0xFFBFE7FF)),
          ),
          Positioned(
            bottom: 120,
            right: 50,
            child: _ConfettiDot(size: 6, color: Color(0xFFDCEBFF)),
          ),
          Positioned(
            bottom: 60,
            left: 120,
            child: _ConfettiDot(size: 5, color: Color(0xFFE5F6D6)),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    final displayName = _resolveFirstName();

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF86F1B6).withValues(alpha: 0.4),
                blurRadius: 18,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(
            Icons.emoji_events_rounded,
            color: Color(0xFF2E6CF6),
            size: 38,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Excellent Work!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1E3A8A),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Congratulations $displayName, you passed!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: const Color(0xFF1E3A8A).withValues(alpha: 0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildScoreDonut(int percentage) {
    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 200,
            height: 200,
            child: CircularProgressIndicator(
              value: percentage / 100,
              strokeWidth: 14,
              backgroundColor: const Color(0xFFE6EEF9),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF2E6CF6)),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$percentage%',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E3A8A),
                ),
              ),
              const Text(
                'Score',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF7B8BB5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required String icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: SvgPicture.asset(
              icon,
              width: 20,
              height: 20,
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E3A8A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF7B8BB5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatGrid(_ResultViewData data) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.25,
      children: [
        _buildStatCard(
          label: 'Correct',
          value: '${data.correct}/${data.total}',
          icon: Assets.correct,
          color: const Color(0xFF35C78A),
        ),
        _buildStatCard(
          label: 'Wrong',
          value: '${data.wrong}/${data.total}',
          icon: Assets.wrong,
          color: const Color(0xFFF16060),
        ),
        _buildStatCard(
          label: 'Score',
          value: '${data.score}',
          icon: Assets.score,
          color: const Color(0xFFF59E0B),
        ),
        _buildStatCard(
          label: 'Coins',
          value: '${data.coins}',
          icon: Assets.earnedCoin,
          color: const Color(0xFFFACC15),
        ),
      ],
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF2E6CF6), size: 20),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF7B8BB5),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E3A8A),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(_ResultViewData data) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: _buildSummaryItem(
              icon: Icons.check_circle_outline,
              label: 'Accuracy',
              value: '${data.percentage}%',
            ),
          ),
          Expanded(
            child: _buildSummaryItem(
              icon: Icons.emoji_events_outlined,
              label: 'Rank',
              value: data.rankLabel,
            ),
          ),
          Expanded(
            child: _buildSummaryItem(
              icon: Icons.schedule,
              label: 'Time',
              value: data.timeLabel,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String title,
    required VoidCallback onTap,
    IconData? leadingIcon,
    IconData? trailingIcon,
    bool isPrimary = false,
    bool isTertiary = false,
  }) {
    final background = isPrimary ? const Color(0xFF2E6CF6) : Colors.white;
    final textColor = isPrimary ? Colors.white : const Color(0xFF1E3A8A);
    final borderColor = isPrimary
        ? Colors.transparent
        : (isTertiary ? const Color(0xFFE7EEF8) : const Color(0xFFDCE6F6));

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: 54,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor),
            boxShadow: [
              if (!isTertiary)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 14,
                  offset: const Offset(0, 8),
                ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (leadingIcon != null) ...[
                Icon(leadingIcon, color: textColor, size: 20),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
              if (trailingIcon != null) ...[
                const SizedBox(width: 10),
                Icon(trailingIcon, color: textColor, size: 22),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRedesignedResultLayout(_ResultViewData data) {
    return Column(
      children: [
        _buildHeaderSection(),
        const SizedBox(height: 24),
        _buildScoreDonut(data.percentage),
        const SizedBox(height: 24),
        _buildStatGrid(data),
        const SizedBox(height: 24),
        _buildSummaryRow(data),
      ],
    );
  }

  Widget _buildResultDataWithIconContainer(
    String title,
    String icon,
    EdgeInsetsGeometry margin,
  ) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: context.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      width: context.width * 0.2125,
      height: 32,
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            icon,
            colorFilter: ColorFilter.mode(
              context.primaryTextColor,
              BlendMode.srcIn,
            ),
            width: 20,
            height: 20,
          ),
          const SizedBox(width: 4),
          Text(
            title,
            style: TextStyle(
              color: context.primaryTextColor,
              fontWeight: FontWeights.bold,
              fontSize: 18,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndividualResultContainer() {
    return BlocConsumer<SetCoinScoreCubit, SetCoinScoreState>(
      listener: (context, state) {
        if (state is SetCoinScoreSuccess) {
          if (widget.quizType
              case QuizTypes.oneVsOneBattle || QuizTypes.randomBattle) {
            final currUserId = context.read<UserDetailsCubit>().userId();

            // Delete room
            if (state.userRanks.first.userId == currUserId) {
              context.read<BattleRoomCubit>().deleteBattleRoom();
            }
          }
        }
      },
      builder: (context, state) {
        if (state is SetCoinScoreSuccess) {
          final confetti = _isWinner ? Assets.winConfetti : Assets.loseConfetti;

          ///
          return Stack(
            clipBehavior: Clip.none,
            children: [
              /// Confetti
              Align(
                alignment: Alignment.topCenter,
                child: Lottie.asset(confetti, fit: BoxFit.fill),
              ),

              /// User Details
              Align(
                alignment: Alignment.topCenter,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    var verticalSpacePercentage = 0.0;
                    final mh = constraints.maxHeight;
                    final mw = constraints.maxWidth;

                    if (constraints.maxHeight <
                        UiUtils.profileHeightBreakPointResultScreen) {
                      verticalSpacePercentage = 0.015;
                    } else {
                      verticalSpacePercentage = 0.035;
                    }

                    return Column(
                      children: [
                        _buildGreetingMessage(
                          scorePct: state.percentage,
                          userName: userName,
                        ),
                        SizedBox(height: mh * verticalSpacePercentage),

                        Stack(
                          alignment: Alignment.center,
                          children: [
                            QImage.circular(
                              imageUrl: userProfileUrl,
                              width: mw * .30,
                              height: mw * .30,
                            ),
                            SvgPicture.asset(
                              Assets.hexagonFrame,
                              width: mw * .37,
                              height: mw * .37,
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),

              /// Correct Answer
              Align(
                alignment: AlignmentDirectional.bottomStart,
                child: _buildResultDataWithIconContainer(
                  '${state.correctAnswer}/${state.totalQuestions}',
                  Assets.correct,
                  const EdgeInsetsDirectional.only(start: 15, bottom: 60),
                ),
              ),

              /// Incorrect Answer
              Align(
                alignment: AlignmentDirectional.bottomStart,
                child: _buildResultDataWithIconContainer(
                  '${state.totalQuestions - state.correctAnswer}/${state.totalQuestions}',
                  Assets.wrong,
                  const EdgeInsetsDirectional.only(start: 15, bottom: 20),
                ),
              ),

              /// Score
              Align(
                alignment: AlignmentDirectional.bottomEnd,
                child: _buildResultDataWithIconContainer(
                  '${state.earnScore}',
                  Assets.score,
                  const EdgeInsetsDirectional.only(end: 15, bottom: 60),
                ),
              ),

              /// Coins
              Align(
                alignment: AlignmentDirectional.bottomEnd,
                child: _buildResultDataWithIconContainer(
                  '${state.earnCoin}',
                  Assets.earnedCoin,
                  const EdgeInsetsDirectional.only(end: 15, bottom: 20),
                ),
              ),

              /// Radial Percentage
              Align(
                alignment: Alignment.bottomCenter,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final mh = constraints.maxHeight;
                    final double radialSizePercentage;
                    if (mh < UiUtils.profileHeightBreakPointResultScreen) {
                      radialSizePercentage = 0.4;
                    } else {
                      radialSizePercentage = 0.325;
                    }

                    return Transform.translate(
                      offset: const Offset(0, 15),
                      child: RadialPercentageResultContainer(
                        percentage: state.percentage.toDouble(),
                        timeTakenToCompleteQuizInSeconds: widget
                            .timeTakenToCompleteQuiz
                            ?.toInt(),
                        size: Size(
                          mh * radialSizePercentage,
                          mh * radialSizePercentage,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }

        if (state is SetCoinScoreFailure) {
          return Center(
            child: ErrorContainer(
              showBackButton: true,
              errorMessageColor: context.primaryColor,
              errorMessage: convertErrorCodeToLanguageKey(state.error),
              onTapRetry: () async {
                await _updateResult();
              },
              showErrorImage: true,
            ),
          );
        }

        return const Center(child: CircularProgressContainer());
      },
    );
  }

  Widget _buildSelfChallengeOrExamResultContainer() {
    final confetti = _isWinner ? Assets.winConfetti : Assets.loseConfetti;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        /// Confetti
        Align(
          alignment: Alignment.topCenter,
          child: Lottie.asset(confetti, fit: BoxFit.fill),
        ),

        /// User Details
        Align(
          alignment: Alignment.topCenter,
          child: LayoutBuilder(
            builder: (context, constraints) {
              var verticalSpacePercentage = 0.0;
              final mh = constraints.maxHeight;
              final mw = constraints.maxWidth;

              var radialSizePercentage = 0.0;
              if (constraints.maxHeight <
                  UiUtils.profileHeightBreakPointResultScreen) {
                verticalSpacePercentage = 0.015;
                radialSizePercentage = 0.6;
              } else {
                verticalSpacePercentage = 0.035;
                radialSizePercentage = 0.525;
              }

              return Column(
                children: [
                  _buildGreetingMessage(
                    scorePct: winPercentage.toInt(),
                    userName: userName,
                  ),
                  SizedBox(height: mh * verticalSpacePercentage),

                  if (widget.quizType == QuizTypes.exam) ...[
                    Transform.translate(
                      offset: const Offset(0, -20),
                      child: RadialPercentageResultContainer(
                        percentage: winPercentage,
                        timeTakenToCompleteQuizInSeconds: widget
                            .timeTakenToCompleteQuiz
                            ?.toInt(),
                        size: Size(
                          mh * radialSizePercentage,
                          mh * radialSizePercentage,
                        ),
                      ),
                    ),

                    Transform.translate(
                      offset: const Offset(0, -30),
                      child: Text(
                        '${widget.obtainedMarks}/${widget.exam!.totalMarks} ${context.tr(markKey)!}',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: MediaQuery.of(
                            context,
                          ).textScaler.scale(22),
                          fontWeight: FontWeight.w400,
                          color: context.primaryTextColor,
                        ),
                      ),
                    ),
                  ] else ...[
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        QImage.circular(
                          imageUrl: userProfileUrl,
                          width: mw * .30,
                          height: mw * .30,
                        ),
                        SvgPicture.asset(
                          Assets.hexagonFrame,
                          width: mw * .37,
                          height: mw * .37,
                        ),
                      ],
                    ),
                  ],
                ],
              );
            },
          ),
        ),

        /// Correct Answer
        Align(
          alignment: AlignmentDirectional.bottomEnd,
          child: _buildResultDataWithIconContainer(
            '$correctAnswers/$totalQuestions',
            Assets.correct,
            const EdgeInsetsDirectional.only(end: 15, bottom: 30),
          ),
        ),

        /// Incorrect Answer
        Align(
          alignment: AlignmentDirectional.bottomStart,
          child: _buildResultDataWithIconContainer(
            '$wrongAnswers/$totalQuestions',
            Assets.wrong,
            const EdgeInsetsDirectional.only(start: 15, bottom: 30),
          ),
        ),

        if (widget.quizType == QuizTypes.selfChallenge)
          Align(
            alignment: Alignment.bottomCenter,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final mh = constraints.maxHeight;
                final double radialSizePercentage;
                if (mh < UiUtils.profileHeightBreakPointResultScreen) {
                  radialSizePercentage = 0.4;
                } else {
                  radialSizePercentage = 0.325;
                }

                return Transform.translate(
                  offset: const Offset(0, 15),
                  child: RadialPercentageResultContainer(
                    percentage: winPercentage,
                    timeTakenToCompleteQuizInSeconds: widget
                        .timeTakenToCompleteQuiz
                        ?.toInt(),
                    size: Size(
                      mh * radialSizePercentage,
                      mh * radialSizePercentage,
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildBattleResultDetails() {
    return BlocBuilder<SetCoinScoreCubit, SetCoinScoreState>(
      builder: (context, state) {
        if (state is SetCoinScoreSuccess) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final coinsString = widget.entryFee! > 0
                  ? " ${state.isWinner ? state.winnerCoins : widget.entryFee} ${context.tr("coinsLbl")!}"
                  : '';

              final BattleUserData winnerUserData;
              final BattleUserData loserUserData;
              final UserBattleRoomDetails winnerDetails;
              final UserBattleRoomDetails loserDetails;

              if (state.isDraw) {
                winnerUserData = state.user1Data!;
                loserUserData = state.user2Data!;
                winnerDetails = widget.battleRoom!.user1!;
                loserDetails = widget.battleRoom!.user2!;
              } else {
                final isUser1Winner = state.user1Id == state.winnerUserId;
                winnerUserData = isUser1Winner
                    ? state.user1Data!
                    : state.user2Data!;
                loserUserData = isUser1Winner
                    ? state.user2Data!
                    : state.user1Data!;
                winnerDetails = isUser1Winner
                    ? widget.battleRoom!.user1!
                    : widget.battleRoom!.user2!;
                loserDetails = isUser1Winner
                    ? widget.battleRoom!.user2!
                    : widget.battleRoom!.user1!;
              }

              return Column(
                children: [
                  _buildGreetingMessage(
                    isWinner: state.isWinner,
                    isDraw: state.isDraw,
                  ),

                  /// Status, You Won or You Lost
                  if (!state.isDraw)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: state.isWinner
                              ? context.primaryColor.withValues(alpha: 0.2)
                              : context.primaryTextColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          "${context.tr(state.isWinner ? 'youWonLbl' : 'youLostLbl')!}$coinsString",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: state.isWinner
                                ? context.primaryColor
                                : context.primaryTextColor,
                          ),
                        ),
                      ),
                    ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  QImage.circular(
                                    width: 80,
                                    height: 80,
                                    imageUrl: winnerDetails.profileUrl,
                                  ),
                                  const QImage(
                                    imageUrl: Assets.hexagonFrame,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.contain,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                winnerDetails.name,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeights.bold,
                                  fontSize: 16,
                                  color: context.primaryTextColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),

                                decoration: BoxDecoration(
                                  color: context.primaryColor.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${winnerUserData.points} ${context.tr('scoreLbl')}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeights.bold,
                                    fontSize: 16,
                                    color: context.primaryColor,
                                  ),
                                ),
                              ),
                              if (winnerUserData.quickestBonus > 0 ||
                                  winnerUserData.secondQuickestBonus > 0) ...[
                                const SizedBox(height: 8),
                                Text(
                                  '+${winnerUserData.quickestBonus + winnerUserData.secondQuickestBonus} ${context.tr('speedBonus')}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeights.bold,
                                    fontSize: 12,
                                    color: context.primaryTextColor,
                                  ),
                                ),
                              ],

                              const SizedBox(height: 8),
                              Text(
                                '${winnerUserData.correctAnswers} / ${state.totalQuestions} ${context.tr("correctAnswersLbl")}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeights.bold,
                                  fontSize: 12,
                                  color: context.primaryTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Vs
                        const SizedBox(width: 4),
                        const Expanded(
                          child: QImage(
                            imageUrl: Assets.versus,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(width: 4),

                        Expanded(
                          flex: 2,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  QImage.circular(
                                    width: 80,
                                    height: 80,
                                    imageUrl: loserDetails.profileUrl,
                                  ),
                                  QImage(
                                    imageUrl: Assets.hexagonFrame,
                                    width: 100,
                                    height: 100,
                                    color: context.primaryTextColor,
                                    fit: BoxFit.contain,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                loserDetails.name,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeights.bold,
                                  fontSize: 16,
                                  color: context.primaryTextColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: context.primaryTextColor.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${loserUserData.points} ${context.tr('scoreLbl')}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeights.bold,
                                    fontSize: 16,
                                    color: context.primaryTextColor,
                                  ),
                                ),
                              ),
                              if (loserUserData.quickestBonus > 0 ||
                                  loserUserData.secondQuickestBonus > 0) ...[
                                const SizedBox(height: 8),
                                Text(
                                  '+${loserUserData.quickestBonus + loserUserData.secondQuickestBonus} ${context.tr('speedBonus')}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeights.bold,
                                    fontSize: 12,
                                    color: context.primaryTextColor,
                                  ),
                                ),
                              ],

                              const SizedBox(height: 8),
                              Text(
                                '${loserUserData.correctAnswers} / ${state.totalQuestions} ${context.tr("correctAnswersLbl")}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeights.bold,
                                  fontSize: 12,
                                  color: context.primaryTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        }

        if (state is SetCoinScoreFailure) {
          return Center(
            child: ErrorContainer(
              showBackButton: true,
              errorMessageColor: Theme.of(context).primaryColor,
              errorMessage: convertErrorCodeToLanguageKey(state.error),
              onTapRetry: () async {
                await _updateResult();
              },
              showErrorImage: true,
            ),
          );
        }

        return const Center(child: CircularProgressContainer());
      },
    );
  }

  Widget _buildResultContainer(BuildContext context) {
    return BlocListener<SetCoinScoreCubit, SetCoinScoreState>(
      listener: (context, state) {
        if (state is SetCoinScoreSuccess) {
          setState(() {
            _isWinner =
                state.percentage >
                context.read<SystemConfigCubit>().quizWinningPercentage;
          });
        }
      },
      child: Screenshot(
        controller: screenshotController,
        child: Container(
          height: context.height * 0.56,
          width: context.width * 0.9,
          decoration: BoxDecoration(
            color: _isWinner
                ? context.surfaceColor
                : context.primaryTextColor.withValues(alpha: .05),
            borderRadius: BorderRadius.circular(10),
          ),
          child: switch (widget.quizType) {
            QuizTypes.oneVsOneBattle ||
            QuizTypes.randomBattle => _buildBattleResultDetails(),
            QuizTypes.selfChallenge ||
            QuizTypes.exam => _buildSelfChallengeOrExamResultContainer(),
            _ => _buildIndividualResultContainer(),
          },
        ),
      ),
    );
  }

  Widget _buildButton(
    String buttonTitle,
    VoidCallback onTap, {
    IconData? leadingIcon,
    IconData? trailingIcon,
    bool isPrimary = false,
    bool isTertiary = false,
  }) {
    return _buildActionButton(
      title: buttonTitle,
      onTap: onTap,
      leadingIcon: leadingIcon,
      trailingIcon: trailingIcon,
      isPrimary: isPrimary,
      isTertiary: isTertiary,
    );
  }

  //play again button will be build different for every quizType
  Widget _buildPlayAgainButton() {
    if (widget.quizType == QuizTypes.audioQuestions) {
      return _buildButton(
        context.tr('playAgainBtn')!,
        () {
          fetchUpdateUserDetails();
          Navigator.of(context).pushReplacementNamed(
            Routes.quiz,
            arguments: {
              'isPlayed': widget.isPlayed,
              'quizType': QuizTypes.audioQuestions,
              'subcategoryId': widget.questions!.first.subcategoryId == '0'
                  ? ''
                  : widget.questions!.first.subcategoryId,
              'categoryId': widget.questions!.first.subcategoryId == '0'
                  ? widget.questions!.first.categoryId
                  : '',
            },
          );
        },
        isPrimary: true,
        trailingIcon: Icons.chevron_right,
      );
    } else if (widget.quizType == QuizTypes.guessTheWord) {
      if (_isWinner) {
        return const SizedBox();
      }

      return _buildButton(
        context.tr('playAgainBtn')!,
        () async {
          await context.pushReplacementNamed(
            Routes.guessTheWord,
            arguments: GuessTheWordQuizScreenArgs(
              categoryId: widget.categoryId!,
              subcategoryId: widget.subcategoryId!.isNotEmpty
                  ? widget.subcategoryId
                  : null,
              isPlayed: widget.isPlayed,
              isPremiumCategory: widget.isPremiumCategory,
            ),
          );
        },
        isPrimary: true,
        trailingIcon: Icons.chevron_right,
      );
    } else if (widget.quizType == QuizTypes.quizZone) {
      //if user is winner
      if (_isWinner) {
        //we need to check if currentLevel is last level or not
        final maxLevel = int.parse(widget.subcategoryMaxLevel!);
        final currentLevel = int.parse(widget.questions!.first.level!);
        if (maxLevel == currentLevel) {
          return const SizedBox.shrink();
        }
        return _buildButton(
          'Continue to Next Level',
          () {
            //if given level is same as unlocked level then we need to update level
            //else do not update level
            final unlockedLevel =
                int.parse(widget.questions!.first.level!) ==
                    widget.unlockedLevel
                ? (widget.unlockedLevel! + 1)
                : widget.unlockedLevel;
            //play quiz for next level
            Navigator.of(context).pushReplacementNamed(
              Routes.quiz,
              arguments: {
                'quizType': widget.quizType,
                //if subcategory id is empty for question means we need to fetch question by it's category
                'categoryId': widget.categoryId,
                'subcategoryId': widget.subcategoryId,
                'level': (currentLevel + 1).toString(),
                //increase level
                'subcategoryMaxLevel': widget.subcategoryMaxLevel,
                'unlockedLevel': unlockedLevel,
              },
            );
          },
          isPrimary: true,
          trailingIcon: Icons.chevron_right,
        );
      }
      //if user failed to complete this level
      return _buildButton(
        context.tr('playAgainBtn')!,
        () {
          fetchUpdateUserDetails();
          //to play this level again (for quizZone quizType)
          Navigator.of(context).pushReplacementNamed(
            Routes.quiz,
            arguments: {
              'quizType': widget.quizType,
              //if subcategory id is empty for question means we need to fetch questions by it's category
              'categoryId': widget.categoryId,
              'subcategoryId': widget.subcategoryId,
              'level': widget.questions!.first.level,
              'unlockedLevel': widget.unlockedLevel,
              'subcategoryMaxLevel': widget.subcategoryMaxLevel,
            },
          );
        },
        isPrimary: true,
        trailingIcon: Icons.chevron_right,
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildShareYourScoreButton() {
    return Builder(
      builder: (context) {
        return _buildButton(
          context.tr('shareScoreBtn')!,
          () async {
            if (_isShareInProgress) return;

            setState(() => _isShareInProgress = true);

            try {
              //capturing image
              final image = await screenshotController.capture();
              //root directory path
              final directory = (await getApplicationDocumentsDirectory()).path;

              final fileName = DateTime.now().microsecondsSinceEpoch.toString();
              //create file with given path
              final file = await File('$directory/$fileName.png').create();
              //write as bytes
              await file.writeAsBytes(image!.buffer.asUint8List());

              final appLink = context.read<SystemConfigCubit>().appUrl;

              final referralCode =
                  context.read<UserDetailsCubit>().getUserProfile().referCode ??
                  '';

              final scoreText =
                  '$kAppName'
                  "\n${context.tr('myScoreLbl')!}"
                  "\n${context.tr("appLink")!}"
                  '\n$appLink'
                  "\n${context.tr("useMyReferral")} $referralCode ${context.tr("toGetCoins")}";

              await UiUtils.share(
                scoreText,
                files: [XFile(file.path)],
                context: context,
              ).onError(
                (e, s) => ShareResult('$e', ShareResultStatus.dismissed),
              );
            } on Exception catch (_) {
              if (!mounted) return;

              context.showSnack(
                context.tr(
                  convertErrorCodeToLanguageKey(errorCodeDefaultMessage),
                )!,
              );
            } finally {
              if (mounted) {
                setState(() => _isShareInProgress = false);
              }
            }
          },
          leadingIcon: Icons.share_outlined,
        );
      },
    );
  }

  bool _unlockedReviewAnswersOnce = false;

  Widget _buildReviewAnswersButton() {
    Future<void> onTapYesReviewAnswers() async {
      final reviewAnswersDeductCoins = context
          .read<SystemConfigCubit>()
          .reviewAnswersDeductCoins;
      //check if user has enough coins
      if (int.parse(context.read<UserDetailsCubit>().getCoins()!) <
          reviewAnswersDeductCoins) {
        await showNotEnoughCoinsDialog(context);
        return;
      }

      /// update coins
      await context
          .read<UpdateCoinsCubit>()
          .updateCoins(
            coins: reviewAnswersDeductCoins,
            addCoin: false,
            title: reviewAnswerLbl,
          )
          .then((_) async {
            final state = context.read<UpdateCoinsCubit>().state;
            if (state is UpdateCoinsFailure) {
              context
                ..shouldPop()
                ..showSnack(
                  context.tr(
                        convertErrorCodeToLanguageKey(state.errorMessage),
                      ) ??
                      context.tr(errorCodeDefaultMessage)!,
                );
              return;
            } else if (state is UpdateCoinsSuccess) {
              context.read<UserDetailsCubit>().updateCoins(
                addCoin: false,
                coins: reviewAnswersDeductCoins,
              );

              _unlockedReviewAnswersOnce = true;
              await context.pushNamed(
                Routes.reviewAnswers,
                arguments: ReviewAnswersScreenArgs(
                  quizType: widget.quizType!,
                  questions: widget.quizType == QuizTypes.guessTheWord
                      ? []
                      : widget.questions!,
                  guessTheWordQuestions:
                      widget.quizType == QuizTypes.guessTheWord
                      ? widget.guessTheWordQuestions!
                      : [],
                ),
              );
            }
          });
    }

    return _buildButton(
      context.tr('reviewAnsBtn')!,
      () async {
        if (_isReviewInProgress) return;

        if (_unlockedReviewAnswersOnce) {
          await context.pushNamed(
            Routes.reviewAnswers,
            arguments: ReviewAnswersScreenArgs(
              quizType: widget.quizType!,
              questions: widget.quizType == QuizTypes.guessTheWord
                  ? []
                  : widget.questions!,
              guessTheWordQuestions: widget.quizType == QuizTypes.guessTheWord
                  ? widget.guessTheWordQuestions!
                  : [],
            ),
          );
          return;
        }

        setState(() => _isReviewInProgress = true);

        try {
          await context.showDialog<void>(
            title: context.tr('reviewAnswers'),
            image: Assets.coinsDialogIcon,
            message:
                '${context.tr('spend')} ${context.read<SystemConfigCubit>().reviewAnswersDeductCoins} ${context.tr('reviewAnsMessage')}',
            onConfirm: onTapYesReviewAnswers,
            confirmButtonText: context.tr('reviewAndImprove'),
            cancelButtonText: context.tr('notNow'),
          );
        } finally {
          if (mounted) {
            setState(() => _isReviewInProgress = false);
          }
        }
      },
      leadingIcon: Icons.article_outlined,
    );
  }

  Widget _buildHomeButton() {
    void onTapHomeButton() {
      fetchUpdateUserDetails();
      globalCtx.pushNamedAndRemoveUntil(Routes.home, predicate: (_) => false);
      dashboardScreenKey.currentState?.changeTab(NavTabType.home);
    }

    return _buildButton(
      context.tr('homeBtn')!,
      onTapHomeButton,
      leadingIcon: Icons.home_outlined,
      isTertiary: true,
    );
  }

  Widget _buildResultButtons(BuildContext context) {
    const buttonSpace = SizedBox(height: 15);

    return Column(
      children: [
        if (widget.quizType! == QuizTypes.audioQuestions ||
            widget.quizType == QuizTypes.guessTheWord ||
            widget.quizType == QuizTypes.quizZone) ...[
          _buildPlayAgainButton(),
          buttonSpace,
        ],
        if (widget.quizType == QuizTypes.quizZone ||
            widget.quizType == QuizTypes.dailyQuiz ||
            widget.quizType == QuizTypes.trueAndFalse ||
            widget.quizType == QuizTypes.selfChallenge ||
            widget.quizType == QuizTypes.audioQuestions ||
            widget.quizType == QuizTypes.guessTheWord ||
            widget.quizType == QuizTypes.funAndLearn ||
            widget.quizType == QuizTypes.mathMania) ...[
          _buildReviewAnswersButton(),
          buttonSpace,
        ],
        _buildShareYourScoreButton(),
        buttonSpace,
        _buildHomeButton(),
        buttonSpace,
      ],
    );
  }

  Widget _buildBackButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          onPageBackCalls();
          Navigator.pop(context);
        },
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF1E3A8A),
            size: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildRedesignedResultContent() {
    if (widget.quizType == QuizTypes.selfChallenge ||
        widget.quizType == QuizTypes.exam) {
      return _buildRedesignedResultLayout(_buildResultViewDataFromLocal());
    }

    return BlocConsumer<SetCoinScoreCubit, SetCoinScoreState>(
      listener: (context, state) {
        if (state is SetCoinScoreSuccess) {
          setState(() {
            _isWinner =
                state.percentage >
                context.read<SystemConfigCubit>().quizWinningPercentage;
          });
        }
      },
      builder: (context, state) {
        if (state is SetCoinScoreSuccess) {
          return _buildRedesignedResultLayout(
            _buildResultViewDataFromState(state),
          );
        }

        if (state is SetCoinScoreFailure) {
          return Center(
            child: ErrorContainer(
              showBackButton: true,
              errorMessageColor: context.primaryColor,
              errorMessage: convertErrorCodeToLanguageKey(state.error),
              onTapRetry: () async {
                await _updateResult();
              },
              showErrorImage: true,
            ),
          );
        }

        return const Center(child: CircularProgressContainer());
      },
    );
  }

  Widget _buildRedesignedBody() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFDFF1FF), Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            _buildConfettiDots(),
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: _buildBackButton(),
                    ),
                    const SizedBox(height: 12),
                    Screenshot(
                      controller: screenshotController,
                      child: _buildRedesignedResultContent(),
                    ),
                    const SizedBox(height: 24),
                    _buildResultButtons(context),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  late final String _appbarTitle = context.tr(switch (widget.quizType) {
    QuizTypes.selfChallenge => 'selfChallengeResult',
    QuizTypes.audioQuestions => 'audioQuizResult',
    QuizTypes.mathMania => 'mathQuizResult',
    QuizTypes.guessTheWord => 'guessTheWordResult',
    QuizTypes.exam => 'examResult',
    QuizTypes.dailyQuiz => 'dailyQuizResult',
    QuizTypes.randomBattle => 'randomBattleResult',
    QuizTypes.oneVsOneBattle => 'oneVsOneBattleResult',
    QuizTypes.funAndLearn => 'funAndLearnResult',
    QuizTypes.trueAndFalse => 'truefalseQuizResult',
    QuizTypes.bookmarkQuiz => 'bookmarkQuizResult',
    _ => 'quizResultLbl',
  })!;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;

        if (context.read<UserDetailsCubit>().state
            is UserDetailsFetchInProgress) {
          return;
        }

        onPageBackCalls();
        context.shouldPop();
      },
      child: MultiBlocListener(
        listeners: [
          BlocListener<UpdateCoinsCubit, UpdateCoinsState>(
            listener: (context, state) {
              if (state is UpdateCoinsFailure) {
                if (state.errorMessage == errorCodeUnauthorizedAccess) {
                  //already showed already logged in from other api error
                  if (!_displayedAlreadyLoggedInDialog) {
                    _displayedAlreadyLoggedInDialog = true;
                    showAlreadyLoggedInDialog(context);
                    return;
                  }
                }
              }
            },
          ),
        ],
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: _isBattleResult
              ? QAppBar(
                  roundedAppBar: false,
                  title: Text(_appbarTitle),
                  onTapBackButton: () {
                    onPageBackCalls();
                    Navigator.pop(context);
                  },
                )
              : null,
          body: _isBattleResult
              ? SingleChildScrollView(
                  child: Column(
                    children: [
                      Center(child: _buildResultContainer(context)),
                      const SizedBox(height: 20),
                      _buildResultButtons(context),
                    ],
                  ),
                )
              : _buildRedesignedBody(),
        ),
      ),
    );
  }
}

class _ConfettiDot extends StatelessWidget {
  const _ConfettiDot({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.45),
        shape: BoxShape.circle,
      ),
    );
  }
}
