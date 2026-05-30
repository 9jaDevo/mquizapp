import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mquiz/core/theme/app_colors.dart';
import 'package:mquiz/core/widgets/common_widgets.dart';
import 'package:mquiz/features/auth/cubit/auth_cubit.dart';
import 'package:mquiz/features/leaderboard/cubit/leaderboard_cubit.dart';
import 'package:mquiz/features/leaderboard/data/leaderboard_repository.dart';
import 'package:mquiz/features/leaderboard/models/leaderboard_entry_model.dart';
import 'package:mquiz/features/quiz/cubit/categories_cubit.dart';
import 'package:mquiz/features/quiz/models/category_model.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  static const _periods = LeaderboardPeriod.values;

  // Category tab state
  int? _selectedCategoryId;
  LeaderboardPeriod _categoryPeriod = LeaderboardPeriod.weekly;

  static const _categoryTabIndex = 3; // 4th tab (0-indexed)

  int? _currentUserId() {
    final s = context.read<AuthCubit>().state;
    if (s is Authenticated) return int.tryParse(s.user.userId);
    return null;
  }

  @override
  void initState() {
    super.initState();
    // 3 period tabs + 1 category tab = 4 total
    _tabs = TabController(length: 4, vsync: this, initialIndex: 1);
    _tabs.addListener(_onTabChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<LeaderboardCubit>()
          .load(_periods[_tabs.index], currentUserId: _currentUserId());
      // Preload categories for the category tab
      final cats = context.read<CategoriesCubit>();
      if (cats.state is CategoriesInitial) cats.load();
    });
  }

  void _onTabChanged() {
    if (!_tabs.indexIsChanging) return;
    if (_tabs.index == _categoryTabIndex) {
      // Category tab selected — if a category is already picked, reload it
      if (_selectedCategoryId != null) {
        context.read<LeaderboardCubit>().loadCategoryTop(
              _selectedCategoryId!,
              _categoryPeriod,
              currentUserId: _currentUserId(),
            );
      }
      return;
    }
    context
        .read<LeaderboardCubit>()
        .load(_periods[_tabs.index], currentUserId: _currentUserId());
  }

  void _onCategorySelected(int categoryId) {
    setState(() => _selectedCategoryId = categoryId);
    context.read<LeaderboardCubit>().loadCategoryTop(
          categoryId,
          _categoryPeriod,
          currentUserId: _currentUserId(),
        );
  }

  void _onCategoryPeriodChanged(LeaderboardPeriod p) {
    setState(() => _categoryPeriod = p);
    if (_selectedCategoryId != null) {
      context.read<LeaderboardCubit>().loadCategoryTop(
            _selectedCategoryId!,
            p,
            currentUserId: _currentUserId(),
          );
    }
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        title: const Text('Leaderboard'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700),
          isScrollable: true,
          tabAlignment: TabAlignment.center,
          tabs: [
            for (final p in _periods) Tab(text: p.label),
            const Tab(text: 'Category'),
          ],
        ),
      ),
      body: BlocBuilder<LeaderboardCubit, LeaderboardState>(
        builder: (context, state) {
          // Show category tab content
          if (_tabs.index == _categoryTabIndex) {
            return _CategoryLeaderboardTab(
              state: state,
              selectedCategoryId: _selectedCategoryId,
              selectedPeriod: _categoryPeriod,
              onCategorySelected: _onCategorySelected,
              onPeriodChanged: _onCategoryPeriodChanged,
            );
          }

          return switch (state) {
            LeaderboardInitial() ||
            LeaderboardLoading() =>
              const Center(child: CircularProgressIndicator()),
            LeaderboardError(message: final msg) => ErrorStateView(
                message: msg,
                onRetry: () => context.read<LeaderboardCubit>().load(
                      _periods[_tabs.index],
                      currentUserId: _currentUserId(),
                    ),
              ),
            LeaderboardLoaded(:final entries, :final myRank, :final period) =>
              Column(
                children: [
                  _MyRankBanner(myRank: myRank, period: period),
                  Expanded(
                    child: entries.isEmpty
                        ? const EmptyStateView(
                            message: 'No rankings yet — play a quiz to get on the board!',
                            icon: Icons.leaderboard_outlined,
                          )
                        : _RankList(entries: entries),
                  ),
                ],
              ),
            // Category states and fallback
            _ => const Center(child: CircularProgressIndicator()),
          };
        },
      ),
    );
  }
}

// ── Category Leaderboard Tab ─────────────────────────────────────────────────

class _CategoryLeaderboardTab extends StatelessWidget {
  const _CategoryLeaderboardTab({
    required this.state,
    required this.selectedCategoryId,
    required this.selectedPeriod,
    required this.onCategorySelected,
    required this.onPeriodChanged,
  });
  final LeaderboardState state;
  final int? selectedCategoryId;
  final LeaderboardPeriod selectedPeriod;
  final ValueChanged<int> onCategorySelected;
  final ValueChanged<LeaderboardPeriod> onPeriodChanged;

  @override
  Widget build(BuildContext context) {
    final catState = context.watch<CategoriesCubit>().state;
    final categories = catState is CategoriesLoaded ? catState.categories : <Category>[];

    return Column(
      children: [
        // Period chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
          child: Row(
            children: LeaderboardPeriod.values.map((p) {
              final selected = p == selectedPeriod;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(p.label),
                  selected: selected,
                  onSelected: (_) => onPeriodChanged(p),
                  selectedColor: AppColors.primary.withValues(alpha: 0.15),
                  labelStyle: TextStyle(
                    color: selected ? AppColors.primary : AppColors.textSecondary,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        // Category chips
        if (categories.isNotEmpty)
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final cat = categories[i];
                final isSelected = cat.id == selectedCategoryId;
                return FilterChip(
                  label: Text(cat.name),
                  selected: isSelected,
                  onSelected: (_) => onCategorySelected(cat.id),
                  selectedColor: AppColors.primary.withValues(alpha: 0.15),
                  labelStyle: TextStyle(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
        // Leaderboard entries
        Expanded(
          child: switch (state) {
            CategoryLeaderboardLoading() =>
              const Center(child: CircularProgressIndicator()),
            LeaderboardError(message: final msg) => ErrorStateView(
                message: msg,
                onRetry: () {},
              ),
            CategoryLeaderboardLoaded(:final entries) => entries.isEmpty
                ? const EmptyStateView(
                    message: 'No rankings yet for this category.',
                    icon: Icons.leaderboard_outlined,
                  )
                : _RankList(entries: entries),
            _ => selectedCategoryId == null
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Select a category above to see rankings',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  )
                : const Center(child: CircularProgressIndicator()),
          },
        ),
      ],
    );
  }
}

class _MyRankBanner extends StatelessWidget {
  const _MyRankBanner({required this.myRank, required this.period});
  final Map<String, dynamic> myRank;
  final LeaderboardPeriod period;

  @override
  Widget build(BuildContext context) {
    final data = myRank[period.name] as Map<String, dynamic>?;
    if (data == null) return const SizedBox.shrink();
    final rank = data['rank'] as int?;
    final score = (data['score'] as num?)?.toInt() ?? 0;
    final inTop1000 = data['inTop1000'] as bool? ?? false;
    if (!inTop1000 || rank == null) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.person_pin_rounded, color: AppColors.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Your rank: #$rank',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
          Row(
            children: [
              const Icon(Icons.star_rounded, color: AppColors.coin, size: 16),
              const SizedBox(width: 4),
              Text('$score pts', style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}

class _RankList extends StatelessWidget {
  const _RankList({required this.entries});
  final List<LeaderboardEntry> entries;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: entries.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (ctx, i) => _RankRow(entry: entries[i]),
    );
  }
}

class _RankRow extends StatelessWidget {
  const _RankRow({required this.entry});
  final LeaderboardEntry entry;

  @override
  Widget build(BuildContext context) {
    Color rankColor() {
      if (entry.rank == 1) return AppColors.coin;
      if (entry.rank == 2) return Colors.grey.shade500;
      if (entry.rank == 3) return const Color(0xFFCD7F32);
      return AppColors.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: entry.isMe
            ? AppColors.primary.withValues(alpha: 0.08)
            : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: entry.isMe ? AppColors.primary : AppColors.border,
          width: entry.isMe ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(
              '#${entry.rank}',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: rankColor(),
              ),
            ),
          ),
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.divider,
            backgroundImage: entry.profileImage != null
                ? NetworkImage(entry.profileImage!)
                : null,
            child: entry.profileImage == null
                ? Text(
                    entry.name.isNotEmpty
                        ? entry.name[0].toUpperCase()
                        : '?',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              entry.name + (entry.isMe ? ' (You)' : ''),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Row(
            children: [
              const Icon(Icons.star_rounded,
                  color: AppColors.coin, size: 18),
              const SizedBox(width: 4),
              Text(
                '${entry.score}',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
