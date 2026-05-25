import 'package:equatable/equatable.dart';
import 'package:mquiz/core/utils/parsers.dart';

class LivesState extends Equatable {
  const LivesState({
    required this.current,
    required this.max,
    this.nextRefillAt,
    this.intervalMs,
    this.lastRefillAt,
  });

  final int current;
  final int max;
  final DateTime? nextRefillAt;
  final DateTime? lastRefillAt;
  final int? intervalMs;

  factory LivesState.fromJson(Map<String, dynamic> j) => LivesState(
        current: parseIntOr(j['current'] ?? j['lives'], 0),
        max: parseIntOr(j['max'] ?? j['maxLives'], 5),
        nextRefillAt: parseDateTime(j['nextRefillAt']),
        lastRefillAt: parseDateTime(j['lastRefillAt']),
        intervalMs: parseInt(j['intervalMs']),
      );

  bool get isFull => current >= max;
  bool get isEmpty => current <= 0;

  @override
  List<Object?> get props =>
      [current, max, nextRefillAt, lastRefillAt, intervalMs];
}

class StreakStatus extends Equatable {
  const StreakStatus({
    required this.current,
    required this.max,
    required this.claimedToday,
    this.coinEarnedToday,
    this.lastLoginDate,
  });

  final int current;
  final int max;
  final bool claimedToday;
  final int? coinEarnedToday;
  final DateTime? lastLoginDate;

  factory StreakStatus.fromJson(Map<String, dynamic> j) => StreakStatus(
        current: parseIntOr(j['current'] ?? j['currentStreak'], 0),
        max: parseIntOr(j['max'] ?? j['maxStreak'], 0),
        claimedToday: parseBool(j['claimedToday']),
        coinEarnedToday: parseInt(j['coinEarnedToday']),
        lastLoginDate: parseDateTime(j['lastLoginDate']),
      );

  @override
  List<Object?> get props =>
      [current, max, claimedToday, coinEarnedToday, lastLoginDate];
}

class Booster extends Equatable {
  const Booster({
    required this.id,
    required this.name,
    required this.description,
    required this.coinCost,
    this.icon,
    this.quantity,
  });

  final int id;
  final String name;
  final String description;
  final int coinCost;
  final String? icon;
  final int? quantity;

  factory Booster.fromJson(Map<String, dynamic> j) => Booster(
        id: parseIntOr(j['id'] ?? j['boosterTypeId'], 0),
        name: parseStringOr(j['name'] ?? j['title'], ''),
        description: parseStringOr(j['description'], ''),
        coinCost: parseIntOr(j['coinCost'] ?? j['cost'] ?? j['price'], 0),
        icon: parseString(j['icon'] ?? j['image']),
        quantity: parseInt(j['quantity'] ?? j['owned']),
      );

  @override
  List<Object?> get props => [id, name, description, coinCost, icon, quantity];
}
