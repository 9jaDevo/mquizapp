# 🚀 mQuiz Production Deployment Checklist

## Pre-Build Verification

### Code Quality
- [ ] All TypeScript files compile without errors
- [ ] No console.error or console.warn in production code
- [ ] All imports are correct (no unused imports)
- [ ] Environment variables configured (VITE_API_BASE_URL)

### Asset Verification
- [ ] Blog posts have featured images (1200x630px minimum)
- [ ] All blog post slugs are URL-safe (lowercase, hyphens)
- [ ] Author information complete (name, avatar, bio)
- [ ] Category descriptions filled in

### API Backend (CodeIgniter)
- [ ] Blog_model.get_posts() functional
- [ ] Image uploads working (`/images/blog/` writable)
- [ ] Database migrations applied
- [ ] CSRF tokens configured (csrf_exclude_uris updated)
- [ ] Blog endpoints accessible:
  - `POST /api/blog/posts` (create)
  - `GET /api/blog/posts` (list with pagination)
  - `GET /api/blog/posts/{slug}` (detail)
  - `PUT /api/blog/posts/{id}` (update)
  - `DELETE /api/blog/posts/{id}` (delete)

## Build Phase

### Asset Generation
```bash
npm run build
```

This automatically executes:
1. ✓ `node scripts/generate-assets.js`
   - Creates `/public/og-image.jpg` (1200x630px)
   - Creates `/public/icon-192.png`
   - Creates `/public/icon-512.png`

2. ✓ `node scripts/generate-sitemaps.js`
   - Creates `/public/sitemap.xml` (index)
   - Creates `/public/sitemap-blog.xml` (blog entries)
   - Creates `/public/sitemap-pages.xml` (static pages)
   - Creates `/public/robots.txt`

3. ✓ TypeScript compilation: `tsc -b`

4. ✓ Vite production build: `vite build`

### Verify Build Output

Check the `dist/` folder contains:
- [ ] `index.html` (with all meta tags)
- [ ] `manifest.json` (PWA metadata)
- [ ] `.htaccess` (SPA routing + compression)
- [ ] `sitemap.xml`, `sitemap-blog.xml`, `sitemap-pages.xml`
- [ ] `robots.txt`
- [ ] `og-image.jpg` (1200x630px)
- [ ] `icon-192.png`, `icon-512.png`
- [ ] JavaScript bundles (optimized/minified)
- [ ] CSS bundles (Tailwind purged)
- [ ] Static assets (images, fonts)

## Deployment to Production

### Server Configuration (Apache/Nginx)

#### Apache .htaccess
```
<IfModule mod_rewrite.c>
  RewriteEngine On
  RewriteBase /

  # SPA routing - all requests go to index.html
  RewriteCond %{REQUEST_FILENAME} !-f
  RewriteCond %{REQUEST_FILENAME} !-d
  RewriteRule ^ index.html [QSA,L]

  # Gzip compression
  <IfModule mod_deflate.c>
    AddOutputFilterByType DEFLATE text/html text/plain text/xml text/css text/javascript application/javascript
  </IfModule>

  # Browser caching
  <IfModule mod_expires.c>
    ExpiresActive On
    ExpiresByType image/jpeg "access plus 1 year"
    ExpiresByType image/png "access plus 1 year"
    ExpiresByType application/javascript "access plus 1 year"
  </IfModule>
</IfModule>
```

#### MIME Types
- [ ] `.js` files: `application/javascript`
- [ ] `.mjs` files: `application/javascript`
- [ ] `.wasm` files: `application/wasm`

### File Permissions
- [ ] `dist/` is readable by web server (755)
- [ ] `sitemap.xml` is publicly accessible
- [ ] `robots.txt` is publicly accessible
- [ ] `manifest.json` is publicly accessible
- [ ] `og-image.jpg` is publicly accessible

### Domain & HTTPS
- [ ] SSL/TLS certificate installed (https://mquiz.uk)
- [ ] HSTS headers configured
- [ ] Mixed content warnings resolved
- [ ] Redirect http → https

### Environment Setup
- [ ] Production domain: `https://mquiz.uk`
- [ ] API base URL: `https://mquiz.uk/api` (or separate domain)
- [ ] CORS headers configured for API
- [ ] CSP headers for security

## Post-Deployment Verification

### Website Accessibility
- [ ] Homepage loads: `https://mquiz.uk`
- [ ] Blog page loads: `https://mquiz.uk/blog`
- [ ] Blog post loads: `https://mquiz.uk/blog/[slug]`
- [ ] Download page loads: `https://mquiz.uk/download`
- [ ] No 404 errors for static assets

### Meta Tags & SEO
- [ ] Inspect homepage meta tags:
  ```bash
  curl -I https://mquiz.uk | grep -i meta
  ```
- [ ] View page source and verify:
  - [ ] `<title>` tag
  - [ ] `<meta name="description">`
  - [ ] `<meta property="og:image">`
  - [ ] `<link rel="manifest">`
  - [ ] All OG tags (og:type, og:title, og:url)
- [ ] PWA manifest accessible: `https://mquiz.uk/manifest.json`
- [ ] Icons accessible: 
  - [ ] `https://mquiz.uk/icon-192.png`
  - [ ] `https://mquiz.uk/icon-512.png`

### Robots & Sitemaps
- [ ] `robots.txt` accessible: `https://mquiz.uk/robots.txt`
  - Verify Sitemap directive
  - Verify User-agent rules
- [ ] Main sitemap: `https://mquiz.uk/sitemap.xml`
  - Contains blog and pages sitemaps
- [ ] Blog sitemap: `https://mquiz.uk/sitemap-blog.xml`
  - Lists all blog posts with lastmod
- [ ] Pages sitemap: `https://mquiz.uk/sitemap-pages.xml`
  - Lists static pages

### Social Sharing Preview
Test with: https://www.opengraph.xyz/

- [ ] **Homepage Share**
  - Title: "mQuiz - Learn, Engage, and Earn Rewards"
  - Description: Shows full meta description
  - Image: og-image.jpg displays (1200x630)
  - Site Name: "mQuiz"

- [ ] **Blog Post Share**
  - Title: Post title from meta_title
  - Description: Post excerpt
  - Image: Featured image from post
  - Author: Author name visible

- [ ] **Download Page Share**
  - Title: "Download mQuiz - iOS & Android"
  - Description: Download instructions
  - Image: og-image.jpg displays

### Platform Testing

#### LinkedIn
- [ ] Post homepage URL
- [ ] Verify card shows title + description + image
- [ ] Card preview matches OG tags

#### Facebook
- Use Facebook Sharing Debugger: https://developers.facebook.com/tools/debug/
- [ ] OG image displays correctly
- [ ] Title and description show
- [ ] Domain verified
- [ ] No errors in debugger

#### Twitter/X
- Use Twitter Card Validator: https://cards-dev.twitter.com/validator
- [ ] Twitter Card appears (summary_large_image)
- [ ] Image displays
- [ ] Creator credit (@mquizonline) shows

#### WhatsApp
- [ ] Share on mobile (iOS/Android)
- [ ] Link preview shows title + image
- [ ] Tappable preview works

### Technical SEO Verification

#### Google Search Console
1. Go to: https://search.google.com/search-console
2. [ ] Add property: `https://mquiz.uk`
3. [ ] Verify domain ownership (DNS or HTML file)
4. [ ] Submit sitemap: `https://mquiz.uk/sitemap.xml`
5. [ ] Request indexing for homepage
6. [ ] Monitor Crawl Errors
7. [ ] Verify no manual actions
8. [ ] Set preferred domain (www vs non-www)

#### Bing Webmaster Tools
1. Go to: https://www.bing.com/webmaster/
2. [ ] Add site: `mquiz.uk`
3. [ ] Submit sitemap
4. [ ] Enable mobile-first indexing
5. [ ] Configure crawl settings

#### Schema Validation
- [ ] Homepage: https://schema.org/validate
  - [ ] Organization schema valid
  - [ ] WebSite schema valid
- [ ] Blog page: Schema validation passes
  - [ ] Blog schema present
- [ ] Blog post: Schema validation passes
  - [ ] NewsArticle schema valid
  - [ ] BreadcrumbList valid
  - [ ] Author/Person valid

#### Performance Testing
- [ ] Google PageSpeed: https://pagespeed.web.dev/
  - Performance score > 75
  - Mobile score > 75
  - Accessibility score > 90
- [ ] Mobile-Friendly Test: https://search.google.com/test/mobile-friendly
  - Mobile-friendly: YES
  - No mobile usability issues

### Analytics Setup
- [ ] Google Analytics 4 implemented
- [ ] Event tracking for:
  - [ ] Blog post views
  - [ ] Download page visits
  - [ ] App store clicks
  - [ ] Social shares (if implemented)
- [ ] Goals configured:
  - [ ] App download
  - [ ] Newsletter signup
  - [ ] Blog subscription
- [ ] Custom dimensions:
  - [ ] User source
  - [ ] Platform (mobile/desktop)
  - [ ] Blog category

## Monitoring & Maintenance

### Daily Checks (First Week)
- [ ] No 500 errors in server logs
- [ ] All API endpoints responding
- [ ] Images loading correctly
- [ ] Download redirects working (Android)
- [ ] Video modal loading properly

### Weekly Checks
- [ ] Check Google Search Console:
  - Coverage report (no errors)
  - Crawl statistics
  - Search appearance
- [ ] Review analytics:
  - User sessions
  - Page performance
  - Bounce rate
- [ ] Test social shares (random posts)

### Monthly Checks
- [ ] Core Web Vitals analysis
- [ ] Blog post indexation status
- [ ] Search query performance
- [ ] Mobile usability issues
- [ ] Update sitemap (new blog posts)
- [ ] Review error logs

### Quarterly Reviews
- [ ] SEO keyword ranking
- [ ] Organic traffic growth
- [ ] Backlink analysis
- [ ] Content performance metrics
- [ ] Update OG images if needed
- [ ] Review structured data strategy

## Troubleshooting Guide

### Meta Tags Not Showing on Social Share

**Problem:** Shared link shows only URL, no title/image

**Solutions:**
1. Verify `index.html` contains meta tags:
   ```bash
   grep "og:image" dist/index.html
   ```
2. Verify og-image.jpg exists and is accessible:
   ```bash
   curl -I https://mquiz.uk/og-image.jpg
   ```
3. Check Image dimensions: Must be 1200x630px
4. Flush social platform cache:
   - Facebook: Sharing Debugger → Scrape Again
   - LinkedIn: Re-share URL
   - Twitter: Clear cache (may take 24h)

### 404 Errors on Page Navigation

**Problem:** Navigating in SPA shows 404

**Solutions:**
1. Verify `.htaccess` deployed in root
2. Check `RewriteEngine On` enabled
3. Verify `RewriteRule ^ index.html [QSA,L]` present
4. Check Apache mod_rewrite enabled:
   ```bash
   apache2ctl -M | grep rewrite
   ```

### Sitemap Not Accessible

**Problem:** `https://mquiz.uk/sitemap.xml` returns 404

**Solutions:**
1. Verify script executed: `node scripts/generate-sitemaps.js`
2. Check `/public/sitemap.xml` exists in dist
3. Verify file permissions: `chmod 644 sitemap.xml`
4. Check web server .htaccess doesn't block .xml files

### PWA Not Installing

**Problem:** PWA install button doesn't appear on mobile

**Solutions:**
1. Verify HTTPS active
2. Check `manifest.json` valid JSON
3. Verify icons accessible:
   ```bash
   curl -I https://mquiz.uk/icon-192.png
   ```
4. Check Chrome DevTools → Manifest tab for errors

## Rollback Plan

If critical issues found:

1. **Immediate:** Revert to previous version
   ```bash
   git checkout previous-tag
   npm run build
   ```

2. **Preserve:** Keep error logs
   ```bash
   cp /var/log/apache2/error.log backup-error-$(date +%s).log
   ```

3. **Communicate:** Update status on social media
   ```
   We're performing maintenance. Service will be back shortly.
   ```

4. **Investigate:** Review error logs and fix issues

5. **Test:** Run full QA on staging before re-deploy

## Sign-Off

- [ ] Product Manager: Approved for production
- [ ] Developer: Code reviewed and tested
- [ ] DevOps: Infrastructure configured
- [ ] QA: All tests passed
- [ ] Security: Security review completed

**Deployment Date:** _______________
**Deployed By:** _______________
**Approval:** _______________

---

**Document Version:** 1.0.0
**Last Updated:** January 2024
**Status:** Ready for Production ✓
