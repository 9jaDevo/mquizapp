/**
 * Analytics Service
 * Google Analytics 4 integration with bot traffic isolation
 * 
 * Architecture:
 * - Primary GA4 property for human traffic
 * - Secondary GA4 property for bot traffic (debug)
 * - Custom dimensions for user_type segmentation
 * - Event tracking for content engagement
 */

import type { BotDetectionResult } from './botDetection';
import { getBotDetection, getAnalyticsDimension, createBotFingerprint } from './botDetection';
import { initializeResourceHints } from './linkPrefetch';

/**
 * Analytics configuration interface
 */
export interface AnalyticsConfig {
    gaTrackingId: string;
    enableBotTracking?: boolean;
    botTrackingPropertyId?: string;
    enableCoreWebVitals?: boolean;
    sampleRate?: number;
    debug?: boolean;
}

/**
 * Analytics event parameters
 */
export interface AnalyticsEventParams {
    event_category?: string;
    event_label?: string;
    value?: number;
    content_type?: string;
    content_id?: string;
    [key: string]: any;
}

/**
 * Analytics Manager Class
 */
class AnalyticsManager {
    private config: AnalyticsConfig;
    private botDetection: BotDetectionResult | null = null;
    private isInitialized: boolean = false;

    constructor(config: AnalyticsConfig) {
        this.config = {
            enableBotTracking: true,
            enableCoreWebVitals: true,
            sampleRate: 100,
            debug: false,
            ...config,
        };
    }

    /**
     * Initialize Google Analytics 4
     * Sets up tracking with bot detection
     */
    public async init(): Promise<void> {
        if (this.isInitialized) {
            return;
        }

        // Initialize bot detection first
        this.botDetection = getBotDetection();

        // Respect DNT header
        if (this.isDNTEnabled()) {
            if (this.config.debug) {
                console.log('[Analytics] DNT enabled, skipping initialization');
            }
            return;
        }

        // Load Google Analytics script
        this.loadGoogleAnalytics();

        // Initialize GA4 with configuration
        this.initializeGA4();

        // Set custom dimensions
        this.setCustomDimensions();

        // Setup event tracking
        this.setupEventTracking();

        // Initialize Core Web Vitals if enabled
        if (this.config.enableCoreWebVitals) {
            this.initializeCoreWebVitals();
        }

        // Prefetch analytics domains
        initializeResourceHints();

        this.isInitialized = true;

        if (this.config.debug) {
            console.log('[Analytics] Initialized with config:', this.config);
            console.log('[Analytics] Bot Detection:', this.botDetection);
        }
    }

    /**
     * Load Google Analytics script dynamically
     */
    private loadGoogleAnalytics(): void {
        const script = document.createElement('script');
        script.async = true;
        script.src = `https://www.googletagmanager.com/gtag/js?id=${this.config.gaTrackingId}`;

        document.head.appendChild(script);

        // Initialize dataLayer
        (window as any).dataLayer = (window as any).dataLayer || [];
        (window as any).gtag = function (..._args: any[]) {
            (window as any).dataLayer.push(arguments);
        };

        // Set default consent mode
        (window as any).gtag('consent', 'default', {
            analytics_storage: 'denied',
            ad_storage: 'denied',
            ad_user_data: 'denied',
            ad_personalization: 'denied',
        });

        // Initialize GA4 with primary tracking ID
        (window as any).gtag('config', this.config.gaTrackingId, {
            allow_google_signals: false,
            allow_ad_personalization_signals: false,
            anonymize_ip: true,
            cookie_flags: 'SameSite=None;Secure',
        });

        if (this.config.debug) {
            console.log('[Analytics] Google Analytics script loaded');
        }
    }

    /**
     * Initialize GA4 with settings
     */
    private initializeGA4(): void {
        const gtag = (window as any).gtag;
        if (!gtag) return;

        // Configure GA4 property
        gtag('config', this.config.gaTrackingId, {
            page_path: window.location.pathname,
            page_title: document.title,
            send_page_view: true,
        });

        // Initialize secondary property for bot traffic if enabled
        if (this.config.enableBotTracking && this.botDetection?.isBot && this.config.botTrackingPropertyId) {
            gtag('config', this.config.botTrackingPropertyId, {
                page_path: window.location.pathname,
                page_title: document.title,
                send_page_view: true,
            });
        }
    }

    /**
     * Set custom dimensions for segmentation
     */
    private setCustomDimensions(): void {
        if (!this.botDetection) return;

        const gtag = (window as any).gtag;
        if (!gtag) return;

        const userType = getAnalyticsDimension(this.botDetection);
        const botFingerprint = createBotFingerprint(this.botDetection);

        gtag('set', {
            user_type: userType,
            bot_name: this.botDetection.botName,
            bot_signature: this.botDetection.botSignature,
            bot_fingerprint: botFingerprint || undefined,
        });

        if (this.config.debug) {
            console.log('[Analytics] Custom dimensions set:', {
                user_type: userType,
                bot_name: this.botDetection.botName,
            });
        }
    }

    /**
     * Setup automatic event tracking
     */
    private setupEventTracking(): void {
        // Track page views (GA4 handles this automatically)

        // Track scroll depth
        this.setupScrollTracking();

        // Track outbound links
        this.setupOutboundLinkTracking();

        // Track time on page
        this.setupTimeOnPageTracking();
    }

    /**
     * Track scroll depth on page
     */
    private setupScrollTracking(): void {
        if (this.botDetection?.isBot) return; // Skip for bots

        const gtag = (window as any).gtag;
        if (!gtag) return;

        let scrollDepthTracked = {
            '25': false,
            '50': false,
            '75': false,
            '100': false,
        };

        const handleScroll = () => {
            const windowHeight = window.innerHeight;
            const documentHeight = document.documentElement.scrollHeight;
            const scrollTop = window.scrollY || document.documentElement.scrollTop;

            const scrollPercentage = Math.round(
                ((scrollTop + windowHeight) / documentHeight) * 100
            );

            (['25', '50', '75', '100'] as const).forEach((threshold) => {
                if (
                    scrollPercentage >= parseInt(threshold) &&
                    !scrollDepthTracked[threshold]
                ) {
                    scrollDepthTracked[threshold] = true;
                    gtag('event', 'scroll_depth', {
                        scroll_depth: parseInt(threshold),
                    });
                }
            });
        };

        window.addEventListener('scroll', handleScroll, { passive: true });
    }

    /**
     * Track outbound link clicks
     */
    private setupOutboundLinkTracking(): void {
        if (this.botDetection?.isBot) return; // Skip for bots

        const gtag = (window as any).gtag;
        if (!gtag) return;

        document.addEventListener('click', (e) => {
            const target = (e.target as HTMLElement).closest('a');
            if (!target) return;

            const href = target.getAttribute('href');
            if (!href) return;

            // Check if outbound
            const isOutbound =
                href.startsWith('http') &&
                !href.includes(window.location.hostname);

            if (isOutbound) {
                gtag('event', 'outbound_click', {
                    link_url: href,
                    link_text: target.textContent?.substring(0, 100) || undefined,
                });
            }
        });
    }

    /**
     * Track time on page
     */
    private setupTimeOnPageTracking(): void {
        if (this.botDetection?.isBot) return; // Skip for bots

        const gtag = (window as any).gtag;
        if (!gtag) return;

        const startTime = Date.now();

        window.addEventListener('beforeunload', () => {
            const timeOnPage = Math.round((Date.now() - startTime) / 1000);
            gtag('event', 'page_engagement', {
                engagement_time_msec: timeOnPage * 1000,
            });
        });
    }

    /**
     * Initialize Core Web Vitals tracking
     */
    private initializeCoreWebVitals(): void {
        try {
            // Dynamic import of web-vitals library
            import('web-vitals').then((vitals: any) => {
                const gtag = (window as any).gtag;
                if (!gtag) return;

                // Largest Contentful Paint
                if (vitals.getLCP) {
                    vitals.getLCP((metric: any) => {
                        gtag('event', 'page_view', {
                            metric_id: metric.id,
                            metric_value: Math.round(metric.value),
                            metric_type: 'LCP',
                        });
                    });
                }

                // Cumulative Layout Shift
                if (vitals.getCLS) {
                    vitals.getCLS((metric: any) => {
                        gtag('event', 'page_view', {
                            metric_id: metric.id,
                            metric_value: Math.round(metric.value * 1000) / 1000,
                            metric_type: 'CLS',
                        });
                    });
                }

                // First Contentful Paint
                if (vitals.getFCP) {
                    vitals.getFCP((metric: any) => {
                        gtag('event', 'page_view', {
                            metric_id: metric.id,
                            metric_value: Math.round(metric.value),
                            metric_type: 'FCP',
                        });
                    });
                }

                // Time to First Byte
                if (vitals.getTTFB) {
                    vitals.getTTFB((metric: any) => {
                        gtag('event', 'page_view', {
                            metric_id: metric.id,
                            metric_value: Math.round(metric.value),
                            metric_type: 'TTFB',
                        });
                    });
                }

                // Interaction to Next Paint (INP) - Replaces FID
                if (vitals.getINP) {
                    vitals.getINP((metric: any) => {
                        gtag('event', 'page_view', {
                            metric_id: metric.id,
                            metric_value: Math.round(metric.value),
                            metric_type: 'INP',
                        });
                    });
                }

                if (this.config.debug) {
                    console.log('[Analytics] Core Web Vitals tracking initialized');
                }
            });
        } catch (error) {
            if (this.config.debug) {
                console.warn('[Analytics] Core Web Vitals library not available:', error);
            }
        }
    }

    /**
     * Track page view
     */
    public trackPageView(path: string, title: string): void {
        if (!this.isInitialized) return;

        const gtag = (window as any).gtag;
        if (!gtag) return;

        gtag('event', 'page_view', {
            page_path: path,
            page_title: title,
        });

        if (this.config.debug) {
            console.log('[Analytics] Page view tracked:', { path, title });
        }
    }

    /**
     * Track custom event
     */
    public trackEvent(eventName: string, params?: AnalyticsEventParams): void {
        if (!this.isInitialized) return;

        const gtag = (window as any).gtag;
        if (!gtag) return;

        // Don't track bots for user engagement events
        if (this.botDetection?.isBot && eventName !== 'page_view') {
            return;
        }

        gtag('event', eventName, params || {});

        if (this.config.debug) {
            console.log('[Analytics] Event tracked:', { eventName, params });
        }
    }

    /**
     * Track blog post engagement
     */
    public trackBlogPostView(postId: string, postTitle: string, readingTime: number): void {
        this.trackEvent('blog_post_viewed', {
            content_type: 'blog_post',
            content_id: postId,
            content_title: postTitle,
            reading_time: readingTime,
        });
    }

    /**
     * Track blog search
     */
    public trackBlogSearch(searchQuery: string): void {
        this.trackEvent('blog_search', {
            search_term: searchQuery,
            content_type: 'blog',
        });
    }

    /**
     * Track content sharing
     */
    public trackContentShare(contentId: string, platform: string): void {
        this.trackEvent('content_share', {
            content_id: contentId,
            platform: platform,
        });
    }

    /**
     * Track category filter
     */
    public trackCategoryFilter(category: string): void {
        this.trackEvent('category_filtered', {
            category: category,
        });
    }

    /**
     * Check DNT header
     */
    private isDNTEnabled(): boolean {
        return navigator.doNotTrack === '1' || (navigator as any).msDoNotTrack === 1;
    }
}

// Export singleton instance
let analyticsInstance: AnalyticsManager | null = null;

/**
 * Get or create analytics manager instance
 */
export function getAnalyticsManager(config?: AnalyticsConfig): AnalyticsManager {
    if (!analyticsInstance && config) {
        analyticsInstance = new AnalyticsManager(config);
    }
    return analyticsInstance!;
}

/**
 * Initialize analytics (convenience function)
 */
export async function initializeAnalytics(config: AnalyticsConfig): Promise<void> {
    const manager = getAnalyticsManager(config);
    await manager.init();
}

/**
 * Track event (convenience function)
 */
export function trackAnalyticsEvent(eventName: string, params?: AnalyticsEventParams): void {
    const manager = getAnalyticsManager();
    if (manager) {
        manager.trackEvent(eventName, params);
    }
}

/**
 * Track page view (convenience function)
 */
export function trackAnalyticsPageView(path: string, title: string): void {
    const manager = getAnalyticsManager();
    if (manager) {
        manager.trackPageView(path, title);
    }
}
