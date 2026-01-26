# Blog Management System - User Guide

## Overview
The blog management system is now fully production-ready with complete CRUD (Create, Read, Update, Delete) functionality for posts, categories, authors, and SEO analytics tracking.

## Features Implemented

### 1. Blog Posts Management (`/blog-posts`)
- **Create Posts**: Rich text editor with WYSIWYG capabilities
- **Edit Posts**: Modify existing posts with all fields editable
- **Delete Posts**: Remove posts with cascade deletion of related data
- **Image Upload**: Featured image upload with automatic storage
- **Auto-generated Slugs**: URL-friendly slugs created from titles
- **Status Management**: Draft, Published, and Archived status
- **Featured Posts**: Mark posts as featured for homepage display
- **Tags System**: Add comma-separated tags to posts
- **Categories & Authors**: Dropdown selection from available data
- **SEO Fields**: 
  - Meta Title (auto-uses post title if empty)
  - Meta Description (auto-generated from content if empty)
  - Meta Keywords (auto-generated using AI keyword extraction if empty)

### 2. Categories Management (`/blog-categories`)
- Create, edit, and delete blog categories
- Auto-generated slugs from category names
- Category descriptions
- Active/Inactive status toggle
- Post count tracking per category

### 3. Authors Management (`/blog-authors`)
- Create and manage blog authors
- Author profiles with:
  - Name and email (unique)
  - Avatar URL
  - Bio
  - Social media links (Twitter, LinkedIn, GitHub, Website)
  - Active/Inactive status
  
### 4. SEO Analytics Dashboard (`/blog-seo-analytics`)
- **Summary Cards**:
  - Total AI Bot Hits
  - Total Human Views
  - Auto-Generated Keywords count
  - Average Time on Page
  
- **Charts**:
  - Bot vs Human Traffic (Doughnut chart)
  - Keyword Generation Sources (Pie chart)
  
- **Detailed Analytics Table**:
  - Post-level metrics
  - Keyword source tracking
  - Bot hits vs human views comparison
  - Average time on page per post
  
- **Top Performing Posts**:
  - Top 5 posts by Bot Hits
  - Top 5 posts by Human Views
  
- **Auto-refresh**: Dashboard updates every 30 seconds

## How to Use

### Initial Setup

#### 1. Run Database Migrations
Execute these SQL files in order via phpMyAdmin or MySQL CLI:

```bash
# Navigate to database migrations folder
cd admin_backend/database/migrations

# Run in MySQL (replace credentials)
mysql -u your_username -p your_database < 001_create_blog_tables.sql
mysql -u your_username -p your_database < 002_add_seo_analytics.sql
```

Or via phpMyAdmin:
1. Login to phpMyAdmin
2. Select your database
3. Click "SQL" tab
4. Copy and paste content from `001_create_blog_tables.sql`
5. Click "Go"
6. Repeat for `002_add_seo_analytics.sql`

#### 2. Create Upload Directory
Ensure the blog image upload directory exists with write permissions:

```bash
mkdir -p admin_backend/upload/blog
chmod 777 admin_backend/upload/blog  # Linux/Mac
```

For Windows (via File Explorer):
- Create folder: `admin_backend\upload\blog`
- Right-click → Properties → Security → Edit → Give "Full Control" to "Users"

#### 3. Verify SEO Helper
The SEO helper file should exist at:
`admin_backend/application/helpers/seo_helper.php`

This file contains:
- `generate_keywords()` - Auto keyword extraction
- `auto_meta_description()` - Auto description generation
- `log_seo_activity()` - SEO analytics logging

### Using the Blog System

#### Creating Your First Blog Post

1. **Login to Admin Panel**
   - Navigate to `https://app.mquiz.uk/admin_backend`
   - Login with admin credentials

2. **Create a Category**
   - Click "Blog Management" → "Categories"
   - Click "+ Add Category" button
   - Fill in:
     - Name: e.g., "Technology"
     - Description: Brief description of category
     - Status: Active
   - Click "Create Category"

3. **Create an Author**
   - Click "Blog Management" → "Authors"
   - Click "+ Add Author" button
   - Fill in:
     - Name: Author's full name
     - Email: Unique email address
     - Avatar URL: Link to author image (optional)
     - Bio: Author biography
     - Social Links: Twitter, LinkedIn, etc. (optional)
   - Click "Create Author"

4. **Create a Blog Post**
   - Click "Blog Management" → "All Posts" or "Create Post"
   - Click "+ Create New Post" button
   - **Required Fields**:
     - Title: Post title (slug auto-generated)
     - Content: Main post content (use rich text editor)
     - Category: Select from dropdown
     - Author: Select from dropdown
   
   - **Optional Fields**:
     - Excerpt: Short summary
     - Featured Image: Upload image (JPG, PNG, GIF, WEBP, max 5MB)
     - Status: Draft/Published/Archived
     - Featured: Check to mark as featured post
     - Tags: Comma-separated (e.g., "web, tutorial, beginner")
   
   - **SEO Fields** (auto-filled if left empty):
     - Meta Title: Page title for search engines
     - Meta Description: Search result snippet
     - Meta Keywords: Keywords for SEO ranking
   
   - Click "Create Post"

#### Editing Posts

1. Navigate to "Blog Management" → "All Posts"
2. Click the **blue edit icon** (pencil) on the post you want to edit
3. Modify any fields in the modal
4. Click "Update Post"

#### Deleting Posts

1. Navigate to "Blog Management" → "All Posts"
2. Click the **red delete icon** (trash) on the post
3. Confirm deletion in the alert dialog
4. Post and related tags are permanently removed

#### Managing Categories and Authors

**Categories**:
- Edit: Click blue pencil icon
- Delete: Click red trash icon
- Note: Deleting a category will not delete posts, but posts will lose category association

**Authors**:
- Edit: Click blue pencil icon
- Delete: Click red trash icon
- Note: Deleting an author will not delete their posts

### Viewing SEO Analytics

1. Navigate to "Blog Management" → "SEO Analytics"
2. View summary metrics at the top
3. Analyze charts for traffic patterns
4. Review detailed table for per-post analytics
5. Check top-performing posts sections
6. Dashboard auto-refreshes every 30 seconds

### Understanding Keyword Generation

**Auto-Generated Keywords** (keyword_source: 'auto'):
- Triggered when Meta Keywords field is left empty
- Uses `generate_keywords()` from seo_helper.php
- Extracts meaningful keywords from post content and title
- Stored in `tbl_blog_seo_analytics.keywords_generated`

**Editor Keywords** (keyword_source: 'editor'):
- Triggered when you manually enter keywords
- Gives you full control over SEO keywords
- Useful for targeting specific search terms

### API Endpoints (For Frontend Integration)

All API endpoints are accessible via:
- Base URL: `https://app.mquiz.uk/index.php/api/blog/`

**Available Endpoints**:
```
GET  /api/blog/posts                  - Get all published posts
GET  /api/blog/post/{slug}            - Get single post by slug
GET  /api/blog/categories             - Get all active categories
GET  /api/blog/featured               - Get featured posts
GET  /api/blog/related/{post_id}      - Get related posts
POST /api/blog/post/{post_id}/view    - Log post view (increments view count)
```

**Example Frontend Usage**:
```javascript
// Fetch all blog posts
const response = await fetch('https://app.mquiz.uk/index.php/api/blog/posts');
const data = await response.json();
console.log(data.posts); // Array of blog posts

// Fetch single post
const post = await fetch('https://app.mquiz.uk/index.php/api/blog/post/my-post-slug');
const postData = await post.json();
console.log(postData); // Single post object
```

## Permissions

The blog system uses the admin panel's permission system:
- `read`, `blog` - View blog management pages
- `create`, `blog` - Create new posts/categories/authors
- `update`, `blog` - Edit existing posts/categories/authors
- `delete`, `blog` - Delete posts/categories/authors

**To grant blog permissions**:
1. Go to "User Accounts & Rights"
2. Select user role
3. Add "blog" module with appropriate CRUD permissions

## Troubleshooting

### Issue: "Permission denied" when accessing blog menu
**Solution**: Grant blog permissions to your user role in User Accounts & Rights

### Issue: CKEditor not loading (plain textarea shown)
**Solution**: Ensure CKEditor library is loaded in admin panel:
```html
<script src="//cdn.ckeditor.com/4.16.2/full/ckeditor.js"></script>
```
Add to `admin_backend/application/views/footer.php` if missing

### Issue: Image upload fails
**Solution**: 
1. Check upload directory exists: `admin_backend/upload/blog/`
2. Verify directory has write permissions (chmod 777 on Linux)
3. Check file size is under 5MB
4. Ensure file type is JPG, PNG, GIF, or WEBP

### Issue: SEO analytics not updating
**Solution**:
1. Verify `002_add_seo_analytics.sql` migration was executed
2. Check that `seo_helper.php` functions are loaded
3. Ensure foreign key constraint matches (post_id INT not UNSIGNED)

### Issue: Categories/Authors dropdown empty
**Solution**: Create at least one category and one author before creating posts

### Issue: Bootstrap Table not loading data
**Solution**: 
1. Check browser console for JavaScript errors
2. Verify jQuery and Bootstrap Table libraries are loaded
3. Ensure API route is accessible (test in browser)

## Advanced Features

### Custom Keyword Generation
Edit `admin_backend/application/helpers/seo_helper.php` to customize keyword extraction:
```php
function generate_keywords($content, $title, $count = 10) {
    // Customize your keyword extraction logic here
    // Current implementation uses word frequency analysis
}
```

### Extending SEO Analytics
Add custom metrics to `tbl_blog_seo_analytics`:
```sql
ALTER TABLE tbl_blog_seo_analytics 
ADD COLUMN bounce_rate DECIMAL(5,2) DEFAULT 0.00,
ADD COLUMN click_through_rate DECIMAL(5,2) DEFAULT 0.00;
```

Then update `Blog.php` controller and views accordingly.

### Adding Rich Snippets
The system supports schema.org structured data. Frontend should include:
```html
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "BlogPosting",
  "headline": "<?= $post['title'] ?>",
  "datePublished": "<?= $post['publish_date'] ?>",
  "author": {
    "@type": "Person",
    "name": "<?= $post['author_name'] ?>"
  }
}
</script>
```

## Next Steps

1. **Deploy Frontend** - Upload built React app to `web.mquiz.uk`
2. **Test API Integration** - Verify frontend can fetch blog posts
3. **Create Content** - Start publishing blog posts
4. **Monitor Analytics** - Track SEO performance in dashboard
5. **Optimize** - Use analytics to improve keyword targeting

## File Structure

```
admin_backend/
├── application/
│   ├── controllers/
│   │   └── Blog.php                    # Main blog controller
│   ├── views/
│   │   ├── blog/
│   │   │   ├── posts.php               # Posts management view
│   │   │   ├── categories.php          # Categories management
│   │   │   ├── authors.php             # Authors management
│   │   │   └── seo_analytics.php       # SEO dashboard
│   │   ├── header.php                  # Includes blog menu
│   │   └── footer.php                  # Page footer
│   ├── config/
│   │   └── routes.php                  # Blog routes configuration
│   └── helpers/
│       └── seo_helper.php              # SEO utility functions
├── database/
│   └── migrations/
│       ├── 001_create_blog_tables.sql  # Main blog schema
│       └── 002_add_seo_analytics.sql   # SEO analytics table
└── upload/
    └── blog/                           # Image upload directory
```

## Support

For issues or questions:
1. Check browser console for JavaScript errors
2. Check PHP error logs in `admin_backend/application/logs/`
3. Verify database tables were created correctly
4. Ensure all file permissions are correct

---

**Version**: 1.0.0  
**Last Updated**: January 25, 2026  
**Status**: Production Ready ✅
