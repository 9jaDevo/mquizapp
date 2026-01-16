import 'package:bloc/bloc.dart';
import 'package:flutterquiz/features/wallet/models/monetization_models.dart';
import 'package:flutterquiz/features/wallet/repos/monetization_remote_data_source.dart';
import 'package:equatable/equatable.dart';

part 'monetization_state.dart';

class MonetizationCubit extends Cubit<MonetizationState> {
  MonetizationCubit(this._monetizationRemoteDataSource) : super(const MonetizationInitial());

  final MonetizationRemoteDataSource _monetizationRemoteDataSource;

  // Daily Streak
  Future<void> checkDailyStreak() async {
    emit(const CheckingDailyStreakInProgress());
    try {
      final data = await _monetizationRemoteDataSource.checkDailyStreak();
      final streak = DailyStreak.fromJson(data);
      emit(DailyStreakChecked(streak: streak));
    } catch (e) {
      emit(MonetizationError(error: e.toString()));
    }
  }

  // Device Registration
  Future<void> registerDevice({
    required String deviceId,
    required String deviceType,
    String? deviceName,
  }) async {
    emit(const RegisteringDeviceInProgress());
    try {
      final data = await _monetizationRemoteDataSource.registerDevice(
        deviceId: deviceId,
        deviceType: deviceType,
        deviceName: deviceName,
      );
      final registration = DeviceRegistration.fromJson(data);
      emit(DeviceRegistered(registration: registration));
    } catch (e) {
      emit(MonetizationError(error: e.toString()));
    }
  }

  // Fraud Evaluation
  Future<void> evaluateUserRisk({
    required String actionType,
    Map<String, dynamic>? metadata,
  }) async {
    emit(const EvaluatingUserRiskInProgress());
    try {
      final data = await _monetizationRemoteDataSource.evaluateUserRisk(
        actionType: actionType,
        metadata: metadata,
      );
      final fraud = FraudDetection.fromJson(data);
      emit(UserRiskEvaluated(fraud: fraud));
    } catch (e) {
      emit(MonetizationError(error: e.toString()));
    }
  }

  // Payout Eligibility Check
  Future<void> checkPayoutEligibility() async {
    emit(const CheckingPayoutEligibilityInProgress());
    try {
      final data = await _monetizationRemoteDataSource.checkPayoutEligibility();
      final eligibility = PayoutEligibility.fromJson(data);
      emit(PayoutEligibilityChecked(eligibility: eligibility));
    } catch (e) {
      emit(MonetizationError(error: e.toString()));
    }
  }

  // Get Sponsor Banner
  Future<void> getSponsorBanner() async {
    emit(const FetchingSponsorBannerInProgress());
    try {
      final data = await _monetizationRemoteDataSource.getSponsorBanner();
      if (data != null) {
        final banner = SponsorBanner.fromJson(data);
        emit(SponsorBannerFetched(banner: banner));
      } else {
        emit(const SponsorBannerNotAvailable());
      }
    } catch (e) {
      emit(MonetizationError(error: e.toString()));
    }
  }

  // Record Banner Click
  Future<void> recordBannerClick({required String bannerId}) async {
    try {
      await _monetizationRemoteDataSource.recordSponsorBannerClick(bannerId: bannerId);
    } catch (e) {
      emit(MonetizationError(error: e.toString()));
    }
  }

  // Offer Boost Earnings
  Future<void> offerBoostEarnings({required String coinsEarned}) async {
    emit(const OfferingBoostEarningsInProgress());
    try {
      final data = await _monetizationRemoteDataSource.offerBoostEarnings(coinsEarned: coinsEarned);
      final boost = BoostEarnings.fromJson(data);
      emit(BoostEarningsOffered(boost: boost));
    } catch (e) {
      emit(MonetizationError(error: e.toString()));
    }
  }

  // Apply Boost Earnings
  Future<void> applyBoostEarnings({required String boostedCoins}) async {
    emit(const ApplyingBoostEarningsInProgress());
    try {
      final data = await _monetizationRemoteDataSource.applyBoostEarnings(boostedCoins: boostedCoins);
      emit(BoostEarningsApplied(data: data));
    } catch (e) {
      emit(MonetizationError(error: e.toString()));
    }
  }

  // Get Watch Unlock Config
  Future<void> getWatchUnlockConfig() async {
    emit(const FetchingWatchUnlockConfigInProgress());
    try {
      final data = await _monetizationRemoteDataSource.getWatchUnlockConfig();
      final config = WatchUnlockConfig.fromJson(data);
      emit(WatchUnlockConfigFetched(config: config));
    } catch (e) {
      emit(MonetizationError(error: e.toString()));
    }
  }
}
