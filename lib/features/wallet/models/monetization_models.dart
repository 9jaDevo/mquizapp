/// Daily streak data model
class DailyStreak {
  final int streakCount;
  final int coinsEarned;
  final bool bonusUnlocked;
  final int maxStreak;

  const DailyStreak({
    required this.streakCount,
    required this.coinsEarned,
    required this.bonusUnlocked,
    required this.maxStreak,
  });

  factory DailyStreak.fromJson(Map<String, dynamic> json) {
    return DailyStreak(
      streakCount: int.parse(json['streak_count']?.toString() ?? '0'),
      coinsEarned: int.parse(json['coins_earned']?.toString() ?? '0'),
      bonusUnlocked: json['bonus_unlocked']?.toString().toLowerCase() == 'true' || json['bonus_unlocked'] == 1,
      maxStreak: int.parse(json['max_streak']?.toString() ?? '0'),
    );
  }

  Map<String, dynamic> toJson() => {
    'streak_count': streakCount,
    'coins_earned': coinsEarned,
    'bonus_unlocked': bonusUnlocked,
    'max_streak': maxStreak,
  };
}

/// Device registration response model
class DeviceRegistration {
  final String status; // 'allowed' or 'suspended'
  final String message;
  final int conflictCount;

  const DeviceRegistration({
    required this.status,
    required this.message,
    required this.conflictCount,
  });

  factory DeviceRegistration.fromJson(Map<String, dynamic> json) {
    return DeviceRegistration(
      status: json['status']?.toString() ?? 'allowed',
      message: json['message']?.toString() ?? '',
      conflictCount: int.parse(json['conflict_count']?.toString() ?? '0'),
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'message': message,
    'conflict_count': conflictCount,
  };
}

/// Fraud detection result model
class FraudDetection {
  final bool isSuspicious;
  final List<Map<String, dynamic>> detections;

  const FraudDetection({
    required this.isSuspicious,
    required this.detections,
  });

  factory FraudDetection.fromJson(Map<String, dynamic> json) {
    return FraudDetection(
      isSuspicious: json['is_suspicious']?.toString().toLowerCase() == 'true' || json['is_suspicious'] == 1,
      detections: List<Map<String, dynamic>>.from(json['detections'] as List? ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
    'is_suspicious': isSuspicious,
    'detections': detections,
  };
}

/// Payout eligibility model
class PayoutEligibility {
  final bool eligible;
  final int activeDays;
  final int requiredDays;
  final String message;

  const PayoutEligibility({
    required this.eligible,
    required this.activeDays,
    required this.requiredDays,
    required this.message,
  });

  factory PayoutEligibility.fromJson(Map<String, dynamic> json) {
    return PayoutEligibility(
      eligible: json['eligible']?.toString().toLowerCase() == 'true' || json['eligible'] == 1,
      activeDays: int.parse(json['active_days']?.toString() ?? '0'),
      requiredDays: int.parse(json['required_days']?.toString() ?? '0'),
      message: json['message']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'eligible': eligible,
    'active_days': activeDays,
    'required_days': requiredDays,
    'message': message,
  };
}

/// Sponsor banner model
class SponsorBanner {
  final String bannerId;
  final String sponsorName;
  final String title;
  final String imageUrl;
  final String redirectUrl;
  final int impressionLimit;
  final int totalImpressions;
  final int todayImpressions;

  const SponsorBanner({
    required this.bannerId,
    required this.sponsorName,
    required this.title,
    required this.imageUrl,
    required this.redirectUrl,
    required this.impressionLimit,
    this.totalImpressions = 0,
    this.todayImpressions = 0,
  });

  factory SponsorBanner.fromJson(Map<String, dynamic> json) {
    return SponsorBanner(
      bannerId: json['banner_id']?.toString() ?? json['id']?.toString() ?? '',
      sponsorName: json['sponsor_name']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      imageUrl: json['image_url']?.toString() ?? json['image']?.toString() ?? '',
      redirectUrl: json['redirect_url']?.toString() ?? '',
      impressionLimit: int.parse(json['impression_limit']?.toString() ?? '0'),
      totalImpressions: int.parse(json['total_impressions']?.toString() ?? '0'),
      todayImpressions: int.parse(json['today_impressions']?.toString() ?? '0'),
    );
  }

  Map<String, dynamic> toJson() => {
    'banner_id': bannerId,
    'sponsor_name': sponsorName,
    'title': title,
    'image_url': imageUrl,
    'redirect_url': redirectUrl,
    'impression_limit': impressionLimit,
    'total_impressions': totalImpressions,
    'today_impressions': todayImpressions,
  };
}

/// Boost earnings offer model
class BoostEarnings {
  final int originalCoins;
  final int boostedCoins;
  final double multiplier;
  final int coinDifference;

  const BoostEarnings({
    required this.originalCoins,
    required this.boostedCoins,
    required this.multiplier,
    required this.coinDifference,
  });

  factory BoostEarnings.fromJson(Map<String, dynamic> json) {
    return BoostEarnings(
      originalCoins: int.parse(json['original_coins']?.toString() ?? '0'),
      boostedCoins: int.parse(json['boosted_coins']?.toString() ?? '0'),
      multiplier: double.parse(json['multiplier']?.toString() ?? '1.0'),
      coinDifference: int.parse(json['coin_difference']?.toString() ?? '0'),
    );
  }

  Map<String, dynamic> toJson() => {
    'original_coins': originalCoins,
    'boosted_coins': boostedCoins,
    'multiplier': multiplier,
    'coin_difference': coinDifference,
  };
}

/// Watch unlock premium configuration model
class WatchUnlockConfig {
  final bool enabled;
  final int adCountRequired;
  final String message;

  const WatchUnlockConfig({
    required this.enabled,
    required this.adCountRequired,
    required this.message,
  });

  factory WatchUnlockConfig.fromJson(Map<String, dynamic> json) {
    return WatchUnlockConfig(
      enabled: json['enabled']?.toString().toLowerCase() == 'true' || json['enabled'] == 1,
      adCountRequired: int.parse(json['ad_count_required']?.toString() ?? '0'),
      message: json['message']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    'ad_count_required': adCountRequired,
    'message': message,
  };
}
