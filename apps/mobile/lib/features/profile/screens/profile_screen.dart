import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mquiz/core/constants/app_constants.dart';
import 'package:mquiz/core/theme/app_colors.dart';
import 'package:mquiz/core/widgets/common_widgets.dart';
import 'package:mquiz/features/auth/cubit/auth_cubit.dart';
import 'package:mquiz/features/profile/cubit/profile_cubit.dart';
import 'package:mquiz/features/profile/models/profile_extras_model.dart' as extras show Badge, ReferralInfo;
import 'package:mquiz/features/profile/models/user_profile_model.dart';
import 'package:mquiz/features/profile/models/user_stats_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    final cubit = context.read<ProfileCubit>();
    if (cubit.state is ProfileInitial) cubit.load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          return switch (state) {
            ProfileInitial() ||
            ProfileLoading() =>
              const Center(child: CircularProgressIndicator()),
            ProfileError(message: final msg) => ErrorStateView(
                message: msg,
                onRetry: () => context.read<ProfileCubit>().load(),
              ),
            ProfileLoaded() => _ProfileView(state: state),
          };
        },
      ),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView({required this.state});
  final ProfileLoaded state;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => context.read<ProfileCubit>().load(),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _Header(profile: state.profile, stats: state.stats),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StatsGrid(stats: state.stats),
                const SizedBox(height: 20),
                if (state.referral != null) ...[
                  _ReferralCard(info: state.referral!),
                  const SizedBox(height: 20),
                ],
                const Text(
                  'Badges',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                _BadgesGrid(badges: state.badges),
                const SizedBox(height: 24),
                _ActionTile(
                  icon: Icons.edit_outlined,
                  label: 'Edit Profile',
                  onTap: () => context.push(AppConstants.routeProfileEdit),
                ),
                _ActionTile(
                  icon: Icons.history_rounded,
                  label: 'Coin History',
                  onTap: () => context.push(AppConstants.routeCoinHistory),
                ),
                _ActionTile(
                  icon: Icons.logout,
                  label: 'Sign Out',
                  color: AppColors.wrong,
                  onTap: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Sign out?'),
                        content: const Text(
                            'You will need to sign in again to access your account.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                                foregroundColor: AppColors.wrong),
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Sign Out'),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true && context.mounted) {
                      await context.read<AuthCubit>().signOut();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.profile, required this.stats});
  final UserProfile profile;
  final UserStats stats;

  @override
  Widget build(BuildContext context) {
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
        children: [
          CircleAvatar(
            radius: 42,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            backgroundImage: profile.profileImage != null
                ? NetworkImage(profile.profileImage!)
                : null,
            child: profile.profileImage == null
                ? const Icon(Icons.person, color: Colors.white, size: 42)
                : null,
          ),
          const SizedBox(height: 12),
          Text(
            profile.name.isNotEmpty ? profile.name : 'Quiz Master',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (profile.email != null && profile.email!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                profile.email!,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 13,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.stats});
  final UserStats stats;

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Score', stats.totalScore.toString(), Icons.star_rounded,
          AppColors.coin),
      ('Quizzes', stats.quizzesPlayed.toString(), Icons.quiz_outlined,
          AppColors.primary),
      ('Coins', stats.coinsBalance.toString(), Icons.bolt_rounded,
          AppColors.coin),
      ('Accuracy', '${(stats.accuracy * 100).toStringAsFixed(0)}%',
          Icons.track_changes_rounded, AppColors.correct),
      ('Streak', stats.streakCurrent.toString(),
          Icons.local_fire_department_rounded, AppColors.streak),
      ('Badges', stats.badgesCount.toString(),
          Icons.workspace_premium_outlined, AppColors.xp),
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.95,
      ),
      itemBuilder: (ctx, i) {
        final (label, value, icon, color) = items[i];
        return GlassCard(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 6),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ReferralCard extends StatelessWidget {
  const _ReferralCard({required this.info});
  final extras.ReferralInfo info;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      gradient: AppColors.successGradient,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.card_giftcard_rounded, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'Your Referral Code',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    info.code,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, color: Colors.white),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: info.code));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Code copied'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.share_rounded, color: Colors.white),
                  tooltip: 'Share referral',
                  onPressed: () {
                    final text =
                        'Join me on mQuiz and use my referral code ${info.code} '
                        'to get bonus coins! 🎁\nhttps://mquizapp.com/join?ref=${info.code}';
                    Share.share(text, subject: 'Join mQuiz with my referral!');
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Referrals: ${info.successfulReferrals}  •  Coins earned: ${info.totalCoinsEarned}',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgesGrid extends StatelessWidget {
  const _BadgesGrid({required this.badges});
  final List<extras.Badge> badges;

  @override
  Widget build(BuildContext context) {
    if (badges.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: const Center(
          child: Text(
            'Play quizzes to start earning badges!',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: badges.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemBuilder: (ctx, i) {
        final b = badges[i];
        return Tooltip(
          message: '${b.title}\n${b.description}',
          child: Opacity(
            opacity: b.isEarned ? 1 : 0.35,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      b.isEarned ? AppColors.coin : AppColors.border,
                  width: b.isEarned ? 1.5 : 1,
                ),
              ),
              padding: const EdgeInsets.all(8),
              child: b.image != null && b.image!.isNotEmpty
                  ? Image.network(
                      b.image!,
                      errorBuilder: (_, __, ___) => const Icon(
                          Icons.workspace_premium,
                          color: AppColors.coin),
                    )
                  : const Icon(Icons.workspace_premium,
                      color: AppColors.coin, size: 28),
            ),
          ),
        );
      },
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                Icon(icon, color: color ?? AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: color ?? AppColors.textPrimary,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right,
                    color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
