/**
 * App Store URLs Configuration
 * Centralized store links for easy updates
 */

export const STORE_URLS = {
    // Google Play Store URL
    playStore: 'https://play.google.com/store/apps/details?id=com.togafrica.mquiz&pcampaignid=web_share',

    // Apple App Store URL (when available)
    appStore: 'https://apps.apple.com/app/mquiz',

    // QR Code images (relative to public folder)
    playStoreQR: '/images/qr-playstore.png',
    appStoreQR: '/images/qr-appstore.png',
} as const;

export const APP_INFO = {
    name: 'mQuiz',
    tagline: 'Learn Smart, Earn Real Cash',
    minAndroidVersion: '5.0',
    minIOSVersion: '12.0',
    size: '25 MB',
} as const;
