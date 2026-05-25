import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mquiz/core/utils/error_handler.dart';
import 'package:mquiz/features/progress/data/progress_repository.dart';
import 'package:mquiz/features/progress/models/progress_stage_model.dart';

sealed class ProgressState extends Equatable {
  const ProgressState();
  @override
  List<Object?> get props => const [];
}

final class ProgressInitial extends ProgressState {
  const ProgressInitial();
}

final class ProgressLoading extends ProgressState {
  const ProgressLoading();
}

final class ProgressLoaded extends ProgressState {
  const ProgressLoaded({
    required this.stages,
    required this.currentStage,
    required this.totalStars,
  });
  final List<ProgressStage> stages;
  final int currentStage;
  final int totalStars;
  @override
  List<Object?> get props => [stages, currentStage, totalStars];
}

final class ProgressError extends ProgressState {
  const ProgressError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

class ProgressCubit extends Cubit<ProgressState> {
  ProgressCubit(this._repo) : super(const ProgressInitial());
  final ProgressRepository _repo;

  Future<void> load() async {
    emit(const ProgressLoading());
    try {
      final stages = await _repo.fetchStages();
      final totalStars =
          stages.fold<int>(0, (sum, s) => sum + s.starsEarned);
      final current = stages
          .where((s) => s.unlocked && !s.completed)
          .map((s) => s.stageNumber)
          .fold<int>(0, (a, b) => a > b ? a : b);
      emit(ProgressLoaded(
        stages: stages,
        currentStage: current,
        totalStars: totalStars,
      ));
    } catch (e) {
      emit(ProgressError(describeError(e)));
    }
  }
}
