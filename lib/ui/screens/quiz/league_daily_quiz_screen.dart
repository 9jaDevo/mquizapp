import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/quiz/cubits/league_daily_quiz_cubit.dart';
import 'package:flutterquiz/features/quiz/cubits/league_submit_cubit.dart';
import 'package:flutterquiz/features/quiz/quiz_repository.dart';
import 'package:flutterquiz/ui/widgets/circular_progress_container.dart';

class LeagueDailyQuizScreen extends StatefulWidget {
  const LeagueDailyQuizScreen({super.key, this.leagueId});

  final String? leagueId;

  static Route<dynamic> route(RouteSettings routeSettings) {
    final args = routeSettings.arguments as Map?;
    return CupertinoPageRoute(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => LeagueDailyQuizCubit(QuizRepository()),
          ),
          BlocProvider(
            create: (_) => LeagueSubmitCubit(QuizRepository()),
          ),
        ],
        child: LeagueDailyQuizScreen(leagueId: args?['leagueId'] as String?),
      ),
    );
  }

  @override
  State<LeagueDailyQuizScreen> createState() => _LeagueDailyQuizScreenState();
}

class _LeagueDailyQuizScreenState extends State<LeagueDailyQuizScreen> {
  final _correctCtrl = TextEditingController(text: '0');

  @override
  void initState() {
    super.initState();
    context.read<LeagueDailyQuizCubit>().getDailyQuiz(
          leagueId: widget.leagueId ?? '',
        );
  }

  @override
  void dispose() {
    _correctCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('League Daily Quiz')),
      body: BlocListener<LeagueSubmitCubit, LeagueSubmitState>(
        listener: (context, state) {
          if (state is LeagueSubmitSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Score: ${state.result.score}, Rank: ${state.result.userRank}',
                ),
              ),
            );
            context.read<LeagueDailyQuizCubit>().getDailyQuiz(
                  leagueId: widget.leagueId ?? '',
                );
          } else if (state is LeagueSubmitFailure) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.errorMessage)));
          }
        },
        child: BlocBuilder<LeagueDailyQuizCubit, LeagueDailyQuizState>(
          builder: (context, state) {
            if (state is LeagueDailyQuizInitial ||
                state is LeagueDailyQuizProgress) {
              return const Center(child: CircularProgressContainer());
            }
            if (state is LeagueDailyQuizFailure) {
              return Center(child: Text(state.errorMessage));
            }

            final quiz = (state as LeagueDailyQuizSuccess).dailyQuiz;
            final total = quiz.questions.length;

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Day ${quiz.leagueDay}'),
                  Text('Plays today: ${quiz.playsToday}'),
                  Text('Remaining: ${quiz.playsRemaining}'),
                  Text('Questions loaded: $total'),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _correctCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Correct Answers',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  BlocBuilder<LeagueSubmitCubit, LeagueSubmitState>(
                    builder: (context, submitState) {
                      final submitting = submitState is LeagueSubmitProgress;
                      return ElevatedButton(
                        onPressed: submitting
                            ? null
                            : () {
                                final correct =
                                    int.tryParse(_correctCtrl.text.trim()) ?? 0;
                                context.read<LeagueSubmitCubit>().submit(
                                      leagueId: quiz.leagueId,
                                      dailyQuizId: quiz.dailyQuizId,
                                      correctAnswers: correct,
                                      totalQuestions: total,
                                      adShown: quiz.showAd,
                                    );
                              },
                        child: Text(submitting ? 'Submitting...' : 'Submit'),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
