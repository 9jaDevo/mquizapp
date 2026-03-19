import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/quiz/models/league_daily_quiz.dart';
import 'package:flutterquiz/features/quiz/quiz_repository.dart';

sealed class LeagueDailyQuizState {
  const LeagueDailyQuizState();
}

final class LeagueDailyQuizInitial extends LeagueDailyQuizState {
  const LeagueDailyQuizInitial();
}

final class LeagueDailyQuizProgress extends LeagueDailyQuizState {
  const LeagueDailyQuizProgress();
}

final class LeagueDailyQuizSuccess extends LeagueDailyQuizState {
  const LeagueDailyQuizSuccess(this.dailyQuiz);

  final LeagueDailyQuiz dailyQuiz;
}

final class LeagueDailyQuizFailure extends LeagueDailyQuizState {
  const LeagueDailyQuizFailure(this.errorMessage);

  final String errorMessage;
}

final class LeagueDailyQuizCubit extends Cubit<LeagueDailyQuizState> {
  LeagueDailyQuizCubit(this._quizRepository)
      : super(const LeagueDailyQuizInitial());

  final QuizRepository _quizRepository;

  Future<void> getDailyQuiz({required String leagueId}) async {
    emit(const LeagueDailyQuizProgress());
    await _quizRepository
        .getLeagueDailyQuiz(leagueId: leagueId)
        .then((value) {
      final data = value['data'] as Map<String, dynamic>;
      emit(LeagueDailyQuizSuccess(LeagueDailyQuiz.fromJson(data)));
    }).catchError((Object e) {
      emit(LeagueDailyQuizFailure(e.toString()));
    });
  }
}
