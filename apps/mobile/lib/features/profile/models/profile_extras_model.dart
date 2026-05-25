import 'package:equatable/equatable.dart';
import 'package:mquiz/core/utils/parsers.dart';

class Badge extends Equatable {
  const Badge({
    required this.id,
    required this.title,
    required this.description,
    required this.isEarned,
    this.image,
    this.requirement,
    this.earnedAt,
  });

  factory Badge.fromJson(Map<String, dynamic> j) => Badge(
        id: parseIntOr(j['id'], 0),
        title: parseStringOr(j['title'] ?? j['name'], ''),
        description: parseStringOr(j['description'], ''),
        isEarned: parseBool(j['isEarned']),
        image: parseString(j['image']),
        requirement: parseString(j['requirement']),
        earnedAt: parseDateTime(j['earnedAt']),
      );

  final int id;
  final String title;
  final String description;
  final bool isEarned;
  final String? image;
  final String? requirement;
  final DateTime? earnedAt;

  @override
  List<Object?> get props => [id, title, isEarned];
}

class CoinHistoryEntry extends Equatable {
  const CoinHistoryEntry({
    required this.id,
    required this.points,
    required this.type,
    required this.direction,
    required this.date,
  });

  factory CoinHistoryEntry.fromJson(Map<String, dynamic> j) => CoinHistoryEntry(
        id: parseIntOr(j['id'], 0),
        points: parseIntOr(j['points'], 0),
        type: parseStringOr(j['type'], ''),
        direction: parseStringOr(j['direction'], 'earned'),
        date: parseDateTime(j['date']) ?? DateTime.now(),
      );

  final int id;
  final int points;
  final String type;
  final String direction; // 'earned' | 'spent'
  final DateTime date;

  bool get isEarned => direction == 'earned';

  @override
  List<Object?> get props => [id, points, type, direction, date];
}

class ReferralInfo extends Equatable {
  const ReferralInfo({
    required this.code,
    required this.totalReferrals,
    required this.successfulReferrals,
    required this.totalCoinsEarned,
  });

  factory ReferralInfo.fromJson(Map<String, dynamic> j) => ReferralInfo(
        code: parseStringOr(j['code'], ''),
        totalReferrals: parseIntOr(j['totalReferrals'], 0),
        successfulReferrals: parseIntOr(j['successfulReferrals'], 0),
        totalCoinsEarned: parseIntOr(j['totalCoinsEarned'], 0),
      );

  final String code;
  final int totalReferrals;
  final int successfulReferrals;
  final int totalCoinsEarned;

  @override
  List<Object?> get props =>
      [code, totalReferrals, successfulReferrals, totalCoinsEarned];
}
