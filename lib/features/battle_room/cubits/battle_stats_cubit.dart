import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/battle_room/battle_room_repository.dart';
import 'package:flutterquiz/features/battle_room/models/battle_stats.dart';

// ---------------------------------------------------------------------------
// States
// ---------------------------------------------------------------------------

sealed class BattleStatsState {
  const BattleStatsState();
}

final class BattleStatsInitial extends BattleStatsState {
  const BattleStatsInitial();
}

final class BattleStatsLoading extends BattleStatsState {
  const BattleStatsLoading();
}

final class BattleStatsLoaded extends BattleStatsState {
  const BattleStatsLoaded(this.stats);
  final BattleStats stats;
}

final class BattleStatsError extends BattleStatsState {
  const BattleStatsError(this.message);
  final String message;
}

// ---------------------------------------------------------------------------
// Cubit
// ---------------------------------------------------------------------------

class BattleStatsCubit extends Cubit<BattleStatsState> {
  BattleStatsCubit(this._repository) : super(const BattleStatsInitial());

  final BattleRoomRepository _repository;

  /// Fetches all three stat values from Firestore.
  /// Called once when the battle landing screen is opened.
  Future<void> fetchStats() async {
    if (state is BattleStatsLoading) return;
    emit(const BattleStatsLoading());
    try {
      final stats = await _repository.fetchBattleStats();
      emit(BattleStatsLoaded(stats));
    } on Exception catch (e) {
      // Non-critical — show zeros rather than crashing the screen.
      emit(BattleStatsError(e.toString()));
    }
  }
}
