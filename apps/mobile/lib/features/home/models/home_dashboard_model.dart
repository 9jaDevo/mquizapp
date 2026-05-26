import 'package:equatable/equatable.dart';
import 'package:mquiz/features/profile/models/user_profile_model.dart';
import 'package:mquiz/features/quiz/models/category_model.dart';

class HomeDashboard extends Equatable {
  const HomeDashboard({
    required this.user,
    required this.categories,
    this.dailyChallenge,
    this.activeContest,
    this.sponsorBanners = const [],
  });

  final UserProfile user;
  final List<Category> categories;
  final Map<String, dynamic>? dailyChallenge;
  final Map<String, dynamic>? activeContest;
  final List<Map<String, dynamic>> sponsorBanners;

  bool get hasDailyChallenge => dailyChallenge != null;
  bool get hasActiveContest => activeContest != null;
  bool get hasSponsorBanner => sponsorBanners.isNotEmpty;

  @override
  List<Object?> get props =>
      [user, categories, dailyChallenge, activeContest, sponsorBanners];
}
