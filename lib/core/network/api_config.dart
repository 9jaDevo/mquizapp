/// NestJS API configuration.
///
/// Base URL is set at build time via --dart-define=API_BASE_URL=https://...
/// Falls back to the production URL if not provided.
library;

const String _kDefaultBase = 'https://mquizapi.onrender.com';

/// The root URL for all NestJS API calls (no trailing slash).
const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: _kDefaultBase,
);

/// Current API version prefix.
const String apiVersion = '/v2';

/// Full versioned base, e.g. https://mquizapi.onrender.com/v2
const String apiRoot = '$apiBaseUrl$apiVersion';

/// Phase 3 migration feature flags.
///
/// Each flag controls whether a feature uses the NestJS backend or the legacy
/// PHP backend. Default is `false` (PHP) until the feature has been verified
/// in production. Flip to `true` per feature once verified.
///
/// Override at build time:
/// `--dart-define=USE_NESTJS_AUTH=true --dart-define=USE_NESTJS_QUIZ=true`
class ApiMigration {
  ApiMigration._();

  /// Global kill-switch — if false, all NestJS routing is bypassed.
  static const bool globallyEnabled = bool.fromEnvironment(
    'USE_NESTJS',
    defaultValue: true,
  );

  static const bool auth = bool.fromEnvironment('USE_NESTJS_AUTH', defaultValue: false);
  static const bool profile = bool.fromEnvironment('USE_NESTJS_PROFILE', defaultValue: false);
  static const bool categories = bool.fromEnvironment('USE_NESTJS_CATEGORIES', defaultValue: false);
  static const bool quiz = bool.fromEnvironment('USE_NESTJS_QUIZ', defaultValue: false);
  static const bool bookmarks = bool.fromEnvironment('USE_NESTJS_BOOKMARKS', defaultValue: false);
  static const bool leaderboard = bool.fromEnvironment('USE_NESTJS_LEADERBOARD', defaultValue: false);
  static const bool badges = bool.fromEnvironment('USE_NESTJS_BADGES', defaultValue: false);
  static const bool streak = bool.fromEnvironment('USE_NESTJS_STREAK', defaultValue: false);
  static const bool stats = bool.fromEnvironment('USE_NESTJS_STATS', defaultValue: false);
  static const bool dailyChallenge = bool.fromEnvironment('USE_NESTJS_DAILY_CHALLENGE', defaultValue: false);
  static const bool contests = bool.fromEnvironment('USE_NESTJS_CONTESTS', defaultValue: false);
  static const bool leagues = bool.fromEnvironment('USE_NESTJS_LEAGUES', defaultValue: false);
  static const bool coins = bool.fromEnvironment('USE_NESTJS_COINS', defaultValue: false);
  static const bool lives = bool.fromEnvironment('USE_NESTJS_LIVES', defaultValue: false);
  static const bool boosters = bool.fromEnvironment('USE_NESTJS_BOOSTERS', defaultValue: false);
  static const bool payments = bool.fromEnvironment('USE_NESTJS_PAYMENTS', defaultValue: false);
  static const bool ads = bool.fromEnvironment('USE_NESTJS_ADS', defaultValue: false);
  static const bool config = bool.fromEnvironment('USE_NESTJS_CONFIG', defaultValue: false);
  static const bool notifications = bool.fromEnvironment('USE_NESTJS_NOTIFICATIONS', defaultValue: false);
  static const bool referral = bool.fromEnvironment('USE_NESTJS_REFERRAL', defaultValue: false);

  /// Returns true if the named feature is currently routed to NestJS.
  static bool isEnabled(String feature) {
    if (!globallyEnabled) return false;
    switch (feature) {
      case 'auth': return auth;
      case 'profile': return profile;
      case 'categories': return categories;
      case 'quiz': return quiz;
      case 'bookmarks': return bookmarks;
      case 'leaderboard': return leaderboard;
      case 'badges': return badges;
      case 'streak': return streak;
      case 'stats': return stats;
      case 'dailyChallenge': return dailyChallenge;
      case 'contests': return contests;
      case 'leagues': return leagues;
      case 'coins': return coins;
      case 'lives': return lives;
      case 'boosters': return boosters;
      case 'payments': return payments;
      case 'ads': return ads;
      case 'config': return config;
      case 'notifications': return notifications;
      case 'referral': return referral;
      default: return false;
    }
  }
}
