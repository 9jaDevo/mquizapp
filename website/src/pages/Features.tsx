import React, { useState, useEffect } from 'react';
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
  Brain,
  Target,
  Award,
  Sparkles,
  Zap,
  Shield,
  Clock,
  BarChart3,
  BookOpen,
  Headphones,
  Calculator,
  CheckCircle2,
  Globe,
  Play,
} from 'lucide-react';
import SEO from '../components/common/SEO';
import GlassCard from '../components/common/GlassCard';

const mainFeatures = [
  {
    icon: Trophy,
    title: 'Gamified Learning',
    description: 'Turn education into an exciting game with achievements, levels, and rewards that keep you motivated.',
    color: 'from-yellow-500 to-orange-500',
    benefits: ['Achievement badges', 'Level progression', 'Daily streaks', 'Leaderboard rankings'],
  },
  {
    icon: Coins,
    title: 'Real Rewards & Gems',
    description: 'Earn gems for correct answers and redeem them for real-world rewards and premium features.',
    color: 'from-blue-500 to-purple-500',
    benefits: ['Earn gems per quiz', 'Redeem for rewards', 'Bonus multipliers', 'Premium unlocks'],
  },
  {
    icon: Swords,
    title: 'P2P Quiz Battles',
    description: 'Challenge friends and players worldwide in real-time quiz competitions and climb the global rankings.',
    color: 'from-red-500 to-pink-500',
    benefits: ['1v1 battles', 'Group challenges', 'Tournament mode', 'Real-time scoring'],
  },
  {
    icon: TrendingUp,
    title: 'Progress Tracking',
    description: 'Monitor your learning journey with detailed analytics, insights, and personalized recommendations.',
    color: 'from-green-500 to-teal-500',
    benefits: ['Performance analytics', 'Strength analysis', 'Study insights', 'Progress reports'],
  },
];

const quizModes = [
  { icon: Brain, title: 'Quiz Zone', description: 'Challenge yourself with multiple-choice questions across various categories' },
  { icon: Target, title: 'Contest Quiz', description: 'Compete for prizes in timed contests with global participants' },
  { icon: Users, title: 'Group Battle', description: 'Collaborate with friends to score the highest team points' },
  { icon: Swords, title: '1 vs 1 Battle', description: 'Test your knowledge in one-on-one competitive matches' },
  { icon: Clock, title: 'Daily Quiz', description: 'Stay engaged with fresh daily quizzes and maintain your streak' },
  { icon: Sparkles, title: 'Fun \'N\' Learn', description: 'Quick comprehension tests to enhance understanding' },
  { icon: BookOpen, title: 'Guess Word', description: 'Improve vocabulary with interactive word games' },
  { icon: Headphones, title: 'Audio Quiz', description: 'Listen and answer questions based on audio clips' },
  { icon: Calculator, title: 'Math Mania', description: 'Sharpen math skills with algebra, calculus, and geometry' },
  { icon: CheckCircle2, title: 'True | False', description: 'Fast-paced quizzes to test and expand knowledge' },
  { icon: Award, title: 'Exam Quiz', description: 'Prepare for exams with timed practice quizzes' },
  { icon: Zap, title: 'Self-Challenge', description: 'Customize quizzes to match your interests and abilities' },
];

const additionalFeatures = [
  { icon: Users, title: 'Referral System', description: 'Invite friends and earn bonus gems for successful referrals' },
  { icon: Moon, title: 'Dark/Light Mode', description: 'Switch themes for comfortable learning any time' },
  { icon: Smartphone, title: 'Mobile Optimized', description: 'Seamless experience across all devices' },
  { icon: Grid3x3, title: 'Multi-Category', description: 'Diverse quiz categories from science to history' },
  { icon: Shield, title: 'Secure & Private', description: 'Your data is protected with industry-standard security' },
  { icon: Globe, title: 'Global Leaderboard', description: 'See where you stand against players worldwide' },
];

const Features: React.FC = () => {
  useEffect(() => {
    window.scrollTo(0, 0);
  }, []);

  const [activeFeature, setActiveFeature] = useState(0);

  return (
    <>
      <SEO
        title="mQuiz Features - Discover What Makes Us Special"
        description="Explore mQuiz's powerful features including gamified learning, quiz battles, progress tracking, and real rewards."
        url="https://mquiz.uk/features"
      />
      <div className="container-custom section-padding">
        {/* Hero Section */}
        <motion.div
          className="text-center max-w-4xl mx-auto mb-16"
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6 }}
        >
          <h1 className="text-4xl md:text-5xl lg:text-6xl font-heading font-bold mb-6">
            Powerful Features for <span className="gradient-text">Better Learning</span>
          </h1>
          <p className="text-lg md:text-xl text-slate-700 dark:text-slate-300">
            Discover the amazing features that make mQuiz the ultimate learning companion for students and quiz enthusiasts worldwide.
          </p>
        </motion.div>

        {/* Main Features */}
        <section className="mb-20">
          <motion.h2
            className="text-3xl md:text-4xl font-heading font-bold text-center mb-12"
            initial={{ opacity: 0 }}
            whileInView={{ opacity: 1 }}
            viewport={{ once: true }}
          >
            Core <span className="gradient-text">Features</span>
          </motion.h2>
          
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
            {mainFeatures.map((feature, index) => {
              const Icon = feature.icon;
              return (
                <motion.div
                  key={index}
                  initial={{ opacity: 0, y: 30 }}
                  whileInView={{ opacity: 1, y: 0 }}
                  viewport={{ once: true }}
                  transition={{ delay: index * 0.1 }}
                >
                  <GlassCard
                    className="p-8 h-full hover:shadow-glass-xl cursor-pointer"
                    blur="lg"
                    hover
                    onClick={() => setActiveFeature(index)}
                  >
                    <div className={`w-16 h-16 rounded-2xl bg-gradient-to-br ${feature.color} flex items-center justify-center mb-6`}>
                      <Icon className="w-8 h-8 text-white" />
                    </div>
                    <h3 className="text-2xl font-heading font-bold mb-3 text-slate-900 dark:text-white">
                      {feature.title}
                    </h3>
                    <p className="text-slate-700 dark:text-slate-300 mb-6">
                      {feature.description}
                    </p>
                    <div className="space-y-2">
                      {feature.benefits.map((benefit, idx) => (
                        <div key={idx} className="flex items-center gap-2">
                          <CheckCircle2 className="w-5 h-5 text-primary flex-shrink-0" />
                          <span className="text-sm text-slate-700 dark:text-slate-400">{benefit}</span>
                        </div>
                      ))}
                    </div>
                  </GlassCard>
                </motion.div>
              );
            })}
          </div>
        </section>

        {/* Quiz Modes */}
        <section className="mb-20">
          <motion.div
            className="text-center mb-12"
            initial={{ opacity: 0 }}
            whileInView={{ opacity: 1 }}
            viewport={{ once: true }}
          >
            <h2 className="text-3xl md:text-4xl font-heading font-bold mb-4">
              12+ <span className="gradient-text">Quiz Modes</span>
            </h2>
            <p className="text-lg text-slate-700 dark:text-slate-300 max-w-2xl mx-auto">
              Multiple engaging quiz formats designed to suit different learning styles and preferences
            </p>
          </motion.div>

          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
            {quizModes.map((mode, index) => {
              const Icon = mode.icon;
              return (
                <motion.div
                  key={index}
                  initial={{ opacity: 0, scale: 0.9 }}
                  whileInView={{ opacity: 1, scale: 1 }}
                  viewport={{ once: true }}
                  transition={{ delay: index * 0.05 }}
                  whileHover={{ scale: 1.05 }}
                >
                  <GlassCard className="p-6 h-full" blur="md" hover>
                    <div className="flex flex-col items-center text-center space-y-3">
                      <div className="w-14 h-14 rounded-xl bg-gradient-to-br from-primary/20 to-secondary/20 flex items-center justify-center">
                        <Icon className="w-7 h-7 text-primary" />
                      </div>
                      <h3 className="font-semibold text-slate-900 dark:text-white">
                        {mode.title}
                      </h3>
                      <p className="text-sm text-slate-600 dark:text-slate-400">
                        {mode.description}
                      </p>
                    </div>
                  </GlassCard>
                </motion.div>
              );
            })}
          </div>
        </section>

        {/* Additional Features */}
        <section className="mb-20">
          <motion.div
            className="text-center mb-12"
            initial={{ opacity: 0 }}
            whileInView={{ opacity: 1 }}
            viewport={{ once: true }}
          >
            <h2 className="text-3xl md:text-4xl font-heading font-bold mb-4">
              Even <span className="gradient-text">More Features</span>
            </h2>
            <p className="text-lg text-slate-700 dark:text-slate-300">
              Everything you need for an exceptional learning experience
            </p>
          </motion.div>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {additionalFeatures.map((feature, index) => {
              const Icon = feature.icon;
              return (
                <motion.div
                  key={index}
                  initial={{ opacity: 0, x: -20 }}
                  whileInView={{ opacity: 1, x: 0 }}
                  viewport={{ once: true }}
                  transition={{ delay: index * 0.1 }}
                >
                  <GlassCard className="p-6" blur="md" hover>
                    <div className="flex items-start gap-4">
                      <div className="w-12 h-12 rounded-lg bg-gradient-to-br from-primary/20 to-accent/20 flex items-center justify-center flex-shrink-0">
                        <Icon className="w-6 h-6 text-primary" />
                      </div>
                      <div>
                        <h3 className="font-semibold mb-2 text-slate-900 dark:text-white">
                          {feature.title}
                        </h3>
                        <p className="text-sm text-slate-700 dark:text-slate-400">
                          {feature.description}
                        </p>
                      </div>
                    </div>
                  </GlassCard>
                </motion.div>
              );
            })}
          </div>
        </section>

        {/* CTA Section */}
        <motion.div
          className="text-center"
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
        >
          <GlassCard className="p-12 max-w-3xl mx-auto" blur="xl">
            <Play className="w-16 h-16 text-primary mx-auto mb-6" />
            <h2 className="text-3xl md:text-4xl font-heading font-bold mb-4">
              Ready to Start <span className="gradient-text">Learning?</span>
            </h2>
            <p className="text-lg text-slate-700 dark:text-slate-300 mb-8">
              Join thousands of learners who are already transforming their education with mQuiz
            </p>
            <a
              href="/download"
              className="inline-flex items-center gap-2 px-8 py-4 bg-gradient-to-r from-primary to-secondary text-white font-semibold rounded-xl hover:shadow-lg transition-all"
            >
              Download App Now
              <Play className="w-5 h-5" />
            </a>
          </GlassCard>
        </motion.div>
      </div>
    </>
  );
};

export default Features;
