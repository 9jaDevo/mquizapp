import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/commons/widgets/custom_snackbar.dart';
import 'package:flutterquiz/core/core.dart';
import 'package:flutterquiz/features/profile_management/cubits/user_details_cubit.dart';
import 'package:flutterquiz/features/system_config/cubits/system_config_cubit.dart';
import 'package:flutterquiz/utils/api_utils.dart';
import 'package:flutterquiz/utils/ui_utils.dart';
import 'package:http/http.dart' as http;

class ReferAndEarnScreen extends StatefulWidget {
  const ReferAndEarnScreen({super.key});

  static Route<dynamic> route() {
    return CupertinoPageRoute(builder: (_) => const ReferAndEarnScreen());
  }

  @override
  State<ReferAndEarnScreen> createState() => _ReferAndEarnScreenState();
}

class _BonusConfig {
  const _BonusConfig({
    required this.enabled,
    required this.minActiveDays,
    required this.minQuizzes,
    required this.referrerBonusCoins,
    required this.refereeBonusCoins,
  });

  final bool enabled;
  final int minActiveDays;
  final int minQuizzes;
  final int referrerBonusCoins;
  final int refereeBonusCoins;

  static const fallback = _BonusConfig(
    enabled: true,
    minActiveDays: 7,
    minQuizzes: 50,
    referrerBonusCoins: 0,
    refereeBonusCoins: 0,
  );
}

class _ReferralStats {
  const _ReferralStats({
    required this.total,
    required this.active,
    required this.earned,
    required this.bonusConfig,
  });

  final int total;
  final int active;
  final int earned;
  final _BonusConfig bonusConfig;
}

class _ReferAndEarnScreenState extends State<ReferAndEarnScreen> {
  late final Future<_ReferralStats?> _statsFuture = _fetchReferralStats();

  Future<_ReferralStats?> _fetchReferralStats() async {
    try {
      final response = await http.post(
        Uri.parse(getReferralStatsUrl),
        headers: await ApiUtils.getHeaders(),
      );

      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;

      if (responseJson['error'] as bool? ?? true) {
        return null;
      }

      final data = responseJson['data'] as Map<String, dynamic>?;
      if (data == null) return null;

      _BonusConfig bonusConfig = _BonusConfig.fallback;
      final bc = data['bonus_config'] as Map<String, dynamic>?;
      if (bc != null) {
        bonusConfig = _BonusConfig(
          enabled: bc['enabled'] as bool? ?? true,
          minActiveDays: int.tryParse(bc['min_active_days'].toString()) ?? 7,
          minQuizzes: int.tryParse(bc['min_quizzes'].toString()) ?? 50,
          referrerBonusCoins: int.tryParse(bc['referrer_bonus_coins'].toString()) ?? 0,
          refereeBonusCoins: int.tryParse(bc['referee_bonus_coins'].toString()) ?? 0,
        );
      }

      return _ReferralStats(
        total: int.tryParse(data['total_referrals'].toString()) ?? 0,
        active: int.tryParse(data['successful_referrals'].toString()) ?? 0,
        earned: int.tryParse(data['total_coins_earned'].toString()) ?? 0,
        bonusConfig: bonusConfig,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final referCode = context
        .read<UserDetailsCubit>()
        .getUserProfile()
        .referCode!;
    final sysConfig = context.read<SystemConfigCubit>();

    final referText =
        '${context.tr('referText1')} ${sysConfig.refereeEarnCoin} ${context.tr('referText2')} $referCode\n ${context.tr('referText3')} ${sysConfig.appUrl}';

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FF),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTopBar(context),
                const SizedBox(height: 18),
                FutureBuilder<_ReferralStats?>(
                  future: _statsFuture,
                  builder: (context, snapshot) {
                    final stats = snapshot.data;
                    if (stats == null) {
                      return const SizedBox.shrink();
                    }

                    return Column(
                      children: [
                        _buildSummaryRow(
                          total: stats.total.toString(),
                          active: stats.active.toString(),
                          earned: stats.earned.toString(),
                        ),
                        const SizedBox(height: 20),
                      ],
                    );
                  },
                ),
                FutureBuilder<_ReferralStats?>(
                  future: _statsFuture,
                  builder: (context, snapshot) {
                    final bc = snapshot.data?.bonusConfig ?? _BonusConfig.fallback;
                    return _buildHeroCard(context, sysConfig, bc);
                  },
                ),
                const SizedBox(height: 20),
                _buildHowItWorksCard(context),
                const SizedBox(height: 20),
                _buildReferralCodeCard(context, referCode),
                const SizedBox(height: 20),
                _buildShareButton(context, referText),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            color: const Color(0xFF1E4FD9),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        const Spacer(),
        const Text(
          'Refer & Earn',
          style: const TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1E4FD9),
          ),
        ),
        const Spacer(),
        const SizedBox(width: 44),
      ],
    );
  }

  Widget _buildSummaryRow({
    required String total,
    required String active,
    required String earned,
  }) {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            title: 'Total',
            value: total,
            accent: const Color(0xFF2E5BEA),
            tint: const Color(0xFFE7ECFF),
            icon: Icons.group_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            title: 'Active',
            value: active,
            accent: const Color(0xFF22C55E),
            tint: const Color(0xFFE9F9F1),
            icon: Icons.check_circle_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            title: 'Earned',
            value: earned,
            accent: const Color(0xFFF59E0B),
            tint: const Color(0xFFFFF2D6),
            icon: Icons.monetization_on_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required Color accent,
    required Color tint,
    required IconData icon,
  }) {
    return Container(
      height: 122,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [tint, tint.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
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
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: accent,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: accent.withValues(alpha: 0.75),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context, SystemConfigCubit sysConfig, _BonusConfig bc) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2E5BEA), Color(0xFF4E7BFF)],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 48,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 86,
            height: 86,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.card_giftcard_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Invite Friends & Earn\nTogether',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Share the joy of learning! Earn rewards when your friends join and succeed.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _buildHeroMiniCard(
                  icon: Icons.card_giftcard_rounded,
                  value: sysConfig.referrerEarnCoin,
                  title: 'Instant Coins',
                  subtitle: 'Per Referral',
                ),
              ),
              const SizedBox(width: 12),
              if (bc.enabled)
                Expanded(
                  child: _buildHeroMiniCard(
                    icon: Icons.auto_awesome_rounded,
                    value: '+${bc.referrerBonusCoins}',
                    title: 'Bonus Reward',
                    subtitle: 'After ${bc.minActiveDays}d + ${bc.minQuizzes} quizzes',
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroMiniCard({
    required IconData icon,
    required String value,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.75),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHowItWorksCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
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
          Row(
            children: [
              const Icon(
                Icons.insights_rounded,
                color: Color(0xFF2E5BEA),
              ),
              const SizedBox(width: 8),
              const Text(
                'How It Works',
                style: TextStyle(
                  color: Color(0xFF1E4FD9),
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildStep(
            number: '1',
            title: 'Share Your Code',
            description: 'Send your unique referral code to friends',
          ),
          const SizedBox(height: 14),
          _buildStep(
            number: '2',
            title: 'They Sign Up',
            description: 'Both get 50 coins instantly when they join',
          ),
          const SizedBox(height: 14),
          _buildStep(
            number: '3',
            title: 'Earn Bonus',
            description: 'Get bonus coins when they complete the activity requirement',
          ),
        ],
      ),
    );
  }

  Widget _buildStep({
    required String number,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF2E5BEA),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF1E4FD9),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  color: const Color(0xFF64748B),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReferralCodeCard(BuildContext context, String referCode) {
    return Container(
      padding: const EdgeInsets.all(18),
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
          Text(
            'Your Referral Code',
            style: TextStyle(
              color: const Color(0xFF64748B),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F7FF),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE6ECFF)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    referCode,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E4FD9),
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () async {
                    await Clipboard.setData(
                      ClipboardData(text: referCode),
                    );
                    if (context.mounted) {
                      context.showSnack(context.tr('referCodeCopyMsg')!);
                    }
                  },
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E5BEA),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.copy_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShareButton(BuildContext context, String referText) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => UiUtils.share(referText, context: context),
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF2E5BEA),
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 32,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.share_rounded,
                color: Colors.white,
                size: 22,
              ),
              const SizedBox(width: 10),
              const Text(
                'Share with Friends',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
