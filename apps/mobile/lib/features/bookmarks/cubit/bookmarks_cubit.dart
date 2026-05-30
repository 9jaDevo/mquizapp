import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mquiz/core/utils/error_handler.dart';
import 'package:mquiz/features/bookmarks/data/bookmarks_repository.dart';
import 'package:mquiz/features/bookmarks/models/bookmark_model.dart';

sealed class BookmarksState extends Equatable {
  const BookmarksState();
  @override
  List<Object?> get props => const [];
}

final class BookmarksInitial extends BookmarksState {
  const BookmarksInitial();
}

final class BookmarksLoading extends BookmarksState {
  const BookmarksLoading();
}

final class BookmarksLoaded extends BookmarksState {
  const BookmarksLoaded({
    required this.items,
    this.hasMore = false,
    this.page = 1,
  });
  final List<BookmarkModel> items;
  final bool hasMore;
  final int page;

  BookmarksLoaded copyWith({
    List<BookmarkModel>? items,
    bool? hasMore,
    int? page,
  }) =>
      BookmarksLoaded(
        items: items ?? this.items,
        hasMore: hasMore ?? this.hasMore,
        page: page ?? this.page,
      );

  @override
  List<Object?> get props => [items, hasMore, page];
}

final class BookmarksError extends BookmarksState {
  const BookmarksError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

class BookmarksCubit extends Cubit<BookmarksState> {
  BookmarksCubit(this._repo) : super(const BookmarksInitial());
  final BookmarksRepository _repo;

  static const _limit = 20;

  Future<void> load() async {
    emit(const BookmarksLoading());
    try {
      final items = await _repo.fetchBookmarks(page: 1, limit: _limit);
      emit(BookmarksLoaded(
        items: items,
        hasMore: items.length >= _limit,
        page: 1,
      ));
    } catch (e) {
      emit(BookmarksError(describeError(e)));
    }
  }

  Future<void> loadMore() async {
    final current = state;
    if (current is! BookmarksLoaded || !current.hasMore) return;
    try {
      final next = await _repo.fetchBookmarks(
        page: current.page + 1,
        limit: _limit,
      );
      emit(current.copyWith(
        items: [...current.items, ...next],
        hasMore: next.length >= _limit,
        page: current.page + 1,
      ));
    } catch (_) {
      // Non-fatal
    }
  }

  Future<void> remove(int questionId) async {
    final current = state;
    if (current is! BookmarksLoaded) return;
    // Optimistic removal
    final updated =
        current.items.where((b) => b.questionId != questionId).toList();
    emit(current.copyWith(items: updated));
    try {
      await _repo.removeBookmark(questionId);
    } catch (e) {
      // Restore on failure
      emit(current);
    }
  }

  /// Fire-and-forget — adds a bookmark during a quiz session.
  /// No state change is emitted so the quiz flow is unaffected.
  Future<void> addInQuiz(int questionId) async {
    try {
      await _repo.addBookmark(questionId);
    } catch (_) {}
  }
}
