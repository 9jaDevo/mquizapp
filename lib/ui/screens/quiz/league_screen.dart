import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/commons/commons.dart';
import 'package:flutterquiz/core/core.dart';
import 'package:flutterquiz/features/quiz/cubits/league_action_cubit.dart';
import 'package:flutterquiz/features/quiz/cubits/league_cubit.dart';
import 'package:flutterquiz/features/quiz/models/league.dart';
import 'package:flutterquiz/features/quiz/quiz_repository.dart';
import 'package:flutterquiz/ui/widgets/circular_progress_container.dart';
import 'package:flutterquiz/ui/widgets/custom_back_button.dart';
import 'package:flutterquiz/ui/widgets/error_container.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';

class LeagueScreen extends StatefulWidget {
  const LeagueScreen({super.key});

  @override
  State<LeagueScreen> createState() => _LeagueScreenState();

  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider<LeagueCubit>(
            create: (_) => LeagueCubit(QuizRepository()),
          ),
          BlocProvider<LeagueActionCubit>(
            create: (_) => LeagueActionCubit(QuizRepository()),
          ),
        ],
        child: const LeagueScreen(),
      ),
    );
  }
}

class _LeagueScreenState extends State<LeagueScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    context.read<LeagueCubit>().getLeagues(
      languageId: UiUtils.getCurrentQuizLanguageId(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: 1,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Leagues'),
          leading: const CustomBackButton(),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Past'),
              Tab(text: 'Active'),
              Tab(text: 'Upcoming'),
            ],
          ),
        ),
        body: BlocListener<LeagueActionCubit, LeagueActionState>(
          listener: (context, state) {
            if (state is LeagueActionSuccess) {
              context.showSnack(state.message);
              _load();
            } else if (state is LeagueActionFailure) {
              context.showSnack(state.errorMessage);
            }
          },
          child: BlocBuilder<LeagueCubit, LeagueState>(
            builder: (context, state) {
              if (state is LeagueInitial || state is LeagueProgress) {
                return const Center(child: CircularProgressContainer());
              }
              if (state is LeagueFailure) {
                return ErrorContainer(
                  errorMessage: state.errorMessage,
                  onTapRetry: _load,
                  showErrorImage: true,
                );
              }

              final leagues = (state as LeagueSuccess).leagues;
              return TabBarView(
                children: [
                  _groupList(leagues.past, 'past'),
                  _groupList(leagues.active, 'active'),
                  _groupList(leagues.upcoming, 'upcoming'),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _groupList(LeagueGroup group, String mode) {
    if (group.errorMessage.isNotEmpty || group.items.isEmpty) {
      return Center(
        child: Text(
          group.errorMessage.isNotEmpty ? group.errorMessage : 'No leagues',
        ),
      );
    }

    return ListView.builder(
      itemCount: group.items.length,
      itemBuilder: (_, i) {
        final item = group.items[i];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: ListTile(
            title: Text(item.name ?? 'League'),
            subtitle: Text(
              '${item.startDate ?? ''} - ${item.endDate ?? ''}\n'
              'Entry: ${item.entry ?? '0'} | Participants: ${item.participants ?? '0'}',
            ),
            isThreeLine: true,
            onTap: () {
              Navigator.of(context).pushNamed(
                Routes.leagueDetails,
                arguments: {'league': item},
              );
            },
            trailing: _actionButton(item, mode),
          ),
        );
      },
    );
  }

  Widget _actionButton(LeagueItem item, String mode) {
    final leagueId = item.id ?? '';

    if (mode == 'upcoming') {
      return TextButton(
        onPressed: () => context.read<LeagueActionCubit>().optInLeague(
          leagueId: leagueId,
        ),
        child: const Text('Opt-in'),
      );
    }

    if (mode == 'active') {
      return TextButton(
        onPressed: () => context.read<LeagueActionCubit>().joinLeague(
          leagueId: leagueId,
        ),
        child: const Text('Join'),
      );
    }

    return TextButton(
      onPressed: () {
        Navigator.of(context).pushNamed(
          Routes.leagueLeaderboard,
          arguments: {'leagueId': leagueId},
        );
      },
      child: const Text('Board'),
    );
  }
}
