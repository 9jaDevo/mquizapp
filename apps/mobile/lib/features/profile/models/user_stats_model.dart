import 'package:equatable/equatable.dart';
import 'package:mquiz/core/utils/parsers.dart';

class UserStats extends Equatable {
  const UserStats({
    required this.totalScore,
    required this.quizzesPlayed,
    required this.coinsBalance,
    required this.lifetimeCoinsEarned,
    required this.streakCurrent,
    required this.streakBest,
    required this.badgesCount,
    required this.accuracy,
  });

  factory UserStats.fromJson(Map<String, dynamic> j) => UserStats(
        totalScore: parseIntOr(j['totalScore'], 0),
        quizzesPlayed: parseIntOr(j['quizzesPlayed'], 0),
        coinsBalance: parseIntOr(j['coinsBalance'] ?? j['coins'], 0),
        lifetimeCoinsEarned: parseIntOr(j['lifetimeCoinsEarned'], 0),
        streakCurrent: parseIntOr(j['streakCurrent'], 0),
        streakBest: parseIntOr(j['streakBest'], 0),
        badgesCount: parseIntOr(j['badgesCount'], 0),
        accuracy: parseDouble(j['accuracy']) ?? 0.0,
      );

  final int totalScore;
  final int quizzesPlayed;
  final int coinsBalance;
  final int lifetimeCoinsEarned;
  final int streakCurrent;
  final int streakBest;
  final int badgesCount;
  final double accuracy;

  @override
  List<Object?> get props => [
        totalScore,
        quizzesPlayed,
        coinsBalance,
        lifetimeCoinsEarned,
        streakCurrent,
        streakBest,
        badgesCount,
        accuracy,
      ];
}
