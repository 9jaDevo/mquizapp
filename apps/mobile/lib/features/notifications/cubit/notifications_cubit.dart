import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mquiz/core/utils/error_handler.dart';
import 'package:mquiz/features/notifications/data/notifications_repository.dart';
import 'package:mquiz/features/notifications/models/notification_model.dart';

sealed class NotificationsState extends Equatable {
  const NotificationsState();
  @override
  List<Object?> get props => const [];
}

final class NotificationsInitial extends NotificationsState {
  const NotificationsInitial();
}

final class NotificationsLoading extends NotificationsState {
  const NotificationsLoading();
}

final class NotificationsLoaded extends NotificationsState {
  const NotificationsLoaded({
    required this.items,
    required this.unreadCount,
    this.hasMore = false,
    this.page = 1,
  });
  final List<NotificationModel> items;
  final int unreadCount;
  final bool hasMore;
  final int page;

  NotificationsLoaded copyWith({
    List<NotificationModel>? items,
    int? unreadCount,
    bool? hasMore,
    int? page,
  }) =>
      NotificationsLoaded(
        items: items ?? this.items,
        unreadCount: unreadCount ?? this.unreadCount,
        hasMore: hasMore ?? this.hasMore,
        page: page ?? this.page,
      );

  @override
  List<Object?> get props => [items, unreadCount, hasMore, page];
}

final class NotificationsError extends NotificationsState {
  const NotificationsError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit(this._repo) : super(const NotificationsInitial());
  final NotificationsRepository _repo;

  static const _limit = 20;

  Future<void> load() async {
    emit(const NotificationsLoading());
    try {
      final items = await _repo.fetchNotifications(page: 1, limit: _limit);
      emit(NotificationsLoaded(
        items: items,
        unreadCount: items.where((n) => !n.isRead).length,
        hasMore: items.length >= _limit,
        page: 1,
      ));
    } catch (e) {
      emit(NotificationsError(describeError(e)));
    }
  }

  Future<void> loadMore() async {
    final current = state;
    if (current is! NotificationsLoaded || !current.hasMore) return;
    try {
      final next = await _repo.fetchNotifications(
        page: current.page + 1,
        limit: _limit,
      );
      emit(current.copyWith(
        items: [...current.items, ...next],
        hasMore: next.length >= _limit,
        page: current.page + 1,
      ));
    } catch (_) {
      // Non-fatal — user can try scrolling again
    }
  }

  Future<void> markRead(int id) async {
    final current = state;
    if (current is! NotificationsLoaded) return;
    // Optimistic update first
    final updated = current.items.map((n) {
      return n.id == id ? n.copyWith(isRead: true) : n;
    }).toList(growable: false);
    emit(current.copyWith(
      items: updated,
      unreadCount: updated.where((n) => !n.isRead).length,
    ));
    try {
      await _repo.markRead(id);
    } catch (_) {
      // Optimistic update stays — not critical if server call fails
    }
  }
}
