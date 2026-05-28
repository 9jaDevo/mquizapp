import 'package:mquiz/core/network/api_client_exception.dart';
import 'package:mquiz/features/home/models/home_dashboard_model.dart';
import 'package:mquiz/features/profile/data/profile_repository.dart';
import 'package:mquiz/features/quiz/data/quiz_repository.dart';
import 'package:mquiz/features/quiz/models/category_model.dart';
import 'package:mquiz/core/network/nestjs_api.dart';

class HomeRepository {
  HomeRepository({
    required ProfileRepository profile,
    required QuizRepository quiz,
    NestJsApi? api,
  })  : _profile = profile,
        _quiz = quiz,
        _api = api ?? NestJsApi.instance;

  final ProfileRepository _profile;
  final QuizRepository _quiz;
  final NestJsApi _api;

  /// Load dashboard data in parallel. Categories, daily challenge, active
  /// contest and sponsor banners are best-effort — failures show empty state,
  /// not a full-screen error.
  Future<HomeDashboard> loadDashboard() async {
    final results = await Future.wait([
      _profile.fetchMe(),
      _safeCategories(),
      _safeDailyChallenge(),
      _safeActiveContest(),
      _safeSponsorBanners(),
    ]);
    return HomeDashboard(
      user: results[0] as dynamic,
      categories: results[1] as dynamic,
      dailyChallenge: results[2] as Map<String, dynamic>?,
      activeContest: results[3] as Map<String, dynamic>?,
      sponsorBanners: results[4] as List<Map<String, dynamic>>,
    );
  }

  Future<List<Category>> _safeCategories() async {
    try {
      return await _quiz.fetchCategories();
    } catch (_) {
      return const [];
    }
  }

  Future<Map<String, dynamic>?> _safeDailyChallenge() async {
    try {
      final data = await _api.getDailyChallenge();
      if (data.isEmpty) return null;
      return data;
    } on ApiClientException catch (e) {
      if (e.isNotFound) return null;
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> _safeActiveContest() async {
    try {
      final contests = await _api.listContests();
      if (contests.isEmpty) return null;
      // Return the first active contest
      return contests.first;
    } catch (_) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> _safeSponsorBanners() async {
    try {
      return await _api.getActiveBanners();
    } catch (_) {
      return const [];
    }
  }
}
