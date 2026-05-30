import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mquiz/core/theme/app_colors.dart';
import 'package:mquiz/core/widgets/common_widgets.dart';
import 'package:mquiz/features/bookmarks/cubit/bookmarks_cubit.dart';
import 'package:mquiz/features/bookmarks/models/bookmark_model.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  late final ScrollController _scroll;

  @override
  void initState() {
    super.initState();
    _scroll = ScrollController()..addListener(_onScroll);
    final cubit = context.read<BookmarksCubit>();
    if (cubit.state is BookmarksInitial) cubit.load();
  }

  void _onScroll() {
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200) {
      context.read<BookmarksCubit>().loadMore();
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        title: const Text('Saved Questions'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<BookmarksCubit, BookmarksState>(
        builder: (context, state) {
          return switch (state) {
            BookmarksInitial() ||
            BookmarksLoading() =>
              const Center(child: CircularProgressIndicator()),
            BookmarksError(message: final msg) => ErrorStateView(
                message: msg,
                onRetry: () => context.read<BookmarksCubit>().load(),
              ),
            BookmarksLoaded(:final items, :final hasMore) => items.isEmpty
                ? const EmptyStateView(
                    message:
                        'No saved questions yet.\nBookmark a question during a quiz to see it here.',
                    icon: Icons.bookmark_border_rounded,
                  )
                : RefreshIndicator(
                    onRefresh: () =>
                        context.read<BookmarksCubit>().load(),
                    child: ListView.separated(
                      controller: _scroll,
                      padding: const EdgeInsets.all(16),
                      itemCount: items.length + (hasMore ? 1 : 0),
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 12),
                      itemBuilder: (ctx, i) {
                        if (i == items.length) {
                          return const Center(
                              child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(),
                          ));
                        }
                        return _BookmarkCard(
                          bookmark: items[i],
                          onDelete: () => context
                              .read<BookmarksCubit>()
                              .remove(items[i].questionId),
                        );
                      },
                    ),
                  ),
          };
        },
      ),
    );
  }
}

class _BookmarkCard extends StatelessWidget {
  const _BookmarkCard({required this.bookmark, required this.onDelete});
  final BookmarkModel bookmark;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final b = bookmark;
    final options = <String>[
      if (b.optiona != null) b.optiona!,
      if (b.optionb != null) b.optionb!,
      if (b.optionc != null) b.optionc!,
      if (b.optiond != null) b.optiond!,
    ];
    final correctLabel = switch (b.correctOption.toLowerCase()) {
      'a' => b.optiona,
      'b' => b.optionb,
      'c' => b.optionc,
      'd' => b.optiond,
      _ => null,
    };

    return Dismissible(
      key: ValueKey(b.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.wrong.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: AppColors.wrong),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.bookmark_rounded,
                    color: AppColors.primary, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    b.questionText,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            if (options.isNotEmpty) ...[
              const SizedBox(height: 10),
              ...options.asMap().entries.map((e) {
                final letter = String.fromCharCode(65 + e.key); // A, B, C, D
                final isCorrect =
                    b.correctOption.toUpperCase() == letter;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isCorrect
                              ? AppColors.correct.withValues(alpha: 0.15)
                              : AppColors.border,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          letter,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isCorrect
                                ? AppColors.correct
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          e.value,
                          style: TextStyle(
                            fontSize: 13,
                            color: isCorrect
                                ? AppColors.correct
                                : AppColors.textPrimary,
                            fontWeight: isCorrect
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
            if (correctLabel != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.check_circle_outline,
                      size: 14, color: AppColors.correct),
                  const SizedBox(width: 4),
                  Text(
                    'Answer: $correctLabel',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.correct,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
