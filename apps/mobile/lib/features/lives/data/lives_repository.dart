import 'package:mquiz/core/network/nestjs_api.dart';
import 'package:mquiz/features/lives/models/lives_models.dart';

class LivesRepository {
  LivesRepository({NestJsApi? api}) : _api = api ?? NestJsApi.instance;
  final NestJsApi _api;

  Future<LivesState> fetchLives() async {
    final data = await _api.getLives();
    return LivesState.fromJson(data);
  }

  Future<LivesState> restoreWithCoins() async {
    final data = await _api.restoreLifeWithCoins();
    return LivesState.fromJson(data);
  }

  Future<LivesState> restoreWithAd() async {
    final data = await _api.restoreLifeWithAd();
    return LivesState.fromJson(data);
  }

  Future<LivesState> consumeLife() async {
    final data = await _api.consumeLife();
    return LivesState.fromJson(data);
  }

  Future<StreakStatus> fetchStreak() async {
    final data = await _api.getStreak();
    return StreakStatus.fromJson(data);
  }

  Future<StreakStatus> claimDailyStreak() async {
    final data = await _api.claimDailyStreak();
    return StreakStatus.fromJson(data);
  }

  Future<List<Booster>> fetchBoosterTypes() async {
    final list = await _api.getBoosterTypes();
    return list.map(Booster.fromJson).toList(growable: false);
  }

  Future<List<Booster>> fetchMyBoosters() async {
    final list = await _api.getMyBoosters();
    return list.map(Booster.fromJson).toList(growable: false);
  }

  Future<void> purchaseBooster(int boosterTypeId) async {
    await _api.purchaseBooster(boosterTypeId);
  }
}
