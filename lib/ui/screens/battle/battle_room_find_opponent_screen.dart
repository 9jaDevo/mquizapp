import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/commons/commons.dart';
import 'package:flutterquiz/core/core.dart';
import 'package:flutterquiz/features/battle_room/cubits/battle_room_cubit.dart';
import 'package:flutterquiz/features/profile_management/cubits/user_details_cubit.dart';
import 'package:flutterquiz/features/quiz/models/quiz_type.dart';
import 'package:flutterquiz/features/system_config/cubits/system_config_cubit.dart';
import 'package:flutterquiz/ui/screens/battle/widgets/user_found_map_container.dart';
import 'package:flutterquiz/ui/widgets/already_logged_in_dialog.dart';
import 'package:flutterquiz/ui/widgets/error_container.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class BattleRoomFindOpponentScreen extends StatefulWidget {
  const BattleRoomFindOpponentScreen({required this.categoryId, super.key});

  final String categoryId;

  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
      builder: (_) => BattleRoomFindOpponentScreen(
        categoryId: routeSettings.arguments! as String,
      ),
    );
  }

  @override
  State<BattleRoomFindOpponentScreen> createState() =>
      _BattleRoomFindOpponentScreenState();
}

class _BattleRoomFindOpponentScreenState
    extends State<BattleRoomFindOpponentScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late ScrollController scrollController = ScrollController();
  late AnimationController letterAnimationController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  );
  late AnimationController quizCountDownAnimationController =
      AnimationController(vsync: this, duration: const Duration(seconds: 4));
  late Animation<int> quizCountDownAnimation = IntTween(
    begin: 3,
    end: 0,
  ).animate(quizCountDownAnimationController);
  late AnimationController animationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 950),
  )..forward();
  late Animation<double> mapAnimation = Tween<double>(begin: 0, end: 1).animate(
    CurvedAnimation(
      parent: animationController,
      curve: const Interval(0, 0.4, curve: Curves.easeInOut),
    ),
  );
  late Animation<double> playerDetailsAnimation =
      Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: animationController,
          curve: const Interval(0.4, 0.7, curve: Curves.easeInOut),
        ),
      );
  late Animation<double> findingOpponentStatusAnimation =
      Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: animationController,
          curve: const Interval(0.7, 1, curve: Curves.easeInOut),
        ),
      );

  //to store images of map so we can simulate the mapSlideAnimation
  late List<String> images = [];

  //
  late bool waitForOpponent = true;

  //waiting time to find opponent to join
  late int waitingTime = context
      .read<SystemConfigCubit>()
      .randomBattleOpponentSearchDuration;
  Timer? waitForOpponentTimer;

  bool playWithBot = false;

  @override
  void initState() {
    super.initState();
    addImages();
    WakelockPlus.enable();
    Future.delayed(const Duration(milliseconds: 1000), () {
      //search for battle room after initial animation completed
      searchBattleRoom();
      startScrollImageAnimation();
      letterAnimationController.repeat();
    });
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    //delete battle room if user press home button or move from battleOpponentFind screen
    if (state == AppLifecycleState.paused) {
      context.read<BattleRoomCubit>().deleteBattleRoom();
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    letterAnimationController.dispose();
    quizCountDownAnimationController.dispose();
    animationController.dispose();
    waitForOpponentTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);

    //we need to set the current route to home.
    //so room will be delete only if user has left this screen and
    //room created afterwards
    if (Routes.currentRoute == Routes.battleRoomFindOpponent) {
      Routes.currentRoute = Routes.home;
      WakelockPlus.disable();
    }
    super.dispose();
  }

  void searchBattleRoom() {
    final userProfile = context.read<UserDetailsCubit>().getUserProfile();
    context.read<BattleRoomCubit>().searchRoom(
      categoryId: widget.categoryId,
      name: userProfile.name!,
      profileUrl: userProfile.profileUrl!,
      uid: userProfile.userId!,
      questionLanguageId: UiUtils.getCurrentQuizLanguageId(context),
      entryFee: context.read<SystemConfigCubit>().randomBattleEntryCoins,
    );
  }

  void addImages() {
    for (var i = 0; i < 20; i++) {
      images.add(Assets.mapFinding);
    }
  }

  //this will be call only when user has created room successfully
  void setWaitForOpponentTimer() {
    waitForOpponentTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (waitingTime == 0) {
        //delete room so other user can not join
        context.read<BattleRoomCubit>().deleteBattleRoom();
        //stop other activities
        letterAnimationController.stop();
        if (scrollController.hasClients) {
          scrollController.jumpTo(scrollController.position.maxScrollExtent);
        }
        setState(() {
          waitForOpponent = false;
        });

        timer.cancel();
      } else {
        waitingTime--;
      }
    });
  }

  Future<void> startScrollImageAnimation() async {
    //if scroll controller is attached to any scrollable widgets
    if (scrollController.hasClients) {
      final maxScroll = scrollController.position.maxScrollExtent;

      if (maxScroll == 0) {
        await startScrollImageAnimation();
      }

      await scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(seconds: 32),
        curve: Curves.linear,
      );
    }
  }

  void retryToSearchBattleRoom() {
    scrollController.dispose();
    setState(() {
      scrollController = ScrollController();
      waitingTime = context
          .read<SystemConfigCubit>()
          .randomBattleOpponentSearchDuration;
      waitForOpponent = true;
    });
    letterAnimationController.repeat();
    Future.delayed(
      const Duration(milliseconds: 100),
      startScrollImageAnimation,
    );
    setWaitForOpponentTimer();
    searchBattleRoom();
  }

  // --- Redesigned avatar card: blue ring + avatar + name + online dot ---
  Widget _buildUserDetails(String name, String profileUrl) {
    final avatarSize = context.height * 0.11;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            // Blue glowing ring
            Container(
              width: avatarSize + 8,
              height: avatarSize + 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.45),
                    blurRadius: 14,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
            // Avatar
            Positioned(
              left: 4,
              top: 4,
              child: ClipOval(
                child: QImage.circular(
                  imageUrl: profileUrl,
                  width: avatarSize,
                  height: avatarSize,
                ),
              ),
            ),
            // Green online dot
            Positioned(
              right: 2,
              bottom: 2,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: context.width * 0.28,
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentUserDetails() {
    final user = context.read<UserDetailsCubit>().getUserProfile();
    return _buildUserDetails(user.name!, user.profileUrl!);
  }

  // --- Opponent side: avatar when found, animated placeholder while searching ---
  Widget _buildOpponentUserDetails() {
    final avatarSize = context.height * 0.11;
    return BlocBuilder<BattleRoomCubit, BattleRoomState>(
      bloc: context.read<BattleRoomCubit>(),
      builder: (context, state) {
        if (state is BattleRoomUserFound) {
          final opponent = context
              .read<BattleRoomCubit>()
              .getOpponentUserDetails(
                context.read<UserDetailsCubit>().userId(),
              );
          return _buildUserDetails(opponent.name, opponent.profileUrl);
        }

        // Placeholder: grey pulsing circle with animated dots below
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: letterAnimationController,
              builder: (context, child) {
                final pulse =
                    (math.sin(
                          letterAnimationController.value * math.pi * 2,
                        ) *
                        0.08) +
                    0.92;
                return Transform.scale(
                  scale: pulse,
                  child: Container(
                    width: avatarSize + 8,
                    height: avatarSize + 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.15),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.35),
                        width: 2.5,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.person_outline_rounded,
                        color: Colors.white.withValues(alpha: 0.6),
                        size: avatarSize * 0.5,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            // Animated three dots
            AnimatedBuilder(
              animation: letterAnimationController,
              builder: (context, _) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (i) {
                    final t = ((letterAnimationController.value * 3) - i).clamp(
                      0.0,
                      1.0,
                    );
                    final opacity = (math.sin(t * math.pi)).clamp(0.3, 1.0);
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Opacity(
                        opacity: opacity,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ],
        );
      },
    );
  }

  // --- World-map dot background ---
  Widget _buildFindingMap() {
    return Positioned.fill(
      child: CustomPaint(
        painter: _WorldMapDotsPainter(),
      ),
    );
  }

  //build details when opponent found
  Widget _buildUserFoundDetails() {
    return Align(
      key: const Key('userFound'),
      alignment: Alignment.topCenter,
      child: SizedBox(
        height: context.height * 0.6,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: context.height * 0.05),
            Text(
              context.tr('getReadyLbl')!,
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 25,
              ),
            ),
            SizedBox(height: context.height * 0.025),
            AnimatedBuilder(
              animation: quizCountDownAnimationController,
              builder: (context, child) {
                return Text(
                  quizCountDownAnimation.value == 0
                      ? context.tr('bestOfLuckLbl')!
                      : '${quizCountDownAnimation.value}',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
            SizedBox(height: context.height * 0.0275),
            const UserFoundMapContainer(),
          ],
        ),
      ),
    );
  }

  // --- "No Opponent Detected" redesigned alert card ---
  Widget _buildOpponentNotFoundDetails() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Alert card
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.search_off_rounded,
                      color: Color(0xFFF59E0B),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr('opponentNotFoundLbl') ??
                              'No Opponent Detected',
                          style: GoogleFonts.nunito(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          context.tr('noOpponentSubtitleLbl') ??
                              'No one is available right now.',
                          style: GoogleFonts.nunito(
                            fontSize: 12,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (!playWithBot) ...[
                const SizedBox(height: 18),
                Row(
                  children: [
                    // Play with Bot
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (playWithBot) return;
                          setState(() => playWithBot = true);
                          final userProfile = context
                              .read<UserDetailsCubit>()
                              .getUserProfile();
                          context.read<BattleRoomCubit>().createRoomWithBot(
                            categoryId: widget.categoryId,
                            charType: context
                                .read<SystemConfigCubit>()
                                .oneVsOneBattleRoomCodeCharType,
                            name: userProfile.name,
                            uid: userProfile.userId,
                            profileUrl: userProfile.profileUrl,
                            botName: context.tr('botNameLbl'),
                            questionLanguageId:
                                UiUtils.getCurrentQuizLanguageId(context),
                            context: context,
                          );
                        },
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            context.tr('playWithBotLbl') ?? 'Play with Bot',
                            style: GoogleFonts.nunito(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Try Again
                    Expanded(
                      child: GestureDetector(
                        onTap: retryToSearchBattleRoom,
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF3B82F6),
                              width: 1.5,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            context.tr('retryLbl') ?? 'Try Again',
                            style: GoogleFonts.nunito(
                              color: const Color(0xFF3B82F6),
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                const SizedBox(height: 14),
                Text(
                  context.tr('battlePreparingLbl') ?? 'Preparing battle…',
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // --- Redesigned VS badge ---
  Widget _buildVsImageContainer() {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFEF4444), width: 2.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEF4444).withValues(alpha: 0.45),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Text(
          'VS',
          style: GoogleFonts.nunito(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  // --- VS Row with both players ---
  Widget _buildPlayersDetails() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildCurrentUserDetails(),
        _buildVsImageContainer(),
        _buildOpponentUserDetails(),
      ],
    );
  }

  // --- Redesigned back button (rounded square white) ---
  Widget _buildBackButton() {
    return GestureDetector(
      onTap: () {
        final battleRoomCubit = context.read<BattleRoomCubit>();
        if (battleRoomCubit.state is BattleRoomUserFound) return;
        context.showDialog<void>(
          title: context.tr('quizExitTitle'),
          message: context.tr('quizExitLbl'),
          cancelButtonText: context.tr('leaveAnyways'),
          confirmButtonText: context.tr('keepPlaying'),
          onCancel: () {
            battleRoomCubit.deleteBattleRoom();
            context
              ..shouldPop()
              ..shouldPop();
          },
        );
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 8,
            ),
          ],
        ),
        child: const Icon(
          Icons.arrow_back_rounded,
          color: Color(0xFF1E293B),
          size: 22,
        ),
      ),
    );
  }

  // --- "Looking for Opponent" full body ---
  Widget _buildMatchmakingBody() {
    return SafeArea(
      child: Column(
        children: [
          // Top bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              children: [
                _buildBackButton(),
                const Spacer(),
                Column(
                  children: [
                    Text(
                      'Matchmaking',
                      style: GoogleFonts.nunito(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      context.tr('findingOpponentLbl') ?? 'Finding opponent',
                      style: GoogleFonts.nunito(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // Countdown ring
                AnimatedBuilder(
                  animation: waitForOpponentTimer != null
                      ? const AlwaysStoppedAnimation(0)
                      : animationController,
                  builder: (_, __) {
                    final total = context
                        .read<SystemConfigCubit>()
                        .randomBattleOpponentSearchDuration;
                    final remaining = waitingTime;
                    return SizedBox(
                      width: 44,
                      height: 44,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CustomPaint(
                            size: const Size(44, 44),
                            painter: _CountdownRingPainter(
                              remaining: remaining.toDouble(),
                              total: total.toDouble(),
                            ),
                          ),
                          Text(
                            '$remaining',
                            style: GoogleFonts.nunito(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // "Scanning globally" pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: letterAnimationController,
                  builder: (_, __) {
                    final v =
                        (math.sin(
                              letterAnimationController.value * math.pi * 2,
                            ) *
                            0.5) +
                        0.5;
                    return Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Color.lerp(
                          const Color(0xFF60A5FA),
                          const Color(0xFF3B82F6),
                          v,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF3B82F6,
                            ).withValues(alpha: 0.6 * v),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),
                Text(
                  'Scanning globally…',
                  style: GoogleFonts.nunito(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          // Players VS row
          _buildPlayersDetails(),
          const Spacer(),
          // Bottom white card with animated indicator
          Container(
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 28),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.10),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Three animated dots
                AnimatedBuilder(
                  animation: letterAnimationController,
                  builder: (_, __) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(3, (i) {
                        final t = ((letterAnimationController.value * 3) - i)
                            .clamp(0.0, 1.0);
                        final dy =
                            -6.0 * (math.sin(t * math.pi)).clamp(0.0, 1.0);
                        return Transform.translate(
                          offset: Offset(0, dy),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF3B82F6),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        );
                      }),
                    );
                  },
                ),
                const SizedBox(width: 14),
                Text(
                  context.tr('findingOpponentLbl') ?? 'Finding opponent…',
                  style: GoogleFonts.nunito(
                    color: const Color(0xFF1E293B),
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- "No Opponent Detected" full body ---
  Widget _buildNoOpponentBody() {
    return SafeArea(
      child: Column(
        children: [
          // Top bar (same as matchmaking but no timer)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              children: [
                _buildBackButton(),
                const Spacer(),
                Text(
                  'Matchmaking',
                  style: GoogleFonts.nunito(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                const SizedBox(width: 44),
              ],
            ),
          ),
          const SizedBox(height: 28),
          _buildOpponentNotFoundDetails(),
          const SizedBox(height: 28),
          _buildPlayersDetails(),
          const Spacer(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final battleRoomCubit = context.read<BattleRoomCubit>();

    return PopScope(
      canPop: battleRoomCubit.state is! BattleRoomUserFound,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;

        context.showDialog<void>(
          title: context.tr('quizExitTitle'),
          message: context.tr('quizExitLbl'),
          cancelButtonText: context.tr('leaveAnyways'),
          confirmButtonText: context.tr('keepPlaying'),
          onCancel: () {
            battleRoomCubit.deleteBattleRoom();
            context
              ..shouldPop()
              ..shouldPop();
          },
        );
      },
      child: Scaffold(
        // Deep navy → blue gradient background
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0F172A),
                Color(0xFF1E3A5F),
                Color(0xFF1D4ED8),
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
          child: BlocListener<BattleRoomCubit, BattleRoomState>(
            bloc: battleRoomCubit,
            listener: (context, state) async {
              // Start timer for waiting user only when room created successfully
              if (state is BattleRoomCreated) {
                if (waitForOpponentTimer == null) {
                  setWaitForOpponentTimer();
                }
              } else if (state is BattleRoomUserFound) {
                // Opponent found
                waitForOpponentTimer?.cancel();
                await Future<void>.delayed(const Duration(milliseconds: 500));
                await quizCountDownAnimationController.forward();

                await WakelockPlus.disable();
                await Navigator.of(context).pushReplacementNamed(
                  Routes.battleRoomQuiz,
                  arguments: {
                    'quiz_type': QuizTypes.randomBattle,
                    'play_with_bot': playWithBot,
                  },
                );
              } else if (state is BattleRoomFailure) {
                if (state.errorMessageCode == errorCodeUnauthorizedAccess) {
                  await showAlreadyLoggedInDialog(context);
                }
              }
            },
            child: BlocBuilder<BattleRoomCubit, BattleRoomState>(
              bloc: battleRoomCubit,
              builder: (context, state) {
                // Opponent found → existing get-ready countdown (unchanged)
                if (state is BattleRoomUserFound) {
                  return _buildUserFoundDetails();
                }

                // Failure
                if (state is BattleRoomFailure) {
                  return SafeArea(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: _buildBackButton(),
                          ),
                        ),
                        Expanded(
                          child: ErrorContainer(
                            showBackButton: false,
                            errorMessage: convertErrorCodeToLanguageKey(
                              state.errorMessageCode,
                            ),
                            errorMessageColor: Colors.white,
                            onTapRetry: retryToSearchBattleRoom,
                            showErrorImage: true,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Main states: searching or timed out
                return Stack(
                  children: [
                    // World-map dot layer
                    _buildFindingMap(),
                    // Body
                    if (waitForOpponent)
                      _buildMatchmakingBody()
                    else
                      _buildNoOpponentBody(),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// World-map silhouette dot painter (~100 dots mapping continental outlines)
// ---------------------------------------------------------------------------
class _WorldMapDotsPainter extends CustomPainter {
  // Each entry is (xFraction, yFraction) across [0,1].
  // Manually mapped lat/lon → normalised coordinates (Mercator-like).
  static const List<List<double>> _dots = [
    // North America
    [0.07, 0.22], [0.09, 0.26], [0.11, 0.24], [0.13, 0.28],
    [0.10, 0.32], [0.12, 0.35], [0.15, 0.30], [0.17, 0.33],
    [0.14, 0.38], [0.16, 0.41], [0.19, 0.36], [0.21, 0.39],
    [0.18, 0.44], [0.20, 0.28], [0.22, 0.31], [0.08, 0.19],
    [0.06, 0.28], [0.12, 0.20], [0.24, 0.34], [0.23, 0.42],
    // Central America & Caribbean
    [0.22, 0.46], [0.24, 0.48], [0.26, 0.47],
    // South America
    [0.25, 0.52], [0.27, 0.55], [0.29, 0.57], [0.26, 0.60],
    [0.28, 0.63], [0.30, 0.66], [0.27, 0.68], [0.25, 0.65],
    [0.31, 0.62], [0.33, 0.59], [0.30, 0.53], [0.28, 0.70],
    [0.26, 0.73], [0.29, 0.75],
    // Western Europe
    [0.43, 0.20], [0.44, 0.23], [0.45, 0.21], [0.46, 0.24],
    [0.47, 0.22], [0.48, 0.26], [0.44, 0.27], [0.46, 0.28],
    [0.43, 0.30], [0.48, 0.30], [0.50, 0.24],
    // Eastern Europe & Russia
    [0.52, 0.19], [0.54, 0.17], [0.56, 0.19], [0.58, 0.16],
    [0.60, 0.18], [0.62, 0.20], [0.64, 0.17], [0.66, 0.19],
    [0.68, 0.21], [0.70, 0.19], [0.72, 0.16], [0.74, 0.18],
    [0.76, 0.20], [0.55, 0.22], [0.57, 0.24], [0.53, 0.26],
    // Africa
    [0.46, 0.37], [0.48, 0.40], [0.50, 0.38], [0.47, 0.43],
    [0.49, 0.46], [0.51, 0.43], [0.48, 0.49], [0.50, 0.53],
    [0.52, 0.50], [0.49, 0.56], [0.51, 0.59], [0.54, 0.54],
    [0.46, 0.34], [0.53, 0.35], [0.55, 0.38],
    // Middle East
    [0.57, 0.30], [0.59, 0.32], [0.61, 0.30], [0.58, 0.34],
    // Central & South Asia
    [0.63, 0.27], [0.65, 0.30], [0.67, 0.28], [0.69, 0.31],
    [0.66, 0.33], [0.68, 0.36], [0.70, 0.33], [0.72, 0.38],
    // East Asia
    [0.74, 0.25], [0.76, 0.27], [0.78, 0.25], [0.80, 0.28],
    [0.75, 0.30], [0.77, 0.33], [0.79, 0.31], [0.81, 0.26],
    [0.83, 0.23], [0.82, 0.30],
    // South-East Asia
    [0.76, 0.40], [0.78, 0.43], [0.80, 0.41], [0.82, 0.44],
    [0.79, 0.46], [0.81, 0.48],
    // Australia
    [0.80, 0.60], [0.82, 0.58], [0.84, 0.61], [0.83, 0.64],
    [0.81, 0.63], [0.85, 0.59], [0.80, 0.66],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE57373).withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;

    for (final d in _dots) {
      canvas.drawCircle(
        Offset(d[0] * size.width, d[1] * size.height),
        2.0,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ---------------------------------------------------------------------------
// Countdown ring painter (grey track + blue arc)
// ---------------------------------------------------------------------------
class _CountdownRingPainter extends CustomPainter {
  const _CountdownRingPainter({required this.remaining, required this.total});

  final double remaining;
  final double total;

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 3.5;
    final rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: (size.width - strokeWidth) / 2,
    );

    // Background track
    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi,
      false,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );

    // Foreground arc
    final fraction = total > 0 ? remaining / total : 0.0;
    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * fraction,
      false,
      Paint()
        ..color = const Color(0xFF60A5FA)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _CountdownRingPainter old) =>
      old.remaining != remaining;
}
