import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mquiz/core/theme/app_colors.dart';
import 'package:mquiz/core/widgets/common_widgets.dart';
import 'package:mquiz/features/lives/cubit/booster_store_cubit.dart';
import 'package:mquiz/features/lives/models/lives_models.dart';

class BoosterStoreScreen extends StatefulWidget {
  const BoosterStoreScreen({super.key});

  @override
  State<BoosterStoreScreen> createState() => _BoosterStoreScreenState();
}

class _BoosterStoreScreenState extends State<BoosterStoreScreen> {
  @override
  void initState() {
    super.initState();
    context.read<BoosterStoreCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        title: const Text('Boosters'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: BlocConsumer<BoosterStoreCubit, BoosterStoreState>(
        listenWhen: (prev, curr) =>
            prev is BoosterStoreLoaded &&
            curr is BoosterStoreLoaded &&
            prev.purchasingId != null &&
            curr.purchasingId == null,
        listener: (context, state) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Booster purchased'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        builder: (context, state) {
          return switch (state) {
            BoosterStoreInitial() ||
            BoosterStoreLoading() =>
              const Center(child: CircularProgressIndicator()),
            BoosterStoreError(message: final m) => ErrorStateView(
                message: m,
                onRetry: () => context.read<BoosterStoreCubit>().load(),
              ),
            BoosterStoreLoaded() => _Body(state: state),
          };
        },
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.state});
  final BoosterStoreLoaded state;

  int _ownedQty(int id) =>
      state.owned.firstWhere(
        (b) => b.id == id,
        orElse: () =>
            const Booster(id: 0, name: '', description: '', coinCost: 0),
      ).quantity ??
      0;

  @override
  Widget build(BuildContext context) {
    if (state.catalog.isEmpty) {
      return const EmptyStateView(
        message: 'No boosters available right now.',
        icon: Icons.bolt_outlined,
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: state.catalog.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (ctx, i) {
        final b = state.catalog[i];
        final owned = _ownedQty(b.id);
        final purchasing = state.purchasingId == b.id;
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.xp.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.bolt_rounded, color: AppColors.xp),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            b.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        if (owned > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.correct.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Owned $owned',
                              style: const TextStyle(
                                color: AppColors.correct,
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (b.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        b.description,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.bolt,
                            color: AppColors.coin, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${b.coinCost} coins',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.coin,
                          ),
                        ),
                        const Spacer(),
                        SizedBox(
                          height: 36,
                          child: FilledButton(
                            onPressed: purchasing ||
                                    state.purchasingId != null
                                ? null
                                : () => context
                                    .read<BoosterStoreCubit>()
                                    .purchase(b.id),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18),
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
                                : const Text('Buy'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
