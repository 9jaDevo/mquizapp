import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mquiz/core/constants/app_constants.dart';
import 'package:mquiz/core/theme/app_colors.dart';
import 'package:mquiz/features/auth/cubit/auth_cubit.dart';
import 'package:mquiz/features/auth/screens/login_screen.dart';
import 'package:mquiz/features/auth/screens/otp_screen.dart';
import 'package:mquiz/features/auth/screens/profile_setup_screen.dart';
import 'package:mquiz/features/auth/screens/splash_screen.dart';
import 'package:mquiz/features/bookmarks/screens/bookmarks_screen.dart';
import 'package:mquiz/features/contests/screens/contests_list_screen.dart';
import 'package:mquiz/features/home/screens/home_screen.dart';
import 'package:mquiz/features/leaderboard/screens/leaderboard_screen.dart';
import 'package:mquiz/features/leagues/screens/league_detail_screen.dart';
import 'package:mquiz/features/leagues/screens/leagues_list_screen.dart';
import 'package:mquiz/features/lives/screens/booster_store_screen.dart';
import 'package:mquiz/features/notifications/screens/notifications_screen.dart';
import 'package:mquiz/features/profile/screens/coin_history_screen.dart';
import 'package:mquiz/features/profile/screens/edit_profile_screen.dart';
import 'package:mquiz/features/profile/screens/profile_screen.dart';
import 'package:mquiz/features/progress/screens/progress_map_screen.dart';
import 'package:mquiz/features/quiz/screens/quiz_result_screen.dart';
import 'package:mquiz/features/quiz/screens/quiz_screen.dart';
import 'package:mquiz/features/quiz/screens/subcategories_screen.dart';
import 'package:mquiz/features/battle/screens/battle_result_screen.dart';
import 'package:mquiz/features/battle/screens/find_opponent_screen.dart';
import 'package:mquiz/features/battle/screens/live_battle_screen.dart';
import 'package:mquiz/features/contests/screens/contest_detail_screen.dart';
import 'package:mquiz/features/contests/screens/contest_quiz_screen.dart';
import 'package:mquiz/features/contests/models/contest_model.dart';
import 'package:mquiz/features/leagues/screens/league_quiz_screen.dart';
import 'package:mquiz/features/quiz/screens/session_result_screen.dart';
import 'package:mquiz/features/settings/screens/settings_screen.dart';
import 'package:mquiz/features/store/screens/coin_store_screen.dart';
import 'package:mquiz/features/partner_contests/cubit/partner_contest_list_cubit.dart';
import 'package:mquiz/features/partner_contests/data/partner_contest_repository.dart';
import 'package:mquiz/features/partner_contests/models/partner_contest.dart';
import 'package:mquiz/features/partner_contests/screens/partner_contest_detail_screen.dart';
import 'package:mquiz/features/partner_contests/screens/partner_contest_leaderboard_screen.dart';
import 'package:mquiz/features/partner_contests/screens/partner_contest_list_screen.dart';
import 'package:mquiz/features/partner_contests/screens/partner_contest_quiz_screen.dart';
import 'package:mquiz/features/partner_contests/screens/partner_join_code_screen.dart';

class AppRouter {
  AppRouter._();

  static GoRouter create(AuthCubit authCubit) {
    return GoRouter(
      initialLocation: AppConstants.routeSplash,
      refreshListenable: _AuthListenable(authCubit),
      redirect: (context, state) => _redirect(authCubit, state),
      routes: [
        GoRoute(
          path: AppConstants.routeSplash,
          builder: (ctx, _) => const SplashScreen(),
        ),
        GoRoute(
          path: AppConstants.routeLogin,
          builder: (ctx, _) => const LoginScreen(),
        ),
        GoRoute(
          path: AppConstants.routeOtp,
          builder: (ctx, state) {
            final extra = state.extra as Map<String, String>?;
            return OtpScreen(
              verificationId: extra?['verificationId'] ?? '',
              phoneNumber: extra?['phoneNumber'] ?? '',
            );
          },
        ),
        GoRoute(
          path: AppConstants.routeProfileSetup,
          builder: (ctx, _) => const ProfileSetupScreen(),
        ),
        // ── Quiz flow (outside bottom nav) ──────────────────────────────────
        GoRoute(
          path: AppConstants.routeSubcategories,
          builder: (ctx, state) {
            final idStr = state.pathParameters['categoryId'] ?? '0';
            final categoryId = int.tryParse(idStr) ?? 0;
            final name = state.extra is String ? state.extra as String : '';
            return SubcategoriesScreen(
              categoryId: categoryId,
              categoryName: name,
            );
          },
        ),
        GoRoute(
          path: AppConstants.routeQuiz,
          builder: (ctx, _) => const QuizScreen(),
        ),
        GoRoute(
          path: AppConstants.routeQuizResult,
          builder: (ctx, _) => const QuizResultScreen(),
        ),
        GoRoute(
          path: AppConstants.routeBoosters,
          builder: (ctx, _) => const BoosterStoreScreen(),
        ),
        GoRoute(
          path: AppConstants.routeCoinStore,
          builder: (ctx, _) => const CoinStoreScreen(),
        ),
        GoRoute(
          path: AppConstants.routeLeagueDetail,
          builder: (ctx, state) {
            final id =
                int.tryParse(state.pathParameters['leagueId'] ?? '0') ?? 0;
            return LeagueDetailScreen(leagueId: id);
          },
        ),
        GoRoute(
          path: AppConstants.routeLeagueQuiz,
          builder: (ctx, state) {
            final id =
                int.tryParse(state.pathParameters['leagueId'] ?? '0') ?? 0;
            final name = state.extra is String ? state.extra as String : null;
            return LeagueQuizScreen(leagueId: id, leagueName: name);
          },
        ),
        GoRoute(
          path: AppConstants.routeContestDetail,
          builder: (ctx, state) {
            // Support both object-passing (normal navigation) and deep-link
            // (extra == null). When arriving via deep link, the screen fetches
            // its own data using the contestId path parameter.
            final contest = state.extra as Contest?;
            final id =
                int.tryParse(state.pathParameters['contestId'] ?? '0') ?? 0;
            return ContestDetailScreen(contest: contest, contestId: id);
          },
        ),
        GoRoute(
          path: AppConstants.routeContestPlay,
          builder: (ctx, state) {
            final id =
                int.tryParse(state.pathParameters['contestId'] ?? '0') ?? 0;
            final name = state.extra is Contest
                ? (state.extra as Contest).name
                : null;
            return ContestQuizScreen(contestId: id, contestName: name);
          },
        ),
        // ── Partner Contests ────────────────────────────────────────────────
        GoRoute(
          path: AppConstants.routePartnerContests,
          builder: (ctx, _) => MultiBlocProvider(
            providers: [
              BlocProvider(
                  create: (_) => PartnerContestListCubit(PartnerContestRepository())),
            ],
            child: const PartnerContestListScreen(),
          ),
        ),
        GoRoute(
          path: AppConstants.routePartnerContestJoinCode,
          builder: (ctx, _) => BlocProvider(
            create: (_) => PartnerJoinCodeCubit(PartnerContestRepository()),
            child: const PartnerJoinCodeScreen(),
          ),
        ),
        GoRoute(
          path: AppConstants.routePartnerContestDetail,
          builder: (ctx, state) {
            final id =
                int.tryParse(state.pathParameters[AppConstants.paramPartnerContestId] ?? '0') ?? 0;
            final contest = state.extra as PartnerContest?;
            return MultiBlocProvider(
              providers: [
                BlocProvider(
                    create: (_) => PartnerContestDetailCubit(PartnerContestRepository())),
              ],
              child: PartnerContestDetailScreen(contestId: id, contest: contest),
            );
          },
        ),
        GoRoute(
          path: AppConstants.routePartnerContestPlay,
          builder: (ctx, state) {
            final id =
                int.tryParse(state.pathParameters[AppConstants.paramPartnerContestId] ?? '0') ?? 0;
            final contest = state.extra as PartnerContest?;
            return RepositoryProvider(
              create: (_) => PartnerContestRepository(),
              child: PartnerContestQuizScreen(contestId: id, contest: contest),
            );
          },
        ),
        GoRoute(
          path: AppConstants.routePartnerContestLeaderboard,
          builder: (ctx, state) {
            final id =
                int.tryParse(state.pathParameters[AppConstants.paramPartnerContestId] ?? '0') ?? 0;
            return BlocProvider(
              create: (_) => PartnerContestDetailCubit(PartnerContestRepository()),
              child: PartnerContestLeaderboardScreen(contestId: id),
            );
          },
        ),
        GoRoute(
          path: AppConstants.routeSessionResult,
          builder: (ctx, _) => const SessionResultScreen(),
        ),
        GoRoute(
          path: AppConstants.routeBattle,
          builder: (ctx, _) => const FindOpponentScreen(),
        ),
        GoRoute(
          path: AppConstants.routeBattleLive,
          builder: (ctx, _) => const LiveBattleScreen(),
        ),
        GoRoute(
          path: AppConstants.routeBattleResult,
          builder: (ctx, _) => const BattleResultScreen(),
        ),
        // ── Authenticated shell with bottom nav ─────────────────────────────
        ShellRoute(
          builder: (ctx, state, child) =>
              MainShell(location: state.uri.path, child: child),
          routes: [
            GoRoute(
              path: AppConstants.routeHome,
              builder: (ctx, _) => const HomeScreen(),
            ),
            GoRoute(
              path: AppConstants.routeLeagues,
              builder: (ctx, _) => const LeaguesListScreen(),
            ),
            GoRoute(
              path: AppConstants.routeContests,
              builder: (ctx, _) => const ContestsListScreen(),
            ),
            GoRoute(
              path: AppConstants.routeProgressMap,
              builder: (ctx, _) => const ProgressMapScreen(),
            ),
            GoRoute(
              path: AppConstants.routeLeaderboard,
              builder: (ctx, _) => const LeaderboardScreen(),
            ),
            GoRoute(
              path: AppConstants.routeProfile,
              builder: (ctx, _) => const ProfileScreen(),
              routes: [
                GoRoute(
                  path: 'edit',
                  builder: (ctx, _) => const EditProfileScreen(),
                ),
                GoRoute(
                  path: 'coin-history',
                  builder: (ctx, _) => const CoinHistoryScreen(),
                ),
              ],
            ),
            GoRoute(
              path: AppConstants.routeNotifications,
              builder: (ctx, _) => const NotificationsScreen(),
            ),
            GoRoute(
              path: AppConstants.routeSettings,
              builder: (ctx, _) => const SettingsScreen(),
            ),
            GoRoute(
              path: AppConstants.routeBookmarks,
              builder: (ctx, _) => const BookmarksScreen(),
            ),
          ],
        ),
      ],
    );
  }

  static String? _redirect(AuthCubit authCubit, GoRouterState state) {
    final authState = authCubit.state;
    final currentPath = state.uri.path;

    final publicRoutes = {
      AppConstants.routeSplash,
      AppConstants.routeLogin,
      AppConstants.routeOtp,
      AppConstants.routeProfileSetup,
    };

    if (authState is AuthInitial || authState is AuthLoading) {
      return null;
    }

    if (authState is Unauthenticated) {
      if (currentPath == AppConstants.routeSplash ||
          !publicRoutes.contains(currentPath)) {
        return AppConstants.routeLogin;
      }
      return null;
    }

    if (authState is AuthNeedsProfileSetup) {
      if (currentPath != AppConstants.routeProfileSetup) {
        return AppConstants.routeProfileSetup;
      }
      return null;
    }

    if (authState is Authenticated) {
      if (publicRoutes.contains(currentPath)) {
        return AppConstants.routeHome;
      }
    }

    return null;
  }
}

/// Drives GoRouter to re-evaluate redirects when auth state changes.
class _AuthListenable extends ChangeNotifier {
  _AuthListenable(AuthCubit cubit) {
    cubit.stream.listen((_) => notifyListeners());
  }
}

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.location, required this.child});
  final String location;
  final Widget child;

  static const _tabs = <_TabSpec>[
    _TabSpec(
      route: AppConstants.routeHome,
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Home',
    ),
    _TabSpec(
      route: AppConstants.routeLeagues,
      icon: Icons.emoji_events_outlined,
      activeIcon: Icons.emoji_events_rounded,
      label: 'Leagues',
    ),
    _TabSpec(
      route: AppConstants.routeProgressMap,
      icon: Icons.map_outlined,
      activeIcon: Icons.map_rounded,
      label: 'Journey',
    ),
    _TabSpec(
      route: AppConstants.routeLeaderboard,
      icon: Icons.leaderboard_outlined,
      activeIcon: Icons.leaderboard_rounded,
      label: 'Ranks',
    ),
    _TabSpec(
      route: AppConstants.routeProfile,
      icon: Icons.person_outline,
      activeIcon: Icons.person_rounded,
      label: 'Profile',
    ),
  ];

  int _currentIndex() {
    for (var i = 0; i < _tabs.length; i++) {
      if (location == _tabs[i].route ||
          location.startsWith('${_tabs[i].route}/')) {
        return i;
      }
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final index = _currentIndex();
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) {
          if (i == index) return;
          context.go(_tabs[i].route);
        },
        indicatorColor: AppColors.primary.withValues(alpha: 0.15),
        destinations: [
          for (final t in _tabs)
            NavigationDestination(
              icon: Icon(t.icon),
              selectedIcon: Icon(t.activeIcon, color: AppColors.primary),
              label: t.label,
            ),
        ],
      ),
    );
  }
}

class _TabSpec {
  const _TabSpec({
    required this.route,
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
  final String route;
  final IconData icon;
  final IconData activeIcon;
  final String label;
}
