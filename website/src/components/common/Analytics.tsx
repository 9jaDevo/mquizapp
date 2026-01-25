import React, { useEffect } from 'react';
import { initializeAnalytics } from '../../utils/analytics';
import { initializeBotDetection } from '../../utils/botDetection';
import { initializeResourceHints } from '../../utils/linkPrefetch';

interface AnalyticsProps {
  gaTrackingId: string;
  botTrackingId?: string;
  enableBotTracking?: boolean;
  enableCoreWebVitals?: boolean;
  debug?: boolean;
}

/**
 * Analytics Component
 * Initializes Google Analytics 4 with bot traffic isolation
 * Should be placed near root of app (in main layout)
 * 
 * Usage:
 * <Analytics 
 *   gaTrackingId={import.meta.env.VITE_GA_TRACKING_ID}
 *   enableBotTracking={true}
 *   debug={import.meta.env.DEV}
 * />
 */
const Analytics: React.FC<AnalyticsProps> = ({
  gaTrackingId,
  botTrackingId,
  enableBotTracking = true,
  enableCoreWebVitals = true,
  debug = false,
}) => {
  useEffect(() => {
    // Initialize bot detection globally
    initializeBotDetection();

    // Initialize resource hints for performance
    initializeResourceHints();

    // Only initialize analytics if tracking ID is provided
    if (!gaTrackingId) {
      console.warn('[Analytics] No tracking ID provided, skipping initialization');
      return;
    }

    // Initialize analytics with configuration
    initializeAnalytics({
      gaTrackingId,
      botTrackingPropertyId: botTrackingId,
      enableBotTracking,
      enableCoreWebVitals,
      debug,
    }).catch((error) => {
      console.error('[Analytics] Failed to initialize:', error);
    });
  }, [gaTrackingId, botTrackingId, enableBotTracking, enableCoreWebVitals, debug]);

  // Component doesn't render anything
  return null;
};

export default Analytics;
