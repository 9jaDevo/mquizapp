import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mquiz/core/utils/error_handler.dart';
import 'package:mquiz/core/utils/parsers.dart';
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
      // Fetch raw stages and user progress in parallel.
      final results = await Future.wait<dynamic>([
        _repo.fetchStages(),
        _repo.fetchMyProgress(),
      ]);
      final stages = results[0] as List<ProgressStage>;
      final myProgress = results[1] as Map<String, dynamic>;

      final totalScore = parseIntOr(myProgress['totalScore'], 0);
      final currentStageNum = parseIntOr(
        (myProgress['currentStage'] as Map<String, dynamic>?)?['stageNumber'],
        1,
      );

      // Compute per-user unlock / completion state from the score ladder.
      final enriched = stages
          .map((s) => ProgressStage(
                stageNumber: s.stageNumber,
                title: s.title,
                description: s.description,
                minScore: s.minScore,
                unlocked: totalScore >= s.minScore,
                completed: s.stageNumber < currentStageNum,
                starsEarned: 0,
                maxStars: 3,
              ))
          .toList(growable: false);

      final current = currentStageNum;
      emit(ProgressLoaded(
        stages: enriched,
        currentStage: current,
        totalStars: 0,
      ));
    } catch (e) {
      emit(ProgressError(describeError(e)));
    }
  }
}
