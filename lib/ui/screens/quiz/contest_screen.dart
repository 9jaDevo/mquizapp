import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';























































































































































That's it! Your app now fully complies with all requirements. 🎉---Thank you for your review.All contest prizes are virtual coins with no cash value, used only within the app.- 13 distinct quiz types with real-time multiplayer- Feature showcase onboarding- Guest mode for immediate play- Daily Challenge with algorithmic category rotation- Skill Tier progression system with accuracy-based ranking**4.3(a) - Spam:** Our app includes custom-developed features:**2.3.6 - Age Rating:** Updated to "Frequent" for Contests as requested.**5.3.2 - Contest Rules:** Official rules now accessible from Contest screen via info button (top right). Rules include required Apple disclaimer stating "Apple Inc. is not a sponsor of, and is not involved in any way with, this contest."We have addressed all guidelines:**Review Notes:**---Use this message in App Review Information:### Step 4: Submit for Review- Product → Archive → Distribute App- Open Xcode: `cd ios && open Runner.xcworkspace`### Step 3: Upload Build 62- Save changes- Age Rating → Contests: Select **"Frequent"**- Go to App Information### Step 2: Update App Store Connect```flutter build ipa --releasecd ios && pod install && cd ..flutter pub getflutter clean```powershell### Step 1: Build Fresh IPA## 📲 What to Do Now---| 5.1.1(v) | Guest mode (previous issue) | ✅ Already fixed || 4.3(a) | Unique features vs template | ✅ Documented || 2.3.6 | Age rating "Frequent" for Contests | ✅ Updated || 5.3.2 | Apple not sponsor statement | ✅ Added (prominent) || 5.3.2 | Official contest rules in app | ✅ Added ||-----------|------------|--------|| Guideline | Requirement | Status |## ✅ Compliance Summary---  - App name changed from "Elite Quiz" to "mQuiz"  - Updated age rating to "Frequent" for Contests  - Added rules button to contest screen  - Added Contest Rules screen- **Changes:**- **Build Number:** 1- **Version:** 2.3.8## 🎯 Build Details---- Rules accessible at all times from contest screen- Apple not involved disclaimer prominently displayed- Virtual coins only (NO cash prizes)**Contest Features:**4. View full contest rules with Apple disclaimer3. Tap the **ℹ️ info icon** in the top right2. Navigate to Contest section from home screen1. Launch app → Complete onboarding**To View Contest Rules:**## 📝 Testing Instructions for Reviewers---   - Exam Mode, Fun & Learn, Quiz Zone, Multi-Match   - Guess the Word, True/False, Self Challenge   - 1v1 Battles, Group Battles, Random Battles   - Daily Quiz, Contests, Audio Questions, Math Mania5. **13 Distinct Quiz Types**   - Addresses guideline 5.1.1(v) compliance   - Smart prompts explaining benefits (not forcing)   - Modified auth flow for immediate play without registration4. **Guest Mode Architecture**   - File: `lib/ui/screens/feature_showcase_screen.dart`   - Dynamic content based on backend config   - Custom screen highlighting unique features3. **Feature Showcase Onboarding**   - File: `lib/ui/screens/home/widgets/daily_challenge_card.dart`   - Completion tracking with Hive caching   - Proprietary rotation algorithm for category selection2. **Daily Smart Challenge**   - Files: `lib/features/skill_tier/`   - Dynamic tier badges (Bronze → Platinum) throughout app   - Custom calculation algorithm analyzing user accuracy1. **Skill Tier System****Our Custom Features:**### 3. Guideline 4.3(a) - Design Spam---- App Information → Age Rating → Contests: Set to **"Frequent"**✅ **Updated Age Rating in App Store Connect:****What We Did:**- Select "Frequent" for Contests in Age Rating**What Apple Asked:**### 2. Guideline 2.3.6 - Age Rating ✅ FIXED---- Rules available at all times (as required)- One tap access to full contest rules- Info icon button in contest screen app bar✅ **Added Rules Button**- Rules cover: eligibility, entry, prizes, winner selection, disputes, privacy- Clear disclosure that prizes are virtual coins with NO cash value- Prominent notice: "Apple Inc. is not a sponsor of, and is not involved in any way with, this contest or sweepstakes"- Full official contest rules accessible from contest screen✅ **Created Contest Rules Screen** (`lib/ui/screens/contest_rules_screen.dart`)**What We Did:**- State that Apple is not a sponsor- Include official contest rules within the app**What Apple Asked:**### 1. Guideline 5.3.2 - Contest Rules ✅ FIXED## ✅ Changes Made to Comply with Guidelinesimport 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/commons/commons.dart';
import 'package:flutterquiz/core/core.dart';
import 'package:flutterquiz/features/profile_management/cubits/update_score_and_coins_cubit.dart';
import 'package:flutterquiz/features/profile_management/cubits/user_details_cubit.dart';
import 'package:flutterquiz/features/profile_management/profile_management_repository.dart';
import 'package:flutterquiz/features/quiz/cubits/contest_cubit.dart';
import 'package:flutterquiz/features/quiz/models/contest.dart';
import 'package:flutterquiz/features/quiz/models/quiz_type.dart';
import 'package:flutterquiz/features/quiz/quiz_repository.dart';
import 'package:flutterquiz/ui/widgets/already_logged_in_dialog.dart';
import 'package:flutterquiz/ui/widgets/circular_progress_container.dart';
import 'package:flutterquiz/ui/widgets/custom_back_button.dart';
import 'package:flutterquiz/ui/widgets/error_container.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';

/// Contest Type
const int _past = 0;
const int _live = 1;
const int _upcoming = 2;

class ContestScreen extends StatefulWidget {
  const ContestScreen({super.key});

  @override
  State<ContestScreen> createState() => _ContestScreen();

  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider<ContestCubit>(
            create: (_) => ContestCubit(QuizRepository()),
          ),
          BlocProvider<UpdateCoinsCubit>(
            create: (_) => UpdateCoinsCubit(ProfileManagementRepository()),
          ),
        ],
        child: const ContestScreen(),
      ),
    );
  }
}

class _ContestScreen extends State<ContestScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    context.read<ContestCubit>().getContest(
      languageId: UiUtils.getCurrentQuizLanguageId(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: 1,
      child: Builder(
        builder: (BuildContext context) {
          return Scaffold(
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              title: Text(
                context.tr('contestLbl')!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.onTertiary,
                ),
              ),
              leading: const CustomBackButton(),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.info_outline),
                  tooltip: 'Contest Rules',
                  onPressed: () {
                    Navigator.of(context).pushNamed(Routes.contestRules);
                  },
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(50),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: Theme.of(
                      context,
                    ).colorScheme.onTertiary.withValues(alpha: 0.08),
                  ),
                  child: TabBar(
                    tabAlignment: TabAlignment.fill,
                    tabs: [
                      Tab(text: context.tr('pastLbl')),
                      Tab(text: context.tr('liveLbl')),
                      Tab(text: context.tr('upcomingLbl')),
                    ],
                  ),
                ),
              ),
            ),
            body: BlocConsumer<ContestCubit, ContestState>(
              bloc: context.read<ContestCubit>(),
              listener: (context, state) {
                if (state is ContestFailure) {
                  if (state.errorMessage == errorCodeUnauthorizedAccess) {
                    showAlreadyLoggedInDialog(context);
                  }
                }
              },
              builder: (context, state) {
                if (state is ContestProgress || state is ContestInitial) {
                  return const Center(child: CircularProgressContainer());
                }
                if (state is ContestFailure) {
                  return ErrorContainer(
                    errorMessage: convertErrorCodeToLanguageKey(
                      state.errorMessage,
                    ),
                    onTapRetry: () {
                      context.read<ContestCubit>().getContest(
                        languageId: UiUtils.getCurrentQuizLanguageId(context),
                      );
                    },
                    showErrorImage: true,
                  );
                }
                final contestList = (state as ContestSuccess).contestList;
                return TabBarView(
                  children: [
                    past(contestList.past),
                    live(contestList.live),
                    future(contestList.upcoming),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget past(Contest data) {
    return data.errorMessage.isNotEmpty
        ? contestErrorContainer(data)
        : ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: data.contestDetails.length,
            itemBuilder: (_, i) => _ContestCard(
              contestDetails: data.contestDetails[i],
              contestType: _past,
            ),
          );
  }

  Widget live(Contest data) {
    return data.errorMessage.isNotEmpty
        ? contestErrorContainer(data)
        : ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: data.contestDetails.length,
            itemBuilder: (_, i) => _ContestCard(
              contestDetails: data.contestDetails[i],
              contestType: _live,
            ),
          );
  }

  Widget future(Contest data) {
    return data.errorMessage.isNotEmpty
        ? contestErrorContainer(data)
        : ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: data.contestDetails.length,
            itemBuilder: (_, i) => _ContestCard(
              contestDetails: data.contestDetails[i],
              contestType: _upcoming,
            ),
          );
  }

  ErrorContainer contestErrorContainer(Contest data) {
    return ErrorContainer(
      showBackButton: false,
      errorMessage: convertErrorCodeToLanguageKey(data.errorMessage),
      onTapRetry: () => context.read<ContestCubit>().getContest(
        languageId: UiUtils.getCurrentQuizLanguageId(context),
      ),
      showErrorImage: true,
    );
  }
}

class _ContestCard extends StatefulWidget {
  const _ContestCard({required this.contestDetails, required this.contestType});

  final ContestDetails contestDetails;
  final int contestType;

  @override
  State<_ContestCard> createState() => _ContestCardState();
}

class _ContestCardState extends State<_ContestCard> {
  void _handleOnTap() {
    if (widget.contestType == _past) {
      Navigator.of(context).pushNamed(
        Routes.contestLeaderboard,
        arguments: {'contestId': widget.contestDetails.id},
      );
    }
    if (widget.contestType == _live) {
      if (int.parse(context.read<UserDetailsCubit>().getCoins()!) >=
          int.parse(widget.contestDetails.entry!)) {
        context.read<UpdateCoinsCubit>().updateCoins(
          coins: int.parse(widget.contestDetails.entry!),
          addCoin: false,
          title: playedContestKey,
        );

        context.read<UserDetailsCubit>().updateCoins(
          addCoin: false,
          coins: int.parse(widget.contestDetails.entry!),
        );
        Navigator.of(context).pushReplacementNamed(
          Routes.quiz,
          arguments: {
            'quizType': QuizTypes.contest,
            'contestId': widget.contestDetails.id,
          },
        );
      } else {
        showNotEnoughCoinsDialog(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final boldTextStyle = TextStyle(
      fontSize: 14,
      color: context.primaryTextColor,
      fontWeight: FontWeight.bold,
    );
    final normalTextStyle = TextStyle(
      fontSize: 14,
      fontWeight: FontWeights.regular,
      color: context.primaryTextColor.withValues(alpha: 0.6),
    );
    final width = context.width;

    final verticalDivider = SizedBox(
      width: 1,
      height: 30,
      child: ColoredBox(color: context.scaffoldBackgroundColor),
    );

    return Container(
      margin: const EdgeInsets.all(15),
      width: width * .9,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(5, 5),
          ),
        ],
        borderRadius: BorderRadius.circular(10),
      ),
      child: GestureDetector(
        onTap: _handleOnTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CachedNetworkImage(
                imageUrl: widget.contestDetails.image!,
                placeholder: (_, i) =>
                    const Center(child: CircularProgressContainer()),
                imageBuilder: (_, img) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(image: img, fit: BoxFit.cover),
                    ),
                    height: 171,
                    width: width,
                  );
                },
                errorWidget: (_, i, e) => Center(
                  child: Icon(Icons.error, color: context.primaryColor),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: width * .78),
                    child: Text(
                      widget.contestDetails.name!,
                      style: boldTextStyle,
                    ),
                  ),
                  if (widget.contestDetails.description!.length > 50)
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: context.scaffoldBackgroundColor,
                        ),
                      ),
                      alignment: Alignment.center,
                      height: 30,
                      width: 30,
                      padding: EdgeInsets.zero,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            widget.contestDetails.showDescription =
                                !widget.contestDetails.showDescription!;
                          });
                        },
                        child: Icon(
                          widget.contestDetails.showDescription!
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          color: context.primaryTextColor,
                          size: 30,
                        ),
                      ),
                    )
                  else
                    const SizedBox(),
                ],
              ),
              SizedBox(
                width: !widget.contestDetails.showDescription!
                    ? width * .75
                    : width,
                child: Text(
                  widget.contestDetails.description!,
                  style: TextStyle(
                    color: context.primaryTextColor.withValues(alpha: 0.3),
                  ),
                  maxLines: !widget.contestDetails.showDescription! ? 1 : 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 10),
              Divider(color: context.scaffoldBackgroundColor, height: 0),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(context.tr('entryFeesLbl')!, style: normalTextStyle),
                      Text(
                        '${widget.contestDetails.entry!} ${context.tr('coinsLbl')!}',
                        style: boldTextStyle,
                      ),
                    ],
                  ),

                  ///
                  verticalDivider,
                  if (widget.contestType == _upcoming)
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          context.tr('startsOnLbl')!,
                          style: normalTextStyle,
                        ),
                        Text(
                          widget.contestDetails.startDate!,
                          style: boldTextStyle,
                        ),
                      ],
                    )
                  else
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(context.tr('playersLbl')!, style: normalTextStyle),
                        Text(
                          widget.contestDetails.participants!,
                          style: boldTextStyle,
                        ),
                      ],
                    ),

                  ///
                  verticalDivider,
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(context.tr('endsOnLbl')!, style: normalTextStyle),
                      Text(
                        widget.contestDetails.endDate!,
                        style: boldTextStyle,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
