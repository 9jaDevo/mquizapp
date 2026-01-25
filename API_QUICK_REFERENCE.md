# Blog API Quick Reference

## Endpoints Overview

### 1️⃣ Get All Blog Posts
```
GET /api/blog/posts
```

**Parameters:**
- `page` (int, default: 1) - Page number
- `limit` (int, default: 10) - Items per page
- `search` (string) - Search in title/excerpt/content
- `category` (string) - Filter by category slug
- `sort` (string, default: created_at) - Sort by: created_at, title, views, updated_at
- `order` (string, default: DESC) - ASC or DESC

**Example:**
```
GET /api/blog/posts?page=1&limit=10&category=learning-tips&search=tips&sort=views&order=DESC
```

**Response:**
```json
{
  "error": false,
  "message": "Blog posts retrieved successfully",
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

---

### 2️⃣ Get Single Blog Post
```
GET /api/blog/post/{slug}
```

**Example:**
```
GET /api/blog/post/getting-started-with-mquiz
```

**Note:** Automatically increments view count when fetched

**Response:**
```json
{
  "error": false,
  "message": "Blog post retrieved successfully",
  "data": {
    "post": {
      "id": 1,
      "title": "Getting Started with mQuiz",
      "slug": "getting-started-with-mquiz",
      "excerpt": "Learn how to get started...",
      "content": "<p>Full HTML content...</p>",
      "featured_image": "https://...",
      "author": {
        "id": 1,
        "name": "Admin",
        "avatar": "https://...",
        "bio": "mQuiz Administrator"
      },
      "category": {
        "id": 1,
        "name": "Learning Tips",
        "slug": "learning-tips"
      },
      "tags": ["tip", "tutorial"],
      "reading_time": 5,
      "views": 142,
      "created_at": "2024-01-20 10:00:00",
      "updated_at": "2024-01-20 10:00:00",
      "meta_title": "Getting Started - mQuiz",
      "meta_description": "Learn to use mQuiz...",
      "meta_keywords": "mquiz, learning, tips"
    }
  }
}
```

---

### 3️⃣ Get All Categories
```
GET /api/blog/categories
```

**Example:**
```
GET /api/blog/categories
```

**Response:**
```json
{
  "error": false,
  "message": "Blog categories retrieved successfully",
  "data": {
    "categories": [
      {
        "id": 1,
        "name": "Learning Tips",
        "slug": "learning-tips",
        "description": "Tips and tricks for effective learning",
        "post_count": 12
      },
      {
        "id": 2,
        "name": "Quiz News",
        "slug": "quiz-news",
        "description": "Latest news from mQuiz",
        "post_count": 5
      }
    ]
  }
}
```

---

### 4️⃣ Get Featured Posts
```
GET /api/blog/featured
```

**Parameters:**
- `limit` (int, default: 5) - Number of featured posts

**Example:**
```
GET /api/blog/featured?limit=5
```

**Response:**
```json
{
  "error": false,
  "message": "Featured blog posts retrieved successfully",
  "data": {
    "posts": [...],
    "pagination": {
      "current_page": 1,
      "total_pages": 1,
      "total_posts": 3,
      "per_page": 5,
      "has_next": false,
      "has_prev": false
    }
  }
}
```

---

### 5️⃣ Get Related Posts
```
GET /api/blog/related/{id}
```

**Parameters:**
- `limit` (int, default: 4) - Number of related posts

**Example:**
```
GET /api/blog/related/1?limit=4
```

**Note:** Returns posts from the same category as the specified post

**Response:**
```json
{
  "error": false,
  "message": "Related blog posts retrieved successfully",
  "data": {
    "posts": [...],
    "pagination": {
      "current_page": 1,
      "total_pages": 1,
      "total_posts": 3,
      "per_page": 4,
      "has_next": false,
      "has_prev": false
    }
  }
}
```

---

### 6️⃣ Increment Post Views
```
POST /api/blog/post/{id}/view
```

**Example:**
```
POST /api/blog/post/1/view
```

**Request Body:** None required

**Response:**
```json
{
  "error": false,
  "message": "View count updated successfully",
  "data": {
    "views": 143
  }
}
```

---

## Error Responses

### 400 Bad Request
```json
{
  "error": true,
  "message": "Post slug is required",
  "data": []
}
```

### 404 Not Found
```json
{
  "error": true,
  "message": "Post not found",
  "data": []
}
```

### 500 Internal Server Error
```json
{
  "error": true,
  "message": "Failed to retrieve blog posts: Database connection error",
  "data": []
}
```

---

## Response Format Legend

| Field   | Type    | Description                           |
| ------- | ------- | ------------------------------------- |
| error   | boolean | `true` if error, `false` if success   |
| message | string  | Human-readable status message         |
| data    | object  | Response payload (varies by endpoint) |

---

## Common Use Cases

### 📱 Display Blog Homepage
```javascript
// Show 10 latest posts with pagination
const response = await fetch('/api/blog/posts?page=1&limit=10&sort=created_at&order=DESC');
const { data } = await response.json();
// Display data.posts and data.pagination
```

### 🔍 Search Blog
```javascript
// Search for posts matching query
const query = 'learning';
const response = await fetch(`/api/blog/posts?search=${query}&limit=10`);
const { data } = await response.json();
// Display search results in data.posts
```

### 📂 Filter by Category
```javascript
// Show posts from specific category
const response = await fetch('/api/blog/posts?category=learning-tips&limit=10');
const { data } = await response.json();
// Display filtered posts
```

### ⭐ Featured Section
```javascript
// Show 5 featured posts on homepage
const response = await fetch('/api/blog/featured?limit=5');
const { data } = await response.json();
// Display data.posts as featured carousel
```

### 📖 Single Post Page
```javascript
// Load post by slug and increment views
const slug = window.location.pathname.split('/').pop();
const response = await fetch(`/api/blog/post/${slug}`);
const { data } = await response.json();
const post = data.post;

// Display post.content
// Show post.author and post.category
// Show related posts if available
```

### 🔗 Related Posts
```javascript
// Show related posts in sidebar
const postId = 1;
const response = await fetch(`/api/blog/related/${postId}?limit=4`);
const { data } = await response.json();
// Display data.posts as related articles
```

---

## Testing with cURL

```bash
# Get all posts
curl -X GET "http://localhost/admin_backend/api/blog/posts"

# Get post by slug
curl -X GET "http://localhost/admin_backend/api/blog/post/getting-started-with-mquiz"

# Get categories
curl -X GET "http://localhost/admin_backend/api/blog/categories"

# Get featured posts
curl -X GET "http://localhost/admin_backend/api/blog/featured?limit=5"

# Get related posts
curl -X GET "http://localhost/admin_backend/api/blog/related/1?limit=4"

# Increment views
curl -X POST "http://localhost/admin_backend/api/blog/post/1/view"
```

---

## Testing with JavaScript/Fetch

```javascript
// Get all posts
fetch('/api/blog/posts')
  .then(r => r.json())
  .then(d => console.log(d.data.posts));

// Get single post
fetch('/api/blog/post/my-post-slug')
  .then(r => r.json())
  .then(d => console.log(d.data.post));

// Get categories
fetch('/api/blog/categories')
  .then(r => r.json())
  .then(d => console.log(d.data.categories));

// Increment views
fetch('/api/blog/post/1/view', { method: 'POST' })
  .then(r => r.json())
  .then(d => console.log('Views:', d.data.views));
```

---

## Frontend Integration

### React Hook Example
```typescript
import { useEffect, useState } from 'react';
import { getBlogPosts, getBlogPost, getBlogCategories } from '@/api/blog';

export default function BlogPage() {
  const [posts, setPosts] = useState([]);
  const [categories, setCategories] = useState([]);

  useEffect(() => {
    // Load posts and categories
    Promise.all([
      getBlogPosts({ page: 1, limit: 10 }),
      getBlogCategories()
    ]).then(([postsData, categoriesData]) => {
      setPosts(postsData.data.posts);
      setCategories(categoriesData.data.categories);
    });
  }, []);

  return (
    <div>
      <h1>Blog</h1>
      {posts.map(post => (
        <div key={post.id}>
          <h2>{post.title}</h2>
          <p>{post.excerpt}</p>
        </div>
      ))}
    </div>
  );
}
```

---

## Pagination Example

```javascript
// Get page 2 with 20 items per page
const page = 2;
const limit = 20;

fetch(`/api/blog/posts?page=${page}&limit=${limit}`)
  .then(r => r.json())
  .then(d => {
    const posts = d.data.posts;
    const { current_page, total_pages, has_next, has_prev } = d.data.pagination;
    
    console.log(`Page ${current_page} of ${total_pages}`);
    console.log(`Has next: ${has_next}`);
    console.log(`Has previous: ${has_prev}`);
  });
```

---

**Last Updated:** 2024-01-20
**Version:** 1.0.0
**Status:** Production Ready
