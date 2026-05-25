import 'package:mquiz/core/network/nestjs_api.dart';
import 'package:mquiz/features/profile/models/profile_extras_model.dart';
import 'package:mquiz/features/profile/models/user_profile_model.dart';
import 'package:mquiz/features/profile/models/user_stats_model.dart';

class ProfileRepository {
  ProfileRepository({NestJsApi? api}) : _api = api ?? NestJsApi.instance;
  final NestJsApi _api;

  Future<UserProfile> fetchMe() async {
    final raw = await _api.getMe();
    return UserProfile.fromJson(raw);
  }

  Future<UserStats> fetchStats() async {
    final raw = await _api.getMyStats();
    return UserStats.fromJson(raw);
  }

  Future<List<Badge>> fetchBadges() async {
    final raw = await _api.getMyBadges();
    return raw.map(Badge.fromJson).toList(growable: false);
  }

  Future<({List<CoinHistoryEntry> items, int totalPages, int page})>
      fetchCoinHistory({int page = 1, int limit = 20}) async {
    final raw = await _api.getMyCoinHistory(page: page, limit: limit);
    final rawItems = raw['items'];
    final items = rawItems is List
        ? rawItems
            .whereType<Map>()
            .map((m) => CoinHistoryEntry.fromJson(Map<String, dynamic>.from(m)))
            .toList(growable: false)
        : const <CoinHistoryEntry>[];
    final pagination = raw['pagination'];
    final totalPages = pagination is Map
        ? (pagination['totalPages'] as num?)?.toInt() ?? 1
        : 1;
    return (items: items, totalPages: totalPages, page: page);
  }

  Future<ReferralInfo> fetchReferral() async {
    final raw = await _api.getReferralCode();
    return ReferralInfo.fromJson(raw);
  }

  Future<void> applyReferral(String code) => _api.applyReferralCode(code);

  Future<UserProfile> updateProfile(Map<String, dynamic> patch) async {
    final raw = await _api.updateMe(patch);
    return UserProfile.fromJson(raw);
  }
}
