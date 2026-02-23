import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/commons/widgets/custom_alert_dialog.dart';
import 'package:flutterquiz/core/core.dart';
import 'package:flutterquiz/features/ads/blocs/rewarded_ad_cubit.dart';
import 'package:flutterquiz/features/battle_room/battle_room_repository.dart';
import 'package:flutterquiz/features/battle_room/cubits/battle_room_cubit.dart';
import 'package:flutterquiz/features/battle_room/cubits/battle_stats_cubit.dart';
import 'package:flutterquiz/features/profile_management/cubits/update_score_and_coins_cubit.dart';
import 'package:flutterquiz/features/profile_management/cubits/user_details_cubit.dart';
import 'package:flutterquiz/features/profile_management/profile_management_repository.dart';
import 'package:flutterquiz/features/quiz/cubits/quiz_category_cubit.dart';
import 'package:flutterquiz/features/quiz/models/quiz_type.dart';
import 'package:flutterquiz/features/system_config/cubits/system_config_cubit.dart';
import 'package:flutterquiz/ui/screens/battle/create_or_join_screen.dart';
import 'package:flutterquiz/ui/widgets/already_logged_in_dialog.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';
import 'package:google_fonts/google_fonts.dart';

class RandomBattleScreen extends StatefulWidget {
  const RandomBattleScreen({super.key});

  static Route<RandomBattleScreen> route(RouteSettings settings) {
    return CupertinoPageRoute(
      builder: (_) => BlocProvider(
        create: (_) => UpdateCoinsCubit(ProfileManagementRepository()),
        child: const RandomBattleScreen(),
      ),
    );
  }

  @override
  State<RandomBattleScreen> createState() => _RandomBattleScreenState();
}

class _RandomBattleScreenState extends State<RandomBattleScreen> {
  // ── Unchanged business-logic state ────────────────────────────────────────
  String selectedCategory = selectCategoryKey;
  String selectedCategoryId = '0';

  // ── Colours ────────────────────────────────────────────────────────────────
  static const _bg1 = Color(0xFF0F172A);
  static const _bg2 = Color(0xFF1E3A5F);
  static const _bg3 = Color(0xFF1D4ED8);
  static const _accent = Color(0xFF3B82F6);

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      context.read<RewardedAdCubit>().createRewardedAd(context);
      if (context.read<SystemConfigCubit>().isCategoryEnabledForRandomBattle) {
        _getCategories();
      }
    });
  }

  // ── Business logic (unchanged) ─────────────────────────────────────────────

  void _getCategories() {
    context.read<QuizCategoryCubit>().getQuizCategoryWithUserId(
      languageId: UiUtils.getCurrentQuizLanguageId(context),
      type: UiUtils.getCategoryTypeNumberFromQuizType(QuizTypes.oneVsOneBattle),
      subType: UiUtils.subTypeFromQuizType(QuizTypes.oneVsOneBattle),
    );
  }

  void _addCoinsAfterRewardAd() {
    final rewardAdsCoins = context.read<SystemConfigCubit>().rewardAdsCoins;
    context.read<UserDetailsCubit>().updateCoins(
      addCoin: true,
      coins: rewardAdsCoins,
    );
    context.read<UpdateCoinsCubit>().updateCoins(
      coins: rewardAdsCoins,
      addCoin: true,
      type: watchedRewardAdKey,
      title: watchedRewardAdKey,
    );
  }

  void _onLetsPlayTap() {
    final userProfile = context.read<UserDetailsCubit>().getUserProfile();

    if (int.parse(userProfile.coins!) <
        context.read<SystemConfigCubit>().randomBattleEntryCoins) {
      if (context.read<RewardedAdCubit>().state is! RewardedAdLoaded) {
        context.showErrorDialog(
          context.tr(convertErrorCodeToLanguageKey(errorCodeNotEnoughCoins))!,
        );
        return;
      }
      context.read<RewardedAdCubit>().showAd(
        context: context,
        rewardAmount: context.read<SystemConfigCubit>().rewardAdsCoins,
        rewardCurrencyLabel: 'coins',
        onAdDismissedCallback: _addCoinsAfterRewardAd,
      );
      return;
    }
    if (selectedCategory == selectCategoryKey &&
        context.read<SystemConfigCubit>().isCategoryEnabledForRandomBattle) {
      context.showErrorDialog(context.tr(pleaseSelectCategoryKey)!);
      return;
    }

    context.read<BattleRoomCubit>().updateState(const BattleRoomInitial());
    Navigator.of(context).pushReplacementNamed(
      Routes.battleRoomFindOpponent,
      arguments: selectedCategoryId,
    );
  }

  void _onPlayWithFriendsTap() {
    Navigator.of(context).push(
      CupertinoPageRoute<CreateOrJoinRoomScreen>(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider<UpdateCoinsCubit>(
              create: (_) => UpdateCoinsCubit(ProfileManagementRepository()),
            ),
            BlocProvider<BattleStatsCubit>(
              create: (_) => BattleStatsCubit(BattleRoomRepository()),
            ),
          ],
          child: CreateOrJoinRoomScreen(
            quizType: QuizTypes.oneVsOneBattle,
            title: context.tr('playWithFrdLbl')!,
          ),
        ),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Widget _glass({
    required Widget child,
    double radius = 16,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
    Color fill = const Color(0x18FFFFFF),
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.20),
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  // ── Category dropdown ──────────────────────────────────────────────────────

  Widget _buildDropDown({
    required List<Map<String, String?>> values,
    required String keyValue,
  }) {
    final ids = values.map((e) => e['id']).toList();
    if (!ids.contains(selectedCategoryId)) {
      selectedCategoryId = ids.first!;
      selectedCategory = values.first['name'] ?? '';
    }

    return StatefulBuilder(
      builder: (context, setLocal) {
        return DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            key: Key(keyValue),
            isExpanded: true,
            dropdownColor: const Color(0xFF1E3A5F),
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.white70,
            ),
            style: GoogleFonts.nunito(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            value: selectedCategoryId,
            hint: Text(
              context.tr(selectCategoryKey)!,
              style: GoogleFonts.nunito(
                color: Colors.white54,
                fontSize: 15,
              ),
            ),
            onChanged: (value) {
              setLocal(() {
                setState(() {
                  selectedCategoryId = value!;
                  final index = values.indexWhere((v) => v['id'] == value);
                  if (index != -1) selectedCategory = values[index]['name']!;
                });
              });
            },
            items: values.map((e) {
              final name = e['name'];
              final id = e['id'];
              return DropdownMenuItem<String>(
                value: id,
                child: name == selectCategoryKey
                    ? Text(context.tr(selectCategoryKey)!)
                    : Text(name!),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildCategorySection() {
    if (!context.read<SystemConfigCubit>().isCategoryEnabledForRandomBattle) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.category_rounded, color: Colors.white70, size: 16),
            const SizedBox(width: 6),
            Text(
              context.tr(selectCategoryKey)!,
              style: GoogleFonts.nunito(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _glass(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: BlocConsumer<QuizCategoryCubit, QuizCategoryState>(
            listener: (context, state) {
              if (state is QuizCategorySuccess) {
                setState(() {
                  selectedCategoryId = state.categories.first.id!;
                  selectedCategory = state.categories.first.categoryName!;
                });
              }
              if (state is QuizCategoryFailure) {
                if (state.errorMessage == errorCodeUnauthorizedAccess) {
                  showAlreadyLoggedInDialog(context);
                  return;
                }
                showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    actions: [
                      TextButton(
                        onPressed: () => ctx.pop(true),
                        child: Text(
                          context.tr(retryLbl)!,
                          style: TextStyle(color: context.primaryColor),
                        ),
                      ),
                    ],
                    content: Text(
                      context.tr(
                        convertErrorCodeToLanguageKey(state.errorMessage),
                      )!,
                    ),
                  ),
                ).then((v) {
                  if (v == true) _getCategories();
                });
              }
            },
            builder: (context, state) {
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: state is QuizCategorySuccess
                    ? _buildDropDown(
                        values: state.categories
                            .where((c) => !c.isPremium)
                            .map((e) => {'name': e.categoryName, 'id': e.id})
                            .toList(),
                        keyValue: 'categorySuccess',
                      )
                    : Opacity(
                        opacity: 0.5,
                        child: _buildDropDown(
                          values: [
                            {'name': selectCategoryKey, 'id': '0'},
                          ],
                          keyValue: 'categoryPlaceholder',
                        ),
                      ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // ── Entry-fee + coins card ─────────────────────────────────────────────────

  Widget _buildStatsCard() {
    final entryFee = context.read<SystemConfigCubit>().randomBattleEntryCoins;
    return _glass(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('\u{1F3DF}', style: TextStyle(fontSize: 26)),
              const SizedBox(height: 6),
              Text(
                context.tr('entryFeesLbl')!,
                style: GoogleFonts.nunito(
                  color: Colors.white60,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$entryFee coins',
                style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          Container(
            width: 1,
            height: 52,
            color: Colors.white.withValues(alpha: 0.2),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('\u{1F4B0}', style: TextStyle(fontSize: 26)),
              const SizedBox(height: 6),
              Text(
                context.tr(currentCoinsKey)!,
                style: GoogleFonts.nunito(
                  color: Colors.white60,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              BlocBuilder<UserDetailsCubit, UserDetailsState>(
                builder: (context, state) {
                  final coins = state is UserDetailsFetchSuccess
                      ? context.read<UserDetailsCubit>().getCoins() ?? '0'
                      : '--';
                  return Text(
                    '$coins coins',
                    style: GoogleFonts.nunito(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Buttons ────────────────────────────────────────────────────────────────

  Widget _buildLetsPlayButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: _onLetsPlayTap,
        icon: const Icon(Icons.flash_on_rounded, size: 20),
        label: Text(
          context.tr('letsPlay') ?? "Let's Play",
          style: GoogleFonts.nunito(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.3,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _accent,
          foregroundColor: Colors.white,
          elevation: 6,
          shadowColor: _accent.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildPlayWithFriendsButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        onPressed: _onPlayWithFriendsTap,
        icon: const Icon(Icons.people_alt_rounded, size: 20),
        label: Text(
          context.tr('playWithFrdLbl') ?? 'Play with Friends',
          style: GoogleFonts.nunito(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.3,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.55),
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildOrDivider() {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: Colors.white.withValues(alpha: 0.25),
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            context.tr(orLbl)!,
            style: GoogleFonts.nunito(
              color: Colors.white54,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: Colors.white.withValues(alpha: 0.25),
            thickness: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildHeroSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
            ),
            boxShadow: [
              BoxShadow(
                color: _accent.withValues(alpha: 0.45),
                blurRadius: 16,
                spreadRadius: 2,
              ),
            ],
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              'VS',
              style: GoogleFonts.nunito(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.tr('randomLbl') ?? 'Random Battle',
              style: GoogleFonts.nunito(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              context.tr('desBattleQuiz') ?? 'Challenge a random opponent',
              style: GoogleFonts.nunito(
                color: Colors.white.withValues(alpha: 0.65),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final showFriendsButton = context
        .read<SystemConfigCubit>()
        .isOneVsOneBattleEnabled;

    return BlocListener<UpdateCoinsCubit, UpdateCoinsState>(
      listener: (context, state) {
        if (state is UpdateCoinsFailure &&
            state.errorMessage == errorCodeUnauthorizedAccess) {
          showAlreadyLoggedInDialog(context);
        }
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_bg1, _bg2, _bg3],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // ── Back button ──────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: Navigator.of(context).pop,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                          ),
                          child: const Icon(
                            Icons.arrow_back_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),
                _buildHeroSection(),
                const SizedBox(height: 14),

                // ── Bottom glass panel ────────────────────────────────────────
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.55),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(32),
                      ),
                      border: Border(
                        top: BorderSide(
                          color: Colors.white.withValues(alpha: 0.12),
                        ),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(32),
                      ),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                        child: SingleChildScrollView(
                          padding: EdgeInsets.fromLTRB(
                            context.width * UiUtils.hzMarginPct,
                            28,
                            context.width * UiUtils.hzMarginPct,
                            MediaQuery.of(context).padding.bottom + 24,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildCategorySection(),
                              _buildStatsCard(),
                              const SizedBox(height: 24),
                              _buildLetsPlayButton(),
                              if (showFriendsButton) ...[
                                const SizedBox(height: 16),
                                _buildOrDivider(),
                                const SizedBox(height: 16),
                                _buildPlayWithFriendsButton(),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
