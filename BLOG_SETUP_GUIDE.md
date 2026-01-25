# Blog API Implementation - Setup Guide

## Overview

The blog API has been successfully implemented in the admin backend. This document provides instructions for completing the setup and testing the integration with the React frontend.

## What Has Been Completed

### ✅ 1. Blog API Endpoints (6 endpoints)

All endpoints have been added to `admin_backend/application/controllers/Api.php`:

**GET Endpoints:**
- `GET /api/blog/posts` - List all blog posts with pagination, search, and filtering
- `GET /api/blog/post/{slug}` - Get a single blog post by slug (auto-increments views)
- `GET /api/blog/categories` - Get all blog categories with post counts
- `GET /api/blog/featured` - Get featured blog posts
- `GET /api/blog/related/{id}` - Get related posts for a specific post

**POST Endpoints:**
- `POST /api/blog/post/{id}/view` - Increment view count for a post

### ✅ 2. Routes Configuration

All routes have been added to `admin_backend/application/config/routes.php`:

```php
// Blog API Routes
$route['api/blog/posts'] = 'Api/blog_posts_get';
$route['api/blog/post/(:any)'] = 'Api/blog_post_get';
$route['api/blog/categories'] = 'Api/blog_categories_get';
$route['api/blog/featured'] = 'Api/blog_featured_get';
$route['api/blog/related/(:num)'] = 'Api/blog_related_get';
$route['api/blog/post/(:num)/view'] = 'Api/blog_view_post';
```

### ✅ 3. Blog Model

The Blog_model.php has been created with full CRUD operations and data formatting methods.

### ⏳ 4. Database Tables (Ready to Deploy)

SQL migration file ready at: `admin_backend/database/migrations/001_create_blog_tables.sql`

## Next Steps - Database Setup

### Option 1: Using PHPMyAdmin (Recommended for Windows/XAMPP)

1. Open PHPMyAdmin: `http://localhost/phpmyadmin/`
2. Select your database `mquiz_d5bueportal`
3. Click "SQL" tab
4. Open file: `admin_backend/database/migrations/001_create_blog_tables.sql`
5. Copy all content from the SQL file
6. Paste into the SQL tab
7. Click "Go" to execute

### Option 2: Using Command Line (MySQL)

```bash
cd c:\xampp\htdocs\mquizapp\admin_backend\database\migrations
mysql -h localhost -u root -p mquiz_d5bueportal < 001_create_blog_tables.sql
```

Note: Replace `root` and database name if different.

### Option 3: Using PHP Script

Run the migration script:

```bash
cd c:\xampp\htdocs\mquizapp\admin_backend
php run_migration.php
```

**Important:** Update database credentials in `run_migration.php` if using non-standard setup.

## API Response Format

All endpoints follow this consistent response format:

```json
{
  "error": false,
  "message": "Success message",
  "data": {
    "posts": [...],
    "pagination": {
      "current_page": 1,
      "total_pages": 5,
      "total_posts": 50,
      "per_page": 10,
      "has_next": true,
      "has_prev": false
    }
  }
}
```

## API Usage Examples

### 1. Get All Blog Posts with Pagination

```bash
GET /api/blog/posts?page=1&limit=10&category=learning-tips&search=test&sort=created_at&order=DESC
```

**Parameters:**
- `page` (int, default: 1) - Page number
- `limit` (int, default: 10) - Items per page
- `category` (string, optional) - Filter by category slug
- `search` (string, optional) - Search in title, excerpt, content
- `sort` (string, default: created_at) - Sort field (created_at, title, views, updated_at)
- `order` (string, default: DESC) - ASC or DESC

### 2. Get Single Blog Post

```bash
GET /api/blog/post/my-blog-post-slug
```

**Notes:**
- Automatically increments view count
- Includes related posts info

### 3. Get Blog Categories

```bash
GET /api/blog/categories
```

**Returns:** All active categories with post count

### 4. Get Featured Posts

```bash
GET /api/blog/featured?limit=5
```

**Parameters:**
- `limit` (int, default: 5) - Number of featured posts

### 5. Get Related Posts

```bash
GET /api/blog/related/123?limit=4
```

**Parameters:**
- `limit` (int, default: 4) - Number of related posts
- URL: `123` is the post ID

### 6. Increment View Count

```bash
POST /api/blog/post/123/view
```

**Returns:** Updated view count

## Database Schema

### Tables Created:

1. **tbl_blog_posts** - Main blog posts
   - Fields: id, title, slug, excerpt, content, featured_image, category_id, author_id, featured, status, views, meta_title, meta_description, meta_keywords, publish_date, created_at, updated_at

2. **tbl_blog_categories** - Blog categories
   - Fields: id, name, slug, description, color, icon, status, display_order, created_at, updated_at

3. **tbl_blog_authors** - Blog authors
   - Fields: id, name, email, avatar, bio, social_links, status, created_at, updated_at

4. **tbl_blog_post_tags** - Blog post tags
   - Fields: id, post_id, tag, created_at

5. **tbl_blog_comments** - Blog comments (for future use)
   - Fields: id, post_id, user_id, name, email, content, status, created_at, updated_at

## Sample Data

The migration includes sample data:
- 1 default author (Admin)
- 4 default categories (Learning Tips, Quiz News, Featured, Tutorials)

## Frontend Integration

The React frontend is already set up to use these endpoints:

**File:** `website/src/api/blog.ts`

All service functions are ready to call the backend:
- `getBlogPosts()`
- `getBlogPost()`
- `getBlogCategories()`
- `getFeaturedPosts()`
- `getRelatedPosts()`
- `incrementPostViews()`

## Testing the API

### Using Postman or Insomnia:

1. **Get All Posts**
   - URL: `http://your-domain.com/admin_backend/api/blog/posts`
   - Method: GET
   - Expected: List of posts with pagination

2. **Get Single Post**
   - URL: `http://your-domain.com/admin_backend/api/blog/post/learning-tips`
   - Method: GET
   - Expected: Single post object

3. **Get Categories**
   - URL: `http://your-domain.com/admin_backend/api/blog/categories`
   - Method: GET
   - Expected: Array of categories

## Troubleshooting

### No database access?
- Verify MySQL credentials in `admin_backend/application/config/database.php`
- Ensure the database user has CREATE TABLE privileges
- Check if the database exists

### Tables not created?
- Run migration manually using PHPMyAdmin
- Copy SQL from `001_create_blog_tables.sql`
- Execute in PHPMyAdmin SQL tab

### API endpoints not responding?
- Verify routes are added to `routes.php`
- Check that `Blog_model.php` is in `application/models/`
- Verify blog methods are added to `Api.php`
- Check CodeIgniter error logs

### Frontend not connecting?
- Verify API base URL in `website/src/api/client.ts`
- Check CORS headers if needed
- Ensure backend is running

## Files Modified/Created

### Created:
- ✅ `admin_backend/application/models/Blog_model.php` - Blog data model
- ✅ `admin_backend/database/migrations/001_create_blog_tables.sql` - Database schema
- ✅ `admin_backend/run_migration.php` - Migration runner script

### Modified:
- ✅ `admin_backend/application/controllers/Api.php` - Added 6 blog endpoints
- ✅ `admin_backend/application/config/routes.php` - Added blog routes

## Next Phase: Admin Panel

After database setup is complete, you may want to create admin interfaces for:
1. Blog post management (create, edit, delete)
2. Category management
3. Author management
4. Blog statistics dashboard
5. Featured posts configuration

These would require additional CRUD endpoints and admin panel views.

## Support

For issues or questions:
1. Check the error logs in `admin_backend/application/logs/`
2. Verify all files are in correct locations
3. Ensure database user has proper permissions
4. Check CodeIgniter configuration

---

**Status:** ✅ Backend API Implementation Complete
**Ready for:** Database table creation and testing
