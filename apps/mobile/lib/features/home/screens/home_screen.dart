import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mquiz/core/constants/app_constants.dart';
import 'package:mquiz/core/theme/app_colors.dart';
import 'package:mquiz/core/widgets/common_widgets.dart';
import 'package:mquiz/features/home/cubit/home_cubit.dart';
import 'package:mquiz/features/home/models/home_dashboard_model.dart';
import 'package:mquiz/features/notifications/cubit/notifications_cubit.dart';
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
          // ── Battle CTA ────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: _BattleCta(),
            ),
          ),          // ── Active Contest Banner ───────────────────────────────────────────────────
          if (data.hasActiveContest)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: _ContestBanner(contest: data.activeContest!),
              ),
            ),          if (data.hasDailyChallenge)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: _DailyChallengeCard(challenge: data.dailyChallenge!),
              ),
            ),
          // ── Sponsor Banner ──────────────────────────────────────────────────────────
          if (data.hasSponsorBanner)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: _SponsorBanner(banner: data.sponsorBanners.first),
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
    final stage = user.progress?.stageNumber ?? 1;
    final totalScore = user.progress?.totalScore ?? 0;
    // Estimate 1000 XP per stage for progress bar fill
    const xpPerStage = 1000;
    final xpInStage = totalScore % xpPerStage;
    final stageFill = (xpInStage / xpPerStage).clamp(0.0, 1.0);

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
              BlocBuilder<NotificationsCubit, NotificationsState>(
                builder: (context, state) {
                  final unread =
                      state is NotificationsLoaded ? state.unreadCount : 0;
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        onPressed: () => context
                            .push(AppConstants.routeNotifications),
                        icon: const Icon(Icons.notifications_outlined,
                            color: Colors.white),
                      ),
                      if (unread > 0)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.wrong,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => context.push(AppConstants.routeCoinStore),
                  child: StatPill(
                    icon: Icons.bolt_rounded,
                    label: 'Coins',
                    value: coins.toString(),
                    color: AppColors.coin,
                  ),
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
          // ── XP / Stage progress bar ───────────────────────────────────────────
          const SizedBox(height: 14),
          Row(
            children: [
              Text(
                'Stage $stage',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: stageFill,
                    minHeight: 6,
                    backgroundColor: Colors.white.withValues(alpha: 0.25),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(AppColors.coin),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$xpInStage / $xpPerStage XP',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 11,
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

/// Battle quick-access card shown on the home screen dashboard.
class _BattleCta extends StatelessWidget {
  const _BattleCta();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push(AppConstants.routeBattle),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF7C3AED), Color(0xFF4F46E5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Icon(Icons.sports_kabaddi_rounded,
                  color: Colors.white, size: 36),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '1v1 Battle',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Challenge a random opponent now!',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Active Contest Banner ────────────────────────────────────────────────────

class _ContestBanner extends StatelessWidget {
  const _ContestBanner({required this.contest});
  final Map<String, dynamic> contest;

  @override
  Widget build(BuildContext context) {
    final title = contest['title']?.toString() ?? 'Live Contest';
    final prize = contest['prizePool'] ?? contest['totalPrize'];
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push(AppConstants.routeContests),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFD97706), Color(0xFFEA580C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              const Icon(Icons.emoji_events_rounded,
                  color: Colors.white, size: 30),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Contest Live!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    if (prize != null)
                      Text(
                        'Prize pool: ₦${prize.toString()}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Sponsor Banner ───────────────────────────────────────────────────────────

class _SponsorBanner extends StatelessWidget {
  const _SponsorBanner({required this.banner});
  final Map<String, dynamic> banner;

  @override
  Widget build(BuildContext context) {
    final name = banner['sponsorName']?.toString() ??
        banner['name']?.toString() ??
        'Sponsor';
    final logoUrl = banner['logoUrl']?.toString() ?? banner['logo']?.toString();
    final websiteUrl =
        banner['websiteUrl']?.toString() ?? banner['website']?.toString();
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          if (websiteUrl != null) {
            final uri = Uri.tryParse(websiteUrl);
            if (uri != null) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            children: [
              if (logoUrl != null && logoUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.network(
                    logoUrl,
                    width: 40,
                    height: 40,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.business, size: 28),
                  ),
                )
              else
                const Icon(Icons.business, size: 28, color: AppColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sponsored',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.4,
                      ),
                    ),
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.open_in_new,
                  size: 16, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Daily Challenge Card ─────────────────────────────────────────────────────

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
