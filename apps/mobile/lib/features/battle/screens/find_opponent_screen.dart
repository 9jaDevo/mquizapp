import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mquiz/core/constants/app_constants.dart';
import 'package:mquiz/core/theme/app_colors.dart';
import 'package:mquiz/core/widgets/common_widgets.dart';
import 'package:mquiz/features/auth/cubit/auth_cubit.dart';
import 'package:mquiz/features/battle/cubit/battle_cubit.dart';
import 'package:mquiz/features/quiz/models/category_model.dart';

/// Entry point for the battle flow: category selection → matchmaking.
/// The screen handles both stages within one view using state switching.
class FindOpponentScreen extends StatelessWidget {
  const FindOpponentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<BattleCubit, BattleState>(
      listenWhen: (_, cur) =>
          cur is BattleInProgress || cur is BattleError || cur is BattleCompleted,
      listener: (ctx, state) {
        if (state is BattleInProgress) {
          ctx.push(AppConstants.routeBattleLive);
        } else if (state is BattleCompleted) {
          ctx.pushReplacement(AppConstants.routeBattleResult);
        } else if (state is BattleError) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(
              content: Text(state.message),
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.wrong,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.pageBackground,
        appBar: AppBar(
          title: const Text('Battle'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: BlocBuilder<BattleCubit, BattleState>(
          builder: (context, state) => switch (state) {
            BattleIdle() => _IdleView(
                onStart: () =>
                    context.read<BattleCubit>().loadCategories(),
              ),
            BattleLoadingCategories() =>
              const Center(child: CircularProgressIndicator()),
            BattleCategoryPicker(categories: final cats) =>
              _CategoryPickerView(categories: cats),
            BattleMatchmaking(categoryName: final name) =>
              _MatchmakingView(categoryName: name),
            BattleWaiting(categoryName: final name) =>
              _WaitingView(categoryName: name),
            // These states navigate away immediately via listener
            BattleInProgress() ||
            BattleSubmitting() ||
            BattleCompleted() =>
              const Center(child: CircularProgressIndicator()),
            BattleError(message: final msg) => ErrorStateView(
                message: msg,
                onRetry: () =>
                    context.read<BattleCubit>().loadCategories(),
              ),
          },
        ),
      ),
    );
  }
}

class _IdleView extends StatelessWidget {
  const _IdleView({required this.onStart});
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.shield_rounded,
                color: Colors.white, size: 60),
          ),
          const SizedBox(height: 24),
          const Text(
            '1v1 Battle',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 26),
          ),
          const SizedBox(height: 8),
          const Text(
            'Challenge a random opponent in a live quiz battle.\nThe player with more correct answers wins!',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, height: 1.5),
          ),
          const SizedBox(height: 40),
          PrimaryButton(
            label: 'Find Opponent',
            icon: Icons.search_rounded,
            onPressed: onStart,
          ),
        ],
      ),
    );
  }
}

class _CategoryPickerView extends StatelessWidget {
  const _CategoryPickerView({required this.categories});
  final List<Category> categories;

  @override
  Widget build(BuildContext context) {
    final user = (context.read<AuthCubit>().state as Authenticated?)?.user;
    if (user == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 20, 16, 12),
          child: Text(
            'Choose a Category',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.4,
            ),
            itemCount: categories.length,
            itemBuilder: (_, i) => _CategoryTile(
              category: categories[i],
              onTap: () => context.read<BattleCubit>().startMatchmaking(
                    category: categories[i],
                    user: user,
                  ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.category, required this.onTap});
  final Category category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (category.image != null)
                Image.network(
                  category.image!,
                  height: 36,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.category_outlined,
                    size: 36,
                    color: AppColors.primary,
                  ),
                )
              else
                const Icon(Icons.category_outlined,
                    size: 36, color: AppColors.primary),
              const SizedBox(height: 8),
              Text(
                category.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MatchmakingView extends StatelessWidget {
  const _MatchmakingView({required this.categoryName});
  final String categoryName;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(strokeWidth: 3),
            const SizedBox(height: 24),
            Text(
              'Finding an opponent for\n$categoryName…',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () => context.read<BattleCubit>().cancel(),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}

class _WaitingView extends StatelessWidget {
  const _WaitingView({required this.categoryName});
  final String categoryName;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.hourglass_top_rounded,
                size: 64, color: AppColors.primary),
            const SizedBox(height: 20),
            const Text(
              'Waiting for opponent…',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Category: $categoryName',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 32),
            const LinearProgressIndicator(
              backgroundColor: AppColors.divider,
              valueColor:
                  AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: () => context.read<BattleCubit>().cancel(),
              icon: const Icon(Icons.close),
              label: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}
