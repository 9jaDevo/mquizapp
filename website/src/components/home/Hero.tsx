import React from 'react';
import { motion } from 'framer-motion';
import { Download, Play } from 'lucide-react';
import GlassButton from '../common/GlassButton';
import GlassCard from '../common/GlassCard';
import appMockup from '../../assets/hero-mockup.webp';

const Hero: React.FC = () => {
  return (
    <section className="relative min-h-screen flex items-center justify-center overflow-hidden">
      {/* Animated Background */}
      <div className="absolute inset-0 bg-gradient-to-br from-primary/10 via-secondary/10 to-accent/10">
        <div className="absolute top-20 left-10 w-72 h-72 bg-primary/20 rounded-full blur-3xl animate-pulse" />
        <div className="absolute bottom-20 right-10 w-96 h-96 bg-secondary/20 rounded-full blur-3xl animate-pulse delay-1000" />
        <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-80 h-80 bg-accent/20 rounded-full blur-3xl animate-pulse delay-500" />
      </div>

      <div className="container-custom relative z-10 py-20">
        <GlassCard className="p-8 md:p-12" blur="xl">
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-12 items-center">
            {/* Left Content */}
            <motion.div
              initial={{ opacity: 0, x: -60 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ duration: 0.8 }}
              className="space-y-6"
            >
              <motion.h1
                className="text-4xl md:text-5xl lg:text-6xl font-heading font-bold"
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.2 }}
              >
                Learn, <span className="gradient-text">Engage</span>, and{' '}
                <span className="gradient-text">Earn Rewards</span>
              </motion.h1>

              <motion.p
                className="text-lg md:text-xl text-slate-600 dark:text-slate-300"
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.4 }}
              >
                Join mQuiz, the ultimate quiz learning platform where knowledge meets rewards. Challenge yourself, compete with friends, and earn real gems while you learn.
              </motion.p>

              <motion.div
                className="flex flex-col sm:flex-row gap-4"
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.6 }}
              >
                <GlassButton
                  variant="primary"
                  size="lg"
                  icon={<Download className="w-5 h-5" />}
                  href="/download"
                >
                  Download Now
                </GlassButton>
                <GlassButton
                  variant="outline"
                  size="lg"
                  icon={<Play className="w-5 h-5" />}
                >
                  Watch Demo
                </GlassButton>
              </motion.div>

              {/* Stats Preview */}
              <motion.div
                className="grid grid-cols-3 gap-6 pt-8 border-t border-white/20"
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                transition={{ delay: 0.8 }}
              >
                <div>
                  <p className="text-2xl md:text-3xl font-bold gradient-text">10K+</p>
                  <p className="text-sm text-slate-600 dark:text-slate-400">Active Users</p>
                </div>
                <div>
                  <p className="text-2xl md:text-3xl font-bold gradient-text">50K+</p>
                  <p className="text-sm text-slate-600 dark:text-slate-400">Lessons</p>
                </div>
                <div>
                  <p className="text-2xl md:text-3xl font-bold gradient-text">25K+</p>
                  <p className="text-sm text-slate-600 dark:text-slate-400">Quiz Battles</p>
                </div>
              </motion.div>
            </motion.div>

            {/* Right Content - App Mockup Image */}
            <motion.div
              initial={{ opacity: 0, x: 60 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ duration: 0.8, delay: 0.2 }}
              className="flex justify-center"
            >
              <div className="relative w-full max-w-sm">
                <div className="absolute -top-6 -left-8 w-40 h-40 rounded-full bg-gradient-to-br from-primary/40 to-secondary/30 blur-3xl" />
                <div className="absolute -bottom-10 -right-10 w-48 h-48 rounded-full bg-gradient-to-br from-accent/40 to-primary/20 blur-3xl" />
                <div className="relative rounded-[32px] overflow-hidden shadow-2xl border border-white/30 dark:border-slate-800/60 bg-slate-50/60 dark:bg-slate-900/40 backdrop-blur-xl">
                  <img
                    src={appMockup}
                    alt="mQuiz app mockup"
                    className="w-full h-full object-contain"
                  />
                </div>
              </div>
            </motion.div>
          </div>
        </GlassCard>
      </div>

      {/* Scroll Indicator */}
      <motion.div
        className="absolute bottom-10 left-1/2 -translate-x-1/2"
        initial={{ opacity: 0 }}
        animate={{ opacity: 1, y: [0, 10, 0] }}
        transition={{ delay: 1, y: { duration: 1.5, repeat: Infinity } }}
      >
        <div className="w-6 h-10 rounded-full border-2 border-slate-400 dark:border-slate-600 flex justify-center pt-2">
          <div className="w-1 h-2 bg-slate-400 dark:bg-slate-600 rounded-full" />
        </div>
      </motion.div>
    </section>
  );
};

export default Hero;
