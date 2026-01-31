import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/commons/commons.dart';
import 'package:flutterquiz/core/core.dart';
import 'package:flutterquiz/features/auth/cubits/auth_cubit.dart';
import 'package:flutterquiz/features/quiz/cubits/quiz_category_cubit.dart';
import 'package:flutterquiz/features/quiz/models/category.dart';
import 'package:flutterquiz/features/quiz/models/quiz_type.dart';
import 'package:flutterquiz/ui/screens/quiz/levels_screen.dart';
import 'package:flutterquiz/ui/screens/quiz/subcategory_and_level_screen.dart';
import 'package:flutterquiz/ui/widgets/already_logged_in_dialog.dart';
import 'package:flutterquiz/ui/widgets/circular_progress_container.dart';
import 'package:flutterquiz/ui/widgets/error_container.dart';
import 'package:flutterquiz/ui/widgets/premium_category_access_badge.dart';
import 'package:flutterquiz/ui/widgets/unlock_premium_category_dialog.dart';
import 'package:flutterquiz/utils/ui_utils.dart';
import 'package:google_fonts/google_fonts.dart';

final class QuizZoneTabScreen extends StatefulWidget {
  const QuizZoneTabScreen({super.key});

  @override
  State<QuizZoneTabScreen> createState() => QuizZoneTabScreenState();
}

final class QuizZoneTabScreenState extends State<QuizZoneTabScreen>
    with AutomaticKeepAliveClientMixin {
  final _scrollController = ScrollController();
  final refreshKey = GlobalKey<RefreshIndicatorState>();

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
    /// Fetch the quiz zone categories, if logged in, fetch categories with user data, otherwise without it.
    if (context.read<AuthCubit>().isGuest) {
      await context.read<QuizCategoryCubit>().getQuizCategory(
        languageId: UiUtils.getCurrentQuizLanguageId(context),
        type: QuizTypes.quizZone.typeValue!,
      );
    } else {
      await context.read<QuizCategoryCubit>().getQuizCategoryWithUserId(
        languageId: UiUtils.getCurrentQuizLanguageId(context),
        type: QuizTypes.quizZone.typeValue!,
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
      // redirect to Subcategories list screen
      globalCtx.pushNamed(
        Routes.subcategoryAndLevel,
        arguments: SubCategoryAndLevelScreenArgs(
          quizType: QuizTypes.quizZone,
          category: category,
          categoryCubit: context.read<QuizCategoryCubit>(),
        ),
      );
    } else {
      // otherwise check if Category has levels
      if (category.hasLevels) {
        // redirect to Levels screen
        globalCtx.pushNamed(
          Routes.levels,
          arguments: LevelsScreenArgs(
            quizType: QuizTypes.quizZone,
            category: category,
            categoryCubit: context.read<QuizCategoryCubit>(),
          ),
        );
      } else {
        // Start the Quiz
        Navigator.of(globalCtx).pushNamed(
          Routes.quiz,
          arguments: {
            'numberOfPlayer': 1,
            'quizType': QuizTypes.quizZone,
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
              height: 320,
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
                    top: -60,
                    right: -60,
                    child: Container(
                      width: 200,
                      height: 200,
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
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Logo/Icon row
          Row(
            children: [
              const SizedBox(width: 44), // Balance for space
              const Spacer(),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: const Icon(
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
            context.tr('quizZone')!,
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
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              Text(
                value,
                style: GoogleFonts.nunito(
                  fontSize: 18,
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
