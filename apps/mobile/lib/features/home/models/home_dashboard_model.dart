import 'package:equatable/equatable.dart';
import 'package:mquiz/features/profile/models/user_profile_model.dart';
import 'package:mquiz/features/quiz/models/category_model.dart';

class HomeDashboard extends Equatable {
  const HomeDashboard({
    required this.user,
    required this.categories,
    this.dailyChallenge,
  });

  final UserProfile user;
  final List<Category> categories;
  final Map<String, dynamic>? dailyChallenge;

  bool get hasDailyChallenge => dailyChallenge != null;

  @override
  List<Object?> get props => [user, categories, dailyChallenge];
}
