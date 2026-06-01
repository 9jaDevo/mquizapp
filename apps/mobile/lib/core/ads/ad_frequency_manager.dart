/// AdMob policy-compliant frequency controls for every ad format.
///
/// Uses UTC-based day keys (not local timezone) to avoid midnight double-counting
/// across timezones — a common cause of policy violations.
///
/// Default limits are aggressive-but-safe per AdMob content policies:
///   Interstitial      : min gap 90 s   / max 12 per UTC day
///   Rewarded          : min gap 45 s   / max 10 per UTC day / max 3 per session
///   Rewarded Interstitial : min gap 90 s / max 5 per UTC day / max 1 per session
///   App-open          : min gap 4 h    / max 3 per UTC day  / max 1 per session
///
/// Remote settings can override limits at runtime via [configure].
///
/// Usage:
///   final mgr = AdFrequencyManager.instance;
///   if (await mgr.canShowInterstitial()) {
///     ad.show();
///     await mgr.recordInterstitialShown();
///   }
library;

import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';

/// Per-format frequency limits. All gap values are milliseconds.
class AdLimits {
  const AdLimits({
    required this.interstitialMinGapMs,
    required this.interstitialMaxPerDay,
    required this.rewardedMinGapMs,
    required this.rewardedMaxPerDay,
    required this.rewardedMaxPerSession,
    required this.rewardedInterstitialMinGapMs,
    required this.rewardedInterstitialMaxPerDay,
    required this.rewardedInterstitialMaxPerSession,
    required this.appOpenMinGapMs,
    required this.appOpenMaxPerDay,
    required this.appOpenMaxPerSession,
  });

  final int interstitialMinGapMs;
  final int interstitialMaxPerDay;
  final int rewardedMinGapMs;
  final int rewardedMaxPerDay;
  final int rewardedMaxPerSession;
  final int rewardedInterstitialMinGapMs;
  final int rewardedInterstitialMaxPerDay;
  final int rewardedInterstitialMaxPerSession;
  final int appOpenMinGapMs;
  final int appOpenMaxPerDay;
  final int appOpenMaxPerSession;

  /// Aggressive-but-compliant defaults based on earning report analysis.
  ///
  /// Rewarded eCPM is highest ($3.48 revenue vs $1.86 interstitial) — so
  /// rewarded has the most generous session cap.
  static const defaults = AdLimits(
    interstitialMinGapMs: 90000, // 90 s
    interstitialMaxPerDay: 12,
    rewardedMinGapMs: 45000, // 45 s — rewarded is user-initiated, lower gap OK
    rewardedMaxPerDay: 10,
    rewardedMaxPerSession: 3,
    rewardedInterstitialMinGapMs: 90000, // 90 s
    rewardedInterstitialMaxPerDay: 5,
    rewardedInterstitialMaxPerSession: 1, // pilot: 1 per session
    appOpenMinGapMs: 4 * 3600000, // 4 h — AdMob recommendation
    appOpenMaxPerDay: 3,
    appOpenMaxPerSession: 1,
  );

  AdLimits copyWith({
    int? interstitialMinGapMs,
    int? interstitialMaxPerDay,
    int? rewardedMinGapMs,
    int? rewardedMaxPerDay,
    int? rewardedMaxPerSession,
    int? rewardedInterstitialMinGapMs,
    int? rewardedInterstitialMaxPerDay,
    int? rewardedInterstitialMaxPerSession,
    int? appOpenMinGapMs,
    int? appOpenMaxPerDay,
    int? appOpenMaxPerSession,
  }) {
    return AdLimits(
      interstitialMinGapMs: interstitialMinGapMs ?? this.interstitialMinGapMs,
      interstitialMaxPerDay:
          interstitialMaxPerDay ?? this.interstitialMaxPerDay,
      rewardedMinGapMs: rewardedMinGapMs ?? this.rewardedMinGapMs,
      rewardedMaxPerDay: rewardedMaxPerDay ?? this.rewardedMaxPerDay,
      rewardedMaxPerSession:
          rewardedMaxPerSession ?? this.rewardedMaxPerSession,
      rewardedInterstitialMinGapMs:
          rewardedInterstitialMinGapMs ?? this.rewardedInterstitialMinGapMs,
      rewardedInterstitialMaxPerDay:
          rewardedInterstitialMaxPerDay ?? this.rewardedInterstitialMaxPerDay,
      rewardedInterstitialMaxPerSession: rewardedInterstitialMaxPerSession ??
          this.rewardedInterstitialMaxPerSession,
      appOpenMinGapMs: appOpenMinGapMs ?? this.appOpenMinGapMs,
      appOpenMaxPerDay: appOpenMaxPerDay ?? this.appOpenMaxPerDay,
      appOpenMaxPerSession: appOpenMaxPerSession ?? this.appOpenMaxPerSession,
    );
  }
}

/// Singleton frequency controller for all ad formats.
///
/// Call [startNewSession] on each app cold-start to reset session counters.
/// Call [configure] after loading remote settings to apply server-side limits.
class AdFrequencyManager {
  AdFrequencyManager._();
  static final AdFrequencyManager instance = AdFrequencyManager._();

  AdLimits _limits = AdLimits.defaults;

  // In-memory session counters — reset when [startNewSession] is called.
  int _rewardedSessionCount = 0;
  int _rewardedInterstitialSessionCount = 0;
  int _appOpenSessionCount = 0;

  static const _tag = 'AdFrequency';

  // ── SharedPreferences keys (stable — never rename without migration) ────
  static const _kInterstitialLastMs = 'adfm_interstitial_last_ms';
  static const _kInterstitialDaily = 'adfm_interstitial_daily';
  static const _kInterstitialDate = 'adfm_interstitial_date';

  static const _kRewardedLastMs = 'adfm_rewarded_last_ms';
  static const _kRewardedDaily = 'adfm_rewarded_daily';
  static const _kRewardedDate = 'adfm_rewarded_date';

  static const _kRewIntLastMs = 'adfm_rew_int_last_ms';
  static const _kRewIntDaily = 'adfm_rew_int_daily';
  static const _kRewIntDate = 'adfm_rew_int_date';

  static const _kAppOpenLastMs = 'adfm_appopen_last_ms';
  static const _kAppOpenDaily = 'adfm_appopen_daily';
  static const _kAppOpenDate = 'adfm_appopen_date';

  // ── Configuration ────────────────────────────────────────────────────────

  /// Apply remote-fetched limits. Safe to call multiple times.
  void configure(AdLimits limits) {
    _limits = limits;
  }

  /// Reset in-memory session counters. Call on cold-start launch.
  void startNewSession() {
    _rewardedSessionCount = 0;
    _rewardedInterstitialSessionCount = 0;
    _appOpenSessionCount = 0;
    log('Session counters reset.', name: _tag);
  }

  // ── Interstitial ─────────────────────────────────────────────────────────

  Future<bool> canShowInterstitial() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().toUtc();

    final lastMs = prefs.getInt(_kInterstitialLastMs) ?? 0;
    if (now.millisecondsSinceEpoch - lastMs < _limits.interstitialMinGapMs) {
      _logBlocked('interstitial', 'min_gap');
      return false;
    }

    final daily = await _getDailyCount(
        prefs, _kInterstitialDaily, _kInterstitialDate, now);
    if (daily >= _limits.interstitialMaxPerDay) {
      _logBlocked('interstitial', 'daily_limit:$daily');
      return false;
    }

    return true;
  }

  Future<void> recordInterstitialShown() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().toUtc();
    await prefs.setInt(_kInterstitialLastMs, now.millisecondsSinceEpoch);
    await _incrementDaily(prefs, _kInterstitialDaily, _kInterstitialDate, now);
    log('Interstitial recorded.', name: _tag);
  }

  // ── Rewarded ──────────────────────────────────────────────────────────────

  Future<bool> canShowRewarded() async {
    if (_rewardedSessionCount >= _limits.rewardedMaxPerSession) {
      _logBlocked('rewarded', 'session_limit:$_rewardedSessionCount');
      return false;
    }

    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().toUtc();

    final lastMs = prefs.getInt(_kRewardedLastMs) ?? 0;
    if (now.millisecondsSinceEpoch - lastMs < _limits.rewardedMinGapMs) {
      _logBlocked('rewarded', 'min_gap');
      return false;
    }

    final daily =
        await _getDailyCount(prefs, _kRewardedDaily, _kRewardedDate, now);
    if (daily >= _limits.rewardedMaxPerDay) {
      _logBlocked('rewarded', 'daily_limit:$daily');
      return false;
    }

    return true;
  }

  Future<void> recordRewardedShown() async {
    _rewardedSessionCount++;
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().toUtc();
    await prefs.setInt(_kRewardedLastMs, now.millisecondsSinceEpoch);
    await _incrementDaily(prefs, _kRewardedDaily, _kRewardedDate, now);
    log('Rewarded recorded (session: $_rewardedSessionCount).', name: _tag);
  }

  /// Returns how many rewarded ads the user can still watch today.
  Future<int> remainingRewardedToday() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().toUtc();
    final used =
        await _getDailyCount(prefs, _kRewardedDaily, _kRewardedDate, now);
    final sessionRemaining =
        _limits.rewardedMaxPerSession - _rewardedSessionCount;
    final dayRemaining = _limits.rewardedMaxPerDay - used;
    return sessionRemaining.clamp(
        0, dayRemaining.clamp(0, _limits.rewardedMaxPerDay));
  }

  // ── Rewarded Interstitial ────────────────────────────────────────────────

  Future<bool> canShowRewardedInterstitial() async {
    if (_rewardedInterstitialSessionCount >=
        _limits.rewardedInterstitialMaxPerSession) {
      _logBlocked(
          'rew_int', 'session_limit:$_rewardedInterstitialSessionCount');
      return false;
    }

    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().toUtc();

    final lastMs = prefs.getInt(_kRewIntLastMs) ?? 0;
    if (now.millisecondsSinceEpoch - lastMs <
        _limits.rewardedInterstitialMinGapMs) {
      _logBlocked('rew_int', 'min_gap');
      return false;
    }

    final daily = await _getDailyCount(prefs, _kRewIntDaily, _kRewIntDate, now);
    if (daily >= _limits.rewardedInterstitialMaxPerDay) {
      _logBlocked('rew_int', 'daily_limit:$daily');
      return false;
    }

    return true;
  }

  Future<void> recordRewardedInterstitialShown() async {
    _rewardedInterstitialSessionCount++;
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().toUtc();
    await prefs.setInt(_kRewIntLastMs, now.millisecondsSinceEpoch);
    await _incrementDaily(prefs, _kRewIntDaily, _kRewIntDate, now);
    log('RewardedInterstitial recorded (session: $_rewardedInterstitialSessionCount).',
        name: _tag);
  }

  // ── App-Open ─────────────────────────────────────────────────────────────

  Future<bool> canShowAppOpen() async {
    if (_appOpenSessionCount >= _limits.appOpenMaxPerSession) {
      _logBlocked('app_open', 'session_limit:$_appOpenSessionCount');
      return false;
    }

    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().toUtc();

    final lastMs = prefs.getInt(_kAppOpenLastMs) ?? 0;
    if (now.millisecondsSinceEpoch - lastMs < _limits.appOpenMinGapMs) {
      _logBlocked('app_open', 'min_gap');
      return false;
    }

    final daily =
        await _getDailyCount(prefs, _kAppOpenDaily, _kAppOpenDate, now);
    if (daily >= _limits.appOpenMaxPerDay) {
      _logBlocked('app_open', 'daily_limit:$daily');
      return false;
    }

    return true;
  }

  Future<void> recordAppOpenShown() async {
    _appOpenSessionCount++;
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().toUtc();
    await prefs.setInt(_kAppOpenLastMs, now.millisecondsSinceEpoch);
    await _incrementDaily(prefs, _kAppOpenDaily, _kAppOpenDate, now);
    log('AppOpen recorded (session: $_appOpenSessionCount).', name: _tag);
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  static String _utcDateKey(DateTime utc) =>
      '${utc.year.toString().padLeft(4, '0')}-'
      '${utc.month.toString().padLeft(2, '0')}-'
      '${utc.day.toString().padLeft(2, '0')}';

  Future<int> _getDailyCount(SharedPreferences prefs, String countKey,
      String dateKey, DateTime utcNow) async {
    final stored = prefs.getString(dateKey) ?? '';
    if (stored != _utcDateKey(utcNow)) return 0;
    return prefs.getInt(countKey) ?? 0;
  }

  Future<void> _incrementDaily(SharedPreferences prefs, String countKey,
      String dateKey, DateTime utcNow) async {
    final today = _utcDateKey(utcNow);
    final stored = prefs.getString(dateKey) ?? '';
    final current = stored == today ? (prefs.getInt(countKey) ?? 0) : 0;
    await prefs.setInt(countKey, current + 1);
    await prefs.setString(dateKey, today);
  }

  void _logBlocked(String format, String reason) {
    log('🛑 [$format] blocked: $reason', name: _tag);
  }
}
