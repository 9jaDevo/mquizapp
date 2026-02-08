# Google Analytics Verification Checklist

## Pre-Deployment Verification ✅

### Environment Configuration
- [x] `.env` file has `VITE_GA_TRACKING_ID=G-NVKN18MWNH`
- [x] `.env` file has `VITE_GA_BOT_PROPERTY_ID=G-432209366`
- [x] `.env` file has `VITE_ENABLE_ANALYTICS=true`
- [x] `.env` file has `VITE_ENABLE_BOT_TRACKING=true`

### Build Verification
- [x] `npm run build` completes without errors
- [x] `dist/index.html` contains gtag script
- [x] `dist/index-*.js` bundle generated
- [x] All assets generated (og-image, icons, sitemaps)

### Code Implementation
- [x] `index.html` has GA4 script in `<head>`
- [x] `src/utils/analytics.ts` exists (505 lines)
- [x] `src/components/common/Analytics.tsx` exists
- [x] Analytics component initialized in `main.tsx`

### Page Coverage (10/10)
- [x] Home (`/`) - Has page_view tracking
- [x] Features (`/features`) - Has page_view tracking
- [x] About (`/about`) - Has page_view tracking
- [x] Blog (`/blog`) - Has page_view tracking
- [x] Blog Post (`/blog/:slug`) - Has blog_post_viewed event
- [x] Download (`/download`) - Has 5 download events
- [x] Contact (`/contact`) - Has page_view tracking
- [x] Privacy (`/privacy`) - Has page_view tracking
- [x] Terms (`/terms`) - Has page_view tracking
- [x] 404 Page - Has page_view tracking

## Post-Deployment Verification

### Step 1: Browser Console Test
```javascript
// Run in browser console on live site:
// 1. Check gtag exists
console.log('gtag:', typeof gtag);

// 2. Check dataLayer
console.log('dataLayer:', window.dataLayer);

// 3. Send test event
gtag('event', 'test_event', {
  event_category: 'verification',
  event_label: 'manual_test'
});

// 4. Verify tracking IDs
console.log('Tracking IDs loaded:', window.dataLayer
  .filter(item => item[0] === 'config')
  .map(item => item[1])
);
```

**Expected Output**:
```
gtag: function
dataLayer: Array[...]
Tracking IDs loaded: ["G-NVKN18MWNH", "G-432209366"]
```

### Step 2: GA4 Real-Time Reports
1. Open [Google Analytics](https://analytics.google.com/)
2. Select property: **G-NVKN18MWNH**
3. Navigate: **Reports** → **Real-time**
4. Visit your website
5. Within 30 seconds, check:

#### Real-Time Checklist
- [ ] Active users count increases
- [ ] Page views appear in "Event count by Event name"
- [ ] Page titles show in "Views by Page title and screen name"
- [ ] Events appear as they're triggered
- [ ] Geographic location shows correctly

### Step 3: Page-by-Page Verification

Visit each page and verify in GA4 Real-time:

#### Home Page (`/`)
- [ ] Visit https://mquiz.uk/
- [ ] Real-time shows: `page_view` event
- [ ] Page title: "Home"
- [ ] Page path: "/"

#### Features Page (`/features`)
- [ ] Visit https://mquiz.uk/features
- [ ] Real-time shows: `page_view` event
- [ ] Page title: "Features"
- [ ] Page path: "/features"

#### About Page (`/about`)
- [ ] Visit https://mquiz.uk/about
- [ ] Real-time shows: `page_view` event
- [ ] Page title: "About"
- [ ] Page path: "/about"

#### Blog Page (`/blog`)
- [ ] Visit https://mquiz.uk/blog
- [ ] Real-time shows: `page_view` event
- [ ] Page title: "Blog"
- [ ] Page path: "/blog"

#### Blog Post Page
- [ ] Click any blog post
- [ ] Real-time shows: `blog_post_viewed` event
- [ ] Event has custom parameters:
  - [ ] `content_id`
  - [ ] `content_title`
  - [ ] `reading_time`
  - [ ] `category`

#### Download Page (`/download`)
- [ ] Visit https://mquiz.uk/download
- [ ] Real-time shows: `download_page_viewed` event
- [ ] Platform detected correctly
- [ ] Wait for countdown or click button
- [ ] Verify additional events:
  - [ ] `download_redirect` (if waited)
  - [ ] `download_redirect_cancelled` (if cancelled)
  - [ ] `download_button_clicked` (if clicked)

#### Contact Page (`/contact`)
- [ ] Visit https://mquiz.uk/contact
- [ ] Real-time shows: `page_view` event
- [ ] Page title: "Contact"
- [ ] Page path: "/contact"

#### Privacy Page (`/privacy`)
- [ ] Visit https://mquiz.uk/privacy-policy
- [ ] Real-time shows: `page_view` event
- [ ] Page title: "Privacy Policy"
- [ ] Page path: "/privacy"

#### Terms Page (`/terms`)
- [ ] Visit https://mquiz.uk/terms
- [ ] Real-time shows: `page_view` event
- [ ] Page title: "Terms & Conditions"
- [ ] Page path: "/terms"

#### 404 Page
- [ ] Visit https://mquiz.uk/nonexistent-page
- [ ] Real-time shows: `page_view` event
- [ ] Page title: "404 Not Found"
- [ ] Page path shows actual attempted path

### Step 4: Bot Traffic Verification

1. Select property: **G-432209366** (Bot tracking)
2. Navigate: **Reports** → **Real-time**
3. Check if bot traffic is being segmented
4. Compare with primary property (G-NVKN18MWNH)

#### Bot Traffic Checklist
- [ ] Bot property exists in GA4
- [ ] Receives events (may be minimal)
- [ ] Different traffic patterns vs primary property

### Step 5: Core Web Vitals Verification

After 24-48 hours of data collection:
1. Navigate: **Reports** → **Engagement** → **Pages and screens**
2. Look for Web Vitals metrics:

#### Web Vitals Checklist
- [ ] LCP (Largest Contentful Paint) data available
- [ ] FID (First Input Delay) data available
- [ ] CLS (Cumulative Layout Shift) data available
- [ ] FCP (First Contentful Paint) data available
- [ ] TTFB (Time to First Byte) data available

### Step 6: Privacy Features Verification

#### Privacy Checklist
- [ ] IP addresses are anonymized (check GA4 settings)
- [ ] Google signals disabled (no ad personalization)
- [ ] DNT (Do Not Track) respected
- [ ] Cookies use SameSite=None;Secure
- [ ] No PII (Personally Identifiable Information) tracked

### Step 7: Event Parameters Verification

Check custom parameters are captured:
1. Navigate: **Reports** → **Engagement** → **Events**
2. Click on event name (e.g., `blog_post_viewed`)
3. Verify parameters:

#### Event Parameters Checklist
- [ ] `page_view`: page_title, page_location, page_path
- [ ] `blog_post_viewed`: content_id, content_title, reading_time, category
- [ ] `download_page_viewed`: platform, source
- [ ] `download_redirect`: platform, source, countdown_seconds
- [ ] `download_button_clicked`: platform, source, button_type

## Common Issues & Solutions

### Issue: No events showing in Real-time
**Solutions**:
- Clear browser cache and cookies
- Disable ad blockers (uBlock, AdBlock, etc.)
- Check browser console for errors
- Verify gtag.js loaded: Network tab → filter "gtag"
- Check dataLayer: `console.log(window.dataLayer)`

### Issue: Events showing but no page title
**Solution**: 
- Check page component has correct parameters
- Verify `page_title` in event data
- Rebuild: `npm run build`

### Issue: Only some pages track
**Solution**:
- Check each page has `import { trackAnalyticsEvent }`
- Verify `useEffect` hook exists
- Check for console errors on that page

### Issue: Bot traffic not segmented
**Solution**:
- Verify `.env` has `VITE_GA_BOT_PROPERTY_ID`
- Check `src/utils/botDetection.ts` exists
- Verify Analytics component has `enableBotTracking={true}`

### Issue: Core Web Vitals not showing
**Solution**:
- Wait 24-48 hours for data
- Verify Analytics component has `enableCoreWebVitals={true}`
- Check `web-vitals` package installed

## Success Criteria

✅ **All checks passed** = GA4 fully functional  
⚠️ **Some checks failed** = Review failed items and fix  
❌ **Most checks failed** = Re-deploy or check configuration  

## Final Verification Report

Fill this out after completing all checks:

```
Date: _______________
Tester: _______________

Pre-Deployment: ☐ Pass ☐ Fail
Browser Console: ☐ Pass ☐ Fail
Real-Time Reports: ☐ Pass ☐ Fail
Page Coverage: ___/10 pages
Bot Segmentation: ☐ Working ☐ Not Working
Core Web Vitals: ☐ Working ☐ Not Working (wait 24-48h)
Privacy Features: ☐ Pass ☐ Fail

Overall Status: ☐ VERIFIED ☐ NEEDS ATTENTION

Notes:
_________________________________
_________________________________
_________________________________
```

## Next Steps After Verification

### If All Tests Pass ✅
1. Configure conversion events
2. Set up custom reports
3. Create audience segments
4. Enable regular monitoring
5. Document any customizations

### If Some Tests Fail ⚠️
1. Document which tests failed
2. Check error messages in console
3. Review implementation for failed pages
4. Rebuild and re-deploy
5. Re-run failed tests

### If Most Tests Fail ❌
1. Review `.env` configuration
2. Check build output for errors
3. Verify gtag script in index.html
4. Review Analytics component initialization
5. Contact support if needed

---

**Verification Tool**: Use `src/utils/ga-verify.ts` script  
**Support**: Check `GA_IMPLEMENTATION_COMPLETE.md` for details  
**Last Updated**: February 3, 2026
