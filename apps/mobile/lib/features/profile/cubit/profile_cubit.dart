import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mquiz/core/utils/error_handler.dart';
import 'package:mquiz/features/profile/data/profile_repository.dart';
import 'package:mquiz/features/profile/models/profile_extras_model.dart';
import 'package:mquiz/features/profile/models/user_profile_model.dart';
import 'package:mquiz/features/profile/models/user_stats_model.dart';

sealed class ProfileState extends Equatable {
  const ProfileState();
  @override
  List<Object?> get props => const [];
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  const ProfileLoaded({
    required this.profile,
    required this.stats,
    required this.badges,
    this.referral,
    this.saving = false,
  });

  final UserProfile profile;
  final UserStats stats;
  final List<Badge> badges;
  final ReferralInfo? referral;
  final bool saving;

  ProfileLoaded copyWith({
    UserProfile? profile,
    UserStats? stats,
    List<Badge>? badges,
    ReferralInfo? referral,
    bool? saving,
  }) =>
      ProfileLoaded(
        profile: profile ?? this.profile,
        stats: stats ?? this.stats,
        badges: badges ?? this.badges,
        referral: referral ?? this.referral,
        saving: saving ?? this.saving,
      );

  @override
  List<Object?> get props => [profile, stats, badges, referral, saving];
}

class ProfileError extends ProfileState {
  const ProfileError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this._repo) : super(const ProfileInitial());
  final ProfileRepository _repo;

  Future<void> load() async {
    emit(const ProfileLoading());
    try {
      final profileFuture = _repo.fetchMe();
      final statsFuture = _repo.fetchStats();
      final badgesFuture = _repo.fetchBadges();
      final referralFuture = _safeReferral();

      final profile = await profileFuture;
      final stats = await statsFuture;
      final badges = await badgesFuture;
      final referral = await referralFuture;
      emit(ProfileLoaded(
        profile: profile,
        stats: stats,
        badges: badges,
        referral: referral,
      ));
    } catch (e) {
      emit(ProfileError(describeError(e)));
    }
  }

  Future<ReferralInfo?> _safeReferral() async {
    try {
      return await _repo.fetchReferral();
    } catch (_) {
      return null;
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> patch) async {
    final s = state;
    if (s is! ProfileLoaded) return false;
    emit(s.copyWith(saving: true));
    try {
      final updated = await _repo.updateProfile(patch);
      emit(s.copyWith(profile: updated, saving: false));
      return true;
    } catch (e) {
      emit(s.copyWith(saving: false));
      emit(ProfileError(describeError(e)));
      // restore previous loaded state so UI can continue
      emit(s);
      return false;
    }
  }

  Future<bool> applyReferral(String code) async {
    try {
      await _repo.applyReferral(code);
      await load();
      return true;
    } catch (_) {
      return false;
    }
  }
}
