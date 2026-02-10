import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutterquiz/commons/commons.dart';
import 'package:flutterquiz/core/core.dart';
import 'package:flutterquiz/features/ads/blocs/interstitial_ad_cubit.dart';
import 'package:flutterquiz/features/ads/blocs/rewarded_interstitial_ad_cubit.dart';
import 'package:flutterquiz/features/profile_management/cubits/update_score_and_coins_cubit.dart';
import 'package:flutterquiz/features/profile_management/cubits/user_details_cubit.dart';
import 'package:flutterquiz/features/profile_management/profile_management_repository.dart';
import 'package:flutterquiz/features/quiz/cubits/set_coin_score_cubit.dart';
import 'package:flutterquiz/features/quiz/cubits/subcategory_cubit.dart';
import 'package:flutterquiz/features/quiz/cubits/unlocked_level_cubit.dart';
import 'package:flutterquiz/features/quiz/models/quiz_type.dart';
import 'package:flutterquiz/features/quiz/multi_match/models/multi_match_question_model.dart';
import 'package:flutterquiz/features/skill_tier/models/skill_tier.dart';
import 'package:flutterquiz/features/skill_tier/skill_tier_service.dart';
import 'package:flutterquiz/features/system_config/cubits/system_config_cubit.dart';
import 'package:flutterquiz/ui/screens/quiz/multi_match/screens/multi_match_quiz_screen.dart';
import 'package:flutterquiz/ui/screens/quiz/multi_match/screens/multi_match_review_screen.dart';
import 'package:flutterquiz/ui/widgets/all.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

final class MultiMatchResultScreenArgs extends RouteArgs {
  const MultiMatchResultScreenArgs({
    required this.questions,
    required this.totalLevels,
    required this.unlockedLevel,
    required this.categoryId,
    required this.timeTakenToCompleteQuiz,
    required this.isPremiumCategory,
    this.subcategoryId,
  });

  final List<MultiMatchQuestion> questions;
  final int totalLevels;
  final int unlockedLevel;
  final String categoryId;
  final String? subcategoryId;
  final int timeTakenToCompleteQuiz;
  final bool isPremiumCategory;
}

class MultiMatchResultScreen extends StatefulWidget {
  const MultiMatchResultScreen({required this.args, super.key});

  final MultiMatchResultScreenArgs args;

  @override
  State<MultiMatchResultScreen> createState() => _MultiMatchResultScreenState();

  static Route<dynamic> route(RouteSettings settings) {
    final args = settings.args<MultiMatchResultScreenArgs>();

    return CupertinoPageRoute(
      builder: (_) => MultiBlocProvider(
        providers: [
          // For Updating Result
          BlocProvider(create: (_) => SetCoinScoreCubit()),
          // For Deducting coins for Review Answers
          BlocProvider<UpdateCoinsCubit>(
            create: (_) => UpdateCoinsCubit(ProfileManagementRepository()),
          ),
        ],
        child: MultiMatchResultScreen(args: args),
      ),
    );
  }
}

class _MultiMatchResultScreenState extends State<MultiMatchResultScreen> {
  final ScreenshotController screenshotController = ScreenshotController();

  late final String userName = context.read<UserDetailsCubit>().getUserName();

  bool _isWinner = false;
  bool _isShareInProgress = false;
  bool _isReviewInProgress = false;
  bool _unlockedReviewAnswersOnce = false;
  String _skillTierLabel = '--';

  static int _quizCompletionCount = 0;

  late final int _currLevel = int.parse(widget.args.questions.first.level);

  @override
  void initState() {
    super.initState();

    _loadSkillTierLabel();

    if (!widget.args.isPremiumCategory) {
      log(
        '[MM_RESULT_ADS] Preparing ads (premium: ${widget.args.isPremiumCategory})',
      );
      context.read<RewardedInterstitialAdCubit>().createRewardedInterstitialAd(
        context,
      );
      context.read<InterstitialAdCubit>().createInterstitialAd(context);
    }

    /// show ad
    Future.delayed(Duration.zero, () async {
      _quizCompletionCount++;

      final adsEnabled = context.read<SystemConfigCubit>().isAdsEnable;
      final adsRemoved = context.read<UserDetailsCubit>().removeAds();

      log(
        '[MM_RESULT_ADS] Trigger (count: $_quizCompletionCount, enabled: $adsEnabled, removed: $adsRemoved)',
      );

      if (!widget.args.isPremiumCategory && adsEnabled && !adsRemoved) {
        if (_quizCompletionCount % 2 == 0) {
          final rewardCoins = context.read<SystemConfigCubit>().rewardAdsCoins;
          final rewardedCubit = context.read<RewardedInterstitialAdCubit>();
          final interstitialCubit = context.read<InterstitialAdCubit>();

          log(
            '[MM_RESULT_ADS] Rewarded attempt (state: ${rewardedCubit.state}, reward: $rewardCoins)',
          );

          if (rewardedCubit.state == RewardedInterstitialAdState.loaded) {
            await rewardedCubit.showAd(
              context: context,
              rewardAmount: rewardCoins,
              rewardCurrencyLabel: 'coins',
              onAdDismissedCallback: () {},
            );
          } else {
            await rewardedCubit.createRewardedInterstitialAd(context);
            if (rewardedCubit.state == RewardedInterstitialAdState.loaded) {
              log('[MM_RESULT_ADS] Rewarded loaded after create');
              await rewardedCubit.showAd(
                context: context,
                rewardAmount: rewardCoins,
                rewardCurrencyLabel: 'coins',
                onAdDismissedCallback: () {},
              );
            } else {
              log(
                '[MM_RESULT_ADS] Rewarded not loaded, fallback to interstitial',
              );
              await interstitialCubit.showAd(context);
            }
          }
        } else {
          log('[MM_RESULT_ADS] Interstitial attempt');
          await context.read<InterstitialAdCubit>().showAd(context);
        }
      }
    });

    Future.delayed(Duration.zero, () async {
      await _updateResult();
      await _fetchUserDetails();
    });
  }

  Future<void> _loadSkillTierLabel() async {
    final tier = await SkillTierService.computeTier();
    if (!mounted) return;
    final label = tier != null ? SkillTier.label(tier.type) : '--';
    setState(() {
      _skillTierLabel = label;
    });
  }

  Future<void> _updateResult() async {
    final type = QuizTypes.multiMatch.typeValue!;

    final playedQuestions = widget.args.questions
        .map(
          (q) => <String, String>{
            'id': q.id,
            'answer': q.submittedIds.join(','),
          },
        )
        .toList();

    await context.read<SetCoinScoreCubit>().setCoinScore(
      categoryId: widget.args.categoryId,
      subcategoryId: widget.args.subcategoryId,
      quizType: type,
      playedQuestions: playedQuestions,
    );
  }

  Future<void> _fetchUserDetails() async {
    await context.read<UserDetailsCubit>().fetchUserDetails();
  }

  void _onBack() {
    if (widget.args.subcategoryId == null) {
      context.read<UnlockedLevelCubit>().fetchUnlockLevel(
        widget.args.categoryId,
        '',
        quizType: QuizTypes.multiMatch,
      );
    } else {
      context.read<SubCategoryCubit>().fetchSubCategory(widget.args.categoryId);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _onBack();
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: _buildRedesignedBody(),
      ),
    );
  }
}

class _ResultViewData {
  const _ResultViewData({
    required this.percentage,
    required this.correct,
    required this.total,
    required this.score,
    required this.coins,
    required this.timeLabel,
  });

  final int percentage;
  final int correct;
  final int total;
  final int score;
  final int coins;
  final String timeLabel;

  int get wrong => total - correct;
}

extension on _MultiMatchResultScreenState {
  String _formatTime(int? totalSeconds) {
    final total = totalSeconds ?? 0;
    if (total <= 0) return '--';
    final minutes = total ~/ 60;
    final seconds = total % 60;
    final minutesText = minutes < 10 ? '0$minutes' : '$minutes';
    final secondsText = seconds < 10 ? '0$seconds' : '$seconds';
    return '$minutesText:$secondsText';
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

  Widget _buildBackButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: _onBack,
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

  Widget _buildHeaderSection() {
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
          'Congratulations ${userName.split(' ').first}, you passed!',
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
              value: _skillTierLabel,
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

  Widget _buildResultContent() {
    return BlocConsumer<SetCoinScoreCubit, SetCoinScoreState>(
      listener: (context, state) {
        if (state is SetCoinScoreSuccess) {
          setState(() {
            _isWinner =
                state.percentage >=
                context.read<SystemConfigCubit>().quizWinningPercentage;
          });
        }
      },
      builder: (context, state) {
        if (state is SetCoinScoreFailure) {
          return ErrorContainer(
            showBackButton: true,
            errorMessageColor: Theme.of(context).primaryColor,
            errorMessage: convertErrorCodeToLanguageKey(state.error),
            onTapRetry: () async {
              await _updateResult();
            },
            showErrorImage: true,
          );
        }

        if (state is SetCoinScoreSuccess) {
          final data = _ResultViewData(
            percentage: state.percentage,
            correct: state.correctAnswer,
            total: state.totalQuestions,
            score: state.earnScore,
            coins: state.earnCoin,
            timeLabel: _formatTime(widget.args.timeTakenToCompleteQuiz),
          );

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
                      child: _buildResultContent(),
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

  Widget _buildResultButtons(BuildContext context) {
    const buttonSpace = SizedBox(height: 15);

    return Column(
      children: [
        if (_isWinner && _currLevel != widget.args.totalLevels) ...[
          _buildPlayNextLevelButton(),
          buttonSpace,
        ],
        if (!_isWinner) ...[_buildPlayAgainButton(), buttonSpace],
        _buildReviewAnswersButton(),
        buttonSpace,
        _buildShareYourScoreButton(),
        buttonSpace,
        _buildHomeButton(),
        buttonSpace,
      ],
    );
  }

  Widget _buildButton(
    String title,
    VoidCallback onTap, {
    IconData? leadingIcon,
    IconData? trailingIcon,
    bool isPrimary = false,
    bool isTertiary = false,
  }) {
    return _buildActionButton(
      title: title,
      onTap: onTap,
      leadingIcon: leadingIcon,
      trailingIcon: trailingIcon,
      isPrimary: isPrimary,
      isTertiary: isTertiary,
    );
  }

  Widget _buildPlayAgainButton() {
    return _buildButton(
      context.tr('playAgainBtn')!,
      () {
        context.pushReplacementNamed(
          Routes.multiMatchQuiz,
          arguments: MultiMatchQuizArgs(
            categoryId: widget.args.categoryId,
            subcategoryId: widget.args.subcategoryId,
            level: _currLevel.toString(),
            unlockedLevel: widget.args.unlockedLevel,
            totalLevels: widget.args.totalLevels,
            isPremiumCategory: widget.args.isPremiumCategory,
          ),
        );
      },
      isPrimary: true,
      trailingIcon: Icons.chevron_right,
    );
  }

  Widget _buildPlayNextLevelButton() {
    return _buildButton(
      'Continue to Next Level',
      () {
        final unlockedLevel = _currLevel == widget.args.unlockedLevel
            ? _currLevel + 1
            : widget.args.unlockedLevel;

        context.pushReplacementNamed(
          Routes.multiMatchQuiz,
          arguments: MultiMatchQuizArgs(
            categoryId: widget.args.categoryId,
            subcategoryId: widget.args.subcategoryId,
            level: (_currLevel + 1).toString(),
            unlockedLevel: unlockedLevel,
            totalLevels: widget.args.totalLevels,
            isPremiumCategory: widget.args.isPremiumCategory,
          ),
        );
      },
      isPrimary: true,
      trailingIcon: Icons.chevron_right,
    );
  }

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
                Routes.multiMatchReviewScreen,
                arguments: MultiMatchReviewScreenArgs(
                  questions: widget.args.questions,
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
            Routes.multiMatchReviewScreen,
            arguments: MultiMatchReviewScreenArgs(
              questions: widget.args.questions,
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

  Widget _buildShareYourScoreButton() {
    Future<void> onTap() async {
      if (_isShareInProgress) return;

      setState(() => _isShareInProgress = true);

      try {
        final image = await screenshotController.capture();
        final directory = (await getApplicationDocumentsDirectory()).path;

        final fileName = DateTime.now().microsecondsSinceEpoch.toString();
        final file = await File('$directory/$fileName.png').create();
        await file.writeAsBytes(image!.buffer.asUint8List());

        final appLink = context.read<SystemConfigCubit>().appUrl;

        final referralCode =
            context.read<UserDetailsCubit>().getUserProfile().referCode ?? '';

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
        ).onError((e, s) => ShareResult('$e', ShareResultStatus.dismissed));
      } on Exception catch (_) {
        if (!mounted) return;

        context.showSnack(
          context.tr(convertErrorCodeToLanguageKey(errorCodeDefaultMessage))!,
        );
      } finally {
        if (mounted) {
          setState(() => _isShareInProgress = false);
        }
      }
    }

    return Builder(
      builder: (context) {
        return _buildButton(
          context.tr('shareScoreBtn')!,
          onTap,
          leadingIcon: Icons.share_outlined,
        );
      },
    );
  }

  Widget _buildHomeButton() {
    void onTapHomeButton() {
      _fetchUserDetails();
      context.pushNamedAndRemoveUntil(Routes.home, predicate: (_) => false);
    }

    return _buildButton(
      context.tr('homeBtn')!,
      onTapHomeButton,
      leadingIcon: Icons.home_outlined,
      isTertiary: true,
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
