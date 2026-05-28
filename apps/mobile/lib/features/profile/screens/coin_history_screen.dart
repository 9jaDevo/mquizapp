import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mquiz/core/theme/app_colors.dart';
import 'package:mquiz/core/utils/error_handler.dart';
import 'package:mquiz/core/widgets/common_widgets.dart';
import 'package:mquiz/features/profile/data/profile_repository.dart';
import 'package:mquiz/features/profile/models/profile_extras_model.dart';

class CoinHistoryScreen extends StatefulWidget {
  const CoinHistoryScreen({super.key});

  @override
  State<CoinHistoryScreen> createState() => _CoinHistoryScreenState();
}

class _CoinHistoryScreenState extends State<CoinHistoryScreen> {
  final _items = <CoinHistoryEntry>[];
  int _page = 1;
  int _totalPages = 1;
  bool _loading = false;
  String? _error;
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    _load();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scroll.position.pixels >
            _scroll.position.maxScrollExtent - 200 &&
        !_loading &&
        _page < _totalPages) {
      _load();
    }
  }

  Future<void> _load() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repo = context.read<ProfileRepository>();
      final page = _items.isEmpty ? 1 : _page + 1;
      final result = await repo.fetchCoinHistory(page: page, limit: 20);
      if (!mounted) return;
      setState(() {
        if (page == 1) _items.clear();
        _items.addAll(result.items);
        _page = result.page;
        _totalPages = result.totalPages;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = describeError(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        title: const Text('Coin History'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_items.isEmpty && _loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_items.isEmpty && _error != null) {
      return ErrorStateView(message: _error!, onRetry: _load);
    }
    if (_items.isEmpty) {
      return const EmptyStateView(
        message: 'No coin transactions yet.',
        icon: Icons.bolt_outlined,
      );
    }
    return RefreshIndicator(
      onRefresh: () async {
        _page = 1;
        await _load();
      },
      child: ListView.separated(
        controller: _scroll,
        padding: const EdgeInsets.all(16),
        itemCount: _items.length + (_page < _totalPages ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (ctx, i) {
          if (i >= _items.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final e = _items[i];
          final color = e.isEarned ? AppColors.coinAdd : AppColors.coinDeduct;
          final sign = e.isEarned ? '+' : '-';
          return Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(ctx).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Icon(
                  e.isEarned
                      ? Icons.arrow_downward_rounded
                      : Icons.arrow_upward_rounded,
                  color: color,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _humanizeType(e.type),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        _formatDate(e.date),
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Text(
                  '$sign${e.points}',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _humanizeType(String type) {
    if (type.isEmpty) return 'Coins';
    return type
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  String _formatDate(DateTime d) {
    final local = d.toLocal();
    return '${local.year}-${_p(local.month)}-${_p(local.day)} '
        '${_p(local.hour)}:${_p(local.minute)}';
  }

  String _p(int n) => n.toString().padLeft(2, '0');
}
