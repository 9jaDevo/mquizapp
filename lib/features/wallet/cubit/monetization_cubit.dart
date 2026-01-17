import 'package:bloc/bloc.dart';
import 'package:flutterquiz/features/wallet/models/monetization_models.dart';
import 'package:flutterquiz/features/wallet/repos/monetization_remote_data_source.dart';
import 'package:equatable/equatable.dart';

part 'monetization_state.dart';

class MonetizationCubit extends Cubit<MonetizationState> {
  MonetizationCubit(this._monetizationRemoteDataSource) : super(const MonetizationState());

  final MonetizationRemoteDataSource _monetizationRemoteDataSource;

  // Daily Streak
  Future<void> checkDailyStreak() async {
    try {
      final data = await _monetizationRemoteDataSource.checkDailyStreak();
      final streak = DailyStreak.fromJson(data);
      emit(state.copyWith(streak: streak, isLoadingStreak: false));
    } catch (e) {
      emit(state.copyWith(isLoadingStreak: false, error: e.toString()));
    }
  }

  // Device Registration
  Future<void> registerDevice({
    required String deviceId,
    required String deviceType,
    String? deviceName,
  }) async {
    emit(state.copyWith(isLoadingDevice: true, clearError: true));
    try {
      final data = await _monetizationRemoteDataSource.registerDevice(
        deviceId: deviceId,
        deviceType: deviceType,
        deviceName: deviceName,
      );
      final registration = DeviceRegistration.fromJson(data);
      emit(state.copyWith(deviceRegistration: registration, isLoadingDevice: false));
    } catch (e) {
      emit(state.copyWith(isLoadingDevice: false, error: e.toString()));
    }
  }

  // Fraud Evaluation
  Future<void> evaluateUserRisk({
    required String actionType,
    Map<String, dynamic>? metadata,
  }) async {
    emit(state.copyWith(isLoadingFraud: true, clearError: true));
    try {
      final data = await _monetizationRemoteDataSource.evaluateUserRisk(
        actionType: actionType,
        metadata: metadata,
      );
      final fraud = FraudDetection.fromJson(data);
      emit(state.copyWith(fraud: fraud, isLoadingFraud: false));
    } catch (e) {
      emit(state.copyWith(isLoadingFraud: false, error: e.toString()));
    }
  }

  // Payout Eligibility Check
  Future<void> checkPayoutEligibility() async {
    emit(state.copyWith(isLoadingPayout: true, clearError: true));
    try {
      final data = await _monetizationRemoteDataSource.checkPayoutEligibility();
      final eligibility = PayoutEligibility.fromJson(data);
      emit(state.copyWith(payoutEligibility: eligibility, isLoadingPayout: false));
    } catch (e) {
      emit(state.copyWith(isLoadingPayout: false, error: e.toString()));
    }
  }

  // Get Sponsor Banner
  Future<void> getSponsorBanner() async {
    try {
      final data = await _monetizationRemoteDataSource.getSponsorBanner();
      if (data != null) {
        final banner = SponsorBanner.fromJson(data);
        emit(state.copyWith(banner: banner, banners: [banner], isLoadingBanner: false));
      } else {
        emit(state.copyWith(isLoadingBanner: false));
      }
    } catch (e) {
      emit(state.copyWith(isLoadingBanner: false, error: e.toString()));
    }
  }

  // Get multiple Sponsor Banners
  Future<void> getSponsorBanners() async {
    try {
      final list = await _monetizationRemoteDataSource.getSponsorBanners();
      final banners = list.map((e) => SponsorBanner.fromJson(e)).toList();
      if (banners.isNotEmpty) {
        emit(state.copyWith(banners: banners, banner: banners.first, isLoadingBanner: false));
      } else {
        emit(state.copyWith(isLoadingBanner: false));
      }
    } catch (e) {
      emit(state.copyWith(isLoadingBanner: false, error: e.toString()));
    }
  }

  // Record Banner Click
  Future<void> recordBannerClick({required String bannerId}) async {
    try {
      await _monetizationRemoteDataSource.recordSponsorBannerClick(bannerId: bannerId);
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  // Offer Boost Earnings
  Future<void> offerBoostEarnings({required String coinsEarned}) async {
    emit(state.copyWith(isLoadingBoost: true, clearError: true));
    try {
      final data = await _monetizationRemoteDataSource.offerBoostEarnings(coinsEarned: coinsEarned);
      final boost = BoostEarnings.fromJson(data);
      emit(state.copyWith(boostEarnings: boost, isLoadingBoost: false));
    } catch (e) {
      emit(state.copyWith(isLoadingBoost: false, error: e.toString()));
    }
  }

  // Apply Boost Earnings
  Future<void> applyBoostEarnings({required String coinsEarned}) async {
    emit(state.copyWith(isLoadingBoost: true, clearError: true));
    try {
      await _monetizationRemoteDataSource.applyBoostEarnings(boostedCoins: coinsEarned);
      emit(state.copyWith(isLoadingBoost: false));
      // Optionally handle success data
    } catch (e) {
      emit(state.copyWith(isLoadingBoost: false, error: e.toString()));
    }
  }

  // Get Watch Unlock Config
  Future<void> getWatchUnlockConfig() async {
    emit(state.copyWith(isLoadingWatchUnlock: true, clearError: true));
    try {
      final data = await _monetizationRemoteDataSource.getWatchUnlockConfig();
      final config = WatchUnlockConfig.fromJson(data);
      emit(state.copyWith(watchUnlockConfig: config, isLoadingWatchUnlock: false));
    } catch (e) {
      emit(state.copyWith(isLoadingWatchUnlock: false, error: e.toString()));
    }
  }
}
