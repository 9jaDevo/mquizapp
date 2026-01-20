import React from 'react';
import { motion } from 'framer-motion';
import {
  Trophy,
  Coins,
  Swords,
  TrendingUp,
  Users,
  Moon,
  Smartphone,
  Grid3x3,
} from 'lucide-react';
import GlassCard from '../common/GlassCard';

const features = [
  {
    icon: Trophy,
    title: 'Gamified Learning',
    description:
      'Turn education into an exciting game with achievements, levels, and rewards.',
  },
  {
    icon: Coins,
    title: 'Real Rewards & Gems',
    description:
      'Earn gems for correct answers and redeem them for real-world rewards.',
  },
  {
    icon: Swords,
    title: 'P2P Quiz Battles',
    description:
      'Challenge friends and players worldwide in real-time quiz competitions.',
  },
  {
    icon: TrendingUp,
    title: 'Progress Tracking',
    description:
      'Monitor your learning journey with detailed analytics and insights.',
  },
  {
    icon: Users,
    title: 'Referral System',
    description:
      'Invite friends and earn bonus gems for every successful referral.',
  },
  {
    icon: Moon,
    title: 'Dark/Light Mode',
    description:
      'Switch between themes for comfortable learning day or night.',
  },
  {
    icon: Smartphone,
    title: 'Mobile Optimized',
    description:
      'Seamless experience across all devices - phone, tablet, or desktop.',
  },
  {
    icon: Grid3x3,
    title: 'Multi-Category',
    description:
      'Choose from diverse quiz categories including science, history, and more.',
  },
];

const containerVariants = {
  hidden: { opacity: 0 },
  visible: {
    opacity: 1,
    transition: {
      staggerChildren: 0.1,
    },
  },
};

const itemVariants = {
  hidden: { opacity: 0, y: 20 },
  visible: {
    opacity: 1,
    y: 0,
    transition: {
      duration: 0.5,
    },
  },
};

const Features: React.FC = () => {
  return (
    <section className="section-padding">
      <div className="container-custom">
        {/* Section Header */}
        <motion.div
          className="text-center max-w-3xl mx-auto mb-16"
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.6 }}
        >
          <h2 className="text-3xl md:text-4xl lg:text-5xl font-heading font-bold mb-6">
            Powerful Features for <span className="gradient-text">Better Learning</span>
          </h2>
          <p className="text-lg text-slate-600 dark:text-slate-300">
            Discover the amazing features that make mQuiz the ultimate learning
            companion for students and quiz enthusiasts.
          </p>
        </motion.div>

        {/* Features Grid */}
        <motion.div
          className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6"
          variants={containerVariants}
          initial="hidden"
          whileInView="visible"
          viewport={{ once: true, margin: '-100px' }}
        >
          {features.map((feature, index) => {
            const Icon = feature.icon;
            return (
              <motion.div key={index} variants={itemVariants}>
                <GlassCard
                  className="p-6 h-full hover:shadow-glass-lg"
                  blur="md"
                  hover
                >
                  <div className="flex flex-col items-center text-center space-y-4">
                    <div className="w-16 h-16 rounded-2xl bg-gradient-to-br from-primary/20 to-secondary/20 flex items-center justify-center">
                      <Icon className="w-8 h-8 text-primary dark:text-accent" />
                    </div>
                    <h3 className="text-xl font-heading font-semibold text-slate-900 dark:text-white">
                      {feature.title}
                    </h3>
                    <p className="text-sm text-slate-600 dark:text-slate-400">
                      {feature.description}
                    </p>
                  </div>
                </GlassCard>
              </motion.div>
            );
          })}
        </motion.div>
      </div>
    </section>
  );
};

export default Features;
