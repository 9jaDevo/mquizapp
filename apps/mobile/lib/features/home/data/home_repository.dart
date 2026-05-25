import 'package:mquiz/core/network/api_client_exception.dart';
import 'package:mquiz/features/home/models/home_dashboard_model.dart';
import 'package:mquiz/features/profile/data/profile_repository.dart';
import 'package:mquiz/features/quiz/data/quiz_repository.dart';
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

  /// Load dashboard data in parallel. Daily challenge is best-effort —
  /// a 404 / not-available state does not fail the whole dashboard.
  Future<HomeDashboard> loadDashboard() async {
    final userFuture = _profile.fetchMe();
    final catsFuture = _quiz.fetchCategories();
    final dailyFuture = _safeDailyChallenge();
    final user = await userFuture;
    final categories = await catsFuture;
    final daily = await dailyFuture;
    return HomeDashboard(
      user: user,
      categories: categories,
      dailyChallenge: daily,
    );
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
}
