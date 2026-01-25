/**
 * Bot Detection Utility
 * Industrial-standard bot signature detection
 * Compliant with: Google, OpenAI, Anthropic, Perplexity bot standards
 */

/**
 * Comprehensive bot signatures by category
 * Last updated: January 2026
 */
const BOT_SIGNATURES = {
    // Search Engine Bots
    search_engine: [
        'googlebot',
        'googlebot-image',
        'googlebot-mobile',
        'googlebot-news',
        'googlebot-video',
        'bingbot',
        'msnbot',
        'slurp',
        'duckduckbot',
        'baiduspider',
        'yandexbot',
        'sogou',
        'ia_archiver',
        'exabot',
        'facebookexternalhit',
    ],

    // AI Model Training Bots
    ai_model: [
        'gptbot', // OpenAI GPT bot
        'chatgpt-user', // ChatGPT user agent
        'ccbot', // Common Crawl
        'anthropic-ai', // Anthropic Claude
        'perplexitybot', // Perplexity AI
        'claudebot', // Explicit Claude bot
        'applebot-extended', // Apple extended bot
        'othersideai', // Other side AI
        'diffbot', // Diffbot
        'openai-gpt-bot',
        'llm-bot',
        'aibot',
    ],

    // Social Media Bots
    social_media: [
        'twitterbot',
        'linkedinbot',
        'whatsapp',
        'slackbot',
        'discordbot',
        'telegrambot',
        'pinterestbot',
        'facebookbot',
        'redditbot',
    ],

    // Other crawlers
    other: [
        'curl',
        'wget',
        'python',
        'java',
        'node',
        'scrapy',
        'semrush',
        'ahrefs',
        'moz',
    ],
};

/**
 * Bot detection result interface
 */
export interface BotDetectionResult {
    isBot: boolean;
    botType: 'search' | 'ai' | 'social' | 'other' | 'unknown';
    botName: string;
    botSignature: string;
}

/**
 * Detect if current request is from a bot
 * Uses navigator.userAgent for client-side detection
 * 
 * @returns BotDetectionResult with bot information
 */
export function detectBot(): BotDetectionResult {
    const userAgent = navigator.userAgent || '';
    const userAgentLower = userAgent.toLowerCase();

    // Check against all bot signatures
    for (const [category, signatures] of Object.entries(BOT_SIGNATURES)) {
        for (const signature of signatures) {
            if (userAgentLower.includes(signature)) {
                return {
                    isBot: true,
                    botType: mapCategoryToBotType(category),
                    botName: extractBotName(userAgent),
                    botSignature: signature,
                };
            }
        }
    }

    // No bot detected
    return {
        isBot: false,
        botType: 'unknown',
        botName: 'human',
        botSignature: '',
    };
}

/**
 * Map category string to BotType
 */
function mapCategoryToBotType(
    category: string
): 'search' | 'ai' | 'social' | 'other' | 'unknown' {
    const mapping: Record<string, 'search' | 'ai' | 'social' | 'other' | 'unknown'> = {
        search_engine: 'search',
        ai_model: 'ai',
        social_media: 'social',
        other: 'other',
    };
    return mapping[category] || 'unknown';
}

/**
 * Extract readable bot name from user agent
 * Attempts to parse bot name from User-Agent string
 */
function extractBotName(userAgent: string): string {
    // GPTBot specific handling
    if (userAgent.includes('GPTBot')) return 'GPTBot';
    if (userAgent.includes('ChatGPT-User')) return 'ChatGPT-User';
    if (userAgent.includes('CCBot')) return 'CCBot';
    if (userAgent.includes('anthropic-ai')) return 'Anthropic';
    if (userAgent.includes('PerplexityBot')) return 'PerplexityBot';
    if (userAgent.includes('ClaudeBot')) return 'ClaudeBot';

    // Search engine bots
    if (userAgent.includes('Googlebot')) return 'Googlebot';
    if (userAgent.includes('Bingbot')) return 'Bingbot';
    if (userAgent.includes('DuckDuckBot')) return 'DuckDuckBot';
    if (userAgent.includes('Baiduspider')) return 'Baiduspider';
    if (userAgent.includes('YandexBot')) return 'YandexBot';

    // Social media bots
    if (userAgent.includes('facebookexternalhit')) return 'Facebook';
    if (userAgent.includes('Twitterbot')) return 'Twitter';
    if (userAgent.includes('LinkedInBot')) return 'LinkedIn';
    if (userAgent.includes('Slackbot')) return 'Slack';

    // Fallback: extract from parentheses pattern
    const match = userAgent.match(/\(([^)]+)\)/);
    return match ? match[1].split(';')[0] : 'unknown';
}

/**
 * Check if bot should have special treatment
 * Prioritized bots: AI bots, search engines
 * 
 * @param detection Bot detection result
 * @returns true if bot should receive priority handling
 */
export function shouldPrioritizeBot(detection: BotDetectionResult): boolean {
    return detection.isBot && (detection.botType === 'ai' || detection.botType === 'search');
}

/**
 * Get cache duration for bot vs human
 * Bots receive shorter cache for fresh content
 * Humans get longer cache for performance
 * 
 * @param detection Bot detection result
 * @returns Cache duration in seconds
 */
export function getCacheDuration(detection: BotDetectionResult): number {
    if (detection.botType === 'ai') {
        return 3600; // 1 hour for AI bots (frequent updates needed)
    } else if (detection.botType === 'search') {
        return 7200; // 2 hours for search engine bots
    } else {
        return 86400; // 24 hours for human users
    }
}

/**
 * Get loading strategy based on bot type
 * 
 * @param detection Bot detection result
 * @returns Loading strategy ('eager' | 'lazy')
 */
export function getLoadingStrategy(
    detection: BotDetectionResult
): 'eager' | 'lazy' {
    return detection.isBot ? 'eager' : 'lazy';
}

/**
 * Get decoding strategy based on bot type
 * 
 * @param detection Bot detection result
 * @returns Decoding strategy ('sync' | 'async')
 */
export function getDecodingStrategy(detection: BotDetectionResult): 'sync' | 'async' {
    return detection.isBot ? 'sync' : 'async';
}

/**
 * Check if request respects DNT (Do Not Track) header
 * Bots typically don't set this header
 * 
 * @returns true if DNT is enabled
 */
export function isDNTEnabled(): boolean {
    return navigator.doNotTrack === '1' || (navigator as any).msDoNotTrack === 1;
}

/**
 * Check if user has explicitly disabled analytics
 * Some bots disable tracking
 * 
 * @returns true if user wants to avoid tracking
 */
export function shouldSkipAnalytics(): boolean {
    return isDNTEnabled() || detectBot().isBot;
}

/**
 * Get analytical dimension for bot type
 * Used for GA4 custom dimension reporting
 * 
 * @param detection Bot detection result
 * @returns Dimension value for analytics
 */
export function getAnalyticsDimension(detection: BotDetectionResult): string {
    if (!detection.isBot) {
        return 'human';
    }

    const dimensionMap: Record<'search' | 'ai' | 'social' | 'other' | 'unknown', string> = {
        search: 'search_bot',
        ai: 'ai_bot',
        social: 'social_bot',
        other: 'other_bot',
        unknown: 'unknown_bot',
    };

    return dimensionMap[detection.botType];
}

/**
 * Create bot fingerprint for tracking
 * Useful for monitoring specific bot behavior over time
 * 
 * @param detection Bot detection result
 * @returns Fingerprint string
 */
export function createBotFingerprint(detection: BotDetectionResult): string {
    if (!detection.isBot) {
        return '';
    }

    return `${detection.botType}:${detection.botSignature}:${detection.botName}`;
}

/**
 * Initialize bot detection and set global flag
 * Call this early in app initialization
 * 
 * @returns Bot detection result
 */
export function initializeBotDetection(): BotDetectionResult {
    const detection = detectBot();

    // Store in window object for access across app
    (window as any).__BOT_DETECTION__ = detection;
    (window as any).__SHOULD_SKIP_ANALYTICS__ = shouldSkipAnalytics();

    return detection;
}

/**
 * Get cached bot detection result
 * Returns previously initialized result without recalculating
 * 
 * @returns Cached bot detection result or re-detect if not cached
 */
export function getBotDetection(): BotDetectionResult {
    return (window as any).__BOT_DETECTION__ || detectBot();
}

/**
 * Export all bot signatures for testing and documentation
 */
export function getAllBotSignatures(): Record<string, string[]> {
    return BOT_SIGNATURES;
}
