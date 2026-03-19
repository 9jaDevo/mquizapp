import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/quiz/models/league_submission.dart';
import 'package:flutterquiz/features/quiz/quiz_repository.dart';

sealed class LeagueSubmitState {
  const LeagueSubmitState();
}

final class LeagueSubmitInitial extends LeagueSubmitState {
  const LeagueSubmitInitial();
}

final class LeagueSubmitProgress extends LeagueSubmitState {
  const LeagueSubmitProgress();
}

final class LeagueSubmitSuccess extends LeagueSubmitState {
  const LeagueSubmitSuccess(this.result);

  final LeagueSubmission result;
}

final class LeagueSubmitFailure extends LeagueSubmitState {
  const LeagueSubmitFailure(this.errorMessage);

  final String errorMessage;
}

final class LeagueSubmitCubit extends Cubit<LeagueSubmitState> {
  LeagueSubmitCubit(this._quizRepository) : super(const LeagueSubmitInitial());

  final QuizRepository _quizRepository;

  Future<void> submit({
    required String leagueId,
    required String dailyQuizId,
    required int correctAnswers,
    required int totalQuestions,
    required bool adShown,
  }) async {
    emit(const LeagueSubmitProgress());
    await _quizRepository
        .submitLeagueQuiz(
          leagueId: leagueId,
          dailyQuizId: dailyQuizId,
          correctAnswers: correctAnswers,
          totalQuestions: totalQuestions,
          adShown: adShown,
        )
        .then((value) {
      final data = value['data'] as Map<String, dynamic>;
      emit(LeagueSubmitSuccess(LeagueSubmission.fromJson(data)));
    }).catchError((Object e) {
      emit(LeagueSubmitFailure(e.toString()));
    });
  }
}
