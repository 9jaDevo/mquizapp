# User Paths API Reference
Quick reference for hybrid positioning API endpoints

## Base URL
```
{baseUrl}/Api/
```

## Authentication
All endpoints require JWT token in headers via `ApiUtils.getHeaders()`

---

## 1. Set User Path
**Endpoint**: `POST /set_user_path`

**Purpose**: Save user's selected learning path and preferences

**Request Body**:
```json
{
  "selected_path": "student|professional|competition",
  "topics_preference": "[\"topic1\",\"topic2\"]",  // Optional, JSON string
  "daily_goal_minutes": "10",  // Optional, default: 10
  "demo_quiz_completed": "1"   // Optional, 0 or 1
}
```

**Success Response**:
```json
{
  "error": false,
  "message": "Path saved successfully",
  "data": {
    "selected_path": "professional",
    "daily_goal_minutes": 10
  }
}
```

**Error Response**:
```json
{
  "error": true,
  "message": "Invalid path selection"
}
```

---

## 2. Get User Path
**Endpoint**: `POST /get_user_path`

**Purpose**: Retrieve user's current learning path settings

**Request Body**: (Empty or just auth headers)

**Success Response** (Path Set):
```json
{
  "error": false,
  "message": "Path retrieved successfully",
  "data": {
    "selected_path": "professional",
    "topics_preference": "[\"Leadership\",\"Communication\"]",
    "daily_goal_minutes": 20,
    "onboarding_completed": 1,
    "demo_quiz_completed": 1,
    "can_switch": 1,
    "selected_at": "2026-02-13 10:30:00"
  }
}
```

**Success Response** (No Path):
```json
{
  "error": false,
  "message": "No path selected yet",
  "data": {
    "selected_path": null,
    "onboarding_completed": 0,
    "demo_quiz_completed": 0
  }
}
```

---

## 3. Switch User Path
**Endpoint**: `POST /switch_user_path`

**Purpose**: Change user's learning path

**Request Body**:
```json
{
  "new_path": "competition"
}
```

**Success Response**:
```json
{
  "error": false,
  "message": "Path switched successfully",
  "data": {
    "selected_path": "competition"
  }
}
```

**Error Response** (Switching Disabled):
```json
{
  "error": true,
  "message": "Path switching is disabled for your account"
}
```

**Error Response** (No Path Set):
```json
{
  "error": true,
  "message": "No path set yet"
}
```

---

## 4. Get Personalized Content
**Endpoint**: `POST /get_personalized_content`

**Purpose**: Fetch content (categories) filtered by user's path

**Request Body**:
```json
{
  "limit": "10"  // Optional, default: 10
}
```

**Success Response**:
```json
{
  "error": false,
  "message": "Content retrieved successfully",
  "data": {
    "selected_path": "professional",
    "categories": [
      {
        "id": "15",
        "category_name": "Leadership & Management",
        "image": "https://example.com/images/leadership.png",
        "no_of": "5",
        "maxlevel": "3",
        "is_premium": "0",
        "target_audience": "professional",
        "content_type": "workplace"
      },
      // ... more categories
    ]
  }
}
```

---

## 5. Get Categories by Audience
**Endpoint**: `POST /get_categories_by_audience`

**Purpose**: Filter categories by target audience type

**Request Body**:
```json
{
  "audience": "professional|student|both|general|all",  // Required
  "language_id": "14"  // Optional
}
```

**Success Response**:
```json
{
  "error": false,
  "message": "Categories retrieved successfully",
  "data": [
    {
      "id": "15",
      "category_name": "Leadership & Management",
      "image": "https://example.com/images/leadership.png",
      "no_of": "5",
      "maxlevel": "3",
      "is_premium": "0",
      "target_audience": "professional",
      "content_type": "workplace"
    },
    // ... more categories
  ]
}
```

---

## 6. Get Scenario Questions
**Endpoint**: `POST /get_scenario_questions`

**Purpose**: Fetch scenario-based or case study questions

**Request Body**:
```json
{
  "category": "15",  // Required
  "difficulty": "intermediate",  // Optional: beginner|intermediate|advanced
  "limit": "10",  // Optional, default: 10
  "language_id": "14"  // Optional
}
```

**Success Response**:
```json
{
  "error": false,
  "message": "Scenario questions retrieved successfully",
  "data": [
    {
      "id": "501",
      "category": "15",
      "subcategory": "0",
      "language_id": "14",
      "image": "",
      "question": "What would you do in this situation?",
      "question_type": "3",  // 3=scenario, 4=case_study
      "optiona": "Option A",
      "optionb": "Option B",
      "optionc": "Option C",
      "optiond": "Option D",
      "optione": "",
      "answer": "a",
      "level": "2",
      "note": "Explanation here",
      "context": "You are managing a team of 10 people. One team member consistently misses deadlines...",
      "difficulty_level": "intermediate",
      "skill_tags": "[\"leadership\",\"conflict-resolution\"]"
    },
    // ... more questions
  ]
}
```

---

## Database Schema Reference

### tbl_user_paths
```sql
user_id INT (FK to tbl_users)
selected_path ENUM('student','professional','competition')
can_switch TINYINT(1) DEFAULT 1
selected_at TIMESTAMP
topics_preference TEXT (JSON array)
daily_goal_minutes INT DEFAULT 10
onboarding_completed TINYINT(1) DEFAULT 0
demo_quiz_completed TINYINT(1) DEFAULT 0
updated_at TIMESTAMP
```

### tbl_category (NEW COLUMNS)
```sql
target_audience ENUM('student','professional','both','general') DEFAULT 'general'
content_type ENUM('academic','workplace','skill','general') DEFAULT 'general'
```

### tbl_question (NEW COLUMNS)
```sql
question_type TINYINT (1=MCQ, 2=T/F, 3=scenario, 4=case_study)
context TEXT (scenario description)
difficulty_level ENUM('beginner','intermediate','advanced') DEFAULT 'beginner'
skill_tags TEXT (JSON array)
```

---

## Error Codes

| Code | Message | Description |
|------|---------|-------------|
| 122 | Error code | General exception |
| Invalid path | - | Path value not in allowed enum |
| No path set yet | - | User hasn't selected a path |
| Path switching disabled | - | User's can_switch flag is 0 |
| Category is required | - | Missing category parameter |

---

## Usage Examples (Flutter)

### Set Path on Onboarding
```dart
final userId = context.read<AuthCubit>().getUserId();
await context.read<UserPathCubit>().setUserPath(
  userId: userId,
  selectedPath: UserPathType.professional,
  topicsPreference: ['Leadership', 'Communication'],
  dailyGoalMinutes: 20,
);
```

### Check if Onboarding Needed
```dart
final userPathCubit = context.read<UserPathCubit>();
await userPathCubit.fetchUserPath(userId);

if (userPathCubit.needsOnboarding) {
  // Show PathSelectionScreen
  Navigator.push(context, PathSelectionScreen.route());
}
```

### Get Personalized Categories
```dart
final content = await context.read<UserPathCubit>()
    .getPersonalizedContent(limit: 10);

final categories = (content['categories'] as List)
    .map((json) => Category.fromJson(json))
    .toList();
```

### Switch Path
```dart
await context.read<UserPathCubit>().switchUserPath(
  userId: userId,
  newPath: UserPathType.competition,
);
```

---

## Professional Categories (Default)

These categories are auto-inserted during migration:

1. **Leadership & Management** (professional, workplace)
2. **Workplace Communication** (professional, workplace)
3. **Business Strategy** (professional, workplace)
4. **Tech & AI Fundamentals** (both, skill)
5. **Finance & Investment** (professional, skill)
6. **Digital Marketing** (professional, skill)
7. **Entrepreneurship** (professional, workplace)
8. **Career & Interview Prep** (both, skill)
9. **Workplace Scenarios** (professional, workplace)

---

## Testing Endpoints with cURL

### Set Path
```bash
curl -X POST https://yourdomain.com/api/Api/set_user_path \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{
    "selected_path": "professional",
    "daily_goal_minutes": "20"
  }'
```

### Get Path
```bash
curl -X POST https://yourdomain.com/api/Api/get_user_path \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### Get Categories
```bash
curl -X POST https://yourdomain.com/api/Api/get_categories_by_audience \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{
    "audience": "professional",
    "language_id": "14"
  }'
```

---

**Version**: 1.0  
**Last Updated**: February 13, 2026  
**Backend File**: `admin_backend/application/controllers/Api.php` (lines 8614+)
