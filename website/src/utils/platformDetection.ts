/**
 * Platform Detection Utilities
 * Detects user's device platform and provides navigation helpers
 */

export type Platform = 'android' | 'ios' | 'desktop' | 'unknown';

/**
 * Detect user's platform based on user agent
 */
export function detectPlatform(): Platform {
    if (typeof window === 'undefined') return 'unknown';

    const userAgent = navigator.userAgent || navigator.vendor || (window as any).opera;

    // Android detection
    if (/android/i.test(userAgent)) {
        return 'android';
    }

    // iOS detection
    if (/iPad|iPhone|iPod/.test(userAgent) && !(window as any).MSStream) {
        return 'ios';
    }

    // Desktop
    return 'desktop';
}

/**
 * Check if device is mobile (Android or iOS)
 */
export function isMobile(): boolean {
    const platform = detectPlatform();
    return platform === 'android' || platform === 'ios';
}

/**
 * Check if device is Android
 */
export function isAndroid(): boolean {
    return detectPlatform() === 'android';
}

/**
 * Check if device is iOS
 */
export function isIOS(): boolean {
    return detectPlatform() === 'ios';
}

/**
 * Get platform-specific display name
 */
export function getPlatformName(platform: Platform): string {
    const names: Record<Platform, string> = {
        android: 'Android',
        ios: 'iOS',
        desktop: 'Desktop',
        unknown: 'Unknown Device'
    };
    return names[platform];
}
