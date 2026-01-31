import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/commons/commons.dart';
import 'package:flutterquiz/core/core.dart';
import 'package:flutterquiz/features/auth/cubits/auth_cubit.dart';
import 'package:flutterquiz/features/quiz/models/quiz_type.dart';
import 'package:flutterquiz/features/system_config/cubits/system_config_cubit.dart';
import 'package:flutterquiz/ui/screens/home/widgets/quiz_grid_card.dart';
import 'package:flutterquiz/ui/screens/quiz/category_screen.dart';
import 'package:flutterquiz/ui/widgets/all.dart';
import 'package:google_fonts/google_fonts.dart';

final class PlayZoneTabScreen extends StatefulWidget {
  const PlayZoneTabScreen({super.key});

  @override
  State<PlayZoneTabScreen> createState() => PlayZoneTabScreenState();
}

final class PlayZoneTabScreenState extends State<PlayZoneTabScreen>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  final _scrollController = ScrollController();

  final _playZones = <Zone>[];
  final List<AnimationController> _controllers = [];
  final List<Animation<double>> _scaleAnimations = [];
  final List<Animation<double>> _opacityAnimations = [];

  @override
  void initState() {
    super.initState();
    _initializePlayZones();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    const animDuration = Duration(milliseconds: 350);
    const staggerDelay = 60;

    for (var i = 0; i < _playZones.length; i++) {
      final controller = AnimationController(
        duration: animDuration,
        vsync: this,
      );
      final curve = CurvedAnimation(
        parent: controller,
        curve: Curves.easeOutBack,
      );

      _controllers.add(controller);
      _scaleAnimations.add(Tween<double>(begin: .7, end: 1).animate(curve));
      _opacityAnimations.add(Tween<double>(begin: 0, end: 1).animate(curve));

      Future.delayed(
        Duration(milliseconds: staggerDelay * i),
        controller.forward,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void onTapTab() {
    if (_scrollController.hasClients && _scrollController.offset != 0) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
    }
  }

  void _initializePlayZones() {
    final config = context.read<SystemConfigCubit>();

    _playZones.addAll([
      if (config.isDailyQuizEnabled)
        (
          type: QuizTypes.dailyQuiz,
          title: 'dailyQuiz',
          img: Assets.dailyQuizIcon,
          desc: 'desDailyQuiz',
        ),
      if (config.isFunNLearnEnabled)
        (
          type: QuizTypes.funAndLearn,
          title: 'funAndLearn',
          img: Assets.funNLearnIcon,
          desc: 'desFunAndLearn',
        ),
      if (config.isGuessTheWordEnabled)
        (
          type: QuizTypes.guessTheWord,
          title: 'guessTheWord',
          img: Assets.guessTheWordIcon,
          desc: 'desGuessTheWord',
        ),
      if (config.isAudioQuizEnabled)
        (
          type: QuizTypes.audioQuestions,
          title: 'audioQuestions',
          img: Assets.audioQuizIcon,
          desc: 'desAudioQuestions',
        ),
      if (config.isMathQuizEnabled)
        (
          type: QuizTypes.mathMania,
          title: 'mathMania',
          img: Assets.mathsQuizIcon,
          desc: 'desMathMania',
        ),
      if (config.isTrueFalseQuizEnabled)
        (
          type: QuizTypes.trueAndFalse,
          title: 'truefalse',
          img: Assets.trueFalseQuizIcon,
          desc: 'desTrueFalse',
        ),
      if (config.isMultiMatchQuizEnabled)
        (
          type: QuizTypes.multiMatch,
          title: 'multiMatch',
          img: Assets.multiMatchIcon,
          desc: 'desMultiMatch',
        ),
    ]);
  }

  void _onTapQuiz(QuizTypes type) {
    // Check if the user is a guest, Show login required dialog for guest users
    if (context.read<AuthCubit>().isGuest) {
      showLoginRequiredDialog(context);
      return;
    }

    if (type case QuizTypes.dailyQuiz || QuizTypes.trueAndFalse) {
      // Daily Quiz and True/False Quiz navigate directly to quiz screen
      Navigator.of(
        globalCtx,
      ).pushNamed(Routes.quiz, arguments: {'quizType': type});
    } else {
      /// Other quiz types (FunAndLearn, GuessTheWord, AudioQuestions, etc)
      /// navigate to category selection screen first.
      globalCtx.pushNamed(
        Routes.category,
        arguments: CategoryScreenArgs(quizType: type),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: Stack(
        children: [
          // Blue gradient header background
          Container(
            height: 280,
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
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(20),
                        child: GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          mainAxisSpacing: 20,
                          crossAxisSpacing: 20,
                          physics: const NeverScrollableScrollPhysics(),
                          children: List.generate(
                            _playZones.length,
                            (index) {
                              final zone = _playZones[index];
                              return FadeTransition(
                                opacity: _opacityAnimations[index],
                                child: ScaleTransition(
                                  scale: _scaleAnimations[index],
                                  child: QuizGridCard(
                                    onTap: () => _onTapQuiz(zone.type),
                                    title: context.tr(zone.title)!,
                                    desc: context.tr(zone.desc)!,
                                    img: zone.img,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
                  Icons.sports_esports_rounded,
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
            context.tr('playZone')!,
            style: GoogleFonts.nunito(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          // Subtitle
          Text(
            'Choose your favorite quiz mode and start playing',
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
