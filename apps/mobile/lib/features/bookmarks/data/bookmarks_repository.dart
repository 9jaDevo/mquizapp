import 'package:mquiz/core/network/nestjs_api.dart';
import 'package:mquiz/features/bookmarks/models/bookmark_model.dart';

class BookmarksRepository {
  BookmarksRepository({NestJsApi? api}) : _api = api ?? NestJsApi.instance;
  final NestJsApi _api;

  Future<List<BookmarkModel>> fetchBookmarks({
    int page = 1,
    int limit = 20,
  }) async {
    final data = await _api.listBookmarks(page: page, limit: limit);
    final raw = data['items'] ?? data['data'] ?? data['bookmarks'];
    if (raw is! List) return const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(BookmarkModel.fromJson)
        .toList(growable: false);
  }

  Future<void> addBookmark(int questionId) async {
    await _api.addBookmark(questionId);
  }

  Future<void> removeBookmark(int questionId) async {
    await _api.removeBookmark(questionId);
  }
}
