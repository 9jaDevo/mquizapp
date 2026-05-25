import 'package:equatable/equatable.dart';
import 'package:mquiz/core/utils/parsers.dart';

class League extends Equatable {
  const League({
    required this.id,
    required this.name,
    this.description,
    this.entryCoinCost,
    this.prizePool,
    this.startDate,
    this.endDate,
    this.image,
    this.participantsCount,
    this.questionsPerDay,
    this.isJoined = false,
    this.status,
  });

  final int id;
  final String name;
  final String? description;
  final int? entryCoinCost;
  final int? prizePool;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? image;
  final int? participantsCount;
  final int? questionsPerDay;
  final bool isJoined;
  final String? status;

  factory League.fromJson(Map<String, dynamic> j) => League(
        id: parseIntOr(j['id'], 0),
        name: parseStringOr(j['name'] ?? j['title'], ''),
        description: parseString(j['description']),
        entryCoinCost: parseInt(j['entryCoinCost'] ?? j['entry_cost']),
        prizePool: parseInt(j['prizePool'] ?? j['prize_pool']),
        startDate: parseDateTime(j['startDate'] ?? j['start_date']),
        endDate: parseDateTime(j['endDate'] ?? j['end_date']),
        image: parseString(j['image'] ?? j['icon']),
        participantsCount:
            parseInt(j['participantsCount'] ?? j['participants']),
        questionsPerDay:
            parseInt(j['questionsPerDay'] ?? j['questions_per_day']),
        isJoined: parseBool(j['isJoined'] ?? j['joined']),
        status: parseString(j['status']),
      );

  bool get isActive {
    final now = DateTime.now();
    if (startDate != null && now.isBefore(startDate!)) return false;
    if (endDate != null && now.isAfter(endDate!)) return false;
    return true;
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        entryCoinCost,
        prizePool,
        startDate,
        endDate,
        image,
        participantsCount,
        questionsPerDay,
        isJoined,
        status,
      ];
}

class LeagueMembership extends Equatable {
  const LeagueMembership({
    required this.leagueId,
    required this.rank,
    required this.score,
    required this.answeredToday,
    this.totalAnswers,
    this.correctAnswers,
  });

  final int leagueId;
  final int rank;
  final int score;
  final bool answeredToday;
  final int? totalAnswers;
  final int? correctAnswers;

  factory LeagueMembership.fromJson(Map<String, dynamic> j) =>
      LeagueMembership(
        leagueId: parseIntOr(j['leagueId'] ?? j['league_id'], 0),
        rank: parseIntOr(j['rank'], 0),
        score: parseIntOr(j['score'] ?? j['points'], 0),
        answeredToday:
            parseBool(j['answeredToday'] ?? j['played_today']),
        totalAnswers: parseInt(j['totalAnswers']),
        correctAnswers: parseInt(j['correctAnswers']),
      );

  @override
  List<Object?> get props =>
      [leagueId, rank, score, answeredToday, totalAnswers, correctAnswers];
}
