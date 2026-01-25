# Blog System Architecture

## System Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                        React Frontend                            │
│                   (website/src/pages/Blog.tsx)                   │
│                                                                   │
│  ┌────────────────────────────────────────────────────────────┐  │
│  │ Pages:                                                     │  │
│  │  • Blog.tsx - Blog listing with search/filter             │  │
│  │  • BlogPost.tsx - Single post page with sidebar            │  │
│  │                                                             │  │
│  │ Components:                                                │  │
│  │  • BlogCard.tsx - Post preview card                       │  │
│  │  • BlogSearch.tsx - Search/filter widget                  │  │
│  └────────────────────────────────────────────────────────────┘  │
└────────────────────────┬─────────────────────────────────────────┘
                         │
                HTTP Requests (Fetch/Axios)
                         │
                    /api/blog/*
                         │
┌────────────────────────▼─────────────────────────────────────────┐
│                  CodeIgniter 3.x Backend                          │
│              (admin_backend/application/)                         │
│                                                                   │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │ Controllers/Api.php                                      │   │
│  │  • blog_posts_get()        → Get all posts              │   │
│  │  • blog_post_get()         → Get single post            │   │
│  │  • blog_categories_get()   → Get categories             │   │
│  │  • blog_featured_get()     → Get featured posts         │   │
│  │  • blog_related_get()      → Get related posts          │   │
│  │  • blog_view_post()        → Increment views            │   │
│  └────────────────────┬────────────────────────────────────┘   │
│                       │                                          │
│                  Uses/Calls                                      │
│                       │                                          │
│  ┌────────────────────▼────────────────────────────────────┐   │
│  │ Models/Blog_model.php                                  │   │
│  │  • get_posts() - Pagination, search, filter            │   │
│  │  • get_post_by_slug() - Single post retrieval          │   │
│  │  • get_featured_posts() - Featured filtering           │   │
│  │  • get_related_posts() - Category-based related        │   │
│  │  • get_categories() - All categories                   │   │
│  │  • increment_views() - View tracking                   │   │
│  │  • format_post() - Response formatting                 │   │
│  └────────────────────┬────────────────────────────────────┘   │
│                       │                                          │
│                Database Queries (CodeIgniter Query Builder)     │
│                       │                                          │
└────────────────────────┬─────────────────────────────────────────┘
                         │
                 MySQLi/MySQL Driver
                         │
┌────────────────────────▼─────────────────────────────────────────┐
│                      MySQL Database                               │
│                    (mquiz_app database)                           │
│                                                                   │
│  ┌────────────────────────────────────────────────────────────┐  │
│  │ Tables:                                                    │  │
│  │  • tbl_blog_posts       - Main posts (18 fields)          │  │
│  │  • tbl_blog_categories  - Categories (9 fields)           │  │
│  │  • tbl_blog_authors     - Authors (9 fields)              │  │
│  │  • tbl_blog_post_tags   - Tags mapping (4 fields)        │  │
│  │  • tbl_blog_comments    - Comments (9 fields, future)    │  │
│  └────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Data Flow Diagram

### 1. Get Blog Posts Flow

```
┌─────────────────────┐
│   React Frontend    │
│  (Blog.tsx page)    │
└──────────┬──────────┘
           │
           │ await getBlogPosts({ page: 1, limit: 10 })
           │ GET /api/blog/posts?page=1&limit=10
           │
┌──────────▼──────────┐
│  CodeIgniter Router │
│  routes.php         │
└──────────┬──────────┘
           │
           │ Matches: 'api/blog/posts' → 'Api/blog_posts_get'
           │
┌──────────▼──────────┐
│ Api.php Controller  │
│ blog_posts_get()    │
└──────────┬──────────┘
           │
           │ Load Blog_model
           │ Get parameters: page, limit, search, category, sort
           │
┌──────────▼──────────┐
│ Blog_model.php      │
│ get_posts()         │
└──────────┬──────────┘
           │
           │ Query Database with CodeIgniter Query Builder:
           │ - SELECT posts with category & author joins
           │ - WHERE status = 'published'
           │ - Optional: LIKE search, category filter
           │ - LIMIT and OFFSET for pagination
           │
┌──────────▼──────────┐
│  MySQL Database     │
│ tbl_blog_posts      │
│ [execute query]     │
└──────────┬──────────┘
           │
           │ Return: Array of posts
           │
┌──────────▼──────────┐
│ Blog_model.php      │
│ format_post()       │
│ [format each post]  │
└──────────┬──────────┘
           │
           │ Return: Formatted posts array
           │
┌──────────▼──────────┐
│ Api.php Controller  │
│ build response      │
│ $this->response()   │
└──────────┬──────────┘
           │
           │ Return JSON:
           │ {
           │   "error": false,
           │   "message": "...",
           │   "data": {
           │     "posts": [...],
           │     "pagination": {...}
           │   }
           │ }
           │
┌──────────▼──────────┐
│  React Frontend     │
│  Update state       │
│  Re-render page     │
└─────────────────────┘
```

### 2. Get Single Post Flow

```
┌──────────────────────────┐
│  React Frontend          │
│  BlogPost.tsx page       │
│  slug = "post-slug"      │
└────────────┬─────────────┘
             │
             │ await getBlogPost(slug)
             │ GET /api/blog/post/post-slug
             │
┌────────────▼──────────┐
│ CodeIgniter Router    │
│ Routes.php            │
└────────────┬──────────┘
             │
             │ Matches: 'api/blog/post/(:any)' → 'Api/blog_post_get/{slug}'
             │
┌────────────▼──────────┐
│ Api.php Controller    │
│ blog_post_get()       │
│ Extract slug from URI │
└────────────┬──────────┘
             │
             │ Load Blog_model
             │
┌────────────▼──────────┐
│ Blog_model.php        │
│ get_post_by_slug()    │
└────────────┬──────────┘
             │
             │ Query Database:
             │ SELECT post WHERE slug = ? AND status = 'published'
             │ JOIN with category and author
             │
┌────────────▼──────────┐
│  MySQL Database       │
│ tbl_blog_posts        │
│ tbl_blog_categories   │
│ tbl_blog_authors      │
│ [execute query]       │
└────────────┬──────────┘
             │
             │ Return: Post data
             │
┌────────────▼──────────┐
│ Api.php Controller    │
│ Increment views       │
│ Call increment_views()│
└────────────┬──────────┘
             │
             │ Update: views = views + 1
             │ in tbl_blog_posts
             │
┌────────────▼──────────┐
│ Blog_model.php        │
│ format_post()         │
│ Get tags              │
│ Get related posts     │
│ Calculate reading time│
└────────────┬──────────┘
             │
             │ Return: Formatted post object
             │
┌────────────▼──────────┐
│ Api.php Controller    │
│ build response        │
│ $this->response()     │
└────────────┬──────────┘
             │
             │ Return JSON with post data
             │
┌────────────▼──────────┐
│  React Frontend       │
│  Update state         │
│  Display full post    │
│  Show related posts   │
│  Show author info     │
└──────────────────────┘
```

---

## Database Relationship Diagram

```
tbl_blog_posts
├── id (PK)
├── title
├── slug (UNIQUE)
├── excerpt
├── content
├── featured_image
├── category_id (FK → tbl_blog_categories)
├── author_id (FK → tbl_blog_authors)
├── featured (boolean)
├── status (draft/published/archived)
├── views (int)
├── meta_title
├── meta_description
├── meta_keywords
├── publish_date
├── created_at
└── updated_at

tbl_blog_categories
├── id (PK)
├── name
├── slug (UNIQUE)
├── description
├── color
├── icon
├── status (active/inactive)
├── display_order
├── created_at
└── updated_at
     ↑
     └── Referenced by tbl_blog_posts.category_id

tbl_blog_authors
├── id (PK)
├── name
├── email (UNIQUE)
├── avatar (URL)
├── bio
├── social_links (JSON)
├── status (active/inactive)
├── created_at
└── updated_at
     ↑
     └── Referenced by tbl_blog_posts.author_id

tbl_blog_post_tags
├── id (PK)
├── post_id (FK → tbl_blog_posts, CASCADE)
├── tag (string)
└── created_at
     ↑
     └── Linked to tbl_blog_posts.id

tbl_blog_comments (Future use)
├── id (PK)
├── post_id (FK → tbl_blog_posts, CASCADE)
├── user_id (nullable)
├── name
├── email
├── content
├── status (pending/approved/spam)
├── created_at
└── updated_at
```

---

## Request/Response Cycle

```
┌─────────────────────────────────────────────────────────────┐
│                     HTTP Request                             │
│  GET /api/blog/posts?page=1&limit=10&category=learning-tips │
└────────────────────┬────────────────────────────────────────┘
                     │
           ┌─────────▼──────────┐
           │  Parse Request     │
           │  Extract params:   │
           │  • page = 1        │
           │  • limit = 10      │
           │  • category = ...  │
           └─────────┬──────────┘
                     │
           ┌─────────▼──────────┐
           │ Load Blog_model    │
           │ Execute get_posts()│
           └─────────┬──────────┘
                     │
           ┌─────────▼──────────┐
           │ Query Database     │
           │ Calculate OFFSET   │
           │ Build WHERE clause │
           │ Execute SELECT     │
           └─────────┬──────────┘
                     │
           ┌─────────▼──────────┐
           │ Format Results     │
           │ • Format each post │
           │ • Get post tags    │
           │ • Calculate read   │
           │   time             │
           └─────────┬──────────┘
                     │
           ┌─────────▼──────────┐
           │ Build Response     │
           │ {                  │
           │   error: false,    │
           │   message: "...",  │
           │   data: {          │
           │     posts: [...],  │
           │     pagination: {} │
           │   }                │
           │ }                  │
           └─────────┬──────────┘
                     │
┌────────────────────▼────────────────────────────────────────┐
│                  HTTP Response (JSON)                        │
│                   Status Code: 200 OK                        │
└─────────────────────────────────────────────────────────────┘
```

---

## API Endpoint Routing

```
CodeIgniter Router (routes.php)
│
├─ GET /api/blog/posts
│  └─ Api::blog_posts_get()
│
├─ GET /api/blog/post/{slug}
│  └─ Api::blog_post_get()
│
├─ GET /api/blog/categories
│  └─ Api::blog_categories_get()
│
├─ GET /api/blog/featured
│  └─ Api::blog_featured_get()
│
├─ GET /api/blog/related/{id}
│  └─ Api::blog_related_get()
│
└─ POST /api/blog/post/{id}/view
   └─ Api::blog_view_post()
```

---

## Error Handling Flow

```
┌─────────────────────┐
│   API Request       │
└────────────┬────────┘
             │
     ┌───────▼────────┐
     │ Validate Input │
     └───────┬────────┘
             │
      ┌──────▼─────┐
      │ Valid?      │
      └──┬────────┬─┘
         │        │
      YES│        │NO
         │        └──────────────────┐
    ┌────▼─────┐                     │
    │ Execute  │         ┌───────────▼──────┐
    │ Database │         │ Return Error     │
    │ Query    │         │ error: true      │
    └────┬─────┘         │ data: []         │
         │               └──────────────────┘
    ┌────▼─────┐
    │ Success? │
    └──┬────┬──┘
       │    │
    YES│    │NO
       │    └──────────────────┐
   ┌───▼───┐                   │
   │Format │         ┌─────────▼──────┐
   │Result │         │ Return Error   │
   └───┬───┘         │ error: true    │
       │             │ message: ...   │
   ┌───▼────────┐    │ data: []       │
   │Return JSON │    └────────────────┘
   │error:false │
   │data: {...} │
   └────────────┘
```

---

## File Structure

```
mquizapp/
├── website/
│   └── src/
│       ├── api/
│       │   └── blog.ts (API client)
│       ├── pages/
│       │   ├── Blog.tsx (Listing page)
│       │   └── BlogPost.tsx (Detail page)
│       └── components/
│           └── blog/
│               ├── BlogCard.tsx
│               └── BlogSearch.tsx
│
└── admin_backend/
    ├── application/
    │   ├── controllers/
    │   │   └── Api.php (API endpoints)
    │   ├── models/
    │   │   └── Blog_model.php (Business logic)
    │   └── config/
    │       └── routes.php (Routing)
    │
    ├── database/
    │   └── migrations/
    │       └── 001_create_blog_tables.sql
    │
    └── run_migration.php (Migration tool)
```

---

**Architecture Version:** 1.0
**Last Updated:** 2024-01-20
**Status:** Production Ready
