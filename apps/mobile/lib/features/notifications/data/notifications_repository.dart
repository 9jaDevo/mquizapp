import 'package:mquiz/core/network/nestjs_api.dart';
import 'package:mquiz/features/notifications/models/notification_model.dart';

class NotificationsRepository {
  NotificationsRepository({NestJsApi? api}) : _api = api ?? NestJsApi.instance;
  final NestJsApi _api;

  Future<List<NotificationModel>> fetchNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    final data = await _api.getNotifications(page: page, limit: limit);
    final raw = data['items'] ?? data['data'] ?? data['notifications'];
    if (raw is! List) return const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(NotificationModel.fromJson)
        .toList(growable: false);
  }

  Future<void> markRead(int id) async {
    await _api.markNotificationRead(id);
  }
}
