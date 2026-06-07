import 'package:flutterquiz/core/constants/api_exception.dart';
import 'package:flutterquiz/features/user_path/models/user_path.dart';
import 'package:flutterquiz/features/user_path/repositories/user_path_remote_data_source.dart';

class UserPathRepository {
  factory UserPathRepository() {
    _userPathRepository._userPathRemoteDataSource ??=
        UserPathRemoteDataSource();
    return _userPathRepository;
  }

  UserPathRepository._internal();
  static final UserPathRepository _userPathRepository =
      UserPathRepository._internal();

  UserPathRemoteDataSource? _userPathRemoteDataSource;

  /// Set user's learning path
  Future<UserPath> setUserPath({
    required String userId,
    required UserPathType selectedPath,
    List<String>? topicsPreference,
    int? dailyGoalMinutes,
    bool? demoQuizCompleted,
  }) async {
    try {
      final topicsJson = topicsPreference != null && topicsPreference.isNotEmpty
          ? '["${topicsPreference.join('","')}"]'
          : '[]';

      final result = await _userPathRemoteDataSource!.setUserPath(
        selectedPath: selectedPath.value,
        topicsPreference: topicsJson,
        dailyGoalMinutes: dailyGoalMinutes,
        demoQuizCompleted: demoQuizCompleted,
      );

      return UserPath(
        userId: userId,
        selectedPath: UserPathType.fromString(
          result['selected_path']?.toString() ?? selectedPath.value,
        ),
        dailyGoalMinutes: int.tryParse(
              result['daily_goal_minutes']?.toString() ?? '10',
            ) ??
            10,
        topicsPreference: topicsPreference ?? [],
        onboardingCompleted: true,
        demoQuizCompleted: demoQuizCompleted ?? false,
      );
    } on ApiException {
      rethrow;
    } on Exception catch (e) {
      throw ApiException(e.toString());
    }
  }

  /// Get user's current learning path
  Future<UserPath?> getUserPath(String userId) async {
    try {
      final result = await _userPathRemoteDataSource!.getUserPath();

      if (result == null) {
        return null;
      }

      return UserPath.fromJson({
        ...result,
        'user_id': userId,
      });
    } on ApiException {
      rethrow;
    } on Exception catch (e) {
      throw ApiException(e.toString());
    }
  }

  /// Switch user's learning path
  Future<UserPath> switchUserPath({
    required String userId,
    required UserPathType newPath,
  }) async {
    try {
      final result = await _userPathRemoteDataSource!.switchUserPath(
        newPath: newPath.value,
      );

      // Get the updated user path
      final updatedPath = await getUserPath(userId);
      
      return updatedPath ??
          UserPath(
            userId: userId,
            selectedPath: newPath,
          );
    } on ApiException {
      rethrow;
    } on Exception catch (e) {
      throw ApiException(e.toString());
    }
  }

  /// Get personalized content based on user's path
  Future<Map<String, dynamic>> getPersonalizedContent({
    int? limit,
  }) async {
    try {
      return await _userPathRemoteDataSource!.getPersonalizedContent(
        limit: limit,
      );
    } on ApiException {
      rethrow;
    } on Exception catch (e) {
      throw ApiException(e.toString());
    }
  }

  /// Get categories filtered by audience
  Future<List<dynamic>> getCategoriesByAudience({
    required String audience,
    String? languageId,
  }) async {
    try {
      return await _userPathRemoteDataSource!.getCategoriesByAudience(
        audience: audience,
        languageId: languageId,
      );
    } on ApiException {
      rethrow;
    } on Exception catch (e) {
      throw ApiException(e.toString());
    }
  }
}
