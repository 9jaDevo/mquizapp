/// Single comprehensive client for all Phase 3 NestJS endpoints.
///
/// Each method maps to one route in the apps/api/ controllers. Cubits and
/// data sources can call these methods directly when their feature is gated
/// to NestJS via [ApiMigration].
///
/// All methods return the unwrapped `data` field from the response envelope.
/// They throw [ApiClientException] on any error (HTTP, network, envelope).
library;

import 'package:flutterquiz/core/network/api_client.dart';
import 'package:flutterquiz/core/network/api_response.dart';

class NestJsApi {
  NestJsApi._();
  static final NestJsApi instance = NestJsApi._();

  ApiClient get _c => ApiClient.instance;

  // ── Auth ───────────────────────────────────────────────────────────────────
  // POST /v2/auth/login — verifies Firebase ID token (already in Authorization header)
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

  // POST /v2/auth/guest
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
    final res = await _c.get<List<Map<String, dynamic>>>(
      '/users/me/badges',
      _asMapList,
    );
    return res.data ?? const [];
  }

  Future<List<Map<String, dynamic>>> getMyCoinHistory({int page = 1, int limit = 20}) async {
    final res = await _c.get<List<Map<String, dynamic>>>(
      '/users/me/coin-history',
      _asMapList,
      queryParameters: {'page': page, 'limit': limit},
    );
    return res.data ?? const [];
  }

  Future<void> updateFcmToken(String token) async {
    await _c.put<dynamic>(
      '/users/me/fcm-token',
      (d) => d,
      body: {'fcm_token': token},
    );
  }

  // ── Categories ─────────────────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> getCategories({String? languageId, String? type}) async {
    final res = await _c.get<List<Map<String, dynamic>>>(
      '/categories',
      _asMapList,
      queryParameters: {
        if (languageId != null) 'language_id': languageId,
        if (type != null) 'type': type,
      },
    );
    return res.data ?? const [];
  }

  Future<List<Map<String, dynamic>>> getSubcategories(String categoryId) async {
    final res = await _c.get<List<Map<String, dynamic>>>(
      '/categories/$categoryId/subcategories',
      _asMapList,
    );
    return res.data ?? const [];
  }

  // ── Quiz ───────────────────────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> getQuestions({
    String? categoryId,
    String? subcategoryId,
    String? level,
    int? limit,
    String? languageId,
  }) async {
    final res = await _c.get<List<Map<String, dynamic>>>(
      '/quiz/questions',
      _asMapList,
      queryParameters: {
        if (categoryId != null) 'category_id': categoryId,
        if (subcategoryId != null) 'subcategory_id': subcategoryId,
        if (level != null) 'level': level,
        if (limit != null) 'limit': limit,
        if (languageId != null) 'language_id': languageId,
      },
    );
    return res.data ?? const [];
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

  Future<Map<String, dynamic>> submitDailyChallenge(Map<String, dynamic> payload) async {
    final res = await _c.post<Map<String, dynamic>>(
      '/quiz/daily-challenge/submit',
      (d) => Map<String, dynamic>.from(d as Map),
      body: payload,
    );
    return res.data ?? <String, dynamic>{};
  }

  // ── Bookmarks ──────────────────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> listBookmarks({int page = 1, int limit = 50}) async {
    final res = await _c.get<List<Map<String, dynamic>>>(
      '/bookmarks',
      _asMapList,
      queryParameters: {'page': page, 'limit': limit},
    );
    return res.data ?? const [];
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
  Future<List<Map<String, dynamic>>> getLeaderboard(String period, {int page = 1, int limit = 50}) async {
    // period: daily | weekly | monthly
    final res = await _c.get<List<Map<String, dynamic>>>(
      '/leaderboard/$period',
      _asMapList,
      queryParameters: {'page': page, 'limit': limit},
    );
    return res.data ?? const [];
  }

  Future<Map<String, dynamic>> getMyLeaderboardRank() async {
    final res = await _c.get<Map<String, dynamic>>(
      '/leaderboard/me',
      (d) => Map<String, dynamic>.from(d as Map),
    );
    return res.data ?? <String, dynamic>{};
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
    final res = await _c.get<List<Map<String, dynamic>>>('/contests', _asMapList);
    return res.data ?? const [];
  }

  Future<List<Map<String, dynamic>>> getContestQuestions(int id) async {
    final res = await _c.get<List<Map<String, dynamic>>>(
      '/contests/$id/questions',
      _asMapList,
    );
    return res.data ?? const [];
  }

  Future<Map<String, dynamic>> submitContest(int id, Map<String, dynamic> payload) async {
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
    final res = await _c.get<List<Map<String, dynamic>>>('/leagues', _asMapList);
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

  Future<Map<String, dynamic>> submitLeagueAnswers(int id, Map<String, dynamic> payload) async {
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
    final res = await _c.get<List<Map<String, dynamic>>>('/coins/store', _asMapList);
    return res.data ?? const [];
  }

  Future<List<Map<String, dynamic>>> getCoinHistory({int page = 1, int limit = 20}) async {
    final res = await _c.get<List<Map<String, dynamic>>>(
      '/coins/history',
      _asMapList,
      queryParameters: {'page': page, 'limit': limit},
    );
    return res.data ?? const [];
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
    final res = await _c.get<List<Map<String, dynamic>>>('/boosters/types', _asMapList);
    return res.data ?? const [];
  }

  Future<List<Map<String, dynamic>>> getMyBoosters() async {
    final res = await _c.get<List<Map<String, dynamic>>>('/boosters/me', _asMapList);
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
  Future<Map<String, dynamic>> initializePayment(Map<String, dynamic> payload) async {
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

  Future<List<Map<String, dynamic>>> getPaymentHistory() async {
    final res = await _c.get<List<Map<String, dynamic>>>('/payments/history', _asMapList);
    return res.data ?? const [];
  }

  // ── Ads ────────────────────────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> getActiveBanners() async {
    final res = await _c.get<List<Map<String, dynamic>>>('/ads/banners/active', _asMapList);
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
  Future<List<Map<String, dynamic>>> getNotifications({int page = 1, int limit = 20}) async {
    final res = await _c.get<List<Map<String, dynamic>>>(
      '/notifications',
      _asMapList,
      queryParameters: {'page': page, 'limit': limit},
    );
    return res.data ?? const [];
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

  // ── Helpers ────────────────────────────────────────────────────────────────
  static List<Map<String, dynamic>> _asMapList(dynamic data) {
    if (data is List) {
      return data.whereType<Map>().map((m) => Map<String, dynamic>.from(m)).toList();
    }
    return const [];
  }
}

// Suppress unused import warning when ApiResponse isn't referenced directly here.
// ignore: unused_element
ApiResponse<dynamic>? _typeWitness;
