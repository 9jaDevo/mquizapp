import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mquiz/core/theme/app_colors.dart';
import 'package:mquiz/core/widgets/common_widgets.dart';
import 'package:mquiz/features/store/cubit/store_cubit.dart';
import 'package:mquiz/features/store/models/coin_pack_model.dart';
import 'package:url_launcher/url_launcher.dart';

class CoinStoreScreen extends StatefulWidget {
  const CoinStoreScreen({super.key});

  @override
  State<CoinStoreScreen> createState() => _CoinStoreScreenState();
}

class _CoinStoreScreenState extends State<CoinStoreScreen> {
  @override
  void initState() {
    super.initState();
    final cubit = context.read<StoreCubit>();
    cubit.load();
    if (Platform.isIOS) cubit.initIAP();
  }

  Future<void> _purchase(CoinPack pack) async {
    // iOS: use native In-App Purchase instead of Paystack
    if (Platform.isIOS) {
      await context.read<StoreCubit>().purchaseIAP(pack.effectiveAppStoreId);
      return;
    }
    final cubit = context.read<StoreCubit>();
    final init = await cubit.initialize(pack: pack);
    if (!mounted || init == null) return;
    if (init.authorizationUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment could not be initialized.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      cubit.cancelPurchase();
      return;
    }
    final uri = Uri.tryParse(init.authorizationUrl);
    final launched = uri != null &&
        await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!mounted) return;
    if (!launched) {
      cubit.cancelPurchase();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open payment page.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    // Server-authoritative: user returns to app → verify.
    final confirmed = await _showVerifySheet(init.reference);
    if (!mounted || !confirmed) {
      cubit.cancelPurchase();
      return;
    }
    final result = await cubit.verify(init.reference);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.success
              ? '+${result.coinsCredited} coins added!'
              : result.message ?? 'Payment not verified yet.',
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: result.success ? AppColors.correct : AppColors.wrong,
      ),
    );
  }

  Future<bool> _showVerifySheet(String reference) async {
    return await showModalBottomSheet<bool>(
          context: context,
          isDismissible: false,
          enableDrag: false,
          builder: (ctx) => Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.payment, size: 48, color: AppColors.primary),
                const SizedBox(height: 12),
                const Text(
                  'Complete your payment',
                  style: TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  'When you finish paying, tap "I\'ve paid" to verify. '
                  'Reference: ${reference.length > 16 ? "${reference.substring(0, 16)}…" : reference}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 20),
                PrimaryButton(
                  label: "I've paid — verify",
                  icon: Icons.verified_rounded,
                  onPressed: () => Navigator.of(ctx).pop(true),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        title: const Text('Coin Store'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<StoreCubit, StoreState>(
        builder: (context, state) => switch (state) {
          StoreInitial() ||
          StoreLoading() =>
            const Center(child: CircularProgressIndicator()),
          StoreError(message: final m) => ErrorStateView(
              message: m,
              onRetry: () => context.read<StoreCubit>().load(),
            ),
          StoreLoaded() => _Body(state: state, onPurchase: _purchase),
        },
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.state, required this.onPurchase});
  final StoreLoaded state;
  final Future<void> Function(CoinPack pack) onPurchase;

  @override
  Widget build(BuildContext context) {
    if (state.packs.isEmpty) {
      return const EmptyStateView(
        message: 'No coin packs available right now.',
        icon: Icons.shopping_cart_outlined,
      );
    }
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              const Icon(Icons.account_balance_wallet, color: Colors.white),
              const SizedBox(width: 10),
              const Text(
                'Your balance',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              const Spacer(),
              Text(
                '${state.balance}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.bolt, color: Colors.white),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            itemCount: state.packs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (ctx, i) {
              final p = state.packs[i];
              final isPurchasing = state.purchasingId == p.id;
              return _PackCard(
                pack: p,
                purchasing: isPurchasing,
                anyPurchasing: state.purchasingId != null,
                onTap: () => onPurchase(p),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PackCard extends StatelessWidget {
  const _PackCard({
    required this.pack,
    required this.purchasing,
    required this.anyPurchasing,
    required this.onTap,
  });
  final CoinPack pack;
  final bool purchasing;
  final bool anyPurchasing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: pack.isPopular ? AppColors.coin : AppColors.border,
          width: pack.isPopular ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.coin.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.monetization_on,
                color: AppColors.coin, size: 30),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      pack.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 15),
                    ),
                    if (pack.isPopular) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.coin,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'POPULAR',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  pack.bonusCoins != null && pack.bonusCoins! > 0
                      ? '${pack.coins} + ${pack.bonusCoins} bonus'
                      : '${pack.coins} coins',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 38,
            child: FilledButton(
              onPressed: anyPurchasing ? null : onTap,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 14),
              ),
              child: purchasing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      pack.priceLocal != null
                          ? '${pack.currency ?? ''} ${pack.priceLocal!.toStringAsFixed(2)}'
                          : pack.priceUsd != null
                              ? '\$${pack.priceUsd!.toStringAsFixed(2)}'
                              : 'Buy',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
