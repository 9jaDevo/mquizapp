# mQuiz Website - Deployment Guide

## Pre-Deployment Checklist

### 1. Environment Variables
Create a `.env` file in the `website/` directory with the following variables:

```env
VITE_EMAILJS_SERVICE_ID=your_service_id_here
VITE_EMAILJS_TEMPLATE_ID=your_template_id_here
VITE_EMAILJS_PUBLIC_KEY=your_public_key_here
VITE_SITE_URL=https://mquiz.uk
VITE_GA_TRACKING_ID=your_google_analytics_id (optional)
VITE_FB_PIXEL_ID=your_facebook_pixel_id (optional)
```

### 2. EmailJS Setup (for Contact Form)
1. Sign up at [EmailJS](https://www.emailjs.com/)
2. Create an email service
3. Create an email template
4. Get your public key from the dashboard
5. Add the credentials to your `.env` file

### 3. Build Verification
Before deploying, verify the build works locally:

```bash
cd website
npm install --legacy-peer-deps
npm run build
npm run preview
```

Visit `http://localhost:4173` to test the production build.

## Deploy to Vercel (Recommended)

### Option 1: Vercel Dashboard (Easy)

1. **Push to GitHub**
   ```bash
   git push origin main
   ```

2. **Import to Vercel**
   - Go to [vercel.com](https://vercel.com)
   - Click "Add New Project"
   - Import your GitHub repository
   - Select the `website` directory as the root

3. **Configure Build Settings**
   - Framework Preset: Vite
   - Root Directory: `website`
   - Build Command: `npm run build`
   - Output Directory: `dist`
   - Install Command: `npm install --legacy-peer-deps`

4. **Add Environment Variables**
   - Go to Project Settings > Environment Variables
   - Add all variables from your `.env` file
   - Apply to Production, Preview, and Development

5. **Deploy**
   - Click "Deploy"
   - Wait for the build to complete
   - Your site will be live at `your-project.vercel.app`

### Option 2: Vercel CLI (Advanced)

1. **Install Vercel CLI**
   ```bash
   npm install -g vercel
   ```

2. **Login to Vercel**
   ```bash
   vercel login
   ```

3. **Deploy from website directory**
   ```bash
   cd website
   vercel
   ```

4. **Follow the prompts**
   - Link to existing project or create new
   - Configure settings as needed

5. **Deploy to Production**
   ```bash
   vercel --prod
   ```

## Deploy to Netlify

1. **Build Configuration**
   Create `netlify.toml` in the `website/` directory:
   ```toml
   [build]
     command = "npm run build"
     publish = "dist"
     base = "website"

   [[redirects]]
     from = "/*"
     to = "/index.html"
     status = 200

   [build.environment]
     NPM_FLAGS = "--legacy-peer-deps"
   ```

2. **Deploy via Netlify Dashboard**
   - Connect your Git repository
   - Set build command: `npm run build`
   - Set publish directory: `dist`
   - Set base directory: `website`
   - Add environment variables
   - Click "Deploy"

3. **Deploy via Netlify CLI**
   ```bash
   npm install -g netlify-cli
   cd website
   netlify init
   netlify deploy --prod
   ```

## Custom Domain Setup

### Vercel
1. Go to Project Settings > Domains
2. Add your custom domain: `mquiz.uk`
3. Add DNS records as instructed:
   - Type: A, Name: @, Value: 76.76.21.21
   - Type: CNAME, Name: www, Value: cname.vercel-dns.com
4. Wait for DNS propagation (up to 48 hours)

### Netlify
1. Go to Site Settings > Domain Management
2. Add custom domain: `mquiz.uk`
3. Configure DNS:
   - Type: A, Name: @, Value: (Netlify IP)
   - Type: CNAME, Name: www, Value: (your-site.netlify.app)

## Post-Deployment Tasks

### 1. Submit to Search Engines
- **Google Search Console**
  1. Go to [search.google.com/search-console](https://search.google.com/search-console)
  2. Add property: `https://mquiz.uk`
  3. Verify ownership
  4. Submit sitemap: `https://mquiz.uk/sitemap.xml`

- **Bing Webmaster Tools**
  1. Go to [bing.com/webmasters](https://www.bing.com/webmasters)
  2. Add site: `https://mquiz.uk`
  3. Verify ownership
  4. Submit sitemap: `https://mquiz.uk/sitemap.xml`

### 2. Setup Analytics
- Add Google Analytics 4 tracking ID to environment variables
- Add Facebook Pixel ID if using Facebook Ads
- Verify tracking is working

### 3. Test Website
- [ ] Test all pages load correctly
- [ ] Test mobile responsiveness
- [ ] Test dark/light mode toggle
- [ ] Test form submissions (when contact form is complete)
- [ ] Test all navigation links
- [ ] Verify SEO meta tags with browser inspector
- [ ] Check loading speed with Google PageSpeed Insights
- [ ] Test on multiple browsers (Chrome, Firefox, Safari, Edge)

### 4. Monitor Performance
- Set up Vercel/Netlify Analytics
- Monitor Core Web Vitals
- Check for errors in deployment logs
- Set up uptime monitoring (e.g., UptimeRobot)

## SSL/HTTPS
Both Vercel and Netlify provide automatic SSL certificates. No additional configuration needed.

## Continuous Deployment
Once connected to Git:
- Every push to `main` branch triggers a production deployment
- Pull requests create preview deployments
- Automatic rollbacks available if needed

## Troubleshooting

### Build Fails
- Check Node.js version (should be 18+)
- Ensure `--legacy-peer-deps` flag is used during install
- Review build logs for specific errors

### Environment Variables Not Working
- Ensure all variables start with `VITE_`
- Rebuild after adding new variables
- Check variables are set in deployment platform

### 404 Errors on Routes
- Ensure redirect/rewrite rules are configured
- Check `vercel.json` or `netlify.toml` is present
- Verify SPA routing is enabled

### Slow Loading
- Enable CDN caching
- Optimize images
- Check bundle size with `npm run build --report`
- Use compression (Vercel/Netlify handle this automatically)

## Support
For deployment issues:
- Vercel: [vercel.com/support](https://vercel.com/support)
- Netlify: [netlify.com/support](https://www.netlify.com/support/)
- mQuiz Team: contact@mquiz.uk
