# Vercel Deployment Fix - Route Configuration

## Issues Fixed:

### 1. **vercel.json Updated** ✅
- Simplified rewrite rules
- Changed API rewrite to: `/api/:path*` → `https://mquiz.uk/admin_backend/index.php/api/:path*`
- Simplified SPA rewrite: `/(.*)`  → `/index.html`

### 2. **_redirects Added** ✅
- Created `public/_redirects` with Netlify-style redirect format
- Tells Vercel to rewrite all routes to index.html for React Router

### 3. **Before Deploying - Critical:**

Create/Update your `.env` file in `website/` folder:

```env
# API Configuration (PHP Backend)
VITE_API_BASE_URL=https://mquiz.uk/admin_backend
VITE_API_TIMEOUT=10000

# Site URL
VITE_SITE_URL=https://mquiz.uk

# Google Analytics 4 Configuration
VITE_GA_TRACKING_ID=G-XXXXXXXXXX
VITE_GA_BOT_PROPERTY_ID=G-YYYYYYYYYY
VITE_GA_ENABLE_BOT_TRACKING=true

# Analytics Configuration
VITE_ANALYTICS_ENABLE_CORE_WEB_VITALS=true
VITE_ANALYTICS_SAMPLE_RATE=100
VITE_ANALYTICS_DEBUG=false

# SEO & Analytics
VITE_ENABLE_SEO_ANALYTICS=true
VITE_ENABLE_BOT_DETECTION=true
VITE_ENABLE_RESOURCE_HINTS=true
```

### 4. **Deploy Steps:**

```bash
# 1. Create .env file in website/ folder (copy from .env.example)
cp website/.env.example website/.env

# 2. Update .env with your GA4 tracking IDs and other values

# 3. Build and test locally
cd website
npm run build
npm run dev

# 4. Verify /blog and /blog/post-slug routes work

# 5. Commit changes
git add website/
git commit -m "Fix Vercel routing configuration"
git push

# 6. Vercel will auto-deploy
```

## Routes That Should Now Work:
- ✅ `/` - Home page
- ✅ `/blog` - Blog listing
- ✅ `/blog/post-slug` - Individual blog post
- ✅ `/features` - Features page
- ✅ `/about` - About page
- ✅ `/contact` - Contact page
- ✅ `/download` - Download page
- ✅ `/api/*` - API calls to your PHP backend

## Troubleshooting:

If routes still don't work:
1. Check browser console for errors (F12)
2. Check Vercel deployment logs
3. Verify .env file has correct values
4. Try clearing browser cache (Ctrl+Shift+Delete)
5. Check if API calls are reaching the backend

## Testing:

After deployment, test:
1. Navigate to: https://mquiz.uk/blog
2. Navigate to: https://mquiz.uk/blog/any-post-slug
3. Check Network tab (F12) to see if requests are working
4. Check React Router in DevTools
