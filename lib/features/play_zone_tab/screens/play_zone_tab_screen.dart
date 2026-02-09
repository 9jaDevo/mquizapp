import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/commons/commons.dart';
import 'package:flutterquiz/core/core.dart';
import 'package:flutterquiz/features/auth/cubits/auth_cubit.dart';
import 'package:flutterquiz/features/quiz/models/quiz_type.dart';
import 'package:flutterquiz/features/system_config/cubits/system_config_cubit.dart';
import 'package:flutterquiz/features/quiz_zone_tab/screens/quiz_zone_tab_screen.dart';
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
        arguments: QuizZoneTabScreenArgs(quizType: type),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final dailyZone = _findZone(QuizTypes.dailyQuiz);
    final funLearnZone = _findZone(QuizTypes.funAndLearn);
    final guessWordZone = _findZone(QuizTypes.guessTheWord);
    final trueFalseZone = _findZone(QuizTypes.trueAndFalse);
    final audioZone = _findZone(QuizTypes.audioQuestions);
    final mathZone = _findZone(QuizTypes.mathMania);
    final multiMatchZone = _findZone(QuizTypes.multiMatch);
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: Stack(
        children: [
          // Blue gradient header background
          Container(
            height: 260,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF2F5FEA), Color(0xFF4E7BFF)],
              ),
            ),
            child: Stack(
              children: [
                // Decorative circle
                Positioned(
                  top: -60,
                  right: -60,
                  child: Container(
                    width: 210,
                    height: 210,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -80,
                  left: -40,
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.08),
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
                // Content area with rounded top
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFF6F7FB),
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
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (dailyZone != null)
                              _buildFeaturedDailyQuiz(context, dailyZone),
                            if (dailyZone != null) const SizedBox(height: 24),
                            if (funLearnZone != null ||
                                guessWordZone != null ||
                                trueFalseZone != null)
                              _buildSectionTitle(
                                context,
                                icon: Icons.sports_esports_rounded,
                                title: 'Classic Games',
                              ),
                            if (funLearnZone != null ||
                                guessWordZone != null ||
                                trueFalseZone != null)
                              const SizedBox(height: 12),
                            if (funLearnZone != null)
                              _buildClassicCard(
                                context,
                                zone: funLearnZone,
                                accent: const Color(0xFFF59E0B),
                                pillText: 'Educational',
                                index: 0,
                              ),
                            if (funLearnZone != null) const SizedBox(height: 12),
                            if (guessWordZone != null)
                              _buildClassicCard(
                                context,
                                zone: guessWordZone,
                                accent: const Color(0xFF3B82F6),
                                pillText: 'Vocabulary',
                                index: 1,
                              ),
                            if (guessWordZone != null) const SizedBox(height: 12),
                            if (trueFalseZone != null)
                              _buildClassicCard(
                                context,
                                zone: trueFalseZone,
                                accent: const Color(0xFFF97316),
                                pillText: 'Quick Play',
                                index: 2,
                              ),
                            if (trueFalseZone != null) const SizedBox(height: 24),
                            if (audioZone != null || mathZone != null)
                              _buildSectionTitle(
                                context,
                                icon: Icons.auto_awesome_rounded,
                                title: 'Special Modes',
                              ),
                            if (audioZone != null || mathZone != null)
                              const SizedBox(height: 12),
                            if (audioZone != null || mathZone != null)
                              Row(
                                children: [
                                  if (audioZone != null)
                                    Expanded(
                                      child: _buildSpecialTile(
                                        context,
                                        zone: audioZone,
                                        accent: const Color(0xFF3B82F6),
                                        subtitle: 'Quiz with audio',
                                        index: 3,
                                      ),
                                    ),
                                  if (audioZone != null && mathZone != null)
                                    const SizedBox(width: 12),
                                  if (mathZone != null)
                                    Expanded(
                                      child: _buildSpecialTile(
                                        context,
                                        zone: mathZone,
                                        accent: const Color(0xFFF59E0B),
                                        subtitle: "It's math quiz",
                                        index: 4,
                                      ),
                                    ),
                                ],
                              ),
                            if (audioZone != null || mathZone != null)
                              const SizedBox(height: 20),
                            if (multiMatchZone != null)
                              _buildMultiMatchPro(context, multiMatchZone),
                          ],
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
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      child: Column(
        children: [
          // Logo/Icon row
          Row(
            children: [
              const SizedBox(width: 44), // Balance for space
              const Spacer(),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.sports_esports_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const Spacer(),
              const SizedBox(width: 44), // Balance for back button
            ],
          ),
          const SizedBox(height: 12),
          // Title
          Text(
            context.tr('playZone')!,
            style: GoogleFonts.nunito(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
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

  Zone? _findZone(QuizTypes type) {
    for (final zone in _playZones) {
      if (zone.type == type) {
        return zone;
      }
    }
    return null;
  }

  IconData _iconForZone(QuizTypes type) {
    return switch (type) {
      QuizTypes.dailyQuiz => Icons.bolt_rounded,
      QuizTypes.funAndLearn => Icons.auto_stories_rounded,
      QuizTypes.guessTheWord => Icons.chat_bubble_rounded,
      QuizTypes.trueAndFalse => Icons.flash_on_rounded,
      QuizTypes.audioQuestions => Icons.headphones_rounded,
      QuizTypes.mathMania => Icons.calculate_rounded,
      QuizTypes.multiMatch => Icons.layers_rounded,
      _ => Icons.quiz_rounded,
    };
  }

  Widget _buildSectionTitle(
    BuildContext context, {
    required IconData icon,
    required String title,
  }) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF1E4FD9), size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.nunito(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1E4FD9),
          ),
        ),
      ],
    );
  }

  Widget _wrapAnimated(int index, Widget child) {
    if (index >= _opacityAnimations.length || index >= _scaleAnimations.length) {
      return child;
    }

    return FadeTransition(
      opacity: _opacityAnimations[index],
      child: ScaleTransition(
        scale: _scaleAnimations[index],
        child: child,
      ),
    );
  }

  Widget _buildFeaturedDailyQuiz(BuildContext context, Zone zone) {
    return _wrapAnimated(
      0,
      GestureDetector(
        onTap: () => _onTapQuiz(zone.type),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 36,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6C343),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star_border_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'FEATURED',
                          style: GoogleFonts.nunito(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                height: 130,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF3B6AFB), Color(0xFF5A86FF)],
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 78,
                    height: 78,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25),
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        _iconForZone(zone.type),
                        size: 34,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr(zone.title)!,
                      style: GoogleFonts.nunito(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1E4FD9),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      context.tr(zone.desc)!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF7E8AA8),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.tr('questions')!,
                              style: GoogleFonts.nunito(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF9AA7C0),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '10',
                              style: GoogleFonts.nunito(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Reward',
                              style: GoogleFonts.nunito(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF9AA7C0),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '+50',
                              style: GoogleFonts.nunito(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: () => _onTapQuiz(zone.type),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E5BEA),
                            elevation: 6,
                            shadowColor: Colors.black.withValues(alpha: 0.2),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(
                                'Play Now',
                                style: GoogleFonts.nunito(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                size: 16,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClassicCard(
    BuildContext context, {
    required Zone zone,
    required Color accent,
    required String pillText,
    required int index,
  }) {
    return _wrapAnimated(
      index,
      GestureDetector(
        onTap: () => _onTapQuiz(zone.type),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Icon(
                    _iconForZone(zone.type),
                    size: 24,
                    color: accent,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr(zone.title)!,
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E4FD9),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.tr(zone.desc)!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF7E8AA8),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        pillText,
                        style: GoogleFonts.nunito(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: accent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: const Color(0xFF94A3B8),
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpecialTile(
    BuildContext context, {
    required Zone zone,
    required Color accent,
    required String subtitle,
    required int index,
  }) {
    return _wrapAnimated(
      index,
      GestureDetector(
        onTap: () => _onTapQuiz(zone.type),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Icon(
                    _iconForZone(zone.type),
                    size: 24,
                    color: accent,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                context.tr(zone.title)!,
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: accent,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF7E8AA8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMultiMatchPro(BuildContext context, Zone zone) {
    return _wrapAnimated(
      5,
      GestureDetector(
        onTap: () => _onTapQuiz(zone.type),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 22,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.layers_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          context.tr(zone.title)!,
                          style: GoogleFonts.nunito(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE9D5FF),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'PRO',
                            style: GoogleFonts.nunito(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF7C3AED),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Mix of multi-select and sequencing quiz type',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF7E8AA8),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.music_note_rounded,
                          size: 14,
                          color: Color(0xFF64748B),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Advanced difficulty level',
                          style: GoogleFonts.nunito(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_rounded,
                color: const Color(0xFF94A3B8),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
