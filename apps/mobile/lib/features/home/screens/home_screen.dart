import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mquiz/core/constants/app_constants.dart';
import 'package:mquiz/core/theme/app_colors.dart';
import 'package:mquiz/core/widgets/common_widgets.dart';
import 'package:mquiz/features/home/cubit/home_cubit.dart';
import 'package:mquiz/features/home/models/home_dashboard_model.dart';
import 'package:mquiz/features/profile/models/user_profile_model.dart';
import 'package:mquiz/features/quiz/models/category_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    final cubit = context.read<HomeCubit>();
    if (cubit.state is HomeInitial) {
      cubit.load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          return switch (state) {
            HomeInitial() ||
            HomeLoading() =>
              const Center(child: CircularProgressIndicator()),
            HomeError(message: final msg) => ErrorStateView(
                message: msg,
                onRetry: () => context.read<HomeCubit>().load(),
              ),
            HomeLoaded(:final data) => _DashboardView(data: data),
          };
        },
      ),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView({required this.data});
  final HomeDashboard data;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => context.read<HomeCubit>().refresh(),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _GreetingHeader(user: data.user)),
          if (data.hasDailyChallenge)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: _DailyChallengeCard(challenge: data.dailyChallenge!),
              ),
            ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Text(
                'Choose a category',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
              ),
            ),
          ),
          if (data.categories.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyStateView(message: 'No categories available yet.'),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: SliverGrid(
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.05,
                ),
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) => _CategoryCard(category: data.categories[i]),
                  childCount: data.categories.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _GreetingHeader extends StatelessWidget {
  const _GreetingHeader({required this.user});
  final UserProfile user;

  @override
  Widget build(BuildContext context) {
    final coins = user.coins;
    final lives = user.lives?.current ?? 0;
    final maxLives = user.lives?.max ?? AppConstants.maxLives;
    final streak = user.streak?.current ?? 0;

    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 16,
        20,
        24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                backgroundImage: user.profileImage != null
                    ? NetworkImage(user.profileImage!)
                    : null,
                child: user.profileImage == null
                    ? Text(
                        _initials(user.name),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back,',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      user.name.isNotEmpty ? user.name : 'Quiz Master',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => context.go(AppConstants.routeProfile),
                icon: const Icon(Icons.person_outline, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: StatPill(
                  icon: Icons.bolt_rounded,
                  label: 'Coins',
                  value: coins.toString(),
                  color: AppColors.coin,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StatPill(
                  icon: Icons.favorite_rounded,
                  label: 'Lives',
                  value: '$lives/$maxLives',
                  color: AppColors.live,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StatPill(
                  icon: Icons.local_fire_department_rounded,
                  label: 'Streak',
                  value: streak.toString(),
                  color: AppColors.streak,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.category});
  final Category category;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: () => context.push(
        '/categories/${category.id}',
        extra: category.name,
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: category.image != null && category.image!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      category.image!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.quiz_outlined,
                        color: AppColors.primary,
                      ),
                    ),
                  )
                : const Icon(Icons.quiz_outlined, color: AppColors.primary),
          ),
          const Spacer(),
          Text(
            category.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14.5,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              if (category.isPremium)
                const Padding(
                  padding: EdgeInsets.only(right: 6),
                  child: Icon(Icons.workspace_premium,
                      size: 14, color: AppColors.coin),
                ),
              const Icon(Icons.bolt_rounded, size: 14, color: AppColors.coin),
              const SizedBox(width: 4),
              Text(
                '${category.coins}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DailyChallengeCard extends StatelessWidget {
  const _DailyChallengeCard({required this.challenge});
  final Map<String, dynamic> challenge;

  @override
  Widget build(BuildContext context) {
    final title = challenge['title']?.toString() ?? 'Daily Challenge';
    final coins = challenge['rewardCoins'] ?? challenge['coins'] ?? 50;
    return GlassCard(
      gradient: AppColors.streakGradient,
      padding: const EdgeInsets.all(16),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Daily challenge opens soon.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Row(
        children: [
          const Icon(Icons.emoji_events_rounded,
              color: Colors.white, size: 36),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Earn $coins coins today',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.white),
        ],
      ),
    );
  }
}
