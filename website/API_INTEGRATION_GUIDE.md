# Blog API Endpoints Documentation

## Overview
The React frontend will fetch blog posts from the existing PHP admin backend. This document outlines the API endpoints that need to be created in the admin_backend.

## Base URL
Configure in React `.env` file:
```
VITE_API_BASE_URL=https://yourdomain.com/admin_backend
```

## Required Endpoints

### 1. Get All Blog Posts (with Pagination & Filters)
```
GET /api/blog/posts
```

**Query Parameters:**
- `page` (optional, default: 1) - Page number
- `limit` (optional, default: 10) - Posts per page
- `category` (optional) - Filter by category ID
- `search` (optional) - Search query for title/content
- `sort` (optional, default: 'created_at') - Sort field
- `order` (optional, default: 'DESC') - Sort order

**Response:**
```json
{
  "success": true,
  "data": {
    "posts": [
      {
        "id": 1,
        "title": "How to Earn Money with mQuiz",
        "slug": "how-to-earn-money-with-mquiz",
        "excerpt": "Learn the best strategies to maximize your earnings...",
        "content": "<p>Full HTML content...</p>",
        "featured_image": "https://yourdomain.com/images/blog/post-1.jpg",
        "author": {
          "id": 1,
          "name": "Admin",
          "avatar": "https://yourdomain.com/images/profile/admin.jpg",
          "bio": "mQuiz content creator"
        },
        "category": {
          "id": 1,
          "name": "Tutorials",
          "slug": "tutorials"
        },
        "tags": ["earning", "guide", "tips"],
        "reading_time": 5,
        "views": 1234,
        "created_at": "2026-01-15T10:30:00Z",
        "updated_at": "2026-01-15T10:30:00Z",
        "meta_title": "SEO optimized title",
        "meta_description": "SEO optimized description",
        "meta_keywords": "mquiz, earn, tutorial"
      }
    ],
    "pagination": {
      "current_page": 1,
      "total_pages": 5,
      "total_posts": 47,
      "per_page": 10,
      "has_next": true,
      "has_prev": false
    }
  }
}
```

### 2. Get Single Blog Post
```
GET /api/blog/post/:slug
```

**URL Parameters:**
- `slug` - Post slug (e.g., "how-to-earn-money-with-mquiz")

**Response:**
```json
{
  "success": true,
  "data": {
    "post": {
      "id": 1,
      "title": "How to Earn Money with mQuiz",
      "slug": "how-to-earn-money-with-mquiz",
      "content": "<p>Full HTML content with proper formatting...</p>",
      "excerpt": "Short description...",
      "featured_image": "https://yourdomain.com/images/blog/post-1.jpg",
      "author": {
        "id": 1,
        "name": "Admin",
        "avatar": "https://yourdomain.com/images/profile/admin.jpg",
        "bio": "mQuiz content creator and educator"
      },
      "category": {
        "id": 1,
        "name": "Tutorials",
        "slug": "tutorials"
      },
      "tags": ["earning", "guide", "tips"],
      "views": 1234,
      "created_at": "2026-01-15T10:30:00Z",
      "updated_at": "2026-01-15T10:30:00Z",
      "meta_title": "How to Earn Money with mQuiz - Complete Guide",
      "meta_description": "Discover proven strategies to earn real money...",
      "meta_keywords": "mquiz, earn money, tutorial, guide"
    }
  }
}
```

### 3. Get Blog Categories
```
GET /api/blog/categories
```

**Response:**
```json
{
  "success": true,
  "data": {
    "categories": [
      {
        "id": 1,
        "name": "Tutorials",
        "slug": "tutorials",
        "description": "Step-by-step guides and tutorials",
        "post_count": 15
      },
      {
        "id": 2,
        "name": "Tips & Tricks",
        "slug": "tips-tricks",
        "description": "Expert tips for better learning",
        "post_count": 12
      }
    ]
  }
}
```

### 4. Get Featured Posts
```
GET /api/blog/featured?limit=5
```

**Query Parameters:**
- `limit` (optional, default: 5) - Number of featured posts

**Response:**
```json
{
  "success": true,
  "data": {
    "posts": [
      {
        "id": 1,
        "title": "How to Earn Money with mQuiz",
        "slug": "how-to-earn-money-with-mquiz",
        "excerpt": "Learn the best strategies...",
        "featured_image": "https://yourdomain.com/images/blog/post-1.jpg",
        "category": {
          "id": 1,
          "name": "Tutorials"
        },
        "created_at": "2026-01-15T10:30:00Z"
      }
    ]
  }
}
```

### 5. Get Related Posts
```
GET /api/blog/related/:id?limit=4
```

**URL Parameters:**
- `id` - Current post ID

**Query Parameters:**
- `limit` (optional, default: 4) - Number of related posts

**Response:**
```json
{
  "success": true,
  "data": {
    "posts": [
      {
        "id": 5,
        "title": "10 Study Tips for mQuiz",
        "slug": "study-tips-for-mquiz",
        "excerpt": "Maximize your learning...",
        "featured_image": "https://yourdomain.com/images/blog/post-5.jpg",
        "category": {
          "id": 1,
          "name": "Tutorials"
        },
        "created_at": "2026-01-10T14:20:00Z"
      }
    ]
  }
}
```

### 6. Increment Post Views
```
POST /api/blog/post/:id/view
```

**URL Parameters:**
- `id` - Post ID

**Response:**
```json
{
  "success": true,
  "data": {
    "views": 1235
  }
}
```

## Database Schema Suggestion

### Table: `blog_posts`
```sql
CREATE TABLE `blog_posts` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `title` VARCHAR(255) NOT NULL,
  `slug` VARCHAR(255) NOT NULL UNIQUE,
  `content` LONGTEXT NOT NULL,
  `excerpt` TEXT,
  `featured_image` VARCHAR(500),
  `author_id` INT,
  `category_id` INT,
  `status` ENUM('draft', 'published') DEFAULT 'draft',
  `is_featured` TINYINT(1) DEFAULT 0,
  `views` INT DEFAULT 0,
  `meta_title` VARCHAR(255),
  `meta_description` TEXT,
  `meta_keywords` VARCHAR(500),
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX `idx_slug` (`slug`),
  INDEX `idx_status` (`status`),
  INDEX `idx_category` (`category_id`),
  INDEX `idx_featured` (`is_featured`)
);
```

### Table: `blog_categories`
```sql
CREATE TABLE `blog_categories` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(100) NOT NULL,
  `slug` VARCHAR(100) NOT NULL UNIQUE,
  `description` TEXT,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Table: `blog_tags`
```sql
CREATE TABLE `blog_tags` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(100) NOT NULL,
  `slug` VARCHAR(100) NOT NULL UNIQUE
);
```

### Table: `blog_post_tags` (Many-to-Many)
```sql
CREATE TABLE `blog_post_tags` (
  `post_id` INT,
  `tag_id` INT,
  PRIMARY KEY (`post_id`, `tag_id`),
  FOREIGN KEY (`post_id`) REFERENCES `blog_posts`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`tag_id`) REFERENCES `blog_tags`(`id`) ON DELETE CASCADE
);
```

## Implementation Notes

### PHP CodeIgniter Controller Example
Create `application/controllers/api/Blog.php`:

```php
<?php
defined('BASEPATH') OR exit('No direct script access allowed');

require APPPATH . 'libraries/REST_Controller.php';

class Blog extends REST_Controller {
    
    public function __construct() {
        parent::__construct();
        $this->load->model('Blog_model');
    }
    
    public function posts_get() {
        $page = $this->get('page') ?: 1;
        $limit = $this->get('limit') ?: 10;
        $category = $this->get('category');
        $search = $this->get('search');
        
        $result = $this->Blog_model->get_posts($page, $limit, $category, $search);
        
        $this->response([
            'success' => true,
            'data' => $result
        ], REST_Controller::HTTP_OK);
    }
    
    public function post_get($slug) {
        $post = $this->Blog_model->get_post_by_slug($slug);
        
        if (!$post) {
            $this->response([
                'success' => false,
                'message' => 'Post not found'
            ], REST_Controller::HTTP_NOT_FOUND);
            return;
        }
        
        $this->response([
            'success' => true,
            'data' => ['post' => $post]
        ], REST_Controller::HTTP_OK);
    }
    
    // Add other methods...
}
```

### CORS Headers
Ensure CORS is enabled in your PHP backend:

```php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');
```

## Frontend Integration

### Environment Variables (.env)
```
VITE_API_BASE_URL=https://yourdomain.com/admin_backend
VITE_API_TIMEOUT=10000
```

### API Client (src/api/client.ts)
```typescript
import axios from 'axios';

const apiClient = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL,
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json',
  },
});

export default apiClient;
```

### Blog API Service (src/api/blog.ts)
```typescript
import apiClient from './client';

export const getBlogPosts = async (params: {
  page?: number;
  limit?: number;
  category?: string;
  search?: string;
}) => {
  const response = await apiClient.get('/api/blog/posts', { params });
  return response.data;
};

export const getBlogPost = async (slug: string) => {
  const response = await apiClient.get(`/api/blog/post/${slug}`);
  return response.data;
};

// Add other functions...
```

## Testing
Test endpoints using tools like:
- Postman
- cURL
- Browser (for GET requests)

Example cURL:
```bash
curl https://yourdomain.com/admin_backend/api/blog/posts?page=1&limit=10
```

## Security Considerations
1. Sanitize HTML content before storing
2. Validate and escape user inputs
3. Use prepared statements to prevent SQL injection
4. Rate limiting on API endpoints
5. Optional: Implement API key authentication for write operations

## Next Steps
1. Create the database tables
2. Implement the API endpoints in PHP
3. Test all endpoints
4. Update React frontend to consume the API
5. Deploy both backend and frontend
