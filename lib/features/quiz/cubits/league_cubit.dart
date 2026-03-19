import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/quiz/models/league.dart';
import 'package:flutterquiz/features/quiz/quiz_repository.dart';
import 'package:flutterquiz/utils/datetime_utils.dart';

sealed class LeagueState {
  const LeagueState();
}

final class LeagueInitial extends LeagueState {
  const LeagueInitial();
}

final class LeagueProgress extends LeagueState {
  const LeagueProgress();
}

final class LeagueSuccess extends LeagueState {
  const LeagueSuccess(this.leagues);

  final Leagues leagues;
}

final class LeagueFailure extends LeagueState {
  const LeagueFailure(this.errorMessage);

  final String errorMessage;
}

final class LeagueCubit extends Cubit<LeagueState> {
  LeagueCubit(this._quizRepository) : super(const LeagueInitial());

  final QuizRepository _quizRepository;

  Future<void> getLeagues({required String languageId}) async {
    emit(const LeagueProgress());
    final (:gmt, :localTimezone) = await DateTimeUtils.getTimeZone();

    await _quizRepository
        .getLeagues(languageId: languageId, timezone: localTimezone, gmt: gmt)
        .then((val) => emit(LeagueSuccess(val)))
        .catchError((Object e) => emit(LeagueFailure(e.toString())));
  }
}
