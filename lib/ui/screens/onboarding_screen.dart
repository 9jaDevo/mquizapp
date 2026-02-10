import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/commons/commons.dart';
import 'package:flutterquiz/core/core.dart';
import 'package:flutterquiz/features/settings/settings_cubit.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';
import 'dart:math' as math;

class IntroSliderScreen extends StatefulWidget {
  const IntroSliderScreen({super.key});

  @override
  State<IntroSliderScreen> createState() => _GettingStartedScreenState();

  static Route<dynamic> route() {
    return CupertinoPageRoute(builder: (_) => const IntroSliderScreen());
  }
}

class _GettingStartedScreenState extends State<IntroSliderScreen>
    with TickerProviderStateMixin {
  int sliderIndex = 0;
  late PageController pageController;

  late AnimationController floatingAnimationController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  )..repeat(reverse: true);

  late final List<OnboardingSlide> slideList = [
    OnboardingSlide(
      icon: Icons.bolt,
      title: 'Real-Time Battles',
      description:
          'Challenge friends or compete with players worldwide in electrifying live matches',
      features: [
        FeatureCard(icon: Icons.adjust, label: '1v1 Duels'),
        FeatureCard(icon: Icons.groups, label: 'Group Play'),
        FeatureCard(icon: Icons.leaderboard, label: 'Live\nRankings'),
      ],
      ctaText: 'Continue',
    ),
    OnboardingSlide(
      icon: Icons.emoji_events,
      title: 'Challenge Your Mind',
      description:
          'Compete in thrilling quiz battles across multiple categories and climb to the top',
      features: [
        FeatureCard(icon: Icons.adjust, label: '1000+\nQuestions'),
        FeatureCard(icon: Icons.update, label: 'Daily\nUpdates'),
        FeatureCard(icon: Icons.category, label: 'Multiple\nModes'),
      ],
      ctaText: 'Continue',
    ),
    OnboardingSlide(
      icon: Icons.star,
      title: 'Earn & Win Rewards',
      description:
          'Collect coins, unlock achievements, and redeem exciting prizes as you progress',
      features: [
        FeatureCard(icon: Icons.card_giftcard, label: 'Daily\nBonuses'),
        FeatureCard(icon: Icons.emoji_events_outlined, label: 'Achievements'),
        FeatureCard(icon: Icons.redeem, label: 'Real\nRewards'),
      ],
      ctaText: 'Get Started',
      showFooterHint: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    pageController = PageController();
  }

  @override
  void dispose() {
    floatingAnimationController.dispose();
    pageController.dispose();
    super.dispose();
  }

  void onPageChanged(int index) => setState(() {
    sliderIndex = index;
  });

  void _handleContinue() {
    if (sliderIndex < slideList.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      context.read<SettingsCubit>().changeShowIntroSlider();
      context.pushReplacementNamed(Routes.featureShowcase);
    }
  }

  void _handleSkip() {
    context.read<SettingsCubit>().changeShowIntroSlider();
    context.pushReplacementNamed(Routes.featureShowcase);
  }

  Widget _buildPageIndicator() {
    const primaryColor = Color(0xFF2196F3);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(slideList.length, (index) {
        final isActive = sliderIndex == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          height: 8,
          width: isActive ? 24 : 8,
          decoration: BoxDecoration(
            color: isActive ? primaryColor : primaryColor.withOpacity(0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  Widget _buildFloatingCircles() {
    return Stack(
      children: [
        Positioned(
          top: 100,
          right: 30,
          child: _FloatingCircle(
            size: 60,
            opacity: 0.1,
            animation: floatingAnimationController,
            offset: 10,
          ),
        ),
        Positioned(
          bottom: 200,
          left: 20,
          child: _FloatingCircle(
            size: 40,
            opacity: 0.08,
            animation: floatingAnimationController,
            offset: -15,
          ),
        ),
        Positioned(
          top: 300,
          left: 50,
          child: _FloatingCircle(
            size: 30,
            opacity: 0.12,
            animation: floatingAnimationController,
            offset: 8,
          ),
        ),
        Positioned(
          bottom: 400,
          right: 50,
          child: _FloatingCircle(
            size: 50,
            opacity: 0.09,
            animation: floatingAnimationController,
            offset: -12,
          ),
        ),
      ],
    );
  }

  Widget _buildSlide(OnboardingSlide slide) {
    const primaryColor = Color(0xFF2196F3);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Center icon tile
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              slide.icon,
              size: 60,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 32),

          // Title
          Text(
            slide.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: primaryColor,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),

          // Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              slide.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Feature cards
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: slide.features.map((feature) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Container(
                  width: 100,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        feature.icon,
                        size: 32,
                        color: primaryColor,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        feature.label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF2196F3);
    final currentSlide = slideList[sliderIndex];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFFE3F2FD),
                Colors.white,
              ],
            ),
          ),
          child: Stack(
            children: [
              // Floating circles
              _buildFloatingCircles(),

              // Main content
              SafeArea(
                child: Column(
                  children: [
                    // Top row: Logo + Skip
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Logo button
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                'mQuiz',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                            ),
                          ),

                          // Skip button
                          GestureDetector(
                            onTap: _handleSkip,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                'Skip',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: primaryColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Slide content
                    Expanded(
                      child: PageView.builder(
                        controller: pageController,
                        onPageChanged: onPageChanged,
                        itemCount: slideList.length,
                        itemBuilder: (context, index) {
                          return Center(
                            child: _buildSlide(slideList[index]),
                          );
                        },
                      ),
                    ),

                    // Page indicator
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: _buildPageIndicator(),
                    ),

                    // CTA Button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _handleContinue,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            elevation: 2,
                            shadowColor: primaryColor.withOpacity(0.3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                currentSlide.ctaText,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.chevron_right, size: 24),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Footer hint (only on last slide)
                    SizedBox(
                      height: 50,
                      child: currentSlide.showFooterHint
                          ? Center(
                              child: Text(
                                'Swipe to explore features →',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[400],
                                ),
                              ),
                            )
                          : const SizedBox(),
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
}

// Model classes
class OnboardingSlide {
  final IconData icon;
  final String title;
  final String description;
  final List<FeatureCard> features;
  final String ctaText;
  final bool showFooterHint;

  OnboardingSlide({
    required this.icon,
    required this.title,
    required this.description,
    required this.features,
    required this.ctaText,
    this.showFooterHint = false,
  });
}

class FeatureCard {
  final IconData icon;
  final String label;

  FeatureCard({
    required this.icon,
    required this.label,
  });
}

// Floating circle widget
class _FloatingCircle extends StatelessWidget {
  final double size;
  final double opacity;
  final AnimationController animation;
  final double offset;

  const _FloatingCircle({
    required this.size,
    required this.opacity,
    required this.animation,
    required this.offset,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, offset * animation.value),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(opacity),
            ),
          ),
        );
      },
    );
  }
}
