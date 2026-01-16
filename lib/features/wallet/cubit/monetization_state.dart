part of 'monetization_cubit.dart';

abstract class MonetizationState extends Equatable {
  const MonetizationState();

  @override
  List<Object> get props => [];
}

class MonetizationInitial extends MonetizationState {
  const MonetizationInitial();
}

// Daily Streak States
class CheckingDailyStreakInProgress extends MonetizationState {
  const CheckingDailyStreakInProgress();
}

class DailyStreakChecked extends MonetizationState {
  final DailyStreak streak;

  const DailyStreakChecked({required this.streak});

  @override
  List<Object> get props => [streak];
}

// Device Registration States
class RegisteringDeviceInProgress extends MonetizationState {
  const RegisteringDeviceInProgress();
}

class DeviceRegistered extends MonetizationState {
  final DeviceRegistration registration;

  const DeviceRegistered({required this.registration});

  @override
  List<Object> get props => [registration];
}

// Fraud Evaluation States
class EvaluatingUserRiskInProgress extends MonetizationState {
  const EvaluatingUserRiskInProgress();
}

class UserRiskEvaluated extends MonetizationState {
  final FraudDetection fraud;

  const UserRiskEvaluated({required this.fraud});

  @override
  List<Object> get props => [fraud];
}

// Payout Eligibility States
class CheckingPayoutEligibilityInProgress extends MonetizationState {
  const CheckingPayoutEligibilityInProgress();
}

class PayoutEligibilityChecked extends MonetizationState {
  final PayoutEligibility eligibility;

  const PayoutEligibilityChecked({required this.eligibility});

  @override
  List<Object> get props => [eligibility];
}

// Sponsor Banner States
class FetchingSponsorBannerInProgress extends MonetizationState {
  const FetchingSponsorBannerInProgress();
}

class SponsorBannerFetched extends MonetizationState {
  final SponsorBanner banner;

  const SponsorBannerFetched({required this.banner});

  @override
  List<Object> get props => [banner];
}

class SponsorBannerNotAvailable extends MonetizationState {
  const SponsorBannerNotAvailable();
}

// Boost Earnings States
class OfferingBoostEarningsInProgress extends MonetizationState {
  const OfferingBoostEarningsInProgress();
}

class BoostEarningsOffered extends MonetizationState {
  final BoostEarnings boost;

  const BoostEarningsOffered({required this.boost});

  @override
  List<Object> get props => [boost];
}

class ApplyingBoostEarningsInProgress extends MonetizationState {
  const ApplyingBoostEarningsInProgress();
}

class BoostEarningsApplied extends MonetizationState {
  final Map<String, dynamic> data;

  const BoostEarningsApplied({required this.data});

  @override
  List<Object> get props => [data];
}

// Watch Unlock Config States
class FetchingWatchUnlockConfigInProgress extends MonetizationState {
  const FetchingWatchUnlockConfigInProgress();
}

class WatchUnlockConfigFetched extends MonetizationState {
  final WatchUnlockConfig config;

  const WatchUnlockConfigFetched({required this.config});

  @override
  List<Object> get props => [config];
}

// Error State
class MonetizationError extends MonetizationState {
  final String error;

  const MonetizationError({required this.error});

  @override
  List<Object> get props => [error];
}
