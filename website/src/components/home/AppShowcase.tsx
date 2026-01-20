import React from 'react';
import { motion } from 'framer-motion';
import GlassCard from '../common/GlassCard';

const AppShowcase: React.FC = () => {
  return (
    <section className="section-padding">
      <div className="container-custom">
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-12 items-center">
          {/* Left Content */}
          <motion.div
            initial={{ opacity: 0, x: -60 }}
            whileInView={{ opacity: 1, x: 0 }}
            viewport={{ once: true }}
          >
            <h2 className="text-3xl md:text-4xl lg:text-5xl font-heading font-bold mb-6">
              Experience Learning <span className="gradient-text">Anywhere, Anytime</span>
            </h2>
            <p className="text-lg text-slate-600 dark:text-slate-300 mb-8">
              Our mobile app brings the power of interactive learning to your fingertips.
              Study on the go, compete in real-time battles, and track your progress
              seamlessly across all devices.
            </p>
            <ul className="space-y-4">
              {[
                'Offline mode for learning without internet',
                'Push notifications for quiz battles',
                'Synced progress across all devices',
                'Beautiful, intuitive interface',
              ].map((feature, index) => (
                <motion.li
                  key={index}
                  className="flex items-center gap-3"
                  initial={{ opacity: 0, x: -20 }}
                  whileInView={{ opacity: 1, x: 0 }}
                  viewport={{ once: true }}
                  transition={{ delay: index * 0.1 }}
                >
                  <div className="w-6 h-6 rounded-full bg-gradient-to-br from-primary to-secondary flex items-center justify-center flex-shrink-0">
                    <svg
                      className="w-4 h-4 text-white"
                      fill="none"
                      stroke="currentColor"
                      viewBox="0 0 24 24"
                    >
                      <path
                        strokeLinecap="round"
                        strokeLinejoin="round"
                        strokeWidth={2}
                        d="M5 13l4 4L19 7"
                      />
                    </svg>
                  </div>
                  <span className="text-slate-700 dark:text-slate-300">
                    {feature}
                  </span>
                </motion.li>
              ))}
            </ul>
          </motion.div>

          {/* Right Content - App Preview */}
          <motion.div
            initial={{ opacity: 0, x: 60 }}
            whileInView={{ opacity: 1, x: 0 }}
            viewport={{ once: true }}
            className="flex justify-center"
          >
            <GlassCard className="p-8 w-full max-w-md" blur="xl">
              <div className="aspect-[9/16] bg-gradient-to-br from-primary/20 via-secondary/20 to-accent/20 rounded-2xl flex items-center justify-center">
                <div className="text-center p-8">
                  <div className="w-24 h-24 mx-auto mb-4 rounded-2xl bg-gradient-to-br from-primary to-secondary flex items-center justify-center">
                    <span className="text-4xl font-bold text-white">m</span>
                  </div>
                  <p className="text-xl font-heading font-bold gradient-text">
                    App Screenshot
                  </p>
                  <p className="text-sm text-slate-600 dark:text-slate-400 mt-2">
                    Coming Soon
                  </p>
                </div>
              </div>
            </GlassCard>
          </motion.div>
        </div>
      </div>
    </section>
  );
};

export default AppShowcase;
