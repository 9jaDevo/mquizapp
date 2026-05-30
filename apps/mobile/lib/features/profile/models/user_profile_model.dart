import 'package:equatable/equatable.dart';
import 'package:mquiz/core/utils/parsers.dart';

class LivesSnapshot extends Equatable {
  const LivesSnapshot({
    required this.current,
    required this.max,
    this.lastRefillAt,
    this.nextRefillAt,
    this.intervalMs,
  });

  factory LivesSnapshot.fromJson(Map<String, dynamic> j) => LivesSnapshot(
        current: parseIntOr(j['current'], 0),
        max: parseIntOr(j['max'], 5),
        lastRefillAt: parseDateTime(j['lastRefillAt']),
        nextRefillAt: parseDateTime(j['nextRefillAt']),
        intervalMs: parseInt(j['intervalMs']),
      );

  final int current;
  final int max;
  final DateTime? lastRefillAt;
  final DateTime? nextRefillAt;
  final int? intervalMs;

  bool get isFull => current >= max;
  bool get isEmpty => current <= 0;

  @override
  List<Object?> get props =>
      [current, max, lastRefillAt, nextRefillAt, intervalMs];
}

class StreakSnapshot extends Equatable {
  const StreakSnapshot({
    required this.current,
    required this.max,
    required this.coinEarnedToday,
    this.lastLoginDate,
    this.claimedToday = false,
  });

  factory StreakSnapshot.fromJson(Map<String, dynamic> j) => StreakSnapshot(
        current: parseIntOr(j['current'], 0),
        max: parseIntOr(j['max'], 0),
        coinEarnedToday: parseIntOr(j['coinEarnedToday'], 0),
        lastLoginDate: parseDateTime(j['lastLoginDate']),
        claimedToday: parseBool(j['claimedToday']),
      );

  final int current;
  final int max;
  final int coinEarnedToday;
  final DateTime? lastLoginDate;
  final bool claimedToday;

  @override
  List<Object?> get props =>
      [current, max, coinEarnedToday, lastLoginDate, claimedToday];
}

class ProgressSnapshot extends Equatable {
  const ProgressSnapshot({
    required this.stageNumber,
    required this.totalScore,
  });

  factory ProgressSnapshot.fromJson(Map<String, dynamic> j) =>
      ProgressSnapshot(
        stageNumber: parseIntOr(j['stageNumber'], 1),
        totalScore: parseIntOr(j['totalScore'], 0),
      );

  final int stageNumber;
  final int totalScore;

  @override
  List<Object?> get props => [stageNumber, totalScore];
}

class UserProfile extends Equatable {
  const UserProfile({
    required this.id,
    required this.firebaseId,
    required this.name,
    required this.coins,
    this.email,
    this.mobile,
    this.profileImage,
    this.type,
    this.referCode,
    this.friendsCode,
    this.removeAds = false,
    this.countryCode,
    this.countryName,
    this.appLanguage,
    this.ageGroup,
    this.dateRegistered,
    this.lives,
    this.progress,
    this.streak,
  });

  factory UserProfile.fromJson(Map<String, dynamic> j) {
    final livesJson = j['lives'];
    final progressJson = j['progress'];
    final streakJson = j['streak'];
    return UserProfile(
      id: parseIntOr(j['id'], 0),
      firebaseId: parseStringOr(j['firebaseId'], ''),
      name: parseStringOr(j['name'], ''),
      coins: parseIntOr(j['coins'], 0),
      email: parseString(j['email']),
      mobile: parseString(j['mobile']),
      profileImage: parseString(j['profile']),
      type: parseString(j['type']),
      referCode: parseString(j['referCode']),
      friendsCode: parseString(j['friendsCode']),
      removeAds: parseBool(j['removeAds']),
      countryCode: parseString(j['countryCode']),
      countryName: parseString(j['countryName']),
      appLanguage: parseString(j['appLanguage']),
      ageGroup: parseString(j['ageGroup']),
      dateRegistered: parseDateTime(j['dateRegistered']),
      lives: livesJson is Map<String, dynamic>
          ? LivesSnapshot.fromJson(livesJson)
          : null,
      progress: progressJson is Map<String, dynamic>
          ? ProgressSnapshot.fromJson(progressJson)
          : null,
      streak: streakJson is Map<String, dynamic>
          ? StreakSnapshot.fromJson(streakJson)
          : null,
    );
  }

  final int id;
  final String firebaseId;
  final String name;
  final int coins;
  final String? email;
  final String? mobile;
  final String? profileImage;
  final String? type;
  final String? referCode;
  final String? friendsCode;
  final bool removeAds;
  final String? countryCode;
  final String? countryName;
  final String? appLanguage;
  final String? ageGroup;
  final DateTime? dateRegistered;
  final LivesSnapshot? lives;
  final ProgressSnapshot? progress;
  final StreakSnapshot? streak;

  UserProfile copyWith({
    String? name,
    int? coins,
    String? profileImage,
    String? mobile,
    String? appLanguage,
    String? ageGroup,
    String? countryCode,
    String? countryName,
    LivesSnapshot? lives,
    ProgressSnapshot? progress,
    StreakSnapshot? streak,
  }) {
    return UserProfile(
      id: id,
      firebaseId: firebaseId,
      name: name ?? this.name,
      coins: coins ?? this.coins,
      email: email,
      mobile: mobile ?? this.mobile,
      profileImage: profileImage ?? this.profileImage,
      type: type,
      referCode: referCode,
      friendsCode: friendsCode,
      removeAds: removeAds,
      countryCode: countryCode ?? this.countryCode,
      countryName: countryName ?? this.countryName,
      appLanguage: appLanguage ?? this.appLanguage,
      ageGroup: ageGroup ?? this.ageGroup,
      dateRegistered: dateRegistered,
      lives: lives ?? this.lives,
      progress: progress ?? this.progress,
      streak: streak ?? this.streak,
    );
  }

  @override
  List<Object?> get props => [
        id,
        firebaseId,
        name,
        coins,
        email,
        mobile,
        profileImage,
        removeAds,
        countryCode,
        appLanguage,
        ageGroup,
        lives,
        progress,
        streak,
      ];
}
