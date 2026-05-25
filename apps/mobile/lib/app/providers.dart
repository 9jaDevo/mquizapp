import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mquiz/features/auth/auth_repository.dart';
import 'package:mquiz/features/auth/cubit/auth_cubit.dart';
import 'package:mquiz/features/auth/data/auth_local_data_source.dart';
import 'package:mquiz/features/auth/data/auth_remote_data_source.dart';
import 'package:mquiz/features/battle/cubit/battle_cubit.dart';
import 'package:mquiz/features/battle/data/battle_repository.dart';
import 'package:mquiz/features/contests/cubit/contest_cubit.dart';
import 'package:mquiz/features/contests/data/contest_repository.dart';
import 'package:mquiz/features/home/cubit/home_cubit.dart';
import 'package:mquiz/features/home/data/home_repository.dart';
import 'package:mquiz/features/leaderboard/cubit/leaderboard_cubit.dart';
import 'package:mquiz/features/leaderboard/data/leaderboard_repository.dart';
import 'package:mquiz/features/leagues/cubit/league_cubit.dart';
import 'package:mquiz/features/leagues/data/league_repository.dart';
import 'package:mquiz/features/lives/cubit/booster_store_cubit.dart';
import 'package:mquiz/features/lives/cubit/lives_cubit.dart';
import 'package:mquiz/features/lives/data/lives_repository.dart';
import 'package:mquiz/features/profile/cubit/profile_cubit.dart';
import 'package:mquiz/features/profile/data/profile_repository.dart';
import 'package:mquiz/features/progress/cubit/progress_cubit.dart';
import 'package:mquiz/features/progress/data/progress_repository.dart';
import 'package:mquiz/features/quiz/cubit/categories_cubit.dart';
import 'package:mquiz/features/quiz/cubit/quiz_cubit.dart';
import 'package:mquiz/features/quiz/data/quiz_repository.dart';
import 'package:mquiz/features/store/cubit/store_cubit.dart';
import 'package:mquiz/features/store/data/store_repository.dart';

class AppProviders extends StatelessWidget {
  const AppProviders({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create: (_) => AuthRepository(
            local: AuthLocalDataSource(),
            remote: AuthRemoteDataSource(),
          ),
        ),
        RepositoryProvider<QuizRepository>(create: (_) => QuizRepository()),
        RepositoryProvider<LeaderboardRepository>(
          create: (_) => LeaderboardRepository(),
        ),
        RepositoryProvider<ProfileRepository>(
          create: (_) => ProfileRepository(),
        ),
        RepositoryProvider<HomeRepository>(
          create: (ctx) => HomeRepository(
            profile: ctx.read<ProfileRepository>(),
            quiz: ctx.read<QuizRepository>(),
          ),
        ),
        RepositoryProvider<LivesRepository>(create: (_) => LivesRepository()),
        RepositoryProvider<LeagueRepository>(
          create: (_) => LeagueRepository(),
        ),
        RepositoryProvider<ContestRepository>(
          create: (_) => ContestRepository(),
        ),
        RepositoryProvider<StoreRepository>(create: (_) => StoreRepository()),
        RepositoryProvider<ProgressRepository>(
          create: (_) => ProgressRepository(),
        ),
        RepositoryProvider<BattleRepository>(
          create: (ctx) => BattleRepository(
            quizRepo: ctx.read<QuizRepository>(),
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>(
            create: (ctx) => AuthCubit(ctx.read<AuthRepository>()),
          ),
          BlocProvider<HomeCubit>(
            create: (ctx) => HomeCubit(ctx.read<HomeRepository>()),
          ),
          BlocProvider<QuizCubit>(
            create: (ctx) => QuizCubit(ctx.read<QuizRepository>()),
          ),
          BlocProvider<CategoriesCubit>(
            create: (ctx) => CategoriesCubit(ctx.read<QuizRepository>()),
          ),
          BlocProvider<SubcategoriesCubit>(
            create: (ctx) => SubcategoriesCubit(ctx.read<QuizRepository>()),
          ),
          BlocProvider<LeaderboardCubit>(
            create: (ctx) =>
                LeaderboardCubit(ctx.read<LeaderboardRepository>()),
          ),
          BlocProvider<ProfileCubit>(
            create: (ctx) => ProfileCubit(ctx.read<ProfileRepository>()),
          ),
          BlocProvider<LivesCubit>(
            create: (ctx) => LivesCubit(ctx.read<LivesRepository>()),
          ),
          BlocProvider<BoosterStoreCubit>(
            create: (ctx) => BoosterStoreCubit(ctx.read<LivesRepository>()),
          ),
          BlocProvider<LeaguesListCubit>(
            create: (ctx) => LeaguesListCubit(ctx.read<LeagueRepository>()),
          ),
          BlocProvider<LeagueDetailCubit>(
            create: (ctx) => LeagueDetailCubit(ctx.read<LeagueRepository>()),
          ),
          BlocProvider<ContestsListCubit>(
            create: (ctx) => ContestsListCubit(ctx.read<ContestRepository>()),
          ),
          BlocProvider<ContestDetailCubit>(
            create: (ctx) =>
                ContestDetailCubit(ctx.read<ContestRepository>()),
          ),
          BlocProvider<StoreCubit>(
            create: (ctx) => StoreCubit(ctx.read<StoreRepository>()),
          ),
          BlocProvider<ProgressCubit>(
            create: (ctx) => ProgressCubit(ctx.read<ProgressRepository>()),
          ),
          BlocProvider<BattleCubit>(
            create: (ctx) => BattleCubit(
              battleRepo: ctx.read<BattleRepository>(),
              quizRepo: ctx.read<QuizRepository>(),
            ),
          ),
        ],
        child: child,
      ),
    );
  }
}
