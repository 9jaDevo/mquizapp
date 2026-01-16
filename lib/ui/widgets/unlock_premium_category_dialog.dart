import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/commons/commons.dart';
import 'package:flutterquiz/core/core.dart';
import 'package:flutterquiz/features/profile_management/cubits/update_score_and_coins_cubit.dart';
import 'package:flutterquiz/features/profile_management/cubits/user_details_cubit.dart';
import 'package:flutterquiz/features/profile_management/profile_management_repository.dart';
import 'package:flutterquiz/features/quiz/cubits/quiz_category_cubit.dart';
import 'package:flutterquiz/features/quiz/cubits/unlock_premium_category_cubit.dart';
import 'package:flutterquiz/features/wallet/cubit/monetization_cubit.dart';
import 'package:flutterquiz/features/ads/blocs/rewarded_ad_cubit.dart';

/// [_UnlockPremiumAlertDialog] handles showing the unlock confirmation dialog.
///
/// It takes in the category details needed to show the unlock dialog.
///
/// On press unlock:
/// - Calls UnlockPremiumCategoryCubit to unlock the category/subcategory
/// - Updates user coins via UpdateScoreAndCoinsCubit if unlock succeeds
/// - Shows success/error message
/// - Closes dialog on completion
///
/// It disables back button while dialog is open.
///
/// Parameters:
/// - categoryId: id of category/subcategory to unlock
/// - subcategoryId: optional subcategory id
/// - categoryName: name to show in dialog text
/// - requiredCoins: coins needed to unlock
/// - isQuizZone (bool): Whether this is a quizzone category
///
/// State handling:
/// - Shows initial unlock confirmation dialog
/// - Shows circular progress indicator when unlock in progress
/// - Shows success/error message based on unlock result
/// - Closes dialog and resets state when finished
///
Future<bool?> showUnlockPremiumCategoryDialog(
  BuildContext context, {
  required String categoryId,
  required String categoryName,
  required int requiredCoins,
  required QuizCategoryCubit categoryCubit,
}) async {
  return showGeneralDialog<bool?>(
    context: context,
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (dialogCtx, _, _) => _UnlockPremiumAlertDialog(
      categoryId: categoryId,
      categoryName: categoryName,
      requiredCoins: requiredCoins,
      categoryCubit: categoryCubit,
    ),
    transitionBuilder: (_, animation, _, child) {
      final curve = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutBack,
      );

      final slideAnimation = Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(curve);

      final scaleAnimation = Tween<double>(begin: 0.7, end: 1).animate(curve);

      final opacityAnimation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: animation,
          curve: const Interval(0, 0.5, curve: Curves.easeOut),
        ),
      );

      return SlideTransition(
        position: slideAnimation,
        child: ScaleTransition(
          scale: scaleAnimation,
          child: FadeTransition(
            opacity: opacityAnimation,
            child: child,
          ),
        ),
      );
    },
  );
}

class _UnlockPremiumAlertDialog extends StatefulWidget {
  const _UnlockPremiumAlertDialog({
    required this.categoryId,
    required this.categoryName,
    required this.requiredCoins,
    required this.categoryCubit,
  });

  final String categoryId;
  final String categoryName;
  final int requiredCoins;
  final QuizCategoryCubit categoryCubit;

  @override
  State<_UnlockPremiumAlertDialog> createState() => _UnlockPremiumAlertDialogState();
}

class _UnlockPremiumAlertDialogState extends State<_UnlockPremiumAlertDialog> {
  int _adsWatched = 0;

  @override
  void initState() {
    super.initState();
    // Step 9: Get watch unlock config
    Future.delayed(Duration.zero, () {
      if (mounted) {
        context.read<MonetizationCubit>().getWatchUnlockConfig();
      }
    });
  }

  void _onPressedUnlock(BuildContext context) {
    final coins = int.parse(context.read<UserDetailsCubit>().getCoins() ?? '0');
    if (coins >= widget.requiredCoins) {
      context.read<UnlockPremiumCategoryCubit>().unlockPremiumCategory(
        categoryId: widget.categoryId,
      );
    } else {
      context.shouldPop();
      showNotEnoughCoinsDialog(context);
    }
  }

  // Step 9: Watch ad to unlock
  Future<void> _onPressedWatchAd(BuildContext context) async {
    try {
      // Show rewarded ad
      await context.read<RewardedAdCubit>().showAd(
        context: context,
        onAdDismissedCallback: () {
          setState(() {
            _adsWatched++;
          });
        },
      );
    } catch (e) {
      // Handle ad error
    }
  }

  void _closeDialog(BuildContext context) {
    context.shouldPop();
    context.read<UnlockPremiumCategoryCubit>().reset();
  }

  @override
  Widget build(BuildContext context) {
    final useLbl = context.tr('useLbl');
    final coinsLbl = context.tr('coinsLbl');
    final unlockLbl = context.tr('unlockLbl');
    final unlockedLbl = context.tr('unlockedLbl');
    final unlockPremiumDescription = context.tr('unlockPremiumDescription')!;

    return MultiBlocProvider(
      providers: [
        BlocProvider<UpdateCoinsCubit>(
          create: (_) => UpdateCoinsCubit(ProfileManagementRepository()),
        ),
        BlocProvider.value(value: widget.categoryCubit),
      ],
      child: BlocBuilder<MonetizationCubit, MonetizationState>(
        builder: (context, monetizationState) {
          // Step 9: Show watch unlock option if enabled
          final showWatchOption = monetizationState.watchUnlockConfig != null &&
              monetizationState.watchUnlockConfig!.enabled;
          final adsRequired = showWatchOption ? monetizationState.watchUnlockConfig!.adCountRequired : 0;
          final canUnlockByWatching = _adsWatched >= adsRequired && showWatchOption;

          return BlocConsumer<UnlockPremiumCategoryCubit, UnlockPremiumCategoryState>(
            builder: (context, state) {
              return QDialog(
                title: '$unlockLbl ${widget.categoryName}',
                image: Assets.coinsDialogIcon,
                message: state is UnlockPremiumCategoryFailure
                    ? context.tr('defaultErrorMessage')
                    : showWatchOption && !canUnlockByWatching
                        ? 'Watch ${adsRequired - _adsWatched} ads to unlock OR use ${widget.requiredCoins} coins'
                        : unlockPremiumDescription,
                isLoading: state is UnlockPremiumCategoryInProgress,
                cancelButtonText: context.tr('maybeLater'),
                confirmButtonText: state is UnlockPremiumCategoryFailure
                    ? null
                    : canUnlockByWatching
                        ? 'Unlock Now'
                        : showWatchOption && _adsWatched < adsRequired
                            ? 'Watch Ad ($_adsWatched/$adsRequired)'
                            : '$useLbl ${widget.requiredCoins} $coinsLbl',
                onCancel: () => _closeDialog(context),
                onConfirm: state is UnlockPremiumCategoryFailure
                    ? null
                    : () {
                        if (canUnlockByWatching) {
                          _onPressedUnlock(context);
                        } else if (showWatchOption && _adsWatched < adsRequired) {
                          _onPressedWatchAd(context);
                        } else {
                          _onPressedUnlock(context);
                        }
                      },
              );
            },
            listener: (context, state) {
              if (state is UnlockPremiumCategorySuccess) {
                context.read<QuizCategoryCubit>().unlockPremiumCategory(
                  id: widget.categoryId,
                );

                // update user coins to remote DS
                context.read<UpdateCoinsCubit>().updateCoins(
                  coins: widget.requiredCoins,
                  addCoin: false,
                  title: '$unlockedLbl ${widget.categoryName}',
                );
                // update user coins to local DS
                context.read<UserDetailsCubit>().updateCoins(
                  addCoin: false,
                  coins: widget.requiredCoins,
                );

                context
                  ..showSnack('$unlockedLbl ${widget.categoryName}')
                  ..shouldPop(true);
                Future.delayed(
                  const Duration(milliseconds: 20),
                  context.read<UnlockPremiumCategoryCubit>().reset,
                );
              }
            },
          );
        },
      ),
    );
  }
}
