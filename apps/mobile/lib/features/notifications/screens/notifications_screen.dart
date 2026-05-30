import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mquiz/core/theme/app_colors.dart';
import 'package:mquiz/core/widgets/common_widgets.dart';
import 'package:mquiz/features/notifications/cubit/notifications_cubit.dart';
import 'package:mquiz/features/notifications/models/notification_model.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late final ScrollController _scroll;

  @override
  void initState() {
    super.initState();
    _scroll = ScrollController()..addListener(_onScroll);
    final cubit = context.read<NotificationsCubit>();
    if (cubit.state is NotificationsInitial) cubit.load();
  }

  void _onScroll() {
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200) {
      context.read<NotificationsCubit>().loadMore();
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
        title: const Text('Notifications'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<NotificationsCubit, NotificationsState>(
        builder: (context, state) {
          return switch (state) {
            NotificationsInitial() ||
            NotificationsLoading() =>
              const Center(child: CircularProgressIndicator()),
            NotificationsError(message: final msg) => ErrorStateView(
                message: msg,
                onRetry: () => context.read<NotificationsCubit>().load(),
              ),
            NotificationsLoaded(:final items, :final hasMore) =>
              items.isEmpty
                  ? const EmptyStateView(
                      message: 'No notifications yet.',
                      icon: Icons.notifications_none_outlined,
                    )
                  : RefreshIndicator(
                      onRefresh: () =>
                          context.read<NotificationsCubit>().load(),
                      child: ListView.separated(
                        controller: _scroll,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: items.length + (hasMore ? 1 : 0),
                        separatorBuilder: (_, __) =>
                            const Divider(height: 1, indent: 72),
                        itemBuilder: (ctx, i) {
                          if (i == items.length) {
                            return const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(
                                  child: CircularProgressIndicator()),
                            );
                          }
                          return _NotificationTile(
                            notification: items[i],
                            onTap: () => _onTap(ctx, items[i]),
                          );
                        },
                      ),
                    ),
          };
        },
      ),
    );
  }

  void _onTap(BuildContext context, NotificationModel n) {
    if (!n.isRead) {
      context.read<NotificationsCubit>().markRead(n.id);
    }
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(n.title),
        content: Text(n.message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification, required this.onTap});
  final NotificationModel notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final n = notification;
    final timeStr = _formatTime(n.dateSent);
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: n.isRead
            ? AppColors.border
            : AppColors.primary.withValues(alpha: 0.12),
        child: Icon(
          _iconForType(n.type),
          color: n.isRead ? AppColors.textSecondary : AppColors.primary,
          size: 20,
        ),
      ),
      title: Text(
        n.title,
        style: TextStyle(
          fontWeight: n.isRead ? FontWeight.w400 : FontWeight.w700,
          fontSize: 14,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        n.message,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
          fontWeight: n.isRead ? FontWeight.normal : FontWeight.w500,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            timeStr,
            style: const TextStyle(
                fontSize: 11, color: AppColors.textSecondary),
          ),
          if (!n.isRead) ...[
            const SizedBox(height: 4),
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData _iconForType(String type) {
    return switch (type) {
      'quiz' => Icons.quiz_outlined,
      'league' => Icons.emoji_events_outlined,
      'contest' => Icons.military_tech_outlined,
      'battle' => Icons.sports_esports_outlined,
      'reward' || 'coins' => Icons.bolt_rounded,
      _ => Icons.notifications_outlined,
    };
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat.MMMd().format(dt);
  }
}
