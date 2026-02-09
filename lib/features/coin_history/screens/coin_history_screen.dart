import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/core/core.dart';
import 'package:flutterquiz/features/ads/ads.dart';
import 'package:flutterquiz/features/coin_history/blocs/coin_history_cubit.dart';
import 'package:flutterquiz/features/coin_history/models/coin_history.dart';
import 'package:flutterquiz/features/coin_history/repos/coin_history_repository.dart';
import 'package:flutterquiz/features/profile_management/cubits/user_details_cubit.dart';
import 'package:flutterquiz/ui/widgets/already_logged_in_dialog.dart';
import 'package:flutterquiz/ui/widgets/circular_progress_container.dart';
import 'package:flutterquiz/ui/widgets/error_container.dart';
import 'package:flutterquiz/utils/datetime_utils.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';

enum _HistoryFilter { all, earned, spent, bonus }

final class CoinHistoryScreen extends StatefulWidget {
  const CoinHistoryScreen({super.key});

  @override
  State<CoinHistoryScreen> createState() => _CoinHistoryScreenState();

  static Route<dynamic> route() {
    return CupertinoPageRoute(
      builder: (_) => BlocProvider<CoinHistoryCubit>(
        create: (_) => CoinHistoryCubit(CoinHistoryRepository()),
        child: const CoinHistoryScreen(),
      ),
    );
  }
}

final class _CoinHistoryScreenState extends State<CoinHistoryScreen> {
  late final ScrollController _scrollController;
  late final CoinHistoryCubit _coinHistoryCubit;
  late final UserDetailsCubit _userDetailsCubit;
  final TextEditingController _searchController = TextEditingController();
  _HistoryFilter _activeFilter = _HistoryFilter.all;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    _coinHistoryCubit = context.read<CoinHistoryCubit>();
    _userDetailsCubit = context.read<UserDetailsCubit>();
    _fetchInitialHistory();
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _fetchInitialHistory() {
    unawaited(_coinHistoryCubit.fetchInitialHistory());
  }

  void _setSearchQuery(String value) {
    setState(() {
      _searchQuery = value.trim();
    });
  }

  void _setFilter(_HistoryFilter filter) {
    setState(() {
      _activeFilter = filter;
    });
  }

  void _onScroll() {
    if (!_isScrolledToBottom) return;

    if (_coinHistoryCubit.hasMoreHistory) {
      unawaited(
        _coinHistoryCubit.fetchMoreHistory(userId: _userDetailsCubit.userId()),
      );
    }
  }

  bool get _isScrolledToBottom =>
      _scrollController.position.pixels >=
      _scrollController.position.maxScrollExtent;

  Widget _buildListItem({
    required CoinHistory transaction,
  }) {
    return _CoinHistoryItem(transaction: transaction);
  }

  Widget _buildLoadMoreIndicator({required bool hasError}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        child: hasError
            ? IconButton(
                onPressed: () => unawaited(
                  _coinHistoryCubit.fetchMoreHistory(
                    userId: _userDetailsCubit.userId(),
                  ),
                ),
                icon: Icon(Icons.error, color: context.primaryColor),
              )
            : const CircularProgressContainer(),
      ),
    );
  }

  Widget _buildContent() {
    return BlocConsumer<CoinHistoryCubit, CoinHistoryState>(
      bloc: _coinHistoryCubit,
      listenWhen: (previous, current) =>
          current is CoinHistoryFetchFailure &&
          current.errorMessage == errorCodeUnauthorizedAccess,
      listener: _handleStateChanges,
      buildWhen: (previous, current) =>
          // Only rebuild when state type changes, not on pagination updates
          previous.runtimeType != current.runtimeType ||
          (current is CoinHistoryFetchSuccess &&
              previous is CoinHistoryFetchSuccess &&
              (current.coinHistory.length != previous.coinHistory.length ||
                  current.hasMoreFetchError != previous.hasMoreFetchError)),
      builder: (context, state) {
        return switch (state) {
          CoinHistoryFetchFailure() => _buildErrorState(state),
          CoinHistoryFetchSuccess() => _buildHistoryList(state),
          _ => const Center(child: CircularProgressContainer()),
        };
      },
    );
  }

  void _handleStateChanges(BuildContext context, CoinHistoryState state) {
    if (state is CoinHistoryFetchFailure &&
        state.errorMessage == errorCodeUnauthorizedAccess) {
      unawaited(showAlreadyLoggedInDialog(context));
    }
  }

  Widget _buildErrorState(CoinHistoryFetchFailure state) {
    return Center(
      child: ErrorContainer(
        errorMessageColor: context.primaryColor,
        errorMessage: convertErrorCodeToLanguageKey(state.errorMessage),
        onTapRetry: _fetchInitialHistory,
        showErrorImage: true,
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
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
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: Color(0xFF1E4FD9),
            ),
          ),
        ),
        const Expanded(child: SizedBox()),
        Text(
          'Coin History',
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1E4FD9),
          ),
        ),
        const Expanded(child: SizedBox()),
        const SizedBox(width: 44),
      ],
    );
  }

  Widget _buildSummaryRow({
    required int balance,
    required int earned,
    required int spent,
  }) {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            title: 'Balance',
            value: UiUtils.formatNumber(balance),
            tint: const Color(0xFFE7ECFF),
            accent: const Color(0xFF2E5BEA),
            icon: Icons.account_balance_wallet_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            title: 'Earned',
            value: '+${UiUtils.formatNumber(earned)}',
            tint: const Color(0xFFE9F9F1),
            accent: const Color(0xFF22C55E),
            icon: Icons.trending_up_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            title: 'Spent',
            value: '-${UiUtils.formatNumber(spent)}',
            tint: const Color(0xFFFFECEC),
            accent: const Color(0xFFEF4444),
            icon: Icons.trending_down_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required Color tint,
    required Color accent,
    required IconData icon,
  }) {
    return Container(
      height: 118,
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

  Widget _buildSearchBar() {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            color: const Color(0xFF94A3B8),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: _setSearchQuery,
              decoration: const InputDecoration(
                hintText: 'Search transactions...',
                border: InputBorder.none,
                isDense: true,
              ),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip(label: 'All', filter: _HistoryFilter.all),
          const SizedBox(width: 10),
          _buildFilterChip(label: 'Earned', filter: _HistoryFilter.earned),
          const SizedBox(width: 10),
          _buildFilterChip(label: 'Spent', filter: _HistoryFilter.spent),
          const SizedBox(width: 10),
          _buildFilterChip(label: 'Bonus', filter: _HistoryFilter.bonus),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required _HistoryFilter filter,
  }) {
    final isActive = _activeFilter == filter;

    return GestureDetector(
      onTap: () => _setFilter(filter),
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF2E5BEA) : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isActive ? Colors.transparent : const Color(0xFF2E5BEA),
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isActive ? Colors.white : const Color(0xFF2E5BEA),
            ),
          ),
        ),
      ),
    );
  }

  List<CoinHistory> _applyFilters(List<CoinHistory> items) {
    final query = _searchQuery.toLowerCase();

    return items.where((item) {
      final type = (context.tr(item.type) ?? item.type).toLowerCase();
      final matchesSearch = query.isEmpty ||
          type.contains(query) ||
          item.pointsValue.toString().contains(query);

      if (!matchesSearch) return false;

      return switch (_activeFilter) {
        _HistoryFilter.all => true,
        _HistoryFilter.earned => !item.isDeduction && !_isBonusType(item),
        _HistoryFilter.spent => item.isDeduction,
        _HistoryFilter.bonus => _isBonusType(item),
      };
    }).toList();
  }

  bool _isBonusType(CoinHistory item) {
    final type = (item.type).toLowerCase();
    return type.contains('bonus') ||
        type.contains('admin') ||
        type.contains('reward') ||
        type.contains('refer');
  }

  int _sumEarned(List<CoinHistory> items) {
    var total = 0;
    for (final item in items) {
      if (!item.isDeduction) {
        total += item.pointsValue;
      }
    }
    return total;
  }

  int _sumSpent(List<CoinHistory> items) {
    var total = 0;
    for (final item in items) {
      if (item.isDeduction) {
        total += item.pointsValue;
      }
    }
    return total;
  }

  Widget _buildHistoryList(CoinHistoryFetchSuccess state) {
    final filtered = _applyFilters(state.coinHistory);
    final balance = int.tryParse(_userDetailsCubit.getCoins() ?? '0') ?? 0;
    final earned = _sumEarned(state.coinHistory);
    final spent = _sumSpent(state.coinHistory);

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopBar(),
                const SizedBox(height: 18),
                _buildSummaryRow(
                  balance: balance,
                  earned: earned,
                  spent: spent,
                ),
                const SizedBox(height: 18),
                _buildSearchBar(),
                const SizedBox(height: 14),
                _buildFilterChips(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        SliverList.separated(
          itemCount: filtered.length,
          separatorBuilder: (context, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) => _buildListItem(
            transaction: filtered[index],
          ),
        ),
        if (state.hasMore)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: _buildLoadMoreIndicator(hasError: state.hasMoreFetchError),
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 18)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final showBannerAd =
        context.watch<BannerAdCubit>().bannerAdLoaded &&
        !_userDetailsCubit.removeAds();

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FF),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: showBannerAd ? 60 : 0),
            child: _buildContent(),
          ),
          const Align(
            alignment: Alignment.bottomCenter,
            child: BannerAdContainer(),
          ),
        ],
      ),
    );
  }
}

/// Individual coin history transaction item widget
class _CoinHistoryItem extends StatelessWidget {
  const _CoinHistoryItem({required this.transaction});

  final CoinHistory transaction;

  static const double _borderRadius = 20;

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateTimeUtils.dateFormat.format(
      DateTime.parse(transaction.date),
    );
    final style = _TransactionStyle.from(transaction);
    final title = context.tr(transaction.type) ?? transaction.type;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [style.tint, style.tint.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(_borderRadius),
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
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: style.accent,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: style.accent.withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(
              style.icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: _TransactionDetails(
              type: title,
              date: formattedDate,
              accent: style.accent,
            ),
          ),
          const SizedBox(width: 12),
          _AmountPill(
            points: transaction.pointsValue,
            isDeduction: transaction.isDeduction,
            accent: style.accent,
          ),
        ],
      ),
    );
  }
}

/// Transaction type and date display
class _TransactionDetails extends StatelessWidget {
  const _TransactionDetails({
    required this.type,
    required this.date,
    required this.accent,
  });

  final String type;
  final String date;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          type,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: accent,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 12,
              color: accent.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 4),
            Text(
              date,
              style: TextStyle(
                color: accent.withValues(alpha: 0.6),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Coin points badge with gradient and shadow
class _AmountPill extends StatelessWidget {
  const _AmountPill({
    required this.points,
    required this.isDeduction,
    required this.accent,
  });

  final int points;
  final bool isDeduction;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 64),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: accent,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Text(
        isDeduction
            ? '-${UiUtils.formatNumber(points)}'
            : '+${UiUtils.formatNumber(points)}',
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _TransactionStyle {
  const _TransactionStyle({
    required this.tint,
    required this.accent,
    required this.icon,
  });

  final Color tint;
  final Color accent;
  final IconData icon;

  static _TransactionStyle from(CoinHistory transaction) {
    final type = transaction.type.toLowerCase();
    final isBonus = type.contains('bonus') ||
        type.contains('admin') ||
        type.contains('reward') ||
        type.contains('refer');

    if (isBonus) {
      return const _TransactionStyle(
        tint: Color(0xFFFFF6DA),
        accent: Color(0xFFF59E0B),
        icon: Icons.star_rounded,
      );
    }

    if (transaction.isDeduction) {
      return const _TransactionStyle(
        tint: Color(0xFFFFE8EC),
        accent: Color(0xFFEF4444),
        icon: Icons.remove_circle_rounded,
      );
    }

    return const _TransactionStyle(
      tint: Color(0xFFE8F8EF),
      accent: Color(0xFF22C55E),
      icon: Icons.add_circle_rounded,
    );
  }
}
