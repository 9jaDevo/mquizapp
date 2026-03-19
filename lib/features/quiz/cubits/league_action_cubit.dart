import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/quiz/quiz_repository.dart';

sealed class LeagueActionState {
  const LeagueActionState();
}

final class LeagueActionInitial extends LeagueActionState {
  const LeagueActionInitial();
}

final class LeagueActionProgress extends LeagueActionState {
  const LeagueActionProgress();
}

final class LeagueActionSuccess extends LeagueActionState {
  const LeagueActionSuccess(this.message);

  final String message;
}

final class LeagueActionFailure extends LeagueActionState {
  const LeagueActionFailure(this.errorMessage);

  final String errorMessage;
}

final class LeagueActionCubit extends Cubit<LeagueActionState> {
  LeagueActionCubit(this._quizRepository) : super(const LeagueActionInitial());

  final QuizRepository _quizRepository;

  Future<void> optInLeague({
    required String leagueId,
    String? deviceToken,
  }) async {
    emit(const LeagueActionProgress());
    await _quizRepository
        .optInLeague(leagueId: leagueId, deviceToken: deviceToken)
        .then((value) => emit(LeagueActionSuccess(value['message'].toString())))
        .catchError((Object e) => emit(LeagueActionFailure(e.toString())));
  }

  Future<void> joinLeague({required String leagueId}) async {
    emit(const LeagueActionProgress());
    await _quizRepository
        .joinLeague(leagueId: leagueId)
        .then((value) => emit(LeagueActionSuccess(value['message'].toString())))
        .catchError((Object e) => emit(LeagueActionFailure(e.toString())));
  }
}
