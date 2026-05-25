import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mquiz/core/constants/app_constants.dart';
import 'package:mquiz/core/theme/app_colors.dart';
import 'package:mquiz/core/widgets/common_widgets.dart';
import 'package:mquiz/features/progress/cubit/progress_cubit.dart';
import 'package:mquiz/features/progress/models/progress_stage_model.dart';

class ProgressMapScreen extends StatefulWidget {
  const ProgressMapScreen({super.key});

  @override
  State<ProgressMapScreen> createState() => _ProgressMapScreenState();
}

class _ProgressMapScreenState extends State<ProgressMapScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProgressCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        title: const Text('Your Journey'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<ProgressCubit, ProgressState>(
        builder: (context, state) => switch (state) {
          ProgressInitial() ||
          ProgressLoading() =>
            const Center(child: CircularProgressIndicator()),
          ProgressError(message: final m) => ErrorStateView(
              message: m,
              onRetry: () => context.read<ProgressCubit>().load(),
            ),
          ProgressLoaded() => _Body(state: state),
        },
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.state});
  final ProgressLoaded state;

  @override
  Widget build(BuildContext context) {
    if (state.stages.isEmpty) {
      return const EmptyStateView(
        message: 'Progress stages will appear here once available.',
        icon: Icons.map_outlined,
      );
    }
    return RefreshIndicator(
      onRefresh: () => context.read<ProgressCubit>().load(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        itemCount: state.stages.length + 1,
        itemBuilder: (ctx, i) {
          if (i == 0) return _Header(state: state);
          final stage = state.stages[i - 1];
          final alignLeft = stage.stageNumber.isOdd;
          return _StageNode(stage: stage, alignLeft: alignLeft);
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.state});
  final ProgressLoaded state;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.star, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            '${state.totalStars} stars earned',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),
          Text(
            'Stage ${state.currentStage}',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StageNode extends StatelessWidget {
  const _StageNode({required this.stage, required this.alignLeft});
  final ProgressStage stage;
  final bool alignLeft;

  void _onTap(BuildContext context) {
    if (!stage.unlocked) return;
    if (stage.categoryId != null) {
      final params = <String, String>{
        'categoryId': stage.categoryId.toString(),
        if (stage.subcategoryId != null)
          'subcategoryId': stage.subcategoryId.toString(),
        'stage': stage.stageNumber.toString(),
      };
      context.push(
        Uri(path: AppConstants.routeQuiz, queryParameters: params).toString(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final locked = !stage.unlocked;
    final done = stage.completed;
    final color = locked
        ? AppColors.border
        : done
            ? AppColors.correct
            : AppColors.primary;
    final node = GestureDetector(
      onTap: locked ? null : () => _onTap(context),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: locked
                  ? null
                  : [
                      BoxShadow(
                        color: color.withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: Icon(
              locked
                  ? Icons.lock
                  : done
                      ? Icons.check
                      : Icons.play_arrow_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Stage ${stage.stageNumber}',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          Text(
            stage.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          if (done)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(stage.maxStars, (i) {
                  final earned = i < stage.starsEarned;
                  return Icon(
                    earned ? Icons.star : Icons.star_border,
                    size: 14,
                    color: AppColors.coin,
                  );
                }),
              ),
            ),
        ],
      ),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment:
            alignLeft ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          if (!alignLeft) const Spacer(),
          node,
          if (alignLeft) const Spacer(),
        ],
      ),
    );
  }
}
