import 'dart:async';
import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/commons/widgets/custom_snackbar.dart';
import 'package:flutterquiz/core/core.dart';
import 'package:flutterquiz/features/ads/blocs/banner_ad_cubit.dart';
import 'package:flutterquiz/features/ads/widgets/banner_ad_container.dart';
import 'package:flutterquiz/features/profile_management/cubits/user_details_cubit.dart';
import 'package:flutterquiz/features/quiz/cubits/quiz_category_cubit.dart';
import 'package:flutterquiz/features/quiz/cubits/subcategory_cubit.dart';
import 'package:flutterquiz/features/quiz/cubits/unlocked_level_cubit.dart';
import 'package:flutterquiz/features/quiz/models/category.dart';
import 'package:flutterquiz/features/quiz/models/quiz_type.dart';
import 'package:flutterquiz/features/quiz/models/subcategory.dart';
import 'package:flutterquiz/features/quiz/quiz_repository.dart';
import 'package:flutterquiz/ui/screens/quiz/multi_match/screens/multi_match_quiz_screen.dart';
import 'package:flutterquiz/ui/screens/quiz/widgets/subcategories_levels_chip.dart';
import 'package:flutterquiz/ui/widgets/already_logged_in_dialog.dart';
import 'package:flutterquiz/ui/widgets/circular_progress_container.dart';
import 'package:flutterquiz/ui/widgets/error_container.dart';
import 'package:flutterquiz/ui/widgets/unlock_premium_category_dialog.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:google_fonts/google_fonts.dart';

final class SubCategoryAndLevelScreenArgs extends RouteArgs {
  const SubCategoryAndLevelScreenArgs({
    required this.quizType,
    required this.category,
    required this.categoryCubit,
  });

  final QuizTypes quizType;
  final Category category;
  final QuizCategoryCubit categoryCubit;
}

class SubCategoryAndLevelScreen extends StatefulWidget {
  const SubCategoryAndLevelScreen({required this.args, super.key});

  final SubCategoryAndLevelScreenArgs args;

  static Route<SubCategoryAndLevelScreen> route(RouteSettings routeSettings) {
    final args = routeSettings.args<SubCategoryAndLevelScreenArgs>();

    return CupertinoPageRoute(
      builder: (_) => SubCategoryAndLevelScreen(args: args),
    );
  }

  @override
  State<SubCategoryAndLevelScreen> createState() =>
      _SubCategoryAndLevelScreen();
}

class _SubCategoryAndLevelScreen extends State<SubCategoryAndLevelScreen> {
  @override
  void initState() {
    fetchSubCategory();
    super.initState();
  }

  void fetchSubCategory() {
    context.read<SubCategoryCubit>().fetchSubCategory(widget.args.category.id!);
  }

  @override
  Widget build(BuildContext context) {
    final bannerAdLoaded =
        context.watch<BannerAdCubit>().bannerAdLoaded &&
        !context.read<UserDetailsCubit>().removeAds();

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: Stack(
        children: [
          // Blue gradient header background
          Container(
            height: 180,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF4A75E8), Color(0xFF60A5FA)],
              ),
            ),
            child: Stack(
              children: [
                // Decorative circle
                Positioned(
                  top: -40,
                  right: -40,
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Content
          SafeArea(
            child: Column(
              children: [
                // Custom Header
                _buildHeader(context),
                const SizedBox(height: 16),
                // Content area with rounded top
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFF0F4FF),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(
                          bottom: bannerAdLoaded ? 60 : 0,
                        ),
                        child: _buildSubcategoryList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Banner Ad
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: BannerAdContainer(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Category info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.args.category.categoryName!,
                  style: GoogleFonts.nunito(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Choose a topic to play',
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          // Category icon
          if (widget.args.category.image != null &&
              widget.args.category.image!.isNotEmpty)
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(8),
              child: CachedNetworkImage(
                imageUrl: widget.args.category.image!,
                color: Colors.white,
                fit: BoxFit.contain,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSubcategoryList() {
    return BlocConsumer<SubCategoryCubit, SubCategoryState>(
      bloc: context.read<SubCategoryCubit>(),
      listener: (context, state) {
        if (state is SubCategoryFetchFailure) {
          if (state.errorMessage == errorCodeUnauthorizedAccess) {
            showAlreadyLoggedInDialog(context);
          }
        }
      },
      builder: (context, state) {
        if (state is SubCategoryFetchInProgress ||
            state is SubCategoryInitial) {
          return const Center(child: CircularProgressContainer());
        }
        if (state is SubCategoryFetchFailure) {
          return ErrorContainer(
            errorMessageColor: Theme.of(context).primaryColor,
            errorMessage: convertErrorCodeToLanguageKey(
              state.errorMessage,
            ),
            showErrorImage: true,
            onTapRetry: fetchSubCategory,
          );
        }

        if (state is SubCategoryFetchSuccess) {
          final subCategoryList = state.subcategoryList;
          final quizRepository = QuizRepository();

          return ListView.separated(
            cacheExtent: context.height,
            separatorBuilder: (_, i) => const SizedBox(height: 12),
            padding: const EdgeInsets.all(16),
            itemCount: subCategoryList.length,
            itemBuilder: (_, i) {
              return BlocProvider<UnlockedLevelCubit>(
                lazy: false,
                create: (_) => UnlockedLevelCubit(quizRepository),
                child: AnimatedSubcategoryContainer(
                  quizType: widget.args.quizType,
                  subcategory: subCategoryList[i],
                  category: widget.args.category,
                  categoryCubit: widget.args.categoryCubit,
                  isPremiumCategory: widget.args.category.isPremium,
                ),
              );
            },
          );
        }

        return const SizedBox();
      },
    );
  }
}

class AnimatedSubcategoryContainer extends StatefulWidget {
  const AnimatedSubcategoryContainer({
    required this.quizType,
    required this.subcategory,
    required this.category,
    required this.isPremiumCategory,
    required this.categoryCubit,
    super.key,
  });

  final QuizTypes quizType;
  final Category category;
  final Subcategory subcategory;
  final bool isPremiumCategory;
  final QuizCategoryCubit categoryCubit;

  @override
  State<AnimatedSubcategoryContainer> createState() =>
      _AnimatedSubcategoryContainerState();
}

class _AnimatedSubcategoryContainerState
    extends State<AnimatedSubcategoryContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController expandController;
  late Animation<double> animation;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _rotationAnimation;

  bool _isExpanded = false;
  late final int maxLevels;
  bool _showAllLevels = false;

  @override
  void initState() {
    scheduleMicrotask(() {
      maxLevels = int.parse(widget.subcategory.maxLevel!);
      _showAllLevels = maxLevels < 6;

      ///fetch unlocked level for current selected subcategory
      fetchUnlockedLevel();
    });

    prepareAnimations();
    setRotation(45);

    super.initState();
  }

  @override
  void dispose() {
    expandController.dispose();
    super.dispose();
  }

  void fetchUnlockedLevel() {
    context.read<UnlockedLevelCubit>().fetchUnlockLevel(
      widget.category.id!,
      widget.subcategory.id!,
      quizType: widget.quizType,
    );
  }

  void prepareAnimations() {
    expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: expandController,
        curve: const Interval(0, 0.4, curve: Curves.easeInOutCubic),
      ),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: expandController,
        curve: const Interval(0.4, 0.7, curve: Curves.easeInOutCubic),
      ),
    );
  }

  void setRotation(int degrees) {
    final angle = degrees * math.pi / 90;
    _rotationAnimation = Tween<double>(begin: 0, end: angle).animate(
      CurvedAnimation(
        parent: expandController,
        curve: const Interval(0, 0.5, curve: Curves.easeInOut),
      ),
    );
  }

  late bool locked = widget.category.isPremium && !widget.category.hasUnlocked;

  Widget _buildLevelSection() {
    return BlocConsumer<UnlockedLevelCubit, UnlockedLevelState>(
      listener: (context, state) {
        if (state is UnlockedLevelFetchFailure) {
          if (state.errorMessage == errorCodeUnauthorizedAccess) {
            showAlreadyLoggedInDialog(context);
          }
        }
      },
      builder: (_, state) {
        if (state is UnlockedLevelFetchInProgress ||
            state is UnlockedLevelInitial) {
          return const SizedBox.shrink();
        }

        if (state is UnlockedLevelFetchFailure) {
          return Center(
            child: ErrorContainer(
              errorMessage: convertErrorCodeToLanguageKey(state.errorMessage),
              topMargin: 0,
              onTapRetry: fetchUnlockedLevel,
              showErrorImage: false,
            ),
          );
        }

        /// No need to show levels when there is no questions or levels.
        if (state is UnlockedLevelFetchSuccess) {
          final unlockedLevel = state.unlockedLevel;
          return SizeTransition(
            axisAlignment: 1,
            sizeFactor: animation,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                paddedDivider(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: List.generate(_showAllLevels ? maxLevels : 6, (
                        i,
                      ) {
                        return GestureDetector(
                          onTap: () {
                            if (locked) {
                              showUnlockPremiumCategoryDialog(
                                context,
                                categoryId: widget.category.id!,
                                categoryName: widget.category.categoryName!,
                                requiredCoins: widget.category.requiredCoins,
                                categoryCubit: widget.categoryCubit,
                              ).then((result) {
                                if (result != null && result) {
                                  setState(() {
                                    locked = false;
                                  });
                                }
                              });
                              return;
                            }

                            if ((i + 1) <= unlockedLevel) {
                              if (widget.quizType == QuizTypes.multiMatch) {
                                context
                                    .pushNamed(
                                      Routes.multiMatchQuiz,
                                      arguments: MultiMatchQuizArgs(
                                        categoryId: widget.category.id!,
                                        subcategoryId: widget.subcategory.id,
                                        level: (i + 1).toString(),
                                        totalLevels: int.parse(
                                          widget.subcategory.maxLevel!,
                                        ),
                                        isPremiumCategory:
                                            widget.isPremiumCategory,
                                        unlockedLevel: state.unlockedLevel,
                                      ),
                                    )
                                    .then((_) => fetchUnlockedLevel());
                              } else {
                                /// Start level
                                Navigator.of(context)
                                    .pushNamed(
                                      Routes.quiz,
                                      arguments: {
                                        'numberOfPlayer': 1,
                                        'quizType': QuizTypes.quizZone,
                                        'categoryId': widget.category.id,
                                        'subcategoryId': widget.subcategory.id,
                                        'level': (i + 1).toString(),
                                        'subcategoryMaxLevel':
                                            widget.subcategory.maxLevel,
                                        'unlockedLevel': state.unlockedLevel,
                                        'contestId': '',
                                        'comprehensionId': '',
                                        'isPremiumCategory':
                                            widget.isPremiumCategory,
                                      },
                                    )
                                    .then((_) => fetchUnlockedLevel());
                              }
                            } else {
                              ScaffoldMessenger.of(context).clearSnackBars();
                              context.showSnack(
                                context.tr(
                                  convertErrorCodeToLanguageKey(
                                    errorCodeLevelLocked,
                                  ),
                                )!,
                              );
                            }
                          },
                          child: SubcategoriesLevelChip(
                            isLevelUnlocked: (i + 1) <= state.unlockedLevel,
                            isLevelPlayed: (i + 2) <= state.unlockedLevel,
                            currIndex: i,
                          ),
                        );
                      }),
                    ),
                  ),
                ),
                paddedDivider(),

                /// View More/Less
                Visibility(
                  visible: maxLevels > 6,
                  child: GestureDetector(
                    onTap: () => setState(() {
                      _showAllLevels = !_showAllLevels;
                    }),
                    child: Container(
                      alignment: Alignment.center,
                      width: double.maxFinite,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        context.tr(!_showAllLevels ? 'viewMore' : 'showLess')!,
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF4A75E8),
                        ),
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: maxLevels > 6,
                  child: const SizedBox(height: 4),
                ),
              ],
            ),
          );
        }

        return Text(context.tr('noLevelsLbl')!);
      },
    );
  }

  Padding paddedDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Divider(
        color: Color(0xFFE2E8F0),
        height: 1,
      ),
    );
  }

  void _onTapSubcategory(Subcategory subcategory) {
    setState(() {
      _isExpanded = !_isExpanded;

      if (_isExpanded) {
        expandController.forward();
      } else {
        expandController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final subcategory = widget.subcategory;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          /// Subcategory header
          GestureDetector(
            onTap: () => _onTapSubcategory(subcategory),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  /// Subcategory Icon with colored background
                  Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F0FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4A75E8),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(6),
                        child: CachedNetworkImage(
                          imageUrl: subcategory.image ?? '',
                          color: Colors.white,
                          fit: BoxFit.contain,
                          errorWidget: (_, s, d) => const Icon(
                            Icons.quiz_outlined,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  /// Subcategory details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Subcategory name
                        Text(
                          subcategory.subcategoryName!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.nunito(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 4),

                        /// Levels and questions
                        Row(
                          children: [
                            Text(
                              "${subcategory.maxLevel} ${context.tr("levels")} • ${subcategory.noOfQue} ${context.tr("questions")}",
                              style: GoogleFonts.nunito(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  /// Expand/Collapse arrow
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A75E8).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: AnimatedBuilder(
                      animation: _rotationAnimation,
                      child: Icon(
                        _isExpanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        size: 20,
                        color: const Color(0xFF4A75E8),
                      ),
                      builder: (_, child) => child!,
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// Subcategory expanded levels
          _buildLevelSection(),
        ],
      ),
    );
  }
}
