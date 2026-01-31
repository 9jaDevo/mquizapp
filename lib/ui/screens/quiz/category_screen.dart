import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/commons/commons.dart';
import 'package:flutterquiz/core/core.dart';
import 'package:flutterquiz/features/ads/blocs/banner_ad_cubit.dart';
import 'package:flutterquiz/features/ads/blocs/interstitial_ad_cubit.dart';
import 'package:flutterquiz/features/ads/widgets/banner_ad_container.dart';
import 'package:flutterquiz/features/profile_management/cubits/user_details_cubit.dart';
import 'package:flutterquiz/features/quiz/cubits/quiz_category_cubit.dart';
import 'package:flutterquiz/features/quiz/models/category.dart';
import 'package:flutterquiz/features/quiz/models/quiz_type.dart';
import 'package:flutterquiz/ui/screens/quiz/guess_the_word_quiz_screen.dart';
import 'package:flutterquiz/ui/screens/quiz/levels_screen.dart';
import 'package:flutterquiz/ui/screens/quiz/multi_match/screens/multi_match_quiz_screen.dart';
import 'package:flutterquiz/ui/screens/quiz/subcategory_and_level_screen.dart';
import 'package:flutterquiz/ui/screens/quiz/subcategory_screen.dart';
import 'package:flutterquiz/ui/widgets/already_logged_in_dialog.dart';
import 'package:flutterquiz/ui/widgets/circular_progress_container.dart';
import 'package:flutterquiz/ui/widgets/error_container.dart';
import 'package:flutterquiz/ui/widgets/premium_category_access_badge.dart';
import 'package:flutterquiz/ui/widgets/unlock_premium_category_dialog.dart';
import 'package:flutterquiz/utils/ui_utils.dart';
import 'package:google_fonts/google_fonts.dart';

final class CategoryScreenArgs extends RouteArgs {
  const CategoryScreenArgs({required this.quizType});

  final QuizTypes quizType;
}

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({required this.args, super.key});

  final CategoryScreenArgs args;

  @override
  State<CategoryScreen> createState() => _CategoryScreen();

  static Route<dynamic> route(RouteSettings routeSettings) {
    final args = routeSettings.args<CategoryScreenArgs>();

    return CupertinoPageRoute(builder: (_) => CategoryScreen(args: args));
  }
}

class _CategoryScreen extends State<CategoryScreen> {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // preload ads
    Future.delayed(Duration.zero, () {
      context.read<InterstitialAdCubit>().showAd(context);
    });

    context.read<QuizCategoryCubit>().getQuizCategoryWithUserId(
      languageId: UiUtils.getCurrentQuizLanguageId(context),
      type: UiUtils.getCategoryTypeNumberFromQuizType(widget.args.quizType),
    );
  }

  String getCategoryTitle(QuizTypes quizType) => context.tr(switch (quizType) {
    QuizTypes.mathMania => 'mathMania',
    QuizTypes.audioQuestions => 'audioQuestions',
    QuizTypes.guessTheWord => 'guessTheWord',
    QuizTypes.funAndLearn => 'funAndLearn',
    QuizTypes.multiMatch => 'multiMatch',
    _ => 'quizZone',
  })!;

  @override
  Widget build(BuildContext context) {
    final bannerAdLoaded =
        context.watch<BannerAdCubit>().bannerAdLoaded &&
        !context.read<UserDetailsCubit>().removeAds();

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            height: 320,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF4A75E8), Color(0xFF60A5FA)],
              ),
            ),
          ),
          // Decorative circle
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ),
          // Main content
          SafeArea(
            child: Column(
              children: [
                // Custom Header
                _buildHeader(),
                // Category Grid
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F4FF),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(bottom: bannerAdLoaded ? 60 : 0),
                      child: showCategory(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Banner Ad
          const Align(
            alignment: Alignment.bottomCenter,
            child: BannerAdContainer(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Back button and logo row
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              const Spacer(),
              // Logo
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.quiz_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const Spacer(),
              const SizedBox(width: 44), // Balance for back button
            ],
          ),
          const SizedBox(height: 16),
          // Title
          Text(
            getCategoryTitle(widget.args.quizType),
            style: GoogleFonts.nunito(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          // Subtitle
          Text(
            'Explore categories and test your knowledge',
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 20),
          // Stats Row
          BlocBuilder<QuizCategoryCubit, QuizCategoryState>(
            builder: (context, state) {
              int categoryCount = 0;
              int topicsCount = 0;
              int questionsCount = 0;

              if (state is QuizCategorySuccess) {
                categoryCount = state.categories.length;
                for (var cat in state.categories) {
                  topicsCount +=
                      int.tryParse(
                        cat.subcategoriesCount.toString(),
                      ) ??
                      0;
                  questionsCount +=
                      int.tryParse(
                        cat.questionsCount.toString(),
                      ) ??
                      0;
                }
              }

              return Row(
                children: [
                  Expanded(
                    child: _buildStatBadge(
                      categoryCount.toString(),
                      'Categories',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatBadge(
                      '${topicsCount > 60 ? "60+" : topicsCount}',
                      'Topics',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatBadge(
                      '${questionsCount > 1000 ? "${(questionsCount / 1000).toStringAsFixed(0)}K+" : questionsCount}',
                      'Questions',
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatBadge(String value, String label) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            children: [
              Text(
                value,
                style: GoogleFonts.nunito(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleOnTapCategory(BuildContext context, Category category) {
    /// Unlock the Premium Category
    if (category.isPremium &&
        !category.hasUnlocked &&
        !category.hasSubcategories &&
        !category.hasLevels) {
      showUnlockPremiumCategoryDialog(
        context,
        categoryId: category.id!,
        categoryName: category.categoryName!,
        requiredCoins: category.requiredCoins,
        categoryCubit: context.read<QuizCategoryCubit>(),
      );
      return;
    }

    /// noOf is number of subcategories
    if (!category.hasSubcategories) {
      if (widget.args.quizType == QuizTypes.multiMatch) {
        if (category.maxLevel == '0') {
          context.pushNamed(
            Routes.multiMatchQuiz,
            arguments: MultiMatchQuizArgs(
              categoryId: category.id!,
              isPremiumCategory: category.isPremium,
            ),
          );
        } else {
          context.pushNamed(
            Routes.levels,
            arguments: LevelsScreenArgs(
              quizType: QuizTypes.multiMatch,
              category: category,
              categoryCubit: context.read<QuizCategoryCubit>(),
            ),
          );
        }
      } else if (widget.args.quizType == QuizTypes.quizZone) {
        /// if category doesn't have any subCategory, check for levels.
        if (category.maxLevel == '0') {
          //direct move to quiz screen pass level as 0
          Navigator.of(context).pushNamed(
            Routes.quiz,
            arguments: {
              'quizType': QuizTypes.quizZone,
              'categoryId': category.id,
              'subcategoryId': '',
              'level': '0',
              'subcategoryMaxLevel': '0',
              'unlockedLevel': 0,
              'contestId': '',
              'comprehensionId': '',
              'showRetryButton': category.hasQuestions,
              'isPremiumCategory': category.isPremium,
            },
          );
        } else {
          //navigate to level screen
          context.pushNamed(
            Routes.levels,
            arguments: LevelsScreenArgs(
              quizType: QuizTypes.quizZone,
              category: category,
              categoryCubit: context.read<QuizCategoryCubit>(),
            ),
          );
        }
      } else if (widget.args.quizType == QuizTypes.audioQuestions) {
        Navigator.of(context).pushNamed(
          Routes.quiz,
          arguments: {
            'quizType': QuizTypes.audioQuestions,
            'categoryId': category.id,
            'isPlayed': category.isPlayed,
            'isPremiumCategory': category.isPremium,
          },
        );
      } else if (widget.args.quizType == QuizTypes.guessTheWord) {
        context.pushNamed(
          Routes.guessTheWord,
          arguments: GuessTheWordQuizScreenArgs(
            categoryId: category.id!,
            isPlayed: category.isPlayed,
            isPremiumCategory: category.isPremium,
          ),
        );
      } else if (widget.args.quizType == QuizTypes.funAndLearn) {
        Navigator.of(context).pushNamed(
          Routes.funAndLearnTitle,
          arguments: {
            'categoryId': category.id,
            'title': category.categoryName,
            'isPremiumCategory': category.isPremium,
          },
        );
      } else if (widget.args.quizType == QuizTypes.mathMania) {
        Navigator.of(context).pushNamed(
          Routes.quiz,
          arguments: {
            'quizType': QuizTypes.mathMania,
            'categoryId': category.id,
            'isPlayed': category.isPlayed,
            'isPremiumCategory': category.isPremium,
          },
        );
      }
    } else {
      if (widget.args.quizType
          case QuizTypes.multiMatch || QuizTypes.quizZone) {
        context.pushNamed(
          Routes.subcategoryAndLevel,
          arguments: SubCategoryAndLevelScreenArgs(
            quizType: widget.args.quizType,
            category: category,
            categoryCubit: context.read<QuizCategoryCubit>(),
          ),
        );
      } else {
        Navigator.of(context).pushNamed(
          Routes.subCategory,
          arguments: SubCategoryScreenArgs(
            quizType: widget.args.quizType,
            category: category,
            categoryCubit: context.read<QuizCategoryCubit>(),
          ),
        );
      }
    }
  }

  Widget showCategory() {
    return BlocConsumer<QuizCategoryCubit, QuizCategoryState>(
      bloc: context.read<QuizCategoryCubit>(),
      listener: (context, state) {
        if (state is QuizCategoryFailure) {
          if (state.errorMessage == errorCodeUnauthorizedAccess) {
            showAlreadyLoggedInDialog(context);
          }
        }
      },
      builder: (context, state) {
        if (state is QuizCategoryProgress || state is QuizCategoryInitial) {
          return const Center(child: CircularProgressContainer());
        }
        if (state is QuizCategoryFailure) {
          return ErrorContainer(
            showBackButton: false,
            errorMessageColor: Theme.of(context).primaryColor,
            showErrorImage: true,
            errorMessage: convertErrorCodeToLanguageKey(state.errorMessage),
            onTapRetry: () {
              context.read<QuizCategoryCubit>().getQuizCategoryWithUserId(
                languageId: UiUtils.getCurrentQuizLanguageId(context),
                type: UiUtils.getCategoryTypeNumberFromQuizType(
                  widget.args.quizType,
                ),
              );
            },
          );
        }
        final categoryList = (state as QuizCategorySuccess).categories;
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.85,
          ),
          itemCount: categoryList.length,
          itemBuilder: (context, index) {
            final category = categoryList[index];
            final isLeftColumn = index % 2 == 0;

            return GestureDetector(
              onTap: () => _handleOnTapCategory(context, category),
              child: _buildCategoryCard(category, isLeftColumn, index),
            );
          },
        );
      },
    );
  }

  Widget _buildCategoryCard(Category category, bool isBlue, int index) {
    final gradientColors = isBlue
        ? [const Color(0xFFD6E4FF), const Color(0xFFE8F0FF)]
        : [const Color(0xFFFFE4D6), const Color(0xFFFFF0E8)];

    final iconBgColor = isBlue
        ? const Color(0xFF4A75E8)
        : const Color(0xFFE8A04A);

    final imageUrl = category.image!.isEmpty
        ? Assets.placeholder
        : category.image!;

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
          // Icon area with gradient background
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradientColors,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Center(
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: iconBgColor.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: QImage(
                        imageUrl: imageUrl,
                        color: Colors.white,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Text content
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    category.categoryName!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          !category.hasSubcategories
                              ? "${category.questionsCount} ${context.tr('questions')}"
                              : "${category.subcategoriesCount} Topics",
                          style: GoogleFonts.nunito(
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ),
                      if (category.isPremium && !category.hasUnlocked)
                        PremiumCategoryAccessBadge(
                          hasUnlocked: category.hasUnlocked,
                          isPremium: category.isPremium,
                        )
                      else
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 20,
                          color: const Color(0xFF64748B),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
