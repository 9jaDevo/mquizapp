part of 'monetization_cubit.dart';

class MonetizationState extends Equatable {
  final DailyStreak? streak;
  final SponsorBanner? banner;
  final DeviceRegistration? deviceRegistration;
  final FraudDetection? fraud;
  final PayoutEligibility? payoutEligibility;
  final BoostEarnings? boostEarnings;
  final WatchUnlockConfig? watchUnlockConfig;
  final bool isLoadingStreak;
  final bool isLoadingBanner;
  final bool isLoadingDevice;
  final bool isLoadingFraud;
  final bool isLoadingPayout;
  final bool isLoadingBoost;
  final bool isLoadingWatchUnlock;
  final String? error;

  const MonetizationState({
    this.streak,
    this.banner,
    this.deviceRegistration,
    this.fraud,
    this.payoutEligibility,
    this.boostEarnings,
    this.watchUnlockConfig,
    this.isLoadingStreak = false,
    this.isLoadingBanner = false,
    this.isLoadingDevice = false,
    this.isLoadingFraud = false,
    this.isLoadingPayout = false,
    this.isLoadingBoost = false,
    this.isLoadingWatchUnlock = false,
    this.error,
  });

  MonetizationState copyWith({
    DailyStreak? streak,
    SponsorBanner? banner,
    DeviceRegistration? deviceRegistration,
    FraudDetection? fraud,
    PayoutEligibility? payoutEligibility,
    BoostEarnings? boostEarnings,
    WatchUnlockConfig? watchUnlockConfig,
    bool? isLoadingStreak,
    bool? isLoadingBanner,
    bool? isLoadingDevice,
    bool? isLoadingFraud,
    bool? isLoadingPayout,
    bool? isLoadingBoost,
    bool? isLoadingWatchUnlock,
    String? error,
    bool clearError = false,
  }) {
    return MonetizationState(
      streak: streak ?? this.streak,
      banner: banner ?? this.banner,
      deviceRegistration: deviceRegistration ?? this.deviceRegistration,
      fraud: fraud ?? this.fraud,
      payoutEligibility: payoutEligibility ?? this.payoutEligibility,
      boostEarnings: boostEarnings ?? this.boostEarnings,
      watchUnlockConfig: watchUnlockConfig ?? this.watchUnlockConfig,
      isLoadingStreak: isLoadingStreak ?? this.isLoadingStreak,
      isLoadingBanner: isLoadingBanner ?? this.isLoadingBanner,
      isLoadingDevice: isLoadingDevice ?? this.isLoadingDevice,
      isLoadingFraud: isLoadingFraud ?? this.isLoadingFraud,
      isLoadingPayout: isLoadingPayout ?? this.isLoadingPayout,
      isLoadingBoost: isLoadingBoost ?? this.isLoadingBoost,
      isLoadingWatchUnlock: isLoadingWatchUnlock ?? this.isLoadingWatchUnlock,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [
    streak,
    banner,
    deviceRegistration,
    fraud,
    payoutEligibility,
    boostEarnings,
    watchUnlockConfig,
    isLoadingStreak,
    isLoadingBanner,
    isLoadingDevice,
    isLoadingFraud,
    isLoadingPayout,
    isLoadingBoost,
    isLoadingWatchUnlock,
    error,
  ];
}
