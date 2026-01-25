/**
 * Content Freshness Utility
 * Tracks and signals content freshness for AI model ranking
 */

/**
 * Calculate days since content was last updated
 */
export function getDaysSinceUpdate(updatedAt: string): number {
    const lastUpdate = new Date(updatedAt);
    const now = new Date();
    const diffTime = Math.abs(now.getTime() - lastUpdate.getTime());
    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
    return diffDays;
}

/**
 * Determine content freshness level
 * AI models prioritize recent content
 */
export function getContentFreshnessLevel(
    updatedAt: string
): 'very_fresh' | 'fresh' | 'stale' | 'very_stale' {
    const daysSince = getDaysSinceUpdate(updatedAt);

    if (daysSince <= 7) return 'very_fresh';
    if (daysSince <= 30) return 'fresh';
    if (daysSince <= 90) return 'stale';
    return 'very_stale';
}

/**
 * Get freshness signal for meta tags
 * Used in robots meta and HTTP headers
 */
export function getFreshnessSignal(updatedAt: string): string {
    const level = getContentFreshnessLevel(updatedAt);

    const mapping: Record<string, string> = {
        very_fresh: 'max-age=3600', // 1 hour cache
        fresh: 'max-age=7200', // 2 hours cache
        stale: 'max-age=86400', // 1 day cache
        very_stale: 'max-age=604800', // 1 week cache
    };

    return mapping[level];
}

/**
 * Get recommendation for content refresh
 * Helps editorial team prioritize updates
 */
export function getRefreshRecommendation(
    updatedAt: string,
    views: number = 0
): {
    shouldRefresh: boolean;
    priority: 'high' | 'medium' | 'low';
    reason: string;
} {
    const daysSince = getDaysSinceUpdate(updatedAt);

    // High priority: recent content with high views that needs update
    if (daysSince > 60 && views > 100) {
        return {
            shouldRefresh: true,
            priority: 'high',
            reason: 'High-performing content that is over 2 months old',
        };
    }

    // Medium priority: evergreen content that needs routine update
    if (daysSince > 90 && views > 50) {
        return {
            shouldRefresh: true,
            priority: 'medium',
            reason: 'Moderate-performing content that is over 3 months old',
        };
    }

    // Low priority: low-traffic content
    if (daysSince > 120) {
        return {
            shouldRefresh: true,
            priority: 'low',
            reason: 'Content has not been updated for over 4 months',
        };
    }

    return {
        shouldRefresh: false,
        priority: 'low',
        reason: 'Content is recent or low priority',
    };
}

/**
 * Create freshness metadata object for SEO
 * Returns object suitable for passing to SEO component
 */
export function generateFreshnessMetadata(
    createdAt: string,
    updatedAt: string
): {
    publishedTime: string;
    modifiedTime: string;
    freshnessLevel: string;
    daysSinceUpdate: number;
} {
    return {
        publishedTime: createdAt,
        modifiedTime: updatedAt,
        freshnessLevel: getContentFreshnessLevel(updatedAt),
        daysSinceUpdate: getDaysSinceUpdate(updatedAt),
    };
}

/**
 * Get freshness score for analytics
 * 0-100 score: higher is fresher (better for AI ranking)
 */
export function getFreshnessScore(updatedAt: string): number {
    const daysSince = getDaysSinceUpdate(updatedAt);

    if (daysSince <= 7) return 100;
    if (daysSince <= 14) return 90;
    if (daysSince <= 30) return 80;
    if (daysSince <= 60) return 70;
    if (daysSince <= 90) return 60;
    if (daysSince <= 180) return 40;
    return 20;
}

/**
 * Check if content should be auto-updated for freshness
 * Useful for evergreen content refresh strategy
 */
export function shouldAutoRefreshContent(
    updatedAt: string,
    views: number,
    isEvergreen: boolean = true
): boolean {
    if (!isEvergreen) return false;

    const daysSince = getDaysSinceUpdate(updatedAt);
    const refreshThreshold = 45; // 45 days for evergreen content

    // Refresh high-traffic evergreen content more frequently
    if (views > 200) {
        return daysSince > 30;
    }

    // Standard refresh threshold
    return daysSince > refreshThreshold;
}

/**
 * Generate recommendations for content team
 */
export function generateContentRefreshPlan(
    posts: Array<{
        id: number;
        title: string;
        updatedAt: string;
        views: number;
    }>
): Array<{
    postId: number;
    title: string;
    priority: 'high' | 'medium' | 'low';
    reason: string;
    daysSinceUpdate: number;
}> {
    return posts
        .map((post) => {
            const rec = getRefreshRecommendation(post.updatedAt, post.views);
            return {
                postId: post.id,
                title: post.title,
                priority: rec.priority,
                reason: rec.reason,
                daysSinceUpdate: getDaysSinceUpdate(post.updatedAt),
            };
        })
        .filter((item) => item.priority !== 'low')
        .sort((a, b) => {
            const priorityOrder = { high: 0, medium: 1, low: 2 };
            return priorityOrder[a.priority] - priorityOrder[b.priority];
        });
}

/**
 * Get Last-Modified HTTP header value
 * For improving crawl efficiency
 */
export function getLastModifiedHeader(updatedAt: string): string {
    const date = new Date(updatedAt);
    return date.toUTCString();
}

/**
 * Create ETag for content caching
 * Simple hash of content version
 */
export function generateETag(content: string, updatedAt: string): string {
    const combined = `${content}:${updatedAt}`;
    // Simple string hash for browser compatibility
    let hash = 0;
    for (let i = 0; i < combined.length; i++) {
        const char = combined.charCodeAt(i);
        hash = ((hash << 5) - hash) + char;
        hash = hash & hash; // Convert to 32bit integer
    }
    return Math.abs(hash).toString(16);
}

/**
 * Check if content needs crawl priority
 * Returns true if AI bots should prioritize this content
 */
export function shouldPrioritizeCrawl(
    updatedAt: string,
    views: number,
    isKeyword: boolean = false
): boolean {
    const daysSince = getDaysSinceUpdate(updatedAt);

    // Prioritize very fresh content
    if (daysSince <= 3) return true;

    // Prioritize popular content
    if (views > 500) return true;

    // Prioritize keyword-targeted content
    if (isKeyword && views > 100) return true;

    return false;
}

/**
 * Format freshness for display
 * Human-readable freshness indicator
 */
export function formatFreshness(updatedAt: string): string {
    const daysSince = getDaysSinceUpdate(updatedAt);

    if (daysSince === 0) return 'Updated today';
    if (daysSince === 1) return 'Updated yesterday';
    if (daysSince < 7) return `Updated ${daysSince} days ago`;
    if (daysSince < 30) return `Updated ${Math.floor(daysSince / 7)} weeks ago`;
    if (daysSince < 365) return `Updated ${Math.floor(daysSince / 30)} months ago`;
    return `Updated ${Math.floor(daysSince / 365)} years ago`;
}
