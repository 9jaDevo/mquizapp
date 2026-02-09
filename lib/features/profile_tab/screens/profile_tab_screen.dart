import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/commons/commons.dart';
import 'package:flutterquiz/core/core.dart';
import 'package:flutterquiz/features/auth/cubits/auth_cubit.dart';
import 'package:flutterquiz/features/profile_management/cubits/user_details_cubit.dart';
import 'package:flutterquiz/features/settings/settings_cubit.dart';
import 'package:flutterquiz/features/skill_tier/models/skill_tier.dart';
import 'package:flutterquiz/features/skill_tier/skill_tier_service.dart';
import 'package:flutterquiz/features/system_config/cubits/system_config_cubit.dart';
import 'package:flutterquiz/ui/screens/app_settings_screen.dart';
import 'package:flutterquiz/ui/screens/profile/create_or_edit_profile_screen.dart';
import 'package:flutterquiz/ui/screens/menu/widgets/delete_account_dialog.dart';
import 'package:flutterquiz/ui/screens/menu/widgets/language_selector_sheet.dart';
import 'package:flutterquiz/ui/screens/menu/widgets/logout_dialog.dart';
import 'package:flutterquiz/ui/screens/menu/widgets/quiz_language_selector_sheet.dart';
import 'package:flutterquiz/ui/screens/menu/widgets/theme_selector_sheet.dart';
import 'package:flutterquiz/utils/gdpr_helper.dart';
import 'package:flutterquiz/utils/ui_utils.dart';
import 'package:url_launcher/url_launcher.dart';

final class ProfileTabScreen extends StatefulWidget {
  const ProfileTabScreen({super.key});

  @override
  State<ProfileTabScreen> createState() => ProfileTabScreenState();
}

final class ProfileTabScreenState extends State<ProfileTabScreen>
    with AutomaticKeepAliveClientMixin {
  final _scrollController = ScrollController();

  bool get _isGuest => context.read<AuthCubit>().isGuest;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void onTapTab() {
    if (_scrollController.hasClients && _scrollController.offset != 0) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onTapMenuItem(String name) {
    if (name == 'profileEdit') {
      if (_isGuest) {
        showLoginRequiredDialog(context);
        return;
      }

      globalCtx.pushNamed(
        Routes.selectProfile,
        arguments: const CreateOrEditProfileScreenArgs(isNewUser: false),
      );
      return;
    }

    /// Menus that guest can use without being logged in.
    switch (name) {
      case 'theme':
        showThemeSelectorSheet(globalCtx);
        return;
      case 'quizLanguage':
        showQuizLanguageSelectorSheet(globalCtx);
        return;
      case 'language':
        showLanguageSelectorSheet(globalCtx, onChange: () => setState(() {}));
        return;
      case 'aboutQuizApp':
        globalCtx.pushNamed(Routes.aboutApp);
        return;
      case howToPlayLbl:
        globalCtx.pushNamed(
          Routes.appSettings,
          arguments: const AppSettingsScreenArgs(howToPlayLbl),
        );
        return;
      case 'shareAppLbl':
        {
          try {
            UiUtils.share(
              '${context.read<SystemConfigCubit>().appUrl}\n${context.read<SystemConfigCubit>().shareAppText}',
              context: globalCtx,
            );
          } on Exception catch (e) {
            context.showSnack(e.toString());
          }
        }
        return;
      case 'rateUsLbl':
        launchUrl(Uri.parse(context.read<SystemConfigCubit>().appUrl));
        return;
      case 'adsPreference':
        GdprHelper.changePrivacyPreferences();
        return;
    }

    /// Menus that users can't use without signing in, (ex. in guest mode).
    if (_isGuest) {
      showLoginRequiredDialog(context);
      return;
    }

    switch (name) {
      case 'coinHistory':
        globalCtx.pushNamed(Routes.coinHistory);
        return;
      case 'wallet':
        globalCtx.pushNamed(Routes.wallet);
        return;
      case 'bookmarkLbl':
        globalCtx.pushNamed(Routes.bookmark);
        return;
      case 'inviteFriendsLbl':
        globalCtx.pushNamed(Routes.referAndEarn);
        return;
      case 'badges':
        globalCtx.pushNamed(Routes.badges);
        return;
      case 'rewardsLbl':
        globalCtx.pushNamed(Routes.rewards);
        return;
      case 'statisticsLabel':
        globalCtx.pushNamed(Routes.statistics);
        return;
      case 'logoutLbl':
        showLogoutDialog(globalCtx);
        return;
      case 'deleteAccountLbl':
        showDeleteAccountDialog(globalCtx);
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FF),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            children: [
              _buildProfileHeaderCard(),
              const SizedBox(height: 16),
              _buildBalanceCard(),
              const SizedBox(height: 16),
              _buildQuickActionsRow(),
              const SizedBox(height: 16),
              _buildWeeklyProgressCard(),
              const SizedBox(height: 16),
              _buildBookmarksBadgesRow(),
              const SizedBox(height: 16),
              _buildPreferencesCard(),
              const SizedBox(height: 16),
              _buildMenuActionsCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeaderCard() {
    return BlocBuilder<UserDetailsCubit, UserDetailsState>(
      builder: (context, state) {
        var profileUrl = '';
        var username = context.tr('helloGuest')!;
        var gamesCount = 0;

        if (state is UserDetailsFetchSuccess) {
          profileUrl = state.userProfile.profileUrl ?? '';
          username = state.userProfile.name ?? username;
          gamesCount = int.tryParse(state.userProfile.allTimeScore ?? '') ?? 0;
        }

        return FutureBuilder<SkillTier>(
          future: SkillTierService.computeTier(),
          builder: (context, snapshot) {
            final tier = snapshot.data;
            final leagueLabel = tier != null
                ? '${SkillTier.label(tier.type)} League'
                : 'Platinum League';
            final accuracy = tier?.accuracyPercent ?? 0;

            return Container(
              height: 280,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 36,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Container(
                    height: 140,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFEBF0FF), Color(0xFFDCE6FF)],
                      ),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(30),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 18,
                    right: 24,
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.4),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 32,
                    left: 24,
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.4),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 48),
                      child: Stack(
                        children: [
                          Container(
                            width: 92,
                            height: 92,
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 18,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: QImage.circular(imageUrl: profileUrl),
                          ),
                          Positioned(
                            bottom: 2,
                            right: 2,
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: const Color(0xFF9B6BFF),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.emoji_events_rounded,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                          ),
                          Positioned(
                            top: -6,
                            right: -6,
                            child: InkWell(
                              onTap: () => _onTapMenuItem('profileEdit'),
                              borderRadius: BorderRadius.circular(999),
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.12,
                                      ),
                                      blurRadius: 12,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.edit_rounded,
                                  size: 16,
                                  color: Color(0xFF2E5BEA),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned.fill(
                    top: 145,
                    child: Column(
                      children: [
                        Text(
                          username,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E4FD9),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFE9FF),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF9B6BFF),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                leagueLabel,
                                style: const TextStyle(
                                  color: Color(0xFF7E5BEA),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildMiniStatCard(
                                  value: UiUtils.formatNumber(gamesCount),
                                  label: 'Games',
                                  color: const Color(0xFF2E5BEA),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildMiniStatCard(
                                  value: '${accuracy.toStringAsFixed(0)}%',
                                  label: 'Accuracy',
                                  color: const Color(0xFFFFA800),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildMiniStatCard(
                                  value: '14',
                                  label: 'Badges',
                                  color: const Color(0xFF2E5BEA),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMiniStatCard({
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF7E8AA8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    return BlocBuilder<UserDetailsCubit, UserDetailsState>(
      builder: (context, state) {
        var coins = '0';
        if (state is UserDetailsFetchSuccess) {
          coins = state.userProfile.coins ?? '0';
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 28,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF2E5BEA),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Balance',
                    style: TextStyle(
                      color: Color(0xFF7E8AA8),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${UiUtils.formatNumber(int.tryParse(coins) ?? 0)} Coins',
                    style: const TextStyle(
                      color: Color(0xFF1E4FD9),
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickActionsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildActionCard(
            title: 'Invite Friends',
            icon: Icons.person_add_alt_rounded,
            tint: const Color(0xFFFFEAD2),
            accent: const Color(0xFFFFA800),
            onTap: () => _onTapMenuItem('inviteFriendsLbl'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionCard(
            title: 'Rewards',
            icon: Icons.card_giftcard_rounded,
            tint: const Color(0xFFE7ECFF),
            accent: const Color(0xFF2E5BEA),
            onTap: () => _onTapMenuItem('rewardsLbl'),
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required String title,
    required IconData icon,
    required Color tint,
    required Color accent,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 96,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 28,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: tint,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: accent, size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF1E4FD9),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyProgressCard() {
    const progressValue = 0.68;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                'Weekly Progress',
                style: TextStyle(
                  color: Color(0xFF1E4FD9),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF0FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.trending_up_rounded,
                  color: Color(0xFF2E5BEA),
                  size: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progressValue,
              minHeight: 8,
              backgroundColor: const Color(0xFFE7ECFF),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF2E5BEA)),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: const [
              Text(
                '34 of 50 quizzes completed',
                style: TextStyle(
                  color: Color(0xFF7E8AA8),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Spacer(),
              Text(
                '68%',
                style: TextStyle(
                  color: Color(0xFF2E5BEA),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBookmarksBadgesRow() {
    return Row(
      children: [
        Expanded(
          child: _buildInfoCard(
            title: 'Bookmarks',
            subtitle: '28 saved',
            icon: Icons.bookmark_rounded,
            tint: const Color(0xFFFFF2D6),
            accent: const Color(0xFFFFA800),
            onTap: () => _onTapMenuItem('bookmarkLbl'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildInfoCard(
            title: 'Badges',
            subtitle: '14 earned',
            icon: Icons.workspace_premium_rounded,
            tint: const Color(0xFFE7ECFF),
            accent: const Color(0xFF2E5BEA),
            onTap: () => _onTapMenuItem('badges'),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color tint,
    required Color accent,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 96,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 28,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: tint,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: accent, size: 20),
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF1E4FD9),
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                color: Color(0xFF7E8AA8),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferencesCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Preferences',
            style: TextStyle(
              color: Color(0xFF1E4FD9),
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          _buildPreferenceRow(
            icon: Icons.palette_rounded,
            label: 'Theme',
            trailing: Text(
              Theme.of(context).brightness == Brightness.dark
                  ? 'Dark'
                  : 'Light',
              style: const TextStyle(
                color: Color(0xFF7E8AA8),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: () => _onTapMenuItem('theme'),
          ),
          const SizedBox(height: 12),
          _buildPreferenceRow(
            icon: Icons.volume_up_rounded,
            label: 'Sound',
            trailing: const _SoundSwitchWidget(),
          ),
          const SizedBox(height: 12),
          _buildPreferenceRow(
            icon: Icons.vibration_rounded,
            label: 'Vibration',
            trailing: const _VibrationSwitchWidget(),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuActionsCard() {
    final items = <_MenuActionItem>[
      _MenuActionItem(
        label: 'Wallet',
        icon: Icons.account_balance_wallet_rounded,
        action: () => _onTapMenuItem('wallet'),
      ),
      _MenuActionItem(
        label: 'Coin History',
        icon: Icons.receipt_long_rounded,
        action: () => _onTapMenuItem('coinHistory'),
      ),
      _MenuActionItem(
        label: 'Statistics',
        icon: Icons.insights_rounded,
        action: () => _onTapMenuItem('statisticsLabel'),
      ),
      _MenuActionItem(
        label: 'About',
        icon: Icons.info_outline_rounded,
        action: () => _onTapMenuItem('aboutQuizApp'),
      ),
      _MenuActionItem(
        label: 'How to Play',
        icon: Icons.help_outline_rounded,
        action: () => _onTapMenuItem(howToPlayLbl),
      ),
      _MenuActionItem(
        label: 'Share App',
        icon: Icons.share_rounded,
        action: () => _onTapMenuItem('shareAppLbl'),
      ),
      _MenuActionItem(
        label: 'Rate Us',
        icon: Icons.star_rate_rounded,
        action: () => _onTapMenuItem('rateUsLbl'),
      ),
      if (!_isGuest)
        _MenuActionItem(
          label: 'Logout',
          icon: Icons.logout_rounded,
          action: () => _onTapMenuItem('logoutLbl'),
          color: const Color(0xFFEF4444),
        ),
      if (!_isGuest)
        _MenuActionItem(
          label: 'Delete Account',
          icon: Icons.delete_forever_rounded,
          action: () => _onTapMenuItem('deleteAccountLbl'),
          color: const Color(0xFFEF4444),
        ),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            _buildMenuActionTile(items[i]),
            if (i != items.length - 1) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  Widget _buildMenuActionTile(_MenuActionItem item) {
    final color = item.color ?? const Color(0xFF2E5BEA);

    return InkWell(
      onTap: item.action,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F4FF),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(item.icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item.label,
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: const Color(0xFF9AA7C0),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferenceRow({
    required IconData icon,
    required String label,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F4FF),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(icon, color: const Color(0xFF2E5BEA), size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF1E4FD9),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

/// Extracts only sound value from settings state to prevent rebuilds
/// when other settings (vibration, notifications, etc.) change
class _SoundSwitchWidget extends StatelessWidget {
  const _SoundSwitchWidget();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<SettingsCubit, SettingsState, bool>(
      selector: (state) => state.settingsModel!.sound,
      builder: (context, isSoundEnabled) {
        return CustomSwitch(
          value: isSoundEnabled,
          onChanged: (v) => context.read<SettingsCubit>().sound = v,
        );
      },
    );
  }
}

class _MenuActionItem {
  _MenuActionItem({
    required this.label,
    required this.icon,
    required this.action,
    this.color,
  });

  final String label;
  final IconData icon;
  final VoidCallback action;
  final Color? color;
}

/// Extracts only vibration value from settings state to prevent rebuilds
/// when other settings (sound, notifications, etc.) change
class _VibrationSwitchWidget extends StatelessWidget {
  const _VibrationSwitchWidget();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<SettingsCubit, SettingsState, bool>(
      selector: (state) => state.settingsModel!.vibration,
      builder: (context, isVibrationEnabled) {
        return CustomSwitch(
          value: isVibrationEnabled,
          onChanged: (v) => context.read<SettingsCubit>().vibration = v,
        );
      },
    );
  }
}
