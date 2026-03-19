import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/ads/blocs/interstitial_ad_cubit.dart';
import 'package:flutterquiz/features/ads/utils/ad_analytics_collector.dart';
import 'package:flutterquiz/features/quiz/cubits/league_daily_quiz_cubit.dart';
import 'package:flutterquiz/features/quiz/cubits/league_submit_cubit.dart';
import 'package:flutterquiz/features/quiz/quiz_repository.dart';
import 'package:flutterquiz/ui/widgets/circular_progress_container.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  static const int _maxLeagueInterstitialPerDay = 2;

  final _correctCtrl = TextEditingController(text: '0');
  bool _leagueAdShownForSubmission = false;
  String? _lastAdEvaluationKey;

  @override
  void initState() {
    super.initState();
    context.read<LeagueDailyQuizCubit>().getDailyQuiz(
      leagueId: widget.leagueId ?? '',
    );
    Future.delayed(Duration.zero, () {
      if (mounted) {
        context.read<InterstitialAdCubit>().createInterstitialAd(context);
      }
    });
  }

  Future<void> _maybeShowDailyInterstitialAd(
    LeagueDailyQuizSuccess state,
  ) async {
    final quiz = state.dailyQuiz;
    final leagueId = quiz.leagueId;
    if (!quiz.showAd) {
      _leagueAdShownForSubmission = false;
      return;
    }

    final dayKey = DateTime.now().toIso8601String().substring(0, 10);
    final key = 'league_daily_interstitial_pre_${leagueId}_$dayKey';
    if (_lastAdEvaluationKey == key) {
      return;
    }
    _lastAdEvaluationKey = key;

    final prefs = await SharedPreferences.getInstance();
    final alreadyShownPre = prefs.getBool(key) ?? false;
    if (!_canShowLeagueSlot(
      prefs: prefs,
      leagueId: leagueId,
      dayKey: dayKey,
      slotKey: key,
    )) {
      _leagueAdShownForSubmission = alreadyShownPre;
      return;
    }

    final canShow = await AdFrequencyManager.canShowAd();
    if (!canShow) {
      _leagueAdShownForSubmission = false;
      return;
    }

    if (!mounted) {
      return;
    }

    context.read<InterstitialAdCubit>().createInterstitialAd(context);
    await Future<void>.delayed(const Duration(milliseconds: 900));

    if (!mounted) {
      return;
    }

    await context.read<InterstitialAdCubit>().showAd(context);
    _leagueAdShownForSubmission = true;
    await _markLeagueSlotShown(
      prefs: prefs,
      leagueId: leagueId,
      dayKey: dayKey,
      slotKey: key,
    );
    await AdAnalyticsCollector.recordImpressionMetric(
      'league_daily_interstitial',
    );
  }

  Future<void> _maybeShowPostSubmitInterstitialAd(String leagueId) async {
    final dayKey = DateTime.now().toIso8601String().substring(0, 10);
    final slotKey = 'league_daily_interstitial_post_${leagueId}_$dayKey';

    final prefs = await SharedPreferences.getInstance();
    if (!_canShowLeagueSlot(
      prefs: prefs,
      leagueId: leagueId,
      dayKey: dayKey,
      slotKey: slotKey,
    )) {
      return;
    }

    final canShow = await AdFrequencyManager.canShowAd();
    if (!canShow || !mounted) {
      return;
    }

    context.read<InterstitialAdCubit>().createInterstitialAd(context);
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) {
      return;
    }

    await context.read<InterstitialAdCubit>().showAd(context);
    await _markLeagueSlotShown(
      prefs: prefs,
      leagueId: leagueId,
      dayKey: dayKey,
      slotKey: slotKey,
    );
    await AdAnalyticsCollector.recordImpressionMetric(
      'league_daily_interstitial_post_submit',
    );
  }

  bool _canShowLeagueSlot({
    required SharedPreferences prefs,
    required String leagueId,
    required String dayKey,
    required String slotKey,
  }) {
    final alreadyShown = prefs.getBool(slotKey) ?? false;
    if (alreadyShown) {
      return false;
    }

    final countKey = 'league_daily_interstitial_count_${leagueId}_$dayKey';
    final shownCount = prefs.getInt(countKey) ?? 0;
    return shownCount < _maxLeagueInterstitialPerDay;
  }

  Future<void> _markLeagueSlotShown({
    required SharedPreferences prefs,
    required String leagueId,
    required String dayKey,
    required String slotKey,
  }) async {
    final countKey = 'league_daily_interstitial_count_${leagueId}_$dayKey';
    final shownCount = prefs.getInt(countKey) ?? 0;
    await prefs.setBool(slotKey, true);
    await prefs.setInt(countKey, shownCount + 1);
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
            _maybeShowPostSubmitInterstitialAd(widget.leagueId ?? '');
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
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage)));
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

            final successState = state as LeagueDailyQuizSuccess;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _maybeShowDailyInterstitialAd(successState);
            });

            final quiz = successState.dailyQuiz;
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
                                  adShown: _leagueAdShownForSubmission,
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
