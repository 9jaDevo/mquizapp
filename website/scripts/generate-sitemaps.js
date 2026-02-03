/**
 * Sitemap Generator for SEO
 * Generates XML sitemaps for blog and website
 * Run: npm run generate-sitemaps
 * 
 * Output:
 * - public/sitemap.xml (main sitemap index)
 * - public/sitemap-blog.xml (blog posts)
 * - public/sitemap-pages.xml (static pages)
 * - public/robots.txt (crawler directives)
 */

import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import { dirname } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const WEBSITE_URL = 'https://mquiz.uk';
const PUBLIC_DIR = path.join(__dirname, '../public');

// Ensure public directory exists
if (!fs.existsSync(PUBLIC_DIR)) {
    fs.mkdirSync(PUBLIC_DIR, { recursive: true });
}

/**
 * Generate Blog Sitemap
 * Note: In production, you'd fetch from API
 */
const generateBlogSitemap = () => {
    // Sample blog entries - in production, fetch from API
    const blogEntries = [
        { slug: 'getting-started-with-mquiz', updated: '2024-01-15', priority: '0.8' },
        { slug: 'tips-for-effective-learning', updated: '2024-01-10', priority: '0.8' },
        { slug: 'gamification-in-education', updated: '2024-01-05', priority: '0.7' },
    ];

    let xml = `<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="${WEBSITE_URL}/sitemap.xsl"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"
        xmlns:image="http://www.google.com/schemas/sitemap-image/1.1"
        xmlns:mobile="http://www.google.com/schemas/sitemap-mobile/1.0">
`;

    // Blog archive page
    xml += `  <url>
    <loc>${WEBSITE_URL}/blog</loc>
    <lastmod>${new Date().toISOString().split('T')[0]}</lastmod>
    <changefreq>weekly</changefreq>
    <priority>1.0</priority>
  </url>
`;

    // Individual blog posts
    blogEntries.forEach(post => {
        xml += `  <url>
    <loc>${WEBSITE_URL}/blog/${post.slug}</loc>
    <lastmod>${post.updated}</lastmod>
    <changefreq>monthly</changefreq>
    <priority>${post.priority}</priority>
    <mobile:mobile/>
  </url>
`;
    });

    xml += `</urlset>`;

    const filePath = path.join(PUBLIC_DIR, 'sitemap-blog.xml');
    fs.writeFileSync(filePath, xml);
    console.log(`✓ Generated sitemap-blog.xml (${blogEntries.length + 1} entries)`);
    return 'sitemap-blog.xml';
};

/**
 * Generate Pages Sitemap (static pages)
 */
const generatePagesSitemap = () => {
    const pages = [
        { path: '/', changefreq: 'weekly', priority: '1.0', lastmod: new Date().toISOString().split('T')[0] },
        { path: '/download', changefreq: 'monthly', priority: '0.9', lastmod: '2024-01-15' },
        { path: '/features', changefreq: 'monthly', priority: '0.8', lastmod: '2024-01-10' },
        { path: '/about', changefreq: 'yearly', priority: '0.7', lastmod: '2024-01-01' },
    ];

    let xml = `<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="${WEBSITE_URL}/sitemap.xsl"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"
        xmlns:mobile="http://www.google.com/schemas/sitemap-mobile/1.0">
`;

    pages.forEach(page => {
        xml += `  <url>
    <loc>${WEBSITE_URL}${page.path}</loc>
    <lastmod>${page.lastmod}</lastmod>
    <changefreq>${page.changefreq}</changefreq>
    <priority>${page.priority}</priority>
    <mobile:mobile/>
  </url>
`;
    });

    xml += `</urlset>`;

    const filePath = path.join(PUBLIC_DIR, 'sitemap-pages.xml');
    fs.writeFileSync(filePath, xml);
    console.log(`✓ Generated sitemap-pages.xml (${pages.length} entries)`);
    return 'sitemap-pages.xml';
};

/**
 * Generate Sitemap Index
 */
const generateSitemapIndex = (sitemaps) => {
    let xml = `<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="${WEBSITE_URL}/sitemap.xsl"?>
<sitemapindex xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
`;

    sitemaps.forEach(sitemap => {
        xml += `  <sitemap>
    <loc>${WEBSITE_URL}/${sitemap}</loc>
    <lastmod>${new Date().toISOString().split('T')[0]}</lastmod>
  </sitemap>
`;
    });

    xml += `</sitemapindex>`;

    const filePath = path.join(PUBLIC_DIR, 'sitemap.xml');
    fs.writeFileSync(filePath, xml);
    console.log(`✓ Generated sitemap.xml (${sitemaps.length} sitemaps)`);
};

/**
 * Generate robots.txt
 */
const generateRobotsTxt = () => {
    const robotsTxt = `# robots.txt for mQuiz
# Generated for SEO optimization
# Last updated: ${new Date().toISOString()}

# Allow all bots
User-agent: *
Allow: /
Disallow: /admin/
Disallow: /api/
Disallow: /admin_backend/
Disallow: *.php
Disallow: /private/

# Specific bot rules
User-agent: Googlebot
Allow: /
Crawl-delay: 0

User-agent: Bingbot
Allow: /
Crawl-delay: 1

# Sitemaps
Sitemap: ${WEBSITE_URL}/sitemap.xml
Sitemap: ${WEBSITE_URL}/sitemap-blog.xml
Sitemap: ${WEBSITE_URL}/sitemap-pages.xml

# Rate limiting
Request-rate: 30/60

# Comments
# Last updated: ${new Date().toISOString()}
# Next update: automatic with each deploy
`;

    const filePath = path.join(PUBLIC_DIR, 'robots.txt');
    fs.writeFileSync(filePath, robotsTxt);
    console.log(`✓ Generated robots.txt`);
};

/**
 * Main execution
 */
try {
    console.log('🚀 Generating SEO sitemaps...\n');

    const blogSitemap = generateBlogSitemap();
    const pagesSitemap = generatePagesSitemap();

    generateSitemapIndex([blogSitemap, pagesSitemap]);
    generateRobotsTxt();

    console.log('\n✓ All sitemaps generated successfully!');
    console.log(`\nNext steps:`);
    console.log(`1. Submit to Google Search Console: ${WEBSITE_URL}/sitemap.xml`);
    console.log(`2. Submit to Bing Webmaster Tools: ${WEBSITE_URL}/sitemap.xml`);
    console.log(`3. Verify robots.txt: ${WEBSITE_URL}/robots.txt`);
    console.log(`\nFiles created:`);
    console.log(`  - ${PUBLIC_DIR}/sitemap.xml`);
    console.log(`  - ${PUBLIC_DIR}/sitemap-blog.xml`);
    console.log(`  - ${PUBLIC_DIR}/sitemap-pages.xml`);
    console.log(`  - ${PUBLIC_DIR}/robots.txt`);
} catch (error) {
    console.error('✗ Sitemap generation failed:', error.message);
    process.exit(1);
}
