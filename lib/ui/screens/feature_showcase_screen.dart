import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/core/routes/routes.dart';
import 'package:flutterquiz/features/system_config/cubits/system_config_cubit.dart';

class FeatureShowcaseScreen extends StatelessWidget {
  const FeatureShowcaseScreen({super.key});

  static Route<dynamic> route() => CupertinoPageRoute(
    builder: (_) => const FeatureShowcaseScreen(),
  );

  @override
  Widget build(BuildContext context) {
    final sys = context.read<SystemConfigCubit>();
    final contestEnabled = sys.isContestEnabled;
    final battlesEnabled =
        sys.isOneVsOneBattleEnabled ||
        sys.isGroupBattleEnabled ||
        sys.isRandomBattleEnabled;

    final items = <({String title, String desc})>[
      (
        title: 'Quiz Variety',
        desc:
            'Play classic, audio, math' +
            (contestEnabled ? ', contest' : '') +
            ' and more.',
      ),
      if (battlesEnabled)
        (
          title: 'Real-time Battles',
          desc: '1v1 and group play with friends.',
        ),
      (
        title: 'Skill-Based Tiers',
        desc: 'Earn your tier with better accuracy.',
      ),
      (title: 'Daily Challenge', desc: 'A fresh category to master daily.'),
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 8),
                Text(
                  'Discover Features',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1F51D9),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Explore what you can do in mQuiz',
                  style: TextStyle(
                    fontSize: 14,
                    color: const Color(0xFF1F51D9).withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (_, i) {
                      final it = items[i];
                      return _GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              it.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1F51D9),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              it.desc,
                              style: TextStyle(
                                fontSize: 14,
                                color: const Color(
                                  0xFF1F51D9,
                                ).withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemCount: items.length,
                  ),
                ),
                SafeArea(
                  top: false,
                  minimum: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _PrimaryGlassButton(
                        title: 'Continue as Guest',
                        onTap: () => Navigator.of(context).pushReplacementNamed(
                          Routes.home,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _SecondaryGlassButton(
                        title: 'Sign In for More Features',
                        onTap: () => Navigator.of(context).pushReplacementNamed(
                          Routes.login,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Positioned.fill(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Color(0xFFEFF6FF),
              Color(0xFFDBEAFF),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  const _GlassCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF1F51D9).withValues(alpha: 0.2),
              width: 1,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 20,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _PrimaryGlassButton extends StatelessWidget {
  const _PrimaryGlassButton({required this.title, required this.onTap});

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 54,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1F51D9), Color(0xFF4A75E8)],
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 20,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _SecondaryGlassButton extends StatelessWidget {
  const _SecondaryGlassButton({required this.title, required this.onTap});

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            width: double.infinity,
            height: 54,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF1F51D9).withValues(alpha: 0.25),
                width: 1,
              ),
            ),
            child: Text(
              title,
              style: TextStyle(
                color: const Color(0xFF1F51D9).withValues(alpha: 0.9),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
