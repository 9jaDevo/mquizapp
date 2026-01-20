import React from 'react';
import { motion } from 'framer-motion';
import { Download, UserPlus, Grid3x3, Trophy, Gift } from 'lucide-react';
import GlassCard from '../common/GlassCard';

const steps = [
  {
    icon: Download,
    title: 'Download mQuiz App',
    description: 'Get the app from Google Play Store or App Store.',
  },
  {
    icon: UserPlus,
    title: 'Create Your Account',
    description: 'Sign up in seconds with your email or social accounts.',
  },
  {
    icon: Grid3x3,
    title: 'Choose Your Category',
    description: 'Select from various quiz categories that interest you.',
  },
  {
    icon: Trophy,
    title: 'Start Learning & Earning',
    description: 'Answer questions, compete in battles, and earn gems.',
  },
  {
    icon: Gift,
    title: 'Redeem Your Rewards',
    description: 'Exchange your earned gems for real-world rewards.',
  },
];

const HowItWorks: React.FC = () => {
  return (
    <section className="section-padding">
      <div className="container-custom">
        <motion.div
          className="text-center max-w-3xl mx-auto mb-16"
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
        >
          <h2 className="text-3xl md:text-4xl lg:text-5xl font-heading font-bold mb-6">
            How <span className="gradient-text">It Works</span>
          </h2>
          <p className="text-lg text-slate-600 dark:text-slate-300">
            Get started with mQuiz in just 5 simple steps and begin your learning journey today.
          </p>
        </motion.div>

        <div className="relative">
          {/* Timeline line */}
          <div className="hidden lg:block absolute top-1/2 left-0 right-0 h-0.5 bg-gradient-to-r from-primary via-secondary to-accent -translate-y-1/2" />

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-5 gap-8 relative">
            {steps.map((step, index) => {
              const Icon = step.icon;
              return (
                <motion.div
                  key={index}
                  initial={{ opacity: 0, y: 50 }}
                  whileInView={{ opacity: 1, y: 0 }}
                  viewport={{ once: true }}
                  transition={{ delay: index * 0.1 }}
                  className="relative"
                >
                  <GlassCard className="p-6 text-center h-full" blur="md" hover>
                    <div className="w-16 h-16 mx-auto mb-4 rounded-full bg-gradient-to-br from-primary to-secondary flex items-center justify-center text-white font-bold text-xl">
                      <Icon className="w-8 h-8" />
                    </div>
                    <h3 className="text-lg font-heading font-semibold mb-2 text-slate-900 dark:text-white">
                      {step.title}
                    </h3>
                    <p className="text-sm text-slate-600 dark:text-slate-400">
                      {step.description}
                    </p>
                  </GlassCard>
                </motion.div>
              );
            })}
          </div>
        </div>
      </div>
    </section>
  );
};

export default HowItWorks;
