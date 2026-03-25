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
import 'package:google_fonts/google_fonts.dart';

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
          elevation: 0,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: Text(
            'Leagues',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Theme.of(context).colorScheme.onTertiary,
            ),
          ),
          leading: const CustomBackButton(),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: Theme.of(
                  context,
                ).colorScheme.onTertiary.withValues(alpha: 0.08),
              ),
              child: const TabBar(
                tabAlignment: TabAlignment.fill,
                tabs: [
                  Tab(text: 'Past'),
                  Tab(text: 'Active'),
                  Tab(text: 'Upcoming'),
                ],
              ),
            ),
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
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: group.items.length,
      itemBuilder: (_, i) {
        final item = group.items[i];
        final entryFee = int.tryParse(item.entry ?? '0') ?? 0;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: mode == 'active'
                        ? const [Color(0xFF2563EB), Color(0xFF1D4ED8)]
                        : mode == 'upcoming'
                        ? const [Color(0xFF7C3AED), Color(0xFFA855F7)]
                        : const [Color(0xFF334155), Color(0xFF475569)],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        item.name ?? 'League',
                        style: GoogleFonts.nunito(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.description ?? '',
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withValues(alpha: 0.95),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ends On',
                            style: GoogleFonts.nunito(
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            (item.endDate ?? '').split(' ').first,
                            style: GoogleFonts.nunito(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Entry Fee',
                            style: GoogleFonts.nunito(
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            entryFee == 0
                                ? 'Free'
                                : '$entryFee ${context.tr('coinsLbl') ?? 'Coins'}',
                            style: GoogleFonts.nunito(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _actionButton(item, mode),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _actionButton(LeagueItem item, String mode) {
    final leagueId = item.id ?? '';

    if (mode == 'upcoming') {
      return GestureDetector(
        onTap: () => context.read<LeagueActionCubit>().optInLeague(
          leagueId: leagueId,
        ),
        child: _actionChip('Opt-in', const [
          Color(0xFF7C3AED),
          Color(0xFFA855F7),
        ]),
      );
    }

    if (mode == 'active') {
      return GestureDetector(
        onTap: () => context.read<LeagueActionCubit>().joinLeague(
          leagueId: leagueId,
        ),
        child: _actionChip('Join', const [
          Color(0xFF4A75E8),
          Color(0xFF60A5FA),
        ]),
      );
    }

    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(
          Routes.leagueLeaderboard,
          arguments: {'leagueId': leagueId},
        );
      },
      child: _actionChip('Board', const [Color(0xFF334155), Color(0xFF475569)]),
    );
  }

  Widget _actionChip(String label, List<Color> colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colors.first.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        label,
        style: GoogleFonts.nunito(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}
