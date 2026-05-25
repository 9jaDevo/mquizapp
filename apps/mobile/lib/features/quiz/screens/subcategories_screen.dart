import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mquiz/core/theme/app_colors.dart';
import 'package:mquiz/core/widgets/common_widgets.dart';
import 'package:mquiz/features/quiz/cubit/categories_cubit.dart';
import 'package:mquiz/features/quiz/cubit/quiz_cubit.dart';
import 'package:mquiz/features/quiz/models/category_model.dart';

class SubcategoriesScreen extends StatefulWidget {
  const SubcategoriesScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  final int categoryId;
  final String categoryName;

  @override
  State<SubcategoriesScreen> createState() => _SubcategoriesScreenState();
}

class _SubcategoriesScreenState extends State<SubcategoriesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SubcategoriesCubit>().load(widget.categoryId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        title: Text(widget.categoryName),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<SubcategoriesCubit, SubcategoriesState>(
        builder: (context, state) {
          return switch (state) {
            SubcategoriesInitial() ||
            SubcategoriesLoading() =>
              const Center(child: CircularProgressIndicator()),
            SubcategoriesError(message: final msg) => ErrorStateView(
                message: msg,
                onRetry: () => context
                    .read<SubcategoriesCubit>()
                    .load(widget.categoryId),
              ),
            SubcategoriesLoaded(:final items) => items.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const EmptyStateView(
                            message: 'No topics yet. Start a quick quiz?',
                            icon: Icons.quiz_outlined,
                          ),
                          PrimaryButton(
                            label: 'Start Quiz',
                            icon: Icons.play_arrow_rounded,
                            expand: false,
                            onPressed: () => _startQuiz(context, null),
                          ),
                        ],
                      ),
                    ),
                  )
                : _SubcategoryList(
                    items: items,
                    onTap: (s) => _startQuiz(context, s),
                  ),
          };
        },
      ),
    );
  }

  void _startQuiz(BuildContext context, Subcategory? sub) {
    context.read<QuizCubit>().start(
          categoryId: widget.categoryId,
          subcategoryId: sub?.id,
          level: 1,
        );
    context.push('/quiz');
  }
}

class _SubcategoryList extends StatelessWidget {
  const _SubcategoryList({required this.items, required this.onTap});
  final List<Subcategory> items;
  final ValueChanged<Subcategory> onTap;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (ctx, i) {
        final s = items[i];
        return GlassCard(
          onTap: () => onTap(s),
          child: Row(
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.bookmarks_outlined,
                    color: AppColors.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Up to level ${s.maxLevel}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        );
      },
    );
  }
}
