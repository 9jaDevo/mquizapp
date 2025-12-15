# Git Branching Strategy for Vendor Updates

This document outlines the Git workflow for managing vendor script updates while preserving custom features for App Store differentiation.

## Branch Structure

```
main (vendor code)
  ├── feature/skill-tiers
  ├── feature/daily-challenges
  ├── feature/enhanced-onboarding
  └── custom-build (production)
```

### Branch Descriptions

- **`main`**: Contains unmodified vendor script code. Always keep this clean.
- **`feature/*`**: Individual feature branches for custom implementations.
- **`custom-build`**: Production branch with all custom features merged. Submit to App Store from this branch.

## Workflow for Vendor Updates

### 1. Receiving Vendor Updates

When the vendor provides a new script version:

```bash
# Switch to main branch
git checkout main

# Pull/merge vendor's updates
git pull vendor main
# OR if vendor provides a zip file:
# - Extract to a temporary location
# - Copy files to main branch
# - Review changes carefully

# Commit vendor changes
git add .
git commit -m "chore: vendor script update v1.2.3"
git push origin main
```

### 2. Merging Updates into Custom Features

```bash
# Update feature branches one by one
git checkout feature/skill-tiers
git merge main
# Resolve any conflicts (see Conflict Resolution section)
git push origin feature/skill-tiers

# Repeat for other feature branches
git checkout feature/daily-challenges
git merge main
# Resolve conflicts if any
git push origin feature/daily-challenges

git checkout feature/enhanced-onboarding
git merge main
# Resolve conflicts if any
git push origin feature/enhanced-onboarding
```

### 3. Rebuilding Production Branch

```bash
# Update custom-build with latest features
git checkout custom-build
git merge feature/skill-tiers
git merge feature/daily-challenges
git merge feature/enhanced-onboarding

# Test thoroughly
flutter clean
flutter pub get
flutter run

# If tests pass, push and build release
git push origin custom-build
flutter build appbundle  # For Android
flutter build ipa        # For iOS
```

## Conflict Resolution

Common conflict points and resolutions:

### 1. `lib/app/app.dart` (BLoC Providers)

**Conflict**: Vendor may add new providers to `MultiBlocProvider`.

**Resolution**:
- Keep vendor's new providers
- Ensure custom providers remain intact
- Maintain proper import statements

### 2. `lib/core/routes/routes.dart`

**Conflict**: Vendor may add new route names or cases.

**Resolution**:
- Keep all vendor routes
- Preserve custom routes (`featureShowcase`)
- Ensure no duplicate route names

### 3. `lib/main.dart`

**Conflict**: Vendor may modify initialization logic.

**Resolution**:
- Accept vendor's initialization changes
- Verify Hive boxes remain opened
- Custom features use existing boxes (no conflicts expected)

### 4. `lib/ui/screens/home/home_screen.dart`

**Conflict**: Vendor may modify home screen layout.

**Resolution**:
- Accept vendor's structural changes
- Re-apply custom widgets:
  - `DailyChallengeCard` insertion
  - `SkillTierBadge` in header
- Test UI renders correctly

### 5. `lib/core/constants/hive_constants.dart`

**Conflict**: Vendor may add new Hive keys.

**Resolution**:
- Keep all vendor keys
- Preserve custom keys at bottom with comment marker:
  ```dart
  /// Custom additions (client-side features)
  const skillTierKey = 'skillTier';
  const dailyChallengeCacheKey = 'dailyChallengeCache';
  const dailyChallengeCompletedOnKey = 'dailyChallengeCompletedOn';
  ```

## Files Modified by Custom Features

### Isolated Custom Files (No Conflicts Expected)
- `lib/features/skill_tier/` (entire folder)
- `lib/ui/screens/home/widgets/daily_challenge_card.dart`
- `lib/ui/screens/feature_showcase_screen.dart`
- `lib/ui/widgets/skill_tier_badge.dart`

### Modified Existing Files (Monitor for Conflicts)
| File | Custom Changes | Conflict Likelihood |
|------|----------------|---------------------|
| `lib/app/app.dart` | None (no changes) | Low |
| `lib/core/routes/routes.dart` | Added `featureShowcase` route | Low |
| `lib/core/constants/hive_constants.dart` | Added 3 keys at end | Low |
| `lib/ui/screens/home/home_screen.dart` | Added imports, DailyChallengeCard, SkillTierBadge | Medium |
| `lib/ui/screens/onboarding_screen.dart` | Changed navigation target | Low |
| `lib/features/profile_tab/screens/profile_tab_screen.dart` | Added SkillTierBadge | Low |
| `lib/ui/screens/home/leaderboard_screen.dart` | Added SkillTierBadge | Low |

## Testing After Merge

### Quick Smoke Tests

```bash
# 1. Build and run
flutter clean && flutter pub get && flutter run

# 2. Test onboarding flow
# - First launch → Feature Showcase → Home
# - Skip button works

# 3. Test Daily Challenge
# - Card appears on Home screen
# - "Play Now" launches quiz
# - Returns to Home, shows "Completed today"

# 4. Test Skill Tier
# - Home header shows tier badge after login
# - Profile tab shows tier badge
# - Leaderboard "My Rank" shows tier badge

# 5. Test vendor features still work
# - Quiz Zone categories load
# - Battles work (1v1, group)
# - Leaderboards display
# - Coin store functional
```

## Rollback Strategy

If a vendor merge causes critical issues:

```bash
# Revert custom-build to previous state
git checkout custom-build
git reset --hard HEAD~1  # Go back one commit
git push origin custom-build --force

# Fix conflicts in feature branches
git checkout feature/skill-tiers
git reset --hard HEAD~1
# Re-merge main with proper conflict resolution
git merge main
# Fix conflicts properly this time
git push origin feature/skill-tiers --force
```

## Best Practices

1. **Never modify `main` branch** except for vendor updates
2. **Always test each feature branch** after merging from main
3. **Document custom changes** in code comments for easy identification
4. **Keep features isolated** in separate folders when possible
5. **Use clear commit messages**:
   - `chore: vendor update v1.2.3`
   - `feat: add skill tier badge to profile`
   - `fix: resolve merge conflict in home_screen.dart`

## Automation (Optional)

Create a merge script for efficiency:

```bash
#!/bin/bash
# merge-vendor-updates.sh

echo "Merging vendor updates into feature branches..."

git checkout feature/skill-tiers && git merge main && git push origin feature/skill-tiers
git checkout feature/daily-challenges && git merge main && git push origin feature/daily-challenges
git checkout feature/enhanced-onboarding && git merge main && git push origin feature/enhanced-onboarding

echo "Rebuilding custom-build..."
git checkout custom-build
git merge feature/skill-tiers
git merge feature/daily-challenges
git merge feature/enhanced-onboarding
git push origin custom-build

echo "Done! Run tests before deploying."
```

## Support

If you encounter merge conflicts you can't resolve:
1. Create a backup of your current work: `git stash`
2. Document the conflict files and error messages
3. Reach out to the vendor for clarification on their changes
4. Restore work: `git stash pop`
