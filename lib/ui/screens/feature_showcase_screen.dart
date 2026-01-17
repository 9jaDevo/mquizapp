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
    final battlesEnabled = sys.isOneVsOneBattleEnabled ||
        sys.isGroupBattleEnabled ||
        sys.isRandomBattleEnabled;

    final items = <({String title, String desc})>[
      (
        title: 'Quiz Variety',
        desc: 'Play classic, audio, math' +
            (contestEnabled ? ', contest' : '') +
            ' and more.',
      ),
      if (battlesEnabled)
        (
          title: 'Real-time Battles',
          desc: '1v1 and group play with friends.',
        ),
      (title: 'Skill-Based Tiers', desc: 'Earn your tier with better accuracy.'),
      (title: 'Daily Challenge', desc: 'A fresh category to master daily.'),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Discover Features')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemBuilder: (_, i) {
          final it = items[i];
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  it.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onTertiary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  it.desc,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onTertiary.withValues(alpha: .7),
                  ),
                ),
              ],
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemCount: items.length,
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Primary CTA: Continue as Guest
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pushReplacementNamed(Routes.home),
                child: const Text('Continue as Guest'),
              ),
            ),
            const SizedBox(height: 12),
            // Secondary CTA: Sign In
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pushReplacementNamed(Routes.login),
                child: const Text('Sign In for More Features'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
