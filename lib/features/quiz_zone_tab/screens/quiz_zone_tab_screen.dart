import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/commons/commons.dart';
import 'package:flutterquiz/core/core.dart';
import 'package:flutterquiz/features/auth/cubits/auth_cubit.dart';
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

final class QuizZoneTabScreenArgs extends RouteArgs {
  const QuizZoneTabScreenArgs({required this.quizType});

  final QuizTypes quizType;
}

final class QuizZoneTabScreen extends StatefulWidget {
  const QuizZoneTabScreen({super.key, this.args});

  final QuizZoneTabScreenArgs? args;

  @override
  State<QuizZoneTabScreen> createState() => QuizZoneTabScreenState();

  static Route<dynamic> route(RouteSettings routeSettings) {
    final args = routeSettings.args<QuizZoneTabScreenArgs>();

    return CupertinoPageRoute(
      builder: (_) => QuizZoneTabScreen(args: args),
    );
  }
}

final class QuizZoneTabScreenState extends State<QuizZoneTabScreen>
    with AutomaticKeepAliveClientMixin {
  final _scrollController = ScrollController();
  final refreshKey = GlobalKey<RefreshIndicatorState>();

  QuizTypes get _quizType => widget.args?.quizType ?? QuizTypes.quizZone;

  String getCategoryTitle(QuizTypes quizType) => context.tr(switch (quizType) {
    QuizTypes.mathMania => 'mathMania',
    QuizTypes.audioQuestions => 'audioQuestions',
    QuizTypes.guessTheWord => 'guessTheWord',
    QuizTypes.funAndLearn => 'funAndLearn',
    QuizTypes.multiMatch => 'multiMatch',
    _ => 'quizZone',
  })!;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void onTapTab() {
    if (_scrollController.hasClients && _scrollController.offset != 0) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
    } else {
      refreshKey.currentState?.show();
    }
  }

  Future<void> _fetchCategories() async {
    final quizType = _quizType;
    /// Fetch the quiz zone categories, if logged in, fetch categories with user data, otherwise without it.
    if (context.read<AuthCubit>().isGuest) {
      await context.read<QuizCategoryCubit>().getQuizCategory(
        languageId: UiUtils.getCurrentQuizLanguageId(context),
        type: UiUtils.getCategoryTypeNumberFromQuizType(quizType),
      );
    } else {
      await context.read<QuizCategoryCubit>().getQuizCategoryWithUserId(
        languageId: UiUtils.getCurrentQuizLanguageId(context),
        type: UiUtils.getCategoryTypeNumberFromQuizType(quizType),
      );
    }
  }

  void _onTapCategory(BuildContext context, Category category) {
    // Check if the user is a guest, Show login required dialog for guest users
    if (context.read<AuthCubit>().isGuest) {
      showLoginRequiredDialog(context);
      return;
    }

    // Check if the category is premium and locked, prompt user to unlock it
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

    // check if Category has subcategories
    if (category.hasSubcategories) {
      if (_quizType case QuizTypes.multiMatch || QuizTypes.quizZone) {
        // redirect to Subcategories list screen
        globalCtx.pushNamed(
          Routes.subcategoryAndLevel,
          arguments: SubCategoryAndLevelScreenArgs(
            quizType: _quizType,
            category: category,
            categoryCubit: context.read<QuizCategoryCubit>(),
          ),
        );
      } else {
        Navigator.of(globalCtx).pushNamed(
          Routes.subCategory,
          arguments: SubCategoryScreenArgs(
            quizType: _quizType,
            category: category,
            categoryCubit: context.read<QuizCategoryCubit>(),
          ),
        );
      }
    } else {
      // otherwise check if Category has levels
      if (_quizType == QuizTypes.multiMatch) {
        if (category.maxLevel == '0') {
          globalCtx.pushNamed(
            Routes.multiMatchQuiz,
            arguments: MultiMatchQuizArgs(
              categoryId: category.id!,
              isPremiumCategory: category.isPremium,
            ),
          );
        } else {
          globalCtx.pushNamed(
            Routes.levels,
            arguments: LevelsScreenArgs(
              quizType: QuizTypes.multiMatch,
              category: category,
              categoryCubit: context.read<QuizCategoryCubit>(),
            ),
          );
        }
      } else if (_quizType == QuizTypes.quizZone) {
        if (category.maxLevel == '0') {
          //direct move to quiz screen pass level as 0
          Navigator.of(globalCtx).pushNamed(
            Routes.quiz,
            arguments: {
              'numberOfPlayer': 1,
              'quizType': _quizType,
              'categoryId': category.id,
              'subcategoryId': '',
              'level': '0',
              'subcategoryMaxLevel': category.maxLevel,
              'unlockedLevel': 0,
              'contestId': '',
              'comprehensionId': '',
              'showRetryButton': category.hasQuestions,
              'isPremiumCategory': category.isPremium,
              'isPlayed': category.isPlayed,
            },
          );
        } else {
          //navigate to level screen
          globalCtx.pushNamed(
            Routes.levels,
            arguments: LevelsScreenArgs(
              quizType: QuizTypes.quizZone,
              category: category,
              categoryCubit: context.read<QuizCategoryCubit>(),
            ),
          );
        }
      } else if (_quizType == QuizTypes.audioQuestions) {
        Navigator.of(context).pushNamed(
          Routes.quiz,
          arguments: {
            'quizType': QuizTypes.audioQuestions,
            'categoryId': category.id,
            'isPlayed': category.isPlayed,
            'isPremiumCategory': category.isPremium,
          },
        );
      } else if (_quizType == QuizTypes.guessTheWord) {
        context.pushNamed(
          Routes.guessTheWord,
          arguments: GuessTheWordQuizScreenArgs(
            categoryId: category.id!,
            isPlayed: category.isPlayed,
            isPremiumCategory: category.isPremium,
          ),
        );
      } else if (_quizType == QuizTypes.funAndLearn) {
        Navigator.of(context).pushNamed(
          Routes.funAndLearnTitle,
          arguments: {
            'categoryId': category.id,
            'title': category.categoryName,
            'isPremiumCategory': category.isPremium,
          },
        );
      } else if (_quizType == QuizTypes.mathMania) {
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
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocListener<QuizLanguageCubit, QuizLanguageState>(
      listenWhen: (prev, curr) => prev.languageId != curr.languageId,
      listener: (_, _) => _fetchCategories(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF0F4FF),
        body: Stack(
          children: [
            // Blue gradient header background
            Container(
              height: 170,
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
                    top: -50,
                    right: -50,
                    child: Container(
                      width: 150,
                      height: 150,
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
                  const SizedBox(height: 12),
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
                        child: _buildCategoriesListView(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        children: [
          // Logo/Icon row
          Row(
            children: [
              if (widget.args != null)
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 34,
                    height: 34,
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
                      size: 16,
                    ),
                  ),
                )
              else
                const SizedBox(width: 34),
              const Spacer(),
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.quiz_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const Spacer(),
              const SizedBox(width: 34), // Balance for back button
            ],
          ),
          const SizedBox(height: 6),
          // Title
          Text(
            getCategoryTitle(_quizType),
            style: GoogleFonts.nunito(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          // Subtitle
          Text(
            'Explore categories and test your knowledge',
            style: GoogleFonts.nunito(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 8),
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
                      int.tryParse(cat.subcategoriesCount.toString()) ?? 0;
                  questionsCount +=
                      int.tryParse(cat.questionsCount.toString()) ?? 0;
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
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatBadge(
                      '${topicsCount > 60 ? "60+" : topicsCount}',
                      'Topics',
                    ),
                  ),
                  const SizedBox(width: 8),
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
      borderRadius: BorderRadius.circular(10),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          constraints: const BoxConstraints(minHeight: 52),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.28),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: GoogleFonts.nunito(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  shadows: const [
                    Shadow(color: Color(0x66000000), blurRadius: 4),
                  ],
                ),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: GoogleFonts.nunito(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  height: 1.1,
                  color: Colors.white,
                  shadows: const [
                    Shadow(color: Color(0x66000000), blurRadius: 4),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesListView() {
    return BlocConsumer<QuizCategoryCubit, QuizCategoryState>(
      builder: (context, state) {
        if (state is QuizCategoryFailure) {
          return ErrorContainer(
            showBackButton: false,
            errorMessageColor: context.primaryColor,
            showErrorImage: true,
            errorMessage: convertErrorCodeToLanguageKey(state.errorMessage),
            onTapRetry: _fetchCategories,
          );
        }

        if (state is QuizCategorySuccess) {
          return RefreshIndicator(
            key: refreshKey,
            color: context.primaryColor,
            backgroundColor: context.scaffoldBackgroundColor,
            onRefresh: () async {
              await Future.delayed(const Duration(seconds: 1), () async {
                await _fetchCategories();
              });
            },
            child: GridView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              itemCount: state.categories.length,
              itemBuilder: (context, index) {
                final category = state.categories[index];
                final isLeftColumn = index % 2 == 0;
                return GestureDetector(
                  onTap: () => _onTapCategory(context, category),
                  child: _buildCategoryCard(category, isLeftColumn),
                );
              },
            ),
          );
        }

        return const Center(child: CircularProgressContainer());
      },
      listener: (context, state) {
        if (state is QuizCategoryFailure) {
          if (state.errorMessage == errorCodeUnauthorizedAccess) {
            showAlreadyLoggedInDialog(context);
          }
        }
      },
    );
  }

  Widget _buildCategoryCard(Category category, bool isBlue) {
    final gradientColors = isBlue
        ? [const Color(0xFFD6E4FF), const Color(0xFFE8F0FF)]
        : [const Color(0xFFFFE4D6), const Color(0xFFFFF0E8)];

    final iconBgColor = isBlue
        ? const Color(0xFF4A75E8)
        : const Color(0xFFE8A04A);

    final imageUrl = category.image ?? '';

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
                          category.hasSubcategories
                              ? "${category.subcategoriesCount} Topics"
                              : "${category.questionsCount} ${context.tr('questions')}",
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

  @override
  bool get wantKeepAlive => true;
}
