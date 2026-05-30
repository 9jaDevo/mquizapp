/// App-wide constants: string keys, asset paths, default values.
library;

abstract final class AppConstants {
  AppConstants._();

  // ── App ────────────────────────────────────────────────────────────────────
  static const String appName = 'mQuiz';
  static const String packageName = 'com.togafrica.mquiz';

  // ── Asset Paths ─────────────────────────────────────────────────────────────
  static const String assetsImages = 'assets/images/';
  static const String assetsAnimations = 'assets/animations/';
  static const String assetsConfig = 'assets/config/';

  // ── Placeholder Assets (replace with originals before store submission) ────
  static const String logoImage = '${assetsImages}logo.png';
  static const String logoWhiteImage = '${assetsImages}logo_white.png';
  static const String onboarding1 = '${assetsImages}onboarding_1.png';
  static const String onboarding2 = '${assetsImages}onboarding_2.png';
  static const String onboarding3 = '${assetsImages}onboarding_3.png';
  static const String googleLogoSvg = '${assetsImages}google_logo.svg';
  static const String appleLogoSvg = '${assetsImages}apple_logo.svg';

  // ── Lottie Animations ──────────────────────────────────────────────────────
  static const String confettiAnimation = '${assetsAnimations}confetti.json';
  static const String correctAnimation = '${assetsAnimations}correct.json';
  static const String wrongAnimation = '${assetsAnimations}wrong.json';
  static const String loadingAnimation = '${assetsAnimations}loading.json';
  static const String emptyAnimation = '${assetsAnimations}empty.json';

  // ── Pagination Defaults ────────────────────────────────────────────────────
  static const int defaultPageSize = 20;
  static const int leaderboardPageSize = 50;

  // ── Quiz Defaults ──────────────────────────────────────────────────────────
  static const int defaultQuestionsPerQuiz = 10;
  static const int secondsPerQuestion = 30;
  static const int maxLives = 5;

  // ── Coin Defaults ──────────────────────────────────────────────────────────
  static const int coinCostPerLifeRestore = 20;

  // ── Auth ───────────────────────────────────────────────────────────────────
  static const String authTypeGoogle = 'google';
  static const String authTypeApple = 'apple';
  static const String authTypePhone = 'phone';
  static const String authTypeGuest = 'guest';

  // ── Routes (must match GoRouter paths in router.dart) ─────────────────────
  static const String routeSplash = '/';
  static const String routeLogin = '/login';
  static const String routeOtp = '/otp';
  static const String routeProfileSetup = '/profile-setup';
  static const String routeHome = '/home';
  static const String routeCategories = '/categories';
  static const String routeLeaderboard = '/leaderboard';
  static const String routeProfile = '/profile';
  static const String routeProfileEdit = '/profile/edit';
  static const String routeCoinHistory = '/profile/coin-history';
  static const String routeNotifications = '/notifications';
  static const String routeSettings = '/settings';
  static const String routeBookmarks = '/bookmarks';
  static const String routeSubcategories = '/categories/:categoryId';
  static const String routeQuiz = '/quiz';
  static const String routeQuizResult = '/quiz/result';
  static const String routeLeagues = '/leagues';
  static const String routeLeagueDetail = '/leagues/:leagueId';
  static const String routeContests = '/contests';
  static const String routeContestDetail = '/contests/:contestId';
  static const String routeCoinStore = '/store';
  static const String routeBoosters = '/boosters';
  static const String routeProgressMap = '/progress';
  static const String routeLeagueQuiz = '/leagues/:leagueId/play';
  static const String routeContestPlay = '/contests/:contestId/play';
  static const String routeSessionResult = '/quiz/session-result';
  static const String routeBattle = '/battle';
  static const String routeBattleLive = '/battle/live';
  static const String routeBattleResult = '/battle/result';

  // ── Extra route params ─────────────────────────────────────────────────────
  static const String paramCategoryId = 'categoryId';
  static const String paramContestId = 'contestId';
  static const String paramLeagueId = 'leagueId';

  // ── SharedPreferences/SecureStorage Keys ─────────────────────────────────
  // NOTE: All sensitive keys are in SecureStorage — NOT here.
  // This section is for non-sensitive config only.

  // ── Supported Languages ───────────────────────────────────────────────────
  static const String defaultLanguageId = '1';
  static const List<String> supportedLocales = ['en', 'fr'];
}
