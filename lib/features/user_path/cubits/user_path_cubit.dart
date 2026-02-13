import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/user_path/models/user_path.dart';
import 'package:flutterquiz/features/user_path/repositories/user_path_repository.dart';

sealed class UserPathState {
  const UserPathState();
}

final class UserPathInitial extends UserPathState {
  const UserPathInitial();
}

final class UserPathLoading extends UserPathState {
  const UserPathLoading();
}

final class UserPathLoaded extends UserPathState {
  const UserPathLoaded(this.userPath);

  final UserPath userPath;
}

final class UserPathNotSet extends UserPathState {
  const UserPathNotSet();
}

final class UserPathError extends UserPathState {
  const UserPathError(this.errorMessage);

  final String errorMessage;
}

final class UserPathCubit extends Cubit<UserPathState> {
  UserPathCubit(this._userPathRepository) : super(const UserPathInitial());

  final UserPathRepository _userPathRepository;

  /// Fetch user's current path
  Future<void> fetchUserPath(String userId) async {
    emit(const UserPathLoading());

    try {
      final userPath = await _userPathRepository.getUserPath(userId);

      if (userPath == null) {
        emit(const UserPathNotSet());
      } else {
        emit(UserPathLoaded(userPath));
      }
    } on Exception catch (e) {
      emit(UserPathError(e.toString()));
    }
  }

  /// Set user's learning path
  Future<void> setUserPath({
    required String userId,
    required UserPathType selectedPath,
    List<String>? topicsPreference,
    int? dailyGoalMinutes,
    bool? demoQuizCompleted,
  }) async {
    emit(const UserPathLoading());

    try {
      final userPath = await _userPathRepository.setUserPath(
        userId: userId,
        selectedPath: selectedPath,
        topicsPreference: topicsPreference,
        dailyGoalMinutes: dailyGoalMinutes,
        demoQuizCompleted: demoQuizCompleted,
      );

      emit(UserPathLoaded(userPath));
    } on Exception catch (e) {
      emit(UserPathError(e.toString()));
    }
  }

  /// Switch user's learning path
  Future<void> switchUserPath({
    required String userId,
    required UserPathType newPath,
  }) async {
    emit(const UserPathLoading());

    try {
      final userPath = await _userPathRepository.switchUserPath(
        userId: userId,
        newPath: newPath,
      );

      emit(UserPathLoaded(userPath));
    } on Exception catch (e) {
      emit(UserPathError(e.toString()));
    }
  }

  /// Update demo quiz completed status
  Future<void> updateDemoQuizCompleted({
    required String userId,
  }) async {
    if (state is! UserPathLoaded) return;

    final currentPath = (state as UserPathLoaded).userPath;

    try {
      final updatedPath = await _userPathRepository.setUserPath(
        userId: userId,
        selectedPath: currentPath.selectedPath,
        topicsPreference: currentPath.topicsPreference,
        dailyGoalMinutes: currentPath.dailyGoalMinutes,
        demoQuizCompleted: true,
      );

      emit(UserPathLoaded(updatedPath));
    } on Exception catch (e) {
      emit(UserPathError(e.toString()));
    }
  }

  /// Get personalized content
  Future<Map<String, dynamic>> getPersonalizedContent({int? limit}) async {
    try {
      return await _userPathRepository.getPersonalizedContent(limit: limit);
    } on Exception catch (e) {
      throw Exception('Failed to get personalized content: $e');
    }
  }

  /// Check if onboarding is completed
  bool get isOnboardingCompleted {
    if (state is UserPathLoaded) {
      return (state as UserPathLoaded).userPath.onboardingCompleted;
    }
    return false;
  }

  /// Check if demo quiz is completed
  bool get isDemoQuizCompleted {
    if (state is UserPathLoaded) {
      return (state as UserPathLoaded).userPath.demoQuizCompleted;
    }
    return false;
  }

  /// Get current selected path
  UserPathType? get selectedPath {
    if (state is UserPathLoaded) {
      return (state as UserPathLoaded).userPath.selectedPath;
    }
    return null;
  }

  /// Check if path is set
  bool get hasPathSet => state is UserPathLoaded;

  /// Check if user needs onboarding
  bool get needsOnboarding => state is UserPathNotSet;
}
