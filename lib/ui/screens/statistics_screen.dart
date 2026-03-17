import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutterquiz/commons/bottom_nav/models/nav_tab_type_enum.dart';
import 'package:flutterquiz/commons/screens/dashboard_screen.dart';
import 'package:flutterquiz/core/core.dart';
import 'package:flutterquiz/features/ads/blocs/interstitial_ad_cubit.dart';
import 'package:flutterquiz/features/ads/utils/ad_feature_flags.dart';
import 'package:flutterquiz/features/badges/blocs/badges_cubit.dart';
import 'package:flutterquiz/features/statistic/cubits/statistics_cubit.dart';
import 'package:flutterquiz/features/statistic/statistic_repository.dart';
import 'package:flutterquiz/features/system_config/cubits/system_config_cubit.dart';
import 'package:flutterquiz/ui/widgets/all.dart';
import 'package:flutterquiz/ui/widgets/badges_icon_container.dart';
import 'package:flutterquiz/utils/extensions.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();

  static Route<StatisticsScreen> route() => CupertinoPageRoute(
    builder: (_) => BlocProvider<StatisticCubit>(
      create: (_) => StatisticCubit(StatisticRepository()),
      child: const StatisticsScreen(),
    ),
  );
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  static bool _shownInterstitialThisLaunch = false;
  static const _detailsCardHeightPercentage = 0.145;
  static const _detailsCardBorderRadius = 20.0;
  static const _showTotalBadgesCounter = 4;

  static const _primaryBlue = Color(0xFF2E6CF6);
  static const _textBlue = Color(0xFF1E3A8A);
  static const _mutedBlue = Color(0xFF7B8BB5);
  static const _cardBorder = Color(0xFFDCE6F6);

  TextStyle get _detailsTitleTextStyle => const TextStyle(
    fontWeight: FontWeight.w700,
    color: _textBlue,
    fontSize: 16,
  );

  static const _correctAnsColor = Color(0xFF62A9CD);
  static const _incorrectAnsColor = Color(0xFF8C4593);
  static const _wonColor = Color(0xFF90C88A);
  static const _lostColor = Color(0xFFF79478);

  final _boxShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 14,
      offset: const Offset(0, 8),
    ),
  ];

  BoxDecoration get _cardDecoration => BoxDecoration(
    boxShadow: _boxShadow,
    color: Colors.white,
    borderRadius: BorderRadius.circular(_detailsCardBorderRadius),
    border: Border.all(color: _cardBorder),
  );

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      context.read<StatisticCubit>().getStatisticWithBattle();
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

  Widget _buildCollectedBadgesContainer() {
    final size = context;

    return BlocBuilder<BadgesCubit, BadgesState>(
      bloc: context.read<BadgesCubit>(),
      builder: (context, state) {
        final unlockedBadges = context.read<BadgesCubit>().getUnlockedBadges();

        if (state is! BadgesFetchSuccess || unlockedBadges.isEmpty) {
          return const SizedBox.shrink();
        }

        void onTapViewAll() => Navigator.of(context).pushNamed(Routes.badges);

        final visibleBadges = (unlockedBadges.length < _showTotalBadgesCounter
            ? unlockedBadges
            : unlockedBadges.sublist(0, _showTotalBadgesCounter));

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: Column(
            children: [
              Row(
                children: [
                  const SizedBox(width: 5),
                  Text(
                    context.tr(collectedBadgesKey)!,
                    style: _detailsTitleTextStyle,
                  ),
                  const Spacer(),
                  if (unlockedBadges.length > _showTotalBadgesCounter)
                    GestureDetector(
                      onTap: onTapViewAll,
                      child: Text(
                        context.tr(viewAllKey)!,
                        style: const TextStyle(
                          color: _primaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  else
                    const SizedBox(),
                  const SizedBox(width: 5),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                height: context.height * _detailsCardHeightPercentage,
                decoration: _cardDecoration,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: visibleBadges
                      .map(
                        (badge) => Container(
                          width: size.width * .20,
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              BadgesIconContainer(
                                addTopPadding: false,
                                badge: badge,
                                constraints: BoxConstraints(
                                  maxHeight:
                                      size.height *
                                      _detailsCardHeightPercentage,
                                  maxWidth: size.width * 0.2,
                                ),
                              ),
                              SizedBox(
                                height: 40,
                                child: Text(
                                  context.tr('${badge.type}_label') ??
                                      badge.type,
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeights.medium,
                                    fontSize: 14,
                                    color: _textBlue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuestionDetailsContainer() {
    final statistics = context.read<StatisticCubit>().getStatisticsDetails();

    final totalAnswers = int.parse(statistics.answeredQuestions);
    final correctAnswers = int.parse(statistics.correctAnswers);
    final incorrectAnswers = totalAnswers - correctAnswers;

    const textStyle = TextStyle(
      color: _mutedBlue,
      fontSize: 16,
      fontWeight: FontWeight.w600,
    );

    return Column(
      children: [
        Row(
          children: [
            const SizedBox(width: 5),
            Text(
              context.tr(questionDetailsKey)!,
              style: _detailsTitleTextStyle,
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          height: context.height * _detailsCardHeightPercentage,
          decoration: _cardDecoration,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 20,
                    ),
                    child: StatisticsPieChart(
                      width: 82,
                      height: 82,
                      values: [
                        (no: correctAnswers, arcColor: _correctAnsColor),
                        (no: incorrectAnswers, arcColor: _incorrectAnsColor),
                      ],
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              statistics.answeredQuestions,
                              style: textStyle.copyWith(
                                color: _textBlue,
                                fontWeight: FontWeights.bold,
                              ),
                            ),
                            Text(
                              context.tr(totalKey)!,
                              style: textStyle.copyWith(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            _dot(_correctAnsColor),
                            const SizedBox(width: 10),
                            Text(
                              '${context.tr(correctKey)!} : ',
                              style: textStyle,
                            ),
                            Text(
                              statistics.correctAnswers,
                              style: textStyle.copyWith(
                                color: _textBlue,
                                fontWeight: FontWeights.bold,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            _dot(_incorrectAnsColor),
                            const SizedBox(width: 10),
                            Text(
                              '${context.tr(incorrectKey)!} : ',
                              style: textStyle,
                            ),
                            Text(
                              incorrectAnswers.toString(),
                              style: textStyle.copyWith(
                                color: _textBlue,
                                fontWeight: FontWeights.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _dot(Color? color, {double size = 8}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }

  Widget _buildBattleStatisticsContainer() {
    final statistics = context.read<StatisticCubit>().getStatisticsDetails();

    final won = int.parse(statistics.battleVictories);
    final lost = int.parse(statistics.battleLoose);
    final drawn = int.parse(statistics.battleDrawn);
    final total = won + lost + drawn;

    return Column(
      children: [
        Row(
          children: [
            const SizedBox(width: 5),
            Text(
              context.tr(battleStatisticsKey)!,
              style: _detailsTitleTextStyle,
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          height: context.height * _detailsCardHeightPercentage,
          decoration: BoxDecoration(
            boxShadow: _boxShadow,
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(_detailsCardBorderRadius),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              const textStyle = TextStyle(
                color: _mutedBlue,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              );

              return Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 20,
                    ),
                    child: StatisticsPieChart(
                      width: 82,
                      height: 82,
                      values: [
                        (no: drawn, arcColor: _incorrectAnsColor),
                        (no: lost, arcColor: _lostColor),
                        (no: won, arcColor: _wonColor),
                      ],
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              total.toString(),
                              style: textStyle.copyWith(
                                color: _textBlue,
                                fontWeight: FontWeights.bold,
                              ),
                            ),
                            Text(
                              context.tr(totalKey)!,
                              style: textStyle.copyWith(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            _dot(_incorrectAnsColor),
                            const SizedBox(width: 10),
                            Text("${context.tr("draw")!} : ", style: textStyle),
                            Text(
                              statistics.battleDrawn,
                              style: textStyle.copyWith(
                                color: _textBlue,
                                fontWeight: FontWeights.bold,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            _dot(_wonColor),
                            const SizedBox(width: 10),
                            Text('${context.tr(wonKey)!} : ', style: textStyle),
                            Text(
                              won.toString(),
                              style: textStyle.copyWith(
                                color: _textBlue,
                                fontWeight: FontWeights.bold,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            _dot(_lostColor),
                            const SizedBox(width: 10),
                            Text(
                              '${context.tr(lostKey)!} : ',
                              style: textStyle,
                            ),
                            Text(
                              statistics.battleLoose,
                              style: textStyle.copyWith(
                                color: _textBlue,
                                fontWeight: FontWeights.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _noStatistics() {
    void onTapPlay() {
      globalCtx.shouldPop();
      dashboardScreenKey.currentState?.changeTab(NavTabType.quizZone);
    }

    void onTapHome() {
      globalCtx.shouldPop();
      dashboardScreenKey.currentState?.changeTab(NavTabType.home);
    }

    return SizedBox(
      height: context.height * 0.75,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            Assets.notFound,
            height: context.height * 0.18,
            width: context.width * 0.18,
          ),
          SizedBox(height: context.height * 0.015),
          Text(
            context.tr('noStatisticsLbl')!,
            style: TextStyle(
              color: context.primaryTextColor,
              fontWeight: FontWeights.bold,
              fontSize: 22,
            ),
          ),
          SizedBox(height: context.height * 0.02),
          Text(
            context.tr('noStatisticsDescLbl')!,
            style: TextStyle(
              color: context.primaryTextColor,
              fontWeight: FontWeights.regular,
              fontSize: 20,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: context.height * 0.035),
          if (context.read<SystemConfigCubit>().isQuizZoneEnabled) ...[
            CustomRoundedButton(
              widthPercentage: context.width,
              backgroundColor: context.primaryColor,
              buttonTitle: context.tr(playLbl),
              radius: 10,
              showBorder: false,
              height: 50,
              onTap: onTapPlay,
            ),
            SizedBox(height: context.height * 0.015),
          ],
          CustomRoundedButton(
            widthPercentage: context.width,
            backgroundColor: context.scaffoldBackgroundColor,
            buttonTitle: context.tr(homeBtn),
            radius: 10,
            showBorder: false,
            height: 50,
            titleColor: context.primaryColor,
            onTap: onTapHome,
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsContainer({
    required bool showQuestionAndBattleStatistics,
  }) {
    const vSpace = SizedBox(height: 16);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        _buildCollectedBadgesContainer(),
        vSpace,
        if (showQuestionAndBattleStatistics) ...[
          Column(
            children: [
              _buildQuestionDetailsContainer(),
              vSpace,
              _buildBattleStatisticsContainer(),
              vSpace,
            ],
          ),
        ] else ...[
          _noStatistics(),
        ],
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _cardBorder),
                boxShadow: _boxShadow,
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: _textBlue,
                size: 18,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          context.tr(statisticsLabelKey)!,
          style: const TextStyle(
            color: _textBlue,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFDFF1FF), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: BlocConsumer<StatisticCubit, StatisticState>(
            listener: (context, state) {
              if (state is StatisticFetchFailure) {
                if (state.errorMessageCode == errorCodeUnauthorizedAccess) {
                  showAlreadyLoggedInDialog(context);
                }
              }
            },
            builder: (_, state) {
              if (state is StatisticInitial ||
                  state is StatisticFetchInProgress) {
                return const Center(child: CircularProgressContainer());
              }

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                    child: _buildHeader(),
                  ),
                  Expanded(
                    child: _buildStatisticsContainer(
                      showQuestionAndBattleStatistics:
                          state is StatisticFetchSuccess,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class StatisticsPieChart extends StatelessWidget {
  const StatisticsPieChart({
    required this.width,
    required this.height,
    required this.values,
    required this.child,
    super.key,
    this.strokeWidth = 8.0,
  });

  final List<({int no, Color arcColor})> values;
  final double width;
  final double height;
  final double strokeWidth;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _StatisticsPieChart(values: values, strokeWidth: strokeWidth),
        child: child,
      ),
    );
  }
}

class _StatisticsPieChart extends CustomPainter {
  _StatisticsPieChart({required this.values, required this.strokeWidth})
    : assert(
        values.isNotEmpty,
        "Values can't be empty. Provide correct values like, for ex. [(no: 10, arcColor: Colors.red)]",
      );

  final List<({int no, Color arcColor})> values;
  final double strokeWidth;

  static const _pi = 3.1415926535897932;

  @override
  void paint(Canvas canvas, Size size) {
    final halfWidth = size.width * .5;
    final center = Offset(size.width * .5, halfWidth);
    final rect = Rect.fromCircle(center: center, radius: halfWidth);

    final total = values.fold(0, (prev, v) => prev += v.no);

    final p = Paint()
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.square
      ..style = PaintingStyle.stroke;

    /// No Data to Display Chart
    if (total == 0) {
      canvas.drawCircle(center, halfWidth, p..color = Colors.grey.shade300);
      return;
    }

    const pi2 = _pi * 2;
    var oldStart = 3 * (_pi * .5); // 0 deg

    for (final val in values) {
      final sweep = (val.no * pi2) / total;

      canvas.drawArc(rect, oldStart, sweep, false, p..color = val.arcColor);

      oldStart += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
