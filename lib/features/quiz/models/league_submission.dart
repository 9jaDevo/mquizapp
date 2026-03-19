final class LeagueSubmission {
  const LeagueSubmission({
    required this.score,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.cumulativeScore,
    required this.userRank,
    required this.gamesPlayed,
    required this.playsRemaining,
  });

  LeagueSubmission.fromJson(Map<String, dynamic> json)
      : score = json['score']?.toString() ?? '0',
        correctAnswers = json['correct_answers']?.toString() ?? '0',
        wrongAnswers = json['wrong_answers']?.toString() ?? '0',
        cumulativeScore = json['cumulative_score']?.toString() ?? '0',
        userRank = json['user_rank']?.toString() ?? '0',
        gamesPlayed = json['games_played']?.toString() ?? '0',
        playsRemaining = json['plays_remaining']?.toString() ?? '0';

  final String score;
  final String correctAnswers;
  final String wrongAnswers;
  final String cumulativeScore;
  final String userRank;
  final String gamesPlayed;
  final String playsRemaining;
}
