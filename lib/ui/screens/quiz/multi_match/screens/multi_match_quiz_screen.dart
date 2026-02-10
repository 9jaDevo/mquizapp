import 'dart:async';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/commons/commons.dart';
import 'package:flutterquiz/core/core.dart';
import 'package:flutterquiz/features/ads/blocs/rewarded_ad_cubit.dart';
import 'package:flutterquiz/features/profile_management/cubits/user_details_cubit.dart';
import 'package:flutterquiz/features/quiz/cubits/subcategory_cubit.dart';
import 'package:flutterquiz/features/quiz/cubits/unlocked_level_cubit.dart';
import 'package:flutterquiz/features/quiz/models/answer_option.dart';
import 'package:flutterquiz/features/quiz/models/quiz_type.dart';
import 'package:flutterquiz/features/quiz/multi_match/blocs/multi_match_fetch_questions_cubit.dart';
import 'package:flutterquiz/features/quiz/multi_match/models/multi_match_answer_type_enum.dart';
import 'package:flutterquiz/features/quiz/multi_match/models/multi_match_question_model.dart';
import 'package:flutterquiz/features/quiz/utils/quiz_utils.dart';
import 'package:flutterquiz/features/settings/settings_cubit.dart';
import 'package:flutterquiz/features/system_config/cubits/system_config_cubit.dart';
import 'package:flutterquiz/ui/screens/quiz/multi_match/screens/multi_match_result_screen.dart';
import 'package:flutterquiz/ui/widgets/all.dart';
import 'package:flutterquiz/utils/answer_encryption.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';

final class MultiMatchQuizArgs extends RouteArgs {
  const MultiMatchQuizArgs({
    required this.categoryId,
    required this.isPremiumCategory,
    this.level = '0', // 0 - no level
    this.subcategoryId,
    this.totalLevels = 0,
    this.unlockedLevel = 0,
  });

  final String categoryId;
  final String level;
  final String? subcategoryId;
  final bool isPremiumCategory;

  final int totalLevels;
  final int unlockedLevel;
}

class MultiMatchQuizScreen extends StatefulWidget {
  const MultiMatchQuizScreen({required this.args, super.key});

  final MultiMatchQuizArgs args;

  @override
  State<MultiMatchQuizScreen> createState() => _MultiMatchQuizScreenState();

  static Route<dynamic> route(RouteSettings settings) {
    final args = settings.args<MultiMatchQuizArgs>();

    return CupertinoPageRoute(
      builder: (_) => BlocProvider(
        create: (_) => MultiMatchFetchQuestionsCubit(),
        child: MultiMatchQuizScreen(args: args),
      ),
    );
  }
}

class _MultiMatchQuizScreenState extends State<MultiMatchQuizScreen>
    with TickerProviderStateMixin {
  late final int quizDuration = context.read<SystemConfigCubit>().quizTimer(
    QuizTypes.multiMatch,
  );

  late Animation<double> questionSlideAnimation;
  late Animation<double> questionScaleUpAnimation;
  late Animation<double> questionScaleDownAnimation;
  late Animation<double> questionContentAnimation;
  late AnimationController questionAnimationController;
  late AnimationController questionContentAnimationController;
  late final timerAnimationController = PreserveAnimationController(
    reverseDuration: const Duration(seconds: inBetweenQuestionTimeInSeconds),
    duration: Duration(seconds: quizDuration),
  )..addStatusListener(timerListener);

  void initializeAnimation() {
    questionContentAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    questionAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 525),
    );
    questionSlideAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: questionAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    questionScaleUpAnimation = Tween<double>(begin: 0, end: 0.1).animate(
      CurvedAnimation(
        parent: questionAnimationController,
        curve: const Interval(0, 0.5, curve: Curves.easeInQuad),
      ),
    );
    questionContentAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: questionContentAnimationController,
        curve: Curves.easeInQuad,
      ),
    );
    questionScaleDownAnimation = Tween<double>(begin: 0, end: 0.05).animate(
      CurvedAnimation(
        parent: questionAnimationController,
        curve: const Interval(0.5, 1, curve: Curves.easeOutQuad),
      ),
    );
  }

  void timerListener(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      totalSecondsToCompleteQuiz += quizDuration;

      context.read<MultiMatchFetchQuestionsCubit>().timeOutOnQuestion(
        currQuestionIndex,
      );
    }
  }

  /// ----------
  var currQuestionIndex = 0;
  var totalSecondsToCompleteQuiz = 0.0;

  late final String _firebaseId = context
      .read<UserDetailsCubit>()
      .getUserFirebaseId();

  @override
  void initState() {
    super.initState();

    // Init Ad
    Future.delayed(Duration.zero, () {
      context.read<RewardedAdCubit>().createRewardedAd(context);
    });

    initializeAnimation();

    _getQuestions();
  }

  @override
  void dispose() {
    timerAnimationController.dispose();
    questionAnimationController.dispose();
    questionContentAnimationController.dispose();
    super.dispose();
  }

  void _getQuestions() {
    Future.delayed(Duration.zero, () {
      context.read<MultiMatchFetchQuestionsCubit>().fetchQuestions(
        categoryId: widget.args.categoryId,
        subcategoryId: widget.args.subcategoryId,
        level: widget.args.level,
      );
    });
  }

  bool isExitDialogOpen = false;
  void _onTapBack() {
    isExitDialogOpen = true;

    context
        .showDialog<void>(
          title: context.tr('quizExitTitle'),
          message: context.tr('quizExitLbl'),
          cancelButtonText: context.tr('leaveAnyways'),
          confirmButtonText: context.tr('keepPlaying'),
          onCancel: () {
            context
              ..shouldPop()
              ..shouldPop();
          },
        )
        .then((_) {
          if (widget.args.subcategoryId != null) {
            context.read<UnlockedLevelCubit>().fetchUnlockLevel(
              widget.args.categoryId,
              '0',
              quizType: QuizTypes.multiMatch,
            );
          } else {
            context.read<SubCategoryCubit>().fetchSubCategory(
              widget.args.categoryId,
            );
          }
        });
  }

  late final List<MultiMatchQuestion> questions = context
      .read<MultiMatchFetchQuestionsCubit>()
      .questions;
  MultiMatchQuestion get currQue => questions[currQuestionIndex];

  void _toggleOptionSelection(String id) {
    /// submitted the answer, cannot change the answer now.
    if (currQue.hasSubmittedAnswers) return;

    context.read<MultiMatchFetchQuestionsCubit>().updateSelectedOptions(
      currQue.id,
      id,
    );
  }

  void _onReorder(List<String> selectedOptionsIds) {
    /// submitted the answer, cannot change the answer now.
    if (currQue.hasSubmittedAnswers) return;

    context.read<MultiMatchFetchQuestionsCubit>().onReorderOptions(
      currQue.id,
      selectedOptionsIds,
    );
  }

  bool _hasSubmittedCurrentQuestion() => currQue.hasSubmittedAnswers;

  Duration get _timer =>
      timerAnimationController.duration! -
      (timerAnimationController.lastElapsedDuration ?? Duration.zero);

  Widget _buildCloseButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: _onTapBack,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(
            Icons.close_rounded,
            color: Color(0xFF1E3A8A),
            size: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionPill({required int current, required int total}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Text(
        'Question $current/$total',
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color: Color(0xFF1E3A8A),
        ),
      ),
    );
  }

  Widget _buildTimerRing() {
    return AnimatedBuilder(
      animation: timerAnimationController,
      builder: (context, _) {
        final seconds = _timer.inSeconds.remainder(60);
        final progress = 1 - timerAnimationController.value;
        return SizedBox(
          width: 38,
          height: 38,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                strokeWidth: 4,
                backgroundColor: const Color(0xFFE6EEF9),
                valueColor: const AlwaysStoppedAnimation(
                  Color(0xFF2E6CF6),
                ),
              ),
              Text(
                seconds.toString().padLeft(2, '0'),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E3A8A),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopProgressBar({required int current, required int total}) {
    final value = total > 0 ? current / total : 0.0;
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: LinearProgressIndicator(
        value: value.clamp(0.0, 1.0),
        minHeight: 6,
        backgroundColor: const Color(0xFFE6EEF9),
        valueColor: const AlwaysStoppedAnimation(Color(0xFF2E6CF6)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<
      MultiMatchFetchQuestionsCubit,
      MultiMatchFetchQuestionsState
    >(
      builder: (context, state) {
        if (state is MultiMatchQuestionsSuccess) {
          final totalQuestions = state.questions.length;
          final currentQuestion = currQuestionIndex + 1;
          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, _) {
              if (didPop) return;

              _onTapBack();
            },
            child: Scaffold(
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
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                _buildCloseButton(),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Center(
                                    child: _buildQuestionPill(
                                      current: currentQuestion,
                                      total: totalQuestions,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                _buildTimerRing(),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildTopProgressBar(
                              current: currentQuestion,
                              total: totalQuestions,
                            ),
                            const SizedBox(height: 16),
                            Expanded(
                              child: Align(
                                alignment: Alignment.topCenter,
                                child: MultiMatchQuestionsView(
                                  currQuestionIdx: currQuestionIndex,
                                  questions: state.questions,
                                  timerAnimationController:
                                      timerAnimationController,
                                  questionAnimationController:
                                      questionAnimationController,
                                  questionContentAnimation:
                                      questionContentAnimation,
                                  questionContentAnimationController:
                                      questionAnimationController,
                                  questionScaleDownAnimation:
                                      questionScaleDownAnimation,
                                  questionScaleUpAnimation:
                                      questionScaleUpAnimation,
                                  questionSlideAnimation:
                                      questionSlideAnimation,
                                  toggleOptionSelection: _toggleOptionSelection,
                                  hasSubmittedCurrentQuestion:
                                      _hasSubmittedCurrentQuestion,
                                  onReorder: _onReorder,
                                ),
                              ),
                            ),
                            const SizedBox(height: 90),
                          ],
                        ),
                      ),
                      _buildCheckAnswersButton(),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        if (state is MultiMatchFetchQuestionsFailure) {
          return Scaffold(
            appBar: const QAppBar(title: SizedBox(), roundedAppBar: false),
            body: Center(
              child: ErrorContainer(
                showBackButton: true,
                errorMessage: convertErrorCodeToLanguageKey(state.error),
                onTapRetry: _getQuestions,
                showErrorImage: true,
              ),
            ),
          );
        }

        return const Scaffold(body: Center(child: CircularProgressContainer()));
      },
      listener: (context, state) {
        if (state is MultiMatchQuestionsSuccess) {
          if (state.questions.isNotEmpty) {
            if (currQuestionIndex == 0 && !currQue.hasSubmittedAnswers) {
              timerAnimationController.forward();
              questionContentAnimationController.forward();
            }
          }
        }
      },
    );
  }

  Future<void> _nextQueOrCompleteQuiz() async {
    if (currQuestionIndex == questions.length - 1) {
      await context.pushReplacementNamed(
        Routes.multiMatchResultScreen,
        arguments: MultiMatchResultScreenArgs(
          categoryId: widget.args.categoryId,
          subcategoryId: widget.args.subcategoryId,
          totalLevels: widget.args.totalLevels,
          unlockedLevel: widget.args.unlockedLevel,
          timeTakenToCompleteQuiz: totalSecondsToCompleteQuiz.toInt(),
          isPremiumCategory: widget.args.isPremiumCategory,
          questions: context.read<MultiMatchFetchQuestionsCubit>().questions,
        ),
      );
    } else {
      /// next question
      await questionAnimationController.forward(from: 0).then((value) {
        //need to dispose the animation controllers
        questionAnimationController.dispose();
        questionContentAnimationController.dispose();
        //initializeAnimation again
        setState(() {
          initializeAnimation();
          ++currQuestionIndex;
          showCheckButton = true;
        });

        //load content(options, image etc) of question
        questionContentAnimationController.forward();
      });
      await timerAnimationController.forward(from: 0);
    }
  }

  late final _audioPlayer = AudioPlayer();
  Future<void> playSound(String trackName) async {
    if (context.read<SettingsCubit>().getSettings().sound) {
      if (_audioPlayer.playing) {
        await _audioPlayer.stop();
      }
      await _audioPlayer.setAsset(trackName);
      await _audioPlayer.play();
    }
  }

  Future<void> playVibrate() async {
    if (context.read<SettingsCubit>().getSettings().vibration) {
      UiUtils.vibrate();
    }
  }

  var showCheckButton = true;
  Widget _buildCheckAnswersButton() {
    Future<void> onTap() async {
      if (currQue.hasSubmittedAnswers) {
        await timerAnimationController.reverse();

        setState(() {
          showCheckButton = false;
        });

        await _nextQueOrCompleteQuiz();
        return;
      } else {
        /// Submit the answer
        timerAnimationController.stop(canceled: false);

        final correctAnswersIds = AnswerEncryption.decryptCorrectAnswers(
          rawKey: _firebaseId,
          correctAnswer: currQue.correctAnswer,
        );

        final bool isCorrectlyAnswered;
        if (currQue.answerType == MultiMatchAnswerType.multiSelect) {
          isCorrectlyAnswered =
              correctAnswersIds.length == currQue.submittedIds.length &&
              correctAnswersIds.toSet().containsAll(currQue.submittedIds);
        } else {
          isCorrectlyAnswered = listEquals<String>(
            correctAnswersIds,
            currQue.submittedIds,
          );
        }

        /// submit the selected answers
        context.read<MultiMatchFetchQuestionsCubit>().submitAnswer(
          currQuestionIndex,
          answerType: currQue.answerType,
          correctAnswersIds: correctAnswersIds,
        );

        if (isCorrectlyAnswered) {
          unawaited(playSound(Assets.sfxCorrectAnswer));
        } else {
          unawaited(playSound(Assets.sfxWrongAnswer));
        }
        unawaited(playVibrate());

        /// Update the time taken to complete quiz.
        totalSecondsToCompleteQuiz += UiUtils.timeTakenToSubmitAnswer(
          animationControllerValue: timerAnimationController.value,
          quizTimer: quizDuration,
        );
      }
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: showCheckButton
          ? Align(
              alignment: const FractionalOffset(.5, .98),
              child: CustomRoundedButton(
                widthPercentage: .9,
                backgroundColor: const Color(0xFF2E6CF6),
                buttonTitle: currQue.hasSubmittedAnswers
                    ? context.tr('continueLbl')
                    : context.tr('checkLbl'),
                radius: 18,
                showBorder: false,
                height: 52,
                onTap: onTap,
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}

class MultiMatchQuestionsView extends StatefulWidget {
  const MultiMatchQuestionsView({
    required this.currQuestionIdx,
    required this.questions,
    required this.questionContentAnimationController,
    required this.questionAnimationController,
    required this.questionSlideAnimation,
    required this.questionScaleUpAnimation,
    required this.questionScaleDownAnimation,
    required this.questionContentAnimation,
    required this.timerAnimationController,
    required this.toggleOptionSelection,
    required this.hasSubmittedCurrentQuestion,
    required this.onReorder,
    super.key,
  });

  final AnimationController questionContentAnimationController;
  final AnimationController questionAnimationController;
  final Animation<double> questionSlideAnimation;
  final Animation<double> questionScaleUpAnimation;
  final Animation<double> questionScaleDownAnimation;
  final Animation<double> questionContentAnimation;
  final AnimationController timerAnimationController;

  final int currQuestionIdx;
  final List<MultiMatchQuestion> questions;

  final bool Function() hasSubmittedCurrentQuestion;
  final void Function(String) toggleOptionSelection;

  final void Function(List<String> selectedOptionsIds) onReorder;

  @override
  State<MultiMatchQuestionsView> createState() =>
      _MultiMatchQuestionsViewState();
}

class _MultiMatchQuestionsViewState extends State<MultiMatchQuestionsView> {
  Widget _buildQuestionCard(MultiMatchQuestion question) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F1FF),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.lightbulb_outline,
              color: Color(0xFF2E6CF6),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              question.question,
              textAlign: TextAlign.start,
              style: GoogleFonts.nunito(
                textStyle: TextStyle(
                  height: 1.2,
                  color: Theme.of(context).colorScheme.onTertiary,
                  fontSize: context
                      .read<SettingsCubit>()
                      .getSettings()
                      .playAreaFontSize,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestion(int queIndex, BuildContext context) {
    //if current question index is same as question index means
    //it is current question and will be on top
    //so we need to add animation that slide and fade this question
    if (widget.currQuestionIdx == queIndex) {
      return FadeTransition(
        opacity: widget.questionSlideAnimation.drive(
          Tween<double>(begin: 1, end: 0),
        ),
        child: SlideTransition(
          position: widget.questionSlideAnimation.drive(
            Tween<Offset>(begin: Offset.zero, end: const Offset(-1.5, 0)),
          ),
          child: _buildQuestionContainer(1, queIndex, true, context),
        ),
      );
    }
    //if the question is second or after current question
    //so we need to animation that scale this question
    //initial scale of this question is 0.95
    else if (queIndex > widget.currQuestionIdx &&
        (queIndex == widget.currQuestionIdx + 1)) {
      return AnimatedBuilder(
        animation: widget.questionAnimationController,
        builder: (context, child) {
          final scale =
              0.95 +
              widget.questionScaleUpAnimation.value -
              widget.questionScaleDownAnimation.value;
          return _buildQuestionContainer(scale, queIndex, false, context);
        },
      );
    }
    //to build question except top 2
    else if (queIndex > widget.currQuestionIdx) {
      return _buildQuestionContainer(1, queIndex, false, context);
    }

    //if the question is already animated that show empty container
    return const SizedBox.shrink();
  }

  Widget _buildOptions(
    MultiMatchQuestion question,
    BoxConstraints constraints,
    List<String> correctAnswersIds,
  ) {
    return MultiMatchAnswerOptions(
      answerType: question.answerType,
      answerOptions: question.options,
      submittedAnswerIds: question.submittedIds,
      toggleOptionSelection: widget.toggleOptionSelection,
      hasSubmittedCurrentQuestion: widget.hasSubmittedCurrentQuestion,
      constraints: constraints,
      correctAnswerIds: correctAnswersIds,
      onReorder: widget.onReorder,
    );
  }

  final optionIds = ['a', 'b', 'c', 'd', 'e'];

  late final String _firebaseId = context
      .read<UserDetailsCubit>()
      .getUserFirebaseId();

  Widget _buildQuestionContainer(
    double scale,
    int index,
    bool showContent,
    BuildContext context,
  ) {
    final child = LayoutBuilder(
      builder: (context, constraints) {
        final question = widget.questions[index];

        final hasImage = question.image.isNotEmpty;

        final correctAnswersIds = AnswerEncryption.decryptCorrectAnswers(
          rawKey: _firebaseId,
          correctAnswer: question.correctAnswer,
        );

        final bool isCorrectlyAnswered;
        if (question.answerType == MultiMatchAnswerType.multiSelect) {
          isCorrectlyAnswered =
              correctAnswersIds.length == question.submittedIds.length &&
              correctAnswersIds.toSet().containsAll(
                question.submittedIds.toSet(),
              );
        } else {
          isCorrectlyAnswered = listEquals<String>(
            correctAnswersIds,
            question.submittedIds,
          );
        }

        final updatedOptions = List.generate(
          question.options.length,
          (idx) => MapEntry(optionIds[idx], question.options[idx]),
        );

        final mappedCorrectAnswersIds = correctAnswersIds
            .map((id) => updatedOptions.firstWhere((e) => e.value.id == id).key)
            .toList();

        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),

              /// Question
              _buildQuestionCard(question),

              /// Show Question Answer Correctness
              SizedBox(height: constraints.maxHeight * .02),
              Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: question.hasSubmittedAnswers
                      ? Icon(
                          isCorrectlyAnswered
                              ? Icons.check_rounded
                              : Icons.close_rounded,
                          size: 35,
                          color: Theme.of(context).primaryColor,
                        )
                      : const SizedBox.shrink(),
                ),
              ),
              if (question.hasSubmittedAnswers &&
                  question.answerType == MultiMatchAnswerType.sequence) ...[
                Text.rich(
                  TextSpan(
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onTertiary,
                      fontWeight: FontWeights.bold,
                      fontSize: 16,
                    ),
                    children: [
                      TextSpan(text: context.tr('correctAnswersLbl')),
                      const TextSpan(text: ' : '),
                      TextSpan(
                        text: mappedCorrectAnswersIds
                            .map((e) => e.toUpperCase())
                            .join(', '),
                      ),
                    ],
                  ),
                ),
              ],

              /// Image
              SizedBox(
                height: constraints.maxHeight * (hasImage ? .0175 : .02),
              ),
              if (hasImage)
                Container(
                  width: context.width,
                  height: constraints.maxHeight * 0.325,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: InteractiveViewer(
                    boundaryMargin: const EdgeInsets.all(20),
                    child: CachedNetworkImage(
                      placeholder: (_, _) =>
                          const Center(child: CircularProgressContainer()),
                      imageUrl: question.image,
                      imageBuilder: (context, imageProvider) {
                        return Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        );
                      },
                      errorWidget: (_, i, e) {
                        return Center(
                          child: Icon(
                            Icons.error,
                            color: Theme.of(context).primaryColor,
                          ),
                        );
                      },
                    ),
                  ),
                )
              else
                const SizedBox.shrink(),

              /// Options
              SizedBox(height: constraints.maxHeight * .015),
              _buildOptions(question, constraints, correctAnswersIds),
              const SizedBox(height: 5),
            ],
          ),
        );
      },
    );

    return Container(
      transform: Matrix4.identity()..scaleByDouble(scale, scale, scale, 1),
      transformAlignment: Alignment.center,
      width: context.width * QuizUtils.questionContainerWidthPercentage,
      height:
          context.height *
          (QuizUtils.questionContainerHeightPercentage - 0.045),
      child: showContent
          ? SlideTransition(
              position: widget.questionContentAnimation.drive(
                Tween<Offset>(begin: const Offset(0.5, 0), end: Offset.zero),
              ),
              child: FadeTransition(
                opacity: widget.questionContentAnimation,
                child: child,
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  List<Widget> _buildQuestions(BuildContext context) {
    final children = <Widget>[];

    for (var i = 0; i < widget.questions.length; ++i) {
      children.add(_buildQuestion(i, context));
    }

    return children.reversed.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: _buildQuestions(context),
    );
  }
}

class MultiMatchAnswerOptions extends StatefulWidget {
  const MultiMatchAnswerOptions({
    required this.answerOptions,
    required this.submittedAnswerIds,
    required this.toggleOptionSelection,
    required this.hasSubmittedCurrentQuestion,
    required this.constraints,
    required this.correctAnswerIds,
    required this.answerType,
    required this.onReorder,
    super.key,
  });

  final List<AnswerOption> answerOptions;
  final List<String> submittedAnswerIds;
  final List<String> correctAnswerIds;
  final BoxConstraints constraints;
  final MultiMatchAnswerType answerType;

  final bool Function() hasSubmittedCurrentQuestion;
  final void Function(String) toggleOptionSelection;

  final void Function(List<String> selectedOptionsIds) onReorder;

  @override
  State<MultiMatchAnswerOptions> createState() =>
      _MultiMatchAnswerOptionsState();
}

class _MultiMatchAnswerOptionsState extends State<MultiMatchAnswerOptions> {
  late final _audioPlayer = AudioPlayer();

  Future<void> playSound(String trackName) async {
    if (context.read<SettingsCubit>().getSettings().sound) {
      if (_audioPlayer.playing) {
        await _audioPlayer.stop();
      }
      await _audioPlayer.setAsset(trackName);
      await _audioPlayer.play();
    }
  }

  Future<void> playVibrate() async {
    if (context.read<SettingsCubit>().getSettings().vibration) {
      UiUtils.vibrate();
    }
  }

  /// ---

  bool isCurrOptionInAnswers(String id) => widget.correctAnswerIds.contains(id);

  bool isCurrOptionSubmitted(String id) =>
      widget.submittedAnswerIds.contains(id);

  Color _optionBorderColor(bool isOptionSubmitted) => isOptionSubmitted
      ? Theme.of(context).colorScheme.onTertiary
      : Theme.of(context).colorScheme.onTertiary.withValues(alpha: 0);

  Color _optionBackgroundColor(bool isOptionCorrect, bool isOptionSubmitted) {
    if (!widget.hasSubmittedCurrentQuestion()) {
      return Colors.white;
    }

    return isOptionCorrect
        ? kCorrectAnswerColor
        : isOptionSubmitted
        ? kWrongAnswerColor
        : Colors.white;
  }

  Color _optionTextColor(bool isOptionCorrect, bool isOptionSubmitted) {
    if (!widget.hasSubmittedCurrentQuestion()) {
      return Theme.of(context).colorScheme.onTertiary;
    } else {
      if (isOptionCorrect || isOptionSubmitted) {
        return Theme.of(context).colorScheme.surface;
      }
      return Theme.of(context).colorScheme.onTertiary;
    }
  }

  void _onTapOption(String id) {
    if (widget.hasSubmittedCurrentQuestion()) return;

    widget.toggleOptionSelection(id);

    playSound(Assets.sfxClickEvent);
    playVibrate();
  }

  late final margin = EdgeInsets.only(
    bottom: widget.constraints.maxHeight * .015,
  );

  late final List<MapEntry<String, AnswerOption>> updatedOptions =
      List.generate(
        widget.answerOptions.length,
        (idx) => MapEntry(optionIds[idx], widget.answerOptions[idx]),
      );

  final optionIds = ['a', 'b', 'c', 'd', 'e'];

  @override
  Widget build(BuildContext context) {
    if (widget.answerType == MultiMatchAnswerType.sequence) {
      Widget proxyDecorator(
        Widget child,
        int index,
        Animation<double> animation,
      ) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            final animValue = Curves.easeOut.transform(animation.value);
            final scale = lerpDouble(1, 1.02, animValue)!;

            return Transform.scale(scale: scale, child: child);
          },
          child: child,
        );
      }

      return IgnorePointer(
        ignoring: widget.hasSubmittedCurrentQuestion(),
        child: ReorderableListView.builder(
          physics: const ClampingScrollPhysics(),
          shrinkWrap: true,
          proxyDecorator: proxyDecorator,
          itemCount: updatedOptions.length,
          dragStartBehavior: DragStartBehavior.down,
          onReorderStart: (idx) {
            HapticFeedback.selectionClick();
            HapticFeedback.vibrate();
          },
          onReorder: (int oldIndex, int newIndex) {
            setState(() {
              if (oldIndex < newIndex) {
                newIndex -= 1;
              }
              final item = updatedOptions.removeAt(oldIndex);
              updatedOptions.insert(newIndex, item);
            });

            final reordered = updatedOptions.map((e) => e.value.id!).toList();
            widget.onReorder(reordered);
          },
          itemBuilder: (context, i) {
            final option = updatedOptions[i];
            final optionValue = option.value;

            final scheme = Theme.of(context).colorScheme;
            return Container(
              key: Key(optionValue.id!),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              margin: margin,
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E6CF6),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      option.key.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      optionValue.title!,
                      style: TextStyle(
                        color: scheme.onTertiary,
                        fontSize: context
                            .read<SettingsCubit>()
                            .getSettings()
                            .playAreaFontSize,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  ReorderableDragStartListener(
                    enabled: !widget.hasSubmittedCurrentQuestion(),
                    key: ValueKey<String>(optionValue.id!),
                    index: i,
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: Icon(
                        Icons.drag_handle_rounded,
                        color: scheme.onTertiary.withValues(alpha: .5),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: widget.answerOptions
            .map((option) {
              final isOptionCorrect = isCurrOptionInAnswers(option.id!);
              final isOptionSubmitted = isCurrOptionSubmitted(option.id!);

              final icon = switch ((isOptionCorrect, isOptionSubmitted)) {
                (true, true) => Icons.check_rounded,
                (true, false) => Icons.close_rounded,
                (false, true) => Icons.close_rounded,
                _ => null,
              };

              final optionLabel = updatedOptions
                  .firstWhere((e) => e.value.id == option.id)
                  .key;

              return GestureDetector(
                onTap: () => _onTapOption(option.id!),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: _optionBorderColor(isOptionSubmitted),
                      width: 1.5,
                    ),
                    color: _optionBackgroundColor(
                      isOptionCorrect,
                      isOptionSubmitted,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 16,
                  ),
                  margin: option.id == widget.answerOptions.last.id
                      ? null
                      : margin,
                  child: Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E6CF6),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          optionLabel.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          option.title!,
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontSize: context
                                .read<SettingsCubit>()
                                .getSettings()
                                .playAreaFontSize,
                            color: _optionTextColor(
                              isOptionCorrect,
                              isOptionSubmitted,
                            ),
                          ),
                        ),
                      ),
                      if (widget.hasSubmittedCurrentQuestion() && icon != null)
                        Icon(
                          icon,
                          color: Theme.of(context).primaryColor,
                          size: 22,
                        ),
                    ],
                  ),
                ),
              );
            })
            .toList(growable: false),
      );
    }
  }
}
