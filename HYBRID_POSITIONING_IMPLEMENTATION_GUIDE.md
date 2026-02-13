# Hybrid Positioning Implementation Guide
## Student/Professional Paths for mQuiz App

### Implementation Status: Foundation Complete ✓

---

## 📋 What Has Been Completed

### 1. Backend Infrastructure ✓

#### Database Migrations
**File**: `admin_backend/database/migrations/2026_02_13_create_user_paths_system.sql`

**Tables Created**:
- `tbl_user_paths` - Stores user's selected path and preferences
  - Fields: user_id, selected_path, can_switch, selected_at, topics_preference, daily_goal_minutes, onboarding_completed, demo_quiz_completed
  
- `tbl_skill_assessments` - Professional skill assessments
  - Fields: id, title, description, category_id, target_audience, question_count, time_limit, passing_score, badge_id
  
- `tbl_user_assessments` - Tracks user assessment completion
  - Fields: user_id, assessment_id, score, total_questions, correct_answers, time_taken, passed, badge_earned
  
- `tbl_skill_assessment_questions` - Maps questions to assessments

**Tables Modified**:
- `tbl_category` - Added `target_audience` and `content_type` fields
- `tbl_question` - Added `context`, `difficulty_level`, `skill_tags` fields (question_type extended to support scenario/case_study)

**Migration Runner**: `admin_backend/run_user_paths_migration.php`

#### API Endpoints Created
**File**: `admin_backend/application/controllers/Api.php` (Lines 8614+)

**Endpoints**:
1. `POST /api/user/set_user_path` - Save user's path selection
2. `POST /api/user/get_user_path` - Retrieve current path
3. `POST /api/user/switch_user_path` - Allow path switching
4. `POST /api/user/get_personalized_content` - Get content based on path
5. `POST /api/categories/get_categories_by_audience` - Filter categories by audience
6. `POST /api/questions/get_scenario_questions` - Fetch scenario-based questions

### 2. Flutter Models & Architecture ✓

#### Models Created

**UserPath Model** (`lib/features/user_path/models/user_path.dart`)
- Enum `UserPathType`: student, professional, competition
- Class `UserPath`: Complete user path data model
- Methods: fromJson, toJson, copyWith
- Helper properties: displayName, icon, description, benefits for each path type

**Updated Models**:

**Category Model** (`lib/features/quiz/models/category.dart`)
- Added `TargetAudience` enum (student, professional, both, general)
- Added `ContentType` enum (academic, workplace, skill, general)
- New fields: `targetAudience`, `contentType`
- Helper methods: `isForStudents`, `isForProfessionals`

**Question Model** (`lib/features/quiz/models/question.dart`)
- Added `DifficultyLevel` enum (beginner, intermediate, advanced)
- New fields: `context`, `difficultyLevel`, `skillTags`
- Helper property: `isScenarioQuestion`

#### Repository Layer

**UserPathRemoteDataSource** (`lib/features/user_path/repositories/user_path_remote_data_source.dart`)
- Methods: setUserPath, getUserPath, switchUserPath, getPersonalizedContent, getCategoriesByAudience
- Error handling with ApiException

**UserPathRepository** (`lib/features/user_path/repositories/user_path_repository.dart`)
- Singleton pattern implementation
- Business logic layer between Cubit and data source

#### State Management

**UserPathCubit** (`lib/features/user_path/cubits/user_path_cubit.dart`)
- States: Initial, Loading, Loaded, NotSet, Error
- Methods: fetchUserPath, setUserPath, switchUserPath, updateDemoQuizCompleted
- Helper getters: isOnboardingCompleted, isDemoQuizCompleted, selectedPath, hasPathSet, needsOnboarding

### 3. UI Components ✓

**PathSelectionScreen** (`lib/ui/screens/user_path/path_selection_screen.dart`)
- Beautiful onboarding UI with 3 path options
- Animated card selection
- Path benefits display
- Continue button with state management
- Follows existing app design patterns

---

## 🚀 Next Steps for Implementation

### IMMEDIATE: Deploy Database Changes

**Step 1: Run Database Migration**
```bash
cd admin_backend
php run_user_paths_migration.php
```

**Verify Migration Success**:
- Check that all tables are created: `tbl_user_paths`, `tbl_skill_assessments`, etc.
- Verify columns added to `tbl_category` and `tbl_question`
- Check that professional categories are inserted

### NEXT: Integrate PathSelectionScreen into App Flow

**Current Onboarding Flow**:
1. Language Selection → IntroSlider (3 slides) → Feature Showcase → Home

**New Flow Should Be**:
1. Language Selection → IntroSlider → **PathSelectionScreen** → PathPreferencesScreen (optional) → Demo Quiz → Home

**Files to Modify**:

**Option A**: Add to existing IntroSlider
- File: `lib/ui/screens/onboarding_screen.dart`
- Add PathSelectionScreen as the 4th slide after rewards slide
- Or navigate to PathSelectionScreen after the 3rd slide instead of FeatureShowcase

**Option B**: Add check in app initialization
- File: Check where app checks for first launch (likely in main.dart or a splash screen)
- Add UserPathCubit check: if `needsOnboarding`, show PathSelectionScreen

**Recommended Approach** (Option A):
```dart
// In onboarding_screen.dart, _handleContinue method
void _handleContinue() {
  if (sliderIndex < slideList.length - 1) {
    pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  } else {
    context.read<SettingsCubit>().changeShowIntroSlider();
    // Navigate to PathSelectionScreen instead of FeatureShowcase
    Navigator.of(context).push(PathSelectionScreen.route());
  }
}
```

### CREATE: PathPreferencesScreen

**Purpose**: Optional screen after path selection for detailed preferences

**Features**:
- Topic checkboxes (populated from categories based on path)
- Daily goal selector (5, 10, 20 minutes)
- Skip button (use defaults)
- Save and continue

**File to Create**: `lib/ui/screens/user_path/path_preferences_screen.dart`

**Template Structure**:
```dart
class PathPreferencesScreen extends StatefulWidget {
  final UserPathType selectedPath;
  
  const PathPreferencesScreen({required this.selectedPath});
  
  // State: selected topics, daily goal
  // UI: Category checkboxes, radio buttons for goals
  // Actions: Save preferences, Skip
}
```

### CREATE: Demo Quiz Flow

**After Path Selection**:
- Show 5 quick questions from selected path's categories
- Simple, fun questions (no timer pressure)
- Celebration animation on completion
- Auto-navigate to home

**Implementation**:
1. Create `DemoQuizScreen` widget
2. Fetch 5 questions filtered by user's path using `getPersonalizedContent` API
3. Show questions with simple UI
4. On completion, call `updateDemoQuizCompleted` in UserPathCubit
5. Navigate to home screen

### UPDATE: Home Screen Logic

**File**: `lib/ui/screens/home/home_screen.dart`

**Add UserPathCubit Check**:
```dart
// In build method, check user path
final userPath = context.watch<UserPathCubit>().selectedPath;

// Conditionally render sections based on path
if (userPath == UserPathType.student) {
  // Show student-focused layout
} else if (userPath == UserPathType.professional) {
  // Show professional layout
} else {
  // Competition layout
}
```

**Create Path-Specific Widgets**:
- `StudentHomeLayout` - Academic focus
- `ProfessionalHomeLayout` - Skills/workplace focus
- `CompetitionHomeLayout` - Battles/leaderboards focus

### ADD: Professional Content to Database

**Manual Steps**:
1. Access admin panel
2. Navigate to Categories
3. Verify professional categories exist:
   - Leadership & Management
   - Workplace Communication
   - Business Strategy
   - Tech & AI Fundamentals
   - Finance & Investment
   - Digital Marketing
   - Entrepreneurship
   - Career & Interview Prep
   - Workplace Scenarios

4. Add professional questions (50-100 per category recommended)
   - Use question_type = 3 for scenario-based questions
   - Fill in `context` field with case study/scenario
   - Set `difficulty_level` appropriately
   - Add `skill_tags` as JSON array

**Bulk Import** (if needed):
Create CSV/JSON import tool in admin panel or use existing question import with new fields

---

## 📝 Testing Checklist

### Backend Testing
- [ ] Run database migration successfully
- [ ] Test all 6 new API endpoints with Postman/curl
- [ ] Verify data persistence in database
- [ ] Test with different user accounts
- [ ] Verify professional categories visible in API

### Frontend Testing
- [ ] Build Flutter app successfully (no compilation errors)
- [ ] Test PathSelectionScreen UI on different screen sizes
- [ ] Verify UserPathCubit state management works
- [ ] Test API integration (mock if backend not ready)
- [ ] Test navigation flow

### Integration Testing
- [ ] Complete onboarding flow as new user
- [ ] Switch between paths
- [ ] Verify personalized content delivery
- [ ] Test backward compatibility with existing users

---

## 🎨 UI/UX Considerations

### Design Consistency
- PathSelectionScreen uses existing app color scheme
- Follows CustomRoundedButton pattern
- Animation duration matches existing screens (800ms fade)

### User Experience
- Path selection is clear and visual
- Benefits are concise (3 per path)
- One-tap selection with immediate visual feedback
- Continue button disabled until selection made

### Accessibility
- High contrast text
- Large touch targets (60px icons)
- Clear labels and descriptions

---

## 🔧 Configuration & Settings

### App Settings to Add

**In tbl_settings table**:
```sql
INSERT INTO tbl_settings (type, message) VALUES
  ('path_switching_enabled', '1'),
  ('onboarding_demo_questions', '5'),
  ('default_path', 'student');
```

### Feature Flags (Optional)
- Enable/disable path system entirely
- Control whether users can switch paths
- Set minimum requirements before path switching

---

## 📚 API Usage Examples

### Set User Path
```dart
final userPathCubit = context.read<UserPathCubit>();
await userPathCubit.setUserPath(
  userId: userId,
  selectedPath: UserPathType.professional,
  topicsPreference: ['Leadership', 'Communication'],
  dailyGoalMinutes: 20,
);
```

### Get Personalized Content
```dart
final content = await userPathCubit.getPersonalizedContent(limit: 10);
final categories = content['categories'] as List;
// Display categories filtered by user's path
```

### Switch Path
```dart
await userPathCubit.switchUserPath(
  userId: userId,
  newPath: UserPathType.competition,
);
```

---

## 🚨 Known Limitations & Future Enhancements

### Current Limitations
1. Skill assessments API not yet implemented
2. Admin panel for professional content not created
3. Scenario question widget not built
4. Path analytics not implemented

### Future Enhancements
1. **Skill Assessments**: Full implementation with badge rewards
2. **Admin Dashboard**: Analytics showing path distribution
3. **Path-Based Notifications**: Personalized push notifications
4. **Content Recommendations**: ML-based recommendations
5. **Social Features**: Connect users with same path
6. **B2B Features**: Organizational accounts for professionals

---

## 📖 Code Quality & Standards

### Follows Existing Patterns
- ✓ Cubit pattern for state management
- ✓ Repository pattern for data access
- ✓ Singleton repositories
- ✓ ApiException for error handling
- ✓ Null-safe Dart code
- ✓ Const constructors where possible
- ✓ Sealed classes for states

### Code Documentation
- All models have inline comments
- API endpoints documented in method comments
- Complex logic explained

### Testing Ready
- Models are testable (pure functions)
- Cubits can be unit tested
- Repositories can be mocked

---

## 🎯 Success Metrics (Post-Launch)

### User Engagement
- % of users completing path selection
- Path distribution (target: 40% student, 35% professional, 25% competition)
- Time to complete onboarding

### Content Engagement
- Questions answered per path
- Professional content usage rate
- Path switching frequency

### Retention
- Day 1, 7, 30 retention by path
- Session duration by path
- Daily active users by path

---

## 🔗 Important File References

### Backend Files
- Migration: `admin_backend/database/migrations/2026_02_13_create_user_paths_system.sql`
- API Controller: `admin_backend/application/controllers/Api.php` (lines 8614+)
- Migration Runner: `admin_backend/run_user_paths_migration.php`

### Flutter Files
- UserPath Model: `lib/features/user_path/models/user_path.dart`
- Category Model: `lib/features/quiz/models/category.dart`
- Question Model: `lib/features/quiz/models/question.dart`
- UserPath Cubit: `lib/features/user_path/cubits/user_path_cubit.dart`
- Repository: `lib/features/user_path/repositories/user_path_repository.dart`
- Remote Data Source: `lib/features/user_path/repositories/user_path_remote_data_source.dart`
- Path Selection Screen: `lib/ui/screens/user_path/path_selection_screen.dart`

### Integration Points
- Onboarding: `lib/ui/screens/onboarding_screen.dart`
- Home Screen: `lib/ui/screens/home/home_screen.dart`
- Auth: `lib/features/auth/cubits/auth_cubit.dart`

---

## 💡 Tips for Developers

1. **Always run migrations first** before testing API endpoints
2. **Check UserPathCubit state** before accessing user path data
3. **Use null-safe operators** when accessing user path (may be null for existing users)
4. **Test with both new and existing users** to ensure backward compatibility
5. **Add UserPathCubit to BlocProvider** in app initialization
6. **Handle loading states** in UI to avoid blank screens
7. **Validate path switching** - check `canSwitch` flag before allowing

---

## 🆘 Troubleshooting

### API Returns Error
- Verify database migration ran successfully
- Check API endpoint URL is correct
- Verify auth token is being sent
- Check server logs for PHP errors

### PathSelectionScreen Not Showing
- Verify UserPathCubit is provided in widget tree
- Check navigation logic in onboarding flow
- Ensure imports are correct

### Categories Not Filtered
- Verify `target_audience` column exists in database
- Check API response includes new fields
- Verify Category.fromJson handles new fields

### Migration Fails
- Check database user has CREATE/ALTER permissions
- Verify no syntax errors in SQL
- Check if tables already exist
- Look at migration runner output for specific error

---

## ✅ Final Deployment Checklist

### Before Launch
- [ ] Database migration completed on production
- [ ] API endpoints tested on production server
- [ ] Professional content added (minimum 50 questions per category)
- [ ] PathSelectionScreen integrated into onboarding
- [ ] UserPathCubit added to app providers
- [ ] Existing users handled (backward compatibility)
- [ ] Error handling tested
- [ ] Loading states tested
- [ ] Analytics events added
- [ ] Play Store description updated

### Post-Launch Monitoring
- [ ] Monitor API error rates
- [ ] Track path selection distribution
- [ ] Watch for crashes/bugs
- [ ] Collect user feedback
- [ ] A/B test variations if needed

---

**Created**: February 13, 2026
**Last Updated**: February 13, 2026
**Status**: Foundation Complete - Ready for Integration
**Version**: 1.0
