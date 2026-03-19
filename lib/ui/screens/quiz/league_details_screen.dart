import 'package:flutter/material.dart';
import 'package:flutterquiz/core/core.dart';
import 'package:flutterquiz/features/quiz/models/league.dart';

class LeagueDetailsScreen extends StatelessWidget {
  const LeagueDetailsScreen({super.key, required this.league});

  final LeagueItem league;

  static Route<dynamic> route(RouteSettings routeSettings) {
    final args = routeSettings.arguments as Map;
    return MaterialPageRoute(
      builder: (_) => LeagueDetailsScreen(
        league: args['league'] as LeagueItem,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final id = league.id ?? '';
    return Scaffold(
      appBar: AppBar(title: Text(league.name ?? 'League')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(league.description ?? 'No description'),
            const SizedBox(height: 12),
            Text('Start: ${league.startDate ?? '-'}'),
            Text('End: ${league.endDate ?? '-'}'),
            Text('Entry: ${league.entry ?? '0'}'),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      Routes.leagueDailyQuiz,
                      arguments: {'leagueId': id},
                    );
                  },
                  child: const Text('Daily Quiz'),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      Routes.leagueLeaderboard,
                      arguments: {'leagueId': id},
                    );
                  },
                  child: const Text('Leaderboard'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
