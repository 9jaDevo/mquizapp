import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/core/core.dart';
import 'package:flutterquiz/features/ads/blocs/banner_ad_cubit.dart';
import 'package:flutterquiz/features/ads/widgets/banner_ad_container.dart';
import 'package:flutterquiz/features/profile_management/cubits/user_details_cubit.dart';
import 'package:flutterquiz/features/quiz/cubits/quiz_category_cubit.dart';
import 'package:flutterquiz/features/quiz/cubits/subcategory_cubit.dart';
import 'package:flutterquiz/features/quiz/models/category.dart';
import 'package:flutterquiz/features/quiz/models/quiz_type.dart';
import 'package:flutterquiz/features/quiz/models/subcategory.dart';
import 'package:flutterquiz/ui/screens/quiz/guess_the_word_quiz_screen.dart';
import 'package:flutterquiz/ui/widgets/already_logged_in_dialog.dart';
import 'package:flutterquiz/ui/widgets/circular_progress_container.dart';
import 'package:flutterquiz/ui/widgets/error_container.dart';
import 'package:flutterquiz/ui/widgets/unlock_premium_category_dialog.dart';
import 'package:google_fonts/google_fonts.dart';

final class SubCategoryScreenArgs extends RouteArgs {
  const SubCategoryScreenArgs({
    required this.quizType,
    required this.category,
    required this.categoryCubit,
  });

  final QuizTypes quizType;
  final Category category;
  final QuizCategoryCubit categoryCubit;
}

class SubCategoryScreen extends StatefulWidget {
  const SubCategoryScreen({required this.args, super.key});

  final SubCategoryScreenArgs args;

  @override
  State<SubCategoryScreen> createState() => _SubCategoryScreenState();

  static Route<dynamic> route(RouteSettings routeSettings) {
    final args = routeSettings.args<SubCategoryScreenArgs>();

    return CupertinoPageRoute(builder: (_) => SubCategoryScreen(args: args));
  }
}

class _SubCategoryScreenState extends State<SubCategoryScreen> {
  late final Category _category = widget.args.category;

  void getSubCategory() {
    Future.delayed(Duration.zero, () {
      context.read<SubCategoryCubit>().fetchSubCategory(_category.id!);
    });
  }

  @override
  void initState() {
    super.initState();
    getSubCategory();
  }

  late bool locked = _category.isPremium && !_category.hasUnlocked;

  void handleListTileTap(Subcategory subCategory) {
    if (locked) {
      showUnlockPremiumCategoryDialog(
        context,
        categoryId: _category.id!,
        categoryName: _category.categoryName!,
        requiredCoins: _category.requiredCoins,
        categoryCubit: widget.args.categoryCubit,
      ).then((result) {
        if (result != null && result) {
          setState(() {
            locked = false;
          });
        }
      });
      return;
    }

    if (widget.args.quizType == QuizTypes.guessTheWord) {
      context.pushNamed(
        Routes.guessTheWord,
        arguments: GuessTheWordQuizScreenArgs(
          categoryId: _category.id!,
          subcategoryId: subCategory.id,
          isPlayed: subCategory.isPlayed,
          isPremiumCategory: _category.isPremium,
        ),
      );
    } else if (widget.args.quizType == QuizTypes.funAndLearn) {
      Navigator.of(context).pushNamed(
        Routes.funAndLearnTitle,
        arguments: {
          'categoryId': _category.id,
          'subcategoryId': subCategory.id,
          'title': subCategory.subcategoryName,
          'isPremiumCategory': _category.isPremium,
        },
      );
    } else if (widget.args.quizType == QuizTypes.audioQuestions) {
      Navigator.of(context).pushNamed(
        Routes.quiz,
        arguments: {
          'quizType': QuizTypes.audioQuestions,
          'categoryId': _category.id,
          'subcategoryId': subCategory.id,
          'isPlayed': subCategory.isPlayed,
          'isPremiumCategory': _category.isPremium,
        },
      );
    } else if (widget.args.quizType == QuizTypes.mathMania) {
      Navigator.of(context).pushNamed(
        Routes.quiz,
        arguments: {
          'quizType': QuizTypes.mathMania,
          'categoryId': _category.id,
          'subcategoryId': subCategory.id,
          'isPlayed': subCategory.isPlayed,
          'isPremiumCategory': _category.isPremium,
        },
      );
    }
  }

  Widget _buildSubCategory() {
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
          return Center(
            child: ErrorContainer(
              showBackButton: false,
              showErrorImage: true,
              errorMessage: convertErrorCodeToLanguageKey(state.errorMessage),
              onTapRetry: getSubCategory,
            ),
          );
        }

        final subcategories =
            (state as SubCategoryFetchSuccess).subcategoryList;
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: subcategories.length,
          physics: const AlwaysScrollableScrollPhysics(),
          separatorBuilder: (_, i) => const SizedBox(height: 12),
          itemBuilder: (BuildContext context, int index) {
            final subcategory = subcategories[index];
            return _buildSubCategoryCard(subcategory, index);
          },
        );
      },
    );
  }

  Widget _buildSubCategoryCard(Subcategory subcategory, int index) {
    final isBlue = index % 2 == 0;
    final iconBgColor = isBlue
        ? const Color(0xFF4A75E8)
        : const Color(0xFFE8A04A);
    final lightBgColor = isBlue
        ? const Color(0xFFE8F0FF)
        : const Color(0xFFFFF0E8);

    return GestureDetector(
      onTap: () => handleListTileTap(subcategory),
      child: Container(
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
            // Main subcategory row
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Icon container
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: lightBgColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: iconBgColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(6),
                        child:
                            subcategory.image != null &&
                                subcategory.image!.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: subcategory.image!,
                                color: Colors.white,
                                fit: BoxFit.contain,
                                placeholder: (_, _) => const SizedBox(),
                                errorWidget: (_, _, _) => const Icon(
                                  Icons.quiz_outlined,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              )
                            : const Icon(
                                Icons.quiz_outlined,
                                color: Colors.white,
                                size: 16,
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Title and info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                        Row(
                          children: [
                            const Icon(
                              Icons.help_outline_rounded,
                              size: 14,
                              color: Color(0xFF64748B),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "${subcategory.noOfQue} ${context.tr(widget.args.quizType == QuizTypes.funAndLearn ? "comprehensiveLbl" : "questions")}",
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
                  // Arrow icon
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: iconBgColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.chevron_right_rounded,
                      color: iconBgColor,
                      size: 20,
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
            height: 140,
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
                _buildHeader(),
                const SizedBox(height: 8),
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
                        child: _buildSubCategory(),
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 18,
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
                  _category.categoryName!,
                  style: GoogleFonts.nunito(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_category.subcategoriesCount} Topics available',
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          // Category icon
          if (_category.image != null && _category.image!.isNotEmpty)
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(8),
              child: CachedNetworkImage(
                imageUrl: _category.image!,
                color: Colors.white,
                fit: BoxFit.contain,
              ),
            ),
        ],
      ),
    );
  }
}
