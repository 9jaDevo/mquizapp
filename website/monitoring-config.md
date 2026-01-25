# SEO & Analytics Monitoring Configuration

## Overview
This document outlines the monitoring strategy for SEO performance, AI bot discoverability, and content ranking optimization.

---

## 1. Bot Traffic Tracking

### Google Analytics 4 Setup
- **Primary Property ID:** `G-XXXXXXXXXX` (Human user traffic)
- **Secondary Property ID:** `G-YYYYYYYYYY` (Bot traffic - debug/monitoring only)

### Bot Traffic Isolation
- **Custom Dimension:** `user_type`
  - `human` - Regular human user
  - `search_bot` - Search engine bot (Googlebot, Bingbot, etc.)
  - `ai_bot` - AI model training bot (GPTBot, Claude, Perplexity, etc.)
  - `social_bot` - Social media bot
  - `other_bot` - Other bots

### Key Bots to Monitor
1. **AI Model Bots** (Priority: HIGH)
   - GPTBot (OpenAI)
   - CCBot (Common Crawl)
   - anthropic-ai (Anthropic/Claude)
   - PerplexityBot (Perplexity AI)
   - ClaudeBot (Anthropic)

2. **Search Engine Bots** (Priority: HIGH)
   - Googlebot (Google)
   - Bingbot (Microsoft Bing)
   - DuckDuckBot (DuckDuckGo)

3. **Social Media Bots** (Priority: MEDIUM)
   - facebookexternalhit
   - Twitterbot
   - LinkedInBot

---

## 2. Content Performance Metrics

### Dashboard Section 1: Crawler Health
**Metrics to Track:**
- GPT Bot visits (last 7 days, 30 days trend)
- Googlebot visits frequency
- Average crawl time per page
- Pages crawled by bot type
- Crawl budget remaining (via Google Search Console)

**Target KPIs:**
- AI bot visits: 2-3x per week minimum
- Search bot visits: Daily
- Average crawl time: <2 seconds per page
- Crawl budget utilization: <80%

### Dashboard Section 2: Content Performance
**Metrics to Track:**
- New posts indexed within 24-48 hours
- Posts with auto-generated keywords vs. editor keywords
- Average position in SERPs for target keywords
- Click-through rate (CTR) from search results
- Keyword ranking movement (up/down/stable)
- Featured snippet capture rate

**Target KPIs:**
- New post indexation: <48 hours
- Keyword coverage: 100+ indexed keywords
- Average SERP position: Top 20 (target: Top 10)
- Featured snippets: 3-5 per month
- CTR improvement: +15-25% in 60 days

### Dashboard Section 3: User Engagement
**Metrics to Track:**
- Organic traffic trend (30-day rolling average)
- Human pageviews vs. bot pageviews (ratio)
- Average time on blog posts
- Bounce rate trend
- Top performing posts by section
- User scroll depth on blog posts

**Target KPIs:**
- Organic traffic growth: +20-30% in 60 days
- Bot traffic ratio: 15-25% of total traffic
- Average time on blog: >3 minutes
- Bounce rate: <50% for blog posts
- Scroll depth: 75%+ of users scroll to bottom

### Dashboard Section 4: Content Freshness
**Metrics to Track:**
- Posts updated in last 30 days
- Average days since last update (all posts)
- High-performing posts due for refresh
- E-E-A-T signals completeness:
  - Author bio presence: 100%
  - Author social links: 75%+ posts
  - Reading time display: 100%
  - Featured image: 100%

**Refresh Strategy:**
- High-performing posts (>100 views/month): Refresh every 30-60 days
- Medium-performing posts (50-100 views/month): Refresh every 60-90 days
- Low-performing posts: Refresh every 90-120 days

### Dashboard Section 5: Core Web Vitals
**Metrics to Track:**
- LCP (Largest Contentful Paint)
- FID (First Input Delay)
- CLS (Cumulative Layout Shift)
- TTFB (Time to First Byte)
- FCP (First Contentful Paint)

**Google Target Values:**
- LCP: <2.5 seconds (Good)
- FID: <100 milliseconds (Good)
- CLS: <0.1 (Good)
- TTFB: <600 milliseconds (Good)

**Mobile vs Desktop Tracking:**
- Track separately for mobile and desktop
- Mobile is primary (Google Mobile-First Indexing)
- Prioritize mobile optimization

---

## 3. Keyword Tracking

### Keyword Categories
1. **Target Keywords** (5-10 primary keywords)
   - Example: "quiz app", "learning app", "earn money quiz"
   - Target: Position 3-10 in Google SERPs

2. **Long-Tail Keywords** (20-50 secondary keywords)
   - Example: "best quiz app 2026", "quiz app with rewards"
   - Target: Position 5-15 in Google SERPs

3. **Supporting Keywords** (100+ tertiary keywords)
   - Blog post specific keywords
   - Should appear in auto-generated keywords

### Keyword Ranking Tools
- **Primary:** Google Search Console (free, official)
- **Secondary:** Semrush, Ahrefs, Moz (optional, for detailed analysis)
- **Monitoring Frequency:** Daily for top 20 keywords, weekly for all keywords

### Keyword Performance Targets
- Month 1: Establish baseline rankings
- Month 2: 20-30% of keywords move up in rankings
- Month 3: 5-10 keywords reach Top 20
- Month 6: 2-3 keywords reach Top 10

---

## 4. SEO Health Monitoring

### Google Search Console Checklist
- ✅ Submit sitemap
- ✅ Monitor crawl errors
- ✅ Check mobile usability
- ✅ Review Core Web Vitals
- ✅ Monitor coverage (indexed pages)
- ✅ Check security issues
- ✅ Submit new blog posts via "Inspect URL"

### Regular Audits
- **Weekly:** Crawl errors, index coverage, 404s
- **Bi-weekly:** Keyword rankings, SERP position changes
- **Monthly:** Core Web Vitals, full site audit, E-A-T assessment
- **Quarterly:** Competitor analysis, strategy adjustment

---

## 5. AI Model Indexing Tracking

### How AI Bots Index Content
1. **Initial Crawl:** Bot discovers and indexes page
2. **Content Analysis:** Extracts text, links, metadata
3. **Schema Recognition:** Reads structured data (JSON-LD)
4. **Ranking Signal:** Considers freshness, authority, relevance
5. **Training Data:** Includes in model training (varies by bot)

### Signals for AI Discoverability
- Schema.org markup (NewsArticle, BreadcrumbList, Author)
- Fresh content (updated within 30 days)
- Author expertise (bio, social links, credentials)
- E-E-A-T signals (expertise, experience, authority, trustworthiness)
- Link authority (backlinks from reputable sites)
- Content quality (original, comprehensive, well-structured)

### Monitoring AI Bot Access
- Track GPTBot visits in GA4
- Monitor crawl frequency in Google Search Console
- Check which pages AI bots prioritize
- Analyze content AI bots index vs. bypass
- Monitor OpenAI/Claude bot user agents

---

## 6. Content Performance Deep Dive

### Blog Post Analysis Template (Monthly)
For each blog post:
1. **Organic Traffic Trend**
   - Sessions from organic search
   - Month-over-month growth %
   - Top referring keywords

2. **Engagement Metrics**
   - Average session duration
   - Scroll depth %
   - Bounce rate
   - Click-through rate to related posts

3. **Ranking Performance**
   - Target keyword position
   - Impressions in Google Search Console
   - CTR improvement potential

4. **Freshness Status**
   - Days since last update
   - Update recommendation (yes/no)
   - Relevance score (1-10)

5. **SEO Audit**
   - Meta title/description quality
   - Keyword density check
   - Internal linking coverage
   - Image alt text compliance
   - Schema validation

---

## 7. Monitoring Dashboard Access

### Tools & Platforms
1. **Google Analytics 4 Dashboard**
   - URL: https://analytics.google.com
   - Access: Team members with GA4 permission
   - Custom report: "Bot Traffic Analysis"

2. **Google Search Console**
   - URL: https://search.google.com/search-console
   - Check: Coverage, Core Web Vitals, Keywords
   - Action: Submit URLs, fix crawl errors

3. **Lighthouse CI** (for Core Web Vitals)
   - Run weekly audits
   - Track LCP, FID, CLS trend
   - Monitor on mobile & desktop

4. **Vercel Analytics** (for deployment performance)
   - Monitor serverless function response times
   - Track bundle size
   - Identify performance regressions

---

## 8. Review Cadence

### Daily Standup (5 minutes)
- Check GA4 bot traffic volume
- Review Google Search Console errors (if any)
- Monitor downtime/errors

### Weekly Review (1 hour)
- Keyword ranking changes
- Organic traffic trend
- Core Web Vitals performance
- New bot visits analysis

### Monthly Deep Dive (2-3 hours)
- Full content performance analysis
- Keyword opportunity assessment
- Content refresh recommendations
- Competitor analysis
- E-E-A-T audit
- Technical SEO audit

### Quarterly Strategy Review (3-4 hours)
- 90-day performance summary
- Goal attainment analysis
- Strategy adjustment
- Content calendar planning
- Backlink strategy review
- Budget allocation for SEO tools

---

## 9. Alert Thresholds

**High Priority Alerts** (immediate action needed)
- Organic traffic drop >20% week-over-week
- Crawl errors >10% of pages
- Core Web Vitals go from "Good" to "Poor"
- Manual action penalty in Search Console
- Site downtime >30 minutes

**Medium Priority Alerts** (review within 24 hours)
- GPTBot stops visiting for 7+ days
- New crawl errors >5
- Keyword ranking drop >5 positions
- CTR drop >15% for top keywords
- Page indexation delay >72 hours

**Low Priority Alerts** (review in weekly standup)
- Organic traffic fluctuation 0-10%
- New keyword opportunities
- Featured snippet lost
- Internal link changes
- Minor Core Web Vitals changes

---

## 10. Success Metrics Timeline

### 30-Day Goals
- ✓ Analytics infrastructure live and tracking
- ✓ Bot detection working correctly
- ✓ Schema markup validated
- ✓ robots.txt updated with AI bot access
- ✓ Core Web Vitals baseline established
- ✓ First content refresh completed

### 60-Day Goals
- ✓ +20-30% organic traffic growth
- ✓ 5-10 new keywords ranking in Top 50
- ✓ AI bot visits 2-3x per week
- ✓ New posts indexed within 48 hours
- ✓ Average SERP position improvement
- ✓ Featured snippet opportunity identified

### 90-Day Goals
- ✓ +25-40% organic traffic growth
- ✓ 10-15 keywords in Top 30
- ✓ 2-3 keywords in Top 10
- ✓ 5-10 new backlinks acquired
- ✓ Core Web Vitals all "Good"
- ✓ Blog contributing 40%+ of organic traffic
- ✓ AI model training data inclusion (GPTBot indexing verified)

---

## 11. Tools & Resources

### Free Tools
- Google Analytics 4
- Google Search Console
- Google Lighthouse
- Google PageSpeed Insights
- Screaming Frog SEO Spider (limited free version)

### Paid Tools (Optional)
- Semrush ($120-400/month) - Keyword research, rank tracking, competitor analysis
- Ahrefs ($99-999/month) - Backlink analysis, keyword research
- Moz ($99-599/month) - Rank tracking, site audit
- Surfer SEO ($99-199/month) - Content optimization
- Jasper AI ($125-1,200/month) - AI content generation (for updates)

---

## 12. Contingency Plan

### If Organic Traffic Plateaus (90 days post-launch)
1. Increase content production (2-3 posts/week)
2. Focus on long-tail keyword targets
3. Implement internal linking strategy
4. Acquire high-quality backlinks (guest posts, partnerships)
5. Evaluate SSR/Next.js migration for crawl efficiency

### If Bot Traffic Isn't Increasing
1. Verify robots.txt rules are permissive
2. Increase schema markup completeness
3. Build more internal links for bot navigation
4. Submit sitemap to search engines
5. Acquire backlinks (AI bots follow link graphs)

### If Core Web Vitals Degrade
1. Analyze performance regressions
2. Optimize image loading (use WebP, lazy load)
3. Reduce JavaScript bundle size
4. Implement caching strategy
5. Upgrade server resources if needed

---

## Document Metadata
- **Version:** 1.0
- **Last Updated:** January 2026
- **Next Review:** Monthly (first Monday of month)
- **Owner:** SEO / Analytics Team
- **Stakeholders:** Product, Marketing, Engineering
