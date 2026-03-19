final class LeagueDailyQuiz {
  const LeagueDailyQuiz({
    required this.leagueId,
    required this.leagueDay,
    required this.dailyQuizId,
    required this.playsToday,
    required this.playsRemaining,
    required this.showAd,
    required this.questions,
  });

  LeagueDailyQuiz.fromJson(Map<String, dynamic> json)
      : leagueId = json['league_id']?.toString() ?? '',
        leagueDay = json['league_day']?.toString() ?? '1',
        dailyQuizId = json['daily_quiz_id']?.toString() ?? '',
        playsToday = json['plays_today']?.toString() ?? '0',
        playsRemaining = json['plays_remaining']?.toString() ?? '0',
        showAd = json['show_ad'] as bool? ?? false,
        questions = (json['questions'] as List? ?? <dynamic>[])
            .cast<Map<String, dynamic>>()
            .toList(growable: false);

  final String leagueId;
  final String leagueDay;
  final String dailyQuizId;
  final String playsToday;
  final String playsRemaining;
  final bool showAd;
  final List<Map<String, dynamic>> questions;
}
