/// All NestJS API endpoints for the mQuiz mobile app.
///
/// Single comprehensive client — every method maps to one route in apps/api/.
/// All methods return the unwrapped `data` field from the response envelope.
/// They throw [ApiClientException] on any error (HTTP, network, envelope).
///
/// Security: auth token is attached by ApiClient's interceptor — never pass
/// it manually. User identity is always derived from Firebase token server-side.
library;

import 'package:mquiz/core/network/api_client.dart';

class NestJsApi {
  NestJsApi._();
  static final NestJsApi instance = NestJsApi._();

  ApiClient get _c => ApiClient.instance;

  // ── Auth ───────────────────────────────────────────────────────────────────
  // POST /auth/login — verifies Firebase ID token (already in Authorization header)
  Future<Map<String, dynamic>> authLogin({
    required String type,
    String? name,
    String? email,
    String? mobile,
    String? profile,
    String? referCode,
    String? friendCode,
    String? appLanguage,
    String? fcmToken,
  }) async {
    final res = await _c.post<Map<String, dynamic>>(
      '/auth/login',
      (d) => Map<String, dynamic>.from(d as Map),
      body: {
        'type': type,
        if (name != null) 'name': name,
        if (email != null) 'email': email,
        if (mobile != null) 'mobile': mobile,
        if (profile != null) 'profile': profile,
        if (referCode != null) 'refer_code': referCode,
        if (friendCode != null) 'friend_code': friendCode,
        if (appLanguage != null) 'app_language': appLanguage,
        if (fcmToken != null) 'fcm_token': fcmToken,
      },
    );
    return res.data ?? <String, dynamic>{};
  }

  // POST /auth/guest
  Future<Map<String, dynamic>> authGuest({String? appLanguage}) async {
    final res = await _c.post<Map<String, dynamic>>(
      '/auth/guest',
      (d) => Map<String, dynamic>.from(d as Map),
      body: {if (appLanguage != null) 'app_language': appLanguage},
    );
    return res.data ?? <String, dynamic>{};
  }

  // ── Users / Profile ────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> getMe() async {
    final res = await _c.get<Map<String, dynamic>>(
      '/users/me',
      (d) => Map<String, dynamic>.from(d as Map),
    );
    return res.data ?? <String, dynamic>{};
  }

  Future<Map<String, dynamic>> updateMe(Map<String, dynamic> patch) async {
    final res = await _c.put<Map<String, dynamic>>(
      '/users/me',
      (d) => Map<String, dynamic>.from(d as Map),
      body: patch,
    );
    return res.data ?? <String, dynamic>{};
  }

  Future<Map<String, dynamic>> getMyStats() async {
    final res = await _c.get<Map<String, dynamic>>(
      '/users/me/stats',
      (d) => Map<String, dynamic>.from(d as Map),
    );
    return res.data ?? <String, dynamic>{};
  }

  Future<List<Map<String, dynamic>>> getMyBadges() async {
    final res = await _c.get<Map<String, dynamic>>(
      '/users/me/badges',
      (d) => Map<String, dynamic>.from(d as Map),
    );
    return _asMapList(res.data?['badges']);
  }

  Future<Map<String, dynamic>> getMyCoinHistory({
    int page = 1,
    int limit = 20,
  }) async {
    final res = await _c.get<Map<String, dynamic>>(
      '/users/me/coin-history',
      (d) => Map<String, dynamic>.from(d as Map),
      queryParameters: {'page': page, 'limit': limit},
    );
    return res.data ?? <String, dynamic>{};
  }

  Future<void> updateFcmToken(String token) async {
    await _c.put<dynamic>(
      '/users/me/fcm-token',
      (d) => d,
      body: {'fcm_token': token},
    );
  }

  // ── Categories ─────────────────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> getCategories({
    int? languageId,
    String? type,
  }) async {
    final res = await _c.get<Map<String, dynamic>>(
      '/categories',
      (d) => Map<String, dynamic>.from(d as Map),
      queryParameters: {
        if (languageId != null) 'languageId': languageId,
        if (type != null) 'type': type,
      },
    );
    return _asMapList(res.data?['categories']);
  }

  Future<List<Map<String, dynamic>>> getSubcategories(
    int categoryId, {
    int? languageId,
  }) async {
    final res = await _c.get<Map<String, dynamic>>(
      '/categories/$categoryId/subcategories',
      (d) => Map<String, dynamic>.from(d as Map),
      queryParameters: {
        if (languageId != null) 'languageId': languageId,
      },
    );
    return _asMapList(res.data?['subcategories']);
  }

  // ── Quiz ───────────────────────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> getQuestions({
    int? categoryId,
    int? subcategoryId,
    int? level,
    int? limit,
    int? languageId,
  }) async {
    final res = await _c.get<Map<String, dynamic>>(
      '/quiz/questions',
      (d) => Map<String, dynamic>.from(d as Map),
      queryParameters: {
        if (categoryId != null) 'categoryId': categoryId,
        if (subcategoryId != null) 'subcategoryId': subcategoryId,
        if (level != null) 'level': level,
        if (limit != null) 'limit': limit,
        if (languageId != null) 'languageId': languageId,
      },
    );
    return _asMapList(res.data?['questions']);
  }

  Future<Map<String, dynamic>> submitQuiz(Map<String, dynamic> payload) async {
    final res = await _c.post<Map<String, dynamic>>(
      '/quiz/submit',
      (d) => Map<String, dynamic>.from(d as Map),
      body: payload,
    );
    return res.data ?? <String, dynamic>{};
  }

  Future<Map<String, dynamic>> getDailyChallenge() async {
    final res = await _c.get<Map<String, dynamic>>(
      '/quiz/daily-challenge',
      (d) => Map<String, dynamic>.from(d as Map),
    );
    return res.data ?? <String, dynamic>{};
  }

  Future<Map<String, dynamic>> submitDailyChallenge(
      Map<String, dynamic> payload) async {
    final res = await _c.post<Map<String, dynamic>>(
      '/quiz/daily-challenge/submit',
      (d) => Map<String, dynamic>.from(d as Map),
      body: payload,
    );
    return res.data ?? <String, dynamic>{};
  }

  // ── Bookmarks ──────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> listBookmarks({
    int page = 1,
    int limit = 50,
  }) async {
    final res = await _c.get<Map<String, dynamic>>(
      '/bookmarks',
      (d) => Map<String, dynamic>.from(d as Map),
      queryParameters: {'page': page, 'limit': limit},
    );
    return res.data ?? <String, dynamic>{};
  }

  Future<Map<String, dynamic>> addBookmark(int questionId) async {
    final res = await _c.post<Map<String, dynamic>>(
      '/bookmarks',
      (d) => Map<String, dynamic>.from(d as Map),
      body: {'question_id': questionId},
    );
    return res.data ?? <String, dynamic>{};
  }

  Future<void> removeBookmark(int questionId) async {
    await _c.delete<dynamic>('/bookmarks/$questionId', (d) => d);
  }

  // ── Leaderboard ────────────────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> getLeaderboard(
    String period, {
    int limit = 50,
  }) async {
    // period: daily | weekly | monthly
    final res = await _c.get<Map<String, dynamic>>(
      '/leaderboard/$period',
      (d) => Map<String, dynamic>.from(d as Map),
      queryParameters: {'limit': limit},
    );
    return _asMapList(res.data?['entries']);
  }

  Future<Map<String, dynamic>> getMyLeaderboardRank() async {
    final res = await _c.get<Map<String, dynamic>>(
      '/leaderboard/me',
      (d) => Map<String, dynamic>.from(d as Map),
    );
    return res.data ?? <String, dynamic>{};
  }

  Future<List<Map<String, dynamic>>> getCategoryLeaderboard(
    int categoryId,
    String period, {
    int limit = 50,
  }) async {
    final res = await _c.get<Map<String, dynamic>>(
      '/leaderboard/category/$categoryId',
      (d) => Map<String, dynamic>.from(d as Map),
      queryParameters: {'period': period, 'limit': limit},
    );
    return _asMapList(res.data?['entries']);
  }

  // ── Streak ─────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> getStreak() async {
    final res = await _c.get<Map<String, dynamic>>(
      '/streak/me',
      (d) => Map<String, dynamic>.from(d as Map),
    );
    return res.data ?? <String, dynamic>{};
  }

  Future<Map<String, dynamic>> claimDailyStreak() async {
    final res = await _c.post<Map<String, dynamic>>(
      '/streak/claim-daily',
      (d) => Map<String, dynamic>.from(d as Map),
    );
    return res.data ?? <String, dynamic>{};
  }

  // ── Contests ───────────────────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> listContests() async {
    final res = await _c.get<List<Map<String, dynamic>>>(
      '/contests',
      _asMapList,
    );
    return res.data ?? const [];
  }

  Future<List<Map<String, dynamic>>> getContestQuestions(int id) async {
    final res = await _c.get<List<Map<String, dynamic>>>(
      '/contests/$id/questions',
      _asMapList,
    );
    return res.data ?? const [];
  }

  Future<Map<String, dynamic>> submitContest(
    int id,
    Map<String, dynamic> payload,
  ) async {
    final res = await _c.post<Map<String, dynamic>>(
      '/contests/$id/submit',
      (d) => Map<String, dynamic>.from(d as Map),
      body: payload,
    );
    return res.data ?? <String, dynamic>{};
  }

  Future<List<Map<String, dynamic>>> getContestLeaderboard(int id) async {
    final res = await _c.get<List<Map<String, dynamic>>>(
      '/contests/$id/leaderboard',
      _asMapList,
    );
    return res.data ?? const [];
  }

  // ── Leagues ────────────────────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> listLeagues() async {
    final res = await _c.get<List<Map<String, dynamic>>>(
      '/leagues',
      _asMapList,
    );
    return res.data ?? const [];
  }

  Future<Map<String, dynamic>> getMyLeague() async {
    final res = await _c.get<Map<String, dynamic>>(
      '/leagues/me',
      (d) => Map<String, dynamic>.from(d as Map),
    );
    return res.data ?? <String, dynamic>{};
  }

  Future<Map<String, dynamic>> getLeague(int id) async {
    final res = await _c.get<Map<String, dynamic>>(
      '/leagues/$id',
      (d) => Map<String, dynamic>.from(d as Map),
    );
    return res.data ?? <String, dynamic>{};
  }

  Future<Map<String, dynamic>> optInLeague(int id) async {
    final res = await _c.post<Map<String, dynamic>>(
      '/leagues/$id/opt-in',
      (d) => Map<String, dynamic>.from(d as Map),
    );
    return res.data ?? <String, dynamic>{};
  }

  Future<Map<String, dynamic>> getTodayLeagueQuestions(int id) async {
    final res = await _c.get<Map<String, dynamic>>(
      '/leagues/$id/today',
      (d) => Map<String, dynamic>.from(d as Map),
    );
    return res.data ?? <String, dynamic>{};
  }

  Future<Map<String, dynamic>> submitLeagueAnswers(
    int id,
    Map<String, dynamic> payload,
  ) async {
    final res = await _c.post<Map<String, dynamic>>(
      '/leagues/$id/submit',
      (d) => Map<String, dynamic>.from(d as Map),
      body: payload,
    );
    return res.data ?? <String, dynamic>{};
  }

  Future<List<Map<String, dynamic>>> getLeagueLeaderboard(int id) async {
    final res = await _c.get<List<Map<String, dynamic>>>(
      '/leagues/$id/leaderboard',
      _asMapList,
    );
    return res.data ?? const [];
  }

  // ── Coins ──────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> getCoinBalance() async {
    final res = await _c.get<Map<String, dynamic>>(
      '/coins/balance',
      (d) => Map<String, dynamic>.from(d as Map),
    );
    return res.data ?? <String, dynamic>{};
  }

  Future<List<Map<String, dynamic>>> getCoinStore() async {
    final res = await _c.get<Map<String, dynamic>>(
      '/coins/store',
      (d) => Map<String, dynamic>.from(d as Map),
    );
    return _asMapList(res.data?['items']);
  }

  Future<Map<String, dynamic>> getCoinHistory({
    int page = 1,
    int limit = 20,
  }) async {
    final res = await _c.get<Map<String, dynamic>>(
      '/coins/history',
      (d) => Map<String, dynamic>.from(d as Map),
      queryParameters: {'page': page, 'limit': limit},
    );
    return res.data ?? <String, dynamic>{};
  }

  // ── Lives ──────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> getLives() async {
    final res = await _c.get<Map<String, dynamic>>(
      '/lives/me',
      (d) => Map<String, dynamic>.from(d as Map),
    );
    return res.data ?? <String, dynamic>{};
  }

  Future<Map<String, dynamic>> consumeLife() async {
    final res = await _c.post<Map<String, dynamic>>(
      '/lives/consume',
      (d) => Map<String, dynamic>.from(d as Map),
    );
    return res.data ?? <String, dynamic>{};
  }

  Future<Map<String, dynamic>> restoreLifeWithCoins() async {
    final res = await _c.post<Map<String, dynamic>>(
      '/lives/restore-with-coins',
      (d) => Map<String, dynamic>.from(d as Map),
    );
    return res.data ?? <String, dynamic>{};
  }

  Future<Map<String, dynamic>> restoreLifeWithAd() async {
    final res = await _c.post<Map<String, dynamic>>(
      '/lives/restore-with-ad',
      (d) => Map<String, dynamic>.from(d as Map),
    );
    return res.data ?? <String, dynamic>{};
  }

  // ── Boosters ───────────────────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> getBoosterTypes() async {
    final res = await _c.get<List<Map<String, dynamic>>>(
      '/boosters/types',
      _asMapList,
    );
    return res.data ?? const [];
  }

  Future<List<Map<String, dynamic>>> getMyBoosters() async {
    final res = await _c.get<List<Map<String, dynamic>>>(
      '/boosters/me',
      _asMapList,
    );
    return res.data ?? const [];
  }

  Future<Map<String, dynamic>> purchaseBooster(int boosterTypeId) async {
    final res = await _c.post<Map<String, dynamic>>(
      '/boosters/$boosterTypeId/purchase',
      (d) => Map<String, dynamic>.from(d as Map),
    );
    return res.data ?? <String, dynamic>{};
  }

  Future<Map<String, dynamic>> consumeBooster(int boosterTypeId) async {
    final res = await _c.post<Map<String, dynamic>>(
      '/boosters/consume',
      (d) => Map<String, dynamic>.from(d as Map),
      body: {'booster_type_id': boosterTypeId},
    );
    return res.data ?? <String, dynamic>{};
  }

  // ── Payments ───────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> initializePayment(
      Map<String, dynamic> payload) async {
    final res = await _c.post<Map<String, dynamic>>(
      '/payments/initialize',
      (d) => Map<String, dynamic>.from(d as Map),
      body: payload,
    );
    return res.data ?? <String, dynamic>{};
  }

  Future<Map<String, dynamic>> verifyPayment(String reference) async {
    final res = await _c.post<Map<String, dynamic>>(
      '/payments/verify/$reference',
      (d) => Map<String, dynamic>.from(d as Map),
    );
    return res.data ?? <String, dynamic>{};
  }

  /// Apple In-App Purchase server-side verification.
  /// Sends Apple receipt data to the NestJS endpoint which validates with Apple
  /// and credits coins. Server enforces [transactionId] idempotency.
  Future<Map<String, dynamic>> verifyAppleIap({
    required String productId,
    required String receiptData,
    required String transactionId,
  }) async {
    final res = await _c.post<Map<String, dynamic>>(
      '/payments/apple-iap/verify',
      (d) => Map<String, dynamic>.from(d as Map),
      body: {
        'productId': productId,
        'receiptData': receiptData,
        'transactionId': transactionId,
      },
    );
    return res.data ?? <String, dynamic>{};
  }

  Future<List<Map<String, dynamic>>> getPaymentHistory() async {
    final res = await _c.get<List<Map<String, dynamic>>>(
      '/payments/history',
      _asMapList,
    );
    return res.data ?? const [];
  }

  // ── Ads ────────────────────────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> getActiveBanners() async {
    final res = await _c.get<List<Map<String, dynamic>>>(
      '/ads/banners/active',
      _asMapList,
    );
    return res.data ?? const [];
  }

  Future<void> recordAdImpression(Map<String, dynamic> payload) async {
    await _c.post<dynamic>('/ads/impression', (d) => d, body: payload);
  }

  // ── Config ─────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> getSystemConfig() async {
    final res = await _c.get<Map<String, dynamic>>(
      '/config',
      (d) => Map<String, dynamic>.from(d as Map),
    );
    return res.data ?? <String, dynamic>{};
  }

  Future<Map<String, dynamic>> getConfigByType(String type) async {
    final res = await _c.get<Map<String, dynamic>>(
      '/config/by-type',
      (d) => Map<String, dynamic>.from(d as Map),
      queryParameters: {'type': type},
    );
    return res.data ?? <String, dynamic>{};
  }

  // ── Notifications ──────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> getNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    final res = await _c.get<Map<String, dynamic>>(
      '/notifications',
      (d) => Map<String, dynamic>.from(d as Map),
      queryParameters: {'page': page, 'limit': limit},
    );
    return res.data ?? <String, dynamic>{};
  }

  Future<void> markNotificationRead(int id) async {
    await _c.put<dynamic>('/notifications/$id/read', (d) => d);
  }

  // ── Referral ───────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> getReferralCode() async {
    final res = await _c.get<Map<String, dynamic>>(
      '/referral/me',
      (d) => Map<String, dynamic>.from(d as Map),
    );
    return res.data ?? <String, dynamic>{};
  }

  Future<Map<String, dynamic>> applyReferralCode(String code) async {
    final res = await _c.post<Map<String, dynamic>>(
      '/referral/apply',
      (d) => Map<String, dynamic>.from(d as Map),
      body: {'code': code},
    );
    return res.data ?? <String, dynamic>{};
  }

  // ── Progress ───────────────────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> getProgressStages() async {
    final res = await _c.get<List<Map<String, dynamic>>>(
      '/progress/stages',
      _asMapList,
    );
    return res.data ?? const [];
  }

  Future<Map<String, dynamic>> getMyProgress() async {
    final res = await _c.get<Map<String, dynamic>>(
      '/progress/me',
      (d) => Map<String, dynamic>.from(d as Map),
    );
    return res.data ?? <String, dynamic>{};
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  static List<Map<String, dynamic>> _asMapList(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map>()
          .map((m) => Map<String, dynamic>.from(m))
          .toList(growable: false);
    }
    return const [];
  }
}
