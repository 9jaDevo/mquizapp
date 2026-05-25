import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mquiz/core/utils/error_handler.dart';
import 'package:mquiz/features/lives/data/lives_repository.dart';
import 'package:mquiz/features/lives/models/lives_models.dart';

sealed class LivesUiState extends Equatable {
  const LivesUiState();
  @override
  List<Object?> get props => const [];
}

final class LivesInitial extends LivesUiState {
  const LivesInitial();
}

final class LivesLoading extends LivesUiState {
  const LivesLoading();
}

final class LivesLoaded extends LivesUiState {
  const LivesLoaded({required this.lives, this.acting = false});
  final LivesState lives;
  final bool acting;

  LivesLoaded copyWith({LivesState? lives, bool? acting}) =>
      LivesLoaded(lives: lives ?? this.lives, acting: acting ?? this.acting);

  @override
  List<Object?> get props => [lives, acting];
}

final class LivesError extends LivesUiState {
  const LivesError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

class LivesCubit extends Cubit<LivesUiState> {
  LivesCubit(this._repo) : super(const LivesInitial());
  final LivesRepository _repo;

  Future<void> load() async {
    emit(const LivesLoading());
    try {
      final lives = await _repo.fetchLives();
      emit(LivesLoaded(lives: lives));
    } catch (e) {
      emit(LivesError(describeError(e)));
    }
  }

  Future<bool> restoreWithCoins() async {
    final current = state;
    if (current is! LivesLoaded || current.acting) return false;
    emit(current.copyWith(acting: true));
    try {
      final lives = await _repo.restoreWithCoins();
      emit(LivesLoaded(lives: lives));
      return true;
    } catch (e) {
      emit(LivesError(describeError(e)));
      return false;
    }
  }

  Future<bool> restoreWithAd() async {
    final current = state;
    if (current is! LivesLoaded || current.acting) return false;
    emit(current.copyWith(acting: true));
    try {
      final lives = await _repo.restoreWithAd();
      emit(LivesLoaded(lives: lives));
      return true;
    } catch (e) {
      emit(LivesError(describeError(e)));
      return false;
    }
  }
}
