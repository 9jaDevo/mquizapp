enum UserPathType {
  student,
  professional,
  competition;

  String get value {
    switch (this) {
      case UserPathType.student:
        return 'student';
      case UserPathType.professional:
        return 'professional';
      case UserPathType.competition:
        return 'competition';
    }
  }

  static UserPathType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'professional':
        return UserPathType.professional;
      case 'competition':
        return UserPathType.competition;
      case 'student':
      default:
        return UserPathType.student;
    }
  }

  String get displayName {
    switch (this) {
      case UserPathType.student:
        return 'Student Learning';
      case UserPathType.professional:
        return 'Professional Growth';
      case UserPathType.competition:
        return 'Competition Arena';
    }
  }

  String get icon {
    switch (this) {
      case UserPathType.student:
        return '🎓';
      case UserPathType.professional:
        return '💼';
      case UserPathType.competition:
        return '🏆';
    }
  }

  String get description {
    switch (this) {
      case UserPathType.student:
        return 'Master academic subjects and prepare for exams';
      case UserPathType.professional:
        return 'Develop workplace skills and advance your career';
      case UserPathType.competition:
        return 'Compete globally and climb the leaderboard';
    }
  }

  List<String> get benefits {
    switch (this) {
      case UserPathType.student:
        return [
          'Exam-focused quizzes',
          'Academic categories',
          'Progress tracking',
        ];
      case UserPathType.professional:
        return [
          'Real-world scenarios',
          'Skill assessments',
          'Career development',
        ];
      case UserPathType.competition:
        return [
          'Global leaderboards',
          'Live battles',
          'Tournaments & rewards',
        ];
    }
  }
}

final class UserPath {
  const UserPath({
    required this.userId,
    required this.selectedPath,
    this.canSwitch = true,
    this.selectedAt,
    this.topicsPreference = const [],
    this.dailyGoalMinutes = 10,
    this.onboardingCompleted = false,
    this.demoQuizCompleted = false,
  });

  factory UserPath.fromJson(Map<String, dynamic> json) {
    List<String> topics = [];
    if (json['topics_preference'] != null) {
      try {
        if (json['topics_preference'] is String) {
          // Parse JSON string
          final decoded = json['topics_preference'] as String;
          if (decoded.isNotEmpty && decoded != '[]') {
            topics = (decoded as String)
                .replaceAll('[', '')
                .replaceAll(']', '')
                .replaceAll('"', '')
                .split(',')
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList();
          }
        } else if (json['topics_preference'] is List) {
          topics = (json['topics_preference'] as List)
              .map((e) => e.toString())
              .toList();
        }
      } catch (e) {
        topics = [];
      }
    }

    return UserPath(
      userId: json['user_id']?.toString() ?? '',
      selectedPath: UserPathType.fromString(
        json['selected_path']?.toString() ?? 'student',
      ),
      canSwitch: (json['can_switch']?.toString() ?? '1') == '1',
      selectedAt: json['selected_at'] != null
          ? DateTime.tryParse(json['selected_at'].toString())
          : null,
      topicsPreference: topics,
      dailyGoalMinutes: int.tryParse(
            json['daily_goal_minutes']?.toString() ?? '10',
          ) ??
          10,
      onboardingCompleted:
          (json['onboarding_completed']?.toString() ?? '0') == '1',
      demoQuizCompleted: (json['demo_quiz_completed']?.toString() ?? '0') == '1',
    );
  }

  final String userId;
  final UserPathType selectedPath;
  final bool canSwitch;
  final DateTime? selectedAt;
  final List<String> topicsPreference;
  final int dailyGoalMinutes;
  final bool onboardingCompleted;
  final bool demoQuizCompleted;

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'selected_path': selectedPath.value,
      'can_switch': canSwitch ? '1' : '0',
      'selected_at': selectedAt?.toIso8601String(),
      'topics_preference': topicsPreference,
      'daily_goal_minutes': dailyGoalMinutes.toString(),
      'onboarding_completed': onboardingCompleted ? '1' : '0',
      'demo_quiz_completed': demoQuizCompleted ? '1' : '0',
    };
  }

  UserPath copyWith({
    String? userId,
    UserPathType? selectedPath,
    bool? canSwitch,
    DateTime? selectedAt,
    List<String>? topicsPreference,
    int? dailyGoalMinutes,
    bool? onboardingCompleted,
    bool? demoQuizCompleted,
  }) {
    return UserPath(
      userId: userId ?? this.userId,
      selectedPath: selectedPath ?? this.selectedPath,
      canSwitch: canSwitch ?? this.canSwitch,
      selectedAt: selectedAt ?? this.selectedAt,
      topicsPreference: topicsPreference ?? this.topicsPreference,
      dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      demoQuizCompleted: demoQuizCompleted ?? this.demoQuizCompleted,
    );
  }
}
