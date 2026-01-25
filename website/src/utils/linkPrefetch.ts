/**
 * Link Prefetch Utility
 * Resource prefetching strategies for improved crawl and user performance
 */

import { getBotDetection } from './botDetection';

/**
 * Prefetch a resource (low priority)
 * Used for future page navigation
 * 
 * @param url URL to prefetch
 */
export function prefetchLink(url: string): void {
    if (!isResourceHintSupported('prefetch')) {
        return;
    }

    const link = document.createElement('link');
    link.rel = 'prefetch';
    link.href = url;
    link.as = 'fetch';
    link.crossOrigin = 'anonymous';
    document.head.appendChild(link);
}

/**
 * Preload a resource (high priority)
 * Used for critical resources needed soon
 * 
 * @param url URL to preload
 * @param type Resource type (script, style, image, etc.)
 */
export function preloadResource(url: string, type: string = 'fetch'): void {
    if (!isResourceHintSupported('preload')) {
        return;
    }

    const link = document.createElement('link');
    link.rel = 'preload';
    link.href = url;
    link.as = type;
    link.crossOrigin = 'anonymous';
    document.head.appendChild(link);
}

/**
 * DNS prefetch for domain
 * Performs DNS lookup in advance
 * 
 * @param domain Domain to prefetch DNS
 */
export function dnsPrefetch(domain: string): void {
    if (!isResourceHintSupported('dns-prefetch')) {
        return;
    }

    const link = document.createElement('link');
    link.rel = 'dns-prefetch';
    link.href = domain;
    document.head.appendChild(link);
}

/**
 * Preconnect to domain
 * Establishes early connection (DNS, TCP, TLS)
 * 
 * @param domain Domain to preconnect
 * @param crossOrigin Should include crossOrigin attribute
 */
export function preconnect(domain: string, crossOrigin: boolean = true): void {
    if (!isResourceHintSupported('preconnect')) {
        return;
    }

    const link = document.createElement('link');
    link.rel = 'preconnect';
    link.href = domain;
    if (crossOrigin) {
        link.crossOrigin = 'anonymous';
    }
    document.head.appendChild(link);
}

/**
 * Check if resource hint is supported by browser
 */
function isResourceHintSupported(hint: string): boolean {
    // All modern browsers support resource hints
    // This is a safety check for older browsers
    if (typeof document === 'undefined') {
        return false;
    }

    const link = document.createElement('link');
    return (link.relList && link.relList.supports(hint)) || true;
}

/**
 * Adaptive prefetch strategy based on user connectivity
 * Respects user's save-data preference
 * 
 * @param url URL to prefetch
 */
export function adaptivePrefetch(url: string): void {
    // Check for save-data preference
    if (shouldSaveData()) {
        return; // Skip prefetch for users on slow connections
    }

    // Check for 4G+ connection
    const connection = getEffectiveConnection();
    if (
        connection === '4g' ||
        connection === '5g' ||
        connection === 'broadband'
    ) {
        prefetchLink(url);
    }
}

/**
 * Get effective connection type
 * Modern browsers provide this information
 */
function getEffectiveConnection(): string {
    const nav = navigator as any;
    if (!nav.connection && !nav.mozConnection && !nav.webkitConnection) {
        return 'unknown';
    }

    const connection =
        nav.connection || nav.mozConnection || nav.webkitConnection;
    return connection.effectiveType || 'unknown';
}

/**
 * Check if user has save-data enabled
 * Respects user's network preference
 */
function shouldSaveData(): boolean {
    const nav = navigator as any;
    return nav.connection?.saveData === true;
}

/**
 * Prefetch next page in pagination
 * Useful for blog listing pages
 * 
 * @param url Next page URL
 */
export function prefetchNextPage(url: string): void {
    // Only prefetch for human users
    const botDetection = getBotDetection();
    if (botDetection.isBot) {
        return;
    }

    adaptivePrefetch(url);
}

/**
 * Prefetch related content
 * Used on article/blog pages
 * 
 * @param urls Array of related content URLs
 */
export function prefetchRelatedContent(urls: string[]): void {
    // Only prefetch for human users
    const botDetection = getBotDetection();
    if (botDetection.isBot) {
        return;
    }

    urls.forEach((url) => {
        adaptivePrefetch(url);
    });
}

/**
 * Initialize resource hints for critical domains
 * Call this early in app initialization
 */
export function initializeResourceHints(): void {
    // API domain
    preconnect('https://mquiz.uk', true);

    // Google services
    preconnect('https://www.google-analytics.com', true);
    preconnect('https://www.googletagmanager.com', true);

    // CDN domains
    dnsPrefetch('https://cdn.jsdelivr.net');

    // Social media domains
    dnsPrefetch('https://platform.twitter.com');
    dnsPrefetch('https://connect.facebook.net');
}

/**
 * Prefetch all links on page on demand
 * Used for SPA navigation patterns
 * Only works for human users (not bots)
 * 
 * @param selector CSS selector for links to prefetch
 */
export function prefetchPageLinks(selector: string = 'a[href^="/"]'): void {
    const botDetection = getBotDetection();
    if (botDetection.isBot) {
        return;
    }

    const links = document.querySelectorAll<HTMLAnchorElement>(selector);

    links.forEach((link) => {
        // Create intersection observer for lazy prefetch
        const observer = new IntersectionObserver(
            (entries) => {
                entries.forEach((entry) => {
                    if (entry.isIntersecting) {
                        prefetchLink(link.href);
                        observer.unobserve(link);
                    }
                });
            },
            { rootMargin: '50px' }
        );

        observer.observe(link);
    });
}

/**
 * Create resource hint for critical images
 * Preload above-the-fold images
 * 
 * @param imageSrc Image source URL
 */
export function preloadImage(imageSrc: string): void {
    preloadResource(imageSrc, 'image');
}

/**
 * Estimate network quality for resource loading decisions
 */
export interface NetworkQuality {
    effectiveType: string;
    downlink: number;
    rtt: number;
    saveData: boolean;
}

/**
 * Get current network quality metrics
 */
export function getNetworkQuality(): NetworkQuality {
    const nav = navigator as any;
    const connection = nav.connection || nav.mozConnection || nav.webkitConnection;

    if (!connection) {
        return {
            effectiveType: 'unknown',
            downlink: 0,
            rtt: 0,
            saveData: false,
        };
    }

    return {
        effectiveType: connection.effectiveType || 'unknown',
        downlink: connection.downlink || 0,
        rtt: connection.rtt || 0,
        saveData: connection.saveData || false,
    };
}
