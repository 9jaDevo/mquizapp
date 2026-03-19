import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/quiz/cubits/league_leaderboard_cubit.dart';
import 'package:flutterquiz/features/quiz/quiz_repository.dart';
import 'package:flutterquiz/ui/widgets/circular_progress_container.dart';
import 'package:flutterquiz/ui/widgets/custom_appbar.dart';

class LeagueLeaderboardScreen extends StatefulWidget {
  const LeagueLeaderboardScreen({super.key, this.leagueId});

  final String? leagueId;

  static Route<dynamic> route(RouteSettings routeSettings) {
    final args = routeSettings.arguments as Map?;
    return CupertinoPageRoute(
      builder: (_) => BlocProvider(
        create: (_) => LeagueLeaderboardCubit(QuizRepository()),
        child: LeagueLeaderboardScreen(leagueId: args?['leagueId'] as String?),
      ),
    );
  }

  @override
  State<LeagueLeaderboardScreen> createState() => _LeagueLeaderboardScreenState();
}

class _LeagueLeaderboardScreenState extends State<LeagueLeaderboardScreen> {
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
    context.read<LeagueLeaderboardCubit>().getLeaderboard(widget.leagueId ?? '');
  }

  void _onScroll() {
    if (_controller.position.maxScrollExtent == _controller.offset) {
      context.read<LeagueLeaderboardCubit>().getMore(widget.leagueId ?? '');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: QAppBar(title: const Text('League Leaderboard')),
      body: BlocBuilder<LeagueLeaderboardCubit, LeagueLeaderboardState>(
        builder: (context, state) {
          if (state is LeagueLeaderboardInitial ||
              state is LeagueLeaderboardProgress) {
            return const Center(child: CircularProgressContainer());
          }
          if (state is LeagueLeaderboardFailure) {
            return Center(child: Text(state.errorMessage));
          }

          final data = state as LeagueLeaderboardSuccess;
          return Column(
            children: [
              if (data.topThree.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    'Top 3: ${data.topThree.map((e) => e.name ?? '').join(', ')}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              Expanded(
                child: ListView.separated(
                  controller: _controller,
                  itemCount: data.rows.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final r = data.rows[i];
                    return ListTile(
                      leading: Text(r.userRank ?? '-'),
                      title: Text(r.name ?? 'User'),
                      trailing: Text(r.score ?? '0'),
                    );
                  },
                ),
              ),
              if (data.myRank != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: Text('My Rank: ${data.myRank} | Score: ${data.myScore ?? '0'}'),
                ),
            ],
          );
        },
      ),
    );
  }
}
