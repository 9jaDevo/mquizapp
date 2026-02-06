/// Model for engagement leaderboard entry
class EngagementLeaderboardEntry {
  final String userId;
  final String totalMinutes;
  final String userRank;
  final String email;
  final String name;
  final String profile;
  final String? countryCode;
  final String? continent;

  EngagementLeaderboardEntry({
    required this.userId,
    required this.totalMinutes,
    required this.userRank,
    required this.email,
    required this.name,
    required this.profile,
    this.countryCode,
    this.continent,
  });

  factory EngagementLeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return EngagementLeaderboardEntry(
      userId: json['user_id']?.toString() ?? '',
      totalMinutes: json['total_minutes']?.toString() ?? '0',
      userRank: json['user_rank']?.toString() ?? '0',
      email: json['email']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      profile: json['profile']?.toString() ?? '',
      countryCode: json['country_code']?.toString(),
      continent: json['continent']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'total_minutes': totalMinutes,
      'user_rank': userRank,
      'email': email,
      'name': name,
      'profile': profile,
      'country_code': countryCode,
      'continent': continent,
    };
  }

  /// Get formatted time string (e.g., "12h 34m")
  String getFormattedTime() {
    final minutes = double.tryParse(totalMinutes) ?? 0.0;
    final hours = (minutes / 60).floor();
    final remainingMinutes = (minutes % 60).round();

    if (hours > 0) {
      return '${hours}h ${remainingMinutes}m';
    } else {
      return '${remainingMinutes}m';
    }
  }

  /// Get compact formatted time for small spaces (e.g., "12.5h" or "34m")
  String getCompactFormattedTime() {
    final minutes = double.tryParse(totalMinutes) ?? 0.0;

    if (minutes >= 60) {
      final hours = (minutes / 60);
      return '${hours.toStringAsFixed(1)}h';
    } else {
      return '${minutes.round()}m';
    }
  }

  /// Get total hours as double
  double getTotalHours() {
    final minutes = double.tryParse(totalMinutes) ?? 0.0;
    return minutes / 60;
  }

  /// Get total minutes as int
  int getTotalMinutes() {
    return int.tryParse(totalMinutes) ?? 0;
  }
}

/// Model for user's own engagement rank
class EngagementMyRank {
  final String userId;
  final String totalMinutes;
  final String userRank;
  final String email;
  final String name;
  final String profile;
  final String? countryCode;
  final String? continent;

  EngagementMyRank({
    required this.userId,
    required this.totalMinutes,
    required this.userRank,
    required this.email,
    required this.name,
    required this.profile,
    this.countryCode,
    this.continent,
  });

  factory EngagementMyRank.fromJson(Map<String, dynamic> json) {
    return EngagementMyRank(
      userId: json['user_id']?.toString() ?? '',
      totalMinutes: json['total_minutes']?.toString() ?? '0',
      userRank: json['user_rank']?.toString() ?? '0',
      email: json['email']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      profile: json['profile']?.toString() ?? '',
      countryCode: json['country_code']?.toString(),
      continent: json['continent']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'total_minutes': totalMinutes,
      'user_rank': userRank,
      'email': email,
      'name': name,
      'profile': profile,
      'country_code': countryCode,
      'continent': continent,
    };
  }

  /// Get formatted time string (e.g., "12h 34m")
  String getFormattedTime() {
    final minutes = double.tryParse(totalMinutes) ?? 0.0;
    final hours = (minutes / 60).floor();
    final remainingMinutes = (minutes % 60).round();

    if (hours > 0) {
      return '${hours}h ${remainingMinutes}m';
    } else {
      return '${remainingMinutes}m';
    }
  }

  /// Get compact formatted time for small spaces (e.g., "12.5h" or "34m")
  String getCompactFormattedTime() {
    final minutes = double.tryParse(totalMinutes) ?? 0.0;

    if (minutes >= 60) {
      final hours = (minutes / 60);
      return '${hours.toStringAsFixed(1)}h';
    } else {
      return '${minutes.round()}m';
    }
  }

  /// Get total hours as double
  double getTotalHours() {
    final minutes = double.tryParse(totalMinutes) ?? 0.0;
    return minutes / 60;
  }

  /// Get total minutes as int
  int getTotalMinutes() {
    return int.tryParse(totalMinutes) ?? 0;
  }

  /// Convert to EngagementLeaderboardEntry
  EngagementLeaderboardEntry toLeaderboardEntry() {
    return EngagementLeaderboardEntry(
      userId: userId,
      totalMinutes: totalMinutes,
      userRank: userRank,
      email: email,
      name: name,
      profile: profile,
      countryCode: countryCode,
      continent: continent,
    );
  }
}
