import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterquiz/core/routes/routes.dart';
import 'package:flutterquiz/utils/extensions.dart';

class FeatureShowcaseScreen extends StatelessWidget {
  const FeatureShowcaseScreen({super.key});

  static Route<dynamic> route() => CupertinoPageRoute(
        builder: (_) => const FeatureShowcaseScreen(),
      );

  @override
  Widget build(BuildContext context) {
    final items = <({String title, String desc})>[
      (title: '13 Quiz Types', desc: 'Play classic, audio, math, contest and more.'),
      (title: 'Real-time Battles', desc: '1v1 and group play with friends.'),
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
        child: ElevatedButton(
          onPressed: () => context.pushReplacementNamed(Routes.home),
          child: const Text('Get Started'),
        ),
      ),
    );
  }
}
