import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/battle_room/battle_room_repository.dart';
import 'package:flutterquiz/features/battle_room/models/battle_room.dart';

// ─── States ──────────────────────────────────────────────────────────────────

sealed class OpenRoomsState {
  const OpenRoomsState();
}

final class OpenRoomsInitial extends OpenRoomsState {
  const OpenRoomsInitial();
}

final class OpenRoomsLoading extends OpenRoomsState {
  const OpenRoomsLoading();
}

final class OpenRoomsLoaded extends OpenRoomsState {
  const OpenRoomsLoaded({
    required this.all,
    required this.filtered,
    this.feeFilter,
    this.sortBy = 'latest',
  });

  /// All rooms returned from Firestore (max 50).
  final List<BattleRoom> all;

  /// Currently displayed list after applying fee filter and sort.
  final List<BattleRoom> filtered;

  /// null = no filter; otherwise the exact entryFee value.
  final int? feeFilter;

  /// 'latest' | 'fewest' (rooms with fewest joined players shown first).
  final String sortBy;

  OpenRoomsLoaded copyWith({
    List<BattleRoom>? all,
    List<BattleRoom>? filtered,
    Object? feeFilter = _sentinel,
    String? sortBy,
  }) {
    return OpenRoomsLoaded(
      all: all ?? this.all,
      filtered: filtered ?? this.filtered,
      feeFilter: feeFilter == _sentinel ? this.feeFilter : feeFilter as int?,
      sortBy: sortBy ?? this.sortBy,
    );
  }
}

final class OpenRoomsError extends OpenRoomsState {
  const OpenRoomsError(this.message);
  final String message;
}

// Sentinel used for nullable copyWith.
const Object _sentinel = Object();

// ─── Cubit ───────────────────────────────────────────────────────────────────

class OpenRoomsCubit extends Cubit<OpenRoomsState> {
  OpenRoomsCubit(this._repository) : super(const OpenRoomsInitial());

  final BattleRoomRepository _repository;
  bool _isGroupBattle = true;

  /// Fetches rooms from Firestore and stores the full list.
  Future<void> loadRooms({required bool isGroupBattle}) async {
    _isGroupBattle = isGroupBattle;
    if (state is OpenRoomsLoading) return;
    emit(const OpenRoomsLoading());
    try {
      final rooms = await _repository.getOpenBattleRooms(
        isGroupBattle: isGroupBattle,
      );
      final filtered = _applyFilterAndSort(
        rooms: rooms,
        feeFilter: null,
        sortBy: 'latest',
      );
      emit(
        OpenRoomsLoaded(all: rooms, filtered: filtered),
      );
    } on Exception catch (e) {
      emit(OpenRoomsError(e.toString()));
    }
  }

  /// Re-fetches without changing the current filter/sort settings.
  Future<void> refresh() async {
    final current = state;
    int? fee;
    String sort = 'latest';
    if (current is OpenRoomsLoaded) {
      fee = current.feeFilter;
      sort = current.sortBy;
    }
    emit(const OpenRoomsLoading());
    try {
      final rooms = await _repository.getOpenBattleRooms(
        isGroupBattle: _isGroupBattle,
      );
      final filtered = _applyFilterAndSort(
        rooms: rooms,
        feeFilter: fee,
        sortBy: sort,
      );
      emit(
        OpenRoomsLoaded(
          all: rooms,
          filtered: filtered,
          feeFilter: fee,
          sortBy: sort,
        ),
      );
    } on Exception catch (e) {
      emit(OpenRoomsError(e.toString()));
    }
  }

  /// Applies a fee filter and/or sort order client-side — no new Firestore
  /// request.
  void applyFilter({int? feeFilter, String? sortBy}) {
    final current = state;
    if (current is! OpenRoomsLoaded) return;

    final newFee = feeFilter; // null = all
    final newSort = sortBy ?? current.sortBy;

    final filtered = _applyFilterAndSort(
      rooms: current.all,
      feeFilter: newFee,
      sortBy: newSort,
    );

    emit(
      current.copyWith(filtered: filtered, feeFilter: newFee, sortBy: newSort),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  List<BattleRoom> _applyFilterAndSort({
    required List<BattleRoom> rooms,
    required int? feeFilter,
    required String sortBy,
  }) {
    var result = rooms.where((r) {
      if (feeFilter != null && r.entryFee != feeFilter) return false;
      return true;
    }).toList();

    if (sortBy == 'fewest') {
      // Rooms with the fewest players joined (most spots still open) first.
      result.sort((a, b) => _filledSlots(a).compareTo(_filledSlots(b)));
    }
    // 'latest' order is preserved from Firestore (createdAt desc).

    return result;
  }

  int _filledSlots(BattleRoom room) {
    var count = 0;
    if (room.user1?.uid.isNotEmpty == true) count++;
    if (room.user2?.uid.isNotEmpty == true) count++;
    if (room.user3?.uid.isNotEmpty == true) count++;
    if (room.user4?.uid.isNotEmpty == true) count++;
    return count;
  }
}
