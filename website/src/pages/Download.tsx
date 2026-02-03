import React, { useEffect, useState } from 'react';
import { motion } from 'framer-motion';
import { Smartphone, Download as DownloadIcon, Clock, CheckCircle, XCircle, Apple } from 'lucide-react';
import SEO from '../components/common/SEO';
import GlassCard from '../components/common/GlassCard';
import GlassButton from '../components/common/GlassButton';
import { detectPlatform, getPlatformName, type Platform } from '../utils/platformDetection';
import { STORE_URLS, APP_INFO } from '../config/stores';
import { trackAnalyticsEvent } from '../utils/analytics';
import { seoConfig } from '../utils/seoConfig';

const Download: React.FC = () => {
  const [platform, setPlatform] = useState<Platform>('unknown');
  const [countdown, setCountdown] = useState(5);
  const [redirectCancelled, setRedirectCancelled] = useState(false);

  useEffect(() => {
    const detectedPlatform = detectPlatform();
    setPlatform(detectedPlatform);

    // Track page view with platform info
    trackAnalyticsEvent('download_page_viewed', {
      platform: detectedPlatform,
    });

    // Auto-redirect Android users after countdown
    if (detectedPlatform === 'android' && !redirectCancelled) {
      const timer = setInterval(() => {
        setCountdown((prev) => {
          if (prev <= 1) {
            clearInterval(timer);
            // Redirect to Play Store
            trackAnalyticsEvent('download_redirect', {
              platform: 'android',
              destination: 'playstore',
            });
            window.location.href = STORE_URLS.playStore;
            return 0;
          }
          return prev - 1;
        });
      }, 1000);

      return () => clearInterval(timer);
    }
  }, [redirectCancelled]);

  const handleCancelRedirect = () => {
    setRedirectCancelled(true);
    trackAnalyticsEvent('download_redirect_cancelled', {
      platform: platform,
    });
  };

  const handleDownloadClick = (store: 'playstore' | 'appstore') => {
    trackAnalyticsEvent('download_button_clicked', {
      platform: platform,
      store: store,
    });
  };

  // Android with countdown
  if (platform === 'android' && !redirectCancelled && countdown > 0) {
    return (
      <>
        <SEO
          title="Download mQuiz for Android - Google Play Store"
          description="Download mQuiz app for free on Google Play Store. Start learning and earning rewards today!"
          url="https://mquiz.uk/download"
        />
        <div className="container-custom section-padding min-h-[70vh] flex items-center justify-center">
          <motion.div
            initial={{ opacity: 0, scale: 0.95 }}
            animate={{ opacity: 1, scale: 1 }}
            className="max-w-2xl mx-auto text-center"
          >
            <GlassCard className="p-12">
              <div className="w-20 h-20 bg-gradient-to-br from-primary to-primary-dark rounded-full flex items-center justify-center mx-auto mb-6 animate-pulse">
                <Smartphone className="w-10 h-10 text-white" />
              </div>
              
              <h1 className="text-3xl md:text-4xl font-heading font-bold mb-4">
                Redirecting to Play Store...
              </h1>
              
              <p className="text-lg text-slate-600 dark:text-slate-300 mb-8">
                You'll be redirected to Google Play Store in <span className="text-3xl font-bold text-primary">{countdown}</span> seconds
              </p>

              <div className="flex flex-col sm:flex-row gap-4 justify-center">
                <GlassButton
                  variant="primary"
                  size="lg"
                  href={STORE_URLS.playStore}
                  icon={<DownloadIcon className="w-5 h-5" />}
                  onClick={() => handleDownloadClick('playstore')}
                >
                  Download Now
                </GlassButton>
                
                <GlassButton
                  variant="secondary"
                  size="lg"
                  onClick={handleCancelRedirect}
                  icon={<XCircle className="w-5 h-5" />}
                >
                  Stay on Page
                </GlassButton>
              </div>
            </GlassCard>
          </motion.div>
        </div>
      </>
    );
  }

  // Android after cancel or iOS/Desktop view
  return (
    <>
      <SEO
        title={seoConfig.download.title}
        description={seoConfig.download.description}
        keywords={seoConfig.download.keywords}
        url="https://mquiz.uk/download"
        type={seoConfig.download.type}
      />
      
      <div className="container-custom section-padding">
        {/* Header */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="text-center mb-16"
        >
          <h1 className="text-4xl md:text-5xl lg:text-6xl font-heading font-bold mb-6 gradient-text">
            Download {APP_INFO.name}
          </h1>
          <p className="text-xl text-slate-600 dark:text-slate-300 max-w-2xl mx-auto">
            {APP_INFO.tagline} - Available on your favorite devices
          </p>
        </motion.div>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-8 max-w-5xl mx-auto">
          {/* Android Card */}
          <motion.div
            initial={{ opacity: 0, x: -20 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ delay: 0.1 }}
          >
            <GlassCard className="p-8 h-full flex flex-col">
              <div className="flex items-center gap-4 mb-6">
                <div className="w-16 h-16 bg-gradient-to-br from-green-500 to-green-600 rounded-2xl flex items-center justify-center">
                  <Smartphone className="w-8 h-8 text-white" />
                </div>
                <div>
                  <h2 className="text-2xl font-heading font-bold">Android</h2>
                  <p className="text-sm text-slate-500 dark:text-slate-400">
                    Version {APP_INFO.minAndroidVersion}+
                  </p>
                </div>
              </div>

              <div className="flex items-center gap-2 text-green-600 dark:text-green-400 mb-4">
                <CheckCircle className="w-5 h-5" />
                <span className="font-semibold">Available Now</span>
              </div>

              <p className="text-slate-600 dark:text-slate-300 mb-6 flex-grow">
                Download mQuiz for Android from Google Play Store. Start your learning journey and earn real cash rewards today!
              </p>

              <div className="space-y-3">
                <GlassButton
                  variant="primary"
                  fullWidth
                  size="lg"
                  href={STORE_URLS.playStore}
                  icon={<DownloadIcon className="w-5 h-5" />}
                  onClick={() => handleDownloadClick('playstore')}
                >
                  Download on Play Store
                </GlassButton>
                
                <div className="text-center">
                  <p className="text-sm text-slate-500 dark:text-slate-400">
                    Size: {APP_INFO.size} • Free
                  </p>
                </div>
              </div>
            </GlassCard>
          </motion.div>

          {/* iOS Card */}
          <motion.div
            initial={{ opacity: 0, x: 20 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ delay: 0.2 }}
          >
            <GlassCard className="p-8 h-full flex flex-col relative overflow-hidden">
              {/* Coming Soon Badge */}
              <div className="absolute top-4 right-4">
                <div className="px-3 py-1 bg-gradient-to-r from-primary/20 to-primary-dark/20 backdrop-blur-sm rounded-full border border-primary/30">
                  <span className="text-xs font-semibold text-primary dark:text-primary-light flex items-center gap-1">
                    <Clock className="w-3 h-3" />
                    Coming Soon
                  </span>
                </div>
              </div>

              <div className="flex items-center gap-4 mb-6">
                <div className="w-16 h-16 bg-gradient-to-br from-slate-700 to-slate-900 rounded-2xl flex items-center justify-center">
                  <Apple className="w-8 h-8 text-white" />
                </div>
                <div>
                  <h2 className="text-2xl font-heading font-bold">iOS</h2>
                  <p className="text-sm text-slate-500 dark:text-slate-400">
                    Version {APP_INFO.minIOSVersion}+
                  </p>
                </div>
              </div>

              <div className="flex items-center gap-2 text-amber-600 dark:text-amber-400 mb-4">
                <Clock className="w-5 h-5" />
                <span className="font-semibold">In Development</span>
              </div>

              <p className="text-slate-600 dark:text-slate-300 mb-6 flex-grow">
                We're working hard to bring mQuiz to iOS devices. Stay tuned for the App Store release!
              </p>

              <div className="space-y-3">
                <GlassButton
                  variant="secondary"
                  fullWidth
                  size="lg"
                  disabled
                  icon={<Apple className="w-5 h-5" />}
                >
                  App Store (Coming Soon)
                </GlassButton>
                
                <div className="text-center">
                  <p className="text-sm text-slate-500 dark:text-slate-400">
                    Follow us for updates
                  </p>
                </div>
              </div>
            </GlassCard>
          </motion.div>
        </div>

        {/* Features Section */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.3 }}
          className="mt-16 text-center"
        >
          <h3 className="text-2xl font-heading font-bold mb-8">Why Download {APP_INFO.name}?</h3>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6 max-w-4xl mx-auto">
            {[
              { icon: '🎓', title: 'Learn Anywhere', desc: 'Access thousands of questions on the go' },
              { icon: '💰', title: 'Earn Rewards', desc: 'Win real cash prizes and redeemable vouchers' },
              { icon: '🏆', title: 'Compete & Win', desc: 'Challenge friends and top the leaderboards' },
            ].map((feature, i) => (
              <GlassCard key={i} className="p-6 text-center">
                <div className="text-4xl mb-3">{feature.icon}</div>
                <h4 className="font-semibold mb-2">{feature.title}</h4>
                <p className="text-sm text-slate-600 dark:text-slate-400">{feature.desc}</p>
              </GlassCard>
            ))}
          </div>
        </motion.div>

        {/* Platform Detection Info (for debugging/transparency) */}
        {platform !== 'unknown' && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ delay: 0.5 }}
            className="mt-12 text-center"
          >
            <p className="text-sm text-slate-400">
              Detected: {getPlatformName(platform)}
            </p>
          </motion.div>
        )}
      </div>
    </>
  );
};

export default Download;
