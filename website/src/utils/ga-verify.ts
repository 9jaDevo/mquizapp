/**
 * Google Analytics Verification & Testing Script
 * Run this in the browser console to verify GA4 is working
 */

// Check if GA is loaded
console.log('=== Google Analytics 4 Verification ===\n');

// 1. Check if gtag is available
if (typeof window.gtag === 'function') {
    console.log('✅ gtag() function is available');
} else {
    console.error('❌ gtag() function NOT found');
}

// 2. Check if dataLayer exists
if (window.dataLayer && Array.isArray(window.dataLayer)) {
    console.log('✅ dataLayer is initialized');
    console.log(`   dataLayer has ${window.dataLayer.length} events`);
} else {
    console.error('❌ dataLayer NOT found');
}

// 3. Check environment variables
const gaId = import.meta.env.VITE_GA_TRACKING_ID;
const botId = import.meta.env.VITE_GA_BOT_PROPERTY_ID;

console.log('\n📊 Tracking IDs:');
console.log(`   Primary GA4: ${gaId || '❌ NOT SET'}`);
console.log(`   Bot Property: ${botId || '❌ NOT SET'}`);

// 4. Test event tracking
console.log('\n🧪 Testing Event Tracking...');

if (typeof window.gtag === 'function') {
    // Send test event
    window.gtag('event', 'test_verification', {
        event_category: 'testing',
        event_label: 'GA verification script',
        value: 1
    });
    console.log('✅ Test event sent: "test_verification"');
    console.log('   Check GA4 Real-time reports in ~30 seconds');
} else {
    console.error('❌ Cannot test - gtag not available');
}

// 5. Check page view tracking
console.log('\n📄 Page View Tracking:');
const pageViews = window.dataLayer?.filter(item =>
    item[0] === 'config' || item[0] === 'event' && item[1] === 'page_view'
);
console.log(`   Found ${pageViews?.length || 0} page view events`);

// 6. Check custom dimensions
console.log('\n🏷️ Custom Dimensions:');
const customDims = window.dataLayer?.filter(item => item[0] === 'set');
console.log(`   Found ${customDims?.length || 0} dimension sets`);

// 7. Network requests check
console.log('\n🌐 Network Requests:');
console.log('   Check Network tab for:');
console.log('   - googletagmanager.com/gtag/js');
console.log('   - google-analytics.com/g/collect');

// 8. Instructions
console.log('\n📝 Verification Steps:');
console.log('1. Open GA4 Dashboard: https://analytics.google.com/');
console.log('2. Go to: Reports > Realtime');
console.log('3. You should see this session appear within 30 seconds');
console.log('4. Check Events tab for "test_verification" event');

// 9. Common issues
console.log('\n⚠️ If not working, check:');
console.log('1. Ad blockers disabled');
console.log('2. Browser privacy settings (Allow cookies)');
console.log('3. Network tab for failed requests');
console.log('4. Console for errors');

console.log('\n=== End Verification ===');

// Export for later use
export function verifyGoogleAnalytics() {
    return {
        gtagAvailable: typeof window.gtag === 'function',
        dataLayerExists: !!window.dataLayer,
        trackingId: import.meta.env.VITE_GA_TRACKING_ID,
        eventCount: window.dataLayer?.length || 0
    };
}

// Auto-run on load
if (typeof window !== 'undefined') {
    console.log('\n💡 Tip: Run verifyGoogleAnalytics() anytime to check status');
}
