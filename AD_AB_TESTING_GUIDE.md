# Ad A/B Testing Implementation Guide

## Overview
This document describes the comprehensive A/B testing framework for optimizing ad monetization in the Quiz App. The framework tests different placement strategies, banner sizes, reward amounts, and user segmentation to maximize eCPM while maintaining user experience.

## Test Variants

### 1. Banner Size Variants
**Purpose**: Determine which banner size generates the highest eCPM while minimizing UX disruption

#### Variant A: Adaptive (Control)
- **Configuration**: 320x50 on small screens, 300x250 on tablets
- **Expected**: Baseline eCPM for comparison
- **Pros**: Best fit for most screens, minimal layout changes
- **Cons**: Smaller on phones, lower visibility

#### Variant B: Medium Rectangle (300x250)
- **Configuration**: Always use 300x250 (medium rectangle)
- **Expected**: Higher eCPM than adaptive, higher CTR
- **Pros**: Premium ad format, commands higher bids from advertisers
- **Cons**: Takes significant screen space, affects UX on small phones

#### Variant C: Banner (320x50)
- **Configuration**: Always use 320x50 (standard banner)
- **Expected**: Lower eCPM than adaptive but consistent
- **Pros**: Minimal UX impact, clean UI
- **Cons**: Lowest eCPM, harder for users to notice

**Selection**: `AdABTestingFramework.getBannerSizeVariant()`
**Tracking**: `AdAnalyticsCollector.recordImpressionMetric('banner_size_*')`

---

### 2. Interstitial Placement Variants
**Purpose**: Find the best moment to show interstitials that maximizes completion rates while minimizing abandonment

#### Variant A: After Quiz Result (Control)
- **Placement**: Show after user completes quiz (at result screen)
- **Expected**: High CTR (user already engaged), baseline abandonment
- **Pros**: Natural flow, user momentum still high
- **Cons**: May disrupt celebration moment

#### Variant B: Before Level Select
- **Placement**: Show after user chooses quiz but before it loads
- **Expected**: Potentially higher CTR (user committed to playing), lower impression volume
- **Pros**: Early commitment point, fewer total ads shown
- **Cons**: May cause early abandonment

#### Variant C: After Two Quizzes
- **Placement**: Show interstitial after every 2 consecutive quiz completions
- **Expected**: Lower impression frequency but highly engaged user
- **Pros**: Reduces ad fatigue, higher quality impressions
- **Cons**: Fewer total impressions, potentially lower total revenue

#### Variant D: Random Timing
- **Placement**: Randomly choose between all above
- **Expected**: Wildcard test, may reveal unforeseen patterns
- **Pros**: Tests novelty effect
- **Cons**: Inconsistent UX, harder to debug

**Selection**: `AdABTestingFramework.getInterstitialPlacementVariant()`
**Implementation**: Check `AdABTestingFramework.shouldShowInterstitialAt('placement_name')`

---

### 3. Reward Amount Variants
**Purpose**: Determine optimal reward amount that maximizes engagement without inflating currency value

#### Variant A: Fixed Coins (10)
- **Reward**: Always 10 coins for any rewarded ad
- **Expected**: Predictable, consistent value perception
- **Pros**: Simple, predictable progression
- **Cons**: May seem stingy to heavy players

#### Variant B: Variable Coins (5-25)
- **Reward**: Random between 5-25 coins per rewarded ad
- **Expected**: Higher engagement due to excitement/variable ratio
- **Pros**: Increased ad watch completion (hope of high reward)
- **Cons**: May feel unfair if user gets low rewards

#### Variant C: Progressive Coins
- **Reward**: Increases based on user engagement level/tier
- **Expected**: High earners get more, incentivizes mastery
- **Pros**: Rewards consistent players
- **Cons**: Complex implementation

**Selection**: `AdABTestingFramework.getRewardAmountVariant()`
**Calculation**: `AdABTestingFramework.calculateRewardCoins(baseReward: 10)`

---

## Test Execution Plan

### Phase 1: Setup (Week 1)
```
1. Deploy code with A/B testing framework
2. Randomly assign users to variants (handled automatically by framework)
3. Monitor initial data collection
4. Verify no technical issues
```

### Phase 2: Data Collection (Weeks 2-4)
```
Target metrics per variant:
- Minimum 1,000 impressions per variant
- Minimum 100 clicks per variant
- 2-3 weeks of data for seasonal variation control
```

### Phase 3: Analysis (Week 4)
```
1. Generate daily reports via AdAnalyticsCollector.generateDailyReport()
2. Compare variants pairwise via AdAnalyticsCollector.compareVariants()
3. Identify winner(s) with statistical confidence
4. Document surprising findings
```

### Phase 4: Rollout (Week 5)
```
1. Roll out winning variant to 100% of users
2. Monitor for negative side effects
3. Archive metrics from test phase
4. Start next test
```

---

## Key Metrics

### 1. eCPM (Effective Cost Per Mille)
```
eCPM = (Total Revenue / Total Impressions) × 1000

Example:
- 10,000 impressions
- $8.50 revenue
- eCPM = ($8.50 / 10,000) × 1000 = $0.85

Interpretation:
- Higher is better
- Typical range: $0.20 - $1.50 for casual games
- Nigeria average: $0.15 - $0.40 (lower than US)
```

### 2. CTR (Click-Through Rate)
```
CTR = (Clicks / Impressions) × 100

Example:
- 10,000 impressions
- 150 clicks
- CTR = (150 / 10,000) × 100 = 1.5%

Interpretation:
- Higher is better
- Typical range: 0.5% - 3% for non-intrusive ads
- If > 5%, may indicate invalid traffic
```

### 3. Fill Rate
```
Fill Rate = (Ads Returned / Ad Requests) × 100

Interpretation:
- Higher is better
- If < 70%, network issues or blocked regions
- If dropping, may indicate quality or policy issues
```

### 4. Conversion Rate (for Rewarded Ads)
```
Conversion Rate = (Watched to Completion / Requested) × 100

Interpretation:
- Higher is better
- Typical: 60-85% for well-placed rewarded ads
- If low (< 40%), placement may be poor
```

### 5. User Retention Impact
```
Track in analytics separately:
- Day 1 retention: Users returning after 1 day
- Day 7 retention: Users returning after 7 days
- More ads = potentially lower retention

Threshold: If retention drops > 5%, winning variant may hurt long-term revenue
```

---

## Implementation: Integrating Metrics into App

### 1. Recording Impressions
```dart
// When banner ad loads
await AdAnalyticsCollector.recordImpressionMetric('banner_size_adaptive');

// Automatic in banner_ad_cubit.dart:
await AdImpressionQualityTracker.recordImpression('banner_standard');
```

### 2. Recording Clicks
```dart
// When user clicks an ad
await AdAnalyticsCollector.recordClickMetric('banner_size_adaptive');

// In OnAdClicked callbacks:
await AdImpressionQualityTracker.recordClickAndGetQuality(adId);
```

### 3. Recording Conversions
```dart
// When rewarded ad completes
await AdAnalyticsCollector.recordConversionMetric('reward_fixed_10');
```

### 4. Updating Revenue (Weekly from AdMob Console)
```dart
// Get revenue from AdMob console, update in app
await AdAnalyticsCollector.updateRevenueEstimate('banner_size_adaptive', 45.50);
```

### 5. Generating Reports
```dart
// Print daily report
final report = await AdAnalyticsCollector.generateDailyReport();
print(report);

// Compare two variants
final comparison = await AdAnalyticsCollector.compareVariants(
  'banner_size_adaptive', 
  'banner_size_medium'
);
print(comparison);
```

---

## Geographic Segmentation Integration

### GDPR Compliance (EU Users)
```dart
// Check if user is in EU
final isEU = await GeographicSegmentation.isEUUser();

if (isEU) {
  // Apply stricter frequency limits
  final limits = await GeographicSegmentation.getFrequencyLimits();
  // limits.maxInterstitialsPerDay = 2 (vs 3 for others)
  // limits.minInterstitialGapMs = 240000ms (vs 120000ms)
  
  // Require explicit consent before first ad
  // Shown in AdConsentDialog which is already integrated
}

// Record consent (already done in AdConsentTracker)
await GeographicSegmentation.recordAdConsent(true);
```

### CCPA Compliance (California Users)
```dart
// Check if user is in California
final isCalifornia = await GeographicSegmentation.isCaliforniaUser();

if (isCalifornia) {
  // Apply moderate limits
  final limits = await GeographicSegmentation.getFrequencyLimits();
  // Use slightly higher than EU, lower than other regions
}
```

---

## Expected Revenue Impact

### Scenario 1: Simple Optimization (Just A/B testing)
```
Assumptions:
- 10,000 DAU (Daily Active Users)
- Current eCPM: $0.25
- Current annual revenue: ~$45,000
- Testing 2 variants

Expected:
- Best variant shows 20% eCPM improvement
- New eCPM: $0.30
- New annual revenue: ~$54,000
- Additional annual: ~$9,000 (+20%)
```

### Scenario 2: Full Optimization (Lazy loading + Quality tracking + A/B + Segmentation)
```
Assumptions:
- 10,000 DAU
- Lazy loading increases quality score 15% → better bids
- A/B testing finds 20% eCPM winner
- Segmentation reduces GDPR compliance risk (avoid suspension)
- Impression quality tracking prevents 5% invalid traffic loss

Expected:
- Combined eCPM improvement: 35%
- New eCPM: $0.3375
- New annual revenue: ~$60,750
- Additional annual: ~$15,750 (+35%)
- Risk mitigation: Avoid $45K+ suspension loss
```

---

## Monitoring & Quality Assurance

### Daily Checks
```
1. Is each variant receiving traffic? (impressions growing)
2. Are metrics balanced? (no single variant dominance)
3. Are CTRs reasonable? (0.5% - 3% range)
4. No unusual patterns? (no sudden spikes/drops)
```

### Weekly Checks
```
1. eCPM trending? (stable or improving)
2. Retention impact? (is engagement maintained)
3. Invalid traffic detected? (quality scores < 0.7)
4. Revenue estimate from AdMob matches expectations?
```

### Monthly Review
```
1. Statistical significance achieved? (n >= 1,000 per variant)
2. Clear winner emerged? (> 15% difference in eCPM)
3. Risk mitigation working? (no policy violations)
4. Next test planned?
```

---

## Testing Utilities

### View All Assigned Variants
```dart
final variants = await AdABTestingFramework.getAllVariants();
print(variants);
// Output: {
//   'banner_size': 'BannerSizeVariant.medium',
//   'interstitial_placement': 'InterstitialPlacementVariant.afterQuizResult',
//   'reward_amount': 'RewardAmountVariant.fixed'
// }
```

### Reset Variants (Testing Only)
```dart
// Start fresh test
await AdABTestingFramework.resetAllVariants();

// User gets new random assignment on next app launch
```

### View Banner Performance Metrics
```dart
final metrics = await AdAnalyticsCollector.getVariantMetrics('banner_size_adaptive');
print(metrics?.toJson());
// Output: {
//   'impressions': 1250,
//   'clicks': 18,
//   'conversions': 0,
//   'ctr_percent': '1.44',
//   'ecpm': '0.68',
//   'active_duration_hours': 72
// }
```

### Detect Impression Quality Issues
```dart
final qualityScore = await AdImpressionQualityTracker.getQualityScore('banner_standard');
if (qualityScore < 0.5) {
  // Flag for manual review - potential fraud
  print('⚠️ Low quality score detected: ${qualityScore * 100}%');
}
```

---

## Troubleshooting

### Issue: One variant has way more impressions than others
**Cause**: Random assignment worked but by chance
**Solution**: Increase test duration to 3+ weeks for balance
**Prevention**: Could implement stratified random assignment in future

### Issue: CTR seems too high (> 5%)
**Cause**: Potential invalid traffic, users clicking repeatedly
**Solution**: Check `AdImpressionQualityTracker.getQualityScore()` - should be < 0.5
**Action**: Block that traffic pattern, investigate placement

### Issue: eCPM varies wildly day-to-day
**Cause**: Small sample size, regional variation
**Solution**: Average over 7+ days, increase traffic volume
**Normal**: ±20% daily variation is typical

### Issue: Revenue not matching AdMob console
**Cause**: Delayed revenue reporting, time zone differences
**Solution**: Update via `AdAnalyticsCollector.updateRevenueEstimate()` weekly
**Timing**: AdMob updates every 24-48 hours with delays

---

## Next Steps After A/B Tests

### If Test Results Are Clear
```
1. Roll out winning variant to 100%
2. Monitor for 1 week to catch issues
3. Document why it won
4. Plan next test based on learnings
```

### Suggested Next Tests (Roadmap)
```
Test 2: Ad Load Timing
  - Load interstitial before activity vs. on demand
  - Expected: Better fill rates with preloading

Test 3: User Segmentation
  - Lighter ad load for new users (< 7 days)
  - Heavier ad load for veterans (> 30 days)
  - Expected: Better retention + higher monetization

Test 4: Dynamic Reward Scaling
  - Rewards based on time played, skills earned
  - Expected: Higher engagement, better LTV

Test 5: Network Redundancy
  - Test AdMob vs. IronSource vs. Unity fill rates
  - Switch to backup network if main fails
  - Expected: Higher fill rate stability
```

---

## Privacy & Compliance Notes

### Data Collected
- Impressions (ad shown count)
- Clicks (user clicked ad)
- Conversions (watched reward ad)
- Estimated revenue (calculated from impressions/clicks)
- Variant assignment (A/B test group)
- Quality metrics (detect fraud)

### NOT Collected
- Individual user IDs (analytics are per-variant, aggregated)
- Ad content details
- Personal information beyond region

### Compliance
- GDPR: EU users can't be forced into high-ad variants without explicit consent ✅
- CCPA: California residents get stricter frequency limits ✅
- AdMob Policy: No ad stacking, clear disclosure, skip option ✅
- Invalid Traffic: Quality scoring prevents fraud impressions ✅

---

## Support

For issues or questions:
1. Check device logs: `adb logcat | grep -E "ABTesting|Analytics|Geographic"`
2. Review metrics: `AdAnalyticsCollector.generateDailyReport()`
3. Check user variant: `AdABTestingFramework.getAllVariants()`
4. Review implementation: See `lib/features/ads/utils/` directory
